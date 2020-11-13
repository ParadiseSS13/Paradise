/obj/item/pipe_painter/window_painter
	name = "window painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "window_painter"
	item_state = "window_painter"

/obj/item/pipe_painter/window_painter/afterattack(atom/A, mob/user as mob)
	if(!(istype(A,/obj/structure/window/reinforced) || istype(A,/obj/structure/window/basic) || istype(A,/obj/machinery/door/window) || istype(A,/obj/structure/window/full/reinforced) || istype(A,/obj/structure/window/full/basic)) || !in_range(user, A))
		return
	var/obj/structure/window/W = A

	if(W.color == GLOB.pipe_colors[mode])
		to_chat(user, "<span class='notice'>This window is aready painted [mode]!</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	W.color = GLOB.pipe_colors[mode]
