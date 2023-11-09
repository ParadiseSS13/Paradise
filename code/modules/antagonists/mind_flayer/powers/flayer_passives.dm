// This file contains all of the mindflayer passives

/datum/mindflayer_passive
	///The text we want to show the player in the shop
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	///The text shown to the player character on upgrade
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///The level of the passive, used for upgrading passives. Basic level is 1
	var/level = 0
	var/max_level = 1
	///The mob who the passive affects, is set in force_add_ability
	var/mob/living/owner
	var/datum/antagonist/mindflayer/flayer
	///The text shown to the player character when bought
	var/gain_desc = "Someone forgot to add this text"
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	///How much it will cost to buy a passive, will increase as passive gets upgraded more.
	var/cost = 30
/datum/mindflayer_passive/New()
	..()
	flayer = ismindflayer(owner)
	if(gain_desc)
		flayer.send_swarm_message(gain_desc)

///For passives that need to use SSObj
/datum/mindflayer_passive/processed

/datum/mindflayer_passive/processed/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/mindflayer_passive/processed/Destroy(force, ...)
	. = ..()
	STOP_PROCESSING(SSobj, src)

///You'll want to call ..() at the start of every passive's on_apply, Returns false if it couldn't get upgraded
/datum/mindflayer_passive/proc/on_apply()
	if(level >= max_level)
		flayer.send_swarm_message("We cannot upgrade this aspect further.")
		return FALSE
	level++
	cost = initial(cost) * level

/datum/mindflayer_passive/proc/on_remove()
	return

/datum/mindflayer_passive/process()
	return

//SELF-BUFF PASSIVES
/datum/mindflayer_passive/armored_plating
	purchase_text = "Increase your natural armor."
	upgrade_text = "The swarm adds more layers of armored nanites, strengthening the plating even more."
	gain_desc = "You feel your plating being reinforced by the swarm."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 10
	var/armor_value = 0

/datum/mindflayer_passive/armored_plating/on_apply()
	..()
	var/owner_armor = owner.dna.species.armor
	var/temp_armor_value = owner_armor - (5 * (level - 1)) // We store our current armor value here just in case they already have armor
	armor_value = temp_armor_value + 5 * level
	owner.dna.species.armor = armor_value

/datum/mindflayer_passive/armored_plating/on_remove()
	armor_value = 5 * level
	owner.dna.species.armor -= armor_value

/datum/mindflayer_passive/fluid_feet
	purchase_text = "Mute your footsteps, then upgrade to become mostly unslippable."
	upgrade_text = "Your feet become even more malleable, seemingly melting into the floor; you feel oddly stable."
	gain_desc = "Your limbs start slowly melting into the floor."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/fluid_feet/on_apply()
	..()
	switch(level)
		if(POWER_LEVEL_ONE)
			qdel(owner.GetComponent(/datum/component/footstep))
		if(POWER_LEVEL_TWO)
			owner.flags |= NOSLIP // Doesn't work, TODO: refactor noslips to work with traits

/datum/mindflayer_passive/fluid_feet/on_remove()
	owner.AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	owner.flags &= ~NOSLIP

/datum/mindflayer_passive/new_crit
	purchase_text = "I give up, IPCs are based now"
	upgrade_text = "Add this later"
	gain_desc = "Ayyyy lmao"
	power_type = FLAYER_PURCHASABLE_POWER //Just for testing

/datum/mindflayer_passive/new_crit/on_apply()
	owner.dna.species.dies_at_threshold = FALSE

/datum/mindflayer_passive/badass
	purchase_text = "Make yourself more badass, allowing you to dual wield guns with no penalty, alongside other benefits."
	gain_desc = "Engaging explosion apathy protocols."
	power_type = FLAYER_PURCHASABLE_POWER
	cost = 100

/datum/mindflayer_passive/badass/on_apply()
	ADD_TRAIT(owner, TRAIT_BADASS, src)

/datum/mindflayer_passive/badass/on_remove()
	REMOVE_TRAIT(owner, TRAIT_BADASS, src)

/datum/mindflayer_passive/processed/regen
	purchase_text = "Regain HP passively, level scales the amount healed."
	upgrade_text = "Our regeneration accelerates."
	gain_desc = "Diverting resources to repairing chassis."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3

/datum/mindflayer_passive/processed/regen/process()
	owner.heal_overall_damage(level, level) //Heals 1 brute/burn for each level of the passive

//MINION PASSIVES
/datum/mindflayer_passive/processed/regen/minion // Note: this isn't something that should be handled here, namely it should be done in the summon mobs spell file, which I'll implement later
	purchase_text = "Your minions will passively regenerate health."
	upgrade_text = "The swarms begin replicating and repairing themselves at an alarming rate."
	gain_desc = "Commanding all autonomous units to begin self-repair protocol."
