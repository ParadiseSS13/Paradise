/datum/local_powernet
	var/area/powernet_area = null

	/// The APC associated with this powernet
	var/obj/machinery/power/apc/powernet_apc = null

	var/power_flags

	/// Is the equipment power channel on?
	var/equipment_powered = TRUE
	/// Is the lighting power channel on?
	var/lighting_powered = TRUE
	/// Is the environment power channel on?
	var/environment_powered = TRUE

	/// The amount of power consumed by equipment in every power cycle
	var/passive_equipment_consumption = 0
	/// The amount of power consumed by lighting in every power cycle
	var/passive_lighting_consumption = 0
	/// The amount of power consumed by environment in every power cycle
	var/passive_environment_consumption = 0

	/// The amount of power consumed by equipment in this power cycle
	var/equipment_consumption = 0
	/// The amount of power consumed by lighting in this power cycle
	var/lighting_consumption = 0
	/// The amount of power consumed by environment in this power cycle
	var/environment_consumption = 0

	/// The amount of the total power consumed passively in power cycles (i.e, each cycle)
	var/passive_consumption = 0
	/// The amount of total power consumed consumed in only this cycle
	var/active_consumption = 0

	var/list/registered_machines = list()

/// tethers a machine to this local powernet
/datum/local_powernet/proc/register_machine(obj/machinery/machine)
	if(machine in registered_machines)
		machine.power_change()
		return
	// machines ref'd in this list should clear themselves from it in destroy(), no need for signals here
	registered_machines += machine 
	machine.power_change()

/// untethers a machine to this local powernet
/datum/local_powernet/proc/unregister_machine(obj/machinery/machine)
	if(!(machine in registered_machines))
		machine.power_change()
		return
	registered_machines -= machine
	machine.power_change()

/**
  * # power_change
  *
  * Called when the area power status changes
  * Updates the area icon, calls power change on all machines in the area, and sends the `COMSIG_AREA_POWER_CHANGE` signal.
*/
/datum/local_powernet/proc/power_change()
	for(var/obj/machinery/M in registered_machines)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	powernet_area.power_change()
	SEND_SIGNAL(src, COMSIG_AREA_POWER_CHANGE)

/// checks to see if the given channel in this local powernet has power
/datum/local_powernet/proc/has_power(channel)
	if(power_flags & PW_ALWAYS_UNPOWERED) //if this local powernet can never be powered, always return FALSE
		return FALSE
	if(power_flags & PW_ALWAYS_POWERED) //if this powernet is always powered, we always return TRUE
		return TRUE
	if(powernet_apc?.stat & (BROKEN|MAINT)) //no working apc, no power
		return FALSE

	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			return equipment_powered
		if(PW_CHANNEL_LIGHTING)
			return lighting_powered
		if(PW_CHANNEL_ENVIRONMENT)
			return environment_powered
	return FALSE

/// Add active power usage to the given channel, returns FALSE is channel cannot be found or the channel does not have power to give
/datum/local_powernet/proc/use_active_power(channel, amount)
	if(!has_power(channel))
		return FALSE
	if(power_flags & PW_ALWAYS_POWERED)
		return TRUE //we check here as well because we want to skip calculations if we will always have power
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			equipment_consumption += amount
		if(PW_CHANNEL_LIGHTING)
			lighting_consumption += amount
		if(PW_CHANNEL_ENVIRONMENT)
			environment_consumption += amount
		else
			return FALSE
	active_consumption += amount
	return TRUE

/// Adjust static power for a specified channel, does not check to see if channel has power flowing into it
/datum/local_powernet/proc/adjust_static_power(channel, amount)
	if(power_flags & PW_ALWAYS_POWERED)
		return TRUE //we check here as well because we want to skip calculations if we will always have power
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			passive_equipment_consumption += amount
		if(PW_CHANNEL_LIGHTING)
			passive_lighting_consumption += amount
		if(PW_CHANNEL_ENVIRONMENT)
			passive_environment_consumption += amount
		else
			return FALSE
	passive_consumption += amount
	return TRUE

/datum/local_powernet/proc/get_total_usage()
	return passive_consumption + active_consumption

/datum/local_powernet/proc/get_channel_usage(channel)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			return passive_equipment_consumption + equipment_consumption
		if(PW_CHANNEL_LIGHTING)
			return passive_lighting_consumption + lighting_consumption
		if(PW_CHANNEL_ENVIRONMENT)
			return passive_environment_consumption + environment_consumption

/datum/local_powernet/proc/clear_usage()
	equipment_consumption = 0
	lighting_consumption = 0
	environment_consumption = 0
	active_consumption = 0

/// Handles flicker operations for apc processing, will flicker machines and lights in the powernet's area by random chance
/datum/local_powernet/proc/handle_flicker()
	if(prob(MACHINE_FLICKER_CHANCE))
		powernet_apc?.flicker()

	// lights don't have their own processing loop, so local powernets will be the father they never had. 3x as likely to cause a light flicker in a particular area, pick a light to flicker at random
	if(prob(MACHINE_FLICKER_CHANCE) * 3)
		var/list/lights = list()
		for(var/obj/machinery/light/L in powernet_area)
			lights += L

		if(length(lights))
			var/obj/machinery/light/picked_light = pick(lights)
			ASSERT(istype(picked_light))
			picked_light.flicker()
