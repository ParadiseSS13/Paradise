/datum/spell/aoe/moon_ringleader
	name = "Ringleaders Rise"
	desc = "Big AoE spell that inflicts insanity and causes hallucinations to everyone in the AoE. \
			The worse their sanity, the stronger this spell becomes. \
			If their sanity is low enough, they even snap and go insane, and the spell then further halves their sanity."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "moon_ringleader"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/effects/moon_parade.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 1 MINUTES
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "R''S 'E"
	invocation_type = INVOCATION_SHOUT

	aoe_range = 5
	/// Effect for when the spell triggers
	var/obj/effect/moon_effect = /obj/effect/temp_visual/moon_ringleader

/datum/spell/aoe/moon_ringleader/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/moon_ringleader/cast(list/targets, mob/user)
	new moon_effect(get_turf(user))
	for(var/mob/living/carbon/human/human_target in targets)
		if(human_target.stat == DEAD)
			continue
		if(IS_HERETIC_OR_MONSTER(human_target))
			continue
		if(human_target.can_block_magic(antimagic_flags))
			continue
		var/datum/status_effect/stacking/heretic_insanity/insanity = human_target.has_status_effect(/datum/status_effect/stacking/heretic_insanity)
		var/power
		if(insanity)
			power = insanity.stacks
		else
			power = 1
		human_target.Hallucinate(max((power *= 5) SECONDS, 40 SECONDS))
		human_target.AdjustConfused(10 SECONDS)
		if(power >= 16)
			human_target.apply_status_effect(/datum/status_effect/moon_converted)
			add_attack_logs(user, human_target, "[human_target] was driven insane by [user]([src])")
			log_game("[human_target] was driven insane by [user]")
		else
			human_target.apply_status_effect(/datum/status_effect/stacking/heretic_insanity, 2)

	return ..()


/obj/effect/temp_visual/moon_ringleader
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "ring_leader_effect"
	alpha = 180
	duration = 6

/obj/effect/temp_visual/moon_ringleader/ringleader/Initialize(mapload)
	. = ..()
	transform = transform.Scale(10)
