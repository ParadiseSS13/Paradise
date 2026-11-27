/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs = list()

	var/list/obj/machinery/atmospherics/pipe/members = list()
	var/list/obj/machinery/atmospherics/other_atmosmch = list()
	/// The valves and connectors in other_atmosmch, the only machinery reconcile_air() needs to look at
	var/list/obj/machinery/atmospherics/reconcile_machinery = list()

	var/update = TRUE

	var/list/crawlers = list()

/datum/pipeline/New()
	SSair.pipenets += src

/datum/pipeline/Destroy()
	SSair.pipenets -= src
	var/datum/gas_mixture/ghost = null
	if(air && air.volume)
		ghost = air
		air = null
	for(var/obj/machinery/atmospherics/pipe/P in members)
		if(QDELETED(P))
			continue
		P.ghost_pipeline = ghost
		P.parent = null
	for(var/obj/machinery/atmospherics/A in other_atmosmch)
		A.nullifyPipenet(src)

	other_airs.Cut()
	members.Cut()
	other_atmosmch.Cut()
	reconcile_machinery.Cut()
	return ..()

/datum/pipeline/process()//This use to be called called from the pipe networks
	if(update)
		update = FALSE
		reconcile_air()
	return

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	var/volume = 0
	var/list/ghost_pipelines = list()
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/E = base
		volume = E.volume
		members += E
		if(E.ghost_pipeline)
			ghost_pipelines[E.ghost_pipeline] = E.volume
			E.ghost_pipeline = null
	else
		addMachineryMember(base)
	if(!air)
		air = new
	var/list/possible_expansions = list(base)
	while(length(possible_expansions)>0)
		for(var/obj/machinery/atmospherics/borderline in possible_expansions)

			var/list/result = borderline.pipeline_expansion(src)

			if(length(result)>0)
				for(var/obj/machinery/atmospherics/P in result)
					if(istype(P, /obj/machinery/atmospherics/pipe))
						var/obj/machinery/atmospherics/pipe/item = P
						if(!members.Find(item))

							if(item.parent)
								stack_trace("[item.type] \[\ref[item]] added to a pipenet while still having one ([item.parent]) (pipes leading to the same spot stacking in one turf). Nearby: [item.x], [item.y], [item.z].")
							members += item
							possible_expansions += item

							volume += item.volume
							item.parent = src

							if(item.ghost_pipeline)
								if(!ghost_pipelines[item.ghost_pipeline])
									ghost_pipelines[item.ghost_pipeline] = item.volume
								else
									ghost_pipelines[item.ghost_pipeline] += item.volume
								item.ghost_pipeline = null
					else
						P.setPipenet(src, borderline)
						addMachineryMember(P)

			possible_expansions -= borderline

	for(var/datum/gas_mixture/ghost in ghost_pipelines)
		var/collected_ghost_volume = ghost_pipelines[ghost]
		var/collected_fraction = collected_ghost_volume / ghost.volume

		var/datum/gas_mixture/ghost_copy = new()
		ghost_copy.copy_from(ghost)
		air.merge(ghost_copy.remove_ratio(collected_fraction))

	air.volume = volume

/datum/pipeline/proc/addMachineryMember(obj/machinery/atmospherics/A)
	other_atmosmch |= A
	if(istype(A, /obj/machinery/atmospherics/binary/valve) || istype(A, /obj/machinery/atmospherics/trinary/tvalve) || istype(A, /obj/machinery/atmospherics/unary/portables_connector))
		reconcile_machinery |= A
	var/datum/gas_mixture/G = A.returnPipenetAir(src)
	other_airs |= G

/datum/pipeline/proc/addMember(obj/machinery/atmospherics/A, obj/machinery/atmospherics/N)
	update = TRUE
	if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		P.parent = src
		var/list/adjacent = P.pipeline_expansion()
		for(var/obj/machinery/atmospherics/pipe/I in adjacent)
			if(I.parent == src)
				continue
			var/datum/pipeline/E = I.parent
			merge(E)
		if(!members.Find(P))
			members += P
			air.volume += P.volume
	else
		A.setPipenet(src, N)
		addMachineryMember(A)

