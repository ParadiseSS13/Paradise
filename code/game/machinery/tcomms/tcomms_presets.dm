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

// RUSKIE RELAY //
/obj/machinery/tcomms/relay/ruskie
	network_id = "RUSKIE-RELAY"
	autolink_id = "STATION-CORE"
	hidden_link = TRUE

// CC RELAY //
/obj/machinery/tcomms/relay/cc
	network_id = "CENTCOMM-RELAY"
	autolink_id = "STATION-CORE"
	hidden_link = TRUE
	password_bypass = TRUE

/// DVORAK RELAY
/obj/machinery/tcomms/relay/dvorak
	network_id = "DEBUG_RELAY_DO_NOT_REMOVE" // I'll change this if needed to avoid confusion, but if I was trying to sneak into a relay system, well...
	autolink_id = "STATION-CORE"
	hidden_link = TRUE
	password_bypass = TRUE // No one can steal this anyway.
	active = TRUE

GLOBAL_VAR(cc_tcomms_relay_uid)
/obj/machinery/tcomms/relay/cc/Initialize(mapload)
	. = ..()
	GLOB.cc_tcomms_relay_uid = UID()
