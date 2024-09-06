/obj/item/vending_refill/nta
	machine_name = "NT Ammunition"
	icon = 'modular_ss220/vending/icons/vending_restock.dmi'
	icon_state = "refill_nta"

/obj/item/vending_refill/adv_ntmed
	machine_name = "Advanced Nanomed"
	icon_state = "refill_medical"

/obj/item/vending_refill/vulpix
	machine_name = "MacVulpix Deluxe Food"
	icon = 'modular_ss220/vending/icons/vending_restock.dmi'
	icon_state = "refill_vulpix"

/datum/supply_packs/vending/vulpix
	name = "Mac Vulpix Supply Crate"
	contains = list(/obj/item/vending_refill/vulpix)
	containername = "mac vulpix supply crate"
