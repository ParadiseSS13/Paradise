/datum/spell/flayer
	action_background_icon_state = "bg_flayer"
	desc = "This spell needs a description!"
	human_req = TRUE
	clothes_req = FALSE
	antimagic_flags = NONE
	/// A reference to the owner mindflayer's antag datum.
	var/datum/antagonist/mindflayer/flayer

	/// What level is our spell currently at
	var/level = 0
	/// Max level of our spell
	var/max_level = 1
	/// Determines whether the power is always given to the mind flayer or if it must be purchased.
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	/// The initial cost of purchasing the spell.
	var/base_cost = 0
	/// Should this spell's cost increase by a static amount every purchase? 0 means it will stay the base cost for every upgrade.
	var/static_upgrade_increase = 0
	/// The current price to upgrade the spell
	var/current_cost = 0

	/// The class that this spell is for or FLAYER_CATEGORY_GENERAL to make it unrelated to a specific tree
	var/category = FLAYER_CATEGORY_GENERAL
	/// The current `stage` that we are on for our powers. Currently only hides powers of a higher stage.
	var/stage = 1
	/// A brief description of what the spell's upgrades do
	var/upgrade_info = "This spell needs upgrade info!"
	/// If the spell checks for a nullification implant/effect, set to FALSE to make it castable despite nullification
	var/checks_nullification = TRUE

/datum/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/flayer/Destroy(force, ...)
	if(!flayer)
		return ..()
	flayer.powers -= src
	flayer = null
	return ..()

/datum/spell/flayer/create_new_handler()
	var/datum/spell_handler/flayer/handler = new()
	handler.checks_nullification = checks_nullification
	return handler

/datum/spell_handler/flayer
	/// Do we check for nullification
	var/checks_nullification = TRUE

/datum/spell_handler/flayer/can_cast(mob/user, charge_check, show_message, datum/spell/spell)
	var/datum/antagonist/mindflayer/flayer_datum = user.mind.has_antag_datum(/datum/antagonist/mindflayer)

	if(!flayer_datum)
		return FALSE

	if(user.stat == DEAD)
		if(show_message)
			flayer_datum.send_swarm_message("We can't cast this while you are dead...")
		return FALSE

	if(checks_nullification && HAS_TRAIT(user, TRAIT_MINDFLAYER_NULLIFIED))
		if(show_message)
			flayer_datum.send_swarm_message("We do not have the energy to manifest that currently...")
		return FALSE
	return TRUE

/// The shop for purchasing and upgrading abilities, from here on the rest of the file is just handling shopping. Specific powers are in the powers subfolder.
/datum/spell/flayer/self/augment_menu
	name = "Self-Augment Operations"
	desc = "Choose how we will upgrade ourselves."
	action_icon_state = "choose_module"
	base_cooldown = 0 SECONDS
	power_type = FLAYER_INNATE_POWER
	checks_nullification = FALSE

/datum/spell/flayer/self/augment_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/spell/flayer/self/augment_menu/cast(mob/user)
	ui_interact(user)

/datum/spell/flayer/self/augment_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AugmentMenu", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/spell/flayer/self/augment_menu/ui_act(action, list/params, datum/tgui/ui)
	var/mob/user = ui.user
	if(user.stat)
		return

	switch(action)
		if("purchase")
			var/path = text2path(params["ability_path"])
			on_purchase(user, path)
			update_static_data(ui.user)

// Takes in a category name and grabs the paths of all the spells/passives specific to that category. Used for TGUI
/datum/antagonist/mindflayer/proc/get_powers_of_category(category)
	var/list/powers = list()
	for(var/path in ability_list)
		if(ispath(path, /datum/spell))
			var/datum/spell/flayer/spell = path
			if(spell.category == category)
				powers += list(list(
					"name" = spell.name,
					"desc" = spell.desc,
					"max_level" = spell.max_level,
					"cost" = spell.base_cost,
					"stage" = spell.stage,
					"ability_path" = spell.type
				))
		else
			var/datum/mindflayer_passive/passive = path
			if(passive.category == category)
				powers += list(list(
					"name" = passive.name,
					"desc" = passive.purchase_text,
					"max_level" = passive.max_level,
					"cost" = passive.base_cost,
					"stage" = passive.stage,
					"ability_path" = passive.type
				))

	return powers

/datum/antagonist/mindflayer/proc/build_ability_tabs()
	var/list/ability_tabs = list()
	for(var/category in category_stage)
		ability_tabs += list(list(
			"category_name" = category,
			"category_stage" = category_stage[category],
			"abilities" = get_powers_of_category(category)
			))
	return ability_tabs

