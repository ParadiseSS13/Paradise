/**
 * Framework for custom vendor crits.
 */

/datum/vendor_crit
	/// If it'll deal damage or not
	var/harmless = FALSE
	/// If we should be thrown against the mob or not.
	var/fall_towards_mob = TRUE

/**
 * Return whether or not the crit selected is valid.
 */
/datum/vendor_crit/proc/is_valid(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	return TRUE

/***
 * Perform the tip crit effect on a victim.
 * Arguments:
 * * machine - The machine that was tipped over
 * * user - The unfortunate victim upon whom it was tipped over
 * Returns: The "crit rebate", or the amount of damage to subtract from the original amount of damage dealt, to soften the blow.
 */
/datum/vendor_crit/proc/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	return 0

/datum/vendor_crit/shatter

/datum/vendor_crit/shatter/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
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
	return machine.squish_damage * (5/6)

/datum/vendor_crit/pin

/datum/vendor_crit/pin/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	machine.forceMove(get_turf(victim))
	machine.buckle_mob(victim, force=TRUE)
	victim.visible_message(
		"<span class='danger'>[victim] gets pinned underneath [machine]!</span>",
		"<span class='userdanger'>You are pinned down by [machine]!</span>"
	)

	return 0

/datum/vendor_crit/embed

/datum/vendor_crit/embed/is_valid(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	. = ..()
	if(machine.num_shards <= 0)
		return FALSE

/datum/vendor_crit/embed/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
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

	return machine.squish_damage * (3/4)

/datum/vendor_crit/pop_head

/datum/vendor_crit/pop_head/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	// pop!
	var/obj/item/organ/external/head/H = victim.get_organ("head")
	var/obj/item/organ/internal/brain/B = victim.get_int_organ_tag("brain")
	if(H)
		victim.visible_message("<span class='danger'>[H] gets crushed under [machine], and explodes in a shower of gore!</span>", "<span class='userdanger'>Oh f-</span>")
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
		H.visible_message("<span class='danger'>[victim]'s head seems to be crushed under [machine]...but wait, they had none in the first place!</span>")
	if(B in H)
		victim.adjustBrainLoss(80)

	return 0

/datum/vendor_crit/lucky
	harmless = TRUE

/datum/vendor_crit/lucky/tip_crit_effect(obj/machinery/economy/vending/machine, mob/living/carbon/victim)
	victim.visible_message(
		"<span class='danger'>[machine] crashes around [victim], but doesn't seem to crush them!</span>",
		"<span class='userdanger'>[machine] crashes around you, but only around you! You're fine!</span>"
	)

	return 1000
