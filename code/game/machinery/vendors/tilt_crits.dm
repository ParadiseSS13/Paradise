/**
 * Framework for custom vendor crits.
 */

/datum/tilt_crit
	/// Name of a crit. Only crits with a name will be options.
	var/name
	/// If it'll deal damage or not
	var/harmless = FALSE
	/// If we should be thrown against the mob or not.
	var/fall_towards_mob = TRUE
	/// List of types which we should be valid for
	var/list/valid_types_whitelist = list(/atom/movable)
	/// Typecache of valid types
	var/list/valid_typecache

/datum/tilt_crit/New()
	valid_typecache = typecacheof(valid_types_whitelist)

/**
 * Return whether or not the crit selected is valid.
 */
/datum/tilt_crit/proc/is_valid(atom/movable/tilter, mob/living/carbon/victim)
	SHOULD_CALL_PARENT(TRUE)
	return is_type_in_typecache(tilter, valid_typecache)

/***
 * Perform the tip crit effect on a victim.
 * Arguments:
 * * machine - The machine that was tipped over
 * * user - The unfortunate victim upon whom it was tipped over
 * * incoming_damage - The amount of damage that was already being dealt to the victim
 * Returns: The "crit rebate", or the amount of damage to subtract from the original amount of damage dealt, to soften the blow.
 */
/datum/tilt_crit/proc/tip_crit_effect(atom/movable/tilter, mob/living/carbon/victim, incoming_damage)
	return 0

/datum/tilt_crit/shatter
	name = "Leg Crush"

/datum/tilt_crit/shatter/is_valid(atom/movable/tilter, mob/living/carbon/victim)
	. = ..()
	return . && iscarbon(victim)

/datum/tilt_crit/shatter/tip_crit_effect(atom/movable/tilter, mob/living/carbon/victim, incoming_damage)
	victim.bleed(150)
	var/obj/item/organ/external/leg/right = victim.get_organ(BODY_ZONE_R_LEG)
	var/obj/item/organ/external/leg/left = victim.get_organ(BODY_ZONE_L_LEG)
	if(istype(left))
		left.receive_damage(200)
	if(istype(right))
		right.receive_damage(200)

	if(left || right)
		victim.visible_message(
			"<span class='danger'>[victim]'s legs shatter with a sickening crunch!</span>",
			"<span class='userdanger'>Your legs shatter with a sickening crunch!</span>",
			"<span class='danger'>You hear a sickening crunch!</span>"
		)

	// that's a LOT of damage, let's rebate most of it.
	return incoming_damage * (5/6)

/datum/tilt_crit/pin
	name = "Pin"

/datum/tilt_crit/pin/is_valid(atom/movable/tilter, mob/living/victim)
	. = ..()
	return . && isliving(victim)

/datum/tilt_crit/pin/tip_crit_effect(atom/movable/tilter, mob/living/victim, incoming_damage)
	tilter.forceMove(get_turf(victim))
	tilter.buckle_mob(victim, force=TRUE)
	victim.visible_message(
		"<span class='danger'>[victim] gets pinned underneath [tilter]!</span>",
		"<span class='userdanger'>You are pinned down by [tilter]!</span>"
	)

	return 0


/datum/tilt_crit/vendor
	valid_types_whitelist = list(/obj/machinery/economy/vending)

/datum/tilt_crit/vendor/embed
	name = "Panel Shatter"

/datum/tilt_crit/vendor/embed/is_valid(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	. = ..()
	if(!. || !istype(machine))
		return
	if(machine.num_shards <= 0)
		return FALSE
	return iscarbon(victim)

/datum/tilt_crit/vendor/embed/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim, incoming_damage)
	victim.visible_message(
		"<span class='danger'>[machine]'s panel shatters against [victim]!</span>",
		"<span class='userdanger>[machine] lands on you, its panel shattering!</span>"
	)

	for(var/i in 1 to machine.num_shards)
		var/obj/item/shard/shard = new /obj/item/shard(get_turf(victim))
		// do a little dance to force the embeds, but make sure the glass isn't gigapowered afterwards
		shard.embed_chance = 100
		shard.embedded_pain_chance = 5
		shard.embedded_impact_pain_multiplier = 1
		shard.embedded_ignore_throwspeed_threshold = TRUE
		victim.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
		shard.embed_chance = initial(shard.embed_chance)
		shard.embedded_pain_chance = initial(shard.embedded_pain_chance)
		shard.embedded_impact_pain_multiplier = initial(shard.embedded_pain_multiplier)
		shard.embedded_ignore_throwspeed_threshold = initial(shard.embedded_ignore_throwspeed_threshold)

	playsound(machine, "shatter", 50)

	return incoming_damage * (3 / 4)

/datum/tilt_crit/pop_head
	name = "Head Pop"

/datum/tilt_crit/pop_head/is_valid(atom/movable/tilter, mob/living/carbon/victim)
	. = ..()
	return . && iscarbon(victim)

/datum/tilt_crit/pop_head/tip_crit_effect(atom/movable/tilter, mob/living/carbon/victim, incoming_damage)
	// pop!
	var/obj/item/organ/external/head/H = victim.get_organ("head")
	var/obj/item/organ/internal/brain/B = victim.get_int_organ_tag("brain")
	if(H)
		victim.visible_message("<span class='danger'>[H] gets crushed under [tilter], and explodes in a shower of gore!</span>", "<span class='userdanger'>Oh f-</span>")
		var/gibspawner = /obj/effect/gibspawner/human
		if(ismachineperson(victim))
			gibspawner = /obj/effect/gibspawner/robot
		else if(isalien(victim))
			gibspawner = /obj/effect/gibspawner/xeno

		new gibspawner(get_turf(victim))
		H.drop_organs()
		H.droplimb(TRUE)
		H.disfigure()
		victim.apply_damage(50, BRUTE, BODY_ZONE_HEAD)
	else
		H.visible_message("<span class='danger'>[victim]'s head seems to be crushed under [tilter]...but wait, they had none in the first place!</span>")
	if(B in H)
		victim.adjustBrainLoss(80)

	return 0

/datum/tilt_crit/lucky
	harmless = TRUE
	name = "Lucky"

/datum/tilt_crit/lucky/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim, incoming_damage)
	victim.visible_message(
		"<span class='danger'>[machine] crashes around [victim], but doesn't seem to crush them!</span>",
		"<span class='userdanger'>[machine] crashes around you, but only around you! You're fine!</span>"
	)

	return 1000
