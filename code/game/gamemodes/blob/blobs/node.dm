/obj/structure/blob/node
	name = "blob node"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	health = 100
	fire_resist = 2
	var/mob/camera/blob/overmind

/obj/structure/blob/node/New(loc, var/h = 100)
	blob_nodes += src
	processing_objects.Add(src)
	..(loc, h)

/obj/structure/blob/node/adjustcolors(var/a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_node_overlay")
	src.overlays += C

/obj/structure/blob/node/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/node/Destroy()
	blob_nodes -= src
	processing_objects.Remove(src)
	return ..()

/obj/structure/blob/node/Life(seconds, times_fired)
	if(overmind)
		for(var/i = 1; i < 8; i += i)
			Pulse(5, i, overmind.blob_reagent_datum.color)
	else
		for(var/i = 1; i < 8; i += i)
			Pulse(5, i, color)
	health = min(initial(health), health + 1)
	color = null

/obj/structure/blob/node/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return