/datum/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and knocking down a single target if their sanity is low enough."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "moon_smile"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "Mo'N S'M'LE"
	invocation_type = INVOCATION_SHOUT
	cast_range = 6

	//active_msg = "You prepare to let them see the true face..."


/datum/spell/pointed/moon_smile/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.use_turf_of_user = TRUE
	C.allowed_type = /mob/living/carbon/human
	C.range = cast_range
	C.try_auto_target = FALSE
	return C

/datum/spell/pointed/moon_smile/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/cast_on = targets[1]
	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	cast_on.apply_status_effect(/datum/status_effect/stacking/heretic_insanity)
	var/datum/status_effect/stacking/heretic_insanity/insanity = cast_on.has_status_effect(/datum/status_effect/stacking/heretic_insanity)
	var/moon_smile_duration
	if(!insanity)
		moon_smile_duration = 1 SECONDS
	else
		moon_smile_duration = max((insanity.stacks / insanity.max_stacks) * maximum_duration, 1)
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, SPAN_NOTICE("The moon turns, its smile no longer set on you."))
		to_chat(user, SPAN_WARNING("The moon does not smile upon them."))
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, SPAN_WARNING("Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!"))
	cast_on.EyeBlind(max(moon_smile_duration / 2 + (1 SECONDS), 2 SECONDS))
	cast_on.EyeBlurry(max(moon_smile_duration + (2 SECONDS), 4 SECONDS))

	cast_on.Deaf(max(moon_smile_duration + (2 SECONDS), 4 SECONDS))

	cast_on.Silence(max(moon_smile_duration + (4 SECONDS), 6 SECONDS))

	// Only knocksdown if the target has a low enough sanity
	if(insanity && insanity.stacks >= 8)
		cast_on.KnockDown(2 SECONDS)
	return TRUE
