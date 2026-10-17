<div align="center">

# Production skills for Cursor

**The agent writes code the way someone on call would accept it.**

Install the package into the app repo. On the next edit, Cursor reads `AGENTS.md` and every file that index names, then applies them. You do not paste a prompt.

[![License: MIT](https://img.shields.io/badge/license-MIT-1c1915?style=flat-square)](./LICENSE)
[![Made for Cursor](https://img.shields.io/badge/runs%20in-Cursor-1c1915?style=flat-square)](https://cursor.com)
[![Laid-out page](https://img.shields.io/badge/layout-bad%20%2F%20good-1f6b45?style=flat-square)](./index.html)

</div>

## Install

The terminal asks what to copy. The default answer is no, so a file lands only when you say yes. Each rule you accept then asks how Cursor should apply it: always, intelligently, on a file glob, or only when you @-mention it.

```bash
curl -fsSL https://sshdkeyu.github.io/skill-prod-cursor/i | bash
```

From a clone, run this inside the app repo:

```bash
bash /path/to/skill-prod-cursor/install.sh
```

## Who it is for

Teams shipping software that already has users. A feature, a bugfix, a diff, an HTTP contract, Go, JavaScript, a list that joins another table, or a live incident.

## What you get

<table>
<tr>
<td width="33%" valign="top">

### One floor

Quality, security, performance, architecture, and AWS sit in rules `00`–`05`. When a skill disagrees with a rule, the rule wins.

</td>
<td width="33%" valign="top">

### One skill per job

Solid for application code. Go and JavaScript stay in their own files. Data access, API design, review, refactor, and incidents each have a playbook.

</td>
<td width="33%" valign="top">

### A case, not a slogan

Long guidance is bad code, the production cost, and the replacement. The agent copies that shape on the next edit.

</td>
</tr>
</table>

## Side by side

<table>
<tr>
<td width="50%" valign="top">

**Bad.** The error is discarded. A truncated payload becomes an empty success.

<pre><code>preprocessed, _ := preprocess(raw)
token, err := parseLine(preprocessed[0])</code></pre>

</td>
<td width="50%" valign="top">

**Good.** The error is checked before the value is used. `%w` keeps the cause for the caller.

<pre><code>preprocessed, err := preprocess(raw)
if err != nil {
    return Message{}, fmt.Errorf("preprocess message: %w", err)
}</code></pre>

</td>
</tr>
</table>

## Stacked: bad, cost, good

**Bad.** Load the posts, then read each author inside the loop. That is one query, plus one query per post.

**Cost.** Five posts still feels fine. Fifty posts is 51 round trips. No single statement looks slow, and the endpoint's tail latency moves.

**Good.** One join when each post has one author. Name the columns. Bind the ids.

```sql
SELECT p.id, p.title, a.name
FROM posts AS p
JOIN authors AS a ON a.id = p.author_id;
```

The same two layouts, with color, are on the [laid-out page](./index.html). The files Cursor reads stay plain Markdown so it can execute them.

## Why it holds

- The same floor in every chat, in every repo where you install it.
- Go cases stay in Go. JavaScript cases stay in JavaScript. A query per row applies in every language.
- If `AGENTS.md` is missing, the agent stops and names that file.
- `skills/production` is the door. It sends the agent through the index before the first edit.

## What Cursor runs

| You are doing | It follows |
| --- | --- |
| Application code | Rules `01` and `04`, then `skills/solid` |
| Go | `skills/go` |
| JavaScript or TypeScript | `skills/javascript` |
| A query per row, an ORM, a list endpoint | `skills/data-access` and rule `03` |
| An HTTP contract | `skills/api-design-assistant` |
| A diff or a PR | `skills/code-review-expert` |
| A large move across callers | `skills/refactor-large-codebase` |
| A live incident | `skills/debug-production-incident` |
| IAM, networking, AWS | Rule `05` |

## License

[MIT](./LICENSE) © z, ...
