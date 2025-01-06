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
	/// If having this bars you from rolling sec/command
	var/blacklisted = FALSE
	/// If this quirk needs to do something every life cycle
	var/processes = FALSE

/*
* What happens during character spawning, to actually apply the effects of the owner's selected quirks.
*/
/datum/quirk/proc/apply_quirk_effects(mob/living/quirky)
	if(!quirky)
		log_debug("[src] did not find a mob to apply its effects to.")
		return FALSE
	owner = quirky.mind
	if(processes)
		START_PROCESSING(SSprocessing, src)

/********************
    * Mob Procs *
 *********************/
/mob/proc/add_quirk_to_save(datum/quirk/to_add)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	if(to_add.organic_only && (active_character.species == "Machine"))
		to_chat(src, "<span class='warning'>You can't put that quirk on a robotic character.</span>")
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
