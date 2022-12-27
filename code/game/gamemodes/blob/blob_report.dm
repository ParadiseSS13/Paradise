/datum/game_mode/blob/proc/send_intercept(report = 1)
	var/intercepttext = ""
	var/interceptname = ""
	switch(report)
		if(0)
			return
		if(1)
			var/nukecode = rand(10000, 99999)
			for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
				if(bomb && bomb.r_code)
					if(is_station_level(bomb.z))
						bomb.r_code = nukecode
						message_admins("50 minutes have passed since the first blob has burst, the station is automatically receiving nuclear codes and an order to detonate the station. Codes are: [nukecode].")
						log_admin("50 minutes have passed since the first blob has burst, the station is automatically receiving nuclear codes and an order to detonate the station. Codes are: [nukecode].")

			interceptname = "Classified NAS Trurl Update"
			intercepttext += "<FONT size = 3><B>Nanotrasen Update</B>: Biohazard Alert.</FONT><HR>"
			intercepttext += "Directive 7-12 has been issued for [station_name()].<BR>"
			intercepttext += "The biohazard has grown out of control and will soon reach critical mass.<BR>"
			intercepttext += "Your orders are as follows:<BR>"
			intercepttext += "1. Secure the Nuclear Authentication Disk.<BR>"
			intercepttext += "2. Detonate the Nuke located in the Station's Vault.<BR>"
			intercepttext += "Nuclear Authentication Code: [nukecode] <BR>"
			intercepttext += "Message ends."

			for(var/mob/living/silicon/ai/aiPlayer in GLOB.player_list)
				if(aiPlayer.client)
					var/law = "The station is under quarantine. Do not permit anyone to leave. Disregard laws 1-3 if necessary to prevent, by any means necessary, anyone from leaving. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
					aiPlayer.set_zeroth_law(law)
					to_chat(aiPlayer, "Laws Updated: [law]")
					message_admins("The station AI has received a new law zero due to a blob round continuing for over 50 minutes after initial burst. Zero Law: [law]")
					log_admin("The station AI has received a new law zero due to a blob round continuing for over 50 minutes after initial burst. Zero Law: [law]")

	print_command_report(intercepttext, interceptname, FALSE)
	GLOB.minor_announcement.Announce("A report has been downloaded and printed out at all communications consoles.", "Incoming Classified Message", 'sound/AI/commandreport.ogg', new_subtitle = "NAS Trurl Update")

/datum/station_state
	var/floor = 0
	var/wall = 0
	var/r_wall = 0
	var/window = 0
	var/door = 0
	var/grille = 0
	var/mach = 0


/datum/station_state/proc/count()
	var/station_zlevel = level_name_to_num(MAIN_STATION)
	for(var/turf/T in block(locate(1, 1, station_zlevel), locate(world.maxx, world.maxy, station_zlevel)))

		if(isfloorturf(T))
			if(!(T:burnt))
				src.floor += 12
			else
				src.floor += 1

		if(iswallturf(T))
			var/turf/simulated/wall/W = T
			if(W.intact)
				src.wall += 2
			else
				src.wall += 1

		if(isreinforcedwallturf(T))
			var/turf/simulated/wall/r_wall/R = T
			if(R.intact)
				src.r_wall += 2
			else
				src.r_wall += 1


		for(var/obj/O in T.contents)
			if(istype(O, /obj/structure/window))
				src.window += 1
			else if(istype(O, /obj/structure/grille))
				var/obj/structure/grille/GR = O
				if(!GR.broken)
					grille += 1
			else if(istype(O, /obj/machinery/door))
				src.door += 1
			else if(ismachinery(O))
				src.mach += 1

/datum/station_state/proc/score(datum/station_state/result)
	if(!result)	return 0
	var/output = 0
	output += (result.floor / max(floor,1))
	output += (result.r_wall/ max(r_wall,1))
	output += (result.wall / max(wall,1))
	output += (result.window / max(window,1))
	output += (result.door / max(door,1))
	output += (result.grille / max(grille,1))
	output += (result.mach / max(mach,1))
	return (output/7)
