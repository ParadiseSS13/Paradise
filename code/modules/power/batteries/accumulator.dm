#warn Implement Accumulator block code

#define DEFAULT_SAFE_CAPACITY 2e6

/obj/machinery/power/battery/accumulator
	name = "high-voltage power accumulator"
	desc = "A high-voltage power container which can save "
	icon = 'icons/obj/power_64x.dmi'
	icon_state = "accumulator"
	density = TRUE

	power_voltage_type = VOLTAGE_HIGH

	var/safe_capacity = DEFAULT_SAFE_CAPACITY

	var/overcharge_counter = 0

#warn Implement Overcharge
#warn Implement Examine + Icon updates

/obj/machinery/power/battery/accumulator/process()
	if(stat & BROKEN)
		return