/datum/pipeline/proc/merge(datum/pipeline/E)
	air.volume += E.air.volume
	members.Add(E.members)
	for(var/obj/machinery/atmospherics/pipe/S in E.members)
		S.parent = src
	air.merge(E.air)
	for(var/obj/machinery/atmospherics/A in E.other_atmosmch)
		A.replacePipenet(E, src)
	// A machine with a side on each of us is on both lists, don't list it twice
	other_atmosmch |= E.other_atmosmch
	reconcile_machinery |= E.reconcile_machinery
	other_airs |= E.other_airs
	E.members.Cut()
	E.other_atmosmch.Cut()
	E.reconcile_machinery.Cut()
	qdel(E)

/// Takes a pipe that's going away out of this pipenet, instead of throwing the whole pipenet away and building it again.
/// Its share of the gas goes with it. Machines joined to it get pipenets of their own when it lets go of them.
/datum/pipeline/proc/remove_pipe(obj/machinery/atmospherics/pipe/gone)
	members -= gone
	gone.parent = null
	if(air.volume > 0)
		air.remove_ratio(gone.volume / air.volume)
	air.volume -= gone.volume
	update = TRUE
	if(!length(members))
		qdel(src)
		return
	var/list/joined = list()
	for(var/obj/machinery/atmospherics/pipe/P in gone.pipeline_expansion())
		if(P.parent == src)
			joined |= P
	// With one pipe or less next to it nothing can be cut off
	if(length(joined) > 1)
		split_off_pieces(joined)

/// Walks out from each pipe the gone one was joined to, one pipe from each walk at a time.
/// Walks that meet are on the same piece. A walk that runs out of pipes found a piece that's cut off.
/// Stops when one walk is left going, that one is the piece we keep. So it only walks about as far as the smaller pieces.
/datum/pipeline/proc/split_off_pieces(list/starts)
	var/walks = length(starts)
	/// Which walk found each pipe
	var/list/found_by = list()
	/// Pipes each walk still has to look past
	var/list/to_visit = list()
	/// Pipes each walk found
	var/list/found = list()
	/// The walk each walk got joined into, or itself
	var/list/joined_into = list()
	for(var/i in 1 to walks)
		found_by[starts[i]] = i
		to_visit += list(list(starts[i]))
		found += list(list(starts[i]))
		joined_into += i
	var/list/cut_off = list()
	var/going = walks
	while(going > 1)
		for(var/i in 1 to walks)
			if(joined_into[i] != i)
				continue
			var/list/visit = to_visit[i]
			if(!length(visit))
				continue
			var/list/mine = found[i]
			var/obj/machinery/atmospherics/pipe/current = visit[length(visit)]
			visit.len--
			for(var/obj/machinery/atmospherics/pipe/next in current.pipeline_expansion())
				if(next.parent != src)
					continue
				var/other = found_by[next]
				if(!other)
					found_by[next] = i
					visit += next
					mine += next
					continue
				while(joined_into[other] != other)
					other = joined_into[other]
				if(other == i)
					continue
				// Met another walk, so it's all one piece
				joined_into[other] = i
				visit += to_visit[other]
				mine += found[other]
				going--
			if(!length(visit))
				cut_off += list(mine)
				going--
			if(going <= 1)
				break
	for(var/list/piece in cut_off)
		make_piece(piece)

