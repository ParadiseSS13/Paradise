/datum/spell_cooldown/charges
	/// the max number of charges a spell can have
	var/max_charges = 2
	/// the number of charges we currently have
	var/current_charges = 0
	/// the cooldown between uses of charges
	var/charge_duration = 1 SECONDS
	/// the time at which a spell charge can be used
	var/charge_time

/datum/spell_cooldown/charges/cooldown_init(obj/effect/proc_holder/spell/new_spell)
	. = ..()
	if(starts_off_cooldown)
		current_charges = max_charges

/datum/spell_cooldown/charges/is_on_cooldown()
	return !current_charges || charge_time >= world.time

/datum/spell_cooldown/charges/should_end_cooldown()
	if(recharge_time > world.time)
		return FALSE
	current_charges++
	if(current_charges < max_charges) // we have more recharges to go
		recharge_time = world.time + recharge_duration
		return FALSE
	return TRUE

/datum/spell_cooldown/charges/start_recharge(recharge_override = 0)
	current_charges--
	if(current_charges)
		charge_time = world.time + charge_duration
	..()

/datum/spell_cooldown/charges/revert_cast()
	..()
	charge_time = world.time

/datum/spell_cooldown/charges/statpanel_info()
	return "[current_charges] / [max_charges], [..()]"

/datum/spell_cooldown/charges/get_availability_percentage()
	if(max_charges == current_charges)
		return 1

	if(charge_time > world.time)
		return (charge_duration - (charge_time - world.time)) / charge_duration

	return (recharge_duration - (recharge_time - world.time)) / recharge_duration //parent proc without the on cooldown check
