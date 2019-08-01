var/global/list/all_cults = list()

/datum/game_mode
	var/list/datum/mind/cult = list()

/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind.has_antag_datum(/datum/antagonist/cult, TRUE)


/proc/is_convertable_to_cult(mob/living/M, datum/team/cult/specific_cult)
	if(!istype(M))
		return 0
	if(M.mind)
		if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
			return 0
		if(specific_cult && specific_cult.is_sacrifice_target(M.mind))
			return 0
		if(iscultist(M))
			return 0
	else
		return 0
	if(ismindshielded(M) || issilicon(M) || isbot(M))
		return 0 //can't convert machines, shielded
	return 1

/datum/team/cult/proc/is_sacrifice_target(datum/mind/mind)
	for(var/datum/objective/sacrifice/sac_objective in objectives)
		if(mind == sac_objective.target)
			return TRUE
	return FALSE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Security Pod Pilot", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Brig Physician", "Nanotrasen Navy Officer", "Special Operations Officer", "Syndicate Officer")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4
	free_golems_disabled = TRUE
	var/acolytes_survived = 0	
	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/datum/team/cult/main_cult

/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentComm-allowed faith they had.</B>")

/datum/game_mode/cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs
	..()
	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist
		cultist.special_role = SPECIAL_ROLE_CULTIST
		cultist.restricted_roles = restricted_jobs
	..()
	return (cult.len>0)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	for(var/datum/mind/cult_mind in cult)
		add_cultist(cult_mind, TRUE)
		if(!main_cult)
			var/datum/antagonist/cult/C = cult_mind.has_antag_datum(/datum/antagonist/cult,TRUE)
			if(C && C.cult_team)
				main_cult = C.cult_team
	..()

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind, equip = FALSE) //BASE
	if(!istype(cult_mind))
		return 0
	var/datum/antagonist/cult/C = new()
	C.talisman = equip
	if(cult_mind.add_antag_datum(C))
		return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind)
		var/datum/antagonist/cult/cult_datum = cult_mind.has_antag_datum(/datum/antagonist/cult, TRUE)
		if(!cult_datum)
			return FALSE
		cult_mind.remove_antag_datum(/datum/antagonist/cult)


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "hudcultist")


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/antagonist/cult/H in GLOB.antagonists)
		if(H.owner.current && H.owner.current.stat != DEAD)
			var/area/A = get_area(H.owner.current)
			if(is_type_in_list(A, centcom_areas))
				acolytes_survived++
			else if(A == SSshuttle.emergency.areaInstance && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)  //snowflaked into objectives because shitty bay shuttles had areas to auto-determine this
				acolytes_survived++


/atom/proc/cult_log(var/message)
	investigate_log(message, "cult")

/datum/game_mode/cult/proc/check_cult_victory()
	return main_cult.check_cult_victory()

/datum/game_mode/cult/declare_completion()
	check_survive()
	if(!check_cult_victory())
		feedback_set_details("round_end_result","cult win - cult win")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "<span class='danger'> <FONT size = 3> The cult wins! It has succeeded in serving its dark masters!</FONT></span>")
	else
		feedback_set_details("round_end_result","cult loss - staff stopped the cult")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "<span class='warning'> <FONT size = 3>The staff managed to stop the cult!</FONT></span>")

	var/parts = "<b>Cultists escaped:</b> [acolytes_survived]"

	if(main_cult.objectives.len)
		parts += "<b>The cultists' objectives were:</b>"
		var/count = 1
		for(var/datum/objective/objective in main_cult.objectives)
			if(objective.check_completion())
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				parts += "<b>Objective #[count]</b>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
			count++


	to_chat(world, parts)
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	if(cult.len || (SSticker && GAMEMODE_IS_CULT))
		var/text = "<br><FONT size = 2><B>The cultists were:</B></FONT>"
		for(var/datum/mind/cultist in cult)
			text += printplayer(cultist)
			text += "<br>"

		text += "<br>"
		to_chat(world, text)
