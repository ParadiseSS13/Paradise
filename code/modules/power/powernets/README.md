
# Understanding Powernets
Much like any other massive numbers system in SS13, the power (or powernet) system is complex and confusing to work with, only being trumped in complexity by atmospherics/LINDA. This README serves as a powernets 101 guide and breaks down how the system works.

## Two Types of Powernets
There are two types of powernets in our code
1. Regional Powernets
2. Local Powernets

They are two completely different datum types from eachother and serve different completely different purposes. In a nutshell, regional powernets are dynamically sized and deal with physical machinery, cables, and generators whereas local powernets are statically locked into a single area each and work directly with APCs to handle individual machines interactions with the larger regional powernet.

## Regional Powernet
An inter-area datum which handles 1 continuous set of cables (`var/list/cables`) and all the connected machinery/nodes on that set of cable (`var/list/nodes`).

On this datum you'll notice a lot of different vars handling power input, output, consumption, demand, etc

### Regional Powernet Process Call Stack
Starting in SSmachines,
`/datum/controller/subsystem/machines/fire(resumed = 0)`
the `fire()` proc will call process `process_powernets()`
`/datum/controller/subsystem/machines/proc/process_powernets(resumed = 0)`
This proc will then call `process_power()` on every single registered regional powernet

### The Power Variables
`var/available_power` - the currently available power in the powernet in watts THIS PROCESS CYCLE
`var/power_demand` - the power being consumed from available power in watts THIS PROCESS CYCLE

`var/queued_power_production` - the power in watts that will be available to be consumed in the NEXT PROCESS CYCLE
--> All power producing generators dump their production into this variable
`var/queued_power_demand` - the power in watts that will be guaranteed to be consumed in the NEXT PROCESS CYCLE
--> Anything machine/item that needs to have priority consumption draws from the queue'd cycle first in order to ensure it gets priority power (electrocution, powersinks, etc)


## Local Powernets
This is a power datum that is locked to an area. There is only one local powernet datum per area which handles all power tracking/consumption
in that area. Every area will be initialized with a local powernet datum either by the area itself or if a machine intializes before the area does.


### The Static/Passive Power System
Powernets used to iterate through every machine to check power, while this is incredibly accurate and straightforward, we don't really need to
iterate through every machine (there are 1000's) since most of those machines will never change how much power they consume during their entire
lifetime except to maybe change power states. So we made the Static/Passive power system which only tracks machine power on the local powernet
so that we only have to iterate through the powernets instead of their machines.

```dm
/* Passive consumption vars, only change when machines are added/removed from the powernet (not if the power channel turns on/off) */
/// The amount of power consumed by equipment in every power cycle
VAR_PRIVATE/passive_equipment_consumption = 0
/// The amount of power consumed by lighting in every power cycle
VAR_PRIVATE/passive_lighting_consumption = 0
/// The amount of power consumed by environment in every power cycle
VAR_PRIVATE/passive_environment_consumption = 0
```

Using `adjust_static_power()`, it's possible to change these variables by inputting a channel and an amount to change the static power by.
Due to the lack of tracking the machines and their current consumption on the local net (by design), we need to be very particular about
how we're changing static power so we're maintaining perfect parity.

On Machine types, we have unsafe private setter procs that faciliate static power changes on machines
```dm
/// Helper proc to positively adjust static power tracking on the machine's powernet, not meant for general use!
/obj/machinery/proc/_add_static_power(channel, amount)
	PRIVATE_PROC(TRUE)
	machine_powernet?.adjust_static_power(channel, amount)

/// Helper proc to negatively adjust static power tracking on the machine's powernet, not meant for general use!
/obj/machinery/proc/_remove_static_power(channel, amount)
	PRIVATE_PROC(TRUE)
	machine_powernet?.adjust_static_power(channel, -amount)
```
These setter procs are called both in Initialize() to set the initial power and by the helper procs we have in machines. **Coders should not be
using `_add_static_power` or `_remove_static_power` ever unless they're changing how power functions on the base machine type. Instead you should
be using the safe helper procs below!**
```dm
/// Safely changes the static power on the local powernet based on an adjustment in idle power
/obj/machinery/proc/update_idle_power_consumption(channel = power_channel, amount)
	if(!power_initialized)
		return FALSE // we set static power values in Initialize(), do not update static consumption until after initialization or you will get weird values on powernet
	if(power_state == IDLE_POWER_USE)
		machine_powernet.adjust_static_power(power_channel, amount - idle_power_consumption)
	idle_power_consumption = amount

/// Safely changes the static power on the local powernet based on an adjustment in active power
/obj/machinery/proc/update_active_power_consumption(channel = power_channel, amount)
	if(!power_initialized)
		return FALSE // we set static power values in Initialize(), do not update static consumption until after initialization or you will get weird values on powernet
	if(power_state == ACTIVE_POWER_USE)
		machine_powernet.adjust_static_power(power_channel, amount - active_power_consumption)
	active_power_consumption = amount
```
These allow you to safely set how much power a machine will use when it's "Active" or "Idle," and the procs will handle changing the static
power for you. That way you never have to worry about losing parity when you're just trying to make your new machine consume power.

As a note: you should never be manually setting power consumption variables in code, this is a really quick way to get funky number on your
powernet. So for example don't edit `power_state`, `idle_power_consumption`, or `active_power_consumption`; Use their respective setter procs
that are already defined on `/machinery`!
