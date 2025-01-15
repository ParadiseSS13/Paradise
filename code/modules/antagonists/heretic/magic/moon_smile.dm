/datum/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and knocking down a single target if their sanity is low enough."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_smile"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/blind.ogg'
	is_a_heretic_spell = TRUE
	base_cooldown = 20 SECONDS
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND
	invocation = "Mo'N S'M'LE"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	cast_range = 6

	active_msg = "You prepare to let them see the true face..."

/datum/spell/pointed/moon_smile/can_cast_spell(feedback = TRUE)
	return ..() && isliving(owner)

/datum/spell/pointed/moon_smile/valid_target(target, user)
	return ..() && ishuman(cast_on)

/datum/spell/pointed/moon_smile/cast(mob/living/carbon/human/cast_on)
	. = ..()
	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	var/moon_smile_duration = ((SANITY_MAXIMUM - cast_on.mob_mood.sanity) / (SANITY_MAXIMUM - SANITY_INSANE)) * maximum_duration
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, "<span class='notice'>The moon turns, its smile no longer set on you.</span>")
		to_chat(owner, "<span class='warning'>The moon does not smile upon them.</span>")
		return FALSE

	playsound(cast_on, 'sound/effects/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, "<span class='warning'>Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!</span>")
	cast_on.adjust_temp_blindness(moon_smile_duration + 1 SECONDS)
	cast_on.EyeBlurry(moon_smile_duration + 2 SECONDS)

	var/obj/item/organ/internal/ears/ears = cast_on.get_organ_slot(ORGAN_SLOT_EARS)
	//adjustEarDamage takes deafness duration parameter in one unit per two seconds, instead of the normal time, so we divide by two seconds
	ears?.adjustEarDamage(0, (moon_smile_duration + 1 SECONDS) / (2 SECONDS))

	cast_on.adjust_silence(moon_smile_duration + 1 SECONDS)
	cast_on.add_mood_event("moon_smile", /datum/mood_event/moon_smile)

	// Only knocksdown if the target has a low enough sanity
	if(cast_on.mob_mood.sanity < 40)
		cast_on.AdjustKnockdown(2 SECONDS)
	//Lowers sanity
	cast_on.mob_mood.set_sanity(cast_on.mob_mood.sanity - 20)
	return TRUE
