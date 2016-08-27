//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode
	var/list/datum/mind/cult = list()
	var/list/allwords = list("travel","self","see","hell","blood","join","tech","destroy", "other", "hide")


/proc/iscultist(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.cult)


/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return 0
	if(!mind.current)
		return 0
	if(iscultist(mind.current))
		return 1 //If they're already in the cult, assume they are convertable
	if(ishuman(mind.current) && (mind.assigned_role in list("Captain", "Chaplain")))
		return 0
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(isloyal(H))
			return 0
	return 1


/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Internal Affairs Agent", "Security Officer", "Warden", "Detective", "Security Pod Pilot", "Head of Security", "Captain", "Head of Personnel", "Blueshield", "Nanotrasen Representative", "Magistrate", "Brig Physician", "Nanotrasen Navy Officer", "Special Operations Officer")
	protected_jobs = list()
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/datum/mind/sacrifice_target = null
	var/finished = 0

	var/list/startwords = list("blood","join","self","hell")

	var/list/objectives = list()

	var/eldergod = 1 //for the summon god objective

	var/acolytes_needed = 4 //for the survive objective - base number of acolytes, increased by 1 for every 10 players
	var/const/min_cultists_to_start = 3
	var/const/max_cultists_to_start = 4
	var/acolytes_survived = 0


/datum/game_mode/cult/announce()
	to_chat(world, "<B>The current game mode is - Cult!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - complete your objectives. Convert crewmembers to your cause by using the convert rune. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with the chaplain's bible reverts them to whatever CentComm-allowed faith they had.</B>")


/datum/game_mode/cult/pre_setup()
	if(prob(50))
		objectives += "survive"
		objectives += "sacrifice"
	else
		objectives += "eldergod"
		objectives += "sacrifice"

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)

	for(var/cultists_number = 1 to max_cultists_to_start)
		if(!cultists_possible.len)
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		cult += cultist
		cultist.restricted_roles = restricted_jobs
		cultist.special_role = SPECIAL_ROLE_CULTIST
	return (cult.len>0)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	acolytes_needed = acolytes_needed + round((num_players_started() / 10))
	if("sacrifice" in objectives)
		var/list/possible_targets = get_unconvertables()
		if(!possible_targets.len)
			for(var/mob/living/carbon/human/player in player_list)
				if(player.mind && !(player.mind in cult))
					possible_targets += player.mind
		if(possible_targets.len > 0)
			sacrifice_target = pick(possible_targets)

	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		grant_runeword(cult_mind.current)
		update_cult_icons_added(cult_mind)
		to_chat(cult_mind.current, "\blue You are a member of the cult!")
		memorize_cult_objectives(cult_mind)

	..()


/datum/game_mode/cult/proc/memorize_cult_objectives(var/datum/mind/cult_mind)
	for(var/obj_count = 1,obj_count <= objectives.len,obj_count++)
		var/explanation
		switch(objectives[obj_count])
			if("survive")
				explanation = "Our knowledge must live on. Make sure at least [acolytes_needed] acolytes escape on the shuttle to spread their work on an another station."
			if("sacrifice")
				if(sacrifice_target)
					explanation = "Sacrifice [sacrifice_target.current.real_name], the [sacrifice_target.assigned_role]. You will need the sacrifice rune (hell blood join) and three acolytes to do so."
				else
					explanation = "Free objective."
			if("eldergod")
				explanation = "Summon Nar-Sie via the use of the appropriate rune (Hell join self). It will only work if nine cultists stand on and around it."
		to_chat(cult_mind.current, "<B>Objective #[obj_count]</B>: [explanation]")
		cult_mind.memory += "<B>Objective #[obj_count]</B>: [explanation]<BR>"
	to_chat(cult_mind.current, "The convert rune is join blood self")
	cult_mind.memory += "The convert rune is join blood self<BR>"


