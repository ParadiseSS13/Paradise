/obj/machinery/quantumpad
	name = "quantum pad"
	desc = "A bluespace quantum-linked telepad used for teleporting objects to other quantum pads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	var/teleport_cooldown = 400 //30 seconds base due to base parts
	var/teleport_speed = 50
	var/last_teleport //to handle the cooldown
	var/teleporting = 0 //if it's in the process of teleporting
	var/power_efficiency = 1
	var/obj/machinery/quantumpad/linked_pad = null

/obj/machinery/quantumpad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/quantumpad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/quantumpad/Destroy()
	linked_pad = null
	return ..()

/obj/machinery/quantumpad/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	power_efficiency = E
	E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	teleport_speed = initial(teleport_speed)
	teleport_speed -= (E*10)
	teleport_cooldown = initial(teleport_cooldown)
	teleport_cooldown -= (E * 100)

/obj/machinery/quantumpad/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/quantumpad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/quantumpad/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(panel_open)
		M.set_multitool_buffer(user, src)
	else
		linked_pad = M.buffer
		to_chat(user, "<span class='notice'>You link the [src] to the one in the [I.name]'s buffer.</span>")

/obj/machinery/quantumpad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "pad-idle-o", "qpad-idle", I)

/obj/machinery/quantumpad/attack_hand(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>The panel must be closed before operating this machine!</span>")
		return

	if(!linked_pad || QDELETED(linked_pad))
		to_chat(user, "<span class='warning'>There is no linked pad!</span>")
		return

	if(world.time < last_teleport + teleport_cooldown)
		to_chat(user, "<span class='warning'>[src] is recharging power. Please wait [round((last_teleport + teleport_cooldown - world.time) / 10)] seconds.</span>")
		return

	if(teleporting)
		to_chat(user, "<span class='warning'>[src] is charging up. Please wait.</span>")
		return

	if(linked_pad.teleporting)
		to_chat(user, "<span class='warning'>Linked pad is busy. Please wait.</span>")
		return

	if(linked_pad.stat & NOPOWER)
		to_chat(user, "<span class='warning'>Linked pad is not responding to ping.</span>")
		return
	add_fingerprint(user)
	doteleport(user)

/obj/machinery/quantumpad/proc/sparks()
	do_sparks(5, 1, get_turf(src))

/obj/machinery/quantumpad/attack_ghost(mob/dead/observer/ghost)
	if(linked_pad)
		ghost.forceMove(get_turf(linked_pad))

/obj/machinery/quantumpad/proc/doteleport(mob/user)
	if(linked_pad)
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
		teleporting = 1

		spawn(teleport_speed)
			if(!src || QDELETED(src))
				teleporting = 0
				return
			if(stat & NOPOWER)
				to_chat(user, "<span class='warning'>[src] is unpowered!</span>")
				teleporting = 0
				return
			if(!linked_pad || QDELETED(linked_pad) || linked_pad.stat & NOPOWER)
				to_chat(user, "<span class='warning'>Linked pad is not responding to ping. Teleport aborted.</span>")
				teleporting = 0
				return

			teleporting = 0
			last_teleport = world.time

			// use a lot of power
			use_power(10000 / power_efficiency)
			sparks()
			linked_pad.sparks()

			flick("qpad-beam", src)
			playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			flick("qpad-beam", linked_pad)
			playsound(get_turf(linked_pad), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			var/tele_success = TRUE
			for(var/atom/movable/ROI in get_turf(src))
				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						if(L.buckled)
							// TP people on office chairs
							if(L.buckled.anchored)
								continue
						else
							continue
					else if(!isobserver(ROI))
						continue
				tele_success = do_teleport(ROI, get_turf(linked_pad))
			if(!tele_success)
				to_chat(user, "<span class='warning'>Teleport failed due to bluespace interference.</span>")