/// Gives some of our pipes a pipenet of their own, with their share of the gas and the machines on them
/datum/pipeline/proc/make_piece(list/pipes)
	var/datum/pipeline/piece = new()
	var/piece_volume = 0
	for(var/obj/machinery/atmospherics/pipe/P as anything in pipes)
		P.parent = piece
		piece_volume += P.volume
		for(var/obj/machinery/atmospherics/A in P.pipeline_expansion())
			if(!istype(A, /obj/machinery/atmospherics/pipe))
				A.setPipenet(piece, P)
				piece.addMachineryMember(A)
	piece.members = pipes
	members -= pipes
	piece.air = new()
	piece.air.volume = piece_volume
	if(air.volume > 0)
		piece.air.merge(air.remove_ratio(piece_volume / air.volume))
	air.volume -= piece_volume
	for(var/obj/machinery/atmospherics/A as anything in piece.other_atmosmch)
		if(!has_machine(A))
			other_atmosmch -= A
			reconcile_machinery -= A
	// A machine can have more than one air here, so list them again the way building a pipenet does
	other_airs.Cut()
	for(var/obj/machinery/atmospherics/A as anything in other_atmosmch)
		other_airs |= A.returnPipenetAir(src)

/// One of a machine's sides moved off this pipenet. It stays on it if another of its sides is still here.
/datum/pipeline/proc/machine_side_left(obj/machinery/atmospherics/A, datum/gas_mixture/side_air)
	other_airs -= side_air
	if(has_machine(A))
		other_airs |= A.returnPipenetAir(src)
	else
		other_atmosmch -= A
		reconcile_machinery -= A

/// If any side of this machine is on us
/datum/pipeline/proc/has_machine(obj/machinery/atmospherics/A)
	var/list/pipelines = A.get_machinery_pipelines()
	// Unary machines give back their one pipenet, not a list
	return islist(pipelines) ? (src in pipelines) : pipelines == src

/obj/machinery/atmospherics/proc/addMember(obj/machinery/atmospherics/A)
	var/datum/pipeline/P = returnPipenet(A)
	P.addMember(A, src)

/obj/machinery/atmospherics/pipe/addMember(obj/machinery/atmospherics/A)
	parent.addMember(A, src)

/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	var/datum/milla_safe/pipeline_temperature_interact/milla = new()
	milla.invoke_async(src, target, share_volume, thermal_conductivity)

/datum/milla_safe/pipeline_temperature_interact

/datum/milla_safe/pipeline_temperature_interact/on_run(datum/pipeline/pipeline, turf/target, share_volume, thermal_conductivity)
	var/total_heat_capacity = pipeline.air.heat_capacity()
	var/partial_heat_capacity = total_heat_capacity*(share_volume/pipeline.air.volume)

	if(issimulatedturf(target))
		var/turf/simulated/modeled_location = target

		if(modeled_location.blocks_air)

			if((modeled_location.heat_capacity>0) && (partial_heat_capacity>0))
				var/delta_temperature = pipeline.air.temperature() - modeled_location.temperature

				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*modeled_location.heat_capacity/(partial_heat_capacity+modeled_location.heat_capacity))

				if(!IS_IN_BOUNDS(heat, -1e10, 1e10))
					CRASH("Sharing [partial_heat_capacity] @ [pipeline.air.temperature()]K with solid-wall environment [modeled_location.heat_capacity] @ [modeled_location.temperature]K produced out-of-bounds heat transfer [heat]!")

				pipeline.air.set_temperature(pipeline.air.temperature() - heat / total_heat_capacity)
				modeled_location.temperature += heat/modeled_location.heat_capacity

		else
			// Only open tiles share heat with their air, walls and space use the turf's own temperature
			var/datum/gas_mixture/environment = get_turf_air(target)
			var/delta_temperature = 0
			var/sharer_heat_capacity = 0

			delta_temperature = (pipeline.air.temperature() - environment.temperature())
			sharer_heat_capacity = environment.heat_capacity()

			var/self_temperature_delta = 0
			var/sharer_temperature_delta = 0

			if((sharer_heat_capacity>0) && (partial_heat_capacity>0))
				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*sharer_heat_capacity/(partial_heat_capacity+sharer_heat_capacity))

				self_temperature_delta = -heat/total_heat_capacity
				sharer_temperature_delta = heat/sharer_heat_capacity

				if(!IS_IN_BOUNDS(heat, -1e10, 1e10))
					CRASH("Sharing [partial_heat_capacity] @ [pipeline.air.temperature()]K with environment [sharer_heat_capacity] @ [environment.temperature()]K produced out-of-bounds heat transfer [heat]!")
			else
				return 1

			pipeline.air.set_temperature(pipeline.air.temperature() + self_temperature_delta)

			environment.set_temperature(environment.temperature() + sharer_temperature_delta)


	else
		if((target.heat_capacity>0) && (partial_heat_capacity>0))
			var/delta_temperature = pipeline.air.temperature() - target.temperature

			var/heat = thermal_conductivity * delta_temperature * \
				(partial_heat_capacity * target.heat_capacity / (partial_heat_capacity + target.heat_capacity))

			if(!IS_IN_BOUNDS(heat, -1e10, 1e10))
				CRASH("Sharing [partial_heat_capacity] @ [pipeline.air.temperature()]K with static environment [target.heat_capacity] @ [target.temperature]K produced out-of-bounds heat transfer [heat]!")
			pipeline.air.set_temperature(pipeline.air.temperature() - heat / total_heat_capacity)
	pipeline.update = TRUE

