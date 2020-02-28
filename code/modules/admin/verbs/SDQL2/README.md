# SDQL2
Welcome admins, badmins, and coders alike, to Structured Datum Query Language. SDQL allows you to powerfully run code on batches of objects (or single objects, as it's still unmatched even there.) When I say "powerfully", I mean it. You're in for a ride.

## Crash course
### Select
Okay so say you want to get a list of every mob. How does one do this?
```sql
SELECT /mob
```
This will open a list of every object in world that is a `/mob`. And you can VV them if you need.

What if you want to get every mob on a *specific z-level*?
```sql
SELECT /mob WHERE z == 4
```

What if you want to select every mob on even numbered z-levels?
```sql
SELECT /mob WHERE z % 2 == 0
```

Can you see where this is going? You can select objects with an arbitrary expression. These expressions can also do variable access and proc calls (yes, both on-object and globals!). Keep reading!

### In, where, and *
Okay. What if you want to get every machine in the `SSmachine` process list? Looping through world is kinda slow.

```sql
SELECT * IN SSmachines.processing
```

Here `*` as type functions as a wildcard. We know everything in the global `SSmachines.processing` list is a machine.

You can specify `IN <expression>` to return a list to operate on. This can be any list that you can wizard together from global variables and global proc calls. Every variable/proc name in the `IN` block is global. It can also be a single object, in which case the object is wrapped in a list for you. So yeah SDQL is unironically better than VV for complex single-object operations.

You can of course combine these.
```sql
SELECT * IN SSmachines.processing WHERE z == 4
SELECT * IN SSmachines.processing WHERE stat & 2 // (2 is NOPOWER, cannot use defines from SDQL. Sorry!)
SELECT * IN SSmachines.processing WHERE stat & 2 && z == 4
```

The possibilities are endless (just don't crash the server, okay?).

### Map and selector arrays
Oh it gets better.

You can use `MAP <expression>` to run some code per object and use the result. For example:

```sql
SELECT /obj/machinery/power/smes MAP [charge / capacity * 100, RCon_tag, src]
```

This will give you a list of all the APCs, their charge, AND RCon tag. Useful eh?

`[]` being a list here. Yeah you can write out lists directly without > lol lists in VV. Color matrix
shenanigans inbound.

After the `MAP` segment is executed, the rest of the query executes as if it's THAT object you just made
(here the list).
Yeah, by the way, you can chain these `MAP` / `WHERE` things FOREVER!

```sql
SELECT /mob WHERE client MAP client WHERE holder MAP holder
```

You can also generate a new list on the fly using a selector array. `@[]` will generate a list of objects based off the selector provided.

```sql
SELECT /mob/living IN (@[/area/crew_quarters/bar MAP contents])[1]
```

### Delete

What if some dumbass admin spawned a bajillion spiders and you need to kill them all?
Oh yeah you'd rather not delete all the spiders in maintenance. Only that one room the spiders were
spawned in.

```sql
DELETE /mob/living/carbon/superior_animal/giant_spider WHERE loc.loc == marked
```

Here I used VV to mark the area they were in, and since `loc.loc == area`, voila.
Only the spiders in a specific area are gone.

Or you know if you want to catch spiders that crawled into lockers too (how even?)

```sql
DELETE /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked
```

### Function calls
What else can you do?

Well suppose you'd rather gib those spiders instead of simply flat deleting them...

```sql
CALL gib() ON /mob/living/carbon/superior_animal/giant_spider WHERE global.get_area(src) == marked
```

Or you can have some fun..

```sql
CALL forceMove(marked) ON /mob/living/carbon/superior_animal
```

You can also run multiple queries sequentially:

```sql
CALL forceMove(marked) ON /mob/living/carbon/superior_animal; CALL gib() ON /mob/living/carbon/superior_animal
```

And finally, you can directly modify variables on objects.

```sql
UPDATE /mob WHERE client SET client.color = [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]
```

Don't crash the server, OK?

### Warning!

A quick recommendation: before you run something like a `DELETE` or another query, run it through `SELECT` first. You'd rather not gib every player on accident. Or crash the server.

By the way, queries are slow and take a while. Be patient. They don't hang the entire server though.

With great power comes great responsibility.

## Formal reference
Here's a slightly more formal quick reference.

The 4 queries you can do are:

```sql
SELECT <selectors>
CALL <proc call> ON <selectors>
UPDATE <selectors> SET var=<value>,var2=<value>
DELETE <selectors>
```

`<selectors>` in this context is `<type> [IN <source>] [chain of MAP/WHERE modifiers]`

`IN` (or `FROM`, that works too but it's kinda weird to read) is the list of objects to work on. This defaults to world if not provided. But doing something like `IN living_mob_list` is quite handy and can optimize your query.

All names inside the `IN` block are global scope, so you can do `living_mob_list` (a global var) easily. You can also run it on a single object. Because SDQL is that convenient even for single operations.

`<type>` filters out objects of, well, that type easily. `*` is a wildcard and just takes everything in
the source list.

And then there's the `MAP`/`WHERE` chain. These operate on each individual object being ran through the query. They're both expressions like IN, but unlike it the expression is scoped *on the object*. So if you do `WHERE z == 4`, this does `src.z`, effectively. If you want to access global variables, you can do `global.living_mob_list`. Same goes for procs.

`MAP` "changes" the object into the result of the expression.
`WHERE` "drops" the object if the expression is falsey (`0`, `null` or `""`)

What can you do inside expressions?

* Proc calls
* Variable reads
* Literals (numbers, strings, type paths, etc...)
* `\ref` referencing: `{0x30000cc}` grabs the object with `\ref [0x30000cc]`
* Lists: `[a, b, c]` or `[a: b, c: d]`
* Math and stuff.
* A few special variables: src (the object currently scoped on), `usr` (your mob),
`marked` (your marked datum), `global`(global scope)

### TG additions
Add USING keyword to the front of the query to use options system. The defaults aren't necessarily implemented, as there is no need to.
Available options: (D) means default
- PROCCALL = (D)ASYNC, BLOCKING
- SELECT = FORCE_NULLS, (D)SKIP_NULLS
- PRIORITY = HIGH, (D) NORMAL
- AUTOGC = (D) AUTOGC, KEEP_ALIVE
- SEQUENTIAL = TRUE - The queries in this batch will be executed sequentially one by one not in parallel

Example: 
```sql
USING PROCCALL = BLOCKING, SELECT = FORCE_NULLS, PRIORITY = HIGH SELECT /mob FROM world WHERE z == 1
```
