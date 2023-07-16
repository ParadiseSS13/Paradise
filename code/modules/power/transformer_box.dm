#define TRANSFORMER_WATTAGE_DEFAULT 40000

/obj/machinery/power/transformer
	name = "Transformer Box"
	desc = "a step-down transformer which transformer high-voltage power into usable low-voltage power"
	icon = 'icons/obj/power.dmi'
	icon_state = "transformer"
	anchored = TRUE
	density = TRUE
	power_state = NO_POWER_USE

	power_voltage_type = VOLTAGE_LOW
	powernet_connection_type = PW_CONNECTION_NODE

	var/last_output = 0
	var/wattage_setting = TRANSFORMER_WATTAGE_DEFAULT

/obj/machinery/power/transformer/Initialize(mapload)
	. = ..()
	GLOB.transformers += src

	connect_to_network(PW_CONNECTION_CONNECTOR) // connect to our HV connectors first
	connect_to_network(PW_CONNECTION_NODE) // then the wire nodes underneath

/obj/machinery/power/transformer/Destroy()
	GLOB.transformers -= src
	return ..()

/obj/machinery/power/transformer/produce_direct_power(amount)
	. = ..()
	if(!.)
		return
	last_output = amount
