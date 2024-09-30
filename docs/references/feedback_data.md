# Using Feedback Data

## Introduction

`Feedback` is the name of the data storage system used for logging game
statistics to the database. It is managed by `SSblackbox` and can be recorded in
many formats. This guide will contain information on how to record feedback data
properly, as well as what should and should not be recorded.

## Things you should and should not record

Feedback data can be useful, depending on how you use it. You need to be careful
with what you record to make sure you are not saving useless data. Examples of
good things to record:

- Antagonist win/loss rates if a new game mode or antagonist is being added
- Department performance (IE: Slime cores produced in science)
- Basically anything which has actual meaning

Examples of bad things to record:

- Amount of times a wrench is used (Why)
- Hours spent on the server (We have other means of that)
- Basically, just think about it and ask yourself "Is this actually useful to
  base game design around"

Also note that feedback data **must** be anonymous. The only exception here is
for data _anyone_ on the server can see, such as round end antagonist reports.

## Feedback Data Recording

Feedback data can be recorded in 7 formats. `amount`, `associative`,
`nested tally`, `tally` `text`, `ledger`, and `nested ledger`.

### Amount

`amount` is the simplest form of feedback data recording. They are simply a
numerical number which increase with each feedback increment. For example:

These DM calls:

```dm
SSblackbox.record_feedback("amount", "example", 8)
SSblackbox.record_feedback("amount", "example", 2)
// Note that you can use negative increments to decrease the value
```

Will produce the following JSON:

```json
{
	"data": 10
}
```

Notice the lack of any specific identification other than it being the value of
the `data` key. Amounts are designed to be simple with minimal complexity, and
are useful for logging statistics such as how many times one specific, distinct
action is done (e.g.: How many MMIs have been filled). If you want to log
multiple similar things (e.g.: How many mechas have been created, broken down by
the mecha type), use a `tally` with a sub-key for each different mecha, instead
of an amount with its own key per mecha.

### Associative

`associative` is used to record text that's associated with multiple key-value
pairs. (e.g: coordinates). Further calls to the same key will append a new list
to existing data. For example:

```dm
SSblackbox.record_feedback("associative", "example", 1, list("text" = "example", "path" = /obj/item, "number" = 4))
SSblackbox.record_feedback("associative", "example", 1, list("number" = 7, "text" = "example", "other text" = "sample"))
```

Will produce the following JSON:

```json
{
	"data": {
		"1": {
			"text": "example",
			"path": "/obj/item",
			"number": "4"
		},
		"2": {
			"number": "7",
			"text": "example",
			"other text": "sample"
		}
	}
}
```

Notice how everything is cast to strings, and each new entry added has its index
increased ("1", "2", etc). Also take note how the `increment` parameter is not
used here. It does nothing to the data, and `1` is used just as the value for
consistency.

### Nested Tally

`nested tally` is used to track the number of occurrences of structured
semi-relational values (e.g.: the results of arcade machines). You can think of
it as a running total, with the key being a list of strings (rather than a
single string), with elements incrementally identifying the entity in question.

Technically, the values are nested in a multi-dimensional array. The final
element in the data list is used as the tracking key, and all prior elements are
used for nesting. Further calls to the same key will add or subtract from the
saved value of the data key if it already exists in the same multi-dimensional
position, and append the key and it's value if it doesn't exist already. This
one is quite complicated, but an example is below:

```dm
SSblackbox.record_feedback("nested tally", "example", 1, list("fruit", "orange", "apricot"))
SSblackbox.record_feedback("nested tally", "example", 2, list("fruit", "orange", "orange"))
SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange", "apricot"))
SSblackbox.record_feedback("nested tally", "example", 10, list("fruit", "red", "apple"))
SSblackbox.record_feedback("nested tally", "example", 1, list("vegetable", "orange", "carrot"))
```

Will produce the following JSON:

```json
{
	"data": {
		"fruit": {
			"orange": {
				"apricot": 4,
				"orange": 2
			},
			"red": {
				"apple": 10
			}
		},
		"vegetable": {
			"orange": {
				"carrot": 1
			}
		}
	}
}
```

!!! note

    Tracking values associated with a number can't merge with a nesting value,
    trying to do so will append to the list.

```dm
SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange"))
```

Will produce the following JSON:

```json
{
	"data": {
		"fruit": {
			"orange": {
				"apricot": 4,
				"orange": 2
			},
			"red": {
				"apple": 10
			},
			"orange": 3
		},
		"vegetable": {
			"orange": {
				"carrot": 1
			}
		}
	}
}
```

Avoid doing this, since having duplicate keys in JSON (data.fruit.orange) will
break when parsing.

### Tally

`tally` is used to track the number of occurrences of multiple related values
(e.g.: how many times each type of gun is fired). Further calls to the same key
will add or subtract from the saved value of the data key if it already exists,
and append the key and it's value if it doesn't exist.

```dm
SSblackbox.record_feedback("tally", "example", 1, "sample data")
SSblackbox.record_feedback("tally", "example", 4, "sample data")
SSblackbox.record_feedback("tally", "example", 2, "other data")
```

Will produce the following JSON:

```json
{
	"data": {
		"sample data": 5,
		"other data": 2
	}
}
```

### Text

