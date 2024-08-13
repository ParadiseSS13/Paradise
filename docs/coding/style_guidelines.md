# Style Guidelines

These guidelines are designed to maintain readability and establish a standard
for future contributions. By following these guidelines, we can reduce the
overhead during the review process and pave the way for future content, fixes,
and more.

## Variables

Variable conventions and naming are an important part of the development
process. We have a few rules for variable naming, some dictated by BYOND itself.
While naming variables can be tough, we ask that variable names are descriptive.
This helps contributors of all different levels understand the code better.
These guidelines only apply to DM, as TGUI uses a different convention. Avoid
using single-letter variables. Variable naming is to follow American English
spelling of words. This means that variables using British English will be
rejected. This is to maintain consistency with BYOND.

Variables written in DM require the use of snake_case, which means words will be
spaced by an underscore while remaining lowercase.

```dm
// An example of a variable written in snake_case
var/example_variable
```

## Strings and Messages

### Strings

When it comes to strings, they should be enclosed in double quotations. Like the
naming convention for variables, American English spelling is to be used.

```dm
var/example_string = "An example of a properly formatted string!"
```

If a string is too long, break it into smaller parts for better readability.
This is especially useful for long descriptions or sentences, making the text
easier to read and understand.

```dm
var/example_long_string = "This is a longer than average string \
                           and how it should be formatted. This \
                           is the method we prefer!"
```

Variables may be incorporated within strings to dynamically convey their values.
This practice is beneficial when the variable's value may change, enhancing
flexibility and maintainability. Avoid hardcoding values directly into strings,
as it is considered poor practice and can lead to less adaptable code.

```dm
// Bad
var/bad_example_string = "There are 20 items in the box."

// Good
var/item_count = 20
var/good_example_string = "There are [item_count] items in the box."
```

### Messages

Messages are anything that is sent to the chat window. This can include system
messages, messages to the user, as well as messages between users.

#### Sending to chat

Though there are multiple ways to send a message to the chat window, only
certain methods will be accepted. Avoid using `<<` when sending information to
the chat window. You can check out other examples throughout the codebase to see
how messages are typically handled.

```dm
// Bad
 world << "Hello World!"

 // Good
 to_chat(world, "Hello World!")

// Also Good
user.visible_message(
    "<span class='notice'>[user] writes Hello World!</span>",
    "<span class='notice'>You write Hello World!.</span>",
    "<span class='notice'>You hear someone writing Hello World!.</span>"
)
```

#### Common Classes

- ``'notice'``: used to convey anything the player should be aware of, including
  actions, successes, and other pertinent information that is non-threatening.
  This also includes information directly unrelated to gameplay.
- ``'warning'``: used for failures, errors, and warnings
- ``'danger'``: danger occurring around the player or to other players, damage
  to things around the player
- ``'userdanger'``: used to convey to the player that they are being attacked or
  damaged

These can be set using in-line span tags.

```dm
proc/my_example_proc
    to_chat(user, "<span class='notice'>Message with the notice style.</span>")
```

You are not limited to the styles listed above. It is important, however, to
evaluate and choose the right style accordingly. You can find additional styles
located within the chat style sheets.

## Comments

Comments are essential for documenting your code. They help others understand
what the code does by explaining its behavior and providing useful details. Use
comments where needed, even if the code seems clear. Proper commenting keeps the
codebase organized and provides valuable context for development.

### Single-Line Comments

Single-line comments are used for brief explanations or notes about the code.
They provide quick, straightforward context to help clarify the code’s purpose
or functionality.

```dm
// This is a single-line comment
```

### Multi-Line Comments

Used for longer explanations or comments spanning multiple lines. Good for
documenting parameters of procs.

```dm
/*
 * This is a multi-line comment.
 * It spans multiple lines and provides detailed explanations.
 */
```

### Autodoc Comments

[Autodoc][] is used for documenting variables, procs, and other elements that
require additional clarification. This is a useful tool, as it allows a coder to
see additional information about a variable or proc without having to navigate
to its declaration. To apply properly, an Autodoc comment should be used
**BEFORE** the actual declaration of a variable or proc.

```dm
/// This is an Autodoc example
var/example_variable = TRUE
```

[Autodoc]: ../references/autodoc.md

### Define Comments

When documenting single-line macros such as constants, use the "enclosing
comment format", `//!`. This prevents issues with macro expansion:

```dm
#define BLUE_KEY 90 //! The access code for the blue key.
```

