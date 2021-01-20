// Species ban system.
// Disallows a player from using a specific species, but lets them play the game regardless
// Useful if someone isnt playing a species properly at all (IE: Not following hard-driven species lore)

/// Global list of all species bans. Key is a ckey, value is a list of species. Its a global list to avoid mass DB lookups.
GLOBAL_LIST_EMPTY(species_bans_assoc)
//GLOBAL_PROTECT(species_bans_assoc) // Mainly just to save space in the already bloated VV window

/datum/admins/proc/add_species_ban(ckey, species)
	if(!ckey || !species)
		return
	if(!GLOB.species_bans_assoc["[ckey]"]) // Incase someone has a ckey thats just all numbers
		GLOB.species_bans_assoc["[ckey]"] = list()

	GLOB.species_bans_assoc["[ckey]"] |= species // Only add once

/datum/admins/proc/remove_species_ban(ckey, species)
	if(!ckey || !species)
		return
	if(!GLOB.species_bans_assoc["[ckey]"]) // Incase someone has a ckey thats just all numbers
		GLOB.species_bans_assoc["[ckey]"] = list()

	GLOB.species_bans_assoc["[ckey]"] -= species

// Global so it can be called from world/New()
/proc/load_all_species_bans()
	var/datum/db_query/select_query = SSdbcore.NewQuery("SELECT ckey, job FROM [format_table_name("ban")] WHERE bantype='SPECIES_BAN' AND isnull(unbanned)")

	if(!select_query.warn_execute(async = FALSE)) // NOT async because its called in world/New()
		qdel(select_query)
		return FALSE

	while(select_query.NextRow())
		// Prep it all
		var/banned_ckey = select_query.item[1]
		var/banned_species = select_query.item[2]

		if(!GLOB.species_bans_assoc["[banned_ckey]"]) // Incase someone has a ckey thats just all numbers
			GLOB.species_bans_assoc["[banned_ckey]"] = list()

		GLOB.species_bans_assoc["[banned_ckey]"] |= banned_species // Incase someone gets banned twice

	qdel(select_query)

// Global so it can be used in other places (IE: Conversion to another species)
/proc/is_species_banned(ckey, species)
	ASSERT(ckey)
	ASSERT(species)
	if(!GLOB.species_bans_assoc["[ckey]"]) // If they dont have an entry in the glob, they aint banned
		return FALSE

	// Cast to local list
	var/list/species_cache = GLOB.species_bans_assoc["[ckey]"]
	if(species in species_cache)
		// If they in the list, they banned from it
		return TRUE

	// If we here, they aint banned
	return FALSE


/mob/verb/display_species_bans()
	set category = "OOC"
	set name = "Display Current Species Bans"
	set desc = "Displays all of your current species bans."

	if(!client || !ckey)
		return

	if(config.ban_legacy_system)
		to_chat(src, "The server is using the legacy ban system. Species bans are not active.")
		return

	// Dont let the client melt the server with SQL queries on a macro'd verb
	if(client.handle_db_verb_limit())
		return

	var/is_actually_banned = FALSE
	var/datum/db_query/select_query = SSdbcore.NewQuery({"
		SELECT bantime, reason, job, a_ckey FROM [format_table_name("ban")]
		WHERE ckey=:ckey AND bantype='SPECIES_BAN' AND isnull(unbanned)
		ORDER BY bantime"},
		list("ckey" = ckey)
	)

	if(!select_query.warn_execute())
		qdel(select_query)
		return FALSE

	while(select_query.NextRow())

		var/bantime = select_query.item[1]
		var/reason = select_query.item[2]
		var/species = select_query.item[3]
		var/ackey = select_query.item[4]

		to_chat(src, "<span class='warning'>[species] - REASON: [reason]<br>Applied by [ackey] at [bantime]</span>")

		is_actually_banned = TRUE

	qdel(select_query)

	if(is_actually_banned)
		if(config.banappeals)
			to_chat(src, "<span class='warning'>You can appeal the bans at: [config.banappeals]</span>")
	else
		to_chat(src, "<span class='notice'>You have no active species bans!</span>")
