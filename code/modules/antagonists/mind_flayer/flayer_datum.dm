/datum/antagonist/mindflayer
	name = "Mindflayer"
	job_rank = ROLE_MIND_FLAYER
	special_role = SPECIAL_ROLE_MIND_FLAYER
	antag_hud_type = ANTAG_HUD_MIND_FLAYER
	antag_hud_name = "hudflayer"
	wiki_page_name = "Mindflayer"
	/// The current amount of swarms the mind flayer has access to purchase with
	var/usable_swarms = 0
	/// The total points of brain damage the flayer has harvested, only used for logging purposes.
	var/total_swarms_gathered = 0
	/// The current person being drained
	var/mob/living/carbon/human/harvesting
	/// The list of all purchased spell and passive objects
	var/list/powers = list()
	/// A list of all powers and passives mindflayers can buy
	var/list/ability_list = list()
	///List for keeping track of who has already been drained
	var/list/drained_humans = list()
	/// How fast the flayer's touch drains
	var/drain_multiplier = 1
	/// The base brain damage dealt per tick of the drain
	var/drain_amount = 0.5
	/// A list of the categories and their associated stages of the power
	var/list/category_stage = list(FLAYER_CATEGORY_GENERAL = 1, FLAYER_CATEGORY_DESTROYER = 1, FLAYER_CATEGORY_INTRUDER = 1)
	/// If the mindflayer can still pick a stage 4 ability
	var/can_pick_capstone = TRUE
	/// Have we notified that our victim does not give swarms from draining
	var/has_notified = FALSE
	boss_title = "Master Mindflayer"

/datum/antagonist/mindflayer/New()
	. = ..()
	if(!length(ability_list))
		ability_list = get_spells_of_type(FLAYER_PURCHASABLE_POWER)
		ability_list += get_passives_of_type(FLAYER_PURCHASABLE_POWER)

/datum/antagonist/mindflayer/Destroy(force, ...)
	QDEL_NULL(owner.current?.hud_used?.vampire_blood_display)
	harvesting = null
	remove_all_abilities()
	remove_all_passives()
	..()

/datum/antagonist/mindflayer/add_owner_to_gamemode()
	SSticker.mode.mindflayers += owner

/datum/antagonist/mindflayer/remove_owner_from_gamemode()
	SSticker.mode.mindflayers -= owner

// This proc adds extra things, and base abilities that the mindflayer should get upon becoming a mindflayer
/datum/antagonist/mindflayer/on_gain()
	. = ..()
	var/list/innate_powers = get_spells_of_type(FLAYER_INNATE_POWER)
	for(var/power_path as anything in innate_powers)
		var/datum/spell/flayer/to_add = new power_path
		add_ability(to_add)
	owner.current.faction += list("flayer") // In case our robot is mindlessly spawned in somehow, and they won't accidentally kill us

/datum/antagonist/mindflayer/give_objectives()
	add_antag_objective(/datum/objective/swarms)
	forge_basic_objectives()

/datum/antagonist/mindflayer/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	remove_all_abilities()
	remove_all_passives()
	if(isplasmaman(extractor)) // Normally, only IPCs can be flayers. This is in case they somehow end up mindswapped to a plasmaman.
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/mindflayer/plasmaman)
	else
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/mindflayer)
	radio.autosay("<b>--ZZZT!- Excellent job, [extractor.real_name]. Proceed to -^%&!-ZZT!-</b>", "Master Flayer", "Security")
	SSblackbox.record_feedback("tally", "successful_extraction", 1, "Mindflayer")

/datum/antagonist/mindflayer/proc/get_swarms()
	return usable_swarms

/datum/antagonist/mindflayer/proc/set_swarms(amount, update_total = FALSE) //If you adminbus someone's swarms it won't add or remove to the total
	var/old_swarm_amount = usable_swarms
	usable_swarms = amount
	if(update_total)
		var/difference = usable_swarms - old_swarm_amount
		if(difference < 0)
			// Otherwise buying an ability can reduce your `total_swarms_gathered`
			return
		total_swarms_gathered += difference

/*
* amount - The positive or negative number to adjust the swarm count by, result clamped above 0
*/
/datum/antagonist/mindflayer/proc/adjust_swarms(amount, bound_lower = 0, bound_upper = INFINITY)
	set_swarms(clamp((usable_swarms + amount), bound_lower, bound_upper), TRUE)

//This is mostly for flavor, for framing messages as coming from the swarm itself. The other reason is so I can type "span" less.
/datum/antagonist/mindflayer/proc/send_swarm_message(message)
	if(HAS_TRAIT(owner.current, TRAIT_MINDFLAYER_NULLIFIED))
		message = stutter(message, 0, TRUE)
	to_chat(owner.current, "<span class='sinister'>[message]</span>")