`text` is used for simple single-string records (e.g.: the current chaplain
religion). Further calls to the same key will append saved data unless the
overwrite argument is true or it already exists. When encoded, calls made with
overwrite will lack square brackets.

```dm
SSblackbox.record_feedback("text", "example", 1, "sample text")
SSblackbox.record_feedback("text", "example", 1, "other text")
SSblackbox.record_feedback("text", "example", 1, "sample text")
```

Will produce the following JSON:

```json
{
	"data": ["sample text", "other text"]
}
```

Note how `"sample text"` only appears once. `text` is a set with no duplicates,
instead of a list with duplicates. Also take note how the `increment` parameter
is not used here. It does nothing to the data, and `1` is used just as the value
for consistency.

### Ledger

!!! warning

    The `ledger` and `nested ledger` feedback types should only be used as a
    last resort. The primary intent of the blackbox system is to track the
    number of times something has happened. It is extremely rare that one should
    require the granularity provided by these feedback types accumulating
    multiple discrete statistics on a single row. They are provided as an escape
    hatch for unusual situations, and to avoid unnecessary repetition of text in
    the JSON.

`ledger` is used for appending entries to a record. It is effectively the same
as `tally`, except instead of adding the value to the existing one, it stores
the value of each call in a list. This is useful for situations where you have a
specific key for which you'd like to store a unique value for each time the key
is used in feedback. For example, if the clown puts on multiple comedy shows and
you want to record the attendance for each one:

```dm
SSblackbox.record_feedback("ledger", "tickets_sold_per_show", 15, "general_admission")
SSblackbox.record_feedback("ledger", "tickets_sold_per_show", 5, "front_row")
SSblackbox.record_feedback("ledger", "tickets_sold_per_show", 20, "general_admission")
SSblackbox.record_feedback("ledger", "tickets_sold_per_show", 2, "front_row")
```

Will produce the following JSON:

```json
{
	"data": {
		"tickets_sold_per_show": {
			"general_admission": [15, 20],
			"front_row": [5, 2]
		}
	}
}
```

Note that items here may be text. Unlike the `text` feedback type, items are added in order and duplicates are permitted.

```dm
SSblackbox.record_feedback("ledger", "menu_items", "fried eggs", "breakfast")
SSblackbox.record_feedback("ledger", "menu_items", "coffee", "breakfast")
SSblackbox.record_feedback("ledger", "menu_items", "hamburgers", "lunch")
SSblackbox.record_feedback("ledger", "menu_items", "french fries", "lunch")
```

Will produce the following JSON:

```json
{
	"data": {
		"breakfast": ["fried eggs", "coffee"],
		"lunch": ["hamburgers", "french fries"]
	}
}
```

### Nested Ledger

`nested ledger` uses the logic of `nested tally`, except instead of adding the value to the last element, it uses the last element as the tracking key for a list of items, appending each one. For example, if you wanted to store individual crew ratings for meals made by different chefs:

```dm
SSblackbox.record_feedback("nested ledger", "meal_ratings", 5, list("Chef Marceau", "hamburger"))
SSblackbox.record_feedback("nested ledger", "meal_ratings", 2, list("Chef Marceau", "hamburger"))
SSblackbox.record_feedback("nested ledger", "meal_ratings", 1, list("Chef Poincare", "hamburger"))
SSblackbox.record_feedback("nested ledger", "meal_ratings", 3, list("Chef Poincare", "hamburger"))
```

Will produce the following JSON:

```json
{
	"data": {
		"Chef Marceau": { "hamburger": [5, 2] },
		"Chef Poincare": { "hamburger": [1, 3] }
	}
}
```

As with `ledger`, text values may be accumulated in this manner.

### Appropriate use of `ledger`

If one were tracking the individual center coordinates of each ruin placed, and
the same ruin may be placed more thanonce, use of the `associative` feedback
type may result in this implementation:

```dm
var/coord_string = "[central_turf.x],[central_turf.y],[central_turf.z]"
SSblackbox.record_feedback("associative", "ruin_placement", 1, list(
	"map" = map_filename,
	"coords" = coord_string
))
```

returning the following JSON:

```json
{
	"data": {
		"1": { "map": "listeningpost.dmm", "coords": "127,169,5" },
		"2": { "map": "listeningpost.dmm", "coords": "64,134,4" }
	}
}
```

This creates unnecessary repetition of the map name, as well as the `"map"` and `"coords"` keys. As well, the numeric keys associated with each row are meaningless. Using `ledger` may transform this into:

```dm
var/coord_string = "[central_turf.x],[central_turf.y],[central_turf.z]"
SSblackbox.record_feedback("ledger", "ruin_placement", coord_string, map_filename)
```

returning the following JSON:

```json
{
	"data": {
		"listeningpost.dmm": ["127,169,5", "64,134,4"]
	}
}
```

## Feedback Versioning

If the logging content (i.e.: What data is logged) for a variable is ever
changed, the version needs bumping. This can be done with the `versions` list on
the subsystem definition itself. All values default to `1`.

```dm
var/list/versions = list(
    "round_end_stats" = 4,
    "admin_toggle" = 2,
    "gun_fired" = 2)
```

If you are doing a type change (i.e.: Changing from a `tally` to a `nested
tally`), **USE AN ENTIRELY NEW KEY NAME**.
