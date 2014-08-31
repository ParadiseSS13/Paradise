/obj/effect/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_idle"
	desc = "Some blob creature thingy"
	health = 60
	brute_resist = 4
	fire_resist = 2


	update_icon()
		if(health <= 0)
			playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
			Delete()
			return
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
		return 0
