/datum/buildmode_mode/basic
	key = "basic"

/datum/buildmode_mode/basic/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button        = Construct / Upgrade</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button       = Deconstruct / Delete / Downgrade</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button + ctrl = R-Window</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button + alt  = Airlock</span>")
	to_chat(user, "<span class='notice'>Use the button in the upper left corner to</span>")
	to_chat(user, "<span class='notice'>change the direction of built objects.</span>")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

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
