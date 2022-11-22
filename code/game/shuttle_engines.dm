/obj/structure/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	max_integrity = 500
	armor = list(melee = 100, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 70) //default + ignores melee

/obj/structure/shuttle/shuttleRotate(rotation)
	return // This override is needed to properly rotate the object when on a shuttle that is rotated.

/obj/structure/shuttle/window
	name = "shuttle window"
	icon = 'icons/obj/podwindows.dmi'
	icon_state = "1"
	density = 1
	opacity = 0
	anchored = 1

/obj/structure/shuttle/window/CanPass(atom/movable/mover, turf/target, height)
	if(!height)
		return 0
	else
		return ..()

/obj/structure/shuttle/window/CanAtmosPass(turf/T)
		return !density

/obj/structure/shuttle/engine
	name = "engine"
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
