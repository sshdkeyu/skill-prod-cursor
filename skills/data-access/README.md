# data-access

Worked cases for the N+1 query problem: a mistake, why it bites in production, and the correction. The short playbook is [`SKILL.md`](./SKILL.md). The cases are [`references/bad-vs-good.md`](references/bad-vs-good.md).

Rule `03` still wins on column lists and pagination. The cases do not use `SELECT *`. `Hibernate.initialize` inside a loop is still N+1, so it is not a fix here.
