/obj/machinery/atmospherics/unary/tank
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."
	icon = 'icons/atmos/tank.dmi'
	icon_state = "air_map"
	layer = GAS_PIPE_VISIBLE_LAYER
	max_integrity = 800
	density = TRUE
	/// in liters, 1 meters by 1 meters by 2 meters
	var/volume = 10000

/obj/machinery/atmospherics/unary/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/tank/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/unary/tank/air
	name = "Pressure Tank (Air)"

/obj/machinery/atmospherics/unary/tank/air/Initialize(mapload)
	. = ..()
	icon_state = "air"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	air_contents.set_oxygen((25 * ONE_ATMOSPHERE * O2STANDARD) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))
	air_contents.set_nitrogen((25 * ONE_ATMOSPHERE * N2STANDARD) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/oxygen
	name = "Pressure Tank (Oxygen)"
	icon_state = "o2_map"

/obj/machinery/atmospherics/unary/tank/oxygen/Initialize(mapload)
	. = ..()
	icon_state = "o2"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	air_contents.set_oxygen((25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/nitrogen
	name = "Pressure Tank (Nitrogen)"
	icon_state = "n2_map"

/obj/machinery/atmospherics/unary/tank/nitrogen/Initialize(mapload)
	. = ..()
	icon_state = "n2"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	air_contents.set_nitrogen((25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"
	icon_state = "co2_map"

/obj/machinery/atmospherics/unary/tank/carbon_dioxide/Initialize(mapload)
	. = ..()
	icon_state = "co2"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	air_contents.set_carbon_dioxide((25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/toxins
	name = "Pressure Tank (Toxins)"
	icon_state = "toxins_map"

/obj/machinery/atmospherics/unary/tank/toxins/Initialize(mapload)
	. = ..()
	icon_state = "toxins"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)
	air_contents.set_toxins((25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/nitrous_oxide
	name = "Pressure Tank (Nitrous Oxide)"
	icon_state = "n2o_map"

/obj/machinery/atmospherics/unary/tank/nitrous_oxide/Initialize(mapload)
	. = ..()
	icon_state = "n2o"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)

	air_contents.set_sleeping_agent((25 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b
	name = "Unidentified Gas Tank"
	desc = "A large vessel containing an unknown pressurized gas."
	icon_state = "agent_b_map"

/obj/machinery/atmospherics/unary/tank/oxygen_agent_b/Initialize(mapload)
	. = ..()
	icon_state = "agent_b"
	air_contents.volume = volume
	air_contents.set_temperature(T20C)

	air_contents.set_agent_b((50 * ONE_ATMOSPHERE) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))
