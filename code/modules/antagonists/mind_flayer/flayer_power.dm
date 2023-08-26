// OOORAAAH WE HAVE POWERS

/obj/effect/proc_holder/spell/flayer
	panel = "Vampire"
	school = "vampire"
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


/obj/effect/proc_holder/spell/flayer/self/create_new_targeting()
	return new /datum/spell_targeting/self

// Behold, a copypaste from changeling, might need some redoing

/obj/effect/proc_holder/spell/flayer/Destroy(force, ...)
	flayer.powers -= src
	flayer = null
	return ..()

/obj/effect/proc_holder/spell/flayer/self/augment_menu
	name = "Self-Augment Operations"
	desc = "Choose how we will upgrade ourselves."
	action_icon_state = "choose_module"
	base_cooldown = 2 SECONDS
	power_type = FLAYER_INNATE_POWER

/obj/effect/proc_holder/spell/flayer/self/augment_menu/cast(mob/user) //For now I'm just gonna make it a menu list, for testing
	//ui_interact(user)
	var/path = input(user, "whaddya wanna buy") in flayer.ability_list
	return path

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
	var/list/data = flayer.ability_list
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
