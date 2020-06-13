/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"
	anchored = 0
	density = 1

	var/power_loss = 2
	var/input_power_multiplier = 1
	var/zap_cooldown = 100
	var/last_zap = 0
	var/datum/wires/tesla_coil/wires = null

/obj/machinery/power/tesla_coil/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/tesla_coil(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	wires = new(src)
	RefreshParts()

/obj/machinery/power/tesla_coil/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	input_power_multiplier = power_multiplier

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(exchange_parts(user, W))
		return

	else if(istype(W, /obj/item/assembly/signaler) && panel_open)
		wires.Interact(user)

	else
		return ..()

/obj/machinery/power/tesla_coil/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/tesla_coil/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/power/tesla_coil/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", I)

/obj/machinery/power/tesla_coil/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/power/tesla_coil/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(default_unfasten_wrench(user, I))
		if(!anchored)
			disconnect_from_network()
		else
			connect_to_network()

/obj/machinery/power/tesla_coil/tesla_act(var/power)
	if(anchored && !panel_open)
		being_shocked = 1
		//don't lose arc power when it's not connected to anything
		//please place tesla coils all around the station to maximize effectiveness
		var/power_produced = powernet ? power / power_loss : power
		add_avail(power_produced*input_power_multiplier)
		flick("coilhit", src)
		playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
		tesla_zap(src, 5, power_produced)
		addtimer(CALLBACK(src, .proc/reset_shocked), 10)
	else
		..()

/obj/machinery/power/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/coeff = (20 - ((input_power_multiplier - 1) * 3))
	coeff = max(coeff, 10)
	var/power = (powernet.avail/2)
	add_load(power)
	playsound(src.loc, 'sound/magic/lightningshock.ogg', 100, 1, extrarange = 5)
	tesla_zap(src, 10, power/(coeff/2))

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keep an area from being fried from Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = 0
	density = 1

/obj/machinery/power/grounding_rod/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grounding_rod(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/power/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(exchange_parts(user, W))
		return

/obj/machinery/power/grounding_rod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", I)

/obj/machinery/power/grounding_rod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/power/grounding_rod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/grounding_rod/tesla_act(var/power)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
	else
		..()
