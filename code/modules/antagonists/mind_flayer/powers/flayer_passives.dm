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
	///The base cost of an ability, used to calculate how much upgrades should cost.
	var/base_cost = 30
	///How much it will cost to upgrade this passive.
	var/current_cost
	///If the passive is for a specific class, or CATEGORY_GENERAL if not
	var/category = CATEGORY_GENERAL
	///If the passive requires prerequisites, currently only important for badass.
	var/stage = 0
	///A brief description of what the ability's upgrades do
	var/upgrade_info = "TODO add upgrade text for this passive"
	/// Does this passive need to process
	var/should_process = TRUE

/datum/mindflayer_passive/New()
	. = ..()
	current_cost = base_cost
	if(should_process)
		START_PROCESSING(SSobj, src)

/datum/mindflayer_passive/Destroy(force, ...)
	. = ..()
	on_remove()
	STOP_PROCESSING(SSobj, src)

///This is where most passive's effects get applied
/datum/mindflayer_passive/proc/on_apply()
	SHOULD_CALL_PARENT(TRUE)
	flayer.send_swarm_message(level ? upgrade_text : gain_text) //This will only be false when level = 0, when first bought
	level++
	current_cost = base_cost * (level + 1)
	log_debug("[src] purchased at level [level], max level is [max_level]")
	return TRUE

/datum/mindflayer_passive/proc/on_remove()
	return

/datum/mindflayer_passive/process()
	return

//SELF-BUFF PASSIVES
/datum/mindflayer_passive/armored_plating
	name = "Armored Plating"
	purchase_text = "Increases our natural armor."
	upgrade_text = "The swarm adds more layers of armored nanites, strengthening the plating even more."
	upgrade_info = "Further increases base armor by 10"
	gain_text = "You feel your chassis being reinforced by the swarm."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	var/armor_value = 0

/datum/mindflayer_passive/armored_plating/on_apply()
	..()
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
	upgrade_info = "Become nearly unslippable."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/fluid_feet/on_apply()
	..()
	switch(level)
		if(POWER_LEVEL_ONE)
			qdel(owner.GetComponent(/datum/component/footstep))
		if(POWER_LEVEL_TWO)
			ADD_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/fluid_feet/on_remove()
	owner.AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	REMOVE_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/new_crit
	name = "Release Limiters"
	purchase_text = "We remove our limiters, allowing us to remain active while severely damaged."
	gain_text = "Advanced urgent protocols engaged."
	power_type = FLAYER_PURCHASABLE_POWER //Just for testing
	category = CATEGORY_DESTROYER

/datum/mindflayer_passive/new_crit/on_apply()
	..()
	owner.dna.species.dies_at_threshold = FALSE

/datum/mindflayer_passive/badass
	name = "Badassery"
	purchase_text = "Make yourself more badass, allowing you to dual wield guns with no penalty, alongside other benefits."
	gain_text = "Engaging explosion apathy protocols."
	power_type = FLAYER_PURCHASABLE_POWER
	category = CATEGORY_DESTROYER
	base_cost = 100
	stage = 2

/datum/mindflayer_passive/badass/on_apply()
	..()
	ADD_TRAIT(owner, TRAIT_BADASS, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/badass/on_remove()
	REMOVE_TRAIT(owner, TRAIT_BADASS, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/emp_resist
	name = "Internal Faraday Cage"
	purchase_text = "Resist EMP effects."
	upgrade_text = "Faraday cage at max efficiency."
	upgrade_info = "Become completely immune to EMPs."
	gain_text = "Faraday cage operational."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2

/datum/mindflayer_passive/emp_resist/on_apply()
	..()
	switch(level)
		if(POWER_LEVEL_ONE)
			ADD_TRAIT(owner, TRAIT_EMP_RESIST, UNIQUE_TRAIT_SOURCE(src))
		if(POWER_LEVEL_TWO)
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
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/shock_resist/on_remove()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/regen
	name = "Regeneration"
	purchase_text = "Gain a passive repairing effect."
	upgrade_info = "Heal an extra 1 brute and burn per tick."
	upgrade_text = "Our repair accelerates."
	gain_text = "Diverting resources to repairing chassis."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	should_process = TRUE

/datum/mindflayer_passive/regen/process()
	if(isspaceturf(get_turf(owner))) // No healing in space
		return
	if(ishuman(owner) && owner.stat == CONSCIOUS)
		var/mob/living/carbon/human/flayer = owner
		flayer.adjustBruteLoss(-level, robotic = TRUE)
		flayer.adjustFireLoss(-level, robotic = TRUE)

/datum/mindflayer_passive/eye_enhancement
	name = "Enhanced Optical Sensitivity"
	purchase_text = "Adjust our optical sensors to see better in the dark."
	gain_text = "Focusing optics lens apeture."
	upgrade_info = "Gain the ability to see prey through walls"
	upgrade_text = "Increasing visible wavelength to infrared."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2
	base_cost = 40

/datum/mindflayer_passive/eye_enhancement/on_apply()
	..()
	switch(level)
		if(POWER_LEVEL_ONE)
			ADD_TRAIT(owner, TRAIT_NIGHT_VISION, UNIQUE_TRAIT_SOURCE(src))
		if(POWER_LEVEL_TWO)
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
	gain_text = "Our mental siphons grow stronger."
	upgrade_text = "Energy transfer rate increased by 100%"
	upgrade_info = "Further increase the rate of swarm siphoning."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	base_cost = 75

/datum/mindflayer_passive/drain_speed/on_apply()
	..()
	flayer.drain_multiplier++

/datum/mindflayer_passive/drain_speed/on_remove()
	flayer.drain_multiplier = initial(flayer.drain_multiplier)

/datum/mindflayer_passive/improved_joints
	name = "Reinforced Joints"
	purchase_text = "Prevents your limbs from falling off due to damage."
	gain_text = "Artificial skeletal structure reinforced."
	max_level = 1
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 50

/datum/mindflayer_passive/improved_joints/on_apply()
	..()
	ADD_TRAIT(owner, TRAIT_IPC_JOINTS_SEALED, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/improved_joints/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IPC_JOINTS_SEALED, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/telescopic_eyes
	name = "Telescopic Eyes"
	purchase_text = "Allows you to expand your sight range, as if you were using a scope."
	gain_text = "Precise optics control engaged."
	max_level = 1
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 50
	var/obj/item/organ/internal/eyes/optical_sensor/user_eyes

/datum/mindflayer_passive/telescopic_eyes/on_apply()
	. = ..()
	user_eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)
	user_eyes.AddComponent(/datum/component/scope, item_action_type = /datum/action/item_action/organ_action/toggle, flags = SCOPE_CLICK_MIDDLE)
	for(var/datum/action/action in user_eyes.actions)
		action.Grant(owner)

/datum/mindflayer_passive/telescopic_eyes/on_remove()
	qdel(user_eyes.GetComponent(/datum/component/scope))

/datum/mindflayer_passive/ultimate_drain
	name = "Perfect Symbiosis"
	purchase_text = "Become a living siphon that drains victim's energy incredibly quickly."
	gain_text = "This vessel serves us well."
	max_level = 1
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 400
	stage = 4
	category = CATEGORY_INTRUDER

/datum/mindflayer_passive/ultimate_drain/on_apply()
	..()
	flayer.drain_amount *= 10 // 0.5 becomes 5 brain damage per tick, stacks with the multiplier

/datum/mindflayer_passive/ultimate_drain/on_remove()
	flayer.drain_amount = 0.5


