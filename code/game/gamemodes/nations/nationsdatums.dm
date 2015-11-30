/datum/nations
	var/default_name
	var/current_name
	var/default_leader
	var/current_leader
	var/list/membership = list()
	var/leader_rank = "Leader"
	var/member_rank = "Member"
	var/heir

/datum/nations/atmosia
	default_name = "Atmosia"
	default_leader = "Chief Engineer"

/datum/nations/brigston
	default_name = "Brigston"
	default_leader = "Head of Security"

/datum/nations/cargonia
	default_name = "Cargonia"
	default_leader = "Quartermaster"

/datum/nations/command
	default_name = "People's Republic of Commandzakstan"
	default_leader = "Captain"

/datum/nations/medistan
	default_name = "Medistan"
	default_leader = "Chief Medical Officer"

/datum/nations/scientopia
	default_name = "Scientopia"
	default_leader = "Research Director"

/datum/nations/service
	default_name = "Servicion"
	default_leader = "Bartender"