/**
	Checks for any reason that you should not be able to drain someone for.
	Returns either true or false, if the harvest will work or not.
*/
/datum/antagonist/mindflayer/proc/check_valid_harvest(mob/living/carbon/human/H)
	if(HAS_TRAIT(owner.current, TRAIT_MINDFLAYER_NULLIFIED))
		send_swarm_message("We do not have the energy for this...")
		return FALSE
	if(IS_MINDFLAYER(H))
		send_swarm_message("Their hive rejects the connection.")
		return FALSE
	var/obj/item/organ/internal/brain/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(!istype(brain))
		send_swarm_message("This entity has no brain to harvest from.")
		return FALSE
	if(!H.ckey && !H.player_ghosted)
		send_swarm_message("This brain does not contain the spark that feeds us. Find more suitable prey.")
		return FALSE
	if(brain.damage >= brain.max_damage || (H.stat == DEAD && !H.has_status_effect(STATUS_EFFECT_RECENTLY_SUCCUMBED)))
		send_swarm_message("We detect no neural activity to harvest from this brain.")
		return FALSE
	if(HAS_MIND_TRAIT(H, TRAIT_XENOBIO_SPAWNED_HUMAN))
		send_swarm_message("This brain is unsuitable to harvest.")
		return FALSE

	var/unique_drain_id = H.UID()
	if(isnull(drained_humans[unique_drain_id]))
		drained_humans[unique_drain_id] = 0
	else if(drained_humans[unique_drain_id] > BRAIN_DRAIN_LIMIT)
		if(!has_notified)
			has_notified = TRUE
			send_swarm_message("You have drained most of the life force from [H]'s brain, and you will get no more swarms from them!")
		return DRAIN_BUT_NO_SWARMS
	return TRUE

/**
	Begins draining the brain of H, gains swarms equal to the amount of brain damage dealt per tick. Upgrades can increase the amount of damage per tick.
**/
/datum/antagonist/mindflayer/proc/handle_harvest(mob/living/carbon/human/H)
	harvesting = H
	var/obj/item/organ/internal/brain/drained_brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(!istype(drained_brain))
		return
	var/unique_drain_id = H.UID()
	owner.current.visible_message(
		"<span class='danger'>[owner.current] puts [owner.current.p_their()] fingers on [H]'s [drained_brain.parent_organ] and begins harvesting!</span>",
		"<span class='sinister'>We begin our harvest on [H].</span>",
		"<span class='notice'>You hear the hum of electricity.</span>"
	)
	if(!do_mob(owner.current, H, time = 2 SECONDS, hidden = TRUE))
		send_swarm_message("Our connection was incomplete.")
		harvesting = null
		return
	while(do_mob(owner.current, H, time = DRAIN_TIME, progress = FALSE))
		var/check_harvest = check_valid_harvest(H)
		if(!check_harvest)
			harvesting = null
			has_notified = FALSE
			return
		H.Beam(owner.current, icon_state = "drain_life", icon ='icons/effects/effects.dmi', time = DRAIN_TIME, beam_color = COLOR_ASSEMBLY_PURPLE)
		var/damage_to_deal = (drain_amount * drain_multiplier * H.dna.species.brain_mod)
		H.adjustBrainLoss(damage_to_deal, use_brain_mod = FALSE) //No need to use brain damage modification since we already got it from the previous line

		if(check_harvest != DRAIN_BUT_NO_SWARMS)
			adjust_swarms(damage_to_deal)
			drained_humans[unique_drain_id] += damage_to_deal

		// Lasting effects. Every second of draining requires 4 seconds of healing
		drained_brain.max_damage -= 0.25 // As much damage as the default drain
		drained_brain.temporary_damage += 0.25

	send_swarm_message("Our connection severs.")
	harvesting = null
	has_notified = FALSE

/datum/antagonist/mindflayer/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/mindflayer_alert.ogg'))
	messages += "<span class='danger'>You feel something stirring within your chassis... You are a Mindflayer!</span><br>"
	messages += "To harvest someone, target where the brain of your victim is and use harm intent with an empty hand. Drain intelligence to increase your swarm."
	return messages

/**
 * Gets a list of mind flayer spell typepaths based on the passed in `spell_type`. (Thanks for the code SteelSlayer)
 *
 * Arguments:
 * * spell_type - should be a define related to [/datum/spell/flayer/power_type].
 */
/datum/antagonist/mindflayer/proc/get_spells_of_type(spell_type)
	var/list/spells = list()
	for(var/spell_path in subtypesof(/datum/spell/flayer))
		var/datum/spell/flayer/spell = spell_path
		if(initial(spell.power_type) != spell_type)
			continue
		spells += spell_path
	return spells

/**
 * Gets a list of mind flayer passive typepaths based on the passed in `passive_type`.
 *
 * Arguments:
 * * passive_type - should be a define related to [/datum/spell/flayer/passive_type].
 */
/datum/antagonist/mindflayer/proc/get_passives_of_type(passive_type)
	var/list/passives = list()
	for(var/passive_path in subtypesof(/datum/mindflayer_passive))
		var/datum/mindflayer_passive/passive = passive_path
		if(initial(passive.power_type) != passive_type)
			continue
		passives += passive_path
	return passives

