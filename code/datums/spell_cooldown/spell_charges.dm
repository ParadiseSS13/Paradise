/datum/spell_cooldown/charges
	/// the max number of charges a spell can have
	var/max_charges = 2
	/// the number of charges we currently have
	var/current_charges = 0
	/// the cooldown between uses of charges
	var/charge_duration = 1 SECONDS
	/// the time at which a spell charge can be used
	var/charge_time

/datum/spell_cooldown/charges/cooldown_init(datum/spell/new_spell)
	. = ..()
	if(starts_off_cooldown)
		current_charges = max_charges

/datum/spell_cooldown/charges/get_cooldown_alpha()
	if(current_charges == 0 || charge_time > world.time)
		return 220 - 140 * get_availability_percentage()
	return 60

/datum/spell_cooldown/charges/should_draw_cooldown()
	return recharge_time > world.time || current_charges < max_charges

/datum/spell_cooldown/charges/is_on_cooldown()
	return !current_charges || charge_time >= world.time

/datum/spell_cooldown/charges/should_end_cooldown()
	if(recharge_time > world.time)
		return FALSE
	current_charges++
	spell_parent.action.build_all_button_icons()
	if(current_charges < max_charges) // we have more recharges to go
		recharge_time = world.time + recharge_duration
		return FALSE
	return TRUE

/datum/spell_cooldown/charges/start_recharge(recharge_override = 0)
	current_charges--
	if(current_charges)
		charge_time = world.time + charge_duration
	..()

/datum/spell_cooldown/charges/get_recharge_time()
	if(recharge_time > world.time)
		return recharge_time
	return ..()

/datum/spell_cooldown/charges/revert_cast()
	..()
	charge_time = world.time

/datum/spell_cooldown/charges/cooldown_info()
	var/charge_string = charge_duration != 0 ? round(min(1, (charge_duration - (charge_time - world.time)) / charge_duration), 0.01) * 100 : 100 // need this for possible 0 charge duration
	var/recharge_string = recharge_duration != 0 ? round(min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration), 0.01) * 100 : 100
	return "[charge_string != 100 ? "[charge_string]%\n" : ""][recharge_string != 100 ? "[recharge_string]%\n" : ""][current_charges]/[max_charges]"

/datum/spell_cooldown/charges/get_availability_percentage()
	if(max_charges == current_charges)
		return 1

	if(charge_time > world.time)
		return min(1, (charge_duration - (charge_time - world.time)) / charge_duration)
	return min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration) //parent proc without the on cooldown check
