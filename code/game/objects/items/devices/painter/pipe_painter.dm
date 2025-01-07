/datum/painter/pipe
	module_name = "pipe painter"
	module_state = "pipe_painter"
	var/static/list/blacklisted_pipes = list(/obj/machinery/atmospherics/pipe/simple/heat_exchanging)
	var/static/list/modes = list()

/datum/painter/pipe/New()
	..()
	if(!length(modes))
		for(var/C in GLOB.pipe_icon_manager.pipe_colors)
			modes += "[C]"
	paint_setting = pick(modes)

/datum/painter/pipe/pick_color(mob/user)
	var/new_paint_setting = tgui_input_list(user, "Which color do you want to use?", "Pick color", modes)
	if(!new_paint_setting)
		return
	paint_setting = new_paint_setting

/datum/painter/pipe/paint_atom(atom/target, mob/user)
	if(!istype(target, /obj/machinery/atmospherics/pipe))
		return
	var/obj/machinery/atmospherics/pipe/P = target

	if(is_type_in_list(P, blacklisted_pipes))
		return

	if(P.pipe_color == GLOB.pipe_icon_manager.pipe_colors[paint_setting])
		to_chat(user, "<span class='notice'>This pipe is aready painted [paint_setting]!</span>")
		return

	var/turf/T = get_turf(P)
	if(P.level < 2 && T.level == 1 && T.intact && !T.transparent_floor)
		to_chat(user, "<span class='warning'>You must remove the flooring first.</span>")
		return

	P.change_color(GLOB.pipe_icon_manager.pipe_colors[paint_setting])
	return TRUE