///////////////////////////////////////////////////////////////
// A BUNCH OF PROCS THAT HANDLE ADDING ABILITIES AND PASSIVES
/////////////////////////////////////////////////////////////

/**
* Adds an ability to a mindflayer if they don't already have it, upgrades it if they do.
* Arguments:
* * to_add - The spell datum you want to add to the flayer
* * set_owner - The antagonist datum of the mindflayer you want to add the spell to
*/
/datum/antagonist/mindflayer/proc/add_ability(datum/spell/flayer/to_add)
	if(!to_add)
		return
	var/datum/spell/flayer/spell = has_spell(to_add)
	if(spell)
		spell.on_apply()
		qdel(to_add)
		return

	to_add.flayer = src

	to_add.level = 1
	to_add.current_cost += to_add.static_upgrade_increase
	owner.AddSpell(to_add)
	powers += to_add
	to_add.spell_purchased()

	check_special_stage_ability(to_add)
	SSblackbox.record_feedback("nested tally", "mindflayer_abilities", 1, list(to_add.name, "purchased"))

/**
* Adds a passive to a mindflayer if they don't already have it, upgrades it if they do.
* Arguments:
* * to_add - The spell datum you want to add to the flayer
* * upgrade_type - optional argument if you need to communicate a define to the passive in question
*/
/datum/antagonist/mindflayer/proc/add_passive(datum/mindflayer_passive/to_add, upgrade_type) //Passives always need to have their owners set
	if(!to_add)
		return
	var/datum/mindflayer_passive/passive = has_passive(to_add)
	if(passive)
		passive.on_apply()
		qdel(to_add)
		return

	to_add.flayer = src
	to_add.owner = owner.current // Passives always need to have their owners set here
	to_add.on_apply()
	powers += to_add

	check_special_stage_ability(to_add)
	SSblackbox.record_feedback("nested tally", "mindflayer_abilities", 1, list(to_add.name, "purchased"))

/*
 * Removing abilities/passives starts here
 */
/datum/antagonist/mindflayer/proc/remove_all_abilities()
	for(var/datum/spell/flayer/spell in powers)
		remove_ability(spell)

/datum/antagonist/mindflayer/proc/remove_all_passives()
	for(var/datum/mindflayer_passive/passive in powers)
		remove_passive(passive)

/datum/antagonist/mindflayer/proc/remove_ability(datum/spell/flayer/to_remove)
	owner.RemoveSpell(to_remove)
	powers -= to_remove

/datum/antagonist/mindflayer/proc/remove_passive(datum/mindflayer_passive/to_remove)
	powers -= to_remove
	qdel(to_remove) //qdel should call destroy, which should call on_remove

/**
* Checks if a mindflayer has a given spell already
* * Arguments: to_get - Some datum/spell/flayer to check if a mindflayer has
* * Returns: The datum/spell/mindflayer if the mindflayer has the power already, null otherwise
*/
/datum/antagonist/mindflayer/proc/has_spell(datum/spell/flayer/to_get)
	for(var/datum/spell/flayer/spell in powers)
		if(istype(spell, to_get))
			return spell

/**
* Checks if a mindflayer has a given passive already
* * Arguments: to_get - Some datum/mindflayer_passive to check if a mindflayer has
* * Returns: The datum/mindflayer_passive if the mindflayer has the passive already, null otherwise
*/
/datum/antagonist/mindflayer/proc/has_passive(datum/mindflayer_passive/to_get)
	for(var/datum/mindflayer_passive/spell in powers)
		if(to_get.name == spell.name)
			return spell

/// This is the proc that gets called every tick of life(), use this for updating something that should update every few seconds
/datum/antagonist/mindflayer/proc/handle_mindflayer()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /atom/movable/screen()
			hud.vampire_blood_display.name = "Usable Swarms"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color=[COLOR_BLUE_LIGHT]>[usable_swarms]</font></div>"

/**
* Checks if we are eligible to get a special ability for reaching the third stage in a given subclass
*/
/datum/antagonist/mindflayer/proc/check_special_stage_ability(datum/spell/flayer/adding_spell)
	if(!istype(adding_spell) || category_stage[adding_spell.category] < 3)
		return

	switch(adding_spell.category)
		if(FLAYER_CATEGORY_DESTROYER)
			if(has_spell(/datum/spell/flayer/techno_wall))
				return
			add_ability(new /datum/spell/flayer/techno_wall)
			send_swarm_message("We gain the ability to bring our internal firewalls into a crystalized form in the physical world")

		if(FLAYER_CATEGORY_INTRUDER)
			if(has_spell(/datum/spell/flayer/self/weapon/access_tuner))
				return
			add_ability(new /datum/spell/flayer/self/weapon/access_tuner)
			send_swarm_message("We gain the ability to manipulate airlocks from a distance.")
