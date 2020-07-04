//Config stuff
#define SYNDICATE_ELITE_MOVETIME 600	//Time to station is milliseconds. 60 seconds, enough time for everyone to be on the shuttle before it leaves.
#define SYNDICATE_ELITE_STATION_AREATYPE "/area/shuttle/syndicate_elite/station" //Type of the spec ops shuttle area for station
#define SYNDICATE_ELITE_DOCK_AREATYPE "/area/shuttle/syndicate_elite/mothership"	//Type of the spec ops shuttle area for dock

GLOBAL_VAR_INIT(syndicate_elite_shuttle_moving_to_station, 0)
GLOBAL_VAR_INIT(syndicate_elite_shuttle_moving_to_mothership, 0)
GLOBAL_VAR_INIT(syndicate_elite_shuttle_at_station, 0)
GLOBAL_VAR_INIT(syndicate_elite_shuttle_can_send, 1)
GLOBAL_VAR_INIT(syndicate_elite_shuttle_time, 0)
GLOBAL_VAR_INIT(syndicate_elite_shuttle_timeleft, 0)

/obj/machinery/computer/syndicate_elite_shuttle
	name = "\improper Elite Syndicate Squad shuttle console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "syndie_key"
	icon_screen = "syndishuttle"
	light_color = LIGHT_COLOR_PURE_CYAN
	req_access = list(ACCESS_SYNDICATE)
	var/temp = null
	var/hacked = 0
	var/allowedtocall = 0

/proc/syndicate_elite_process()
	var/area/syndicate_mothership/control/syndicate_ship = locate()//To find announcer. This area should exist for this proc to work.
	//var/area/syndicate_mothership/elite_squad/elite_squad = locate()//Where is the specops area located?
	var/mob/living/silicon/decoy/announcer = locate() in syndicate_ship//We need a fake AI to announce some stuff below. Otherwise it will be wonky.

	var/message_tracker[] = list(0,1,2,3,5,10,30,45)//Create a a list with potential time values.
	var/message = "THE SYNDICATE ELITE SHUTTLE IS PREPARING FOR LAUNCH"//Initial message shown.
	if(announcer)
		announcer.say(message)
	//	message = "ARMORED SQUAD TAKE YOUR POSITION ON GRAVITY LAUNCH PAD"
	//	announcer.say(message)

	while(GLOB.syndicate_elite_shuttle_time - world.timeofday > 0)
		var/ticksleft = GLOB.syndicate_elite_shuttle_time - world.timeofday

		if(ticksleft > 1e5)
			GLOB.syndicate_elite_shuttle_time = world.timeofday	// midnight rollover
		GLOB.syndicate_elite_shuttle_timeleft = (ticksleft / 10)

		//All this does is announce the time before launch.
		if(announcer)
			var/rounded_time_left = round(GLOB.syndicate_elite_shuttle_timeleft)//Round time so that it will report only once, not in fractions.
			if(rounded_time_left in message_tracker)//If that time is in the list for message announce.
				message = "ALERT: [rounded_time_left] SECOND[(rounded_time_left!=1)?"S":""] REMAIN"
				if(rounded_time_left==0)
					message = "ALERT: TAKEOFF"
				announcer.say(message)
				message_tracker -= rounded_time_left//Remove the number from the list so it won't be called again next cycle.
				//Should call all the numbers but lag could mean some issues. Oh well. Not much I can do about that.

		sleep(5)

	GLOB.syndicate_elite_shuttle_moving_to_station = 0
	GLOB.syndicate_elite_shuttle_moving_to_mothership = 0

	GLOB.syndicate_elite_shuttle_at_station = 1
	if(GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership) return

	if(!syndicate_elite_can_move())
		to_chat(usr, "<span class='warning'>The Syndicate Elite shuttle is unable to leave.</span>")
		return

