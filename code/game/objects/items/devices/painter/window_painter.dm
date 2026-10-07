/// Yes, this is a pipe painter subtype.
/datum/painter/window
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

/datum/painter/window/pick_color(mob/user)
	var/new_paint_setting = tgui_input_color(user,"Please select a paint color.","Window Painter Color")
	if(!new_paint_setting)
		return
	paint_setting = new_paint_setting

/datum/painter/window/paint_atom(atom/target, mob/user)
	if(!is_type_in_list(target, paintable_windows))
		return
	var/obj/structure/window/W = target

	if(is_type_in_list(target, polarized_windows))
		if(!W.opacity)
			W.color = paint_setting
		W.old_color = paint_setting
		return TRUE
		
	W.color = paint_setting
	return TRUE
