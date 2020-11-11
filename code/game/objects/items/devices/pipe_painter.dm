/obj/item/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/device.dmi'
	icon_state = "pipe_painter"
	item_state = "pipe_painter"
	usesound = 'sound/effects/spray2.ogg'
	var/list/modes
	var/mode

/obj/item/pipe_painter/New()
	..()
	modes = new()
	for(var/C in GLOB.pipe_colors)
		modes += "[C]"
	mode = pick(modes)

/obj/item/pipe_painter/afterattack(atom/A, mob/user as mob)
	if(!istype(A,/obj/machinery/atmospherics/pipe) || istype(A,/obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(A,/obj/machinery/atmospherics/pipe/simple/insulated) || !in_range(user, A))
		return
	var/obj/machinery/atmospherics/pipe/P = A

	if(P.pipe_color == "[GLOB.pipe_colors[mode]]")
		to_chat(user, "<span class='notice'>This pipe is aready painted [mode]!</span>")
		return

	var/turf/T = P.loc
	if(P.level < 2 && T.level==1 && isturf(T) && T.intact)
		to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	P.change_color(GLOB.pipe_colors[mode])


/obj/item/pipe_painter/attack_self(mob/user as mob)
	mode = input("Which colour do you want to use?", "Pipe Painter", mode) in modes

/obj/item/pipe_painter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is in [mode] mode.</span>"
