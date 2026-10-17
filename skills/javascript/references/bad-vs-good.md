# Example: Bad vs. Good JavaScript and TypeScript

A worked reference for the `javascript` skill. Each case shows a common mistake, why it bites in production, and the corrected version.

Where a loose tip and these TypeScript cases disagree, follow the case, and rule `02` for HTML.

---

## 1. Loose equality

**Bad**

```js
if (status == "200" || retries == false || count == "") {
  settle(order);
}
```

**Why it's bad:** `==` coerces before comparing. `0 == ""`, `1 == "1"`, and `1 == true` are all true. A missing retry count or a string status can take the success branch and mark an unpaid order settled.

**Good**

```ts
if (status === "200" && retries === 0) {
  settle(order);
}
if (value == null) {
  return;
}
```

Use `===` and `!==` for control flow. `== null` is the one exception: it is true for both `null` and `undefined` and for nothing else.

---

## 2. Types that disappear at runtime

**Bad**

```ts
const user = JSON.parse(body) as User;
user.email.toLowerCase();

const node = document.querySelector("#pay")!;
node.submit();

// @ts-ignore
danger.whoops();
```

**Why it's bad:** `as`, `!`, `any`, and `@ts-ignore` only silence the compiler. `JSON.parse` returns whatever the network sent. A missing `#pay` or a payload without `email` throws in production, in a function that typecheck said was safe.

**Good**

```ts
function readUser(body: string): User {
  const value: unknown = JSON.parse(body);
  if (!isUser(value)) {
    throw new Error("response is not a user");
  }
  return value;
}

const node = document.querySelector("#pay");
if (!(node instanceof HTMLFormElement)) {
  throw new Error("pay form missing");
}
node.submit();
```

Parse to `unknown`, then narrow with a check. A type assertion needs a comment that says why the check already happened. Do not ship `@ts-ignore` or `debugger`.

---

## 3. Parses that keep going after junk

**Bad**

```ts
const qty = parseInt(rawQty, 10);
const price = +rawPrice;
if (qty > 0) charge(qty, price);
```

**Why it's bad:** `parseInt("12 dwarves", 10)` is `12`. Unary `+` is the same class of coercion and is easy to miss in review. `Number("")` is `0`, not `NaN`, so a blank field becomes a free order if you only check `NaN`.

**Good**

```ts
const qty = Number(rawQty);
const price = Number(rawPrice);
if (!Number.isFinite(qty) || !Number.isFinite(price) || qty <= 0) {
  throw new Error("qty and price must be finite numbers");
}
charge(Math.trunc(qty), price);
```

Use `Number`, then reject `NaN` and infinities. Reach for `parseInt` only with an explicit radix other than 10, and only after a pattern has already accepted the whole string.

`new Number(0)`, `new String("")`, and `new Boolean(false)` are objects. `new Boolean(false)` is truthy. Use the primitives.

---

## 4. `for...in` and `||` defaults

**Bad**

```ts
for (const key in payload) {
  apply(key, payload[key]);
}
const seats = requested || 1;
```

**Why it's bad:** `for...in` walks enumerable names on the prototype, and on an array it yields index strings, not values. A payload that inherited an unexpected key gets applied. `||` treats `0` and `""` as missing, so a request for zero extra seats becomes one seat. `??` only replaces `null` and `undefined`.

**Good**

```ts
for (const [key, value] of Object.entries(payload)) {
  apply(key, value);
}
for (const item of items) {
  ship(item);
}
const seats = requested ?? 1;
```

Use `Object.entries` or `Object.keys` for objects and `for...of` for arrays. Prefer `for...of` over `forEach` when TypeScript has to keep a narrowing inside the loop: a closure passed to `forEach` is not guaranteed to run before a later assignment. Use `??` when `0` or `""` is a real value.

---

## 5. User text in HTML

**Bad**

```ts
function sanitize(input: string): string {
  return input.replace(/[<>"']/g, "");
}
element.innerHTML = sanitize(user.name);
```

**Why it's bad:** Stripping a few characters is not an HTML encoder. Encodings, nested tags, and attributes still reach the DOM. Assigning to `innerHTML` parses HTML. The same string in `document.write` does too.

**Good**

```ts
element.textContent = user.name;
```

Put untrusted text in `textContent` (or a framework binding that escapes). If you must emit HTML, encode for that context with a vetted library. Rule `02` is the floor: allow-list, do not strip a few characters and hope.

---

## 6. Swallowed async failures

**Bad**

```ts
function load() {
  fetch("/v1/orders")
    .then((response) => response.json())
    .then((orders) => render(orders));
}

try {
  await charge(card);
} catch {
}
```

**Why it's bad:** A non-2xx body, a network failure, or a rejected charge becomes an unhandled rejection or an empty `catch`. The UI renders nothing, or it renders the error JSON as if it were orders. The caller thinks the function succeeded.

**Good**

```ts
async function load(): Promise<Order[]> {
  const response = await fetch("/v1/orders");
  if (!response.ok) {
    throw new Error(`orders failed: ${response.status}`);
  }
  const body: unknown = await response.json();
  if (!isOrderList(body)) {
    throw new Error("orders response has the wrong shape");
  }
  return body;
}
```

`await` it, check `response.ok`, and narrow the body. An empty `catch` is a discarded error. If you catch, add context and rethrow, or return a typed failure the caller has to handle.

---

## 7. A switch that falls through

**Bad**

```ts
switch (event.type) {
  case "paid":
    capture();
  case "refunded":
    notify();
    break;
}
```

**Why it's bad:** `paid` falls through into `notify` for a refund. There is no `default`, so a new event type does nothing and the process stays healthy.

**Good**

```ts
switch (event.type) {
  case "paid":
    capture();
    break;
  case "refunded":
    notify();
    break;
  default: {
    const never: never = event.type;
    throw new Error(`unexpected event ${never}`);
  }
}
```

End every group with `break` unless the group is empty on purpose (`case "a": case "b":`). A `default` that assigns to `never` fails the build when a union gains a member.

---

## Takeaways

| Principle | Rule of thumb |
| --- | --- |
| No silent coercion | `===` / `!==`. `== null` only when both nullish values mean the same thing. |
| Types are a compile-time claim | `unknown`, then a runtime check. `as`, `!`, `any`, and `@ts-ignore` need a reason written next to them. |
| Parse the whole value | `Number` plus `Number.isFinite`. Do not use `parseInt` or unary `+` on base-10 input. |
| Walk your own keys | `for...of` and `Object.entries`. `??` when zero and empty string are valid. |
| Text is not HTML | `textContent` for user strings. A regex strip is not sanitizing. |
| Async failures are errors | `await`, check `response.ok`, never an empty `catch`. |
| Switches are closed | `break` every group. `default` rejects a type you did not handle. |
