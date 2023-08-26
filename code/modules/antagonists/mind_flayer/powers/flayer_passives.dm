// This file contains all of the mindflayer passives

/datum/mindflayer_passive
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///The level of the passive, used for upgrading passives. Basic level is 1
	var/level = 1
	var/mob/living/owner
	var/gain_desc
	var/power_type = FLAYER_UNOBTAINABLE_POWER

/datum/mindflayer_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You can now use [src]."

/datum/mindflayer_passive/proc/on_apply(datum/antagonist/mindflayer/flayer)
	return

/datum/mindflayer_passive/proc/on_remove(datum/antagonist/mindflayer/flayer)
	return

/datum/mindflayer_passive/armored_plating
	purchase_text = "The swarm will reinforce your armor, strengthening it against attacks."
	upgrade_text = "The swarm adds more layers of armored nanites, strengthening the plating even more."
	gain_desc = "You feel your plating being reinforced by the swarm."
	power_type = FLAYER_PURCHASABLE_POWER

/datum/mindflayer_passive/armored_plating/on_apply(datum/antagonist/mindflayer/flayer)
	var/armor_value = 5 * level
	owner.dna.species.armor = armor_value

/datum/mindflayer_passive/fluid_feet
	purchase_text = "The swarm will make your legs more fluid, resulting in it muting your footsteps."
	upgrade_text = "Your feet become even more malleable, seemingly melting into the floor; you feel oddly stable."
	gain_desc = "Your limbs start slowly melting into the floor."
	power_type = FLAYER_PURCHASABLE_POWER

/datum/mindflayer_passive/fluid_feet/on_apply(datum/antagonist/mindflayer/flayer)
	switch(level)
		if(1)
			qdel(owner.GetComponent(/datum/component/footstep))
		if(2)
			owner.flags |= NOSLIP // Does this work? We'll find out once the Tgui is working

/datum/mindflayer_passive/new_crit
	purchase_text = "I give up, IPCs are based now"
	upgrade_text = "Add this later"
	gain_desc = "Ayyyy lmao"
	power_type = FLAYER_INNATE_POWER //Just for testing

/datum/mindflayer_passive/new_crit/on_apply(datum/antagonist/mindflayer/flayer)
	owner.dna.species.dies_at_threshold = FALSE
