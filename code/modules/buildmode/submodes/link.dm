/datum/buildmode_mode/link
	key = "link"

	var/list/link_lines = list()
	var/obj/link_obj


/datum/buildmode_mode/link/proc/clear_lines()
	QDEL_LIST(link_lines)

/datum/buildmode_mode/link/proc/form_connection(atom/source, atom/dest, valid)
	var/obj/effect/buildmode_line/L = new(BM.holder, source, dest, "[source.name] to [dest.name]")
	L.color = valid ? "#339933" : "#993333"
	link_lines += L
	var/obj/effect/buildmode_line/L2 = new(BM.holder, dest, source, "[dest.name] to [source.name]") // Yes, reversed one so that you can see it source both sides.
	L2.color = L.color
	link_lines += L2

/datum/buildmode_mode/link/Destroy()
	clear_lines()
	link_obj = null
	return ..()

/datum/buildmode_mode/link/Reset()
	clear_lines()
	link_obj = null
	..()

/datum/buildmode_mode/link/show_help(mob/user)
	to_chat(user, "<span class='notice'>***********************************************************</span>")
	to_chat(user, "<span class='notice'>Left Mouse Button on obj  = Select button to link</span>")
	to_chat(user, "<span class='notice'>Right Mouse Button on obj = Link/unlink to selected button")
	to_chat(user, "<span class='notice'>***********************************************************</span>")

// FIXME: this probably would work better with something component-based
/datum/buildmode_mode/link/handle_click(mob/user, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	if(left_click && istype(object, /obj/machinery))
		link_obj = object
	if(right_click && istype(object, /obj/machinery))
		if(istype(link_obj, /obj/machinery/door_control) && istype(object, /obj/machinery/door/airlock))
			var/obj/machinery/door_control/M = link_obj
			var/obj/machinery/door/airlock/P = object
			if(!M.id || M.id == "")
				M.id = input(user, "Please select an ID for the button", "Buildmode", "")
				if(!M.id || M.id == "")
					goto(line_jump)
			if(P.id_tag == M.id && P.id_tag && P.id_tag != "")
				P.id_tag = null
				to_chat(user, "[P] unlinked.")
				goto(line_jump)
			if(!M.normaldoorcontrol)
				if(link_lines.len && alert(user, "Warning: This will disable links to connected pod doors. Continue?", "Buildmode", "Yes", "No") == "No")
					goto(line_jump)
				M.normaldoorcontrol = 1
			if(P.id_tag && alert(user, "Warning: This will unlink something else from the door. Continue?", "Buildmode", "Yes", "No") == "No")
				goto(line_jump)
			P.id_tag = M.id
		if(istype(link_obj, /obj/machinery/door_control) && istype(object, /obj/machinery/door/poddoor))
			var/obj/machinery/door_control/M = link_obj
			var/obj/machinery/door/poddoor/P = object
			if(!M.id || M.id == "")
				M.id = input(user, "Please select an ID for the button", "Buildmode", "")
				if(!M.id || M.id == "")
					goto(line_jump)
			if(P.id_tag == M.id && P.id_tag && P.id_tag != "")
				P.id_tag = null
				to_chat(user, "[P] unlinked.")
				goto(line_jump)
			if(M.normaldoorcontrol)
				if(link_lines.len && alert(user, "Warning: This will disable links to connected airlocks. Continue?", "Buildmode", "Yes", "No") == "No")
					goto(line_jump)
				M.normaldoorcontrol = 0
			if(!M.id || M.id == "")
				M.id = input(user, "Please select an ID for the button", "Buildmode", "")
				if(!M.id || M.id == "")
					goto(line_jump)
			if(P.id_tag && P.id_tag != 1 && alert(user, "Warning: This will unlink something else from the door. Continue?", "Buildmode", "Yes", "No") == "No")
				goto(line_jump)
			P.id_tag = M.id

	line_jump // For the goto
	clear_lines()

	if(istype(link_obj, /obj/machinery/door_control))
		var/obj/machinery/door_control/M = link_obj
		for(var/obj/machinery/door/airlock/P in GLOB.airlocks)
			if(P.id_tag == M.id)
				form_connection(M, P, M.normaldoorcontrol)
		for(var/obj/machinery/door/poddoor/P in GLOB.airlocks)
			if(P.id_tag == M.id)
				form_connection(M, P, !M.normaldoorcontrol)
