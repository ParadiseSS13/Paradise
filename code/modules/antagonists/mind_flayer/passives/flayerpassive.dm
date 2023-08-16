// This file contains all of the mindflayer passives

/datum/mindflayer_passive
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///All passives start at level on
	var/level = 1
	var/mob/living/owner
	var/gain_desc

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

/datum/mindflayer_passive/armored_plating/on_apply(datum/antagonist/mindflayer/flayer)
	var/armor_value = 5 * level
	owner.dna.species.armor = armor_value
