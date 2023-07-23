/datum/client_login_processor/load_characters
	priority = 20

/datum/client_login_processor/load_characters/get_query(client/C)
	// Get all their characters
	var/datum/db_query/query = SSdbcore.NewQuery({"SELECT
		OOC_Notes,
		real_name,
		name_is_always_random,
		gender,
		age,
		species,
		language,
		hair_colour,
		secondary_hair_colour,
		facial_hair_colour,
		secondary_facial_hair_colour,
		skin_tone,
		skin_colour,
		marking_colours,
		head_accessory_colour,
		hair_style_name,
		facial_style_name,
		marking_styles,
		head_accessory_style_name,
		alt_head_name,
		eye_colour,
		underwear,
		undershirt,
		backbag,
		b_type,
		alternate_option,
		job_support_high,
		job_support_med,
		job_support_low,
		job_medsci_high,
		job_medsci_med,
		job_medsci_low,
		job_engsec_high,
		job_engsec_med,
		job_engsec_low,
		flavor_text,
		med_record,
		sec_record,
		gen_record,
		disabilities,
		player_alt_titles,
		organ_data,
		rlimb_data,
		nanotrasen_relation,
		speciesprefs,
		socks,
		body_accessory,
		gear,
		autohiss,
		slot,
		hair_gradient,
		hair_gradient_offset,
		hair_gradient_colour,
		hair_gradient_alpha,
		custom_emotes,
		tts_seed
		FROM characters WHERE ckey=:ckey"}, list(
			"ckey" = C.ckey
		))

	return query

/datum/client_login_processor/load_characters/process_result(datum/db_query/Q, client/C)
	// If we already loaded their characters, dont do it all again
	if(C.prefs.characters_loaded)
		return
	// Step one, initialize their list of characters
	C.prefs.character_saves = list()
	C.prefs.character_saves.len = C.prefs.max_save_slots // Fill the list with empty indexes
	// Fill it with blank characters first
	for(var/i in 1 to C.prefs.max_save_slots)
		var/datum/character_save/CS = new
		CS.slot_number = i
		C.prefs.character_saves[i] = CS

	// Did we load at all
	var/character_loaded = FALSE

	while(Q.NextRow())
		character_loaded = TRUE
		var/datum/character_save/CS = C.prefs.character_saves[Q.item[50]] // Get the slot referenced by this query
		CS.load(Q) // Let the save handle the query processing
		CS.valid_save = TRUE

	if(character_loaded)
		// They have a character, set their active as their default slot
		C.prefs.active_character = C.prefs.character_saves[C.prefs.default_slot]
		C.prefs.active_character.init_custom_emotes(C.prefs.active_character.custom_emotes)
	else
		// If we are here, they dont have a character. Lets make them a random one
		var/datum/character_save/CS = C.prefs.character_saves[1] // Get slot 1
		CS.randomise()
		CS.real_name = random_name(CS.gender) // Pick a name
		CS.valid_save = TRUE
		CS.save(C)
		C.prefs.active_character = C.prefs.character_saves[1] // Set slot 1 as their active
		C.prefs.default_slot = 1
		C.prefs.save_preferences(C)

	C.prefs.characters_loaded = TRUE // Avoid this happening again