/datum/pipeline/proc/reconcile_air()
	var/list/datum/gas_mixture/GL = list()
	var/list/datum/pipeline/PL = list()
	PL += src

	for(var/i=1;i<=length(PL);i++)
		var/datum/pipeline/P = PL[i]
		if(!istype(P) || QDELETED(P) || isnull(P.air))
			continue
		GL += P.air
		GL += P.other_airs

		for(var/obj/machinery/atmospherics/binary/valve/V in P.reconcile_machinery)
			if(QDELETED(V))
				continue
			if(V.open)
				PL |= V.parent1
				PL |= V.parent2
		for(var/obj/machinery/atmospherics/trinary/tvalve/T in P.reconcile_machinery)
			if(QDELETED(T))
				continue
			if(!T.state)
				if(src != T.parent2) // otherwise dc'd side connects to both other sides!
					PL |= T.parent1
					PL |= T.parent3
			else
				if(src != T.parent3)
					PL |= T.parent1
					PL |= T.parent2
		for(var/obj/machinery/atmospherics/unary/portables_connector/C in P.reconcile_machinery)
			if(QDELETED(C))
				continue
			if(C.connected_device)
				GL += C.portableConnectorReturnAir()

	if(length(members))
		share_many_airs(GL, members[1])
	else if(length(other_atmosmch))
		share_many_airs(GL, other_atmosmch[1])
	// If neither has anything, GL will have no volumen, so nothing to share.

/datum/pipeline/proc/add_ventcrawler(mob/living/crawler)
	if(!(crawler in crawlers))
		RegisterSignal(crawler, COMSIG_LIVING_EXIT_VENTCRAWL, PROC_REF(remove_ventcrawler), crawler)
		crawlers += crawler

/datum/pipeline/proc/remove_ventcrawler(mob/living/crawler)
	UnregisterSignal(crawler, COMSIG_LIVING_EXIT_VENTCRAWL)
	crawlers -= crawler

/**
 * Gets all pipelines connected to this with valves, including src.
 */
/datum/pipeline/proc/get_connected_pipelines()
	. = list()
	var/list/possible_expansions = list(src)
	while(length(possible_expansions))
		var/datum/pipeline/P = popleft(possible_expansions)
		if(!P)
			break
		. |= P
		for(var/obj/machinery/atmospherics/V in P.other_atmosmch)
			for(var/datum/pipeline/possible in V.get_machinery_pipelines())
				if(possible in .)
					continue
				possible_expansions |= possible

/datum/pipeline/proc/get_ventcrawls(check_welded = TRUE)
	. = list()
	for(var/datum/pipeline/P in get_connected_pipelines())
		for(var/obj/machinery/atmospherics/V in P.other_atmosmch)
			if(!is_type_in_list(V, GLOB.ventcrawl_machinery))
				continue
			if(check_welded && !V.can_crawl_through())
				continue
			. |= V
