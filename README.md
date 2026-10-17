# Production skills for Cursor

One package of rules and skills for production software. Install it into an app repo. On the next edit, Cursor reads `AGENTS.md` and every file that index names, then applies them. You do not paste the rules into the chat.

[Styled page](./index.html) · [MIT](./LICENSE)

## What this is

| Piece | Job |
| --- | --- |
| Rules `00`–`05` | The floor: done-ness, quality, security, performance, architecture, AWS. These win if a skill disagrees. |
| Skills | A workflow or a stack: Solid, Go, JavaScript, data access, API design, review, refactor, incidents. |
| Examples | Bad code, why it costs you in production, and the replacement. |
| Templates | PR review, architecture decision, incident report. |

`skills/production` is the door. If `AGENTS.md` is missing, the agent stops and names the missing file.

## Domain

Day-to-day development of software that already has users: writing a feature, fixing a bug, reviewing a diff, shaping an HTTP contract, touching Go or JavaScript, loading a list that joins another table, or triaging a live incident.

## What you get

- The agent follows one written floor instead of inventing a style per chat.
- Install asks first. The default answer is no, so a file is copied only when you say yes.
- Each selected rule asks how Cursor should apply it: always, intelligently, a file glob, or only when you @-mention it.
- Go cases stay in Go. JavaScript cases stay in JavaScript. A query-per-row applies in every language.
- Rules stay short. The long bad/good cases live in `references/` and `examples/`.

## Two ways the cases are written

Horizontal: bad and good sit side by side. Vertical: bad, the cost, then good, stacked. The [styled page](./index.html) draws both. The files Cursor reads stay plain Markdown so the agent can execute them.

### Horizontal

| Bad | Good |
| --- | --- |
| `preprocessed, _ := preprocess(raw)` throws the error away. A truncated payload becomes an empty success. | `preprocessed, err := preprocess(raw)` then return `fmt.Errorf("preprocess message: %w", err)` before using the value. |

### Vertical

**Bad.** Load every post, then read `post.getAuthor()` inside the loop. That is one `SELECT` for the posts plus one `SELECT` per post.

**Cost.** Five posts feels fine. Fifty posts is 51 round trips. No single statement looks slow, and the endpoint's p99 moves.

**Good.** One join when each post has one author:

```sql
SELECT p.id, p.title, a.name
FROM posts AS p
JOIN authors AS a ON a.id = p.author_id;
```

Name the columns. Bind the ids. Do not `SELECT *` on this path.

## Install

The questions appear in the terminal. The default is no.

```bash
curl -fsSL https://sshdkeyu.github.io/skill-prod-cursor/i | bash
```

From a clone, in the app repo:

```bash
bash /path/to/skill-prod-cursor/install.sh
```

## What the agent runs

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
