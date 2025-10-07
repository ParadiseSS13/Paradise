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
//   |      |        V - Suction vent (Like the ones in atmos)

/// Multiplies the friction of the compressor
#define COMPFRICTION 440
/// Compressor's moment of inertia in kg * m^2
#define COMP_MOMENT_OF_INERTIA 300
/// Convert RPM to radians per second(SI angular velocity units)
#define RPM_TO_RAD_PER_SECOND 0.1047
/// Compressors heat capacity in J / K
#define COMPRESSOR_HEAT_CAPACITY 50000
/// Changes the scaling of thermal efficiency with temperature. Lower value means faster scaling
#define THERMAL_EFF_TEMP_CURVE 7500
/// Changes the scaling of compression ratio with RPM. Lower value means faster scaling
#define COMPRESSION_RPM_CURVE 12000
/// The portion of the kinetic energy converted to electrical
#define KINETIC_TO_ELECTRIC 0.005
/// The maximum compression ratio of the turbine
#define COMPRESSION_RATIO_MAX 50
/// Scales the effect of compresion ratio on thermal efficiency
#define THERMAL_EFF_COMPRESSION_CURVE 0.9
/// The base value we add values dervied from componenet ratings to for thermal efficiency scaling. higher value means lesser effect of parts
#define THERMAL_EFF_PART_BASE 8
/// The base value we add values dervied from componenet ratings to for power efficiency. higher value means lesser effect of parts
#define POWER_EFF_PART_BASE 4
/// Maximum possible thermal efficiency
#define THERMAL_EFF_MAX 0.55
#define OVERDRIVE 4
#define VERY_FAST 3
#define FAST 2
#define SLOW 1

//below defines the time between an overheat event and next startup
#define OVERHEAT_TIME 120 SECONDS
/// Amount of damage at which the turbine catastrophically fails
#define BEARING_DAMAGE_MAX 2000
/// The temperature at which the bearings start taking damage
#define BEARING_DAMAGE_BASE_THRESHOLD 3e4
/// Scales the damage taken by the bearings. Higher value means less damage.
#define BEARING_DAMAGE_SCALING 5e5
/// Friction from bearing damage
#define BEARING_DAMAGE_FRICTION 960
/// Message send upon catastrphic failure
#define FAILURE_MESSAGE "Alert! The gas turbine generator's bearings have overheated. Initiating automatic cooling procedures. Manual restart is required."
/// RPM at which the turbine explodes upon failing
#define FAIILRE_RPM_EXPLOSION_THRESHOLD 15000

/// The maximum portion of the compressor's kinetic energy the turbine can harvest each tick
#define MAX_ENERGY_PORTION 0.125
#define ENERGY_PORTION_CURVE 10000
#define ENERGY_PORTION_CURVE_POWER 1.2

/obj/machinery/power/compressor
	name = "gas turbine compressor"
	desc = "The compressor stage of a gas turbine generator. A data panel for linking with a to a computer can be accessed with a screwdriver."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "compressor"
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
	/// Moment of Inertia
	var/moment_of_inertia = COMP_MOMENT_OF_INERTIA
	/// Heat capacity of the compressor. Used for gas heating and cooling it.
	var/heat_capacity = COMPRESSOR_HEAT_CAPACITY
	/// Current temperature of the compressor
	var/temperature = T20C
	/// The kinetic energy of the turbine
	var/kinetic_energy = 0
	var/efficiency
	/// The amount of bearing damage. Increases friction and can lead to a catastrophic failure
	var/bearing_damage = 0
	/// This value needs to be zero. It represents seconds since the last overheat event
	var/a_thing = 0
	/// Internal radio, used to alert engineers of turbine trip!
	var/obj/item/radio/radio
	/// Limits the amount of gas mix that is allowed to go into the compressor. 1 is fully open, 0 is fully closed
	var/throttle = 1
	/// The temperature of the gas in the compressor before the burn
	var/pre_burn_temp = 0
	/// The temperature of the gas in the compressor after the burn
	var/post_burn_temp = 0
	/// The portion of the gas' thermal energy that is converted to kinetic energy
	var/thermal_efficiency = 0
	/// By how much the intake gas is getting compressed
	var/compression_ratio = 1
	/// Intaked gas in mol/tick. tick is 2 seconds
	var/gas_throughput = 0
	/// List of things that would get sucked into the compressor if it spins fast enough
	var/list/to_suck_in = list()

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "turbine"
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
	gas_contained.volume = 50
	inturf = get_step(src, dir)
	locate_machinery()
	recalculate_atmos_connectivity()

	//Radio for screaming about overheats
	radio = new(src)
	radio.listening = FALSE
	radio.follow_target = src
	radio.config(list("Engineering" = 0))

	// Register signal near inlet to suck things in
	RegisterSignal(inturf, COMSIG_ATOM_ENTERED, PROC_REF(enter_inlet_turf))
	RegisterSignal(inturf, COMSIG_ATOM_EXIT, PROC_REF(leave_inlet_turf))

