/// Section header - use these to set default supply group and crate type for sections
/datum/supply_packs/emergency
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = SUPPLY_EMERGENCY

/datum/supply_packs/emergency/evac
	name = "Emergency Equipment Crate"
	contains = list(/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/floorbot,
					/mob/living/simple_animal/bot/medbot,
					/mob/living/simple_animal/bot/medbot,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/storage/box/oxygen_grenades,
					/obj/item/storage/box/oxygen_grenades)
	cost = 400
	containername = "emergency crate"

/datum/supply_packs/emergency/glowstick/emergency
	name = "Emergency Glowstick Crate"
	contains = list(/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "emergency glowstick crate"

/datum/supply_packs/emergency/glowstick/premium
	name = "Premium Glowstick Crate"
	contains = list(/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium)
	cost = 200
	containertype = /obj/structure/closet/crate
	containername = "premium glowstick crate"

/datum/supply_packs/emergency/flares
	name = "Emergency Flare Crate"
	contains = list(/obj/item/storage/box/flares,
					/obj/item/storage/box/flares,
					/obj/item/storage/box/flares)
	cost = 150
	containertype = /obj/structure/closet/crate
	containername = "emergency flare crate"

/datum/supply_packs/emergency/internals
	name = "Internals Crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air,
					/obj/item/tank/internals/air)
	cost = 100
	containername = "internals crate"

/datum/supply_packs/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/extinguisher,
					/obj/item/extinguisher,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "firefighting crate"

/datum/supply_packs/emergency/atmostank
	name = "Firefighting Watertank Crate"
	contains = list(/obj/item/watertank/atmos)
	cost = 100
	containertype = /obj/structure/closet/crate/secure
	containername = "firefighting watertank crate"
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/emergency/voxsupport
	name = "Vox Life Support Supplies"
	contains = list(/obj/item/clothing/mask/breath/vox,
					/obj/item/clothing/mask/breath/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox)
	cost = 200
	containertype = /obj/structure/closet/crate/internals/nitrogen
	containername = "vox life support supplies crate"

/datum/supply_packs/emergency/plasmamansupport
	name = "Plasmaman Supply Kit"
	contains = list(/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/mask/breath,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman)
	cost = 200
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "plasmaman life support supplies crate"
	access = ACCESS_EVA

/datum/supply_packs/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 150 //this is hard enough to get, lets make it easier to buy
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = TRUE

/datum/supply_packs/emergency/floodlight
	name = "Emergency Flood Light"
	contains = list(/obj/machinery/floodlight)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "emergency flood light"
