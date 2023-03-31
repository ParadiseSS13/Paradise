// This needs moving somewhere more sensible
// Code reviewers I choose you to help me
// If this PR gets merged with this comment in you're all fired
// -aa07
/proc/can_use_species(mob/M, species)
	// Always if human
	if(species == "human" || species == "Human")
		return TRUE

	var/datum/species/S = GLOB.all_species[species]
	// Part of me feels like the below checks could be merged but ehh

	// No if species is not selectable
	if(NOT_SELECTABLE in S.species_traits)
		return FALSE

	// Yes if admin
	if(check_rights(R_ADMIN, FALSE))
		return TRUE

	// No if species is blacklisted
	if(S.blacklisted)
		return FALSE

	return TRUE
