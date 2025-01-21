/datum/spell/aoe/wave_of_desperation
	name = "Wave Of Desperation"
	desc = "Removes your restraints, repels and knocks down adjacent people, and applies certain effects of the Mansus Grasp upon everything nearby. \
		Cannot be cast unless you are restrained, and the stress renders you unconscious 12 seconds later!"


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "uncuff"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/magic/swap.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 5 MINUTES

	invocation = "F'K 'FF."
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	aoe_range = 3


// Before the cast, we do some small AOE damage around the caster
/datum/spell/aoe/wave_of_desperation/before_cast(list/targets, mob/living/carbon/user)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return
	if(!(user.handcuffed || user.legcuffed))
		return
	if(user.handcuffed)
		user.visible_message("<span class='danger'>[user.handcuffed] on [user] shatter!</span>")
		QDEL_NULL(user.handcuffed)
	if(user.legcuffed)
		user.visible_message("<span class='danger'>[user.legcuffed] on [user] shatters!</span>")
		QDEL_NULL(user.legcuffed)

	user.apply_status_effect(/datum/status_effect/heretic_lastresort)
	new /obj/effect/temp_visual/knockblast(get_turf(user))

	for(var/mob/living/victim in get_things_to_cast_on(user, radius_override = 1))
		victim.KnockDown(3 SECONDS)
		victim.AdjustWeakened(0.5 SECONDS)
		var/our_turf = get_turf(user)
		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(victim, our_turf)))
		victim.throw_at(throwtarget, 3, 1)
		SEND_SIGNAL(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) //qwertodo: primary

/datum/spell/aoe/wave_of_desperation/proc/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_range))
		if(nearby == center || isarea(nearby))
			continue
		if(!ismob(nearby))
			. += nearby
			continue
		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob



/obj/effect/temp_visual/knockblast
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	alpha = 180
	duration = 1 SECONDS
