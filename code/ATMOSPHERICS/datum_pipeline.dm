var/global/list/pipe_networks = list()
var/global/list/deferred_pipenet_rebuilds = list()

/datum/pipeline
	var/datum/gas_mixture/air
	var/list/datum/gas_mixture/other_airs = list()

	var/list/obj/machinery/atmospherics/pipe/members = list()
	var/list/obj/machinery/atmospherics/other_atmosmch = list()

	var/update = 1

	var/alert_pressure = 0

/datum/pipeline/New()
	pipe_networks += src

/datum/pipeline/Destroy()
	pipe_networks -= src
	if(air && air.volume)
		temporarily_store_air()
	for(var/obj/machinery/atmospherics/pipe/P in members)
		P.parent = null
	for(var/obj/machinery/atmospherics/A in other_atmosmch)
		A.nullifyPipenet(src)
	return ..()

/datum/pipeline/proc/process()//This use to be called called from the pipe networks
	if(update)
		update = 0
		reconcile_air()
	return

var/pipenetwarnings = 10

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	var/volume = 0
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/E = base
		volume = E.volume
		alert_pressure = E.alert_pressure
		members += E
		if(E.air_temporary)
			air = E.air_temporary
			E.air_temporary = null
	else
		addMachineryMember(base)
	if(!air)
		air = new
	var/list/possible_expansions = list(base)
	while(possible_expansions.len>0)
		for(var/obj/machinery/atmospherics/borderline in possible_expansions)

			var/list/result = borderline.pipeline_expansion(src)

			if(result.len>0)
				for(var/obj/machinery/atmospherics/P in result)
					if(istype(P, /obj/machinery/atmospherics/pipe))
						var/obj/machinery/atmospherics/pipe/item = P
						if(!members.Find(item))

							if(item.parent)
								if(pipenetwarnings > 0)
									error("[item.type] added to a pipenet while still having one (pipes leading to the same spot stacking in one turf). Nearby: [item.x], [item.y], [item.z].")
									pipenetwarnings -= 1
									if(pipenetwarnings == 0)
										error("Further messages about pipenets will be suppressed.")
							members += item
							possible_expansions += item

							volume += item.volume
							item.parent = src

							alert_pressure = min(alert_pressure, item.alert_pressure)

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
	return

/obj/machinery/atmospherics/pipe/addMember(obj/machinery/atmospherics/A)
	parent.addMember(A, src)

/obj/machinery/atmospherics/addMember(obj/machinery/atmospherics/A)
	var/datum/pipeline/P = returnPipenet(A)
	P.addMember(A, src)

/datum/pipeline/proc/temporarily_store_air()
	//Update individual gas_mixtures by volume ratio

	for(var/obj/machinery/atmospherics/pipe/member in members)
		member.air_temporary = new
		member.air_temporary.volume = member.volume

		member.air_temporary.oxygen = air.oxygen*member.volume/air.volume
		member.air_temporary.nitrogen = air.nitrogen*member.volume/air.volume
		member.air_temporary.toxins = air.toxins*member.volume/air.volume
		member.air_temporary.carbon_dioxide = air.carbon_dioxide*member.volume/air.volume

		member.air_temporary.temperature = air.temperature

		if(air.trace_gases.len)
			for(var/datum/gas/trace_gas in air.trace_gases)
				var/datum/gas/corresponding = new trace_gas.type()
				member.air_temporary.trace_gases += corresponding

				corresponding.moles = trace_gas.moles*member.volume/air.volume

/datum/pipeline/proc/temperature_interact(turf/target, share_volume, thermal_conductivity)
	var/total_heat_capacity = air.heat_capacity()
	var/partial_heat_capacity = total_heat_capacity*(share_volume/air.volume)

	if(istype(target, /turf/simulated))
		var/turf/simulated/modeled_location = target

		if(modeled_location.blocks_air)

			if((modeled_location.heat_capacity>0) && (partial_heat_capacity>0))
				var/delta_temperature = air.temperature - modeled_location.temperature

				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*modeled_location.heat_capacity/(partial_heat_capacity+modeled_location.heat_capacity))

				air.temperature -= heat/total_heat_capacity
				modeled_location.temperature += heat/modeled_location.heat_capacity

		else
			var/delta_temperature = 0
			var/sharer_heat_capacity = 0

			delta_temperature = (air.temperature - modeled_location.air.temperature)
			sharer_heat_capacity = modeled_location.air.heat_capacity()

			var/self_temperature_delta = 0
			var/sharer_temperature_delta = 0

			if((sharer_heat_capacity>0) && (partial_heat_capacity>0))
				var/heat = thermal_conductivity*delta_temperature* \
					(partial_heat_capacity*sharer_heat_capacity/(partial_heat_capacity+sharer_heat_capacity))

				self_temperature_delta = -heat/total_heat_capacity
				sharer_temperature_delta = heat/sharer_heat_capacity
			else
				return 1

			air.temperature += self_temperature_delta

			modeled_location.air.temperature += sharer_temperature_delta


	else
		if((target.heat_capacity>0) && (partial_heat_capacity>0))
			var/delta_temperature = air.temperature - target.temperature

			var/heat = thermal_conductivity*delta_temperature* \
				(partial_heat_capacity*target.heat_capacity/(partial_heat_capacity+target.heat_capacity))

			air.temperature -= heat/total_heat_capacity
	update = 1

/datum/pipeline/proc/reconcile_air()
	var/list/datum/gas_mixture/GL = list()
	var/list/datum/pipeline/PL = list()
	PL += src

	for(var/i=1;i<=PL.len;i++)
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

	var/total_volume = 0
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0
	var/total_oxygen = 0
	var/total_nitrogen = 0
	var/total_toxins = 0
	var/total_carbon_dioxide = 0
	var/list/total_trace_gases = list()

	for(var/datum/gas_mixture/G in GL)
		total_volume += G.volume
		total_thermal_energy += G.thermal_energy()
		total_heat_capacity += G.heat_capacity()

		total_oxygen += G.oxygen
		total_nitrogen += G.nitrogen
		total_toxins += G.toxins
		total_carbon_dioxide += G.carbon_dioxide

		if(G.trace_gases.len)
			for(var/datum/gas/trace_gas in G.trace_gases)
				var/datum/gas/corresponding = locate(trace_gas.type) in total_trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					total_trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	if(total_volume > 0)

		//Calculate temperature
		var/temperature = 0

		if(total_heat_capacity > 0)
			temperature = total_thermal_energy/total_heat_capacity

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/G in GL)
			G.oxygen = total_oxygen*G.volume/total_volume
			G.nitrogen = total_nitrogen*G.volume/total_volume
			G.toxins = total_toxins*G.volume/total_volume
			G.carbon_dioxide = total_carbon_dioxide*G.volume/total_volume

			G.temperature = temperature

			if(total_trace_gases.len)
				for(var/datum/gas/trace_gas in total_trace_gases)
					var/datum/gas/corresponding = locate(trace_gas.type) in G.trace_gases
					if(!corresponding)
						corresponding = new trace_gas.type()
						G.trace_gases += corresponding

					corresponding.moles = trace_gas.moles*G.volume/total_volume
