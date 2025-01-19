/datum/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1


/datum/spell/pointed/cleave/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, user))
		if(victim == user || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				"<span class='danger'>[victim]'s flashes in a firey glow, but repels the blaze!</span>",
				"<span class='danger'>Your body begins to flash a firey glow, but you are protected!!</span>"
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			"<span class='danger'>[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!</span>",
			"<span class='danger'>Your veins burst from within and unholy flame erupts from your blood!</span>"
		)

		var/obj/item/organ/external/bodypart = pick(victim.bodyparts)
		bodypart.cause_internal_bleeding()
		victim.apply_damage(20, BURN)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/spell/pointed/cleave/long
	name = "Lesser Cleave"
	base_cooldown = 90 SECONDS

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