These constant names can then be referred to in other Autodoc comments by
enclosing their names in brackets:

```dm
/// This door only opens if your access is [BLUE_KEY].
/obj/door/blue
	...
```

### Mark Comments

Used to delineate distinct sections within a file when necessary. It should only
be used for that purpose. Avoid using it for items, procs, or datums.

```dm
// MARK: [Section Name]
```

### Commented Out Code

Commented out code is generally not permitted within the code base unless it is
used for the purpose of debugging. Code that is commented out during a
contribution should be removed prior to creating a pull request. If you are
unsure whether or not something should be left commented out, please contact a
development team member.

## Multi-Line Procs and List Formatting

When calling procs with very long arguments (such as list or proc definitions
with multiple or especially dense arguments), it may sometimes be preferable to
spread them out across multiple lines for clarity. For some more text-heavy
procs where readability of the arguments is especially important (such as
visible_message), you're asked to always multi-line them if you're providing
multiple arguments.

For lists that may be subject to frequent code churn, we suggest adding a
trailing comma as well, as it prevents the line from needing to be changed
unnecessarily down the line.

```dm
// Bad
var/list/numbers = list(
    1, 2, 3)

user.visible_message("<span class='notice'>[user] writes the style guide.</span>",
"<span class='notice'>You wonder if you're following the guide correctly.</span>")

// Good
var/list/numbers = list(
    1,
    2,
    3,
)

user.visible_message(
    "<span class='notice'>[user] writes the style guide.</span>",
    "<span class='notice'>You write the style guide.</span>",
    "<span class='notice'>You hear typing.</span>"
)

// Also good
var/list/letters = list("a", "b", "c")
```

## Indentation

Indentation in DM is used to define code blocks and scopes. Our code base
requiress tab spacing. Singular spacing to the length of four spaces will not be
accepted.

```dm
// Good
for(var/example in 1 to 10)
	if(example > 5)
		to_chat(world, "Higher than five")
	else
		to_chat(world, "Lower than five")
```

Only when it comes to defines, curly braces can be used. This is allowed in some
instances to keep code neat and readable, and to ensure that macros expand
properly regardless of their indentation level in code

```dm
// Good
#define FOO /datum/foo {\
    var/name = "my_foo"}
```

Not only is it easier to write, but the DM compiler also optimizes the preferred
method to run faster than the bad example. Using the DM style loop enhances
readability and aligns with the language’s conventions.

## Operators

### Spacing

Code readability is an important aspect of developing on a large-scale project,
especially when it comes to open-source. As emphasized by other places in this
document, it is important to keep the code as readable as possible. One way we
do that is through spacing. Maintain a single space between all operators and
operands, including during variable declarations and value assignments.

```dm
// Bad
var/example_variable=5

// Also Bad
example_variable=example_variable*2

// Good
var/example_variable = 5

// Also Good
example_variable = example_variable * 2
```

## Boolean Defines

Use `TRUE` and `FALSE` instead of 1 and 0 for booleans. This improves
readability and clarity, making it clear that values represent true or false
conditions.

```dm
// Bad
var/example = 1
	if(example)
		example_proc()

// Good
var/example = TRUE
	if(example)
		example_proc()
```

## File Naming and References

### Naming

When naming files, it is important to keep readability in mind. Use these
guidelines when creating a new file.

- Keep names short (≤ 25 characters).
- Do not add spaces. Use underscores to separate words.
- Do not include special characters such as: " / \ [ ] : ; | = , < ? > & $ # ! ' { } *.

### References

When referencing files, use single quotes (') around the file name instead of
double quotes.

```dm
// Bad
var/sound_effect = "sounds/machines/wooden_closet_open.ogg"

// Good
var/sound_effect = 'sounds/machines/wooden_closet_open.ogg'
```

## HTML Tag Format

Though uppercase or mixing cases will work, we prefer to follow the W3 standard
for writing HTML tags. This means tags should be written in lowercase. This
makes code more readable and it just looks better.

```dm
// Bad
<B>This is an example of how not to do it.</B>

// Good
<b>This is an example of how it should be.</b>
```

## A Final Note

These guidelines are subject to change, and this document may be expanded on in
the future. Contributors and reviewers should take note of it and reference it
when needed. By following these guidelines, we can promote consistency across
the codebase and improve the quality of our code. Not only that, by doing so,
you help reduce the workload for those responsible for reviewing and managing
your intended changes. Thank you for taking the time to review this document.
Happy contributing!
