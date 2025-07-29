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
	var/mob/living/carbon/human/owner
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
	///If the passive is for a specific class, or FLAYER_CATEGORY_GENERAL if not
	var/category = FLAYER_CATEGORY_GENERAL
	///If the passive only unlocks after the stages below it have been bought, for subclass passives
	var/stage = 0
	///A brief description of what the ability's upgrades do
	var/upgrade_info = "TODO add upgrade text for this passive"
	/// Does this passive need to process
	var/should_process = FALSE
	/// Do we increase the cost by a static amount? And by how much?
	var/static_upgrade_increase

/datum/mindflayer_passive/New()
	. = ..()
	current_cost = base_cost
	if(should_process)
		START_PROCESSING(SSobj, src)

/datum/mindflayer_passive/Destroy(force, ...)
	. = ..()
	if(!flayer)
		return
	on_remove()
	STOP_PROCESSING(SSobj, src)

///This is where most passive's effects get applied
/datum/mindflayer_passive/proc/on_apply()
	SHOULD_CALL_PARENT(TRUE)
	flayer.send_swarm_message(level ? upgrade_text : gain_text) //This will only be false when level = 0, when first bought
	level++
	current_cost += static_upgrade_increase
	if(level != 1) // Purchasing a passive also calls this proc
		SSblackbox.record_feedback("nested tally", "mindflayer_abilities", 1, list(name, "upgraded", level))
	return TRUE

/datum/mindflayer_passive/proc/on_remove()
	return

/datum/mindflayer_passive/process()
	return PROCESS_KILL

