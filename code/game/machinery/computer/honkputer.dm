/obj/machinery/computer/HONKputer
	name = "\improper HONKputer Mark I"
	desc = "A yellow computer used in case of critically low levels of HONK."
	icon = 'icons/obj/machines/HONKputer.dmi'
	icon_state = "honkputer"
	icon_keyboard = "key_honk"
	icon_screen = "honkcomms"
	light_color = LIGHT_COLOR_PINK
	req_access = list(access_clown)
	circuit = /obj/item/circuitboard/HONKputer
	var/authenticated = 0
	var/message_cooldown = 0
	var/state = STATE_DEFAULT
	var/const/STATE_DEFAULT = 1

/obj/machinery/computer/HONKputer/process()
	if(..())
		src.updateDialog()

/obj/machinery/computer/HONKputer/Topic(href, href_list)
	if(..())
		return 1
	if(is_away_level(src.z))
		to_chat(usr, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	switch(href_list["operation"])
		// main interface
		if("main")
			src.state = STATE_DEFAULT
		if("login")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_hand()
			if(istype(I, /obj/item/pda))
				var/obj/item/pda/pda = I
				I = pda.id
			if(I && istype(I))
				if(src.check_access(I) || src.emagged==1)
					authenticated = 1
		if("logout")
			authenticated = 0

		if("MessageHonkplanet")
			if(src.authenticated==1)
				if(message_cooldown)
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to your HONKbrothers on the homeworld. Transmission does not guarantee a response.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)))
					return
				HONK_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				log_game("[key_name(usr)] has made a HONKplanet announcement: [input]")
				message_cooldown = 1
				spawn(6000)//10 minute cooldown
					message_cooldown = 0

	src.updateUsrDialog()

/obj/machinery/computer/HONKputer/emag_act(user as mob)
	if(!emagged)
		src.emagged = 1
		to_chat(user, "You scramble the login circuits, allowing anyone to use the console!")

/obj/machinery/computer/HONKputer/attack_hand(var/mob/user as mob)
	if(..())
		return
	if(is_away_level(src.z))
		to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
		return

	user.set_machine(src)
	var/dat = "<head><title>HONKputer Interface</title></head><body>"

	if(istype(user, /mob/living/silicon))
		to_chat(user, "This console is not networked to the rest of the grid.")
		return

	switch(src.state)
		if(STATE_DEFAULT)
			if(src.authenticated)
				dat += "<BR>\[ <A HREF='?src=[UID()];operation=logout'>Log Out</A> \]"
				dat += "<BR>\[ <A HREF='?src=[UID()];operation=MessageHonkplanet'>Send an emergency message to Honkplanet</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=[UID()];operation=login'>Log In</A> \]"


	dat += "<BR>\[ [(src.state != STATE_DEFAULT) ? "<A HREF='?src=[UID()];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=[user.UID()];mach_close=honkputer'>Close</A> \]"
	user << browse(dat, "window=honkputer;size=400x500")
	onclose(user, "honkputer")


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
		src.attack_hand(user)
	return
