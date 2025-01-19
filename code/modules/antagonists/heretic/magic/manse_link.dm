/datum/spell/pointed/manse_link
	name = "Manse Link"
	desc = "This spell allows you to pierce through reality and connect minds to one another \
		via your Mansus Link. All minds connected to your Mansus Link will be able to communicate discreetly across great distances."

	overlay_icon_state = "bg_heretic"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 20 SECONDS

	invocation = "PI'RC' TH' M'ND."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	cast_range = 7

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS

//qwertodo: mind link component?
