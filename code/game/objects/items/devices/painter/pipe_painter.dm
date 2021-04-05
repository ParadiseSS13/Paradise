/obj/item/painter/pipe
	name = "pipe painter"
	icon_state = "pipe_painter"
	var/static/list/blacklisted_pipes = list(/obj/machinery/atmospherics/pipe/simple/heat_exchanging, /obj/machinery/atmospherics/pipe/simple/insulated)
	var/static/list/modes = list()
	var/chosen_colour = null

/obj/item/painter/pipe/Initialize(mapload)
	. = ..()
	if(!length(modes))
		for(var/C in GLOB.pipe_colors)
			modes += "[C]"
	chosen_colour = pick(modes)

/obj/item/painter/pipe/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is in [chosen_colour] mode.</span>"

/obj/item/painter/pipe/attack_self(mob/user)
	chosen_colour = input("Which colour do you want to use?", null, chosen_colour) in modes

/obj/item/painter/pipe/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target, /obj/machinery/atmospherics/pipe) || !proximity)
		return
	var/obj/machinery/atmospherics/pipe/P = target

	if(is_type_in_list(P, blacklisted_pipes))
		return

	if(P.pipe_color == GLOB.pipe_colors[chosen_colour])
		to_chat(user, "<span class='notice'>This pipe is aready painted [chosen_colour]!</span>")
		return

	var/turf/T = get_turf(P)
	if(P.level < 2 && T.level == 1 && T.intact)
		to_chat(user, "<span class='warning'>You must remove the plating first.</span>")
		return

	playsound(loc, usesound, 30, TRUE)
	P.change_color(GLOB.pipe_colors[chosen_colour])