/obj/machinery/power/compressor/proc/check_broken()
	if(turbine && bearing_damage < BEARING_DAMAGE_MAX)
		stat &= ~BROKEN
	else
		stat |= BROKEN

/obj/machinery/power/compressor/locate_machinery()
	if(turbine)
		return
	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(turbine)
		turbine.locate_machinery()
	check_broken()

/obj/machinery/power/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6

/obj/machinery/power/compressor/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_change_direction_wrench(user, used))
		turbine = null
		inturf = get_step(src, dir)
		locate_machinery()
		if(turbine)
			to_chat(user, "<span class='notice'>Turbine connected.</span>")
		else
			to_chat(user, "<span class='alert'>Turbine not connected.</span>")
		check_broken()

		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/power/compressor/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/power/compressor/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return TRUE

/obj/machinery/power/compressor/welder_act(mob/user, obj/item/I)
	if(panel_open)
		if(!I.use_tool(src, user, 5 SECONDS, volume = I.tool_volume))
			return FALSE
		to_chat(user, "<span class='notice'>You fix [src]'s bearings</span>")
		bearing_damage = 0
		check_broken()
		return TRUE
	else
		to_chat(user,"<span class='warning'>You need to open the panel first</span>")
		return TRUE

/obj/machinery/power/compressor/multitool_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	if(panel_open)
		M.set_multitool_buffer(user, src)


/obj/machinery/power/compressor/CanAtmosPass(direction)
	return !density

/// Prevents heat leakage through the compressor
/obj/machinery/power/compressor/get_superconductivity(direction)
	return ZERO_HEAT_TRANSFER_COEFFICIENT

