#define OVERCHARGE_COUNT_CHARGE 16
#define OVERCHARGE_COUNT_DISCHARGE 32

#define BASE_ACCUMULATOR_SAFE_CAPACITY 1000000

/datum/accumulator_block

	var/list/accumulators = list()

	var/current_charge = 0

	var/safe_capacity = BASE_ACCUMULATOR_SAFE_CAPACITY

	var/max_capacity = 1e7

	var/over_charging = FALSE

	var/discharging = FALSE

	var/over_charge_counter = 0

/datum/accumulator_block/New(initial_accumulator)
	. = ..()
	add_accumulator(initial_accumulator)
	recalculate_safe_capacity()
	START_PROCESSING(SSmachines, src)

/datum/accumulator_block/proc/add_charge(amount)
	var/amount_added = clamp(round(amount), 0, (max_capacity - current_charge)) // can't consume less than 0, can't consume more than the current charge
	current_charge += amount_added
	return amount_added

/datum/accumulator_block/proc/consume_charge(amount)
	var/amount_consumed =  clamp(round(amount), 0, current_charge) // can't consume less than 0, can't consume more than the current charge
	current_charge -= amount_consumed
	return amount_consumed

/datum/accumulator_block/proc/add_accumulator(obj/machinery/power/battery/accumulator/accumulator)
	if(accumulator.accumulator_block)
		var/datum/accumulator_block/block_to_merge = accumulator.accumulator_block
		current_charge += block_to_merge.current_charge
		block_to_merge.current_charge = 0
		block_to_merge.remove_accumulator(accumulator)
	accumulators |= accumulator
	accumulator.accumulator_block = src
	recalculate_safe_capacity()

/datum/accumulator_block/proc/remove_accumulator(obj/machinery/power/battery/accumulator/accumulator)
	current_charge -= current_charge / length(accumulators)
	accumulators -= accumulator
	accumulator.accumulator_block = null
	recalculate_safe_capacity()

/datum/accumulator_block/proc/recalculate_safe_capacity()
	safe_capacity = BASE_ACCUMULATOR_SAFE_CAPACITY + (BASE_ACCUMULATOR_SAFE_CAPACITY * ((1.05 ** length(accumulators)) * length(accumulators)))

/datum/accumulator_block/process()
	if(current_charge > safe_capacity)
		over_charge()
		return
	if(over_charge_counter > 0)
		over_charge_counter--

	if(over_charge_counter < OVERCHARGE_COUNT_CHARGE && over_charging)
		stop_discharging()


/datum/accumulator_block/proc/over_charge()
	if(discharging)
		return
	over_charge_counter++
	if(over_charge_counter >= OVERCHARGE_COUNT_CHARGE && !over_charging)
		start_discharge()
		return
	#warn play electricity noise on prob?
	if(over_charge_counter >= OVERCHARGE_COUNT_DISCHARGE)
		discharging = TRUE
		over_charging = FALSE
		var/obj/machinery/power/battery/accumulator/accumulator_to_discharge = pick(accumulators)
		playsound(get_turf(accumulator_to_discharge), 'sound/machines/power/electricity/electronic_chargeup.ogg', 50, FALSE)
		addtimer(CALLBACK(accumulator_to_discharge, TYPE_PROC_REF(/obj/machinery/power/battery/accumulator, power_discharge)), 1.5 SECONDS)
		current_charge = safe_capacity

/datum/accumulator_block/proc/start_discharge()
	over_charging = TRUE
	playsound(get_turf(pick(accumulators)), 'sound/machines/power/electricity/short_buzz1.ogg', 50, FALSE)

/datum/accumulator_block/proc/stop_discharging()
	over_charging = FALSE

