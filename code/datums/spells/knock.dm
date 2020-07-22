/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	range = 3
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"
	sound = 'sound/magic/knock.ogg'

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets, mob/user = usr)
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

/obj/effect/proc_holder/spell/aoe_turf/knock/greater
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the station, and announce this spell's use to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"

	charge_max = 200
	invocation = "MAIOR OXIN FIERA"
	invocation_type = "shout"
	range = 7
	level_max = 0 //Cannot be improved, quality of life since can't be refunded
	cooldown_min = 200
	var/used = FALSE

/obj/effect/proc_holder/spell/aoe_turf/knock/greater/cast(list/targets, mob/user = usr)
	if(!used)
		used = TRUE
		for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
			if(is_station_level(A.z))
				A.req_access = list()
				A.req_one_access = list()
		command_announcement.Announce("We have removed all access requirements on your station's airlocks. You can thank us later!", "Greetings!", 'sound/misc/notice2.ogg', , , "Space Wizard Federation Message")
	else
		..()
	return
