////////////////////////////////////////
//////////Telecomms Equipment///////////
////////////////////////////////////////
// Only 2 of these exist, so they should really be in a different place. But oh well.
/datum/design/telecomms_core
	name = "Machine Board (Telecommunications Core)"
	desc = "Allows for the construction of Telecommunications Cores."
	id = "s-hub"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tcomms/core
	category = list("Subspace Telecomms")

/datum/design/telecomms_relay
	name = "Machine Board (Telecommunications Relay)"
	desc = "Allows for the construction of Telecommunications Relays."
	id = "s-relay"
	req_tech = list("programming" = 2, "engineering" = 2, "bluespace" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/tcomms/relay
	category = list("Subspace Telecomms")
