/datum/game_mode
	/// A list of all minds currently in the cult
	// var/list/datum/mind/cult = list()

	var/datum/team/cult/cult_team

/datum/game_mode/proc/get_cult_team()
	return cult_team || new /datum/team/cult()

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain", "AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer", "Solar Federation General")
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
	for(var/datum/mind/cult_mind in pre_cult)
		cult_team.equip_cultist(cult_mind.current) // cTODO, use get_cult
	..()


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind)
	if(!istype(cult_mind) || cult_mind.has_antag_datum(/datum/antagonist/cultist))
		return FALSE

	cult_mind.add_antag_datum(/datum/antagonist/cultist)
	return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = TRUE, remove_gear = FALSE, mob/target_mob)
	// if(target_mob)
	// 	cult -= target_mob // ctodo, figure out how to do this better
	if(!cult_mind.has_antag_datum(/datum/antagonist/cultist)) // Not actually a cultist in the first place
		return

	var/mob/cultist = target_mob
	if(!cultist)
		cultist = cult_mind.current
	cult_team.remove_member(cult_mind)

	if(show_message)
		cultist.visible_message("<span class='cult'>[cultist] looks like [cultist.p_they()] just reverted to [cultist.p_their()] old faith!</span>",
		"<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of [GET_CULT_DATA(entity_title1, "Nar'Sie")] and the memories of your time as their servant with it.</span>")

/datum/game_mode/cult/declare_completion()
	if(cult_team.sacrifices_required == NARSIE_HAS_RISEN)
		SSticker.mode_result = "cult win - cult win"
		to_chat(world, "<span class='danger'> <FONT size = 3>The cult wins! It has succeeded in summoning [GET_CULT_DATA(entity_name, "their god")]!</FONT></span>")
	else if(cult_team.sacrifices_required == NARSIE_HAS_FALLEN)
		SSticker.mode_result = "cult draw - narsie died, nobody wins"
		to_chat(world, "<span class='danger'> <FONT size = 3>Nobody wins! [GET_CULT_DATA(entity_name, "the cult god")] was summoned, but banished!</FONT></span>")
	else
		SSticker.mode_result = "cult loss - staff stopped the cult"
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	..()
