/**
 * Bespoke element that deals damage to the attached mob when the atmos requirements aren't satisfied
 */
/datum/element/atmos_requirements
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// An assoc list of "what atmos does this mob require to survive in".
	var/list/atmos_requirements
	/// How much (brute) damage we take from being in unsuitable atmos.
	var/unsuitable_atmos_damage

/datum/element/atmos_requirements/Attach(datum/target, list/atmos_requirements_, unsuitable_atmos_damage_ = 5)
	. = ..()

	if(!isanimal_or_basicmob(target))
		return ELEMENT_INCOMPATIBLE

	if(!atmos_requirements_)
		stack_trace("[type] added to [target] without any requirements specified.")

	atmos_requirements = atmos_requirements_
	unsuitable_atmos_damage = unsuitable_atmos_damage_
	RegisterSignal(target, COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT, PROC_REF(handle_environment))

/datum/element/atmos_requirements/Detach(datum/target)
	UnregisterSignal(target, COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT)
	return ..()

/datum/element/atmos_requirements/proc/handle_environment(mob/living/simple_animal/target, datum/gas_mixture/readonly_environment)
	SIGNAL_HANDLER  // COMSIG_SIMPLEANIMAL_HANDLE_ENVIRONMENT

	if(!readonly_environment)
		return

	var/atmos_suitable = TRUE

	var/tox = readonly_environment.toxins()
	var/oxy = readonly_environment.oxygen()
	var/n2 = readonly_environment.nitrogen()
	var/co2 = readonly_environment.carbon_dioxide()

	if(atmos_requirements["min_oxy"] && oxy < atmos_requirements["min_oxy"])
		atmos_suitable = FALSE
		target.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy)
	else if(atmos_requirements["max_oxy"] && oxy > atmos_requirements["max_oxy"])
		atmos_suitable = FALSE
		target.throw_alert("too_much_oxy", /atom/movable/screen/alert/too_much_oxy)
	else
		target.clear_alert("not_enough_oxy")
		target.clear_alert("too_much_oxy")

	if(atmos_requirements["min_tox"] && tox < atmos_requirements["min_tox"])
		atmos_suitable = FALSE
		target.throw_alert("not_enough_tox", /atom/movable/screen/alert/not_enough_tox)
	else if(atmos_requirements["max_tox"] && tox > atmos_requirements["max_tox"])
		atmos_suitable = FALSE
		target.throw_alert("too_much_tox", /atom/movable/screen/alert/too_much_tox)
	else
		target.clear_alert("too_much_tox")
		target.clear_alert("not_enough_tox")

	if(atmos_requirements["min_n2"] && n2 < atmos_requirements["min_n2"])
		atmos_suitable = FALSE
	else if(atmos_requirements["max_n2"] && n2 > atmos_requirements["max_n2"])
		atmos_suitable = FALSE

	if(atmos_requirements["min_co2"] && co2 < atmos_requirements["min_co2"])
		atmos_suitable = FALSE
	else if(atmos_requirements["max_co2"] && co2 > atmos_requirements["max_co2"])
		atmos_suitable = FALSE

	if(!atmos_suitable)
		target.adjustHealth(unsuitable_atmos_damage)