/datum/spell/flayer/self/augment_menu/ui_data(mob/user)
	var/list/data = list()
	var/list/known_abilities = list()
	data["usable_swarms"] = flayer.usable_swarms
	for(var/datum/mindflayer_passive/passive in flayer.powers)
		known_abilities += list(list(
									"name" = passive.name,
										"current_level" = passive.level,
										"max_level" = passive.max_level,
										"cost" = passive.current_cost,
										"upgrade_text" = passive.upgrade_info,
										"ability_path" = passive.type
									))

	for(var/datum/spell/flayer/spell in flayer.powers)
		known_abilities += list(list(
									"name" = spell.name,
									"current_level" = spell.level,
									"max_level" = spell.max_level,
									"cost" = spell.current_cost,
									"upgrade_text" = spell.upgrade_info,
									"ability_path" = spell.type
								))
	data["known_abilities"] = known_abilities
	return data

/datum/spell/flayer/self/augment_menu/ui_static_data(mob/user)
	var/list/static_data = list()
	static_data["ability_tabs"] = flayer.build_ability_tabs()
	return static_data

/*
 * Given a spell, checks if a mindflayer is able to afford, and has the prerequisites for that spell.
 * If so it adds the ability and increments the category stage if needed, then returns TRUE
 * otherwise, returns FALSE
 */
/datum/antagonist/mindflayer/proc/try_purchase_spell(datum/spell/flayer/to_add)
	var/datum/spell/flayer/existing_spell = has_spell(to_add)
	if(existing_spell && (existing_spell.level >= existing_spell.max_level))
		send_swarm_message("That function is already at its strongest.")
		qdel(to_add)
		return FALSE

	if(to_add.current_cost > get_swarms())
		send_swarm_message("We need [to_add.current_cost - get_swarms()] more swarm\s for this...")
		qdel(to_add)
		return FALSE

	if(category_stage[to_add.category] < to_add.stage)
		send_swarm_message("We do not have all the knowledge needed for this.")
		qdel(to_add)
		return FALSE

	if(to_add.stage == FLAYER_CAPSTONE_STAGE)
		if(!can_pick_capstone && !existing_spell)
			send_swarm_message("We have already forsaken that knowledge.")
			qdel(to_add)
			return FALSE

		can_pick_capstone = FALSE
		send_swarm_message("We evolve to the ultimate being.")

	if(category_stage[to_add.category] == to_add.stage)
		category_stage[to_add.category] += 1

	to_add.current_cost = to_add.base_cost
	adjust_swarms(-to_add.current_cost)
	add_ability(to_add) // Level gets set to 1 when AddSpell is called later, it also handles the cost
	return TRUE // The reason we do this is cause we don't have the spell object that will get added to the mindflayer yet

/*
 * Given a passive, checks if a mindflayer is able to afford, and has the prerequisites for that spell.
 * If so it adds the ability and increments the category stage if needed, then returns TRUE
 * otherwise, returns FALSE
 */
/datum/antagonist/mindflayer/proc/try_purchase_passive(datum/mindflayer_passive/to_add)
	var/datum/mindflayer_passive/existing_passive = has_passive(to_add)
	if(existing_passive)
		if(existing_passive.level >= to_add.max_level)
			send_swarm_message("That function is already at its strongest.")
			return FALSE
		to_add.current_cost = existing_passive.current_cost

	if(to_add.current_cost > get_swarms())
		send_swarm_message("We need [to_add.current_cost - get_swarms()] more swarm\s for this...")
		return FALSE

	if(category_stage[to_add.category] < to_add.stage)
		send_swarm_message("We do not have all the knowledge needed for this...")
		return FALSE

	if(to_add.stage == FLAYER_CAPSTONE_STAGE)
		if(!can_pick_capstone && !existing_passive)
			send_swarm_message("We have already forsaken that knowledge.")
			return FALSE
		can_pick_capstone = FALSE
		send_swarm_message("We evolve to the ultimate being.")
	if(category_stage[to_add.category] == to_add.stage)
		category_stage[to_add.category] += 1

	adjust_swarms(-to_add.current_cost)
	add_passive(to_add, src)
	return TRUE

/*
 * Mindflayer code relies on on_purchase to grant powers and passives.
 * It first splits up whether the path bought was a passive or spell, then checks if the flayer can afford it.
 * Returns TRUE if an ability was added, FALSE otherwise
 */
/datum/spell/flayer/proc/on_purchase(mob/user, datum/path)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(user) || !user.mind || !flayer)
		qdel(src)
		return FALSE
	if(ispath(path, /datum/spell))
		var/datum/spell/flayer/to_add = new path(user)
		return flayer.try_purchase_spell(to_add)

	var/datum/mindflayer_passive/to_add = new path(user) //If its not a spell, it's a passive
	return flayer.try_purchase_passive(to_add)

/// This is the proc that handles spell upgrades, override this to have upgrades change duration/strength etc
/datum/spell/flayer/proc/on_apply()
	SHOULD_CALL_PARENT(TRUE)
	level++
	current_cost += static_upgrade_increase

	SSblackbox.record_feedback("nested tally", "mindflayer_abilities", 1, list(name, "upgraded", level))

/// This is a proc that is called when the ability is purchased and first added to the flayer
/datum/spell/flayer/proc/spell_purchased() // I'd call it `on_purchased` but that is already taken
	return
