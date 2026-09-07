/datum/spell/shapeshift/shed_human_form
	name = "Shed form"
	desc = "Shed your fragile form, become one with the arms, become one with the emperor. \
		Causes heavy amounts of brain damage to nearby mortals."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "worm_ascend"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	is_a_heretic_spell = TRUE

	invocation = "REALITY UNCOIL!"
	shapeshift_type = /mob/living/basic/heretic_summon/armsy/prime
	current_shapes = list(/mob/living/basic/heretic_summon/armsy/prime)
	current_casters = list()
	possible_shapes = list(/mob/living/basic/heretic_summon/armsy/prime)
	/// The length of our new wormy when we shed.
	var/segment_length = 10
	/// The radius around us that we cause brain damage to.
	var/scare_radius = 9

/datum/spell/shapeshift/shed_human_form/Shapeshift(mob/living/caster)
	// When we transform into the worm, everyone nearby gets freaked out
	for(var/mob/living/carbon/human/nearby_human in view(scare_radius, caster))
		if(IS_HERETIC_OR_MONSTER(nearby_human) || nearby_human == caster)
			continue

		nearby_human.adjustBrainLoss(30)

	for(var/mob/living/M in caster)
		if(M.status_flags & GODMODE)
			to_chat(caster, SPAN_WARNING("You're already shapeshifted!"))
			return
	// We overide the spell vs call parent as we need to setup segments.

	var/mob/living/shape = new shapeshift_type(get_turf(caster), TRUE, segment_length)
	caster.forceMove(shape)
	caster.status_flags |= GODMODE

	current_shapes |= shape
	current_casters |= caster
	clothes_req = FALSE
	human_req = FALSE

	caster.mind.transfer_to(shape)

/datum/spell/shapeshift/shed_human_form/Restore(mob/living/basic/heretic_summon/armsy/caster)
	if(istype(caster))
		segment_length = caster.get_length() - 1 // Don't count the head
	return ..()


/datum/spell/worm_contract
	name = "Force Contract"
	desc = "Forces your body to contract onto a single tile."
	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "worm_contract"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'

	base_cooldown = 30 SECONDS

	spell_requirements = NONE
	clothes_req = FALSE


/datum/spell/worm_contract/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/worm_contract/valid_target(target, user)
	return istype(user, /mob/living/basic/heretic_summon/armsy)

/datum/spell/worm_contract/cast(list/targets, mob/living/basic/heretic_summon/armsy/user)
	. = ..()
	user.contract_next_chain_into_single_tile()
