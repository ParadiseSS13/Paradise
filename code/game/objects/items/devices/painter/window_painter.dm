/datum/painter/pipe/window // Yes, this is a pipe painter subtype.
	module_name = "window painter"
	module_state = "window_painter"
	var/static/list/paintable_windows = list(
			/obj/structure/window/reinforced,
			/obj/structure/window/basic,
			/obj/structure/window/full/reinforced,
			/obj/structure/window/full/basic,
			/obj/machinery/door/window)

/datum/painter/pipe/window/paint_atom(atom/target, mob/user)
	if(!is_type_in_list(target, paintable_windows))
		return
	var/obj/structure/window/W = target

	if(W.color == GLOB.pipe_colors[paint_setting])
		to_chat(user, "<span class='notice'>This window is aready painted [paint_setting]!</span>")
		return

	W.color = GLOB.pipe_colors[paint_setting]
	return TRUE
