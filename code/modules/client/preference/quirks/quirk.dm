GLOBAL_LIST_EMPTY(quirk_paths)
/datum/quirk
	/// Name of the quirk. It's important that the basetypes don't have a name, and that any quirks you want people to see to have one.
	var/name
	/// The (somewhat) IC explanation of what this quirk does, to be shown in the TGUI menu.
	var/desc = "Uh oh sisters! No description!"
	/// A positive or negative number, good quirks should be 1 to 4, bad quirks should be -1 to -4
	var/cost = 0
	/// The mob that this quirk gets applied to.
	var/mob/living/carbon/human/owner
	/// If IPCs and/or organic people can use it
	var/species_flags
	/// If having this bars you from rolling sec/command
	var/blacklisted = FALSE
	/// If this quirk needs to do something every life cycle
	var/processes = FALSE
	/// If this quirk applies a trait, what trait should be applied.
	var/trait_to_apply
	/// If this quirk lets the mob spawn with an item
	var/item_to_give
	/// If there's an item to give, what slot should it be equipped to roundstart?
	var/item_slot = ITEM_SLOT_IN_BACKPACK
	/// The path of the organ the quirk should give.
	var/organ_to_give
	/// What organ should be removed (if any). Must be the string name of the organ as found in the has_organ var from the species datum.
	var/organ_slot_to_remove
	/// If the quirk should spawn a mob with the player.
	var/mob_to_spawn

/datum/quirk/Destroy(force, ...)
	remove_quirk_effects()
	owner.quirks.Remove(src)
	owner = null
	return ..()

/* For any quirk that processes, you'll want to have
*
* if(!..())
*	return

* At the beginning to prevent it from firing on dead people
*/
/datum/quirk/process()
	if(owner.stat == DEAD)
		return FALSE
	return TRUE

/*
* The proc for actually applying a quirk to a mob, most often during spawning.
*/
/datum/quirk/proc/apply_quirk_effects(mob/living/carbon/human/quirky)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(quirky))
		log_debug("[src] did not find a mob to apply its effects to.")
		return FALSE
	owner = quirky
	owner.quirks += src
	if(processes)
		START_PROCESSING(SSobj, src)
	if(trait_to_apply)
		ADD_TRAIT(owner, trait_to_apply, "quirk")
	if(organ_slot_to_remove)
		RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(remove_organ))
	if(organ_to_give)
		RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(give_organ))
	if(mob_to_spawn)
		RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(spawn_mob))
	owner.update_sight()

/datum/quirk/proc/remove_organ(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER //COMSIG_GLOB_JOB_AFTER_SPAWN
	if(spawned != owner)
		return
	var/obj/item/organ/to_remove = owner.get_organ_slot(organ_slot_to_remove)
	INVOKE_ASYNC(to_remove, TYPE_PROC_REF(/obj/item/organ/internal, remove), owner, TRUE)

/datum/quirk/proc/give_organ(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER //COMSIG_GLOB_JOB_AFTER_SPAWN
	if(spawned != owner)
		return
	var/obj/item/organ/internal/cybernetic = new organ_to_give
	INVOKE_ASYNC(cybernetic, TYPE_PROC_REF(/obj/item/organ/internal, insert), owner, TRUE)

/datum/quirk/proc/spawn_mob(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER //COMSIG_GLOB_JOB_AFTER_SPAWN
	if(spawned != owner)
		return
	new mob_to_spawn(owner.loc)

/// For any behavior that needs to happen before a quirk is destroyed
/datum/quirk/proc/remove_quirk_effects()
	SHOULD_CALL_PARENT(TRUE)
	if(trait_to_apply)
		REMOVE_TRAIT(owner, trait_to_apply, "quirk")
	if(processes)
		STOP_PROCESSING(SSprocessing, src)
	owner.update_sight()

/********************************************************************
*   Mob Procs, mostly for many mob/new_player in the lobby screen 	*
 ********************************************************************/
/mob/proc/add_quirk_to_save(datum/quirk/to_add)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	if((to_add.species_flags & QUIRK_MACHINE_INCOMPATIBLE) && (active_character.species == "Machine"))
		to_chat(src.client, SPAN_WARNING("You can't put that quirk on a robotic character."))
		return FALSE
	if((to_add.species_flags & QUIRK_ORGANIC_INCOMPATIBLE) && (active_character.species != "Machine"))
		to_chat(src.client, SPAN_WARNING("You can't put that quirk on an organic character."))
		return FALSE
	if((to_add.species_flags & QUIRK_SLIME_INCOMPATIBLE) && (active_character.species == "Slime People")) //Since they don't have eyes
		to_chat(src.client, SPAN_WARNING("You can't put that quirk on a slime character, you have no eyes!"))
		return FALSE
	if((to_add.species_flags & QUIRK_PLASMAMAN_INCOMPATIBLE) && (active_character.species == "Plasmaman")) //If someone can figure out how to only let plasmaman with a secondary language take this feel free to do that
		to_chat(src.client, SPAN_WARNING("You can't put that quirk on a plasmaman, you have no species language!"))
		return FALSE
	active_character.quirks += to_add
	return TRUE

/// Returns true if a quirk was removed, false otherwise
/mob/proc/remove_quirk_from_save(datum/quirk/to_remove)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	for(var/datum/quirk/quirk as anything in active_character.quirks)
		if(quirk.name == to_remove.name)
			active_character.quirks.Remove(quirk)
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/clear_quirks()
	for(var/datum/quirk/quirk in quirks)
		qdel(quirk)
