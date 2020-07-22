/obj/item/pipe_painter
	name = "pipe painter"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler1"
	item_state = "flight"
	var/list/modes
	var/mode

/obj/item/pipe_painter/New()
	..()
	modes = new()
	for(var/C in pipe_colors)
		modes += "[C]"
	mode = pick(modes)

/obj/item/pipe_painter/afterattack(atom/A, mob/user as mob)
	if(!istype(A,/obj/machinery/atmospherics/pipe) || istype(A,/obj/machinery/atmospherics/pipe/simple/heat_exchanging) || istype(A,/obj/machinery/atmospherics/pipe/simple/insulated) || !in_range(user, A))
		return
	var/obj/machinery/atmospherics/pipe/P = A

	var/turf/T = P.loc
	if(P.level < 2 && T.level==1 && isturf(T) && T.intact)
		to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return

	P.change_color(pipe_colors[mode])

/obj/item/pipe_painter/attack_self(mob/user as mob)
	mode = input("Which colour do you want to use?", "Pipe Painter", mode) in modes

/obj/item/pipe_painter/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is in [mode] mode.</span>"
