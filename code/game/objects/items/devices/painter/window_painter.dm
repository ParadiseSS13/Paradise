/obj/item/painter/pipe/window // Yes, this is a pipe painter subtype.
	name = "window painter"
	icon_state = "window_painter"
	item_state = "window_painter"
	var/static/list/paintable_windows = list(
			/obj/structure/window/reinforced,
			/obj/structure/window/basic,
			/obj/structure/window/full/reinforced,
			/obj/structure/window/full/basic,
			/obj/machinery/door/window)

/obj/item/painter/pipe/window/afterattack(atom/A, mob/user, proximity, params)
	if(!is_type_in_list(A, paintable_windows) || !proximity)
		return
	var/obj/structure/window/W = A

	if(W.color == GLOB.pipe_colors[chosen_colour])
		to_chat(user, "<span class='notice'>This window is aready painted [chosen_colour]!</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	W.color = GLOB.pipe_colors[chosen_colour]
