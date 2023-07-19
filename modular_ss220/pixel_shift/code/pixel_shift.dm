/mob/proc/add_pixel_shift_component()
	return

/mob/living/Login()
	. = ..()
	add_pixel_shift_component()

/mob/living/add_pixel_shift_component()
	if(!GetComponent(/datum/component/pixel_shift))
		AddComponent(/datum/component/pixel_shift)

/mob/living/silicon/ai/add_pixel_shift_component()
	return

// Да, костыльно, но модульно по другому не вижу как
/mob/living/Process_Spacemove(movement_dir)
	if(SEND_SIGNAL(src, COMSIG_MOB_PIXEL_SHIFTING) & COMPONENT_LIVING_PASSABLE)
		SEND_SIGNAL(src, COMSIG_MOB_PIXEL_SHIFT, movement_dir)
		return FALSE
	. = ..()

/mob/living/CanPass(atom/movable/mover, turf/target, height)
	if(!istype(mover, /obj/item/projectile) && !mover.throwing)
		if(SEND_SIGNAL(src, COMSIG_MOB_PIXEL_SHIFT_PASSABLE, get_dir(src, mover)) & COMPONENT_LIVING_PASSABLE)
			return TRUE
	return ..()
