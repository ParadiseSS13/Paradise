// A buff given to people sacrificed to help them survive.

/// Screen alert for the below status effect.
/atom/movable/screen/alert/status_effect/unholy_determination
	name = "Unholy Determination"
	desc = "You appear in a unfamiliar room. The darkness begins to close in. Panic begins to set in. There is no time. Fight on, or die!"
	icon_state = "wounded"

/// The buff given to people within the shadow realm to assist them in surviving.
/datum/status_effect/unholy_determination
	id = "unholy_determination"
	duration = 3 MINUTES // Given a default duration so no one gets to hold onto this buff forever by accident.
	tick_interval = 1 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/unholy_determination
	/// How much to heal every second
	var/heal_per_second = 0.25

/datum/status_effect/unholy_determination/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	return ..()

/datum/status_effect/unholy_determination/on_apply()
	owner.add_traits(list(TRAIT_COAGULATING, TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), type)
	return TRUE

/datum/status_effect/unholy_determination/on_remove()
	owner.remove_traits(list(TRAIT_COAGULATING, TRAIT_NOCRITDAMAGE, TRAIT_NOSOFTCRIT), type)

/datum/status_effect/unholy_determination/tick()
	// The amount we heal of each damage type per tick. If we're missing legs we heal better because we can't dodge.
	var/healing_amount = (heal_per_second) + (heal_per_second * (2 - owner.usable_legs))

	// In softcrit you're, strong enough to stay up.
	if(owner.health <= owner.crit_threshold && owner.health >= 0)
		if(prob(5))
			to_chat(owner, "<span class='hierophant_warning'>Your body feels like giving up, but you fight on!</span>")
		healing_amount *= 2
	// ...But reach hardcrit and you're done. You now die faster.
	if(owner.health < -100)
		if(prob(5))
			to_chat(owner, "<span class='hierophant_warning'>You can't hold on for much longer...</span>")
		healing_amount *= -0.5

	if(owner.health > owner.crit_threshold && prob(4))
		owner.set_jitter_if_lower(20 SECONDS)
		owner.set_dizzy_if_lower(10 SECONDS)
		owner.adjust_hallucinations_up_to(6 SECONDS, 48 SECONDS)

	if(prob(2))
		playsound(owner, pick(GLOB.creepy_ambience), 50, TRUE)

	adjust_all_damages(healing_amount)

/*
 * Heals up all the owner a bit, fire stacks and losebreath included.
 */
/datum/status_effect/unholy_determination/proc/adjust_all_damages(amount)

	owner.adjust_fire_stacks(-1)

	var/damage_healed = 0
	damage_healed += owner.adjustToxLoss(-amount, updating_health = FALSE)
	damage_healed += owner.adjustOxyLoss(-amount, updating_health = FALSE)
	damage_healed += owner.adjustBruteLoss(-amount, updating_health = FALSE)
	damage_healed += owner.adjustFireLoss(-amount, updating_health = FALSE)
	if(damage_healed > 0)
		owner.updatehealth()


/// Torment the target with a frightening hand
/proc/fire_curse_hand(mob/living/carbon/victim, turf/forced_turf)
	var/grab_dir = turn(victim.dir, pick(-90, 90, 180, 180)) // Not in front, favour behind
	var/turf/spawn_turf = get_ranged_target_turf(victim, grab_dir, 8)
	spawn_turf = forced_turf ? forced_turf : spawn_turf
	if(isnull(spawn_turf))
		return
	new /obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, victim.dir)
	playsound(spawn_turf, 'sound/effects/curse/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/curse_hand/hel/hand = new (spawn_turf)
	hand.aim_projectile(victim, spawn_turf)
	if(QDELETED(hand)) // safety check if above fails - above has a stack trace if it does fail
		return
	hand.fire()
