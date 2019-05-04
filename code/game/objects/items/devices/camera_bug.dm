#define BUGMODE_LIST	0
#define BUGMODE_MONITOR	1
#define BUGMODE_TRACK	2



/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state	= "camera_bug"
	w_class		= WEIGHT_CLASS_TINY
	item_state	= "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"

	var/obj/machinery/camera/current = null

	var/last_net_update = 0
	var/list/bugged_cameras = list()

	var/track_mode = BUGMODE_LIST
	var/last_tracked = 0
	var/refresh_interval = 50

	var/tracked_name = null
	var/atom/tracking = null

	var/last_found = null
	var/last_seen = null

/obj/item/camera_bug/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/camera_bug/Destroy()
	get_cameras()
	for(var/cam_tag in bugged_cameras)
		var/obj/machinery/camera/camera = bugged_cameras[cam_tag]
		if(camera.bug == src)
			camera.bug = null
	bugged_cameras = list()
	if(tracking)
		tracking = null
	return ..()

/obj/item/camera_bug/interact(var/mob/user = usr)
	var/datum/browser/popup = new(user, "camerabug","Camera Bug",nref=src)
	popup.set_content(menu(get_cameras()))
	popup.open()

/obj/item/camera_bug/attack_self(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/item/camera_bug/check_eye(var/mob/user as mob)
	if(user.stat || loc != user || !user.canmove || !user.has_vision() || !current)
		user.reset_perspective(null)
		user.unset_machine()
		return null

	var/turf/T = get_turf(user.loc)
	if(T.z != current.z || !current.can_use())
		to_chat(user, "<span class='danger'>[src] has lost the signal.</span>")
		current = null
		user.reset_perspective(null)
		user.unset_machine()
		return null

	return 1

/obj/item/camera_bug/proc/get_cameras()
	if(world.time > (last_net_update + 100))
		bugged_cameras = list()
		for(var/obj/machinery/camera/camera in cameranet.cameras)
			if(camera.stat || !camera.can_use())
				continue
			if(length(list("SS13","MINE")&camera.network))
				bugged_cameras[camera.c_tag] = camera
	sortList(bugged_cameras)
	return bugged_cameras



/obj/item/camera_bug/proc/menu(var/list/cameras)
	if(!cameras || !cameras.len)
		return "No bugged cameras found."

	var/html
	switch(track_mode)
		if(BUGMODE_LIST)
			html = "<h3>Select a camera:</h3> <a href='?src=[UID()];view'>\[Cancel camera view\]</a><hr><table>"
			for(var/entry in cameras)
				var/obj/machinery/camera/C = cameras[entry]
				var/functions = ""
				if(C.bug == src)
					functions = " - <a href='?src=[UID()];monitor=\ref[C]'>\[Monitor\]</a> <a href='?src=[UID()];emp=\ref[C]'>\[Disable\]</a>"
				else
					functions = " - <a href='?src=[UID()];monitor=\ref[C]'>\[Monitor\]</a>"
				html += "<tr><td><a href='?src=[UID()];view=\ref[C]'>[entry]</a></td><td>[functions]</td></tr>"

		if(BUGMODE_MONITOR)
			if(current)
				html = "Analyzing Camera '[current.c_tag]' <a href='?src=[UID()];mode=0'>\[Select Camera\]</a><br>"
				html += camera_report()
			else
				track_mode = BUGMODE_LIST
				return .(cameras)
		if(BUGMODE_TRACK)
			if(tracking)
				html = "Tracking '[tracked_name]'  <a href='?src=[UID()];mode=0'>\[Cancel Tracking\]</a>  <a href='?src=[UID()];view'>\[Cancel camera view\]</a><br>"
				if(last_found)
					var/time_diff = round((world.time - last_seen) / 150)
					var/obj/machinery/camera/C = bugged_cameras[last_found]
					var/outstring
					if(C)
						outstring = "<a href='?src=[UID()];view=\ref[C]'>[last_found]</a>"
					else
						outstring = last_found
					if(!time_diff)
						html += "Last seen near [outstring] (now)<br>"
					else
						// 15 second intervals ~ 1/4 minute
						var/m = round(time_diff/4)
						var/s = (time_diff - 4*m) * 15
						if(!s) s = "00"
						html += "Last seen near [outstring] ([m]:[s] minute\s ago)<br>"
					if( C && (C.bug == src)) //Checks to see if the camera has a bug
						html += "<a href='?src=[UID()];emp=\ref[C]'>\[Disable\]</a>"

				else
					html += "Not yet seen."
			else
				track_mode = BUGMODE_LIST
				return .(cameras)
	return html

/obj/item/camera_bug/proc/camera_report()
	// this should only be called if current exists
	var/dat = ""
	if(current && current.can_use())
		var/list/seen = current.can_see()
		var/list/names = list()
		for(var/obj/singularity/S in seen) // god help you if you see more than one
			if(S.name in names)
				names[S.name]++
				dat += "[S.name] ([names[S.name]])"
			else
				names[S.name] = 1
				dat += "[S.name]"
			var/stage = round(S.current_size / 2)+1
			dat += " (Stage [stage])"
			dat += " <a href='?src=[UID()];track=\ref[S]'>\[Track\]</a><br>"

		for(var/obj/mecha/M in seen)
			if(M.name in names)
				names[M.name]++
				dat += "[M.name] ([names[M.name]])"
			else
				names[M.name] = 1
				dat += "[M.name]"
			dat += " <a href='?src=[UID()];track=\ref[M]'>\[Track\]</a><br>"


		for(var/mob/living/M in seen)
			if(M.name in names)
				names[M.name]++
				dat += "[M.name] ([names[M.name]])"
			else
				names[M.name] = 1
				dat += "[M.name]"
			if(M.buckled && !M.lying)
				dat += " (Sitting)"
			if(M.lying)
				dat += " (Laying down)"
			dat += " <a href='?src=[UID()];track=\ref[M]'>\[Track\]</a><br>"
		if(length(dat) == 0)
			dat += "No motion detected."
		return dat
	else
		return "Camera Offline<br>"

/obj/item/camera_bug/Topic(var/href,var/list/href_list)
	if(usr != loc)
		usr.unset_machine()
		usr.reset_perspective(null)
		usr << browse(null, "window=camerabug")
		return
	usr.set_machine(src)
	if("mode" in href_list)
		track_mode = text2num(href_list["mode"])
	if("monitor" in href_list)
		var/obj/machinery/camera/C = locate(href_list["monitor"])
		if(C)
			track_mode = BUGMODE_MONITOR
			current = C
			usr.reset_perspective(null)
			interact()
	if("track" in href_list)
		var/atom/A = locate(href_list["track"])
		if(A)
			tracking = A
			tracked_name = A.name
			last_found = current.c_tag
			last_seen = world.time
			track_mode = BUGMODE_TRACK
	if("emp" in href_list)
		var/obj/machinery/camera/C = locate(href_list["emp"])
		if(istype(C) && C.bug == src)
			C.emp_act(1)
			C.bug = null
			bugged_cameras -= C.c_tag
		interact()
		return
	if("close" in href_list)
		usr.reset_perspective(null)
		usr.unset_machine()
		current = null
		return // I do not <- I do not remember what I was going to write in this comment -Sayu, sometime later
	if("view" in href_list)
		var/obj/machinery/camera/C = locate(href_list["view"])
		if(istype(C))
			if(!C.can_use())
				to_chat(usr, "<span class='danger'>Something's wrong with that camera.  You can't get a feed.</span>")
				return
			var/turf/T = get_turf(loc)
			if(!T || C.z != T.z)
				to_chat(usr, "<span class='danger'>You can't get a signal.</span>")
				return
			current = C
			spawn(6)
				if(src.check_eye(usr))
					usr.reset_perspective(C)
					interact()
				else
					usr.unset_machine()
					usr.reset_perspective(null)
					usr << browse(null, "window=camerabug")
			return
		else
			usr.unset_machine()
			usr.reset_perspective(null)

	interact()

/obj/item/camera_bug/process()
	if(track_mode == BUGMODE_LIST || (world.time < (last_tracked + refresh_interval)))
		return
	last_tracked = world.time
	if(track_mode == BUGMODE_TRACK ) // search for user
		// Note that it will be tricked if your name appears to change.
		// This is not optimal but it is better than tracking you relentlessly despite everything.
		if(!tracking)
			src.updateSelfDialog()
			return

		if(tracking.name != tracked_name) // Hiding their identity, tricksy
			var/mob/M = tracking
			if(istype(M))
				if(!(tracked_name == "Unknown" && findtext(tracking.name,"Unknown"))) // we saw then disguised before
					if(!(tracked_name == M.real_name && findtext(tracking.name,M.real_name))) // or they're still ID'd
						src.updateSelfDialog()//But if it's neither of those cases
						return // you won't find em on the cameras
			else
				src.updateSelfDialog()
				return

		var/list/tracking_cams = list()
		var/list/b_cams = get_cameras()
		for(var/entry in b_cams)
			tracking_cams += b_cams[entry]
		var/list/target_region = view(tracking)

		for(var/obj/machinery/camera/C in (target_region & tracking_cams))
			if(!can_see(C,tracking)) // target may have xray, that doesn't make them visible to cameras
				continue
			if(C.can_use())
				last_found = C.c_tag
				last_seen = world.time
				break
	src.updateSelfDialog()


#undef BUGMODE_LIST
#undef BUGMODE_MONITOR
#undef BUGMODE_TRACK
