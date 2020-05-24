/obj/machinery/atmospherics/unary/tank
	icon = 'icons/atmos/tank.dmi'
	icon_state = "air_map"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800

	var/volume = 10000 //in liters, 1 meters by 1 meters by 2 meters ~tweaked it a little to simulate a pressure tank without needing to recode them yet

	density = 1

/obj/machinery/atmospherics/unary/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/tank/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/analyzer))
		atmosanalyzer_scan(air_contents, user)
		return

	return ..()

/obj/machinery/atmospherics/unary/tank/air
	name = "Pressure Tank (Air)"
	icon_state = "air_map"

/obj/machinery/atmospherics/unary/tank/air/New()
	..()
	icon_state = "air"
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
	air_contents.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/oxygen
	name = "Pressure Tank (Oxygen)"
	icon_state = "o2_map"

/obj/machinery/atmospherics/unary/tank/oxygen/New()
	..()
	icon_state = "o2"
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.oxygen = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrogen
	name = "Pressure Tank (Nitrogen)"
	icon_state = "n2_map"

/obj/machinery/atmospherics/unary/tank/nitrogen/New()
	..()
	icon_state = "n2"
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.nitrogen = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"
	icon_state = "co2_map"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/New()
	..()
	icon_state = "co2"
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/toxins
	name = "Pressure Tank (Toxins)"
	icon_state = "toxins_map"

/obj/machinery/atmospherics/unary/tank/toxins/New()
	..()
	icon_state = "toxins"
	air_contents.volume = volume
	air_contents.temperature = T20C
	air_contents.toxins = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

/obj/machinery/atmospherics/unary/tank/nitrous_oxide
	name = "Pressure Tank (Nitrous Oxide)"
	icon_state = "n2o_map"

/obj/machinery/atmospherics/unary/tank/nitrous_oxide/New()
	..()
	icon_state = "n2o"
	air_contents.volume = volume
	air_contents.temperature = T20C

	var/datum/gas/sleeping_agent/trace_gas = new
	trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

	air_contents.trace_gases += trace_gas

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	name = "Unidentified Gas Tank"
	desc = "A large vessel containing an unknown pressurized gas."
	icon_state = "agent_b_map"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/New()
	..()
	icon_state = "agent_b"
	air_contents.volume = volume
	air_contents.temperature = T20C

	var/datum/gas/oxygen_agent_b/trace_gas = new
	trace_gas.moles = (50 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.trace_gases += trace_gas