/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return

	if(mob.mind)
		if(mob.mind.assigned_role == "Clown")
			to_chat(mob, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")
			mob.mutations.Remove(CLUMSY)

	add_cult_viewpoint(mob) // give them a viewpoint

	var/obj/item/weapon/paper/talisman/supply/T = new(mob)
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		to_chat(mob, "Unfortunately, you weren't able to get a talisman. This is very bad and you should adminhelp immediately.")
	else
		to_chat(mob, "You have a talisman in your [where], one that will help you start the cult on this station. Use it well and remember - there are others.")
		mob.update_icons()
		return 1


/datum/game_mode/cult/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if(!word)
		if(startwords.len > 0)
			word=pick(startwords)
			startwords -= word
	return ..(cult_mob,word)


/datum/game_mode/proc/grant_runeword(mob/living/carbon/human/cult_mob, var/word)
	if(!cultwords["travel"])
		runerandom()
	if(!word)
		word=pick(allwords)
	var/wordexp = "[cultwords[word]] is [word]..."
	to_chat(cult_mob, "\red [pick("You remember something from the dark teachings of your master","You hear a dark voice on the wind","Black blood oozes into your vision and forms into symbols","You have a vision of a [pick("crow","raven","vulture","parrot")] it squawks","You catch a brief glimmer of the otherside")]... [wordexp]")
	cult_mob.mind.store_memory("<B>You remember that</B> [wordexp]", 0, 0)


/datum/game_mode/proc/add_cult_viewpoint(var/mob/target)
	for(var/obj/cult_viewpoint/viewpoint in target)
		return
	var/obj/cult_viewpoint/viewpoint = new(target)
	viewpoint.loc = target
	return viewpoint


/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if(!istype(cult_mind))
		return 0
	if(!(cult_mind in cult) && is_convertable_to_cult(cult_mind))
		cult += cult_mind
		add_cult_viewpoint(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Has been converted to the cult!</span>"
		if(jobban_isbanned(cult_mind.current, ROLE_CULTIST))
			replace_jobbaned_player(cult_mind.current, ROLE_CULTIST)
		return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if(!..(cult_mind))
		return
	memorize_cult_objectives(cult_mind)


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		to_chat(cult_mind.current, "\red <FONT size = 3><B>An unfamiliar white light flashes through your mind, cleansing the taint of the dark-one and the memories of your time as his servant with it.</B></FONT>")
		cult_mind.memory = ""
		cult_mind.special_role = null
		// remove the cult viewpoint object
		var/obj/viewpoint = getCultViewpoint(cult_mind.current)
		qdel(viewpoint)

		update_cult_icons_removed(cult_mind)
		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				to_chat(M, "<FONT size = 3>[cult_mind.current] looks like they just reverted to their old faith!</FONT>")


/datum/game_mode/proc/add_cult_icon_to_spirit(mob/spirit/currentSpirit)
	if(!istype(currentSpirit))
		return FALSE
	if(currentSpirit.client)
		var/datum/atom_hud/antag/maskhud = huds[ANTAG_HUD_CULT]
		maskhud.join_hud(currentSpirit)
		set_antag_hud(currentSpirit,"hudcultist")


/datum/game_mode/proc/remove_cult_icon_from_spirit(mob/spirit/currentSpirit)
	if(!istype(currentSpirit))
		return FALSE
	if(currentSpirit.client)
		var/datum/atom_hud/antag/maskhud = huds[ANTAG_HUD_CULT]
		maskhud.leave_hud(currentSpirit)
		set_antag_hud(currentSpirit, null)


/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	for(var/mob/spirit/currentSpirit in spirits)
		add_cult_icon_to_spirit(currentSpirit,cult_mind)

	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "hudcultist")


/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)

	for(var/mob/spirit/currentSpirit in spirits)
		remove_cult_icon_from_spirit(currentSpirit,cult_mind)

	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)


/datum/game_mode/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs


