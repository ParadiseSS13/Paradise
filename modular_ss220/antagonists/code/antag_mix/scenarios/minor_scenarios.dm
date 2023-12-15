/datum/antag_scenario/traitor
	name = "Traitor"
	config_tag = "traitor"
	abstract = FALSE
	antag_role = ROLE_TRAITOR
	antag_special_role = SPECIAL_ROLE_TRAITOR
	antag_datum = /datum/antagonist/traitor
	required_players = 10
	cost = 10
	weight = 1
	antag_cap = 1
	candidates_required = 1
	restricted_roles = list("Cyborg")
	protected_roles = list(
		"Security Cadet",
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Captain",
		"Blueshield",
		"Nanotrasen Representative",
		"Magistrate",
		"Internal Affairs Agent",
		"Nanotrasen Navy Officer",
		"Special Operations Officer",
		"Syndicate Officer",
		"Solar Federation General")

/datum/antag_scenario/changeling
	name = "Changeling"
	config_tag = "changeling"
	abstract = FALSE
	antag_role = ROLE_CHANGELING
	antag_special_role = SPECIAL_ROLE_CHANGELING
	antag_datum = /datum/antagonist/changeling
	required_players = 10
	cost = 10
	weight = 1
	antag_cap = 1
	candidates_required = 1
	restricted_roles = list("Cyborg", "AI")
	protected_roles = list(
		"Security Cadet",
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Captain",
		"Blueshield",
		"Nanotrasen Representative",
		"Magistrate",
		"Internal Affairs Agent",
		"Nanotrasen Navy Officer",
		"Special Operations Officer",
		"Syndicate Officer",
		"Solar Federation General")
	restricted_species = list("Machine")

/datum/antag_scenario/vampire
	name = "Vampire"
	config_tag = "vampire"
	abstract = FALSE
	antag_role = ROLE_VAMPIRE
	antag_special_role = SPECIAL_ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	required_players = 10
	cost = 10
	weight = 1
	antag_cap = 1
	candidates_required = 1
	restricted_roles = list("Cyborg", "AI", "Chaplain")
	protected_roles = list(
		"Security Cadet",
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Captain",
		"Blueshield",
		"Nanotrasen Representative",
		"Magistrate",
		"Internal Affairs Agent",
		"Nanotrasen Navy Officer",
		"Special Operations Officer",
		"Syndicate Officer",
		"Solar Federation General")
	restricted_species = list("Machine")

/datum/antag_scenario/team/blood_brothers
	name = "Blood Brothers"
	config_tag = "blood_brothers"
	abstract = FALSE
	antag_role = ROLE_BLOOD_BROTHER
	antag_special_role = SPECIAL_ROLE_BLOOD_BROTHER
	antag_datum = /datum/antagonist/blood_brother
	antag_team = /datum/team/blood_brothers_team
	required_players = 20
	cost = 20
	weight = 1
	antag_cap = 2
	candidates_required = 2
	team_size = 2
	restricted_roles = list("Cyborg", "AI")
	protected_roles = list(
		"Security Cadet",
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Captain",
		"Blueshield",
		"Nanotrasen Representative",
		"Magistrate",
		"Internal Affairs Agent",
		"Nanotrasen Navy Officer",
		"Special Operations Officer",
		"Syndicate Officer",
		"Solar Federation General")
