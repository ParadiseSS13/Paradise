// TURBINE v2 AKA rev4407 Engine reborn!

// How to use it? - Mappers
//
// This is a very good power generating mechanism. All you need is a blast furnace with soaring flames and output.
// Not everything is included yet so the turbine can run out of fuel quite quickly. The best thing about the turbine is that even
// though something is on fire that passes through it, it won't be on fire as it passes out of it. So the exhaust fumes can still
// containt unreacted fuel - plasma and oxygen that needs to be filtered out and re-routed back. This of course requires smart piping
// For a computer to work with the turbine the compressor requires a comp_id matching with the turbine computer's id. This will be
// subjected to a change in the near future mind you. Right now this method of generating power is a good backup but don't expect it
// become a main power source unless some work is done. Have fun.
//
// - Numbers
//
// Example setup	 S - sparker
//					 B - Blast doors into space for venting
// *BBB****BBB*		 C - Compressor
// S    CT    *		 T - Turbine
// * ^ *  * V *		 D - Doors with firedoor
// **|***D**|**      ^ - Fuel feed (Not vent, but a gas outlet)
//   |      |        V - Suction vent (Like the ones in atmos
//

#define OVERDRIVE 4
#define VERY_FAST 3
#define FAST 2
#define SLOW 1

//below defines the time between an overheat event and next startup
#define OVERHEAT_TIME 120 SECONDS
#define OVERHEAT_THRESHOLD 200 //measured in cycles of 2 seconds
#define OVERHEAT_MESSAGE "Alert! The gas turbine generator's bearings have overheated. Initiating automatic cooling procedures. Manual restart is required."

/obj/machinery/power/compressor
	name = "gas turbine compressor"
	desc = "The compressor stage of a gas turbine generator. A data panel for linking with a to a computer can be accessed with a screwdriver."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "compressor"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = FALSE
	var/rpm = 0
	var/rpm_threshold = NONE
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0
	var/efficiency
	/// value that dertermines the amount of overheat "damage" on the turbine.
	var/overheat = 0
	/// This value needs to be zero. It represents seconds since the last overheat event
	var/last_overheat = 0
	/// Internal radio, used to alert engineers of turbine trip!
	var/obj/item/radio/radio

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "turbine"
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF
	var/opened = FALSE
	var/obj/machinery/power/compressor/compressor
	var/turf/simulated/outturf
	var/lastgen
	/// If the turbine is outputing enough to visibly affect its sprite
	var/generator_threshold = FALSE
	var/productivity = 1

/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "A computer to remotely control a gas turbine. Link it to a turbine via use of a multitool."
	icon_screen = "turbinecomp"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/turbine_computer
	var/obj/machinery/power/compressor/compressor
	var/id = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/power/compressor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_compressor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()
// The inlet of the compressor is the direction it faces

	gas_contained = new
	inturf = get_step(src, dir)
	locate_machinery()
	if(!turbine)
		stat |= BROKEN


	//Radio for screaming about overheats
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Engineering" = 0))

#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800


// Crucial to make things work!!!!
// OLD FIX - explanation given down below.
// /obj/machinery/power/compressor/CanPass(atom/movable/mover, turf/target, height=0)
// 		return !density

/obj/machinery/power/compressor/locate_machinery()
	if(turbine)
		return
	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(turbine)
		turbine.locate_machinery()

/obj/machinery/power/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6

/obj/machinery/power/compressor/attackby(obj/item/I, mob/user, params)
	if(default_change_direction_wrench(user, I))
		turbine = null
		inturf = get_step(src, dir)
		locate_machinery()
		if(turbine)
			to_chat(user, "<span class='notice'>Turbine connected.</span>")
			stat &= ~BROKEN
		else
			to_chat(user, "<span class='alert'>Turbine not connected.</span>")
			stat |= BROKEN
		return

	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/power/compressor/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/power/compressor/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return TRUE

/obj/machinery/power/compressor/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(panel_open)
		M.set_multitool_buffer(user, src)


/obj/machinery/power/compressor/CanAtmosPass(turf/T)
	return !density

/obj/machinery/power/compressor/proc/trigger_overheat()
	starter = FALSE
	last_overheat = world.time
	overheat -= 50
	radio.autosay(OVERHEAT_MESSAGE, name, "Engineering")
	playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, 40, 30, falloff_distance = 10)

