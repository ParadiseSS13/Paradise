/datum/painter/airlock
	module_name = "airlock painter"
	module_desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on a completed airlock to change its paintjob."
	module_state = "airlock_painter"

	// All the different paint jobs that an airlock painter can apply.
	// If the airlock you're using it on is glass, the new paint job will also be glass
	var/list/available_paint_jobs = list(
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Command" = /obj/machinery/door/airlock/command,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Virology" = /obj/machinery/door/airlock/virology,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Public" = /obj/machinery/door/airlock/public,
		"Research" = /obj/machinery/door/airlock/research,
		"Science" = /obj/machinery/door/airlock/science,
		"Security" = /obj/machinery/door/airlock/security,
		"Standard" = /obj/machinery/door/airlock)

/datum/painter/airlock/pick_color(mob/user)
	var/choice = tgui_input_list(user, "Please select a paintjob.", "Airlock painter", available_paint_jobs)
	if(!choice)
		return
	paint_setting = choice
	to_chat(user, "<span class='notice'>The [paint_setting] paint setting has been selected.</span>")

/datum/painter/airlock/paint_atom(atom/target, mob/user)
	if(!istype(target, /obj/machinery/door/airlock))
		return
	var/obj/machinery/door/airlock/A = target

	if(!paint_setting)
		to_chat(user, "<span class='warning'>You need to select a paintjob first.</span>")
		return

	if(!A.paintable)
		to_chat(user, "<span class='warning'>This type of airlock cannot be painted.</span>")
		return

	var/obj/machinery/door/airlock/airlock = available_paint_jobs["[paint_setting]"] // get the airlock type path associated with the airlock name the user just chose
	var/obj/structure/door_assembly/assembly = initial(airlock.assemblytype)

	if(A.assemblytype == assembly)
		to_chat(user, "<span class='notice'>This airlock is already painted with the \"[paint_setting]\" color scheme!</span>")
		return

	if(A.airlock_material == "glass" && initial(assembly.noglass)) // prevents painting glass airlocks with a paint job that doesn't have a glass version, such as the freezer
		to_chat(user, "<span class='warning'>This paint job can only be applied to non-glass airlocks.</span>")
		return

	if(do_after(user, 2 SECONDS, FALSE, A))
		// applies the user-chosen airlock's icon, overlays and assemblytype to the target airlock
		A.icon = initial(airlock.icon)
		A.overlays_file = initial(airlock.overlays_file)
		A.assemblytype = initial(airlock.assemblytype)
		A.update_icon()
		return TRUE
