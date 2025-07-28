// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon_state = "mflash1"
	max_integrity = 250
	integrity_failure = 100
	damage_deflection = 10
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = FALSE
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 10 SECONDS //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = TRUE
	var/datum/proximity_monitor/proximity_monitor

/obj/machinery/flasher/Initialize(mapload)
	. = ..()
	update_icon()

/// Portable version of the flasher. Only flashes when anchored
/obj/machinery/flasher/portable
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 4
	anchored = FALSE
	base_state = "pflash"
	density = TRUE

/obj/machinery/flasher/portable/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, range)

/obj/machinery/flasher/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		set_light(0)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()

/obj/machinery/flasher/update_icon_state()
	. = ..()
	if((stat & NOPOWER) || !anchored)
		icon_state = "[base_state]1-p"
	else
		icon_state = "[base_state]1"

/obj/machinery/flasher/update_overlays()
	. = ..()
	underlays.Cut()
	cut_overlays()
	if(stat & NOPOWER)
		return

	if(anchored)
		. += "[base_state]-s"
		underlays += emissive_appearance(icon, "[base_state]_lightmask")


//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if(anchored)
		return flash()

/obj/machinery/flasher/attack_ghost(mob/user)
	if(anchored && user.can_advanced_admin_interact())
		return flash()

/obj/machinery/flasher/proc/flash()
	if(!has_power())
		return

	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	playsound(loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	set_light(2, 1, COLOR_WHITE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, set_light), 0), 2)
	last_flash = world.time
	use_power(1000)

	for(var/mob/living/L in viewers(src, null))
		if(get_dist(src, L) > range)
			continue

		if(L.flash_eyes(affect_silicon = 1))
			L.Weaken(strength)

/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM)
	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	if(iscarbon(AM))
		var/mob/living/carbon/M = AM
		if((M.m_intent != MOVE_INTENT_WALK) && (anchored))
			flash()

//Don't want to render prison breaks impossible
/obj/machinery/flasher/portable/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	disable = !disable
	if(disable)
		user.visible_message("<span class='warning'>[user] has disconnected [src]'s flashbulb!</span>", "<span class='warning'>You disconnect [src]'s flashbulb!</span>")
	if(!disable)
		user.visible_message("<span class='warning'>[user] has connected [src]'s flashbulb!</span>", "<span class='warning'>You connect [src]'s flashbulb!</span>")

/obj/machinery/flasher/portable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE
	update_icon()

// Flasher button
/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = FALSE
	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 4

/obj/machinery/flasher_button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = TRUE
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in SSmachines.get_by_type(/obj/machinery/flasher))
		if(M.id == id)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = FALSE
