
/datum/spell/paradox_spell/aoe/display_inability
	name = "Display Inability"
	desc = "Causes paradoxial interference in the HUDs for nearby humans and silicons. Blinds them for a while."
	action_icon_state = "display_inability"
	base_cooldown = 140 SECONDS

/datum/spell/paradox_spell/aoe/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new
	A.allowed_type = /mob/living
	A.range = 6
	return A

/datum/spell/paradox_spell/aoe/display_inability/proc/return_huds(obj/item/clothing/glasses/hud/H, r_hud_types, list/r_examine_extensions)
	H.hud_types = r_hud_types
	H.examine_extensions = r_examine_extensions

/datum/spell/paradox_spell/aoe/display_inability/cast(list/targets, mob/living/user = usr)

	var/used = FALSE

	for(var/mob/living/L in targets)
		if(is_paradox_clone(L))
			continue
		if(istype(L, /mob/living/carbon/human))
			used = TRUE
			var/mob/living/carbon/human/H = L
			var/obj/item/clothing/glasses/G = H.glasses
			if(istype(G, /obj/item/clothing/glasses/hud))
				var/obj/item/clothing/glasses/hud/HUD = G
				var/temp_hud_types = HUD.hud_types
				var/list/temp_examine_extensions = list()
				temp_examine_extensions = HUD.examine_extensions

				HUD.hud_types = null
				HUD.examine_extensions = HUD.examine_extensions.Cut()

				addtimer(CALLBACK(src, PROC_REF(return_huds), HUD, temp_hud_types, temp_examine_extensions), 20 SECONDS, TIMER_STOPPABLE)

				H.flash_eyes(0.5, TRUE, type = /atom/movable/screen/fullscreen/flash/noise)
				H.KnockDown(1 SECONDS)
				H.EyeBlurry(10 SECONDS)
		if(istype(L, /mob/living/silicon))
			used = TRUE
			var/mob/living/silicon/S = L
			S.remove_med_sec_hud()
			S.flash_eyes(2, TRUE, type = /atom/movable/screen/fullscreen/flash/noise)
			S.EyeBlurry(20 SECONDS)

	if(used)
		playsound(get_turf(user), 'sound/effects/paradox_display_inability.ogg', 10, TRUE)
	else
		revert_cast()
		return

	add_attack_logs(user, user, "(Paradox Clone) Display Inabilited")
