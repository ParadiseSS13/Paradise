/datum/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	clothes_req = FALSE
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"
	cooldown_min = 20 //20 deciseconds reduction per rank

	action_icon_state = "knock"
	sound = 'sound/magic/knock.ogg'
	aoe_range = 3

/datum/spell/aoe/knock/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/knock/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/obj/machinery/door/door in T.contents)
			INVOKE_ASYNC(src, PROC_REF(try_open_airlock), door)
		for(var/obj/structure/closet/C in T.contents)
			INVOKE_ASYNC(src, PROC_REF(try_open_closet), C)

/datum/spell/aoe/knock/proc/try_open_airlock(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = door
		A.unlock(TRUE)	//forced because it's magic!
	door.open()

/datum/spell/aoe/knock/proc/try_open_closet(obj/structure/closet/C)
	if(istype(C, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/SC = C
		SC.locked = FALSE
	C.open()

/datum/spell/aoe/knock/greater
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the station, and announce this spell's use to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"

	base_cooldown = 200
	invocation = "MAIOR OXIN FIERA"
	invocation_type = "shout"
	level_max = 0 //Cannot be improved, quality of life since can't be refunded
	cooldown_min = 200
	var/used = FALSE

	action_icon_state = "greater_knock"

/datum/spell/aoe/knock/greater/cast(list/targets, mob/user = usr)
	if(!used)
		used = TRUE
		for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
			if(is_station_level(A.z))
				A.req_access = list()
				A.req_one_access = list()
		GLOB.major_announcement.Announce(
			message = "We have removed all access requirements on your station's airlocks. You can thank us later!",
			new_title = "Space Wizard Federation Message",
			new_subtitle = "Greetings!",
			new_sound = 'sound/misc/notice2.ogg'
		)
	else
		..()
	return