/obj/machinery/power/compressor/proc/time_until_overheat_done()
	return max(last_overheat + OVERHEAT_TIME - world.time, 0)

/obj/machinery/power/compressor/process()
	if(!turbine)
		stat = BROKEN
	if(stat & BROKEN || panel_open)
		return
	if(!starter)
		return

	if(rpm_threshold == OVERDRIVE)
		//UI update here
		overheat += 2
		if(overheat >= OVERHEAT_THRESHOLD)
			trigger_overheat()
	else if(overheat > 0)
		overheat -= 2
	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/datum/gas_mixture/environment = inturf.return_air()

	// It's a simplified version taking only 1/10 of the moles from the turf nearby. It should be later changed into a better version
	//2023 note: It works, im not touc

	var/transfer_moles = environment.total_moles()/10
	//var/transfer_moles = rpm/10000*capacity
	var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

// RPM function to include compression friction - be advised that too low/high of a compfriction value can make things screwy

	rpm = max(0, rpm - (rpm*rpm)/(COMPFRICTION*efficiency))


	if(starter && !(stat & NOPOWER))
		use_power(2800)
		if(rpm<1000)
			rpmtarget = 1000
	else
		if(rpm<1000)
			rpmtarget = 0

	var/new_rpm_threshold
	switch(rpm)
		if(50001 to INFINITY)
			new_rpm_threshold = OVERDRIVE
		if(10001 to 50000)
			new_rpm_threshold = VERY_FAST
		if(2001 to 10000)
			new_rpm_threshold = FAST
		if(501 to 2000)
			new_rpm_threshold = SLOW
		else
			new_rpm_threshold = NONE

	if(rpm_threshold != new_rpm_threshold)
		rpm_threshold = new_rpm_threshold
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/compressor/update_overlays()
	. = ..()
	if(!rpm_threshold)
		return
	. += image(icon, "comp-o[rpm_threshold]", FLY_LAYER)

// These are crucial to working of a turbine - the stats modify the power output.
// TURBPOWER modifies how much raw energy can you get from rpms,
// TURBCURVESHAPE modifies the shape of the curve - the lower the value the less straight the curve is.

#define TURBPOWER 500000
#define TURBCURVESHAPE 0.5
#define POWER_CURVE_MOD 1.7 // Used to form the turbine power generation curve

/obj/machinery/power/turbine/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/power_turbine(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)
	RefreshParts()
// The outlet is pointed at the direction of the turbine component

	outturf = get_step(src, dir)
	locate_machinery()
	if(!compressor)
		stat |= BROKEN

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

/obj/machinery/power/turbine/locate_machinery()
	if(compressor)
		return
	compressor = locate() in get_step(src, get_dir(outturf, src))
	if(compressor)
		compressor.locate_machinery()

/obj/machinery/power/turbine/CanAtmosPass(turf/T)
	return !density

/obj/machinery/power/turbine/process()

	if(!compressor)
		stat = BROKEN

	if((stat & BROKEN) || panel_open)
		return
	if(!compressor.starter)
		return

	// This is the power generation function. If anything is needed it's good to plot it in EXCEL before modifying
	// the TURBPOWER and TURBCURVESHAPE values

	if(compressor.gas_contained.temperature < 500)
		lastgen = 0
	else
		lastgen = ((compressor.rpm / TURBPOWER) ** TURBCURVESHAPE) * TURBPOWER * productivity * POWER_CURVE_MOD

	produce_direct_power(lastgen)

	// Weird function but it works. Should be something else...

	var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles())/4

	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if(compressor.gas_contained.total_moles()>0)
		var/oamount = min(compressor.gas_contained.total_moles(), (compressor.rpm+100)/35000*compressor.capacity)
		var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

	if((lastgen > 100) != generator_threshold)
		generator_threshold = !generator_threshold
		update_icon(UPDATE_OVERLAYS)

	updateDialog()

/obj/machinery/power/turbine/update_overlays()
	. = ..()
	if(!generator_threshold)
		return
	. += image(icon, "turb-o", FLY_LAYER)

