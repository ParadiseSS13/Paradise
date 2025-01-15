// Currently unused
/datum/spell/touch/mad_touch
	name = "Touch of Madness"
	desc = "A touch spell that drains your enemy's sanity and knocks them down."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mad_touch"

	is_a_heretic_spell = TRUE
	base_cooldown = 15 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

/datum/spell/touch/mad_touch/valid_target(target, user)
	if(!ishuman(cast_on))
		return FALSE
	var/mob/living/carbon/human/human_cast_on = cast_on
	if(!human_cast_on.mind || !human_cast_on.mob_mood || IS_HERETIC_OR_MONSTER(human_cast_on))
		return FALSE
	return TRUE

/datum/spell/touch/mad_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		"<span class='danger'>The spell bounces off of [victim]!</span>",
		"<span class='danger'>The spell bounces off of you!</span>",
	)

/datum/spell/touch/mad_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/carbon/human/victim, mob/living/carbon/caster)
	to_chat(caster, "<span class='warning'>[victim.name] has been cursed!</span>")
	victim.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	return TRUE
