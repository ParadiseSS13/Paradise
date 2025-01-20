/datum/spell/mind_gate
	name = "Mind Gate"
	desc = "Deals you 20 brain damage and the target suffers a hallucination, \
			is left confused for 10 seconds, and suffers oxygen loss and brain damage."


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
	spell_requirements = NONE

/datum/spell/mind_gate/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.allowed_type = /mob/living/carbon/human
	return C

/datum/spell/mind_gate/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	var/mob/living/target = targets[1]
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, "<span class='notice'>Your mind feels closed.</span>")
		to_chat(user, "<span class='warning'>Their mind doesn't swing open, but neither does yours.</span>")
		return FALSE

	target.AdjustConfused(10 SECONDS)
	target.adjustOxyLoss(30)
	//__rust_gtarget.cause_hallucination(get_random_valid_hallucination_subtype(/datum/hallucination/body), "Mind gate, cast by [owner]")
	//target.cause_hallucination(/datum/hallucination/delusion/preset/heretic/gate, "Caused by mindgate") QWERTODO: This should be a sprite that looks like heretics
	target.adjustBrainLoss(25)

	var/mob/living/living_owner = user
	living_owner.adjustBrainLoss(16.5)
