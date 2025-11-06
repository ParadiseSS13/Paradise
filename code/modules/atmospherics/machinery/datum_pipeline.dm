/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs = list()

	var/list/obj/machinery/atmospherics/pipe/members = list()
	var/list/obj/machinery/atmospherics/other_atmosmch = list()

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
	other_atmosmch.Add(E.other_atmosmch)
	other_airs.Add(E.other_airs)
	E.members.Cut()
	E.other_atmosmch.Cut()
	qdel(E)

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
	var/datum/gas_mixture/environment = get_turf_air(target)

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

		for(var/obj/machinery/atmospherics/binary/valve/V in P.other_atmosmch)
			if(QDELETED(V))
				continue
			if(V.open)
				PL |= V.parent1
				PL |= V.parent2
		for(var/obj/machinery/atmospherics/trinary/tvalve/T in P.other_atmosmch)
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
		for(var/obj/machinery/atmospherics/unary/portables_connector/C in P.other_atmosmch)
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
