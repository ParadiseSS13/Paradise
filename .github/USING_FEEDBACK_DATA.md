# Using Feedback Data

## Introduction

`Feedback` is the name of the data storage system used for logging game statistics to the database. It is managed by `SSblackbox` and can be recorded in many formats. This guide will contain information on how to record feedback data properly, as well as what should and should not be recorded.

## Things you should and should not record

Feedback data can be useful, depending on how you use it. You need to be careful with what you record to make sure you are not saving useless data. Examples of good things to record:

- Antagonist win/loss rates if a new gamemode or antagonist is being added
- Department performance (IE: Slime cores produced in science)
- Basically anything which has actual meaning

Examples of bad things to record:

- Amount of times a wrench is used (Why)
- Hours spent on the server (We have other means of that)
- Basically, just think about it and ask yourself "Is this actually useful to base game design around"

Also note that feedback data **must** be anonymous. The only exception here is for data *anyone* on the server can see, such as round end antagonist reports.

## Feedback Data Recording

Feedback data can be reocrded in 5 formats. `amount`, `associative`, `nested tally`, `tally` and `text`.

### Amount

`amount` is the simplest form of feedback data recording. They are simply a numerical number which increase with each feedback increment. For example:

These DM calls:

```dm
SSblackbox.record_feedback("amount", "example", 8)
SSblackbox.record_feedback("amount", "example", 2)
// Note that you can use negative increments to decrease the value
```

Will produce the following JSON:

```json
{
    "data":10
}
```

Notice the lack of any specific identification other than it being the value of the `data` key. Amounts are designed to be simple with minimal complexity, and are useful for logging statistics such as how many times one specific, distinct action is done (e.g.: How many MMIs have been filled). If you want to log multiple similar things (e.g.: How many mechas have been created, broken down by the mecha type), use a `tally` with a sub-key for each different mecha, instead of an amount with its own key per mecha.

### Associative

`associative` is used to record text that's associated with multiple key-value pairs. (e.g: coordinates). Further calls to the same key will append a new list to existing data. For example:

```dm
SSblackbox.record_feedback("associative", "example", 1, list("text" = "example", "path" = /obj/item, "number" = 4))
SSblackbox.record_feedback("associative", "example", 1, list("number" = 7, "text" = "example", "other text" = "sample"))
```

Will produce the following JSON:

```json
{
    "data":{
        "1":{
            "text":"example",
            "path":"/obj/item",
            "number":"4"
        },
        "2":{
            "number":"7",
            "text":"example",
            "other text":"sample"
        }
    }
}
```

Notice how everything is cast to strings, and each new entry added has its index increased ("1", "2", etc). Also take note how the `increment` parameter is not used here. It does nothing to the data, and `1` is used just as the value for consistency.

### Nested Tally

`nested tally` is used to track the number of occurances of structured semi-relational values (e.g.: the results of arcade machines). You can think of it as a running total, with the key being a list of strings (rather than a single string), with elements incrementally identifying the entity in question.

Technically, the values are nested in a multi-dimensional array. The final element in the data list is used as the tracking key, and all prior elements are used for nesting. Further calls to the same key will add or subtract from the saved value of the data key if it already exists in the same multi-dimensional position, and append the key and it's value if it doesn't exist already. This one is quite complicated, but an example is below:

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
    "data":{
        "fruit":{
            "orange":{
                "apricot":4,
                "orange":2
            },
            "red":{
                "apple":10
            }
        },
        "vegetable":{
            "orange":{
                "carrot":1
            }
        }
    }
}
```

#### NOTE

Tracking values associated with a number can't merge with a nesting value, trying to do so will append the list

```dm
SSblackbox.record_feedback("nested tally", "example", 3, list("fruit", "orange"))
```

Will produce the following JSON:

```json
{
    "data":{
        "fruit":{
            "orange":{
                "apricot":4,
                "orange":2
            },
            "red":{
                "apple":10
            },
            "orange":3
        },
        "vegetable":{
            "orange":{
                "carrot":1
            }
        }
    }
}
```

Avoid doing this, since having duplicate keys in JSON (data.fruit.orange) will break when parsing.

### Tally

`tally` is used to track the number of occurances of multiple related values (e.g.: how many times each type of gun is fired). Further calls to the same key will add or subtract from the saved value of the data key if it already exists, and append the key and it's value if it doesn't exist.

```dm
SSblackbox.record_feedback("tally", "example", 1, "sample data")
SSblackbox.record_feedback("tally", "example", 4, "sample data")
SSblackbox.record_feedback("tally", "example", 2, "other data")
```

Will produce the following JSON:

```json
{
    "data":{
        "sample data":5,
        "other data":2
    }
}
```

### Text

`text` is used for simple single-string records (e.g.: the current chaplain religion). Further calls to the same key will append saved data unless the overwrite argument is true or it already exists. When encoded, calls made with overwrite will lack square brackets.

```dm
SSblackbox.record_feedback("text", "example", 1, "sample text")
SSblackbox.record_feedback("text", "example", 1, "other text")
SSblackbox.record_feedback("text", "example", 1, "sample text")
```

Will produce the following JSON:

```json
{
    "data":[
        "sample text",
        "other text"
    ]
}
```

Note how `"sample text"` only appears once. `text` is a set with no duplicates, instead of a list with duplicates. Also take note how the `increment` parameter is not used here. It does nothing to the data, and `1` is used just as the value for consistency.

## Feedback Versioning

If the logging content (i.e.: What data is logged) for a variable is ever changed, the version needs bumping. This can be done with the `versions` list on the subsystem definition itself. All values default to `1`.

```dm
var/list/versions = list(
    "round_end_stats" = 4,
    "admin_toggle" = 2,
    "gun_fired" = 2)
```

If you are doing a type change (i.e.: Changing from a `tally` to a `nested tally`), **USE AN ENTIRELY NEW KEY NAME**.
