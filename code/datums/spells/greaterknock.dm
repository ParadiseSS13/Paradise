/obj/effect/proc_holder/spell/aoe_turf/greaterknock
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the Cyberiad, and announce this spell's use and your arrival to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"

	school = "transmutation"
	charge_max = 200
	clothes_req = 0
	invocation = "MAIOR OXIN FIERA"
	invocation_type = "shout"
	range = 7
	cooldown_min = 40 //40 deciseconds reduction per rank
	action_icon_state = "knock"
	sound = 'sound/magic/Knock.ogg'
	var/used = FALSE

/obj/effect/proc_holder/spell/aoe_turf/greaterknock/cast(list/targets, mob/user = usr)
	if (!used)
		for(var/obj/machinery/door/airlock/A in airlocks)
			if(is_station_level(A.z))
				A.req_access = list()
		if (is_station_level(usr.z))
			command_announcement.Announce("We have noticed several issues inhibiting productivity on your station, and would like to help resolve them! We have already improved your airlock access system. No longer will you be unable to get what you need, as of now you can go anywhere you want! One of our employees should already be on-site to further improve your station. Have a pleasant day!", "Greetings!", 'sound/misc/notice2.ogg', , , "Space Wizard Federation Message")
		else
			command_announcement.Announce("We have noticed several issues inhibiting productivity on your station, and would like to help resolve them! We have already improved your airlock access system. No longer will you be unable to get what you need, as of now you can go anywhere you want! We are sending one of our employees to further improve your station. Have a pleasant day!", "Greetings!", 'sound/misc/notice2.ogg', , , "Space Wizard Federation Message")
		used = TRUE
	else
		for(var/turf/T in targets)
			for(var/obj/machinery/door/door in T.contents)
				spawn(1)
					if(istype(door,/obj/machinery/door/airlock/hatch/gamma))
						return
					if(istype(door,/obj/machinery/door/airlock))
						var/obj/machinery/door/airlock/A = door
						A.unlock(1)	//forced because it's magic!
					door.open()
			for(var/obj/structure/closet/C in T.contents)
				spawn(1)
					if(istype(C, /obj/structure/closet/secure_closet))
						var/obj/structure/closet/secure_closet/SC = C
						SC.locked = 0
					C.open()
	return