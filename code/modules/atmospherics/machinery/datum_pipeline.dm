/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs = list()

	var/list/obj/machinery/atmospherics/pipe/members = list()
	var/list/obj/machinery/atmospherics/other_atmosmch = list()

	var/update = TRUE

/datum/pipeline/New()
	SSair.pipenets += src

/datum/pipeline/Destroy()
	SSair.pipenets -= src
	if(air && air.volume)
		temporarily_store_air()
	for(var/obj/machinery/atmospherics/pipe/P in members)
		P.parent = null
	for(var/obj/machinery/atmospherics/A in other_atmosmch)
		A.nullifyPipenet(src)
	return ..()

/datum/pipeline/process()//This use to be called called from the pipe networks
	if(update)
		update = FALSE
		reconcile_air()
	return

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	var/volume = 0
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/E = base
		volume = E.volume
		members += E
		if(E.air_temporary)
			air = E.air_temporary
			E.air_temporary = null
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

							if(item.air_temporary)
								air.merge(item.air_temporary)
								item.air_temporary = null
					else
						P.setPipenet(src, borderline)
						addMachineryMember(P)

			possible_expansions -= borderline

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

/datum/pipeline/proc/temporarily_store_air()
	//Update individual gas_mixtures by volume ratio

	for(var/obj/machinery/atmospherics/pipe/member in members)
		member.air_temporary = new
		member.air_temporary.volume = member.volume

		member.air_temporary.set_oxygen(air.oxygen() * member.volume / air.volume)
		member.air_temporary.set_nitrogen(air.nitrogen() * member.volume / air.volume)
		member.air_temporary.set_toxins(air.toxins() * member.volume / air.volume)
		member.air_temporary.set_carbon_dioxide(air.carbon_dioxide() * member.volume / air.volume)
		member.air_temporary.set_sleeping_agent(air.sleeping_agent() * member.volume / air.volume)
		member.air_temporary.set_agent_b(air.agent_b() * member.volume / air.volume)

		member.air_temporary.set_temperature(air.temperature())

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
			else
				return 1

			pipeline.air.set_temperature(pipeline.air.temperature() + self_temperature_delta)

			environment.set_temperature(environment.temperature() + sharer_temperature_delta)


	else
		if((target.heat_capacity>0) && (partial_heat_capacity>0))
			var/delta_temperature = pipeline.air.temperature() - target.temperature

			var/heat = thermal_conductivity * delta_temperature * \
				(partial_heat_capacity * target.heat_capacity / (partial_heat_capacity + target.heat_capacity))

			pipeline.air.set_temperature(pipeline.air.temperature() - heat / total_heat_capacity)
	pipeline.update = TRUE

/datum/pipeline/proc/reconcile_air()
	var/list/datum/gas_mixture/GL = list()
	var/list/datum/pipeline/PL = list()
	PL += src

	for(var/i=1;i<=length(PL);i++)
		var/datum/pipeline/P = PL[i]
		if(!P)
			return
		GL += P.air
		GL += P.other_airs
		for(var/obj/machinery/atmospherics/binary/valve/V in P.other_atmosmch)
			if(V.open)
				PL |= V.parent1
				PL |= V.parent2
		for(var/obj/machinery/atmospherics/trinary/tvalve/T in P.other_atmosmch)
			if(!T.state)
				if(src != T.parent2) // otherwise dc'd side connects to both other sides!
					PL |= T.parent1
					PL |= T.parent3
			else
				if(src != T.parent3)
					PL |= T.parent1
					PL |= T.parent2
		for(var/obj/machinery/atmospherics/unary/portables_connector/C in P.other_atmosmch)
			if(C.connected_device)
				GL += C.portableConnectorReturnAir()

	share_many_airs(GL)
