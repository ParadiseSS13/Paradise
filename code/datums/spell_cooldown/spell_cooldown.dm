/datum/spell_cooldown
	/// the world.time the spell will be available again
	var/recharge_time = 0
	/// the amount of time that must pass before a spell can be used again
	var/recharge_duration = 10 SECONDS // default spell cooldown
	/// does it start off cooldown?
	var/starts_off_cooldown = TRUE
	/// holds a ref to the spell
	var/datum/spell/spell_parent

/datum/spell_cooldown/Destroy()
	spell_parent = null
	return ..()

/datum/spell_cooldown/proc/cooldown_init(datum/spell/new_spell)
	spell_parent = new_spell
	if(!starts_off_cooldown)
		start_recharge()

/datum/spell_cooldown/proc/should_draw_cooldown()
	return is_on_cooldown()

/datum/spell_cooldown/proc/get_cooldown_alpha()
	return 220 - 140 * get_availability_percentage()

/datum/spell_cooldown/proc/is_on_cooldown()
	return recharge_time > world.time

/datum/spell_cooldown/proc/should_end_cooldown()
	return !is_on_cooldown()

/datum/spell_cooldown/process()
	if(!spell_parent.action)
		stack_trace("[spell_parent.type] ended up with a null action")
		return PROCESS_KILL
	spell_parent.action.build_all_button_icons()
	if(should_end_cooldown())
		return PROCESS_KILL


/*
 * used to track how long is left on the spell cooldown
 * finds them time left, before we can cast (recharge_time - world.time)
 * then subtracts that from the total time.
 * then divides it by the total time.
*/
/datum/spell_cooldown/proc/get_availability_percentage()
	if(!is_on_cooldown()) // if off cooldown, we don't bother with the maths
		return 1
	return min(1, (recharge_duration - (recharge_time - world.time)) / recharge_duration)

/datum/spell_cooldown/proc/get_recharge_time()
	return world.time + recharge_duration

/datum/spell_cooldown/proc/start_recharge(recharge_duration_override = 0)
	if(recharge_duration_override)
		recharge_time = world.time + recharge_duration_override
	else
		recharge_time = get_recharge_time()
	if(spell_parent.action)
		spell_parent.action.build_all_button_icons()
		START_PROCESSING(SSfastprocess, src)

/datum/spell_cooldown/proc/revert_cast()
	recharge_time = world.time

/datum/spell_cooldown/proc/cooldown_info()
	return "[round(get_availability_percentage(), 0.01) * 100]%"
