/datum/spell/pointed/moon_smile
	name = "Smile of the moon"
	desc = "Lets you turn the gaze of the moon on someone \
			temporarily blinding, muting, deafening and knocking down a single target if their sanity is low enough."

	overlay_icon_state = "bg_heretic"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
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

	//active_msg = "You prepare to let them see the true face..."


/datum/spell/pointed/moon_smile/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/cast_on = targets[1]
	/// The duration of these effects are based on sanity, mainly for flavor but also to make it a weaker alpha strike
	var/maximum_duration = 15 SECONDS
	var/moon_smile_duration = (100 / (cast_on.getBrainLoss())) * maximum_duration
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, "<span class='notice'>The moon turns, its smile no longer set on you.</span>")
		to_chat(user, "<span class='warning'>The moon does not smile upon them.</span>")
		return FALSE

	playsound(cast_on, 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	to_chat(cast_on, "<span class='warning'>Your eyes cry out in pain, your ears bleed and your lips seal! THE MOON SMILES UPON YOU!</span>")
	cast_on.EyeBlind(moon_smile_duration / 2 + 1 SECONDS)
	cast_on.EyeBlurry(moon_smile_duration + 2 SECONDS)

	cast_on.Deaf(moon_smile_duration + 2 SECONDS)

	cast_on.Silence(moon_smile_duration + 1 SECONDS)

	// Only knocksdown if the target has a low enough sanity
	if(cast_on.getBrainLoss() < 40)
		cast_on.KnockDown(2 SECONDS)
	return TRUE
