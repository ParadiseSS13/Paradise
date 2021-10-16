/datum/element/beaker_nosplash

/datum/element/beaker_nosplash/Attach(datum/target)
	. = ..()
	if(!isatom(target) || ismob(target))  // Don't stick this on mobs
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, .proc/on_attack_by)

/datum/element/beaker_nosplash/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, COMSIG_PARENT_ATTACKBY)

/datum/element/beaker_nosplash/proc/on_attack_by(datum/host, obj/item/weapon, obj/item/target, mob/living/attacker, params)
	SIGNAL_HANDLER

	if(istype(weapon, /obj/item/reagent_containers/glass) && attacker.a_intent == INTENT_HARM)
		// Spilling happens in afterattack, returning this makes afterattacks not be called
		return COMPONENT_NO_AFTERATTACK
