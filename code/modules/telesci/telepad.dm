///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency

/obj/machinery/telepad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telesci_pad(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/telepad/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telesci_pad(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/ore/bluespace_crystal/artificial(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/telepad/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E

/obj/machinery/telepad/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "pad-idle", I))
		return

	if(panel_open)
		if(istype(I, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = I
			M.buffer = src
			to_chat(user, "<span class = 'caution'>You save the data in the [I.name]'s buffer.</span>")

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)


//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0
/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src, W.usesound, 50, 1)
		if(anchored)
			anchored = 0
			to_chat(user, "<span class = 'caution'> The [src] can now be moved.</span>")
		else if(!anchored)
			anchored = 1
			to_chat(user, "<span class = 'caution'> The [src] is now secured.</span>")
	if(istype(W, /obj/item/weapon/screwdriver))
		if(stage == 0)
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class = 'caution'> You unscrew the telepad's tracking beacon.</span>")
			stage = 1
		else if(stage == 1)
			playsound(src, W.usesound, 50, 1)
			to_chat(user, "<span class = 'caution'> You screw in the telepad's tracking beacon.</span>")
			stage = 0
	if(istype(W, /obj/item/weapon/weldingtool) && stage == 1)
		playsound(src, W.usesound, 50, 1)
		to_chat(user, "<span class = 'caution'> You disassemble the telepad.</span>")
		new /obj/item/stack/sheet/metal(get_turf(src))
		new /obj/item/stack/sheet/glass(get_turf(src))
		qdel(src)

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=3"

/obj/item/device/telepad_beacon/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class = 'caution'> Locked In</span>")
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "A device used to teleport crates and closets to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	item_state = "rcd"
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 5
	toolspeed = 1
	usesound = 'sound/machines/click.ogg'
	var/obj/item/weapon/stock_parts/cell/high/rcell = null
	var/obj/machinery/pad = null
	var/mode = 0
	var/rand_x = 0
	var/rand_y = 0
	var/emagged = 0
	var/teleporting = 0
	var/chargecost = 1500

/obj/item/weapon/rcs/New()
	..()
	rcell = new(src)


/obj/item/weapon/rcs/examine(mob/user)
	..(user)
	to_chat(user, "There are [round(rcell.charge/chargecost)] charge\s left.")

/obj/item/weapon/rcs/Destroy()
	QDEL_NULL(rcell)
	return ..()

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		if(mode == 0)
			mode = 1
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			to_chat(user, "<span class = 'caution'> The telepad locator has become uncalibrated.</span>")
		else
			mode = 0
			playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
			to_chat(user, "<span class = 'caution'> You calibrate the telepad locator.</span>")

/obj/item/weapon/rcs/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		to_chat(user, "<span class = 'caution'> You emag the RCS. Activate it to toggle between modes.</span>")
		return
