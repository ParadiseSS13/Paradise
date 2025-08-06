/obj/structure/blob/node
	name = "blob node"
	icon_state = "blank_blob"
	max_integrity = 200
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 65, ACID = 90)
	point_return = 18

/obj/structure/blob/node/Initialize(mapload)
	. = ..()
	GLOB.blob_nodes += src
	START_PROCESSING(SSobj, src)

/obj/structure/blob/node/adjustcolors(a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.overlays += C

/obj/structure/blob/node/Destroy()
	GLOB.blob_nodes -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blob/node/Life(seconds, times_fired)
	if(overmind)
		for(var/i = 1; i < 8; i += i)
			Pulse(5, i, overmind.blob_reagent_datum.color)
	else
		for(var/i = 1; i < 8; i += i)
			Pulse(5, i, color)
	obj_integrity = min(max_integrity, obj_integrity + 1)
	color = null
