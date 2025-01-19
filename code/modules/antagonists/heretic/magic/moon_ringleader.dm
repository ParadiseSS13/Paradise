/datum/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that deals brain damage and causes hallucinations to everyone in the AoE. \
			The worse their sanity, the stronger this spell becomes. \
			If their sanity is low enough, they even snap and go insane, and the spell then further halves their sanity."

	overlay_icon_state = "bg_heretic"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "moon_ringleader"
	sound = 'sound/effects/moon_parade.ogg'

	is_a_heretic_spell = TRUE
	base_cooldown = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "R''S 'E"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	aoe_range = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/spell/aoe/moon_ringleader/cast(list/targets, mob/user)
	new moon_effect(get_turf(user))
	return ..()

//QWERTODO: YOU KNOW THE DRILL MAKE THIS A PROPER AOE SPELL


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
