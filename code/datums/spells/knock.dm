/obj/effect/proc_holder/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	base_cooldown = 10 SECONDS
	cooldown_min = 2 SECONDS //20 deciseconds reduction per rank
	clothes_req = FALSE
	invocation = "AULIE OXIN FIERA"
	invocation_type = "whisper"

	action_icon_state = "knock"
	sound = 'sound/magic/knock.ogg'
	aoe_range = 3


/obj/effect/proc_holder/spell/aoe/knock/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/knock/cast(list/targets, mob/user = usr)
	for(var/turf/target_turf in targets)
		for(var/obj/machinery/door/door in target_turf.contents)
			if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
				continue
			INVOKE_ASYNC(src, PROC_REF(try_open_airlock), door)

		for(var/obj/structure/closet/closet in target_turf.contents)
			INVOKE_ASYNC(src, PROC_REF(try_open_closet), closet)


/obj/effect/proc_holder/spell/aoe/knock/proc/try_open_airlock(obj/machinery/door/door)
	if(istype(door, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = door
		airlock.unlock(TRUE)	//forced because it's magic!
	door.open()


/obj/effect/proc_holder/spell/aoe/knock/proc/try_open_closet(obj/structure/closet/closet)
	if(istype(closet, /obj/structure/closet/secure_closet))
		var/obj/structure/closet/secure_closet/s_closet = closet
		s_closet.locked = FALSE
	closet.open()


/obj/effect/proc_holder/spell/aoe/knock/greater
	name = "Greater Knock"
	desc = "On first cast, will remove access restrictions on all airlocks on the station, and announce this spell's use to the station. On any further cast, will open all doors in sight. Cannot be refunded once bought!"

	base_cooldown = 20 SECONDS
	cooldown_min = 20 SECONDS
	invocation = "MAIOR OXIN FIERA"
	invocation_type = "shout"
	level_max = 0 //Cannot be improved, quality of life since can't be refunded
	aoe_range = 7
	var/used = FALSE


/obj/effect/proc_holder/spell/aoe/knock/greater/cast(list/targets, mob/user = usr)
	if(!used)
		used = TRUE
		for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
			if(is_station_level(A.z))
				A.req_access = list()
		GLOB.command_announcement.Announce(
			message = "Мы убрали все доступы у шл+юзов вашей станции. Вы сможете поблагодарить нас позже!",
			new_title = "Приветствуем!",
			new_sound = 'sound/misc/announce_dig.ogg',
			from = "Послание Федерации Космических Волшебников."
		)
	else
		..()

