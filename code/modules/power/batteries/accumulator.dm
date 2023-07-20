#warn Implement Accumulator block code

#define DEFAULT_SAFE_CAPACITY 2e6

/obj/machinery/power/battery/accumulator
	name = "high-voltage power accumulator"
	desc = "A high-voltage power container which can save "
	icon = 'icons/obj/power_64x.dmi'
	icon_state = "accumulator"
	density = TRUE

	power_voltage_type = VOLTAGE_HIGH
	var/datum/accumulator_block/accumulator_block = null

	var/safe_capacity = DEFAULT_SAFE_CAPACITY

	var/overcharge_counter = 0

/obj/machinery/power/battery/accumulator/Initialize(mapload)
	. = ..()
	accumulator_block = new(src)

/obj/machinery/power/battery/accumulator/Destroy()
	disconnect_from_block()
	return ..()

/obj/machinery/power/battery/accumulator/proc/disconnect_from_block()
	accumulator_block.remove_accumulator(src)

/obj/machinery/power/battery/accumulator/add_charge(amount)
	return accumulator_block.add_charge(amount)

/obj/machinery/power/battery/accumulator/consume_charge(amount)
	return accumulator_block.consume_charge(amount)
/*
/obj/machinery/power/battery/accumulator/proc/check_neighboring_accumulators()
	for(var/direction in GLOB.cardinal)
		for(var/obj/machinery/power/battery/accumulator in get_turf(get_step(src, direction)))
			if(accumulator.accumulator_block)
				accumulator.accumaltor_block.add_accumulator(src)
*/

/obj/machinery/power/battery/accumulator/proc/power_discharge()
	tesla_zap(src, 3, (accumulator_block.current_charge - accumulator_block.safe_capacity) * 10, shocked_targets = list())
	accumulator_block.discharging = FALSE

/obj/machinery/power/battery/accumulator/zap_act(power, zap_flags)
	return


#warn Implement Overcharge
#warn Implement Examine + Icon updates




