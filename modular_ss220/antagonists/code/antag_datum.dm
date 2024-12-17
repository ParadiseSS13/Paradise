/datum/antagonist/proc/make_body(loc_spawn, datum/mind/mind, try_use_preference = FALSE, species_name = null, list/possible_species)
	var/datum/character_save/character
	var/mob/living/carbon/human/H = mind.current
	if(!H)
		H = new
	H.forceMove(get_turf(loc_spawn))
	var/new_name = H.real_name

	var/client/client = mind.current.client
	if(try_use_preference && client && client.prefs && length(client.prefs.character_saves))
		var/temp_species_name = species_name
		if(!temp_species_name)
			if(length(possible_species))
				temp_species_name = pick(possible_species)
			else
				temp_species_name = "Human"
		for(var/datum/character_save/temp_character in client.prefs.character_saves)
			if(temp_character.species == temp_species_name)
				character = temp_character
				species_name = temp_species_name
				new_name = random_name(character.gender, character.species)
				break

	if(!character)
		// Randomize appearance
		character = new
		if(!species_name)
			species_name = pick(get_safe_species())
		character.species = species_name
		new_name = random_name(H.gender, species_name)
		character.randomise()

	character.copy_to(H)
	H.rename_character(H.real_name, new_name)

	// species
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever ops.
	H.overeatduration = 0
	H.flavor_text = null
	H.update_body()
