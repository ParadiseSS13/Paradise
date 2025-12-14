/datum/spell/charge_up/bounce/fire_blast
	name = "Volcano Blast"
	desc = "Charge up a blast of fire that chains between nearby targets, setting them ablaze. \
		Targets already on fire will take priority. If the target fails to catch ablaze, or \
		extinguishes themselves before it bounces, the chain will stop."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "flames"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/magic/fireball.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 45 SECONDS

	invocation = "V'LC'N!"
	invocation_type = INVOCATION_SHOUT
	max_charge_time = 5 SECONDS
	charge_sound = new /sound('sound/magic/fireball.ogg', channel = 7)
	var/max_beam_bounces = 4

	/// How long the beam visual lasts, also used to determine time between jumps
	bounce_time = 2 SECONDS

/datum/spell/charge_up/bounce/fire_blast/cast(list/targets, mob/user)
	if(isliving(user))
		var/mob/living/living_user = user
		living_user.apply_status_effect(/datum/status_effect/fire_blasted, bounce_time, -2)
	return ..()

/datum/spell/charge_up/bounce/fire_blast/bounce(mob/origin, mob/living/target, energy, bounces, mob/user)

	// Send a beam from the origin to the hit mob
	origin.Beam(target, icon_state = "solar_beam", time = bounce_time, beam_type = /obj/effect/ebeam/fire)

	// If they block the magic, the chain wont necessarily stop,
	// but likely will (due to them not catching on fire)
	if(target.can_block_magic(antimagic_flags))
		target.visible_message(
			SPAN_WARNING("[target] absorbs the spell, remaining unharmed!"),
			SPAN_USERDANGER("You absorb the spell, remaining unharmed!"),
		)
		// Apply status effect but with no overlay
		target.apply_status_effect(/datum/status_effect/fire_blasted)

	// Otherwise, if unblocked apply the damage and set them up
	else
		target.apply_damage(20, BURN)
		target.adjust_fire_stacks(3)
		target.IgniteMob()
		// Apply the fire blast status effect to show they got blasted
		target.apply_status_effect(/datum/status_effect/fire_blasted, bounce_time * 0.5)

	// We can keep bouncing, try to continue the chain
	if(bounces >= 1)
		playsound(target, sound, 50, vary = TRUE, extrarange = -1)
		// Chain continues shortly after. If they extinguish themselves in this time, the chain will stop anyways.
		addtimer(CALLBACK(src, PROC_REF(continue_beam), target, bounces, user), bounce_time * 0.5)

	else
		playsound(target, sound, 50, vary = TRUE, frequency = 12000)
		// We hit the maximum chain length, apply a bonus for managing it
		new /obj/effect/temp_visual/fire_blast_bonus(target.loc)
		for(var/mob/living/nearby_living in range(1, target))
			if(IS_HERETIC_OR_MONSTER(nearby_living) || nearby_living == user)
				continue
			nearby_living.KnockDown(0.8 SECONDS)
			nearby_living.apply_damage(15, BURN)
			nearby_living.adjust_fire_stacks(2)
			nearby_living.IgniteMob()

/// Timer callback to continue the chain, calling send_fire_bream recursively.
/datum/spell/charge_up/bounce/fire_blast/proc/continue_beam(mob/living/carbon/beamed, bounces, mob/user)
	// We will only continue the chain if we exist, are still on fire, and still have the status effect
	if(QDELETED(beamed) || !beamed.on_fire || !beamed.has_status_effect(/datum/status_effect/fire_blasted))
		return
	// We fulfilled the conditions, get the next target
	var/mob/living/carbon/to_beam_next = get_target(beamed)
	if(isnull(to_beam_next)) // No target = no chain
		return

	// Chain again! Recursively
	bounce(beamed, to_beam_next, 1, bounces - 1, user)

/datum/spell/charge_up/bounce/fire_blast/get_bounce_amount()
	return max_beam_bounces

/// Pick a carbon mob in a radius around us that we can reach.
/// Mobs on fire will have priority and be targeted over others.
/// Returns null or a carbon mob.
/datum/spell/charge_up/bounce/fire_blast/get_target(mob/origin, mob/user)
	var/list/possibles = list()
	var/list/priority_possibles = list()
	for(var/mob/living/carbon/to_check in view(5, origin))
		if(to_check == origin || to_check == user)
			continue
		if(to_check.has_status_effect(/datum/status_effect/fire_blasted)) // Already blasted
			continue
		if(IS_HERETIC_OR_MONSTER(to_check))
			continue
		if(!length(get_path_to(origin, to_check, max_distance = 5, simulated_only = FALSE)))
			continue

		possibles += to_check
		if(to_check.on_fire && to_check.stat != DEAD)
			priority_possibles += to_check

	if(!length(possibles))
		return null

	return length(priority_possibles) ? pick(priority_possibles) : pick(possibles)

/**
 * Status effect applied when someone's hit by the fire blast.
 *
 * Applies an overlay, then causes a damage over time (or heal over time)
 */
/datum/status_effect/fire_blasted
	id = "fire_blasted"
	alert_type = null
	duration = 5 SECONDS
	tick_interval = 0.5 SECONDS
	/// How much fire / stam to do per tick (stamina damage is doubled this)
	var/tick_damage = 1
	/// How long does the animation of the appearance last? If 0 or negative, we make no overlay
	var/animate_duration = 0.75 SECONDS
	///This overlay is applied to the owner for the duration of the effect.
	var/mutable_appearance/mob_overlay

/datum/status_effect/fire_blasted/on_creation(mob/living/new_owner, animate_duration = -1, tick_damage = 1)
	src.animate_duration = animate_duration
	src.tick_damage = tick_damage
	return ..()

/datum/status_effect/fire_blasted/on_apply()
	if(owner.on_fire && animate_duration > 0 SECONDS)
		mob_overlay = mutable_appearance('icons/effects/effects.dmi', "blessed", BELOW_MOB_LAYER)
		mob_overlay.alpha = 50
		owner.add_overlay(mob_overlay)

	return TRUE

/datum/status_effect/fire_blasted/on_remove()
	owner.cut_overlay(mob_overlay)


/datum/status_effect/fire_blasted/tick()
	owner.adjustFireLoss(tick_damage)
	owner.adjustStaminaLoss(2 * tick_damage)

// Visual effect played when we hit the max bounces
/obj/effect/temp_visual/fire_blast_bonus
	name = "fire blast"
	icon_state = "explosion"