/datum/game_mode/cult/proc/check_cult_victory()
	var/cult_fail = 0
	if(objectives.Find("survive"))
		cult_fail += check_survive() //the proc returns 1 if there are not enough cultists on the shuttle, 0 otherwise
	if(objectives.Find("eldergod"))
		cult_fail += eldergod //1 by default, 0 if the elder god has been summoned at least once
	if(objectives.Find("sacrifice"))
		if(sacrifice_target && !(sacrifice_target in sacrificed)) //if the target has been sacrificed, ignore this step. otherwise, add 1 to cult_fail
			cult_fail++

	return cult_fail //if any objectives aren't met, failure


/datum/game_mode/cult/proc/check_survive()
	acolytes_survived = 0
	for(var/datum/mind/cult_mind in cult)
		if(cult_mind.current && cult_mind.current.stat!=2)
			var/area/A = get_area(cult_mind.current )
			if( is_type_in_list(A, centcom_areas))
				acolytes_survived++
			else if(A == shuttle_master.emergency.areaInstance && shuttle_master.emergency.mode >= SHUTTLE_ESCAPE)  //snowflaked into objectives because shitty bay shuttles had areas to auto-determine this
				acolytes_survived++

	if(acolytes_survived>=acolytes_needed)
		return 0
	else
		return 1


/atom/proc/cult_log(var/message)
	investigate_log(message, "cult")


/datum/game_mode/cult/declare_completion()

	if(!check_cult_victory())
		feedback_set_details("round_end_result","win - cult win")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "\red <FONT size = 3><B> The cult wins! It has succeeded in serving its dark masters!</B></FONT>")
	else
		feedback_set_details("round_end_result","loss - staff stopped the cult")
		feedback_set("round_end_result",acolytes_survived)
		to_chat(world, "\red <FONT size = 3><B> The staff managed to stop the cult!</B></FONT>")

	var/text = "<b>Cultists escaped:</b> [acolytes_survived]"

	if(objectives.len)
		text += "<br><b>The cultists' objectives were:</b>"
		for(var/obj_count=1, obj_count <= objectives.len, obj_count++)
			var/explanation
			switch(objectives[obj_count])
				if("survive")
					if(!check_survive())
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_survive|SUCCESS|[acolytes_needed]")
					else
						explanation = "Make sure at least [acolytes_needed] acolytes escape on the shuttle. <font color='red'>Fail.</font>"
						feedback_add_details("cult_objective","cult_survive|FAIL|[acolytes_needed]")
				if("sacrifice")
					if(sacrifice_target)
						if(sacrifice_target in sacrificed)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='green'><B>Success!</B></font>"
							feedback_add_details("cult_objective","cult_sacrifice|SUCCESS")
						else if(sacrifice_target && sacrifice_target.current)
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail.</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL")
						else
							explanation = "Sacrifice [sacrifice_target.name], the [sacrifice_target.assigned_role]. <font color='red'>Fail (Gibbed).</font>"
							feedback_add_details("cult_objective","cult_sacrifice|FAIL|GIBBED")
				if("eldergod")
					if(!eldergod)
						explanation = "Summon Nar-Sie. <font color='green'><B>Success!</B></font>"
						feedback_add_details("cult_objective","cult_narsie|SUCCESS")
					else
						explanation = "Summon Nar-Sie. <font color='red'>Fail.</font>"
						feedback_add_details("cult_objective","cult_narsie|FAIL")
			text += "<br><B>Objective #[obj_count]</B>: [explanation]"

	to_chat(world, text)
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	if(cult.len || (ticker && GAMEMODE_IS_CULT))
		var/text = "<FONT size = 2><B>The cultists were:</B></FONT>"
		for(var/datum/mind/cultist in cult)

			text += "<br>[cultist.key] was [cultist.name] ("
			if(cultist.current)
				if(cultist.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(cultist.current.real_name != cultist.name)
					text += " as [cultist.current.real_name]"
			else
				text += "body destroyed"
			text += ")"

		to_chat(world, text)
