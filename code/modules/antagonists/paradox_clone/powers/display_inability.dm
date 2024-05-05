/datum/spell/paradox_spell/aoe/display_inability
	name = "Display Inability"
	desc = "Causes paradoxial interference in the HUDs and vision for nearby humans (even in mechas) turrets, bots and silicons. Blinds them for a while."
	action_icon_state = "display_inability"
	base_cooldown = 140 SECONDS

/datum/spell/paradox_spell/aoe/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new
	A.allowed_type = /atom
	A.range = 6
	return A

/datum/spell/paradox_spell/aoe/display_inability/cast(list/targets, mob/living/user = usr)

	var/used = FALSE

	for(var/obj/O in targets)
		if(istype(O, /obj/machinery/porta_turret))
			used = TRUE
		if(istype(O, /obj/mecha))
			var/obj/mecha/M = O
			used = TRUE
			M.occupant += targets

		O.emp_act(EMP_LIGHT)

	for(var/mob/living/L in targets)
		if(is_paradox_clone(L))
			continue
		if(istype(L, /mob/living/carbon/human))
			used = TRUE
			var/mob/living/carbon/human/H = L
			var/obj/item/clothing/glasses/G = H.glasses
			if(istype(G, /obj/item/clothing/glasses/hud))
				H.flash_eyes(10, TRUE, type = /atom/movable/screen/fullscreen/flash)
				H.KnockDown(1 SECONDS)
				H.EyeBlurry(10 SECONDS)
		if(istype(L, /mob/living/silicon))
			used = TRUE
			var/mob/living/silicon/S = L
			S.remove_med_sec_hud()
			S.flash_eyes(20, TRUE, 1, type = /atom/movable/screen/fullscreen/flash)
			S.EyeBlurry(20 SECONDS)
		if(istype(L, /mob/living/simple_animal/bot))
			L.emp_act(EMP_LIGHT)
			L.flash_eyes(8, TRUE, 1, type = /atom/movable/screen/fullscreen/flash)
			L.EyeBlurry(6 SECONDS)

		L.Weaken(rand(4 SECONDS, 8 SECONDS))

	if(used)
		playsound(get_turf(user), 'sound/effects/paradox_display_inability.ogg', 10, TRUE)
	else
		revert_cast()
		return

	add_attack_logs(user, user, "(Paradox Clone) Display Inabilited")
