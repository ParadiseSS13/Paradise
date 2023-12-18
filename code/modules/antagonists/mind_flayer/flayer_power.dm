// OOORAAAH WE HAVE POWERS
#define POWER_LEVEL_ZERO	0 // Only used for mobs to check what powers they should have // TODO: figure out wtf I meant with this comment // Okay so I think I meant this as a define to use in comparison with something, to check if it's bought or not?
#define POWER_LEVEL_ONE		1
#define POWER_LEVEL_TWO		2
#define POWER_LEVEL_THREE	3
#define POWER_LEVEL_FOUR	4

// These defines are used
#define RANGED_ATTACK_BASE "base ranged attack"
#define MELEE_ATTACK_BASE "base melee attack"

/obj/effect/proc_holder/spell/flayer
//	panel = "Vampire"
//	school = "vampire"
	action_background_icon_state = "bg_vampire" // TODO: flayer background
	human_req = TRUE
	clothes_req = FALSE
	/// A reference to the mind flayer's antag datum.
	var/datum/antagonist/mindflayer/flayer
	/// Determines whether the power is always given to the mind flayer or if it must be purchased.
	var/power_type = FLAYER_UNOBTAINABLE_POWER
	/// The cost of purchasing the power.
	var/swarm_cost = 0
	/// What `stat` value the mind flayer needs to have to use this power. Will be CONSCIOUS, UNCONSCIOUS or DEAD.
	var/req_stat = CONSCIOUS
	/// If it's only unlocked after buying a different ability, or abilities. Should be a list of ability paths required for purchase.
	var/list/prerequisite = list()
	/// The class that this spell is for or CATEGORY_GENERAL to make it unrelated to a specific tree
	var/category = CATEGORY_GENERAL
	/// The current `stage` that we are on for our powers. Currently only hides powers of a higher stage. TODO: IMPLEMENT CORRECTLY WHEN TGUI IS ROLLING
	var/stage = 1

/obj/effect/proc_holder/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self

// Behold, a copypaste from changeling, might need some redoing

/obj/effect/proc_holder/spell/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

///The shop for purchasing and upgrading abilities
/obj/effect/proc_holder/spell/flayer/self/augment_menu
	name = "Self-Augment Operations"
	desc = "Choose how we will upgrade ourselves."
	action_icon_state = "choose_module"
	base_cooldown = 2 SECONDS
	power_type = FLAYER_INNATE_POWER

/obj/effect/proc_holder/spell/flayer/self/augment_menu/cast(mob/user) //For now I'm just gonna make it a menu list, for testing
	//ui_interact(user)
	var/list/categories = list(CATEGORY_GENERAL, CATEGORY_DESTROYER, CATEGORY_INTRUDER, CATEGORY_SWARMER)
	var/power_category = tgui_input_list(user, "What category do you want to buy from", "Choose category", categories)
	offer_power_choices(user, power_category)

/obj/effect/proc_holder/spell/flayer/self/augment_menu/proc/offer_power_choices(mob/user, power_category)
	var/list/possible_powers = list()
	var/list/all_powers = flayer.ability_list.Copy()
	for(var/i in 1 to length(all_powers))
		var/obj/effect/proc_holder/spell/flayer/spell = all_powers[i]
		if(spell.category != power_category)
			continue
		if(spell.stage > flayer.category_stage[power_category])
			continue
		possible_powers += spell
	get_ability(user, possible_powers, power_category)

/obj/effect/proc_holder/spell/flayer/self/augment_menu/proc/get_ability(mob/user, list/all_powers = list(), power_category)
	if(!length(all_powers))
		flayer.send_swarm_message("Either you bought all the powers, or something went terribly wrong. Contact a coder or admin if you should have powers to buy.")
		return
	var/path = tgui_input_list(user, "whaddya wanna buy", "Buy power", all_powers)
	flayer.add_ability(path)
	flayer.send_swarm_message("nice one dude")

/* This is all the TGUI stuff that will need to be fleshed out once I figure out all the stuff I need to get the data working

/obj/effect/proc_holder/spell/flayer/self/augment_menu/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	if(..())
		return

/obj/effect/proc_holder/spell/flayer/self/augment_menu/ui_data(mob/user)
	var/datum/antagonist/mindflayer/MF = user.has_antag_datum(/datum/antagonist/mindflayer)
	var/list/data = list(
		"usable_swarms" = MF.usable_swarms,
		"purchased_abilities" = MF.powers)
	return data

/obj/effect/proc_holder/spell/flayer/self/augment_menu/ui_static_data(mob/user)
	var/list/data = flayer.purchasable_abilities
	return data
*/

/*
 * Mindflayer code relies on on_purchase to grant powers.
 * The same goes for Remove(). if you override Remove(), call parent or else your power wont be removed on respec TODO: make Remove()
 */

/obj/effect/proc_holder/spell/flayer/proc/on_purchase(mob/user, datum/antagonist/mindflayer/C, datum/path)
	SHOULD_CALL_PARENT(TRUE)
	if(!user || !user.mind || !C)
		qdel(src)
		return
	flayer = C
	flayer.add_ability(path)
	return TRUE
