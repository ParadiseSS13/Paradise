// This file contains all of the mindflayer passives

/datum/mindflayer_passive
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///The level of the passive, used for upgrading passives. Basic level is 1
	var/level = 0
	var/max_level = 1
	var/mob/living/owner
	var/gain_desc
	var/power_type = FLAYER_UNOBTAINABLE_POWER

/datum/mindflayer_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You can now use [src]."

///This is for passives that need to use SSProcessing
/datum/mindflayer_passive/processed

/datum/mindflayer_passive/processed/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/mindflayer_passive/processed/Destroy(force, ...)
	. = ..()
	STOP_PROCESSING(SSobj, src)


/datum/mindflayer_passive/proc/on_apply(datum/antagonist/mindflayer/flayer)
	if(level > max_level)
		flayer.send_swarm_message("We cannot upgrade this aspect further.")
		return
	level++

/datum/mindflayer_passive/proc/on_remove(datum/antagonist/mindflayer/flayer)
	return

/datum/mindflayer_passive/process()
	return

//SELF-BUFF PASSIVES
/datum/mindflayer_passive/armored_plating
	purchase_text = "The swarm will reinforce your armor, strengthening it against attacks."
	upgrade_text = "The swarm adds more layers of armored nanites, strengthening the plating even more."
	gain_desc = "You feel your plating being reinforced by the swarm."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 10
	var/armor_value = 0

/datum/mindflayer_passive/armored_plating/on_apply(datum/antagonist/mindflayer/flayer)
	..()
	armor_value = 5 * level
	owner.dna.species.armor += armor_value

/datum/mindflayer_passive/armored_plating/on_remove(datum/antagonist/mindflayer/flayer)
	armor_value = 5 * level
	owner.dna.species.armor -= armor_value

/datum/mindflayer_passive/fluid_feet
	purchase_text = "The swarm will make your legs more fluid, resulting in it muting your footsteps."
	upgrade_text = "Your feet become even more malleable, seemingly melting into the floor; you feel oddly stable."
	gain_desc = "Your limbs start slowly melting into the floor."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/fluid_feet/on_apply(datum/antagonist/mindflayer/flayer)
	..()
	switch(level)
		if(1)
			qdel(owner.GetComponent(/datum/component/footstep))
		if(2)
			owner.flags |= NOSLIP // Does this work? We'll find out once the Tgui is working

/datum/mindflayer_passive/fluid_feet/on_remove(datum/antagonist/mindflayer/flayer)
	owner.AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	owner.flags &= ~NOSLIP

/datum/mindflayer_passive/new_crit
	purchase_text = "I give up, IPCs are based now"
	upgrade_text = "Add this later"
	gain_desc = "Ayyyy lmao"
	power_type = FLAYER_INNATE_POWER //Just for testing

/datum/mindflayer_passive/new_crit/on_apply(datum/antagonist/mindflayer/flayer)
	owner.dna.species.dies_at_threshold = FALSE

/datum/mindflayer_passive/processed/regen
	purchase_text = "We passively regenerate health."
	upgrade_text = "Our regeneration accelerates."
	gain_desc = "Diverting resources to repairing chassis."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3

/datum/mindflayer_passive/processed/regen/process()
	owner.heal_overall_damage(level, level) //Heals 1 brute/burn for each level of the passive
//MINION PASSIVES
/datum/mindflayer_passive/processed/regen/minion
	purchase_text = "Your minions passively regenerate health."
	upgrade_text = "The swarms begin replicating and repairing themselves at an alarming rate."
	gain_desc = "Commanding all autonomous units to begin self-repair protocol."
