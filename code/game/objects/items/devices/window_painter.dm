/obj/item/pipe_painter/window_painter
	name = "window painter"
	icon_state = "window_painter"

	var/list/paintable_windows = list(
			/obj/structure/window/reinforced,
			/obj/structure/window/basic,
			/obj/structure/window/full/reinforced,
			/obj/structure/window/full/basic,
			/obj/machinery/door/window)

/obj/item/pipe_painter/window_painter/afterattack(atom/A, mob/user as mob)
	if(!is_type_in_list(A, paintable_windows) || !in_range(user, A))
		return
	var/obj/structure/window/W = A

	if(W.color == GLOB.pipe_colors[mode])
		to_chat(user, "<span class='notice'>This window is aready painted [mode]!</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	W.color = GLOB.pipe_colors[mode]
