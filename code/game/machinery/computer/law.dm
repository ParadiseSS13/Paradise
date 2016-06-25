//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/aiupload
	var/mob/living/silicon/ai/current = null
	var/opened = 0

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
			return

		opened = !opened
		if(opened)
			to_chat(usr, "\blue The access panel is now open.")
		else
			to_chat(usr, "\blue The access panel is now closed.")
		return


	attackby(obj/item/weapon/O as obj, mob/user as mob, params)
		if (user.z > 6)
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
			return
		if(istype(O, /obj/item/weapon/aiModule))
			var/datum/game_mode/nations/mode = get_nations_mode()
			if(!mode)
				var/obj/item/weapon/aiModule/M = O
				M.install(src)
			else
				if(mode.kickoff)
					to_chat(user, "<span class='warning'>You have been locked out from modifying the AI's laws!</span>")
		else
			..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = select_active_ai(user)

		if (!src.current)
			to_chat(usr, "No active AIs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return

	attack_ghost(user as mob)
		return 1

/obj/machinery/computer/borgupload
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/weapon/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob, params)
		if(istype(module, /obj/item/weapon/aiModule))
			var/datum/game_mode/nations/mode = get_nations_mode()
			if(!mode)
				module.install(src)
			else
				if(mode.kickoff)
					to_chat(user, "<span class='warning'>You have been locked out from modifying the borg's laws!</span>")
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = freeborg()

		if (!src.current)
			to_chat(usr, "No free cyborgs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return

	attack_ghost(user as mob)
		return 1
