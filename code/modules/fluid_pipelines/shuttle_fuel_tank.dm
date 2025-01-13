#define STATE_IDLE		0
#define STATE_INTAKE	1
#define STATE_OUTPUT	2

/obj/machinery/fluid_pipe/shuttle_fuel_tank
	name = "Shuttle Plasma Tank"
	desc = "Used to fuel the cargo shuttle."
	icon = 'icons/obj/pipes/shuttleintake_east.dmi'
	icon_state = "intake"
	dir = EAST
	just_a_pipe = FALSE
	capacity = 500
	connect_dirs = list(WEST)
	/// What state are we in
	var/state
	/// Ref to the internal storage tank
	var/datum/fluid_pipe/tank
	/// What fuel do we have in the tank?
	var/datum/fluid/current_fuel
	/// Units moved per 0.5 seconds. Base is 50/s
	var/amount_moved = 25

/obj/machinery/fluid_pipe/shuttle_fuel_tank/west
	icon = 'icons/obj/pipes/shuttleintake_west.dmi'
	dir = WEST
	connect_dirs = list(EAST)

/obj/machinery/fluid_pipe/shuttle_fuel_tank/Initialize(mapload)
	tank = new(src, 5000)
	return ..()

/obj/machinery/fluid_pipe/shuttle_fuel_tank/examine(mob/user)
	. = ..()
	/*
	. += "<span class='notice'>It is [full_percent]% full.</span>"
	if(purity >= 34)
		. += "<span class='warning'>It looks volatile.</span>"
*/

/obj/machinery/fluid_pipe/shuttle_fuel_tank/update_icon_state()
	return

/obj/machinery/fluid_pipe/shuttle_fuel_tank/update_overlays()
	. = ..()
	var/current_amount = tank.get_fluid_volumes()
	switch(current_amount)
		if(1 to 2500)
			. += "1_[round(current_amount / 500, 500)]"
		if(2500 to 5000)
			. += "1_100"
			. += "1_[round((current_amount - 2500) / 500, 500)]"

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
		if(!is_type_in_list(current_fuel, fluid_datum.fluids))
			return
		fluid_datum.move_fluid(current_fuel, tank, amount_moved)
	if(state == STATE_OUTPUT)
		tank.move_any_fluid(fluid_datum)

/obj/machinery/fluid_pipe/shuttle_fuel_tank/attack_hand(mob/user)
	if(..())
		return TRUE

	var/decision = tgui_alert(user, "Do you want to add fluids or retrieve them?", "Shuttle fuel tank", list("Add", "Retrieval", "Idle"))
	switch(decision)
		if("Add")
			state = STATE_INTAKE
		if("Retrieval")
			state = STATE_OUTPUT
		if("Idle")
			state = STATE_IDLE

/*
/obj/structure/shuttle_plasma_tank/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/analyzer) && full_percent > 0)
		to_chat(user, "<span class='notice'>[bicon(src)] [src]'s purity reads at [purity]%.</span>")
		return
	return ..()


/obj/machinery/fluid_pipe/shuttle_fuel_tank/proc/kaboom()
	var/explosion_score = clamp(full_percent * purity, 0, 10000)
	if(explosion_score <= 0)
		return
	var/destroy = explosion_score / 3000
	var/heavy = explosion_score / 2500
	var/light = explosion_score / 2000
	var/flash = explosion_score / 1000

	explosion(get_turf(src), destroy, heavy, light, flash)
*/



/obj/machinery/fluid_pipe/shuttle_fuel_tank/proc/on_shuttle_launch()


