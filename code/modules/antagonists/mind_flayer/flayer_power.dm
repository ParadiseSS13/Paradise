//POWERS// OOORAAAH WE HAVE POWERS
#define POWER_LEVEL_ZERO	0 // Only used for mobs to check what powers they should have // TODO: figure out wtf I meant with this comment // Okay so I think I meant this as a define to use in comparison with something, to check if it's bought or not?
#define POWER_LEVEL_ONE		1
#define POWER_LEVEL_TWO		2
#define POWER_LEVEL_THREE	3
#define POWER_LEVEL_FOUR	4

// These defines are used
#define RANGED_ATTACK_BASE "base ranged attack"
#define MELEE_ATTACK_BASE "base melee attack"

/datum/spell/flayer
//	panel = "Vampire"
//	school = "vampire"
	action_background_icon_state = "bg_vampire" // TODO: flayer background
	human_req = TRUE
	clothes_req = FALSE
	/// A reference to the owner mindflayer's antag datum.
	var/datum/antagonist/mindflayer/flayer
	var/level = 0
	var/max_level = 1
	/// Determines whether the power is always given to the mind flayer or if it must be purchased.
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	/// The cost of purchasing the power.
	var/current_cost = 0
	/// What `stat` value the mind flayer needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS
	/// The class that this spell is for or CATEGORY_GENERAL to make it unrelated to a specific tree
	var/category = CATEGORY_GENERAL
	/// The current `stage` that we are on for our powers. Currently only hides powers of a higher stage. TODO: IMPLEMENT CORRECTLY WHEN TGUI IS ROLLING
	var/stage = 1

/datum/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self

// Behold, a copypaste from changeling, might need some redoing

/datum/spell/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

///The shop for purchasing and upgrading abilities, from here on the rest of the file is just handling shopping. Specific powers are in the powers subfolder.
/datum/spell/flayer/self/augment_menu
	name = "Self-Augment Operations"
	desc = "Choose how we will upgrade ourselves."
	action_icon_state = "choose_module"
	base_cooldown = 2 SECONDS
	power_type = FLAYER_INNATE_POWER

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
	if(..())
		return
	var/mob/user = ui.user
	if(user.stat)
		return

	switch(action)
		if("purchase")
			var/path = text2path(params["ability_path"])
			on_purchase(user, path)

/datum/spell/flayer/self/augment_menu/ui_data(mob/user)
	var/list/list/data = list()
	var/list/known_abilities = list()
	data["usable_swarms"] = flayer.usable_swarms
//	for(var/datum/mindflayer_passive/passive in flayer.powers)
//		known_abilities += list(list(
//			"name" = passive.name,
//			"current_level" = passive.level
//		))
//	for(var/datum/spell/flayer/spell in flayer.powers)
//		known_abilities += list(list(
//			"name" = spell.name,
//			"current_level" = spell.level
//		))
//	data["known_abilities"] = known_abilities
	return data

/datum/spell/flayer/self/augment_menu/ui_static_data(mob/user)
	var/list/list/static_data = list()
	var/list/abilities = list()
	for(var/path in flayer.ability_list)
		if(flayer.is_path_spell(path))
			var/datum/spell/flayer/spell = path
			abilities += list(list(
				"name" = spell.name,
				"desc" = spell.desc,
				"cost" = spell.current_cost,
				"stage" = spell.stage,
				"category" = spell.category,
				"max_level" = spell.max_level,
				"ability_path" = spell.type))
		else
			var/datum/mindflayer_passive/passive = path
			abilities += list(list(
				"name" = passive.name,
				"desc" = passive.purchase_text,
				"cost" = passive.current_cost,
				"stage" = passive.stage,
				"category" = passive.category,
				"ability_path" = passive.type))
	static_data["abilities"] = abilities
	return static_data
/*
* Given a path, return TRUE if the path is a mindflayer spell, or FALSE otherwise. Only used to sort passives from spells.
*/
/datum/antagonist/mindflayer/proc/is_path_spell(path)
	var/spell = new path() //No need to give it an owner since we're just checking the type
	return isspell(spell)


/*Given a spell, checks if a mindflayer is able to afford, and has the prerequisites for that spell.
* If so it adds the ability and increments the category stage if needed, then returns TRUE
* otherwise, returns FALSE
*/

/datum/antagonist/mindflayer/proc/try_purchase_spell(datum/spell/flayer/to_add)
	var/datum/spell/flayer/existing_spell = has_spell(to_add)
	if(existing_spell)
		if(existing_spell.level >= to_add.max_level)
			send_swarm_message("That function is already at it's strongest.")
			return FALSE
		to_add.current_cost = existing_spell.current_cost
	if(category_stage[to_add.category] < to_add.stage)
		send_swarm_message("We do not have all the knowledge needed for this...")
		return FALSE
	else if (category_stage[to_add.category] == to_add.stage)
		category_stage[to_add.category] += 1
	if(to_add.current_cost > get_swarms())
		send_swarm_message("We need more sustenance for this...")
		return FALSE
	adjust_swarms(-to_add.current_cost)
	add_ability(to_add, src)
	return TRUE

/*Given a passive, checks if a mindflayer is able to afford, and has the prerequisites for that spell.
* If so it adds the ability and increments the category stage if needed, then returns TRUE
* otherwise, returns FALSE
*/
/datum/antagonist/mindflayer/proc/try_purchase_passive(datum/mindflayer_passive/to_add)
	var/datum/mindflayer_passive/existing_passive = has_passive(to_add)
	if(existing_passive)
		if(existing_passive.level >= to_add.max_level)
			send_swarm_message("That function is already at it's strongest.")
			return FALSE
		to_add.current_cost = existing_passive.current_cost
	if(category_stage[to_add.category] < to_add.stage)
		send_swarm_message("We do not have all the knowledge needed for this...")
		return FALSE
	else if (category_stage[to_add.category] == to_add.stage)
		category_stage[to_add.category] += 1
	if(to_add.current_cost > get_swarms())
		send_swarm_message("We need more sustenance for this...")
		return FALSE
	adjust_swarms(-to_add.current_cost)
	add_passive(to_add, src)
	return TRUE
/*
 * Mindflayer code relies on on_purchase to grant powers and passives. It first splits up whether the path bought was a passive or spell, then checks if the flayer can afford it.
 * Returns TRUE if an ability was added, FALSE otherwise
 */

/datum/spell/flayer/proc/on_purchase(mob/user, datum/path)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !flayer)
		qdel(src)
		return FALSE
	if(flayer.is_path_spell(path))
		var/datum/spell/flayer/to_add = new path(user)
		return flayer.try_purchase_spell(to_add)
	var/datum/mindflayer_passive/to_add = new path(user) //If its not a spell, it's a passive
	return flayer.try_purchase_passive(to_add)
