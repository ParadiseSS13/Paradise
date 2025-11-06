/// Yes, this is a pipe painter subtype.
/datum/painter/pipe/window
	module_name = "window painter"
	module_state = "window_painter"
	var/static/list/paintable_windows = list(
			/obj/structure/window/reinforced,
			/obj/structure/window/basic,
			/obj/structure/window/full/reinforced,
			/obj/structure/window/full/basic,
			/obj/machinery/door/window)
	var/static/list/polarized_windows = list(
			/obj/structure/window/reinforced/polarized,
			/obj/structure/window/full/reinforced/polarized,
			/obj/machinery/door/window
	)

/datum/painter/pipe/window/paint_atom(atom/target, mob/user)
	if(!is_type_in_list(target, paintable_windows))
		return
	var/obj/structure/window/W = target

	if(is_type_in_list(target, polarized_windows))
		if((W.opacity && W.old_color == GLOB.pipe_icon_manager.pipe_colors[paint_setting]) || (!W.opacity && W.color == GLOB.pipe_icon_manager.pipe_colors[paint_setting]))
			to_chat(user, "<span class='notice'>This window is aready painted [paint_setting]!</span>")
			return
		if(!W.opacity)
			W.color = GLOB.pipe_icon_manager.pipe_colors[paint_setting]
		W.old_color = GLOB.pipe_icon_manager.pipe_colors[paint_setting]
		return TRUE

	if(W.color == GLOB.pipe_icon_manager.pipe_colors[paint_setting])
		to_chat(user, "<span class='notice'>This window is aready painted [paint_setting]!</span>")
		return

	W.color = GLOB.pipe_icon_manager.pipe_colors[paint_setting]
	return TRUE
