
/obj/machinery/power/battery
	name = "power battery"
	desc = "A power container which can save power over long periods of time"
	icon_state = "smes"
	density = TRUE

	var/charge = 0 // actual charge
	var/max_capacity = DEFAULT_SAFE_CAPACITY * 2

/// will remove charge from the battery equal to the amount specified or up to what charge is left in the battery, returns amount of energy consumed
/obj/machinery/power/battery/proc/consume_charge(amount)
	var/amount_consumed =  clamp(round(amount), 0, charge) // can't consume less than 0, can't consume more than the current charge
	charge -= amount_consumed
	return amount_consumed

/// will add charge to the battery equal to the amount specified or up to what the max charge is for the battery
/obj/machinery/power/battery/proc/add_charge(amount)
	var/amount_added = clamp(round(amount), 0, (max_capacity - charge)) // can't consume less than 0, can't consume more than the current charge
	charge += amount_added
	return amount_added
