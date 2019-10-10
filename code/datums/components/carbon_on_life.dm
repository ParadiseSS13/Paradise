/datum/component/carbon_on_life
	dupe_type = COMPONENT_DUPE_ALLOWED
	var/datum/callback/callback

// Will call the callback everytime the carbon calls Life() and the carbon is still alive
/datum/component/carbon_on_life/Initialize(datum/callback/callback)
	var/mob/living/carbon/C = parent
	if(!istype(C) || !callback) //Something went wrong
		return COMPONENT_INCOMPATIBLE
	src.callback = callback
	RegisterSignal(C, COMSIG_CARBON_LIFE, .proc/Life)

/datum/component/carbon_on_life/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_CARBON_LIFE)

/datum/component/carbon_on_life/proc/Life(mob/living/carbon/C)
	if(C.stat != DEAD)
		callback.Invoke(C)