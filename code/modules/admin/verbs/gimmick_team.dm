// Gimmick Team
// Spawns a group of player-controlled mobs with an outfit specified by the admin, at their location.

/client/proc/gimmick_team()
	set category = "Event"
	set name = "Send Gimmick Team"
	set desc = "Spawns a group of players in the specified outfit."
	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		alert("The game hasn't started yet!")
		return

	if(alert("Do you want to spawn a Gimmick Team at YOUR CURRENT LOCATION?",,"Yes","No")=="No")
		return
	var/turf/T = get_turf(mob)

	var/pick_manually = 0
	if(alert("Pick the team members manually? If you select yes, you pick from ghosts. If you select no, ghosts get offered the chance to join.",,"Yes","No")=="Yes")
		pick_manually = 1

	var/force_species = FALSE
	var/selected_species = null
	if(alert("Do you want to enforce a specific species of the team? No - defaults to human.",,"Yes","No")=="Yes")
		force_species = TRUE
		selected_species = input("Select a species", "Species Selection",null) as null|anything in GLOB.all_species
		if(!selected_species)
			alert("Spawning stopped.")
			return	// You didn't pick, abort

	var/list/teamsizeoptions = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/teamsize = input(src, "How many team members?") as null|anything in teamsizeoptions
	if(!(teamsize in teamsizeoptions))
		alert("Invalid team size specified. Aborting.")
		return

	var/team_name = null
	while(!team_name)
		team_name = sanitize(copytext_char(input(src, "Please specify a name for the team. Defaults to \"Gimmick Team\".", "Specify Name", ""),1,MAX_MESSAGE_LEN))
		if(!team_name)
			team_name = "Gimmick Team"

	var/themission = null
	while(!themission)
		themission = sanitize(copytext_char(input(src, "Please specify a briefing message for the team.", "Specify Mission", ""),1,MAX_MESSAGE_LEN))
		if(!themission)
			alert("No mission specified. Aborting.")
			return

	var/dresscode = robust_dress_shop()
	if(!dresscode)
		return

	var/is_syndicate = 0
	if(alert("Do you want these characters automatically classified as antagonists?",,"Yes","No")=="Yes")
		is_syndicate = 1

	var/list/players_to_spawn = list()
	if(pick_manually)
		var/list/possible_ghosts = list()
		for(var/mob/dead/observer/G in GLOB.player_list)
			if(!G.client.is_afk())
				if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
					possible_ghosts += G
		for(var/i=teamsize,(i>0&&possible_ghosts.len),i--) //Decrease with every member selected.
			var/candidate = input("Pick characters to spawn. This will go on until there either no more ghosts to pick from, or the slots are full.", "Active Players") as null|anything in possible_ghosts // auto-picks if only one candidate
			possible_ghosts -= candidate
			players_to_spawn += candidate
	else
		to_chat(src, "Polling candidates...")
		players_to_spawn = SSghost_spawns.poll_candidates("Do you want to play as \a [team_name]?")

	if(!players_to_spawn.len)
		to_chat(src, "Nobody volunteered.")
		return 0

	var/players_spawned = 0
	for(var/mob/thisplayer in players_to_spawn)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(T)
		H.name = random_name(pick(MALE,FEMALE))
		var/datum/preferences/A = new() //Randomize appearance
		A.real_name = H.name
		A.copy_to(H)
		H.dna.ready_dna(H)

		if(force_species)
			var/datum/species/selected_species_datum = GLOB.all_species[selected_species]
			H.set_species(selected_species_datum.type)
			H.regenerate_icons()

		H.mind_initialize()
		H.mind.assigned_role = "Event Character"
		H.mind.special_role = "Event Character"
		H.mind.offstation_role = TRUE

		H.key = thisplayer.key
		if(dresscode != "Naked")
			H.equipOutfit(dresscode, FALSE)

		to_chat(H, "<BR><span class='danger'><B>[themission]</B></span>")
		H.mind.store_memory("<B>[themission]</B><BR><BR>")

		if(is_syndicate)
			SSticker.mode.traitors |= H.mind //Adds them to extra antag list

		players_spawned++
		if(players_spawned >= teamsize)
			break


	log_and_message_admins("used Spawn Gimmick Team.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Gimmick Team") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

// ---------------------------------------------------------------------------------------------------------
