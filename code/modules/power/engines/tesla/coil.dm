/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"
	anchored = FALSE
	density = TRUE

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
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
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	input_power_multiplier = (0.85 * (power_multiplier / 4)) //Max out at 85% efficency.

/obj/machinery/power/tesla_coil/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Power generation at <b>[input_power_multiplier*100]%</b>.<br>Shock interval at <b>[zap_cooldown*0.1]</b> seconds.</span>"

/obj/machinery/power/tesla_coil/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/assembly/signaler) && panel_open)
		wires.Interact(user)
		return ITEM_INTERACT_COMPLETE

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

/obj/machinery/power/tesla_coil/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		//don't lose arc power when it's not connected to anything
		//please place tesla coils all around the station to maximize effectiveness
		being_shocked = TRUE
		addtimer(CALLBACK(src, PROC_REF(reset_shocked)), 1 SECONDS)
		zap_buckle_check(power)
		if(zap_flags & ZAP_GENERATES_POWER) //I don't want no tesla revolver making 8GW you hear
			return power / 2
		var/power_produced = powernet ? power * input_power_multiplier : power
		produce_direct_power(power_produced)
		flick("coilhit", src)
		return power - power_produced //You get back the amount we didn't use
	else
		. = ..()

/obj/machinery/power/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/power = (powernet.available_power) * 0.2 * input_power_multiplier  //Always always always use more then you output for the love of god
	power = min(get_surplus(), power) //Take the smaller of the two
	consume_direct_power(power)
	playsound(loc, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
	tesla_zap(src, 10, power, zap_flags)
	zap_buckle_check(power)

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keeps an area from being fried by Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = FALSE
	density = TRUE

	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

/obj/machinery/power/grounding_rod/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grounding_rod(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/power/grounding_rod/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(exchange_parts(user, used))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/power/grounding_rod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", I)

/obj/machinery/power/grounding_rod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/power/grounding_rod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/power/grounding_rod/zap_act(power, zap_flags)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
		zap_buckle_check(power)
		return FALSE
	else
		. = ..()
