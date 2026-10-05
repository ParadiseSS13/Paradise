// Given to heretic monsters.
/datum/spell/blind/eldritch
	name = "Eldritch Blind"

	is_a_heretic_spell = TRUE
	invocation = "E'E'S"

/datum/spell/blind/eldritch/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.allowed_type = /mob/living
	return C

/datum/spell/blind/eldritch/cast(list/targets, mob/living/user)
	if(!length(targets))
		to_chat(user, SPAN_NOTICE("No target found in range."))
		return

	var/mob/living/target = targets[1]
	if(target.can_block_magic(antimagic_flags))
		to_chat(target, SPAN_NOTICE("Your eye itches, but it passes momentarily."))
		to_chat(user, SPAN_NOTICE("The spell had no effect!"))
		return FALSE
	target.EyeBlurry(40 SECONDS)
	target.EyeBlind(5 SECONDS)

	SEND_SOUND(target, sound('sound/magic/blind.ogg'))
	return TRUE
