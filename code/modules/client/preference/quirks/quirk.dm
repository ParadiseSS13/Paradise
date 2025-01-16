GLOBAL_LIST_EMPTY(quirk_datums)
/datum/quirk
	var/name
	var/desc = "Uh oh sisters! No description!"
	var/quirk_type = QUIRK_NEUTRAL
	var/cost = 0
	/// The mind that this quirk gets applied to
	var/datum/mind/owner
	/// If only organic characters can have it
	var/organic_only = FALSE
	/// If only IPC characters can have it
	var/machine_only = FALSE
	/// If having this bars you from rolling sec/command
	var/blacklisted = FALSE
	/// If this quirk needs to do something every life cycle
	var/processes = FALSE
	/// If this quirk applies a trait, what trait should be applied.
	var/trait_to_apply
	/// If this quirk lets the mob start with extra item
	var/item_to_give
	/// If there's text that the user needs to be shown when they're given the quirk.
	var/spawn_text

/datum/quirk/Destroy(force, ...)
	remove_quirk_effects()
	owner = null
	..()

/datum/quirk/proc/build_quirks()

/*
* The proc for actually applying a quirk to a mob, most often during spawning.
*/
/datum/quirk/proc/apply_quirk_effects(mob/living/carbon/human/quirky)
	SHOULD_CALL_PARENT(TRUE)
	if(!quirky)
		log_debug("[src] did not find a mob to apply its effects to.")
		return FALSE
	owner = quirky.mind
	if(processes)
		START_PROCESSING(SSprocessing, src)
	if(trait_to_apply)
		ADD_TRAIT(quirky, trait_to_apply, "quirk")
	if(spawn_text)
		to_chat(quirky, "<span class='notice'>[spawn_text]</span>")

/// For any behavior that needs to happen before a quirk is destroyed
/datum/quirk/proc/remove_quirk_effects()
	SHOULD_CALL_PARENT(TRUE)
	if(trait_to_apply)
		REMOVE_TRAIT(owner, trait_to_apply, "quirk")
	if(processes)
		STOP_PROCESSING(SSprocessing, src)

/// The proc run at roundstart that gives users any items that a quirk may let them spawn with.
/datum/quirk/proc/give_item(mob/living/carbon/human/quirky)
	if(!item_to_give)
		return
	var/item = new item_to_give()
	if(!isitem(item))
		return
	var/obj/item/to_give = item
	quirky.equip_or_collect(to_give, ITEM_SLOT_IN_BACKPACK) //TODO make this actually put the item in their backpack.

/********************************************************************
*   Mob Procs, mostly for many mob/new_player in the lobby screen 	*
 ********************************************************************/
/mob/proc/add_quirk_to_save(datum/quirk/to_add)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	if(to_add.organic_only && (active_character.species == "Machine"))
		to_chat(src, "<span class='warning'>You can't put that quirk on a robotic character.</span>")
		return FALSE
	if(to_add.machine_only && (active_character.species != "Machine"))
		to_chat(src, "<span class='warning'>You can't put that quirk on an organic character.</span>")
		return FALSE
	active_character.quirks += to_add
	return TRUE

/// Returns true if a quirk was removed, false otherwise
/mob/proc/remove_quirk_from_save(datum/quirk/to_remove)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	for(var/datum/quirk/quirk in active_character.quirks)
		if(quirk.name == to_remove.name)
			active_character.quirks.Remove(quirk)
			return TRUE
	return FALSE