/*
	//Begin Marauder launchpad.
	spawn(0)//So it parallel processes it.
		for(var/obj/machinery/door/poddoor/M in elite_squad)
			switch(M.id)
				if("ASSAULT0")
					spawn(10)//1 second delay between each.
						M.open()
				if("ASSAULT1")
					spawn(20)
						M.open()
				if("ASSAULT2")
					spawn(30)
						M.open()
				if("ASSAULT3")
					spawn(40)
						M.open()

		sleep(10)

		var/spawn_marauder[] = new()
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(L.name == "Marauder Entry")
				spawn_marauder.Add(L)
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(L.name == "Marauder Exit")
				var/obj/effect/portal/P = new(L.loc)
				P.invisibility = 101//So it is not seen by anyone.
				P.failchance = 0//So it has no fail chance when teleporting.
				P.target = pick(spawn_marauder)//Where the marauder will arrive.
				spawn_marauder.Remove(P.target)

		sleep(10)

		for(var/obj/machinery/mass_driver/M in elite_squad)
			switch(M.id)
				if("ASSAULT0")
					spawn(10)
						M.drive()
				if("ASSAULT1")
					spawn(20)
						M.drive()
				if("ASSAULT2")
					spawn(30)
						M.drive()
				if("ASSAULT3")
					spawn(40)
						M.drive()

		sleep(50)//Doors remain open for 5 seconds.

		for(var/obj/machinery/door/poddoor/M in elite_squad)
			switch(M.id)//Doors close at the same time.
				if("ASSAULT0")
					spawn(0)
						M.close()
				if("ASSAULT1")
					spawn(0)
						M.close()
				if("ASSAULT2")
					spawn(0)
						M.close()
				if("ASSAULT3")
					spawn(0)
						M.close()
		elite_squad.readyreset()//Reset firealarm after the team launched.
	*/
	//End Marauder launchpad.

	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/L = thing
		if(L.name == "Syndicate Breach Area")
			explosion(L.loc,4,6,8,10,0)

	sleep(40)


	var/area/start_location = locate(/area/shuttle/syndicate_elite/mothership)
	var/area/end_location = locate(/area/shuttle/syndicate_elite/station)

	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in end_location)
		dstturfs  = T
		if(T.y < throwy)
			throwy = T.y

				// hey you, get out of the way!
	for(var/turf/T in dstturfs)
					// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

	for(var/mob/living/carbon/bug in end_location) // If someone somehow is still in the shuttle's docking area...
		bug.gib()

	for(var/mob/living/simple_animal/pest in end_location) // And for the other kind of bug...
		pest.gib()

	start_location.move_contents_to(end_location)

	for(var/turf/T in get_area_turfs(end_location) )
		var/mob/M = locate(/mob) in T
		to_chat(M, "<span class='warning'>You have arrived to [station_name()]. Commence operation!</span>")

/proc/syndicate_elite_can_move()
	if(GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership) return 0
	else return 1

/obj/machinery/computer/syndicate_elite_shuttle/attack_ai(var/mob/user as mob)
	to_chat(user, "<span class='warning'>Access Denied.</span>")
	return 1

/obj/machinery/computer/syndicate_elite_shuttle/attackby(I as obj, user as mob, params)
	if(istype(I,/obj/item/card/emag))
		to_chat(user, "<span class='notice'>The electronic systems in this console are far too advanced for your primitive hacking peripherals.</span>")
	else
		return ..()

/obj/machinery/computer/syndicate_elite_shuttle/attack_hand(var/mob/user as mob)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied.</span>")
		return

//	if(sent_syndicate_strike_team == 0)
//		to_chat(usr, "<span class='warning'>The strike team has not yet deployed.</span>")
//		return

	if(..())
		return

	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		dat  = {"<BR><B>Special Operations Shuttle</B><HR>
		\nLocation: [GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership ? "Departing for [station_name()] in ([GLOB.syndicate_elite_shuttle_timeleft] seconds.)":GLOB.syndicate_elite_shuttle_at_station ? "Station":"Dock"]<BR>
		[GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership ? "\n*The Syndicate Elite shuttle is already leaving.*<BR>\n<BR>":GLOB.syndicate_elite_shuttle_at_station ? "\n<A href='?src=[UID()];sendtodock=1'>Shuttle Offline</A><BR>\n<BR>":"\n<A href='?src=[UID()];sendtostation=1'>Depart to [station_name()]</A><BR>\n<BR>"]
		\n<A href='?src=[user.UID()];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/syndicate_elite_shuttle/Topic(href, href_list)
	if(..())
		return 1

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	if(href_list["sendtodock"])
		if(!GLOB.syndicate_elite_shuttle_at_station|| GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership) return

		to_chat(usr, "<span class='notice'>The Syndicate will not allow the Elite Squad shuttle to return.</span>")
		return

	else if(href_list["sendtostation"])
		if(GLOB.syndicate_elite_shuttle_at_station || GLOB.syndicate_elite_shuttle_moving_to_station || GLOB.syndicate_elite_shuttle_moving_to_mothership) return

		if(!specops_can_move())
			to_chat(usr, "<span class='warning'>The Syndicate Elite shuttle is unable to leave.</span>")
			return

		to_chat(usr, "<span class='notice'>The Syndicate Elite shuttle will arrive on [station_name()] in [(SYNDICATE_ELITE_MOVETIME/10)] seconds.</span>")

		temp  = "Shuttle departing.<BR><BR><A href='?src=[UID()];mainmenu=1'>OK</A>"
		updateUsrDialog()

		var/area/syndicate_mothership/elite_squad/elite_squad = locate()
		if(elite_squad)
			elite_squad.readyalert()//Trigger alarm for the spec ops area.
		GLOB.syndicate_elite_shuttle_moving_to_station = 1

		GLOB.syndicate_elite_shuttle_time = world.timeofday + SYNDICATE_ELITE_MOVETIME
		spawn(0)
			syndicate_elite_process()


	else if(href_list["mainmenu"])
		temp = null

	add_fingerprint(usr)
	updateUsrDialog()
	return
