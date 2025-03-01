# Advanced Bitwise Operations

Expanding on information covered in [Bitflags](./bitflags.md), this document
further explores how other bitwise operators can be used. This document uses the
prefix `0b` to denote a binary number, to distinguish them from numbers in base
ten. For example, the base ten number 5 is `0b101`, and the base ten number
1,110 is `0b10001010110`.

## Or Operator

The Or operator can be used merge bitflags, even if they contain the same flag.

```
var/a = 5     // 0b101
var/b = 6     // 0b110
var/c = a | b // 0b111 = 7
```

The Or operator can be used in conjunction with each other to reduce line count.
This example from the previous bitflags document can be simplified.

```dm
var/player_abilities = WALK
player_abilities |= SING
player_abilities |= READ
```

Instead of assigning twice, we can simplify.

```dm
var/player_abilities = DANCE
player_abilities |= (SING|READ)
```

Note that these are now wrapped in parentheses, primarily to make them easier to
read that they are a pair of OR'd bitflags.

## And Operator

The And operator can be used to check if 2 variables contain the same bitflag.

```
var/a = 5     // 0b101
var/b = 6     // 0b110
var/c = a & b // 0b100 = 4
```

The only bit that stayed true was the bit that was in both inputs. This is
different to the Or operator, where it only had to be in one input.

In the previous section, we turned a flag off using this example:

```dm
player_abilities &= ~SING
```

This done by using the & (And) operator and a negation of the bitflag. Negating
this bitflag replace all the 1s with 0s and all the 0s with 1s.

```
#define DANCE (1 << 4)  // 0b10000 = 16
to_chat(world, DANCE)   // 0b10000 = 16, note that all the leading zeros have been hidden here.
to_chat(world, ~DANCE)  // 0b111111111111111111101111 = 16777199
```

When the `&= ~DANCE` operation is performed, it takes negated version, where the
flag is only zero and applies the and operation

```
var/player_abilities = (DANCE|SING|SWIM)
player_abilities &= ~DANCE // remove the dance flag
to_chat(world, player_abilities) // now just contains (SING | SWIM)
```

## Exclusive Or Operator.

The exclusive or operator `^` acts as a "toggle", and doesn't require knowledge
of what is inside the flags, as seen in the example below.

```
var/player_abilities = (DANCE|SING|SWIM)
player_abilities ^= DANCE // remove the dance flag
to_chat(world, player_abilities) // (SING | SWIM)
player_abilities ^= DANCE // enable the dance flag
to_chat(world, player_abilities) // (DANCE | SING | SWIM)
```

When used between two variables, this can be used to check the differences
between them.

```
var/a = 3     // 0b010
var/b = 5     // 0b101
var/c = a ^ b // 0b110 = 6
```

## Bitwise Shift Right

Finally, in conjunction to `<<` bitwise left shift, there is a bitwise right
shift, used with `>>`. These shifts can also be used with numbers other than
one, as shown in the example below.

```dm
var/a = 5      //    0b101 = 5
var/b = (a<<3) // 0b101000 = 40
var/c = (b>>1) //  0b10100 = 20
```

However, using these shifts are not common outside of defining bitflags, bitwise
right shift is barely used.

Not to be confused, these operators (`<<` and `>>`) are also used as "output"
and "input" operators for mobs, savefiles, etc. These are only rarely used,
users should be using helper procs like to_chat() instead.
