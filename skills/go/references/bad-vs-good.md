# Example: Bad vs. Good Go

A worked reference for the `go` skill. Each case shows a common mistake, why it bites in production, and the corrected version.

The source post's later edit matters: one goroutine per line looked faster on a small fixture and then lost to context switches. Parallelism here is bounded, or it waits for a benchmark.

---

## 1. Discarded errors

**Bad**

```go
preprocessed, _ := preprocess(raw)
token, err := parseLine(preprocessed[0])
if err != nil {
    return Message{}, fmt.Errorf("Input is empty.")
}
```

**Why it's bad:** The preprocess failure is thrown away, so a truncated payload becomes a successful empty message. The error text is capitalized and punctuated, which breaks callers that match `errors.Is` style strings and log pipelines that expect the Go convention. A static error does not need `fmt.Errorf`.

**Good**

```go
preprocessed, err := preprocess(raw)
if err != nil {
    return Message{}, fmt.Errorf("preprocess message: %w", err)
}
if len(preprocessed) == 0 {
    return Message{}, errors.New("input is empty")
}
```

Check the error before using the value. Wrap with `%w` when the caller needs the cause. Use `errors.New` for a fixed string: lowercase, no period.

---

## 2. Goroutines mutating one struct

**Bad**

```go
var msg Message
for _, line := range lines {
    go func(line []byte) {
        msg.Fields = append(msg.Fields, parseField(line))
    }(line)
}
```

**Why it's bad:** Several goroutines append to the same slice. That is a data race: lost fields, a torn slice header, or a crash under `-race` that you will not see in a short test. Locking every append puts a mutex on the hot path and still shares the cache line.

**Good**

```go
results := make(chan Field, len(lines))
for _, line := range lines {
    go func(line []byte) {
        results <- parseField(line)
    }(line)
}
msg := Message{}
for range lines {
    msg.Fields = append(msg.Fields, <-results)
}
```

The parent owns `msg`. Workers only send values. Do not use this shape until case 3 bounds the number of goroutines.

---

## 3. One goroutine per input row

**Bad**

```go
for _, line := range lines {
    go mapLine(line, ch)
}
```

**Why it's bad:** An ADEXP-sized fixture hides the cost. A large upload or a hot endpoint starts one goroutine per line, then spends the time in context switches and stacks. The source post measured a win, then withdrew this pattern for that reason.

**Good**

```go
const workers = 8

jobs := make(chan []byte)
var wg sync.WaitGroup
for i := 0; i < workers; i++ {
    wg.Add(1)
    go func() {
        defer wg.Done()
        for line := range jobs {
            ch <- mapLine(line)
        }
    }()
}
for _, line := range lines {
    jobs <- line
}
close(jobs)
wg.Wait()
```

Cap the workers. If the input is small or the work is cheap, a plain loop is the right version until a benchmark on production-sized input says otherwise.

---

## 4. Forcing a string on bytes you already have

**Bad**

```go
func Parse(raw string) (Message, error) {
    return preprocess(raw)
}
// caller, after a TCP read:
msg, err := Parse(string(buf))
```

**Why it's bad:** The bytes on the wire are copied into a string, then copied back to bytes for `bytes.Trim` and regexp. On a parse hot path that copy shows up in allocations, not in the algorithm.

**Good**

```go
func Parse(raw []byte) (Message, error) {
    return preprocess(raw)
}
```

Keep `[]byte` until a boundary needs a string (a map key, a log line, a struct field you will retain). A slice header is small. Copying a large struct by value on that same hot path has the same shape: pass the bytes or a pointer, and do not let that pointer escape into another goroutine.

---

## 5. Recursion over untrusted input

**Bad**

```go
func parseComplex(in []byte, cur map[string]string, out []map[string]string) []map[string]string {
    match := subfield.Find(in)
    if match == nil {
        return append(out, cur)
    }
    // ...
    return parseComplex(in[len(match):], cur, out)
}
```

**Why it's bad:** Go does not do tail-call elimination. A deep or hostile payload grows the stack until the process dies. The iterative form returns the same maps.

**Good**

```go
func parseComplex(in []byte) []map[string]string {
    var out []map[string]string
    cur := map[string]string{}
    for _, match := range subfield.FindAll(in, -1) {
        key, val := parseLine(match)
        if _, exists := cur[string(key)]; exists {
            out = append(out, cur)
            cur = map[string]string{}
        }
        cur[string(key)] = string(bytes.TrimSpace(val))
    }
    return append(out, cur)
}
```

Iterate. Bound `FindAll` if the pattern can match without consuming input.

---

## 6. A switch that drops unknown tokens

**Bad**

```go
switch token {
case tokenTitle:
    msg.Title = value
case tokenAdep:
    msg.Adep = value
}
```

**Why it's bad:** A new or corrupt token is ignored. The message still parses. Downstream treats the missing field as "not present" and acts on a partial flight plan.

**Good**

```go
switch token {
case tokenTitle:
    msg.Title = value
case tokenAdep:
    msg.Adep = value
default:
    return Message{}, fmt.Errorf("unexpected token %q", token)
}
```

Fail the parse. Log the token value, not the whole message, if the payload can contain personal data.

---

## Takeaways

| Principle | Rule of thumb |
| --- | --- |
| Errors are values | Check every `err` before using the other result. Wrap with `%w`. Static text is `errors.New`, lowercase, no period. |
| Share by communicating | One goroutine owns a struct. Workers send results. |
| Bound concurrency | A fixed worker count, or a sequential loop until a benchmark says otherwise. |
| Don't recopy the payload | Stay in `[]byte` until a boundary needs a string. |
| No unbounded recursion | Iterate over input you do not control. Go will not tail-call it for you. |
| Unknown input is an error | A `switch` on external tokens has a `default` that returns. |
