

/obj/machinery/computer3/aiupload
	name = "AI Upload"
	desc = "Used to upload laws to the AI."
	icon_state = "frame-rnd"
	circuit = "/obj/item/part/board/circuit/aiupload"
	var/mob/living/silicon/ai/current = null
	var/opened = 0


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(!Adjacent(usr) || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon) || !istype(usr, /mob/living))
			return

		opened = !opened
		if(opened)
			usr << "\blue The access panel is now open."
		else
			usr << "\blue The access panel is now closed."
		return


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob)
		if (user.z > 6)
			user << "\red <b>Unable to establish a connection</b>: \black You're too far away from the station!"
			return
		if(istype(module, /obj/item/weapon/aiModule))
			module.install(src)
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = select_active_ai(user)

		if (!src.current)
			usr << "No active AIs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return



/obj/machinery/computer3/borgupload
	name = "Cyborg Upload"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "frame-rnd"
	circuit = "/obj/item/part/board/circuit/borgupload"
	var/mob/living/silicon/robot/current = null


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob)
		if(istype(module, /obj/item/weapon/aiModule))
			module.install(src)
		else
			return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			usr << "The upload computer has no power!"
			return
		if(src.stat & BROKEN)
			usr << "The upload computer is broken!"
			return

		src.current = freeborg()

		if (!src.current)
			usr << "No free cyborgs detected."
		else
			usr << "[src.current.name] selected for law changes."
		return
