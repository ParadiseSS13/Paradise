/datum/spell/mind_gate
	name = "Mind Gate"
	desc = "target suffers a hallucination, is left confused for 10 seconds, suffers oxyloss, and is inflicted with insanity."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "mind_gate"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	sound = 'sound/effects/curse.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS

	invocation = "Op' 'oY 'Mi'd"
	invocation_type = INVOCATION_WHISPER

/datum/spell/mind_gate/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.allowed_type = /mob/living/carbon/human
	return C

/datum/spell/mind_gate/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, SPAN_NOTICE("No target found in range."))
		return

	var/mob/living/target = targets[1]
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, SPAN_NOTICE("Your mind feels closed."))
		to_chat(user, SPAN_WARNING("Their mind doesn't swing open, but neither does yours."))
		return FALSE

	target.AdjustConfused(10 SECONDS)
	target.adjustOxyLoss(30)
	new /obj/effect/hallucination/delusion(get_turf(target), target, 'icons/effects/eldritch.dmi', "heretic")
	target.apply_status_effect(/datum/status_effect/stacking/heretic_insanity, 3)
