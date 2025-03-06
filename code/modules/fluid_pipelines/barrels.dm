/obj/structure/barrel
	name = "barrel"
	desc = "A simple barrel. Caution: may explode when materials inside are volatile."
	icon = 'icons/obj/pipes/barrel.dmi'
	icon_state = "base"
	density = TRUE
	anchored = FALSE
	/// Max amount of fluids
	var/max_amount = 250
	/// Internal fluid tank datum
	var/datum/fluid_pipe/tank

/obj/structure/barrel/Initialize(mapload)
	. = ..()
	tank = new(src, max_amount)

/obj/structure/barrel/Destroy()
	. = ..()
	QDEL_NULL(tank)

/obj/structure/barrel/examine(mob/user)
	. = ..()
	. += "Can store up to [max_amount] units of a single fluid."

/obj/structure/barrel/update_icon_state()
	for(var/datum/fluid/liquid as anything in tank.fluids)
		icon_state = liquid.barrel_state
		return
	icon_state = "base"

/obj/structure/barrel/update_overlays()
	. = ..()
	for(var/datum/fluid/liquid as anything in tank.fluids)
		. += liquid.fluid_id
		return

/obj/structure/barrel/wrench_act(mob/living/user, obj/item/I)
	var/obj/machinery/fluid_pipe/barrel_filler/base = locate() in get_turf(src)
	if(!base)
		return FALSE
	if(anchored)
		anchored = FALSE
		base.remove_barrel()
	else
		anchored = TRUE
		base.add_barrel(src)
	return TRUE

/obj/machinery/fluid_pipe/barrel_filler
	name = "barrel filler"
	desc = "Connect a barrel and fill it with a fluid of your choice."
	icon = 'icons/obj/pipes/fluid_machinery.dmi'
	icon_state = "filler"
	capacity = 0
	connect_dirs = list(NORTH, EAST, WEST) // south looks ugly
	only_one_connect = TRUE
	/// The connected barrel
	var/obj/structure/barrel/barrel
	/// Selected fluid. Is a typepath
	var/selected_fluid
	/// How much do we move per 0.5 seconds?
	var/move_amount = 50

/obj/machinery/fluid_pipe/barrel_filler/Destroy()
	. = ..()
	remove_barrel()

/obj/machinery/fluid_pipe/barrel_filler/update_icon_state()
	return

/obj/machinery/fluid_pipe/barrel_filler/update_overlays()
	..()
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		. += "[get_dir(src, pipe)]"

	if(barrel)
		. += "active"

/obj/machinery/fluid_pipe/barrel_filler/attack_hand(mob/user)
	var/datum/fluid/liquid = tgui_input_list(user, "What liquid do you want to pump in the barrel?", "Barrel filler", GLOB.fluid_name_to_path)
	if(!liquid)
		return FALSE
	selected_fluid = GLOB.fluid_name_to_path[liquid]

/obj/machinery/fluid_pipe/barrel_filler/process()
	if(!barrel || !selected_fluid)
		return
	var/datum/fluid/liquid = is_path_in_list(selected_fluid, fluid_datum.fluids, TRUE)
	if(!liquid)
		return
	fluid_datum.move_fluid(selected_fluid, barrel.tank, move_amount)

/obj/machinery/fluid_pipe/barrel_filler/proc/add_barrel(obj/structure/barrel/_barrel)
	barrel = _barrel
	RegisterSignal(barrel, COMSIG_PARENT_QDELETING, PROC_REF(remove_barrel))

/obj/machinery/fluid_pipe/barrel_filler/proc/remove_barrel()
	barrel = null
	UnregisterSignal(barrel, COMSIG_PARENT_QDELETING)
