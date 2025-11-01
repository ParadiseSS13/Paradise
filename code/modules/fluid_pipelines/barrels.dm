#define STATE_IDLE		"Idle"
#define STATE_INTAKE	"Intake"
#define STATE_OUTPUT	"Output"

/obj/structure/barrel
	name = "barrel"
	desc = "A simple barrel. Caution: may explode when materials inside are volatile."
	icon = 'icons/obj/pipes/barrel.dmi'
	icon_state = "base"
	density = TRUE
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

/obj/structure/barrel/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/rcs))
		var/obj/item/rcs/E = W
		E.try_send_container(user, src)
		return ITEM_INTERACT_COMPLETE

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

// MARK: Barrel filler

/obj/machinery/fluid_pipe/barrel_filler
	name = "barrel filler"
	desc = "Connect a barrel and fill it with a fluid of your choice."
	icon = 'icons/obj/pipes/fluid_machinery.dmi'
	icon_state = "filler"
	capacity = 0
	connect_dirs = list(NORTH, EAST, WEST) // south looks ugly
	/// The connected barrel
	var/obj/structure/barrel/barrel
	/// Selected fluid. Is a typepath
	var/selected_fluid
	/// How much do we move per 0.5 seconds?
	var/move_amount = 50
	/// What are we currently doing
	var/state = STATE_IDLE

/obj/machinery/fluid_pipe/barrel_filler/Destroy()
	. = ..()
	remove_barrel()

/obj/machinery/fluid_pipe/barrel_filler/update_icon_state()
	return

/obj/machinery/fluid_pipe/barrel_filler/update_overlays()
	..()
	. = list()
	for(var/obj/machinery/fluid_pipe/pipe as anything in get_adjacent_pipes())
		. += "[get_dir(src, pipe)]"
		// Somehow doesnt' want to render more than one connection

	if(barrel)
		. += "active"

/obj/machinery/fluid_pipe/barrel_filler/attack_hand(mob/user)
	var/datum/fluid/liquid = tgui_input_list(user, "What liquid do you want to pump in the barrel?", "Barrel filler", GLOB.fluid_name_to_path)
	if(!liquid)
		return FALSE
	selected_fluid = GLOB.fluid_name_to_path[liquid]
	var/response = tgui_input_list(user, "What state should the filler be in?", "Barrel filler", list(STATE_IDLE, STATE_INTAKE, STATE_OUTPUT))
	if(!response)
		return
	state = response

/obj/machinery/fluid_pipe/barrel_filler/process()
	if(!barrel || state == STATE_IDLE)
		return
	if(state == STATE_INTAKE)
		if(!selected_fluid)
			return
		var/datum/fluid/liquid = is_path_in_list(selected_fluid, fluid_datum.fluids, TRUE)
		if(!liquid)
			return
		fluid_datum.move_fluid(selected_fluid, barrel.tank, move_amount)
	else if(state == STATE_OUTPUT)
		if(!fluid_datum)
			return
		var/amount = min(move_amount, fluid_datum.get_empty_space())
		barrel.tank.move_any_fluid(fluid_datum, amount)


/obj/machinery/fluid_pipe/barrel_filler/proc/add_barrel(obj/structure/barrel/_barrel)
	barrel = _barrel
	RegisterSignal(barrel, COMSIG_PARENT_QDELETING, PROC_REF(remove_barrel))

/obj/machinery/fluid_pipe/barrel_filler/proc/remove_barrel()
	barrel = null
	UnregisterSignal(barrel, COMSIG_PARENT_QDELETING)

#undef STATE_IDLE
#undef STATE_INTAKE
#undef STATE_OUTPUT
