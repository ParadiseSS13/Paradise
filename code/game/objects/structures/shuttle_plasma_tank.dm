#define STATE_IDLE		0
#define STATE_INTAKE	1
#define STATE_OUTPUT	2

/obj/machinery/fluid_pipe/shuttle_fuel_tank
	name = "Shuttle Plasma Tank"
	desc = "Used to fuel the cargo shuttle."
//	icon = 'icons/obj/shuttle_plasma_tank.dmi'
	icon_state = "tank_full"
	/// What state are we in
	var/state

/obj/machinery/fluid_pipe/shuttle_fuel_tank/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [full_percent]% full.</span>"
	if(purity >= 34)
		. += "<span class='warning'>It looks volatile.</span>"

/obj/machinery/fluid_pipe/shuttle_fuel_tank/process()
	return STOP_PROCESSING

/obj/machinery/fluid_pipe/shuttle_fuel_tank/attack_hand(mob/user)
	if(..())
		return TRUE

	var/decision = tgui_alert(user, "Do you want to add fluids or retrieve them?")
/*
/obj/structure/shuttle_plasma_tank/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/analyzer) && full_percent > 0)
		to_chat(user, "<span class='notice'>[bicon(src)] [src]'s purity reads at [purity]%.</span>")
		return
	return ..()
*/
/obj/machinery/fluid_pipe/shuttle_fuel_tank/proc/refill(obj/machinery/atmospherics/unary/plasma_refinery, incoming_purity, incoming_amount)
	if(full_percent >= 100)
		return
	// a tank can be refilled in 100 seconds with a default refinery
	var/actual_transferred_amount = clamp(incoming_amount, 0, 100 - full_percent)
	var/before_full = full_percent
	full_percent = clamp(full_percent + actual_transferred_amount, 0, 100)
	purity = clamp(((purity * before_full) + (incoming_purity * incoming_amount)) / full_percent, 1, 100)




/obj/machinery/fluid_pipe/shuttle_fuel_tank/proc/kaboom()
	var/explosion_score = clamp(full_percent * purity, 0, 10000)
	if(explosion_score <= 0)
		return
	var/destroy = explosion_score / 3000
	var/heavy = explosion_score / 2500
	var/light = explosion_score / 2000
	var/flash = explosion_score / 1000

	explosion(get_turf(src), destroy, heavy, light, flash)




/obj/machinery/fluid_pipe/shuttle_fuel_tank








/obj/structure/shuttle_plasma_tank/full
	full_percent = 100
