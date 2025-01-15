/datum/spell/pointed/cleave
	name = "Cleave"
	desc = "Causes severe bleeding on a target and several targets around them."

	overlay_icon_state = "bg_heretic_border"
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "cleave"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	is_a_heretic_spell = TRUE
	base_cooldown = 45 SECONDS

	invocation = "CL'VE!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 4

	/// The radius of the cleave effect
	var/cleave_radius = 1
	/// What type of wound we apply
	var/wound_type = /datum/wound/slash/flesh/critical/cleave

/datum/spell/pointed/cleave/valid_target(target, user)
	return ..() && ishuman(user)

/datum/spell/pointed/cleave/cast(mob/living/carbon/human/cast_on)
	. = ..()
	for(var/mob/living/carbon/human/victim in range(cleave_radius, cast_on))
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
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

		var/obj/item/bodypart/bodypart = pick(victim.bodyparts)
		var/datum/wound/slash/flesh/crit_wound = new wound_type()
		crit_wound.apply_wound(bodypart)
		victim.apply_damage(20, BURN, wound_bonus = CANT_WOUND)

		new /obj/effect/temp_visual/cleave(get_turf(victim))

	return TRUE

/datum/spell/pointed/cleave/long
	name = "Lesser Cleave"
	base_cooldown = 60 SECONDS
	wound_type = /datum/wound/slash/flesh/severe

/obj/effect/temp_visual/cleave
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cleave"
	duration = 6
