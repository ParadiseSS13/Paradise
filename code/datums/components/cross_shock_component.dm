/datum/component/cross_shock
	var/shock_damage
	var/energy_cost
	var/delay_between_shocks
	var/requires_cable

	COOLDOWN_DECLARE(last_shock)

/datum/component/cross_shock/Initialize(_shock_damage, _energy_cost, _delay_between_shocks, _requires_cable = TRUE)
	if(ismovable(parent))
		var/static/list/crossed_connections = list(
			COMSIG_ATOM_ENTERED = PROC_REF(do_shock),
		)
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))
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

/datum/component/cross_shock/proc/on_movable_moved(atom/source, old_location, direction, forced)
	SIGNAL_HANDLER // COMSIG_MOVABLE_MOVED
	if(isturf(source.loc))
		for(var/mob/living/mob in source.loc)
			do_shock(src, mob)

/datum/component/cross_shock/proc/do_shock(atom/source, atom/movable/to_shock)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED
	if(!COOLDOWN_FINISHED(src, last_shock))
		return
	var/mob/living/living_to_shock = to_shock
	if(!istype(living_to_shock))
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
		living_to_shock.electrocute_act(shock_damage, parent)
		to_deduct_from.powernet.use_active_power(energy_cost)
		playsound(get_turf(parent), 'sound/effects/eleczap.ogg', 30, TRUE)
	else
		living_to_shock.electrocute_act(shock_damage, parent)
		playsound(get_turf(parent), 'sound/effects/eleczap.ogg', 30, TRUE)
	COOLDOWN_START(src, last_shock, delay_between_shocks)

/datum/component/cross_shock/proc/on_organ_removal(datum/source)
	SIGNAL_HANDLER
	qdel(src)
