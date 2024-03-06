/datum/component/cross_shock
	var/shock_damage
	var/energy_cost
	var/delay_between_shocks
	var/requires_cable
	COOLDOWN_DECLARE(last_shock)

/datum/component/cross_shock/Initialize(_shock_damage, _energy_cost, _delay_between_shocks, _requires_cable = TRUE)
	if(ismovable(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_CROSSED_MOVABLE), PROC_REF(do_shock))
		if(ismob(parent))
			RegisterSignal(parent, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(on_organ_removal))
	else if(isarea(parent))
		RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(do_shock))
	else if(isturf(parent))
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(do_shock))
	else
		return COMPONENT_INCOMPATIBLE

	shock_damage = _shock_damage
	energy_cost = _energy_cost
	delay_between_shocks = _delay_between_shocks
	requires_cable = _requires_cable

/datum/component/cross_shock/proc/do_shock(datum/source, mob/living/thing_were_gonna_shock)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, last_shock))
		return
	if(!istype(thing_were_gonna_shock))
		return
	if(isliving(parent))
		var/mob/living/M = parent
		if(M.stat == DEAD || !IS_HORIZONTAL(M))
			return
	if(requires_cable)
		var/turf/our_turf = get_turf(parent)
		if(our_turf.transparent_floor || our_turf.intact || HAS_TRAIT(our_turf, TRAIT_TURF_COVERED))
			return
		var/obj/structure/cable/our_cable =	locate(/obj/structure/cable) in our_turf
		if(!our_cable || !our_cable.powernet || !our_cable.powernet.available_power)
			return
		var/area/to_deduct_from = get_area(our_cable)
		thing_were_gonna_shock.electrocute_act(shock_damage, source)
		to_deduct_from.powernet.use_active_power(energy_cost)
		playsound(get_turf(parent), 'sound/effects/eleczap.ogg', 30, TRUE)
	else
		thing_were_gonna_shock.electrocute_act(shock_damage, source)
		playsound(get_turf(parent), 'sound/effects/eleczap.ogg', 30, TRUE)
	COOLDOWN_START(src, last_shock, delay_between_shocks)

/datum/component/cross_shock/proc/on_organ_removal(datum/source)
	SIGNAL_HANDLER
	qdel(src)
