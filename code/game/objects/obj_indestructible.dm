/obj/indestructible

/obj/indestructible/ex_act(severity)
	return

/obj/indestructible/blob_act(obj/structure/blob/B)
	return

/obj/indestructible/singularity_act()
	return

/obj/indestructible/singularity_pull(S, current_size)
	return

/obj/indestructible/narsie_act()
	return

/obj/indestructible/attackby(obj/item/I, mob/user, params)
	return

/obj/indestructible/attack_hand(mob/user)
	return

/obj/indestructible/attack_hulk(mob/user, does_attack_animation = FALSE)
	return

/obj/indestructible/attack_animal(mob/living/simple_animal/M)
	return

/obj/indestructible/mech_melee_attack(obj/mecha/M)
	return

/obj/indestructible/structure
	anchored = TRUE
	density = TRUE

/obj/indestructible/structure/New()
	..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
			QUEUE_SMOOTH(src)
			QUEUE_SMOOTH_NEIGHBORS(src)
		if(smoothing_flags & SMOOTH_CORNERS)
			icon_state = ""
	if(SSticker)
		GLOB.cameranet.updateVisibility(src)

/obj/indestructible/structure/window
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS) //they are not walls but this lets walls smooth with them
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WALLS)

/obj/indestructible/structure/window/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/windows/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	armor = list(MELEE = 50, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, RAD = 100, FIRE = 80, ACID = 100)
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_TITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_TITANIUM_WALLS)
