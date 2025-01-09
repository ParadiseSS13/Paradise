#define STATE_IDLE		0
#define STATE_INTAKE	1
#define STATE_OUTPUT	2

/obj/machinery/fluid_pipe/shuttle_fuel_tank
	name = "Shuttle Plasma Tank"
	desc = "Used to fuel the cargo shuttle."
//	icon = 'icons/obj/shuttle_plasma_tank.dmi'
	icon_state = "tank_full"
	just_a_pipe = FALSE
	/// What state are we in
	var/state
	/// Ref to the internal storage tank
	var/obj/machinery/fluid_pipe/abstract/internal_tank/tank
	/// What fuel do we have in the tank?
	var/datum/fluid/current_fuel
	/// Units moved per 0.5 seconds. Base is 50/s
	var/amount_moved = 25

/obj/machinery/fluid_pipe/shuttle_fuel_tank/Initialize(mapload)
	dir = EAST
	connect_dirs = list(dir)
	tank = new(src)
	return ..()

/obj/machinery/fluid_pipe/shuttle_fuel_tank/examine(mob/user)
	. = ..()
	/*
	. += "<span class='notice'>It is [full_percent]% full.</span>"
	if(purity >= 34)
		. += "<span class='warning'>It looks volatile.</span>"
*/
/obj/machinery/fluid_pipe/shuttle_fuel_tank/process()
	if(state == STATE_IDLE)
		return
	if(state == STATE_INTAKE)
		if(!length(fluid_datum.fluids))
			return
		for(var/datum/fluid/liquid as anything in fluid_datum.fluids)
			if(!liquid.fuel_value)
				continue
			if(current_fuel && !istype(current_fuel, liquid))
				continue
		if(current_fuel)
			fluid_datum.move_fluid(current_fuel, tank.fluid_datum, amount_moved)


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


