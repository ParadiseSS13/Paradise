#define cooldown_delay = 60 SECONDS

/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	var/mob/living/silicon/ai/current = null
	var/opened = FALSE
	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2
	var/cooldown = 0

//For emagging the console
/obj/machinery/computer/aiupload/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message("<span class='warning'>Sparks fly out of [src]!</span>",
								"<span class='notice'>You emag [src], scrambling the computer's law encoding system.</span>")
		playsound(loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		do_sparks(5, TRUE, src)
		circuit = /obj/item/circuitboard/aiupload_broken

// What the fuck even is this
/obj/machinery/computer/aiupload/verb/AccessInternals()
	set category = "Object"
	set name = "Access Computer's Internals"
	set src in oview(1)
	if(get_dist(src, usr) > 1 || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || usr.stat || issilicon(usr))
		return

	opened = !opened
	if(opened)
		to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
	else
		to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
	return


/obj/machinery/computer/aiupload/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/aiModule))
		if(!current)//no AI selected
			to_chat(user, "<span class='danger'>No AI selected. Please chose a target before proceeding with upload.")
			return
		var/turf/T = get_turf(current)
		if(!atoms_share_level(T, src))
			to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
			return
		if(!emagged) //non-emag law change
			var/obj/item/aiModule/M = O
			M.install(src)
			return
		else
			if(world.time < cooldown)
				to_chat(user, "The program seems to have frozen. It will need some time to process.")
				return
			do_sparks(5, TRUE, src)
			var/foundlaws = 0
			var/checked = FALSE
			for(var/datum/ai_law/law in current.laws.all_laws())
				if(law in current.laws.inherent_laws)
					foundlaws++
				if(checked)
					continue
				if(!length(current.laws.ion_laws))
					checked = TRUE
					if(prob(20))  // 20% chance to generate an ion law if none exists
						current.add_ion_law(generate_ion_law())
						cooldown = world.time + cooldown_delay
						return
				else if(law in current.laws.ion_laws) //10% chance to overwrite a current ion
					checked = TRUE
					if(prob(10))
						current.clear_ion_laws()
						current.add_ion_law()
						cooldown = world.time + cooldown_delay
						return
			var/lawposition = rand(1, foundlaws)
			if(foundlaws) //as long as it finds a law to change
				current.laws.inherent_laws[lawposition].law = new/datum/ai_law/inherent(generate_ion_law()).law
				log_and_message_admins("has given [current] the emag'd inherent law: [current.laws.inherent_laws[lawposition].law].")
				current.show_laws()
				current.throw_alert("newlaw", /obj/screen/alert/newlaw)
				cooldown = world.time + cooldown_delay
				for(var/i in 1 to length(current.connected_robots)) // push alert to the AI's borgs
					current.connected_robots[i].cmd_show_laws()
					current.connected_robots[i].throw_alert("newlaw", /obj/screen/alert/newlaw)
			return
		return
	return ..()


/obj/machinery/computer/aiupload/proc/add_emag_law()

/obj/machinery/computer/aiupload/attack_hand(mob/user as mob)
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

// Why is this not a subtype
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


/obj/machinery/computer/borgupload/attack_hand(mob/user as mob)
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
