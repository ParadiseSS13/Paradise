////////////////////////////////////////
//////////Telecomms Equipment///////////
////////////////////////////////////////
/datum/design/telecomms_bus
	name = "Machine Board (Bus Mainframe)"
	desc = "Allows for the construction of Telecommunications Bus Mainframes."
	id = "s-bus"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/bus
	category = list("Subspace Telecomms")

/datum/design/telecomms_hub
	name = "Machine Board (Hub Mainframe)"
	desc = "Allows for the construction of Telecommunications Hub Mainframes."
	id = "s-hub"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/hub
	category = list("Subspace Telecomms")


/datum/design/telecomms_processor
	name = "Machine Board (Processor Unit)"
	desc = "Allows for the construction of Telecommunications Processor equipment."
	id = "s-processor"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/processor
	category = list("Subspace Telecomms")

/datum/design/telecomms_relay
	name = "Machine Board (Relay Mainframe)"
	desc = "Allows for the construction of Telecommunications Relay Mainframes."
	id = "s-relay"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/relay
	category = list("Subspace Telecomms")

/datum/design/telecomms_server
	name = "Machine Board (Server Mainframe)"
	desc = "Allows for the construction of Telecommunications Servers."
	id = "s-server"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/server
	category = list("Subspace Telecomms")

/datum/design/subspace_broadcaster
	name = "Machine Board (Subspace Broadcaster)"
	desc = "Allows for the construction of Subspace Broadcasting equipment."
	id = "s-broadcaster"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/broadcaster
	category = list("Subspace Telecomms")

/datum/design/subspace_receiver
	name = "Machine Board (Subspace Receiver)"
	desc = "Allows for the construction of Subspace Receiver equipment."
	id = "s-receiver"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 1)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telecomms/receiver
	category = list("Subspace Telecomms")

/datum/design/subspace_crystal
	name = "Ansible Crystal"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-crystal"
	req_tech = list("magnets" = 2, "materials" = 2, "bluespace" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 800, MAT_SILVER = 100, MAT_GOLD = 100)
	build_path = /obj/item/stock_parts/subspace/crystal
	category = list("Stock Parts")

/datum/design/hyperwave_filter
	name = "Hyperwave Filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	id = "s-filter"
	req_tech = list("programming" = 3, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 100)
	build_path = /obj/item/stock_parts/subspace/filter
	category = list("Stock Parts")

/datum/design/subspace_amplifier
	name = "Subspace Amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	id = "s-amplifier"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 3, "bluespace" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GOLD = 100, MAT_URANIUM = 100)
	build_path = /obj/item/stock_parts/subspace/amplifier
	category = list("Stock Parts")

/datum/design/subspace_analyzer
	name = "Subspace Analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	id = "s-analyzer"
	req_tech = list("programming" = 3, "magnets" = 4, "materials" = 2, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GOLD = 100)
	build_path = /obj/item/stock_parts/subspace/analyzer
	category = list("Stock Parts")

/datum/design/subspace_ansible
	name = "Subspace Ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	id = "s-ansible"
	req_tech = list("programming" = 2, "magnets" = 2, "materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 100)
	build_path = /obj/item/stock_parts/subspace/ansible
	category = list("Stock Parts")

/datum/design/subspace_transmitter
	name = "Subspace Transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	id = "s-transmitter"
	req_tech = list("magnets" = 3, "materials" = 4, "bluespace" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 100, MAT_SILVER = 100, MAT_URANIUM = 100)
	build_path = /obj/item/stock_parts/subspace/transmitter
	category = list("Stock Parts")

/datum/design/subspace_treatment
	name = "Subspace Treatment Disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	id = "s-treatment"
	req_tech = list("programming" = 2, "magnets" = 3, "materials" = 2, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_SILVER = 200)
	build_path = /obj/item/stock_parts/subspace/treatment
	category = list("Stock Parts")
