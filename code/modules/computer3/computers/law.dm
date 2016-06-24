

/obj/machinery/computer3/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_state = "frame-rnd"
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
			to_chat(usr, "\blue The access panel is now open.")
		else
			to_chat(usr, "\blue The access panel is now closed.")
		return


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob, params)
		if (user.z > 6)
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the station!")
			return
		if(istype(module, /obj/item/weapon/aiModule))
			module.install(src)
		else
			return ..()


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



/obj/machinery/computer3/borgupload
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_state = "frame-rnd"
	var/mob/living/silicon/robot/current = null


	attackby(obj/item/weapon/aiModule/module as obj, mob/user as mob, params)
		if(istype(module, /obj/item/weapon/aiModule))
			module.install(src)
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
