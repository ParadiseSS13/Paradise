/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	var/mob/living/silicon/ai/current = null
	var/uses = 0

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2


/obj/machinery/computer/aiupload/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/aiModule))
		if(!current)//no AI selected
			to_chat(user, "<span class='danger'>No AI selected. Please chose a target before proceeding with upload.")
			return
		var/turf/T = get_turf(current)
		if(!atoms_share_level(T, src))
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
			return
		var/obj/item/aiModule/M = O
		M.install(src)
		return
	return ..()


/obj/machinery/computer/aiupload/attack_hand(var/mob/user as mob)
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	src.current = select_active_ai(user)

	if(!src.current)
		to_chat(usr, "No active AIs detected.")
	else
		to_chat(usr, "[src.current.name] selected for law changes.")
	return

/obj/machinery/computer/aiupload/attack_ghost(user as mob)
	return 1

///obj/machinery/computer/aiupload/deconstruct()
//	M.circuit.uses = uses
//	..()


/obj/machinery/computer/borgupload
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null


/obj/machinery/computer/borgupload/attackby(obj/item/aiModule/module as obj, mob/user as mob, params)
	if(istype(module, /obj/item/aiModule))
		if(!current)//no borg selected
			to_chat(user, "<span class='danger'>No borg selected. Please chose a target before proceeding with upload.")
			return
		var/turf/T = get_turf(current)
		if(!atoms_share_level(T, src))
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
			return
		module.install(src)
		return
	return ..()


/obj/machinery/computer/borgupload/attack_hand(var/mob/user as mob)
	if(src.stat & NOPOWER)
		to_chat(usr, "The upload computer has no power!")
		return
	if(src.stat & BROKEN)
		to_chat(usr, "The upload computer is broken!")
		return

	src.current = freeborg()

	if(!src.current)
		to_chat(usr, "No free cyborgs detected.")
	else
		to_chat(usr, "[src.current.name] selected for law changes.")
	return

/obj/machinery/computer/borgupload/attack_ghost(user as mob)
		return 1
