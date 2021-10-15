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
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attack_by)

/datum/component/beaker_nosplash/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)

/datum/component/beaker_nosplash/proc/on_attack_by(datum/host, obj/item/weapon, obj/item/target, mob/living/attacker, params)
	SIGNAL_HANDLER

	if(istype(weapon, /obj/item/reagent_containers/glass) && attacker.a_intent == INTENT_HARM)
		// Spilling happens in afterattack, returning this makes afterattacks not be called
		return COMPONENT_NO_AFTERATTACK
