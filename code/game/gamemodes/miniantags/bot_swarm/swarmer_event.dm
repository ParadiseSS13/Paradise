/datum/event/spawn_swarmer
	startWhen = 3 //30 minutes
	announceWhen = 10

/datum/event/spawn_swarmer/announce()
	if(prob(25)) //25% chance to announce it to the crew
		var/swarmer_report = "<font size=3><b>[command_name()] High-Priority Update</b></span>"
		swarmer_report += "<br><br>Our long-range sensors have detected an odd signal emanating from your station's gateway. We recommend immediate investigation of your gateway, as something may have come \
		through."
		print_command_report(swarmer_report, "Classified [command_name()] Update")
		event_announcement.Announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg')

/datum/event/spawn_swarmer/start()
	if(find_swarmer())
		return 0
	if(!the_gateway)
		return 0
	new /obj/item/unactivated_swarmer(get_turf(the_gateway))


/datum/event/spawn_swarmer/proc/find_swarmer()
	for(var/mob/living/M in GLOB.mob_list)
		if(istype(M, /mob/living/simple_animal/hostile/swarmer) && M.client) //If there is a swarmer with an active client, we've found our swarmer
			return 1
	return 0
