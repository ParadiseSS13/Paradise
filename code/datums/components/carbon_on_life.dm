/datum/component/carbon_on_life
	dupe_type = COMPONENT_DUPE_ALLOWED

// Will call the callback everytime the carbon calls Life()
/datum/component/carbon_on_life/Initialize(datum/callback/_callback)
	var/mob/living/carbon/C = parent
	if(!istype(C) || !_callback) //Something went wrong
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(C, COMSIG_CARBON_LIFE, _callback)

/datum/component/carbon_on_life/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CARBON_LIFE)
