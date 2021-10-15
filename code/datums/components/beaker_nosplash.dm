/*
	This component should be used for machinery and other datums that take a beaker/reagent container
	for processing, where splashing the beaker is generally *not* what you want to do.

	Essentially tells the item attacking to not apply any sort of after-attack, which in glass beakers
	tends to be splashing or changing reagent levels.
*/

/datum/component/beaker_nosplash

/datum/component/beaker_nosplash/Initialize()
	if(!isatom(parent) || ismob(parent))  // Don't stick this on mobs
		return COMPONENT_INCOMPATIBLE

/datum/component/beaker_nosplash/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attack)

/datum/component/beaker_nosplash/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/beaker_nosplash/proc/on_attack(obj/item/attacked_by, mob/living/attacker, params)
	SIGNAL_HANDLER

	// Returning COMPONENT_NO_AFTERATTACK cancels the afterattack, which is when post-damage effects
	// (like beaker spilling) take place.
	if(attacker.i_select)
	if(istype(attacked_by, /obj/item/reagent_containers/glass/))
		return COMPONENT_NO_AFTERATTACK




