/datum/spell/ethereal_jaunt/ash
	name = "Ashen Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "ash_shift"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = null

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 40 SECONDS

	invocation = "ASH'N P'SSG'"
	invocation_type = INVOCATION_WHISPER

	sound1 = null
	sound2 = null
	jaunt_duration = 1.1 SECONDS
	jaunt_in_time = 0.35 SECONDS //Did you know it sleeps 4x this number? So you have to make it 1/4th of what it actually is?
	jaunt_out_time = 0.6 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out


/datum/spell/ethereal_jaunt/ash/jaunt_steam()
	return

/datum/spell/ethereal_jaunt/ash/long
	name = "Ashen Walk"
	desc = "A long range spell that allows you pass unimpeded through multiple walls."
	jaunt_duration = 5 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon_state = "ash_shift2"
	duration = 1.3 SECONDS

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"