/obj/machinery/power/compressor/proc/catastrophic_failure()
	var/rpm_delta = rpm - FAIILRE_RPM_EXPLOSION_THRESHOLD
	if(rpm_delta > 0)
		explosion(src, rpm_delta / 5000, rpm_delta / 3000, rpm_delta / 1000)
		qdel(turbine)
		qdel(src)
	else
		radio.autosay(FAILURE_MESSAGE, name, "Engineering")
		playsound(src, 'sound/machines/buzz-two.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
		check_broken()
		starter = FALSE

/obj/machinery/power/compressor/proc/time_until_overheat_done()
	return max(a_thing + OVERHEAT_TIME - world.time, 0)


/obj/machinery/power/compressor/proc/enter_inlet_turf(turf/source, atom/movable/entered)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	var/static/list/compressor_ignored_things = typecacheof(list(
		/mob/dead,
		/mob/camera,
		/obj/effect,
		/obj/docking_port,
		))
	if(!compressor_ignored_things[entered.type] && !entered.anchored)
		to_suck_in += entered

	if(rpm > 1000)
		suck_in()

/obj/machinery/power/compressor/proc/leave_inlet_turf(turf/source, atom/movable/entered)
	SIGNAL_HANDLER  //COMSIG_ATOM_EXIT

	var/list/things = list(entered)
	while(length(things))
		var/atom/movable/thing = things[1]
		things -= thing
		to_suck_in -= thing
		things += thing.contents

/obj/machinery/power/compressor/proc/suck_in()
	var/static/list/compressor_ignored_things = typecacheof(list(
	/mob/dead,
	/mob/camera,
	/obj/effect,
	/obj/docking_port,
	))
	var/list/act_list = list()

	for(var/atom/movable/thing in to_suck_in)
		to_suck_in -= thing
		act_list += list(thing)

	while(length(act_list))
		var/atom/movable/thing = act_list[1]
		act_list -= thing
		if(compressor_ignored_things[thing.type])
			continue
		if(ishuman(thing))
			var/mob/living/carbon/human/target_mob = thing
			if(HAS_TRAIT(target_mob, TRAIT_NOSLIP))
				continue
		act_list += thing.contents
		thing.forceMove(get_step(turbine.loc, turbine.loc.dir))
		thing.compressor_grind()
		bearing_damage += BEARING_DAMAGE_MAX / 10

	if(bearing_damage > BEARING_DAMAGE_MAX)
		catastrophic_failure()

/obj/machinery/power/compressor/process()
	var/datum/milla_safe/compressor_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/compressor_process

/datum/milla_safe/compressor_process/on_run(obj/machinery/power/compressor/compressor)
	// The things at the start should happen regardless of whether the compressor works.
	// Lose heat to conduction.
	compressor.temperature = compressor.temperature * 0.997
	var/friction_energy_loss = 0
	// Rotational kinetic energy turned to heat by friction
	if(compressor.rpm)
		friction_energy_loss = ((compressor.bearing_damage / BEARING_DAMAGE_MAX) * BEARING_DAMAGE_FRICTION + COMPFRICTION) * (compressor.rpm ** 1.27)  / ((THERMAL_EFF_PART_BASE + compressor.efficiency) / (THERMAL_EFF_PART_BASE + 4))

	compressor.check_broken()
	// If the compressor cannot function only lose kinetic energy to friction and damage the bearings if over temp
	if(compressor.stat & BROKEN || compressor.panel_open || !compressor.starter)
		// Update values that show up on the UI
		compressor.compression_ratio = 0
		compressor.pre_burn_temp = 0
		compressor.post_burn_temp = 0
		compressor.thermal_efficiency = 0
		compressor.gas_throughput = 0
		// Lose kinetic energy to friction
		compressor.kinetic_energy = max(compressor.kinetic_energy - friction_energy_loss, 0)
		compressor.temperature += friction_energy_loss / compressor.heat_capacity
		compressor.rpm = max(0, sqrtor0(2 * compressor.kinetic_energy / compressor.moment_of_inertia) / RPM_TO_RAD_PER_SECOND)

		// Calculate the temperature threshold for taking bearing damage. Damaged bearings get more damaged more easily
		var/bearing_damage_threshold = BEARING_DAMAGE_BASE_THRESHOLD * (1 - 0.4 * compressor.bearing_damage / BEARING_DAMAGE_MAX)
		// Damage bearings if overheated
		if(compressor.temperature > bearing_damage_threshold)
			compressor.bearing_damage = min(compressor.bearing_damage + max(0, (compressor.temperature - bearing_damage_threshold) * compressor.rpm / BEARING_DAMAGE_SCALING), BEARING_DAMAGE_MAX)
		return

	// By how much we compress the gas going into the turbine
	compressor.compression_ratio = 1 + (COMPRESSION_RATIO_MAX - 1) * (compressor.rpm /(compressor.rpm + COMPRESSION_RPM_CURVE))

	var/datum/gas_mixture/environment = get_turf_air(compressor.inturf)
	var/datum/gas_mixture/output_side = get_turf_air(get_step(compressor.turbine.loc, compressor.turbine.loc.dir))
	// The more we are able to compress the gas the more gas we can shove in the compressor
	var/transfer_moles = environment.total_moles() * (compressor.compression_ratio / 50) * compressor.throttle
	var/datum/gas_mixture/removed = environment.remove(transfer_moles)
	compressor.gas_contained.merge(removed)
	// Record how much gas we took in for the UI
	compressor.gas_throughput = compressor.gas_contained.total_moles()

	// Lose kinetic energy to compressing the gas.
	compressor.kinetic_energy -= min(compressor.kinetic_energy, compressor.compression_ratio * (compressor.gas_contained.return_pressure() - environment.return_pressure()))

	var/gas_heat_capacity = compressor.gas_contained.heat_capacity()
	var/total_heat_energy = compressor.gas_contained.thermal_energy() + (compressor.temperature * compressor.heat_capacity)

	// Pre heat the gas using the compressor's residual heat
	compressor.gas_contained.set_temperature(total_heat_energy / (compressor.heat_capacity + gas_heat_capacity))
	compressor.temperature = total_heat_energy / (compressor.heat_capacity + gas_heat_capacity)

	// Record the pre burn temp. This is for the UI
	compressor.pre_burn_temp = compressor.gas_contained.temperature()

	// Burn the gas mix
	for(var/i in 1 to (10 + (compressor.compression_ratio / 2)))
		compressor.gas_contained.react()

	// Record the post burn temp. This is for the UI
	compressor.post_burn_temp = compressor.gas_contained.temperature()

	// We just changed our composition
	gas_heat_capacity = compressor.gas_contained.heat_capacity()

	// The portion of the thermal energy of the gas converted to kinetic energy
	compressor.thermal_efficiency = (compressor.gas_contained.return_pressure() + output_side.return_pressure()) <= 0 ? 0 : \
	THERMAL_EFF_MAX * \
	((compressor.compression_ratio / COMPRESSION_RATIO_MAX) ** THERMAL_EFF_COMPRESSION_CURVE) * \
	((THERMAL_EFF_PART_BASE + compressor.efficiency) / (THERMAL_EFF_PART_BASE + 4)) * \
	(compressor.gas_contained.temperature() / (compressor.gas_contained.temperature() + THERMAL_EFF_TEMP_CURVE)) * \
	(compressor.gas_contained.return_pressure() / (compressor.gas_contained.return_pressure() + output_side.return_pressure())) * \
	((1 - compressor.bearing_damage / BEARING_DAMAGE_MAX) ** 3)

	var/kinetic_energy_gain = compressor.gas_contained.thermal_energy() * compressor.thermal_efficiency

	// Take energy away from the gas
	if(compressor.gas_contained.total_moles() > 0)
		compressor.gas_contained.set_temperature((compressor.gas_contained.thermal_energy() - kinetic_energy_gain) / gas_heat_capacity)

	// Calculate the total kinetic energy
	compressor.kinetic_energy = max(compressor.kinetic_energy + kinetic_energy_gain - friction_energy_loss, 0)

	// Set compressor RPM accoring to current kinetic energy
	compressor.rpm = max(0, sqrtor0(2 * compressor.kinetic_energy / compressor.moment_of_inertia) / RPM_TO_RAD_PER_SECOND)

	// Increase temperature according to the amount of energy lost to friction
	compressor.temperature += friction_energy_loss / compressor.heat_capacity

	total_heat_energy = compressor.gas_contained.thermal_energy() + (compressor.temperature * compressor.heat_capacity)

	// Do another heat transfer after the burn
	compressor.gas_contained.set_temperature(total_heat_energy / (compressor.heat_capacity + gas_heat_capacity))
	compressor.temperature = total_heat_energy / (compressor.heat_capacity + gas_heat_capacity)

	// Calculate the temperature threshold for taking bearing damage. Damaged bearings get more damaged more easily
	var/bearing_damage_threshold = BEARING_DAMAGE_BASE_THRESHOLD * (1 - 0.4 * compressor.bearing_damage / BEARING_DAMAGE_MAX)
	// Damage bearings if overheated
	if(compressor.temperature > bearing_damage_threshold)
		compressor.bearing_damage = min(compressor.bearing_damage + max(0, (compressor.temperature - bearing_damage_threshold) * compressor.rpm / BEARING_DAMAGE_SCALING), BEARING_DAMAGE_MAX)

	if(compressor.rpm > 1000)
		compressor.suck_in()

	if(compressor.bearing_damage >= BEARING_DAMAGE_MAX)
		compressor.catastrophic_failure()

	/// Check RPM against thresholds to decide which icon to use
	var/new_rpm_threshold
	switch(compressor.rpm)
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

	if(compressor.rpm_threshold != new_rpm_threshold)
		compressor.rpm_threshold = new_rpm_threshold
		compressor.update_icon(UPDATE_OVERLAYS)

/obj/machinery/power/compressor/update_overlays()
	. = ..()
	if(!rpm_threshold)
		return
	. += image(icon, "comp-o[rpm_threshold]", FLY_LAYER)

// These are crucial to working of a turbine - the stats modify the power output.
// TURBPOWER modifies how much raw energy can you get from rpms,
// TURBCURVESHAPE modifies the shape of the curve - the lower the value the less straight the curve is.

#define TURBPOWER 150000
#define TURBCURVESHAPE 1.5
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

	outturf = loc
	locate_machinery()

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

/obj/machinery/power/turbine/locate_machinery()
	if(compressor)
		return
	compressor = locate() in get_step(src, ((dir & 5) << 1) | ((dir & 10) >> 1))
	if(compressor)
		compressor.locate_machinery()
		stat &= ~BROKEN
	else
		stat |= BROKEN

/obj/machinery/power/turbine/process()
	var/datum/milla_safe/turbine_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/turbine_process

/datum/milla_safe/turbine_process/on_run(obj/machinery/power/turbine/turbine)
	if(!turbine.compressor)
		turbine.stat = BROKEN

	if((turbine.stat & BROKEN) || turbine.panel_open || !turbine.compressor.starter)
		turbine.lastgen = 0
		return

	// This is the power generation function. If anything is needed it's good to plot it in EXCEL before modifying

	// Calculate the portion of the compressor's kinetic energy the turbine will harvest this tick
	var/energy_portion = MAX_ENERGY_PORTION * (turbine.compressor.rpm / (turbine.compressor.rpm + ENERGY_PORTION_CURVE)) ** ENERGY_PORTION_CURVE_POWER
	// Lose the calculated portion kinetic energy and convert it to electrical energy with the amount depending on the efficiency
	turbine.lastgen = (turbine.compressor.kinetic_energy * energy_portion / WATT_TICK_TO_JOULE) * ((POWER_EFF_PART_BASE + turbine.productivity) / (POWER_EFF_PART_BASE + 4))
	turbine.compressor.kinetic_energy -= energy_portion * turbine.compressor.kinetic_energy

	turbine.produce_direct_power(turbine.lastgen)

	if(turbine.compressor.gas_contained.total_moles() > 0)
		var/oamount = min(turbine.compressor.gas_contained.total_moles(), (turbine.compressor.rpm + 100) / 35000 * turbine.compressor.capacity)
		var/datum/gas_mixture/removed = turbine.compressor.gas_contained.remove(oamount)
		turbine.outturf.blind_release_air(removed)

	if((turbine.lastgen > 100) != turbine.generator_threshold)
		turbine.generator_threshold = !turbine.generator_threshold
		turbine.update_icon(UPDATE_OVERLAYS)

	turbine.updateDialog()

/obj/machinery/power/turbine/update_overlays()
	. = ..()
	if(!generator_threshold)
		return
	. += image(icon, "turb-o", FLY_LAYER)

/obj/machinery/power/turbine/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), used))
		return ITEM_INTERACT_COMPLETE

	if(default_change_direction_wrench(user, used))
		compressor = null
		outturf = get_step(src, dir)
		locate_machinery()
		if(compressor)
			to_chat(user, "<span class='notice'>Compressor connected.</span>")
			stat &= ~BROKEN
		else
			to_chat(user, "<span class='alert'>Compressor not connected.</span>")
			stat |= BROKEN
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

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
		data["temperature"] = compressor.gas_contained.temperature()
	return data