// SELF-BUFF PASSIVES
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
		if(FLAYER_POWER_LEVEL_ONE)
			owner.DeleteComponent(/datum/component/footstep)
		if(FLAYER_POWER_LEVEL_TWO)
			ADD_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/fluid_feet/on_remove()
	owner.AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	REMOVE_TRAIT(owner, TRAIT_NOSLIP, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/badass
	name = "Badassery"
	purchase_text = "Makes us more badass, allowing us to dual wield guns with no penalty, alongside other benefits."
	gain_text = "Engaging explosion apathy protocols."
	power_type = FLAYER_PURCHASABLE_POWER
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 50
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
	static_upgrade_increase = 30

/datum/mindflayer_passive/emp_resist/on_apply()
	..()
	switch(level)
		if(FLAYER_POWER_LEVEL_ONE)
			ADD_TRAIT(owner, TRAIT_EMP_RESIST, UNIQUE_TRAIT_SOURCE(src))
		if(FLAYER_POWER_LEVEL_TWO)
			ADD_TRAIT(owner, TRAIT_EMP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/emp_resist/on_remove()
	REMOVE_TRAIT(owner, TRAIT_EMP_IMMUNE, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(owner, TRAIT_EMP_RESIST, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/insulated
	name = "Insulated Chassis"
	purchase_text = "Become immune to basic shocks."
	gain_text = "The outer layer of our chassis gets slightly thicker."
	power_type = FLAYER_PURCHASABLE_POWER

/datum/mindflayer_passive/shock_resist/on_apply()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/shock_resist/on_remove()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, UNIQUE_TRAIT_SOURCE(src))

/datum/mindflayer_passive/regen
	name = "Replicating Nanites"
	purchase_text = "Gain a passive repairing effect."
	upgrade_info = "Heal an extra 1 brute and burn per tick."
	upgrade_text = "Our repair quickens."
	gain_text = "Diverting resources to repairing chassis."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	base_cost = 50
	should_process = TRUE

/datum/mindflayer_passive/regen/process()
	if(isspaceturf(get_turf(owner)) || owner.stat == DEAD) // No healing in space or while you're dead
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/flayer = owner
		flayer.adjustBruteLoss(-level, robotic = TRUE)
		flayer.adjustFireLoss(-level, robotic = TRUE)

/datum/mindflayer_passive/fix_components
	name = "Internal Nanite Application"
	purchase_text = "Slowly repair damage done to your organs."
	gain_text = "Administering reparative swarms to internal components."
	upgrade_text = "Our repair quickens."
	power_type = FLAYER_PURCHASABLE_POWER
	should_process = TRUE
	base_cost = 40
	max_level = 2
	var/heal_modifier = 0.4 // Same speed as mito

/datum/mindflayer_passive/fix_components/process()
	if(!ishuman(owner) || owner.stat == DEAD)
		return
	var/mob/living/carbon/human/flayer = owner
	for(var/obj/item/organ/internal/I in flayer.internal_organs)
		I.heal_internal_damage(heal_modifier * level, TRUE)
		if(istype(I, /obj/item/organ/internal/cyberimp))
			var/obj/item/organ/internal/cyberimp/implant = I
			implant.crit_fail = FALSE

/datum/mindflayer_passive/eye_enhancement
	name = "Enhanced Optical Sensitivity"
	purchase_text = "Adjust our optical sensors to see better in the dark."
	gain_text = "Focusing optics lens apeture."
	upgrade_info = "Gain the ability to see prey through walls"
	upgrade_text = "Increasing visible wavelength to infrared."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 2
	base_cost = 40
	static_upgrade_increase = 20

/datum/mindflayer_passive/eye_enhancement/on_apply()
	..()
	switch(level)
		if(FLAYER_POWER_LEVEL_ONE)
			ADD_TRAIT(owner, TRAIT_NIGHT_VISION, UNIQUE_TRAIT_SOURCE(src))
		if(FLAYER_POWER_LEVEL_TWO)
			ADD_TRAIT(owner, TRAIT_THERMAL_VISION, UNIQUE_TRAIT_SOURCE(src))
	var/mob/living/carbon/human/to_enhance = owner //Gotta make sure it calls the right update_sight()
	to_enhance.update_sight()

/datum/mindflayer_passive/eye_enhancement/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NIGHT_VISION, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, UNIQUE_TRAIT_SOURCE(src))
	var/mob/living/carbon/human/to_enhance = owner
	to_enhance.update_sight()

/datum/mindflayer_passive/drain_speed
	name = "Swarm Absorption Efficiency"
	purchase_text = "Adds a multiplier to the amount of swarms you drain per second."
	gain_text = "Our mental siphons grow stronger."
	upgrade_text = "Energy transfer rate increased by 100%"
	upgrade_info = "Further increase the rate of swarm siphoning."
	power_type = FLAYER_PURCHASABLE_POWER
	max_level = 3
	base_cost = 50
	static_upgrade_increase = 50

/datum/mindflayer_passive/drain_speed/on_apply()
	..()
	flayer.drain_multiplier += 0.5

/datum/mindflayer_passive/drain_speed/on_remove()
	flayer.drain_multiplier = initial(flayer.drain_multiplier)

/datum/mindflayer_passive/improved_joints
	name = "Reinforced Joints"
	purchase_text = "Prevents your limbs from falling off due to damage."
	gain_text = "Artificial skeletal structure reinforced."
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
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 40
	var/obj/item/organ/internal/eyes/optical_sensor/user_eyes

/datum/mindflayer_passive/telescopic_eyes/on_apply()
	. = ..()
	user_eyes = owner.get_int_organ(/obj/item/organ/internal/eyes)
	if(!user_eyes)
		return // TODO, add a refund proc?
	user_eyes.AddComponent(/datum/component/scope, item_action_type = /datum/action/item_action/organ_action/toggle, flags = SCOPE_CLICK_MIDDLE)
	for(var/datum/action/action in user_eyes.actions)
		action.background_icon_state = "bg_flayer"
		action.Grant(owner)

/datum/mindflayer_passive/telescopic_eyes/on_remove()
	user_eyes.DeleteComponent(/datum/component/scope)
	user_eyes = null // I made sure this doesn't accidentally delete the user's eyes

/datum/mindflayer_passive/ultimate_drain
	name = "Perfect Symbiosis"
	purchase_text = "Become a living siphon that drains victim's energy incredibly quickly."
	gain_text = "This vessel serves us well."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 400
	stage = FLAYER_CAPSTONE_STAGE
	category = FLAYER_CATEGORY_INTRUDER
	/// How much do we multiply the drain amount?
	var/drain_multiplier_amount = 10

/datum/mindflayer_passive/ultimate_drain/on_apply()
	..()
	flayer.drain_amount *= drain_multiplier_amount // 0.5 becomes 5 brain damage per tick, stacks with the multiplier

/datum/mindflayer_passive/ultimate_drain/on_remove()
	flayer.drain_amount /= drain_multiplier_amount

/datum/mindflayer_passive/torque_enhancer
	name = "Torque Enhancer"
	purchase_text = "Allows us to deal more damage with our unarmed strikes."
	gain_text = "Arm pistons reinforced."
	upgrade_text = "Increasing length of lever arm."
	upgrade_info = "Upgrades allows us to deal even more damage with our fists."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 75
	max_level = 3
	stage = 3
	category = FLAYER_CATEGORY_DESTROYER
	/// A reference to our martial art
	var/datum/martial_art/torque/style

/datum/mindflayer_passive/torque_enhancer/on_apply()
	..()
	if(!style)
		style = new()
		style.teach(owner)

	style.level = level

/datum/mindflayer_passive/torque_enhancer/on_remove()
	style.remove(owner)
	QDEL_NULL(style)

/datum/mindflayer_passive/radio_jammer
	name = "Destructive Interference"
	purchase_text = "Allows us toggle a close-range radio jamming signal."
	gain_text = "Localized communications brownout available."
	upgrade_info = "Upgrades increase the range of our jamming signal. At the apex of strength, we become invisible to silicon lifeforms."
	upgrade_text = "Our signal grows in strength."
	power_type = FLAYER_PURCHASABLE_POWER
	base_cost = 80
	max_level = 3
	static_upgrade_increase = 40 // Upgrading this doesn't really do a ton except being more annoying and letting people triangulate your location easier
	category = FLAYER_CATEGORY_INTRUDER
	stage = 2
	/// The internal jammer of the ability
	var/obj/item/jammer/internal_jammer
	/// The owner's invisibility before this ability
	var/stored_invis

/datum/mindflayer_passive/radio_jammer/on_apply()
	..()
	if(!internal_jammer)
		internal_jammer = new /obj/item/jammer(owner) //Shove it in the flayer's chest
		for(var/datum/action/action in internal_jammer.actions)
			action.background_icon_state = "bg_flayer"
			action.Grant(owner)

	internal_jammer.range = 15 + ((level - 1) * 5) //Base range of the jammer is 15, each level adds 5 tiles for a max of 25 if you want to be REALLY annoying

	if(level == FLAYER_POWER_LEVEL_THREE)
		ADD_TRAIT(owner, TRAIT_AI_UNTRACKABLE, "silicon_cham[UID()]")
		stored_invis = owner.invisibility
		owner.set_invisible(SEE_INVISIBLE_LIVING)
		to_chat(owner, "<span class='notice'>You feel a slight shiver as the cybernetic obfuscators activate.</span>")

/datum/mindflayer_passive/radio_jammer/on_remove()
	QDEL_NULL(internal_jammer)
	REMOVE_TRAIT(owner, TRAIT_AI_UNTRACKABLE, "silicon_cham[UID()]")
	if(stored_invis)
		owner.set_invisible(stored_invis)
	to_chat(owner, "<span class='notice'>You feel a slight shiver as the cybernetic obfuscators deactivate.</span>")
