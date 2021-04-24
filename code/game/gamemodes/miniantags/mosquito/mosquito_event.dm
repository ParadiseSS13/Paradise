/datum/event/spawn_mosquito
	startWhen = 30 MINUTES
	announceWhen = 10 MINUTES

	var/spawncount = 5
	var/successSpawn = FALSE
	var/SuccesAnnouncement = FALSE

/datum/event/spawn_mosquito/announce()
	if(prob(25)) //25% chance to announce it to the crew
		var/mosquito_report = "<font size=3><b>[command_name()] High-Priority Update</b></span>"
		mosquito_report += "<br><br>We suspect there is a biohazard aboard your station. We recommend immidiate investigation of your personnel."
		print_command_report(mosquito_report, "Classified [command_name()] Update", FALSE)
		GLOB.event_announcement.Announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')
		SuccesAnnouncement = TRUE
	else
		addtimer(CALLBACK(src, .proc/announce), 5 MINUTES)


/datum/event/spawn_mosquito/start()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	while(spawncount && length(vents))
		var/obj/vent = pick_n_take(vents)
		new /mob/living/simple_animal/mosquito(vent.loc)
		successSpawn = TRUE
		spawncount--
