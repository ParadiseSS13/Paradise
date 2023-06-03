
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
