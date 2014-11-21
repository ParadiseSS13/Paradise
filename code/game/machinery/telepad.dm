/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 50
	var/efficiency

/obj/machinery/telepad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telesci_pad(src)
	component_parts += new /obj/item/bluespace_crystal/artificial(src)
	component_parts += new /obj/item/bluespace_crystal/artificial(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(src)
	component_parts += new /obj/item/stack/cable_coil(src, 1)
	RefreshParts()	

/obj/machinery/telepad/RefreshParts()
	var/E
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E
	
/obj/machinery/telepad/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "pad-idle", I))
		return

	if(panel_open)
		if(istype(I, /obj/item/device/multitool))
			var/obj/item/device/multitool/M = I
			M.buffer = src
			user << "<span class='caution'>You save the data in the [I.name]'s buffer.</span>"

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 50
	var/stage = 0	
	
/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(anchored)
			anchored = 0
			user << "<span class='caution'>The [src] can now be moved.</span>"
		else if(!anchored)
			anchored = 1
			user << "<span class='caution'>The [src] is now secured.</span>"
	if(istype(W, /obj/item/weapon/screwdriver))
		if(stage == 0)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='caution'>You unscrew the telepad's tracking beacon.</span>"
			stage = 1
		else if(stage == 1)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			user << "<span class='caution'>You screw in the telepad's tracking beacon.</span>"
			stage = 0
	if(istype(W, /obj/item/weapon/weldingtool) && stage == 1)
		playsound(src, 'sound/items/Welder.ogg', 50, 1)
		user << "<span class='caution'>You disassemble the telepad.</span>"
		new /obj/item/stack/sheet/metal(get_turf(src))
		new /obj/item/stack/sheet/glass(get_turf(src))
		qdel(src)	