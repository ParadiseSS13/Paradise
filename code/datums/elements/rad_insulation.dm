/datum/element/rad_insulation
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/amount					// Multiplier for radiation strength passing through

/datum/element/rad_insulation/Attach(datum/target, _amount = RAD_MEDIUM_INSULATION, protects = TRUE, contamination_proof = TRUE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	if(protects) // Does this protect things in its contents from being affected?
		RegisterSignal(target, COMSIG_ATOM_RAD_PROBE, PROC_REF(rad_probe_react))
	if(contamination_proof) // Can this object be contaminated?
		RegisterSignal(target, COMSIG_ATOM_RAD_CONTAMINATING, PROC_REF(rad_contaminating))

	amount = _amount

/datum/element/rad_insulation/proc/rad_probe_react(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_RADIATION

/datum/element/rad_insulation/proc/rad_contaminating(datum/source)
	SIGNAL_HANDLER

	return COMPONENT_BLOCK_CONTAMINATION
