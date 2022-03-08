// This entire file makes me with DM had enums

/// Base datum for karma packages
/datum/karma_package
	/// DB ID. MUST BE UNIQUE. It should follow CATEGORY_ProductName casing. Should be a respective define in [code/__DEFINES/karma.dm]
	var/database_id = "ERROR_Unset"
	/// Friendly name to show to the user
	var/friendly_name = "Some coder was lazy"
	/// Cost of karma
	var/karma_cost = 0
	/// Is this package refundable?
	var/refundable = FALSE
	/// Category to show in under the karma store
	var/category = "UNSET"
	/// List of "Meta" packages that arent entries, just organisers
	var/list/meta_packages = list(/datum/karma_package/job, /datum/karma_package/species)

/datum/karma_package/vv_edit_var(var_name, var_value)
	return FALSE // fuck off


// If you are ever removing something from the karma store, **DO NOT** delete its definition datum.
// Just set redunable = TRUE on it so people can get their karma refund

// Jobs
/datum/karma_package/job
	category = "Karma Jobs"

/datum/karma_package/job/blueshield
	database_id = KARMAPACKAGE_JOB_BLUESHIELD
	friendly_name = "Blueshield"
	karma_cost = 30

/datum/karma_package/job/barber
	database_id = KARMAPACKAGE_JOB_BARBER
	friendly_name = "Barber"
	karma_cost = 5

/datum/karma_package/job/brigphys
	database_id = KARMAPACKAGE_JOB_BRIGPHYSICIAN
	friendly_name = "Brig Physician"
	karma_cost = 5
	refundable = TRUE

/datum/karma_package/job/ntrep
	database_id = KARMAPACKAGE_JOB_NANOTRASENREPRESENTATIVE
	friendly_name = "Nanotrasen Representative"
	karma_cost = 30

/datum/karma_package/job/secpodpilot
	database_id = KARMAPACKAGE_JOB_SECURITYPODPILOT
	friendly_name = "Security Pod Pilot"
	karma_cost = 30
	refundable = TRUE

/datum/karma_package/job/mechanic
	database_id = KARMAPACKAGE_JOB_MECHANIC
	friendly_name = "Mechanic"
	karma_cost = 30
	refundable = TRUE

/datum/karma_package/job/magistrate
	database_id = KARMAPACKAGE_JOB_MAGISTRATE
	friendly_name = "Magistrate"
	karma_cost = 45
	refundable = TRUE


// Species
/datum/karma_package/species
	category = "Karma Species"

/datum/karma_package/species/grey
	database_id = KARMAPACKAGE_SPECIES_GREY
	friendly_name = "Grey"
	karma_cost = 30

/datum/karma_package/species/kidan
	database_id = KARMAPACKAGE_SPECIES_KIDAN
	friendly_name = "Kidan"
	karma_cost = 30

/datum/karma_package/species/slimepeople
	database_id = KARMAPACKAGE_SPECIES_SLIMEPEOPLE
	friendly_name = "Slime People"
	karma_cost = 45

/datum/karma_package/species/vox
	database_id = KARMAPACKAGE_SPECIES_VOX
	friendly_name = "Vox" // pox
	karma_cost = 45

/datum/karma_package/species/drask
	database_id = KARMAPACKAGE_SPECIES_DRASK
	friendly_name = "Drask"
	karma_cost = 30

/datum/karma_package/species/machine
	database_id = KARMAPACKAGE_SPECIES_MACHINE
	friendly_name = "Machine People (IPC)"
	karma_cost = 15

/datum/karma_package/species/plasmaman
	database_id = KARMAPACKAGE_SPECIES_PLASMAMAN
	friendly_name = "Plasmaman"
	karma_cost = 45
