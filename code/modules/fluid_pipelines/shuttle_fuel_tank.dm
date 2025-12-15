#define STATE_IDLE		0
#define STATE_INTAKE	1
#define STATE_OUTPUT	2

/obj/machinery/fluid_pipe/shuttle_fuel_tank
	name = "shuttle fuel tank"
	desc = "Used to fuel the cargo shuttle. Can only contain one type of fuel, and has an internal storage of 5000 units."
	icon = 'icons/obj/pipes/shuttleintake_east.dmi'
	icon_state = "intake"
	dir = EAST
	layer = ABOVE_WINDOW_LAYER + 0.1
	just_a_pipe = FALSE
	capacity = 500
	connect_dirs = list(WEST)
	resistance_flags = INDESTRUCTIBLE
	/// What state are we in
	var/state
	/// Ref to the internal storage tank
	var/datum/fluid_pipe/tank
	/// What fuel do we have in the tank?
	var/datum/fluid/current_fuel
	/// Units moved per 0.5 seconds. Base is 100/s
	var/amount_moved = 50

/obj/machinery/fluid_pipe/shuttle_fuel_tank/west
	icon = 'icons/obj/pipes/shuttleintake_west.dmi'
	dir = WEST
	connect_dirs = list(EAST)

/obj/machinery/fluid_pipe/shuttle_fuel_tank/Initialize(mapload)
	tank = new(src, 5000)
	SSshuttle.supply.fuel_tank = src
	return ..()

/obj/machinery/fluid_pipe/shuttle_fuel_tank/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("It is [(tank.get_fluid_volumes() / tank.total_capacity) * 100]% full.")
	if(current_fuel)
		. += "The current fuel is [initial(current_fuel.fluid_name)]."

/obj/machinery/fluid_pipe/shuttle_fuel_tank/update_icon_state()
	return

/obj/machinery/fluid_pipe/shuttle_fuel_tank/update_overlays()
	. = ..()
	var/current_amount = tank?.get_fluid_volumes()
	switch(current_amount)
		if(1 to 2500)
			. += "1_[round(current_amount / 125, 20)]"
		if(2500 to 5000)
			. += "1_100"
			. += "2_[round((current_amount - 2500) / 125, 20)]"

/obj/machinery/fluid_pipe/shuttle_fuel_tank/process()
	if(state == STATE_IDLE)
		return

	if(state == STATE_INTAKE)
		if(!length(fluid_datum.fluids))
			return
		if(!current_fuel)
			for(var/datum/fluid/liquid as anything in fluid_datum.fluids)
				if(!liquid.fuel_value)
					continue
				current_fuel = liquid.type
		if(!is_path_in_list(current_fuel, fluid_datum.fluids, TRUE))
			return
		fluid_datum.move_fluid(current_fuel, tank, amount_moved)
		return

	if(state == STATE_OUTPUT)
		var/amount = min(amount_moved, fluid_datum.get_empty_space())
		tank.move_any_fluid(fluid_datum, amount)
		return

/obj/machinery/fluid_pipe/shuttle_fuel_tank/attack_hand(mob/user)
	var/decision = tgui_alert(user, "Do you want to add fluids or retrieve them?", "Shuttle fuel tank", list("Add", "Retrieval", "Idle"))
	switch(decision)
		if("Add")
			state = STATE_INTAKE
		if("Retrieval")
			state = STATE_OUTPUT
		if("Idle")
			state = STATE_IDLE

/obj/machinery/fluid_pipe/shuttle_fuel_tank/proc/check_fuels()
	if(tank.get_fluid_volumes() < 500)
		return // Need at least 500 units of fuel


/obj/machinery/fluid_pipe/shuttle_fuel_tank/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration_flat, armor_penetration_percentage)
	return // This shit is indestructable

/obj/machinery/fluid_pipe/shuttle_fuel_tank/wrench_act(mob/living/user, obj/item/I)
	return // No picking it up aswell

#undef STATE_IDLE
#undef STATE_INTAKE
#undef STATE_OUTPUT
