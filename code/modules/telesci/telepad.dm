///SCI TELEPAD///
/obj/machinery/telepad
	name = "telepad"
	desc = "A bluespace telepad used for teleporting objects to and from a location."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	var/efficiency

/obj/machinery/telepad/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/telesci_pad(null)
	component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/telepad/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/telesci_pad(null)
	//component_parts += new /obj/item/stack/ore/bluespace_crystal/artificial(null, 2)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/telepad/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	efficiency = E

/obj/machinery/telepad/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/telepad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "pad-idle-o", "pad-idle", I)

/obj/machinery/telepad/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

/obj/machinery/telepad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0

/obj/machinery/telepad_cargo/crowbar_act(mob/living/user, obj/item/I)
	if(stage != 1)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/telepad_cargo/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class = 'caution'> You [stage ? "screw in" : "unscrew"] the telepad's tracking beacon.</span>")
	stage = !stage

/obj/machinery/telepad_cargo/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)


/obj/machinery/telepad_cargo/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc)
		new /obj/item/stack/sheet/glass(loc)
	..()


///TELEPAD CALLER///
/obj/item/telepad_beacon
	name = "telepad beacon"
	desc = "Use to warp in a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = "bluespace=3"

/obj/item/telepad_beacon/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class = 'caution'> Locked In</span>")
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return
