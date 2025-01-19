/datum/spell/charge_up/bounce/fire_blast
	name = "Volcano Blast"
	desc = "Charge up a blast of fire that chains between nearby targets, setting them ablaze. \
		Targets already on fire will take priority. If the target fails to catch ablaze, or \
		extinguishes themselves before it bounces, the chain will stop."

	overlay_icon_state = "bg_heretic"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "flames"
	sound = 'sound/magic/fireball.ogg'

	is_a_heretic_spell = TRUE
	base_cooldown = 45 SECONDS

	invocation = "V'LC'N!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	max_charge_time = 5 SECONDS
	var/max_beam_bounces = 4

	/// How long the beam visual lasts, also used to determine time between jumps
	var/beam_duration = 2 SECONDS
//qwertodo: fuck this spell do later

// Visual effect played when we hit the max bounces
/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion"
	duration = 1 SECONDS
