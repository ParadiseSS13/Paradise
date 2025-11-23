/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(mob/user)
	to_chat(user, SPAN_NOTICE("***********************************************************"))
	to_chat(user, SPAN_NOTICE("Left Mouse Button        = Construct / Upgrade"))
	to_chat(user, SPAN_NOTICE("Right Mouse Button       = Deconstruct / Delete / Downgrade"))
	to_chat(user, SPAN_NOTICE("Left Mouse Button + ctrl = R-Window"))
	to_chat(user, SPAN_NOTICE("Left Mouse Button + alt  = Airlock"))
	to_chat(user, SPAN_NOTICE("Use the button in the upper left corner to"))
	to_chat(user, SPAN_NOTICE("change the direction of built objects."))
	to_chat(user, SPAN_NOTICE("***********************************************************"))

/datum/buildmode_mode/basic/handle_click(user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/ctrl_click = pa.Find("ctrl")
	var/alt_click = pa.Find("alt")

	if(isturf(object) && left_click && !alt_click && !ctrl_click)
		var/turf/T = object
		if(isspaceturf(object))
			T.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			T.ChangeTurf(/turf/simulated/wall)
		else if(iswallturf(object))
			T.ChangeTurf(/turf/simulated/wall/r_wall)
		log_admin("Build Mode: [key_name(user)] built [T] at ([T.x],[T.y],[T.z])")
	else if(right_click)
		log_admin("Build Mode: [key_name(user)] deleted [object] at ([object.x],[object.y],[object.z])")
		if(iswallturf(object))
			var/turf/T = object
			T.ChangeTurf(/turf/simulated/floor/plasteel)
		else if(isfloorturf(object))
			var/turf/T = object
			T.ChangeTurf(T.baseturf)
		else if(isreinforcedwallturf(object))
			var/turf/T = object
			T.ChangeTurf(/turf/simulated/wall)
		else if(isobj(object))
			qdel(object)
	else if(isturf(object) && alt_click && left_click)
		log_admin("Build Mode: [key_name(user)] built an airlock at ([object.x],[object.y],[object.z])")
		var/obj/machinery/door/airlock/A = new /obj/machinery/door/airlock(get_turf(object))
		A.admin_spawned = TRUE
	else if(isturf(object) && ctrl_click && left_click)
		var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
		WIN.admin_spawned = TRUE
		WIN.setDir(BM.build_dir)
		log_admin("Build Mode: [key_name(user)] built a window at ([object.x],[object.y],[object.z])")
