# Spriting Requirements

## Mobs

Mobs require sprites in 4 directions. Playable mobs should be able to wear
clothes, hold items, wear gloves, glasses, etc. Anything worn on mobs must be in
the same place in all 4 directions.

## Turfs

Floors are one of few exceptions to perspective. Floors should be 2-dimensional.
Avoid flat, solid coloring. Instead, try to divide floors into sections or have
a special design in mind.

## Objects

### Items

Items that you can pick up generally require in-hand sprites, as well as being
1-directional. If objects are 4-directional or 8-directional, they should never
rotate. The best example of this is the pinpointer or medical crew pinpointer.

### Clothing

Clothing requires an item sprite in the appropriate dmi file in
icons/obj/clothing/, an in-hand sprite in icons/mob/items_lefthand.dmi and
items_righthand.dmi, as well as the on-mob sprite in the appropriate file in
icons/mob/clothing

### Machinery and structures

Direction count varies from machine to machine. Some can be rotated, such as
laser emitters, and some cannot, such as chemical dispensers. Ideally, if it can
have 4-directional sprites, it should have 4-directional sprites. All machines
should have an 'on' sprite and an 'off' sprite.
