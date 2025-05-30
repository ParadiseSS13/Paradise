/datum/game_mode/proc/get_cult_team()
	if(!cult_team)
		new /datum/team/cult() // assignment happens in create_team()
	return cult_team

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain", "AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Nanotrasen Career Trainer", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Trans-Solar Federation General", "Research Director", "Chief Medical Officer", "Chief Engineer", "Quartermaster")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/list/pre_cult = list()

	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the offer rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(GLOB.configuration.gamemode.prevent_mindshield_antags)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)
	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!length(cultists_possible))
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		pre_cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	return length(pre_cult)

/datum/game_mode/cult/post_setup()
	new /datum/team/cult(pre_cult)
	..()

/datum/game_mode/cult/declare_completion()
	if(cult_team.cult_status == NARSIE_HAS_RISEN)
		SSticker.mode_result = "cult win - cult win"
		to_chat(world, "<span class='danger'><FONT size=3>The cult wins! It has succeeded in summoning [GET_CULT_DATA(entity_name, "their god")]!</FONT></span>")
	else if(cult_team.cult_status == NARSIE_HAS_FALLEN)
		SSticker.mode_result = "cult draw - narsie died, nobody wins"
		to_chat(world, "<span class='danger'><FONT size = 3>Nobody wins! [GET_CULT_DATA(entity_name, "the cult god")] was summoned, but banished!</FONT></span>")
	else
		SSticker.mode_result = "cult loss - staff stopped the cult"
		to_chat(world, "<span class='warning'><FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	..()
