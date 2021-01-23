# Maze Generation Module

## Introduction

All the code in here is related to the maze generation system. There are 4 things to be aware of here.

- `maze_generator.dm` is the file with the main generator code.
- `maze_helper_atoms.dm` is a file with helper atoms (EG: Window panes that work as walls)
- `loot_modules` is a directory which houses all the modules for loot spawners.
- `helper_modules` is a directory which houses maze helper modules (EG: Guaranteed entrance and exit spots).

## How Do I Use This

To use this you need a rectangular room (squares are fine). It must be a standard box-room with no weird wall extrusions. Lets use this room below.

```hs
#####################################
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#####################################
```

This room in question has an inner width of 35 and an inner height of 11. To get started, place your maze generator (marked by G) in the bottom left of your room.

```hs
#####################################
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#                                   #
#G                                  #
#####################################
```

Edit this mapping instance to set `mwidth` and `mheight` to your internal dimensions. At this point, you will have a functional maze, but you wont have designated entrypoints or exit points, or loot if you want that.

## Using Loot Modules

Loot modules are subtypes of `/obj/effect/mazegen/loot_module` and can be used to add loot to dead ends on maps. Place them anywhere inside your maze area and they will register. You can combine multiple modules to have a variation between loot spawns.

## Using Helper Modules

Helper modules are subtypes of `/obj/effect/mazegen/helper_module` and can be used to reduce some randomness of the maze. For example, you can use these to make some spots designated entrances or exits in the maze if you need a fully enclosed room. Unlike the loot modules, these cannot be placed anywhere randomly though, they have to be put in their exact spots. Make sure to make the modules qdel themselves after running!