/obj/machinery/power/turbine/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("toggle_power")
			if(compressor?.turbine)
				compressor.starter = !compressor.starter
				. = TRUE
				playsound(src, 'sound/mecha/powerup.ogg', 100, FALSE, 40, 30, falloff_distance = 10)

		if("reconnect")
			locate_machinery()
			. = TRUE

//////////////////
/////COMPUTER/////
/////////////////

/obj/machinery/computer/turbine_computer/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/turbine_computer/LateInitialize()
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
	data["throttle"] = (compressor?.throttle * 100)

	if(compressor?.turbine)
		data["online"] = compressor.starter
		data["power"] = compressor.turbine.lastgen
		data["rpm"] = compressor.rpm
		data["compressionRatio"] = compressor.compression_ratio
		data["temperature"] = compressor.temperature
		data["bearingDamage"] = clamp((compressor.bearing_damage / BEARING_DAMAGE_MAX) * 100, 0, 100)
		data["preBurnTemperature"] = compressor.pre_burn_temp
		data["postBurnTemperature"] = compressor.post_burn_temp
		data["thermalEfficiency"] = compressor.thermal_efficiency
		data["gasThroughput"] = compressor.gas_throughput

	return data

/obj/machinery/computer/turbine_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("toggle_power")
			if(compressor?.turbine)
				if(!compressor.starter)
					playsound(compressor, 'sound/mecha/powerup.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
				compressor.starter = !compressor.starter
				. = TRUE

		if("disconnect")
			disconnect()
			. = TRUE
		if("set_throttle")
			compressor.throttle = text2num(params["throttle"]) / 100

/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return

#undef OVERDRIVE
#undef VERY_FAST
#undef FAST
#undef SLOW
#undef BEARING_DAMAGE_BASE_THRESHOLD
#undef OVERHEAT_TIME
#undef BEARING_DAMAGE_MAX
#undef FAILURE_MESSAGE
#undef COMPFRICTION
#undef TURBPOWER
#undef TURBCURVESHAPE
#undef POWER_CURVE_MOD
#undef COMP_MOMENT_OF_INERTIA
#undef RPM_TO_RAD_PER_SECOND
#undef COMPRESSOR_HEAT_CAPACITY
#undef THERMAL_EFF_TEMP_CURVE
#undef COMPRESSION_RPM_CURVE
#undef KINETIC_TO_ELECTRIC
#undef COMPRESSION_RATIO_MAX
#undef THERMAL_EFF_COMPRESSION_CURVE
#undef THERMAL_EFF_PART_BASE
#undef POWER_EFF_PART_BASE
#undef THERMAL_EFF_MAX
#undef BEARING_DAMAGE_SCALING
#undef BEARING_DAMAGE_FRICTION
#undef FAIILRE_RPM_EXPLOSION_THRESHOLD
#undef MAX_ENERGY_PORTION
#undef ENERGY_PORTION_CURVE
#undef ENERGY_PORTION_CURVE_POWER
