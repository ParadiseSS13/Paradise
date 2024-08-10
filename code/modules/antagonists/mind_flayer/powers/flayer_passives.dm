// This file contains all of the mindflayer passives

/datum/mindflayer_passive
	var/name = "default dan"
	///The text we want to show the player in the shop
	var/purchase_text = "Oopsie daisies! No purchase text on this ability!"
	///The text shown to the player character on upgrade
	var/upgrade_text = "Uh oh someone forgot to add upgrade text!"
	///The level of the passive, used for upgrading passives. Basic level is 1
	var/level = 0
	var/max_level = 1
	///The mob who the passive affects, usually an IPC. Set in force_add_abillity
	var/mob/living/owner
	///The mindflayer datum we'll reference back to. Set in force_add_abillity
	var/datum/antagonist/mindflayer/flayer
	///The text shown to the player character when bought
	var/gain_text = "Someone forgot to add this text"
	///Uses a power type define, should be FLAYER_UNOBTAINABLE_POWER, FLAYER_PURCHASABLE_POWER, or FLAYER_INNATE_POWER
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	///How much it will cost to buy a passive. Upgrading an ability increases the cost to the initial cost times the level.
	var/swarm_cost = 30
	///If the passive is for a specific class, or CATEGORY_GENERAL if not
	var/category = CATEGORY_GENERAL
	///If the passive requires prerequisites, currently only important for badass.
	var/stage = 0

///For passives that need to use SSObj
/datum/mindflayer_passive/processed

/datum/mindflayer_passive/Destroy(force, ...)
	..()
	on_remove()

/datum/mindflayer_passive/processed/New()
	START_PROCESSING(SSobj, src)

/datum/mindflayer_passive/processed/Destroy(force, ...)
	..()
	STOP_PROCESSING(SSobj, src)

///Returns false if it couldn't get upgraded, Call if(!..()) at the start of every passive's on_apply to properly apply the level check
/datum/mindflayer_passive/proc/on_apply()
	SHOULD_CALL_PARENT(TRUE)
	if(level >= max_level)
		flayer.send_swarm_message("We cannot upgrade this aspect further.")
		return FALSE
	flayer.send_swarm_message("[level ? upgrade_text : gain_text]") //This will only be false when level = 0, when first bought
	level = level + 1
	swarm_cost = initial(swarm_cost) * level
	log_debug("[src] purchased at level [level], max level is [max_level]")
	return TRUE

/datum/mindflayer_passive/proc/on_remove()
	return

/datum/mindflayer_passive/process()
	return

//SELF-BUFF PASSIVES
/datum/mindflayer_passive/armored_plating
	name = "Armored Plating"
	purchase_text = "Increase your natural armor."
	upgrade_text = "The swarm adds more layers of armored nanites, strengthening the plating even more."
	gain_text = "You feel your plating being reinforced by the swarm."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	var/armor_value = 0

/datum/mindflayer_passive/armored_plating/on_apply()
	if(!..())
		return FALSE
	var/owner_armor = owner.dna.species.armor
	var/temp_armor_value = owner_armor - (5 * (level - 1)) // We store our current armor value here just in case they already have armor
	armor_value = temp_armor_value + 5 * level
	owner.dna.species.armor = armor_value

/datum/mindflayer_passive/armored_plating/on_remove()
	owner.dna.species.armor -= armor_value

/datum/mindflayer_passive/fluid_feet
	name = "Fluid Feet"
	purchase_text = "Mute your footsteps, then upgrade to become mostly unslippable."
	upgrade_text = "Your feet become even more malleable, seemingly melting into the floor; you feel oddly stable."
	gain_text = "Your limbs start slowly melting into the floor."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/fluid_feet/on_apply()
	if(!..())
		return FALSE
	switch(level)
		if(POWER_LEVEL_ONE)
			qdel(owner.GetComponent(/datum/component/footstep))
		if(POWER_LEVEL_TWO)
			ADD_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/fluid_feet/on_remove()
	owner.AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	REMOVE_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/new_crit
	name = "NEW CRIT WHOOPEE!"
	purchase_text = "I give up, IPCs are based now"
	upgrade_text = "Add this later"
	gain_text = "Ayyyy lmao"
	power_type = FLAYER_PURCHASABLE_POWER //Just for testing
	category = CATEGORY_DESTROYER

