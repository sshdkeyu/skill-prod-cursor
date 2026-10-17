# Example: Bad vs. Good Data Access

A worked reference for the `data-access` skill. Each case shows a common mistake, why it bites in production, and the corrected version.

N+1 is one query for the parents plus one query per parent for the same relation. Each extra query is small, so a slow-query log stays quiet while the request burns a round trip per row.

---

## 1. A query hidden in the loop

**Bad**

```java
List<Post> posts = postRepository.findAll();
for (Post post : posts) {
    Author author = post.getAuthor(); // lazy load, one SELECT per post
    render(post.getTitle(), author.getName());
}
```

```sql
SELECT id, title FROM posts;
SELECT id, name FROM authors WHERE id = 1;
SELECT id, name FROM authors WHERE id = 2;
-- ... N times
```

**Why it's bad:** The code reads like a loop over objects. With 5 posts it feels fine. With 50 it is 51 round trips, the pool queue grows, and the endpoint's p99 moves while no single statement looks slow. The same shape exists without an ORM: a `SELECT` inside the loop, including `Hibernate.initialize` on each element.

**Good**

```sql
SELECT p.id, p.title, a.name
FROM posts AS p
JOIN authors AS a ON a.id = p.author_id;
```

One statement when each post has one author. When you need the children of many parents and a join would multiply rows, use two statements and group in memory:

```sql
SELECT id, title FROM posts WHERE published = true;
SELECT post_id, body FROM comments WHERE post_id IN (?, ?, ?);
```

```text
commentsByPost = group comments by post_id
for post in posts:
    post.comments = commentsByPost[post.id] or []
```

Name the columns. Do not `SELECT *` on this path. The `IN` list is a bound parameter list, never string-concatenated ids.

---

## 2. Eager on the mapping, for every caller

**Bad**

```java
@ManyToOne(fetch = FetchType.EAGER)
@JoinColumn(name = "author_id")
private Author author;
```

**Why it's bad:** Every load of `Post` now joins `authors`, including the endpoint that only needed the title. A `OneToMany` marked eager is worse: listing posts and their comments and their tags multiplies rows (100 posts × 20 comments × 3 tags). Memory and the page size both lie. Several answers to the ORM question say "make it eager" as the whole fix. That changes every caller.

**Good**

Leave the mapping lazy. Fetch the relation on the query that needs it:

```java
@Query("SELECT p FROM Post p JOIN FETCH p.author WHERE p.published = true")
List<Post> findPublishedWithAuthor();
```

Eager on the mapping only when every use of the entity needs that relation, and the relation is to-one. A batch size (`@BatchSize`) is the middle step when the relation is touched only sometimes: it turns N selects into `ceil(N / batch)` selects. It does not make the access one statement. Prefer the explicit fetch when you already know the request needs the rows.

---

## 3. A join, then a page of rows

**Bad**

```sql
SELECT p.id, p.title, c.body
FROM posts AS p
LEFT JOIN comments AS c ON c.post_id = p.id
ORDER BY p.id
LIMIT 20 OFFSET 0;
```

**Why it's bad:** `LIMIT 20` limits joined rows, not posts. One popular post with 20 comments fills the page. The client asked for 20 posts and received 1. Offset pagination on top of that scans and discards the skipped rows, and inserts between requests shift the page.

**Good**

Page the parents first, then load the children for that page only:

```sql
SELECT id, title
FROM posts
WHERE published = true AND id > ?
ORDER BY id
LIMIT 20;

SELECT post_id, body
FROM comments
WHERE post_id IN (/* the 20 ids just fetched */);
```

Keyset pagination (`id > ?`) stays stable. The second query cannot fan out the page, because the page was already chosen. Chunk the `IN` list if a database caps the number of parameters. An unbounded `IN` of every id in the table is the N+1 problem moved into one statement the planner will not use an index for cleanly.

---

## How you know

- The same statement appears N times in the query log, differing only by id.
- A trace shows a repeated database span under one request. Ten calls at 1 ms each are still 10 ms plus pool time, and they grow with the list.
- The handler is fast on a fixture of 5 rows and slow on 50, with no new code in the loop.

A profiler that only ranks single statements misses this. Count statements per request.

---

## Takeaways

| Principle | Rule of thumb |
| --- | --- |
| No query per row | One statement for a to-one relation. Two statements (`IN` + group) for a to-many. |
| Lazy mapping, eager query | Do not mark a relation eager for every caller. Fetch it on the query that needs it. |
| Batch is a bound, not a join | `@BatchSize` cuts round trips when access is conditional. It is still more than one statement. |
| Page parents, then children | `LIMIT` on a one-to-many join pages rows. Select the parent page first. |
| Count statements | A slow-query log will not catch N fast selects. Look for the repeated shape. |
| Columns and parameters | Name the columns. Bind the `IN` list. Chunk it when it would be huge. |
