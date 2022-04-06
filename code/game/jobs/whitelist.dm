/proc/is_job_whitelisted(mob/M, rank)
	if(!check_job_karma(rank)) // If it aint a karma job, let them play
		return TRUE
	if(!GLOB.configuration.general.enable_karma)
		return TRUE
	if(check_rights(R_ADMIN, FALSE, M))
		return TRUE

	var/package_id = job2package(rank)
	if(!package_id) // Not a valid karma package
		return TRUE
	if(M.client.karmaholder.hasPackage(package_id)) // They have it
		return TRUE

	return FALSE

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

/proc/job2package(job_id)
	switch(job_id)
		if("Blueshield")
			return KARMAPACKAGE_JOB_BLUESHIELD
		if("Barber")
			return KARMAPACKAGE_JOB_BARBER
		if("Nanotrasen Representative")
			return KARMAPACKAGE_JOB_NANOTRASENREPRESENTATIVE
