/obj/machinery/computer/HONKputer
	name = "\improper HONKputer Mark I"
	desc = "A yellow computer used in case of critically low levels of HONK."
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "honkputer"
	icon_keyboard = "key_honk"
	icon_screen = "honkcomms"
	light_color = LIGHT_COLOR_PINK
	req_access = list(ACCESS_CLOWN)
	check_access = TRUE
	no_gateway_use = TRUE
	circuit = /obj/item/circuitboard/HONKputer
	var/authenticated = 0
	var/message_cooldown = 0

/obj/machinery/computer/HONKputer/attack_hand(var/mob/user as mob)
	if(..())
		return

	if(!ishuman(user))
		return

	if(message_cooldown)
		to_chat(usr, "Arrays recycling.  Please stand by.")
		return

	var/input = stripped_input(user, "Please choose a message to transmit to your HONKbrothers on the homeworld. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
	if(!input || !(user in view(1, src)) || message_cooldown)
		return
	HONK_announce(input, user)
	to_chat(user, "Message transmitted.")
	log_game("[key_name(user)] has sent a message to HONKplanet: [input]")
	message_cooldown = 1
	spawn(6000)//10 minute cooldown
		message_cooldown = 0

/obj/machinery/computer/HONKputer/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) && circuit)
		var/obj/item/screwdriver/S = I
		playsound(src.loc, S.usesound, 50, 1)
		if(do_after(user, 20 * S.toolspeed, target = src))
			var/obj/structure/computerframe/HONKputer/A = new /obj/structure/computerframe/HONKputer( src.loc )
			var/obj/item/circuitboard/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for(var/obj/C in src)
				C.loc = src.loc
			if(src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			qdel(src)
	else
		return ..()
