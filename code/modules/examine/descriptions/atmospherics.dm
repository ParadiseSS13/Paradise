
/obj/machinery/atmospherics/pipe
	description_info = "This pipe, and all other pipes, can be connected or disconnected by a wrench.  The internal pressure of the pipe must \
	be below 300 kPa to do this.  More pipes can be obtained from the pipe dispenser."

/obj/machinery/atmospherics/pipe/New() //This is needed or else 20+ lines of copypasta to dance around inheritence.
	..()
	description_info += "<br>Most pipes and atmospheric devices can be connected or disconnected with a wrench.  The pipe's pressure must not be too high, \
	or if it is a device, it must be turned off first."

//HE pipes
/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	description_info = "This radiates heat from the pipe's gas to space, cooling it down."

//Supply/Scrubber pipes
/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/simple/visible/supply
	description_info = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/simple/hidden/supply
	description_info = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Universal adapters
/obj/machinery/atmospherics/pipe/simple/visible/universal
	description_info = "This allows you to connect 'normal' pipes, red 'scrubber' pipes, and blue 'supply' pipes."

/obj/machinery/atmospherics/pipe/simple/hidden/universal
	description_info = "This allows you to connect 'normal' pipes, red 'scrubber' pipes, and blue 'supply' pipes."

//Three way manifolds
/obj/machinery/atmospherics/pipe/manifold
	description_info = "A normal pipe with three ends to connect to."

/obj/machinery/atmospherics/pipe/manifold/visible/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/manifold/visible/supply
	description_info = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/manifold/hidden/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/manifold/hidden/supply
	description_info = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Insulated pipes
/obj/machinery/atmospherics/pipe/simple/insulated
	description_info = "This is completely useless, use a normal pipe." //Sorry, but it's true.

//Four way manifolds
/obj/machinery/atmospherics/pipe/manifold4w
	description_info = "This is a four-way pipe."

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	description_info = "This is a special 'supply' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	description_info = "This is a special 'scrubber' pipe, which does not connect to 'normal' pipes.  If you want to connect it, use \
	a Universal Adapter pipe."

//Endcaps
/obj/machinery/atmospherics/pipe/cap
	description_info = "This is a cosmetic attachment, as pipes currently do not spill their contents into the air."

//T-shaped valves
/obj/machinery/atmospherics/trinary/tvalve
	description_info = "Click this to toggle the mode.  The direction with the green light is where the gas will flow."

//Normal valves
/obj/machinery/atmospherics/binary/valve
	description_info = "Click this to turn the valve.  If red, the pipes on each end are separated.  Otherwise, they are connected."

//TEG ports
/obj/machinery/atmospherics/binary/circulator
	description_info = "This generates electricity, depending on the difference in temperature between each side of the machine.  The meter in \
	the center of the machine gives an indicator of how much electricity is being generated."

//Passive gates
/obj/machinery/atmospherics/binary/passive_gate
	description_info = "This is a one-way regulator, allowing gas to flow only at a specific pressure and flow rate.  If the light is green, it is flowing."

//Normal pumps (high power one inherits from this)
/obj/machinery/atmospherics/binary/pump
	description_info = "This moves gas from one pipe to another.  A higher target pressure demands more energy.  The side with the red end is the output."

//Vents
/obj/machinery/atmospherics/unary/vent_pump
	description_info = "This pumps the contents of the attached pipe out into the atmosphere, if needed.  It can be controlled from an Air Alarm."

//Freezers
/obj/machinery/atmospherics/unary/cold_sink/freezer
	description_info = "Cools down the gas of the pipe it is connected to.  It uses massive amounts of electricity while on. \
	It can be upgraded by replacing the capacitors, manipulators, and matter bins.  It can be deconstructed by screwing the maintenance panel open with a \
	screwdriver, and then using a crowbar."

//Heaters
/obj/machinery/atmospherics/unary/heat_reservoir/heater
	description_info = "Heats up the gas of the pipe it is connected to.  It uses massive amounts of electricity while on. \
	It can be upgraded by replacing the capacitors, manipulators, and matter bins.  It can be deconstructed by screwing the maintenance panel open with a \
	screwdriver, and then using a crowbar."

//Gas injectors
/obj/machinery/atmospherics/unary/outlet_injector
	description_info = "Outputs the pipe's gas into the atmosphere, similar to an air vent.  It can be controlled by a nearby atmospherics computer. \
	A green light on it means it is on."

//Scrubbers
/obj/machinery/atmospherics/unary/vent_scrubber
	description_info = "This filters the atmosphere of harmful gas.  Filtered gas goes to the pipes connected to it, typically a scrubber pipe. \
	It can be controlled from an Air Alarm.  It can be configured to drain all air rapidly with a 'panic syphon' from an air alarm."

//Omni filters
/obj/machinery/atmospherics/omni/filter
	description_info = "Filters gas from a custom input direction, with up to two filtered outputs and a 'everything else' \
	output.  The filtered output's arrows glow orange."

//Omni mixers
/obj/machinery/atmospherics/omni/mixer
	description_info = "Combines gas from custom input and output directions.  The percentage of combined gas can be defined."

//Canisters
/obj/machinery/portable_atmospherics/canister
	description_info = "The canister can be connected to a connector port with a wrench.  Tanks of gas (the kind you can hold in your hand) \
	can be filled by the canister, by using the tank on the canister, increasing the release pressure, then opening the valve until it is full, and then close it.  \
	*DO NOT* remove the tank until the valve is closed.  A gas analyzer can be used to check the contents of the canister."

	description_antag = "Canisters can be damaged, spilling their contents into the air, or you can just leave the release valve open."

//Portable pumps
/obj/machinery/portable_atmospherics/pump
	description_info = "Invaluable for filling air in a room rapidly after a breach repair.  The internal gas container can be filled by \
	connecting it to a connector port.  The pump can pump the air in (sucking) or out (blowing), at a specific target pressure.  The powercell inside can be \
	replaced by using a screwdriver, and then adding a new cell.  A tank of gas can also be attached to the air pump."

//Portable scrubbers
/obj/machinery/portable_atmospherics/scrubber
	description_info = "Filters the air, placing harmful gases into the internal gas container.  The container can be emptied by \
	connecting it to a connector port.  The pump can pump the air in (sucking) or out (blowing), at a specific target pressure.  The powercell inside can be \
	replaced by using a screwdriver, and then adding a new cell.  A tank of gas can also be attached to the scrubber. "

//Meters
/obj/machinery/meter
	description_info = "Measures the volume and temperature of the pipe under the meter."

//Pipe dispensers
/obj/machinery/pipedispenser
	description_info = "This can be moved by using a wrench.  You will need to wrench it again when you want to use it.  You can put \
	excess (atmospheric) pipes into the dispenser, as well.  The dispenser requires electricity to function."
