# Production skills package

This repository is one package. Rules, skills, examples, and templates are the same set. Before the first edit in a session, read every file listed below. Do not answer a coding question from memory of this index.

If two files disagree, `.cursor/rules/00-global-standards.mdc` through `05-cloud-aws.mdc` win. A skill adds a workflow or a stack. It does not replace a rule.

## Read first (the floor)

- `.cursor/rules/00-global-standards.mdc`
- `.cursor/rules/01-code-quality.mdc`
- `.cursor/rules/02-security.mdc`
- `.cursor/rules/03-performance.mdc`
- `.cursor/rules/04-architecture.mdc`
- `.cursor/rules/05-cloud-aws.mdc`

## Read next (every skill)

- `skills/solid/SKILL.md`
- `skills/solid/references/tdd.md`
- `skills/solid/references/testing.md`
- `skills/solid/references/solid-principles.md`
- `skills/solid/references/code-smells.md`
- `skills/solid/references/object-design.md`
- `skills/solid/references/complexity.md`
- `skills/go/SKILL.md`
- `skills/go/references/bad-vs-good.md`
- `skills/javascript/SKILL.md`
- `skills/javascript/references/bad-vs-good.md`
- `skills/data-access/SKILL.md`
- `skills/data-access/references/bad-vs-good.md`
- `skills/api-design-assistant/SKILL.md`
- `skills/code-review-expert/SKILL.md`
- `skills/refactor-large-codebase/SKILL.md`
- `skills/debug-production-incident/SKILL.md`

## Read with them (examples and templates)

- `examples/bad-vs-good-api-design.md`
- `examples/scaling-example.md`
- `.cursor/templates/pr-review-template.md`
- `.cursor/templates/architecture-doc-template.md`
- `.cursor/templates/incident-report-template.md`

## Which file governs what

| You are doing | Follow |
| --- | --- |
| Any application code | Rules `01` and `04`, then `skills/solid` |
| Go | `skills/go` on top of the rules |
| JavaScript or TypeScript | `skills/javascript` on top of the rules |
| A query per row, an ORM, a list endpoint | `skills/data-access` and rule `03` |
| An HTTP contract | `skills/api-design-assistant` and `examples/bad-vs-good-api-design.md` |
| A diff or a PR | `skills/code-review-expert` and `.cursor/templates/pr-review-template.md` |
| A large move across callers | `skills/refactor-large-codebase` |
| A live incident | `skills/debug-production-incident` and `.cursor/templates/incident-report-template.md` |
| IaC, IAM, AWS | Rule `05` |

Go cases do not apply to JavaScript. JavaScript cases do not apply to Go. Data-access cases apply in every language.

## Install so this file still resolves

Copy the repository as a tree. Paths above are from the workspace root. Copying a single skill folder drops the files this index names.

```bash
cp AGENTS.md /path/to/app/AGENTS.md
cp -R skills /path/to/app/skills
cp -R examples /path/to/app/examples
cp -R .cursor/rules /path/to/app/.cursor/rules
cp -R .cursor/templates /path/to/app/.cursor/templates
```
