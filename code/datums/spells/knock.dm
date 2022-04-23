/obj/effect/proc_holder/spell/aoe_turf/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"
	sound = 'sound/magic/knock.ogg'

/obj/effect/proc_holder/spell/aoe_turf/knock/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = 3
	return T

/obj/effect/proc_holder/spell/aoe_turf/knock/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			INVOKE_ASYNC(src, .proc/try_open_airlock, door)
		for(var/obj/structure/closet/C in T.contents)
			INVOKE_ASYNC(src, .proc/try_open_closet, C)

/obj/effect/proc_holder/spell/aoe_turf/knock/proc/try_open_airlock(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
		return
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = door
		A.unlock(TRUE)	//forced because it's magic!
	door.open()

/obj/effect/proc_holder/spell/aoe_turf/knock/proc/try_open_closet(obj/structure/closet/C)
	if(istype(C, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/SC = C
		SC.locked = FALSE
	C.open()

/obj/effect/proc_holder/spell/aoe_turf/knock/greater
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the station, and announce this spell's use to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"

	charge_max = 200
	invocation = "MAIOR OXIN FIERA"
	invocation_type = "shout"
	level_max = 0 //Cannot be improved, quality of life since can't be refunded
	cooldown_min = 200
	var/used = FALSE

/obj/effect/proc_holder/spell/aoe_turf/knock/greater/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	return T

/obj/effect/proc_holder/spell/aoe_turf/knock/greater/cast(list/targets, mob/user = usr)
	if(!used)
		used = TRUE
		for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
			if(is_station_level(A.z))
				A.req_access = list()
				A.req_one_access = list()
		GLOB.command_announcement.Announce("We have removed all access requirements on your station's airlocks. You can thank us later!", "Greetings!", 'sound/misc/notice2.ogg', , , "Space Wizard Federation Message")
	else
		..()
	return