/obj/machinery/power/turbine/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		compressor = null
		outturf = get_step(src, dir)
		locate_machinery()
		if(compressor)
			to_chat(user, "<span class='notice'>Compressor connected.</span>")
			stat &= ~BROKEN
		else
			to_chat(user, "<span class='alert'>Compressor not connected.</span>")
			stat |= BROKEN
		return

	if(exchange_parts(user, I))
		return

	if(default_deconstruction_crowbar(user, I))
		return
	return ..()

/obj/machinery/power/turbine/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/power/turbine/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/turbine/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineComputer", name)
		ui.open()

/obj/machinery/power/turbine/ui_data(mob/user)
	var/list/data = list()
	data["compressor"] = !isnull(compressor)
	data["compressor_broken"] = (!compressor || (compressor.stat & BROKEN))
	data["turbine"] = !isnull(compressor?.turbine)
	data["turbine_broken"] = (compressor?.turbine?.stat & BROKEN)

	if(compressor && compressor.turbine)
		data["online"] = compressor.starter
		data["power"] = compressor.turbine.lastgen
		data["rpm"] = compressor.rpm
		data["temperature"] = compressor.gas_contained.return_temperature()
	return data

/obj/machinery/power/turbine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("toggle_power")
			var/time_until_done =  compressor.time_until_overheat_done()
			if(time_until_done)
				compressor.starter = FALSE
				to_chat(usr, "<span class='alert'>The turbine is overheating, please wait [time_until_done / 10] seconds for cooldown procedures to complete.</span>")
				playsound(src, 'sound/effects/electheart.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
			else if(compressor?.turbine)
				compressor.starter = !compressor.starter
				. = TRUE
				playsound(src, 'sound/mecha/powerup.ogg', 100, FALSE, 40, 30, falloff_distance = 10)

		if("reconnect")
			locate_machinery()
			. = TRUE

//////////////////
/////COMPUTER/////
/////////////////

/obj/machinery/computer/turbine_computer/Initialize()
	..()
	spawn(10)
		locate_machinery()

/obj/machinery/computer/turbine_computer/proc/disconnect()
	//this disconnects the computer from the turbine, good for resets.
	compressor = null

/obj/machinery/computer/turbine_computer/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/turbine_computer/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/obj/item/multitool/M = I
	compressor = M.buffer
	to_chat(user, "<span class='notice'>You link [src] to the turbine compressor in [I]'s buffer.</span>")

/obj/machinery/computer/turbine_computer/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/turbine_computer/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineComputer", name)
		ui.open()

/obj/machinery/computer/turbine_computer/ui_data(mob/user)
	var/list/data = list()
	data["compressor"] = !isnull(compressor)
	data["compressor_broken"] = (compressor?.stat & BROKEN)
	data["turbine"] = !isnull(compressor?.turbine)
	data["turbine_broken"] = (compressor?.turbine?.stat & BROKEN)

	if(compressor?.turbine)
		data["online"] = compressor.starter
		data["power"] = compressor.turbine.lastgen
		data["rpm"] = compressor.rpm
		data["temperature"] = compressor.gas_contained.return_temperature()
		data["bearing_heat"] = clamp((compressor.overheat / OVERHEAT_THRESHOLD) * 100, 0, 100)
	return data

/obj/machinery/computer/turbine_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("toggle_power")
			var/time_until_done = compressor.time_until_overheat_done()
			if(time_until_done)
				compressor.starter = FALSE
				to_chat(usr, "<span class='alert'>The turbine is overheating, please wait [time_until_done / 10] seconds for cooldown procedures to complete.</span>")
				playsound(src, 'sound/effects/electheart.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
				. = TRUE
			else if(compressor?.turbine)
				if(!compressor.starter)
					playsound(compressor, 'sound/mecha/powerup.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
				compressor.starter = !compressor.starter
				. = TRUE

		if("disconnect")
			disconnect()
			. = TRUE

/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return

#undef OVERDRIVE
#undef VERY_FAST
#undef FAST
#undef SLOW

#undef OVERHEAT_TIME
#undef OVERHEAT_THRESHOLD
#undef OVERHEAT_MESSAGE
#undef COMPFRICTION
#undef COMPSTARTERLOAD
#undef TURBPOWER
#undef TURBCURVESHAPE
#undef POWER_CURVE_MOD
