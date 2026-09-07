/datum/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "cleave"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1


/datum/spell/pointed/cleave/create_new_targeting()
	var/datum/spell_targeting/click/C = new()
	C.selection_type = SPELL_SELECTION_RANGE
	C.use_turf_of_user = TRUE
	C.allowed_type = /mob/living/carbon/human
	C.range = cast_range
	C.try_auto_target = FALSE
	return C

/datum/spell/pointed/cleave/cast(list/targets, mob/user)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, targets[1]))
		if(victim == user || IS_HERETIC_OR_MONSTER(victim))
			continue
		if(victim.can_block_magic(antimagic_flags))
			victim.visible_message(
				SPAN_DANGER("[victim]'s flashes in a firey glow, but repels the blaze!"),
				SPAN_DANGER("Your body begins to flash a firey glow, but you are protected!!")
			)
			continue

		if(!victim.blood_volume)
			continue

		victim.visible_message(
			SPAN_DANGER("[victim]'s veins are shredded from within as an unholy blaze erupts from [victim.p_their()] blood!"),
			SPAN_DANGER("Your veins burst from within and unholy flame erupts from your blood!")
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
