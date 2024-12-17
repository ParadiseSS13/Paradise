// Exile implants will allow you to use the station gate, but not return home.
// This will allow security to exile badguys/for badguys to exile their kill targets
/obj/item/bio_chip/exile
	name = "exile bio-chip"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/exile
	implant_state = "implant-nanotrasen"

/datum/implant_fluff/exile
	name = "Nanotrasen Employee Exile Bio-chip"
	life = "Known to last up to 3 to 4 years."
	notes = "The onboard station gateway system has been modified to reject entry by individuals containing this bio-chip."
	function = "Prevents the user from reentering the station through the gateway.... alive."

/datum/supply_packs/security/armory/exileimp
	name = "Exile Bio-chips Crate"
	contains = list(/obj/item/storage/box/exileimp)
	cost = 600
	containername = "exile bio-chip crate"

/obj/item/storage/box/exileimp
	name = "boxed exile bio-chip kit"
	desc = "Box of exile bio-chips. It has a picture of a clown being booted through the Gateway."

/obj/item/storage/box/exileimp/populate_contents()
	new /obj/item/bio_chip_implanter/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)

/obj/item/bio_chip_implanter/exile
	name = "bio-chip implanter (exile)"
	implant_type = /obj/item/bio_chip/exile

/obj/item/bio_chip_case/exile
	name = "bio-chip case - 'Exile'"
	desc = "A glass case containing an exile bio-chip."
	implant_type = /obj/item/bio_chip/exile

/obj/structure/closet/secure_closet/exile
	name = "exile bio-chips"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/exile/populate_contents()
	new /obj/item/bio_chip_implanter/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
	new /obj/item/bio_chip_case/exile(src)
