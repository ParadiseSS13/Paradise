/datum/game_mode/changeling/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/cult/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/revolution/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/traitor/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/trifecta/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/traitor/vampire/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/game_mode/vampire/pre_setup()
	protected_jobs |= GLOB.restricted_jobs_ss220
	. = ..()

// antag mix scenarious
/datum/antag_scenario/traitor/New()
	protected_roles |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/antag_scenario/changeling/New()
	protected_roles |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/antag_scenario/vampire/New()
	protected_roles |= GLOB.restricted_jobs_ss220
	. = ..()

/datum/antag_scenario/team/blood_brothers/New()
	protected_roles |= GLOB.restricted_jobs_ss220
	. = ..()
