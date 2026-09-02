#define NONCARBON_DEFAULT_MIN_BODY_TEMP 250
#define NONCARBON_DEFAULT_MAX_BODY_TEMP 350
#define NONCARBON_DEFAULT_COLD_DAMAGE 2
#define NONCARBON_DEFAULT_HEAT_DAMAGE 2

/**
 * Bespoke element that deals damage to the attached mob when the ambient temperature is unsuitable.
 */
/datum/element/body_temperature
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Min body temp
	var/min_body_temp = NONCARBON_DEFAULT_MIN_BODY_TEMP
	/// Max body temp
	var/max_body_temp = NONCARBON_DEFAULT_MAX_BODY_TEMP

	//// Damage when below min temp
	var/cold_damage_per_tick = NONCARBON_DEFAULT_COLD_DAMAGE
	/// Damage when above max temp
	var/heat_damage_per_tick = NONCARBON_DEFAULT_HEAT_DAMAGE

/datum/element/body_temperature/Attach(datum/target, min_body_temp_, max_body_temp_, cold_damage_per_tick_, heat_damage_per_tick_)
	. = ..()

	if(!isanimal_or_basicmob(target))
		return ELEMENT_INCOMPATIBLE

	if(isnum(min_body_temp))
		min_body_temp = min_body_temp_

	if(isnum(max_body_temp))
		max_body_temp = max_body_temp_

	if(isnum(cold_damage_per_tick))
		cold_damage_per_tick = cold_damage_per_tick_

	if(isnum(heat_damage_per_tick))
		heat_damage_per_tick = heat_damage_per_tick_

	RegisterSignal(target, COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT, PROC_REF(handle_temperature))

/datum/element/body_temperature/Detach(datum/target)
	UnregisterSignal(target, COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT)
	return ..()

/datum/element/body_temperature/proc/handle_temperature(mob/living/simple_animal/target, datum/gas_mixture/readonly_environment)
	SIGNAL_HANDLER  // COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT

	if(!readonly_environment)
		return

	var/areatemp = target.get_temperature(readonly_environment)

	if(abs(areatemp - target.bodytemperature) > 5 && !HAS_TRAIT(src, TRAIT_NOBREATH))
		var/diff = areatemp - target.bodytemperature
		diff = diff / 5
		target.bodytemperature += diff

	if(target.bodytemperature < min_body_temp)
		target.adjustHealth(cold_damage_per_tick)
	else if(target.bodytemperature > max_body_temp)
		target.adjustHealth(heat_damage_per_tick)

#undef NONCARBON_DEFAULT_MIN_BODY_TEMP
#undef NONCARBON_DEFAULT_MAX_BODY_TEMP
#undef NONCARBON_DEFAULT_COLD_DAMAGE
#undef NONCARBON_DEFAULT_HEAT_DAMAGE
