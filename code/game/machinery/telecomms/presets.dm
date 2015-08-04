// ### Preset machines  ###

//Relay

/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	listening_level = 1
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = 0
	autolinkers = list("r_relay")
	
/obj/machinery/telecomms/relay/preset/engioutpost
	id = "Engineering Outpost"
	hide = 1
	toggled = 0
	autolinkers = list("e_relay")

/obj/machinery/telecomms/relay/preset/centcom
	id = "Centcom Relay"
	hide = 1
	toggled = 1
	//anchored = 1
	use_power = 0
	//idle_power_usage = 0
	heatgen = 0
	autolinkers = list("c_relay")

//HUB

/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "c_relay", "s_relay", "m_relay", "r_relay", "e_relay", "science", "medical",
	"supply", "service", "common", "command", "engineering", "security",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")
	
/obj/machinery/telecomms/hub/preset_cent
	id = "CentComm Hub"
	network = "tcommsat"
	use_power = 0
	autolinkers = list("hub_cent", "c_relay", "s_relay", "m_relay", "r_relay", "e_relay",
	 "centcomm", "receiverCent", "broadcasterCent")

//Receivers

//--PRESET LEFT--//

/obj/machinery/telecomms/receiver/preset_left
	id = "Receiver A"
	network = "tcommsat"
	autolinkers = list("receiverA") // link to relay
	freq_listening = list(1351, 1355, 1347, 1349) // science, medical, supply, service


//--PRESET RIGHT--//

/obj/machinery/telecomms/receiver/preset_right
	id = "Receiver B"
	network = "tcommsat"
	autolinkers = list("receiverB") // link to relay
	freq_listening = list(1353, 1357, 1359) //command, engineering, security

	//Common and other radio frequencies for people to freely use
	New()
		for(var/i = 1441, i < 1489, i += 2)
			freq_listening |= i
		..()
		
/obj/machinery/telecomms/receiver/preset_cent
	id = "CentComm Receiver"
	network = "tcommsat"
	use_power = 0
	autolinkers = list("receiverCent")
	freq_listening = list(ERT_FREQ, DTH_FREQ)

//Buses

/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	freq_listening = list(1351, 1355)
	autolinkers = list("processor1", "science", "medical")

/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	freq_listening = list(1347,1349)
	autolinkers = list("processor2", "supply", "service")

/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	freq_listening = list(1359, 1353)
	autolinkers = list("processor3", "security", "command")

/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	freq_listening = list(1357)
	autolinkers = list("processor4", "engineering", "common")

/obj/machinery/telecomms/bus/preset_four/New()
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i
	..()
	
/obj/machinery/telecomms/bus/preset_cent
	id = "CentComm Bus"
	network = "tcommsat"
	use_power = 0
	freq_listening = list(ERT_FREQ, DTH_FREQ)
	autolinkers = list("processorCent", "centcomm")

//Processors

/obj/machinery/telecomms/processor/preset_one
	id = "Processor 1"
	network = "tcommsat"
	autolinkers = list("processor1") // processors are sort of isolated; they don't need backward links

/obj/machinery/telecomms/processor/preset_two
	id = "Processor 2"
	network = "tcommsat"
	autolinkers = list("processor2")

/obj/machinery/telecomms/processor/preset_three
	id = "Processor 3"
	network = "tcommsat"
	autolinkers = list("processor3")

/obj/machinery/telecomms/processor/preset_four
	id = "Processor 4"
	network = "tcommsat"
	autolinkers = list("processor4")
	
/obj/machinery/telecomms/processor/preset_cent
	id = "CentComm Processor"
	network = "tcommsat"
	use_power = 0
	autolinkers = list("processorCent")

//Servers

/obj/machinery/telecomms/server/presets

	network = "tcommsat"

/obj/machinery/telecomms/server/presets/science
	id = "Science Server"
	freq_listening = list(1351)
	autolinkers = list("science")

/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	freq_listening = list(1355)
	autolinkers = list("medical")

/obj/machinery/telecomms/server/presets/supply
	id = "Supply Server"
	freq_listening = list(1347)
	autolinkers = list("supply")

/obj/machinery/telecomms/server/presets/service
	id = "Service Server"
	freq_listening = list(1349)
	autolinkers = list("service")	
	
/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	freq_listening = list()
	autolinkers = list("common")

	//Common and other radio frequencies for people to freely use
	// 1441 to 1489
/obj/machinery/telecomms/server/presets/common/New()
	for(var/i = 1441, i < 1489, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(1353)
	autolinkers = list("command")

/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(1357)
	autolinkers = list("engineering")

/obj/machinery/telecomms/server/presets/security
	id = "Security Server"
	freq_listening = list(1359)
	autolinkers = list("security")

/obj/machinery/telecomms/server/presets/centcomm
	id = "CentComm Server"
	freq_listening = list(ERT_FREQ, DTH_FREQ)
	use_power = 0
	autolinkers = list("centcomm")	

//Broadcasters

//--PRESET LEFT--//

/obj/machinery/telecomms/broadcaster/preset_left
	id = "Broadcaster A"
	network = "tcommsat"
	autolinkers = list("broadcasterA")

//--PRESET RIGHT--//

/obj/machinery/telecomms/broadcaster/preset_right
	id = "Broadcaster B"
	network = "tcommsat"
	autolinkers = list("broadcasterB")

/obj/machinery/telecomms/broadcaster/preset_cent
	id = "CentComm Broadcaster"
	network = "tcommsat"
	use_power = 0
	autolinkers = list("broadcasterCent")