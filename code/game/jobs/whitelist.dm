/proc/can_use_species(mob/M, species)
	if(!GLOB.configuration.general.enable_karma)
		return TRUE
	if(species == "human" || species == "Human")
		return TRUE
	if(check_rights(R_ADMIN, FALSE))
		return TRUE

	// Cant be using this if youre not an admin
	var/datum/species/S = GLOB.all_species[species]
	if(S.blacklisted)
		return FALSE

	var/package_id = species2package(species)
	if(!package_id)
		return TRUE // Not a valid karma package
	if(M.client.karmaholder.hasPackage(package_id)) // They have it
		return TRUE

	return FALSE

/proc/species2package(species_id)
	switch(species_id)
		if("Grey")
			return KARMAPACKAGE_SPECIES_GREY
		if("Kidan")
			return KARMAPACKAGE_SPECIES_KIDAN
		if("Slime People")
			return KARMAPACKAGE_SPECIES_SLIMEPEOPLE
		if("Vox")
			return KARMAPACKAGE_SPECIES_VOX
		if("Drask")
			return KARMAPACKAGE_SPECIES_DRASK
		if("Machine")
			return KARMAPACKAGE_SPECIES_MACHINE
		if("Plasmaman")
			return KARMAPACKAGE_SPECIES_PLASMAMAN
