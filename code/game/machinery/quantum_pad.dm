#define QPAD_ANIM_WINDUP 0.8 SECONDS
#define QPAD_ANIM_COOLDOWN 0.7 SECONDS

/obj/machinery/quantumpad
	name = "quantum pad"
	desc = "A bluespace quantum-linked telepad used for teleporting objects to other quantum pads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	anchored = TRUE
	idle_power_consumption = 200
	active_power_consumption = 5000
	var/teleport_cooldown = 400 //30 seconds base due to base parts
	var/teleport_speed = 50
	var/last_teleport //to handle the cooldown
	// Is the pad currently doing a teleportation?
	var/teleporting = FALSE
	// Power consumption multiplier.
	var/power_efficiency = 1
	// The pad this quantum pad will teleport to.
	var/obj/machinery/quantumpad/linked_pad = null
	// Pre-linked pad target, for mapped-in quantum pads.
	var/preset_target = null

/obj/machinery/quantumpad/Initialize(mapload)
	. = ..()
	PopulateParts()

/obj/machinery/quantumpad/proc/PopulateParts()
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

/obj/machinery/quantumpad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/quantumpad/multitool_act(mob/user, obj/item/I)
	if(!preset_target)
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
			to_chat(user, "<span class='notice'>You link [src] to the one in [I]'s buffer.</span>")
	else
		to_chat(user, "<span class='notice'>[src]'s target cannot be modified!</span>")

/obj/machinery/quantumpad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "pad-idle-o", "qpad-idle", I)

/obj/machinery/quantumpad/proc/check_usable(mob/user)
	. = FALSE
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
	return TRUE

/obj/machinery/quantumpad/attack_hand(mob/user)
	if(is_ai(user))
		return
	if(!check_usable(user))
		return
	add_fingerprint(user)
	doteleport(user)

/obj/machinery/quantumpad/attack_ai(mob/user)
	if(isrobot(user))
		return attack_hand(user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		return
	if(AI.eyeobj.loc != loc)
		AI.eyeobj.set_loc(get_turf(loc))
		return
	if(!check_usable(user))
		return
	var/turf/T = get_turf(linked_pad)
	if(GLOB.cameranet && GLOB.cameranet.check_turf_vis(T))
		AI.eyeobj.set_loc(T)
	else
		to_chat(user, "<span class='warning'>Linked pad is not on or near any active cameras on the station.</span>")

/obj/machinery/quantumpad/attack_ghost(mob/dead/observer/ghost)
	if(!QDELETED(linked_pad))
		ghost.forceMove(get_turf(linked_pad))

/obj/machinery/quantumpad/proc/precharge()
	layer = HIGH_OBJ_LAYER
	linked_pad.layer = HIGH_OBJ_LAYER
	flick("qpad-beam", src)
	flick("qpad-beam", linked_pad)
	addtimer(CALLBACK(src, PROC_REF(finish_teleport)), max((teleport_speed + QPAD_ANIM_COOLDOWN), 1))

/obj/machinery/quantumpad/proc/finish_teleport()
	if(!teleporting)
		layer = BELOW_OBJ_LAYER
		linked_pad.layer = BELOW_OBJ_LAYER

/obj/machinery/quantumpad/proc/doteleport(mob/user)
	if(linked_pad)
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
		teleporting = TRUE
		src.icon_state = "qpad-charge"
		linked_pad.icon_state = "qpad-charge"
		addtimer(CALLBACK(src, PROC_REF(precharge)), max((teleport_speed - QPAD_ANIM_WINDUP), 1))
		addtimer(CALLBACK(src, PROC_REF(process_teleport)), teleport_speed)

/obj/machinery/quantumpad/proc/process_teleport(mob/user)
	if(!src || QDELETED(src))
		teleporting = FALSE
		return
	if(stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] is unpowered!</span>")
		teleporting = FALSE
		return
	if(!linked_pad || QDELETED(linked_pad) || linked_pad.stat & NOPOWER)
		to_chat(user, "<span class='warning'>Linked pad is not responding to ping. Teleport aborted.</span>")
		teleporting = FALSE
		return

	teleporting = FALSE
	last_teleport = world.time

	// use a lot of power
	use_power(10000 / power_efficiency)
	playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, TRUE)
	playsound(get_turf(linked_pad), 'sound/weapons/emitter2.ogg', 25, TRUE)
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
		tele_success = do_teleport(ROI, get_turf(linked_pad), do_effect = FALSE)
	if(!tele_success)
		to_chat(user, "<span class='warning'>Teleport failed due to bluespace interference.</span>")
	src.icon_state = "qpad-idle"
	linked_pad.icon_state = "qpad-idle"

#undef QPAD_ANIM_WINDUP
#undef QPAD_ANIM_COOLDOWN
