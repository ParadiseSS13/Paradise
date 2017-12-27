/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "Some blob creature thingy"
	health = 75
	fire_resist = 2


/obj/structure/blob/shield/update_icon()
	if(health <= 0)
		qdel(src)
		return
	return

/obj/structure/blob/shield/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/blob/shield/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0
