/**
  * # local_powernet
  *
  * Manages all power related mechanics for a single /area
  * Machines in areas will directly register to this datum in order to receive power
  *
  * Machine/Turf/Item -> Local Powernet -> APC -> Terminal -> Wirenet
  *
  * Non-machines cannot register to the local powernet and should instead listen for power change signals
*/
/datum/local_powernet
	/// The area this local powernet is attached to
	var/area/powernet_area = null
	/// The APC associated with this powernet
	var/obj/machinery/power/apc/powernet_apc = null

	/// Bit Flags indicating special behaviour on this powernet, always powered, never powered, etc
	var/power_flags

	/// Is the equipment power channel on?
	var/equipment_powered = TRUE
	/// Is the lighting power channel on?
	var/lighting_powered = TRUE
	/// Is the environment power channel on?
	var/environment_powered = TRUE

	/* Passive consumption vars, only change when machines are added/removed from the powernet (not if the power channel turns on/off) */
	/// The amount of power consumed by equipment in every power cycle
	VAR_PRIVATE/passive_equipment_consumption = 0
	/// The amount of power consumed by lighting in every power cycle
	VAR_PRIVATE/passive_lighting_consumption = 0
	/// The amount of power consumed by environment in every power cycle
	VAR_PRIVATE/passive_environment_consumption = 0

	/* Active consumption vars, changed when machines need spurts of power, unlike passive consumption these reset to 0 every process() cycle */
	/// The amount of power consumed by equipment in this power cycle
	var/equipment_consumption = 0
	/// The amount of power consumed by lighting in this power cycle
	var/lighting_consumption = 0
	/// The amount of power consumed by environment in this power cycle
	var/environment_consumption = 0

	/* Total consumption vars, tracking vars that only count aggregate consumption from active power channels */
	/// The amount of total power consumed consumed in only this cycle
	var/active_consumption = 0

	/// All machines registered to this local powernet, strictly typed to machines, everything else needs to register power change signals
	var/list/registered_machines = list()

/// tethers a machine to this local powernet
/datum/local_powernet/proc/register_machine(obj/machinery/machine)
	if(machine in registered_machines)
		machine.power_change() // this is probably what they wanted anyway by calling this proc
		log_debug("[machine] try to register to [powernet_apc]'s local powernet but was already registered!")
		return
	// machines ref'd in this list should clear themselves from it in destroy(), no need for signals here
	machine.machine_powernet = src
	registered_machines += machine
	machine.power_change()

/// untethers a machine to this local powernet
/datum/local_powernet/proc/unregister_machine(obj/machinery/machine)
	if(!(machine in registered_machines))
		return
	machine.machine_powernet = null
	registered_machines -= machine
	machine.power_change()

/**
  * # power_change
  *
  * Called when the area power status changes
  * calls power change on all machines in the area, and sends the `COMSIG_POWERNET_POWER_CHANGE` signal.
*/
/datum/local_powernet/proc/power_change()
	for(var/obj/machinery/M as anything in registered_machines)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	SEND_SIGNAL(src, COMSIG_POWERNET_POWER_CHANGE)

/// sets a power channel on or off and adjusts total power usage accordingly
/datum/local_powernet/proc/set_power_channel(channel, new_state)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			if(equipment_powered == new_state)
				return
			equipment_powered = new_state
		if(PW_CHANNEL_LIGHTING)
			if(lighting_powered == new_state)
				return
			lighting_powered = new_state
		if(PW_CHANNEL_ENVIRONMENT)
			if(environment_powered == new_state)
				return
			environment_powered = new_state
	power_change()

/// checks to see if the given channel in this local powernet has power
/datum/local_powernet/proc/has_power(channel)
	if(power_flags & PW_ALWAYS_UNPOWERED) //if this local powernet can never be powered, always return FALSE
		return FALSE
	if(power_flags & PW_ALWAYS_POWERED) //if this powernet is always powered, we always return TRUE
		return TRUE
	if(!powernet_apc)
		return FALSE
	if(powernet_apc.stat & (BROKEN|MAINT)) // no working apc, no power
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
	return TRUE

/// Returns the local powernets total power usage between all three of its channels, only includes usage on currently powered channels
/datum/local_powernet/proc/get_total_usage()
	return get_channel_usage(PW_CHANNEL_EQUIPMENT) + get_channel_usage(PW_CHANNEL_LIGHTING) + get_channel_usage(PW_CHANNEL_ENVIRONMENT)

/// returns active + passive power of a channel, if the channel is not powered it returns 0 watts
/datum/local_powernet/proc/get_channel_usage(channel)
	switch(channel)
		if(PW_CHANNEL_EQUIPMENT)
			return equipment_powered ? passive_equipment_consumption + equipment_consumption : 0
		if(PW_CHANNEL_LIGHTING)
			return lighting_powered ? passive_lighting_consumption + lighting_consumption : 0
		if(PW_CHANNEL_ENVIRONMENT)
			return environment_powered ? passive_environment_consumption + environment_consumption : 0

/datum/local_powernet/proc/clear_usage()
	equipment_consumption = 0
	lighting_consumption = 0
	environment_consumption = 0
	active_consumption = 0

/// Handles flicker operations for apc processing, will flicker machines and lights in the powernet's area by random chance
/datum/local_powernet/proc/handle_flicker()
	if(prob(MACHINE_FLICKER_CHANCE))
		powernet_apc?.flicker()

