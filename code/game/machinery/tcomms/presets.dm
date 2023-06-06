/*
	All machine presets go in here
*/

// STATION CORE //
/obj/machinery/tcomms/core/station
	network_id = "STATION-CORE"

// MINING RELAY //
/obj/machinery/tcomms/relay/mining
	network_id = "MINING-RELAY"
	autolink_id = "STATION-CORE"

// ENGINEERING RELAY //
/obj/machinery/tcomms/relay/engineering
	network_id = "ENGINEERING-RELAY"
	autolink_id = "STATION-CORE"
	active = FALSE

// RUSKIE RELAY //
/obj/machinery/tcomms/relay/ruskie
	network_id = "RUSKIE-RELAY"
	autolink_id = "STATION-CORE"
	active = FALSE
	hidden_link = TRUE

// CC RELAY //
/obj/machinery/tcomms/relay/cc
	network_id = "CENTCOMM-RELAY"
	autolink_id = "STATION-CORE"
	hidden_link = TRUE

// USSP CORE //
/obj/machinery/tcomms/core/ussp
	network_id = "USSP-CORE"

// GORKY17 RELAY //
/obj/machinery/tcomms/relay/gorky17
	network_id = "GORKY17-RELAY"
	autolink_id = "USSP-CORE"
	active = TRUE
	hidden_link = TRUE