/datum/mindflayer_passive/new_crit/on_apply()
	if(!..())
		return FALSE
	owner.dna.species.dies_at_threshold = FALSE

/datum/mindflayer_passive/badass
	name = "Badassery"
	purchase_text = "Make yourself more badass, allowing you to dual wield guns with no penalty, alongside other benefits."
	gain_text = "Engaging explosion apathy protocols."
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_DESTROYER
	swarm_cost = 100
	stage = 2

/datum/mindflayer_passive/badass/on_apply()
	if(!..())
		return FALSE
	ADD_TRAIT(owner, TRAIT_BADASS, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/badass/on_remove()
	REMOVE_TRAIT(owner, TRAIT_BADASS, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/emp_resist
	name = "Internal Faraday Cage"
	purchase_text = "Resist EMP effects, level 2 negates them entirely."
	upgrade_text = "Faraday cage at max efficiency."
	gain_text = "Faraday cage operational."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/emp_resist/on_apply()
	if(!..())
		return FALSE
	switch(level)
		if(1)
			ADD_TRAIT(owner, TRAIT_EMP_RESIST, UNIQUE_TRAIT_SOURCE(src))
		if(2)
			ADD_TRAIT(owner, TRAIT_EMP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/emp_resist/on_remove()
	REMOVE_TRAIT(owner, TRAIT_EMP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(owner, TRAIT_EMP_RESIST, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/insulated
	name = "Insulated Chassis"
	purchase_text = "Become immune to basic shocks."
	gain_text = "The outer layer of our chassis gets slightly thicker."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 1

/datum/mindflayer_passive/shock_resist/on_apply()
	if(!..())
		return FALSE
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/shock_resist/on_remove()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/processed/regen
	name = "Regeneration"
	purchase_text = "Regain HP passively, level scales the amount healed."
	upgrade_text = "Our repair accelerates."
	gain_text = "Diverting resources to repairing chassis."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3

/datum/mindflayer_passive/processed/regen/process()
	if(ishuman(owner))
		var/mob/living/carbon/human/flayer = owner
		flayer.adjustBruteLoss(-level, robotic = TRUE)
		flayer.adjustFireLoss(-level, robotic = TRUE)

/datum/mindflayer_passive/eye_enhancement
	name = "Enhanced Optical Sensitivity"
	purchase_text = "Level 1 grants night vision, level 2 lets you see creatures through walls."
	gain_text = "Focusing optics lens apeture."
	upgrade_text = "Increasing visible wavelength to infrared."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2
	swarm_cost = 40

/datum/mindflayer_passive/eye_enhancement/on_apply()
	if(!..())
		return FALSE
	switch(level)
		if(1)
			ADD_TRAIT(owner, TRAIT_NIGHT_VISION, UNIQUE_TRAIT_SOURCE(src))
		if(2)
			ADD_TRAIT(owner, TRAIT_THERMAL_VISION, UNIQUE_TRAIT_SOURCE(src))
	var/mob/living/carbon/human/to_enhance = owner //Gotta make sure it calls the right update_sight()
	to_enhance.update_sight()

/datum/mindflayer_passive/eye_enhancement/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, UNIQUE_TRAIT_SOURCE(src))
	var/mob/living/carbon/human/to_enhance = owner
	to_enhance.update_sight()

/datum/mindflayer_passive/drain_speed
	name = "Swarm Absorbtion Efficiency"
	purchase_text = "Adds a multiplier to the amount of swarms you drain per second."
	gain_text = "something something efficiency WIP"
	upgrade_text = "MORE EFFICIENCY IS MORE GOOD WIP"
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	swarm_cost = 50

/datum/mindflayer_passive/drain_speed/on_apply()
	if(!..())
		return FALSE
	flayer.drain_multiplier++

/datum/mindflayer_passive/drain_speed/on_remove()
	flayer.drain_multiplier = initial(flayer.drain_multiplier)

/datum/mindflayer_passive/improved_joints
	name = "Reinforced Joints"
	purchase_text = "Prevents your limbs from falling off due to damage."
	gain_text = "Makes joints gooder"
	max_level = 1
	swarm_cost = 50

/datum/mindflayer_passive/improved_joints/on_apply()
	if(!..())
		return FALSE
	ADD_TRAIT(owner, TRAIT_IPC_JOINTS_SEALED, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/improved_joints/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IPC_JOINTS_SEALED, UNIQUE_TRAIT_SOURCE(src))


