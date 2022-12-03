/obj/structure/shuttle
	name = "shuttle"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_integrity = 500
	armor = list(melee = 100, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70) //default + ignores melee

/obj/structure/shuttle/shuttleRotate(rotation)
	return // This override is needed to properly rotate the object when on a shuttle that is rotated.

/obj/structure/shuttle/engine
	name = "engine"
	icon = 'icons/turf/shuttle/misc.dmi'
	density = 1
	anchored = 1.0
	resistance_flags = INDESTRUCTIBLE			// То что у нас двигатели ломаются от пары пуль - бред
	var/list/obj/structure/fillers = list()		// Для коллизии более больших двигателей

// Это временное решение, дабы движки были освещены. Я хотел сделать анимацию с перекрасом цветов света в синий при полёте, но не сделал. Надеюсь кто-то сделает.
/obj/structure/shuttle/engine/Initialize(mapload)
	. = ..()
	set_light(2)

/obj/structure/shuttle/engine/heater
	name = "heater"
	icon_state = "heater"

/obj/structure/shuttle/engine/platform
	name = "platform"
	icon_state = "platform"

/obj/structure/shuttle/engine/propulsion
	name = "propulsion"
	icon_state = "propulsion"
	opacity = 1

/obj/structure/shuttle/engine/propulsion/burst

/obj/structure/shuttle/engine/propulsion/burst/left
	icon_state = "burst_l"

/obj/structure/shuttle/engine/propulsion/burst/right
	icon_state = "burst_r"

/obj/structure/shuttle/engine/router
	name = "router"
	icon_state = "router"

// Engines
/obj/structure/shuttle/engine/large
	name = "engine"
	opacity = 1
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	desc = "A very large bluespace engine used to propel very large ships."
//	bound_width = 64
//	bound_height = 64
	appearance_flags = 0

/obj/structure/shuttle/engine/large/Initialize()
	..()
	var/list/occupied = list()
	for(var/direct in list(EAST,NORTH,NORTHEAST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

/obj/structure/shuttle/engine/huge
	name = "engine"
	opacity = 1
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	desc = "Almost gigantic bluespace engine used to propel very large ships at very high speed."
	pixel_x = -32
	pixel_y = -32
//	bound_width = 96
//	bound_height = 96
	appearance_flags = 0

/obj/structure/shuttle/engine/huge/Initialize()
	..()
	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,NORTH,SOUTH,SOUTHEAST,SOUTHWEST,NORTHEAST,NORTHWEST))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F
