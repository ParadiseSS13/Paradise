/obj/vehicle_part/propulsion
	name = "propulsion"
	/// How many tiles it should take to make a full turn, assuming it's not omnimaneuverable.
	var/turning_radius
	/// How much the propulsion contributes to the vehicle's acceleration
	var/acceleration
	/// Bool, whether or not this works to move the vehicle in space.
	var/spaceworthy
	/// How effectively this form of propulsion can slow the vehicle
	var/braking_power

/obj/vehicle_part/propulsion/proc/get_turning_radius()
	return 1

/obj/vehicle_part/propulsion/wheelbase
	name = "wheels"
	desc = "The wheels on the bus..."
	spaceworthy = FALSE
	turning_radius = 1
