# javascript

Worked JavaScript and TypeScript cases: a mistake, why it bites in production, and the correction. The short playbook is [`SKILL.md`](./SKILL.md). The cases are [`references/bad-vs-good.md`](references/bad-vs-good.md).

Where a loose tip and the stricter TypeScript cases disagree, follow the TypeScript case. In particular the reference does not hoist `var` out of the loop, does not treat a regex strip as an XSS fix, and does not replace loops with `forEach`.
