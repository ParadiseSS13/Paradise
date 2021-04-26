/datum/design/circuit_imprinter/inge
	name = "Machine Board (Engineers Circuit Imprinter)"
	desc = "The circuit board for a Circuit Imprinter."
	id = "circuit_imprinteringe"
	req_tech = list("programming" = 2, "engineering" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/circuit_imprinter/inge
	category = list("Research Machinery")

/datum/design/telepad
	name = "Machine Board (Telepad Board)"
	desc = "Allows for the construction of circuit boards used to build a Telepad."
	id = "telepad"
	req_tech = list("programming" = 5, "bluespace" = 5, "plasmatech" = 5, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/telesci_pad
	category = list ("Teleportation Machinery")

/datum/design/doppler_array
	name = "Machine Board (Tachyon-Doppler Array Board)"
	desc = "A highly precise directional sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	id = "doppler_array"
	req_tech = list("programming" = 4, "plasmatech" = 4, "bluespace" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/doppler_array
	category = list ("Research Machinery")

/datum/design/undirect_doppler_array
	name = "Machine Board (Long Range Tachyon-Doppler Array Board)"
	desc = "A highly precise sensor array which measures the release of quants from decaying tachyons. The doppler shifting of the mirror-image formed by these quants can reveal the size, location and temporal affects of energetic disturbances within a large radius ahead of the array."
	id = "undirect_doppler_array"
	req_tech = list("programming" = 6, "plasmatech" = 4, "bluespace" = 5, "toxins" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/doppler_array/range
	category = list ("Research Machinery")

/datum/design/mixer
	name = "Machine Board (Mixer)"
	desc = "The circuit board for a Mixer."
	id = "mixer"
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mixer
	category = list("Misc. Machinery")


/datum/design/chem_dispenser/botanical
	name = "Machine Board (Botanical Chem Dispenser)"
	desc = "The circuit board for a Botanical Chem Dispenser."
	id = "botanical_chem_dispenser"
	req_tech = list("programming" = 5, "biotech" = 3, "materials" = 4, "plasmatech" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/chem_dispenser/botanical
	category = list ("Hydroponics Machinery")
