/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	max_integrity = 100
	fire_resist = 2
	point_return = 18
	var/mob/camera/blob/overmind

/obj/structure/blob/node/New(loc, var/h = 100)
	blob_nodes += src
	START_PROCESSING(SSobj, src)
	..(loc, h)

/obj/structure/blob/node/adjustcolors(var/a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.overlays += C

/obj/structure/blob/node/fire_act(exposed_temperature, exposed_volume)
	return

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
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
