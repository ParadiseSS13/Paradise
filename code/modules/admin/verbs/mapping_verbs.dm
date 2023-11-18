//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

GLOBAL_VAR_INIT(camera_range_display_status, 0)
GLOBAL_VAR_INIT(intercom_range_display_status, 0)

/obj/effect/debugging/mapfix_marker
	name = "map fix marker"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "mapfixmarker"
	desc = "I am a mappers mistake."

/obj/effect/debugging/marker
	icon = 'icons/turf/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Move()
	return 0

/client/proc/camera_view()
	set category = "Mapping"
	set name = "Camera Range Display"

	if(!check_rights(R_DEBUG))
		return

	if(GLOB.camera_range_display_status)
		GLOB.camera_range_display_status = 0
	else
		GLOB.camera_range_display_status = 1

	for(var/obj/effect/debugging/marker/M in world)
		qdel(M)

	if(GLOB.camera_range_display_status)
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			for(var/turf/T in orange(7, C))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if(!(F in view(7, C.loc)))
					qdel(F)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Camera Range Display") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/sec_camera_report()
	set category = "Mapping"
	set name = "Camera Report"

	if(!check_rights(R_DEBUG))
		return

	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		CL += C

	var/output = {"<B>CAMERA ANOMALIES REPORT</B><HR>
<B>The following anomalies have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</B><BR><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) and \[[C2.x], [C2.y], [C2.z]\] ([C2.loc.loc]) - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Networks: [C1.network] and [C2.network]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density)
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if(W.dir == turn(C1.dir,180) || W.fulltile)
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at \[[C1.x], [C1.y], [C1.z]\] ([C1.loc.loc]) Network: [C1.network]</color></li>"

	output += "</ul>"
	usr << browse(output,"window=airreport;size=1000x500")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Camera Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/intercom_view()
	set category = "Mapping"
	set name = "Intercom Range Display"

	if(!check_rights(R_DEBUG))
		return

	if(GLOB.intercom_range_display_status)
		GLOB.intercom_range_display_status = 0
	else
		GLOB.intercom_range_display_status = 1

	for(var/obj/effect/debugging/marker/M in world)
		qdel(M)

	if(GLOB.intercom_range_display_status)
		for(var/obj/item/radio/intercom/I in GLOB.global_radios)
			for(var/turf/T in orange(7,I))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if(!(F in view(7,I.loc)))
					qdel(F)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Intercom Range Display") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_on_z_level()
	set category = "Mapping"
	set name = "Count Objects On Level"

	if(!check_rights(R_DEBUG))
		return

	var/level = clean_input("Which z-level?","Level?")
	if(!level) return
	var/num_level = text2num(level)
	if(!num_level) return
	if(!isnum(num_level)) return

	var/type_text = clean_input("Which type path?","Path?")
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	var/list/atom/atom_list = list()

	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B && B.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Count Objects (On Level)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/count_objects_all()
	set category = "Mapping"
	set name = "Count Objects All"

	if(!check_rights(R_DEBUG))
		return

	var/type_text = clean_input("Which type path?","")
	if(!type_text) return
	var/type_path = text2path(type_text)
	if(!type_path) return

	var/count = 0

	for(var/atom/A in world)
		if(istype(A,type_path))
			count++

	to_chat(world, "There are [count] objects of type [type_path] in the game world.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Count Objects (Global)") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/set_next_map()
	set category = "Server"
	set name = "Set Next Map"

	if(!check_rights(R_SERVER))
		return

	var/list/map_datums = list()
	for(var/x in subtypesof(/datum/map))
		var/datum/map/M = x
		if(initial(M.voteable))
			map_datums["[initial(M.fluff_name)] ([initial(M.technical_name)])"] = M // Put our map in

	var/target_map_name = input(usr, "Select target map", "Next map", null) as null|anything in map_datums

	if(!target_map_name)
		return

	var/datum/map/TM = map_datums[target_map_name]
	SSmapping.next_map = new TM
	var/announce_to_players = alert(usr, "Do you wish to tell the playerbase about your choice?", "Announce", "Yes", "No")
	message_admins("[key_name_admin(usr)] has set the next map to [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])")
	log_admin("[key_name(usr)] has set the next map to [SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])")
	if(announce_to_players == "Yes")
		to_chat(world, "<span class='boldannounce'>[key] has chosen the following map for next round: <font color='cyan'>[SSmapping.next_map.fluff_name] ([SSmapping.next_map.technical_name])</font></span>")
