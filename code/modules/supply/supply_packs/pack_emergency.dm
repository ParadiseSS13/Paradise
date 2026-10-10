/// Section header - use these to set default supply group and crate type for sections
/datum/supply_packs/emergency
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = SUPPLY_EMERGENCY

// MARK: Illumination
/datum/supply_packs/emergency/floodlight
	name = "Emergency Flood Light"
	contains = list(/obj/machinery/floodlight,
					/obj/item/wrench)
	cost = 250
	containertype = /obj/structure/largecrate
	containername = "emergency flood light"

/datum/supply_packs/emergency/flare
	name = "Emergency Flare Crate"
	contains = list(/obj/item/storage/box/flares,
					/obj/item/storage/box/flares,
					/obj/item/storage/box/flares)
	cost = 150
	containertype = /obj/structure/closet/crate
	containername = "emergency flare crate"

/datum/supply_packs/emergency/flare/glowstick
	name = "Premium Glowstick Crate"
	contains = list(/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium,
					/obj/item/storage/box/glowstick/premium)
	cost = 200
	containername = "premium glowstick crate"

/datum/supply_packs/emergency/flare/emergency_glowstick
	name = "Emergency Glowstick Crate"
	contains = list(/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency,
					/obj/item/storage/box/large/glowstick/emergency)
	cost = 100
	containername = "emergency glowstick crate"

// MARK: Life support
/datum/supply_packs/emergency/internals
	name = "Internals Crate"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/tank/internals/emergency_oxygen/engi,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest)
	cost = 100
	containername = "internals crate"

/datum/supply_packs/emergency/internals/vox
	name = "Internals Crate (Vox)"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/tank/internals/emergency_oxygen/double/vox,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest)
	containertype = /obj/structure/closet/crate/internals/nitrogen
	containername = "internals crate (vox)"

/datum/supply_packs/emergency/internals/plasmaman
	name = "Internals Crate (Plasmaman)"
	contains = list(/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/tank/internals/plasmaman/belt/full,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/head/helmet/space/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/under/plasmaman,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest)
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "internals crate (plasmaman)"
	access = ACCESS_EVA

/datum/supply_packs/emergency/damage_control
	name = "Emergency Damage Control Crate"
	contains = list(/mob/living/basic/bot/repairbot,
					/mob/living/basic/bot/repairbot,
					/mob/living/basic/bot/medbot,
					/mob/living/basic/bot/medbot,
					/obj/item/storage/box/foam_grenades,
					/obj/item/storage/box/oxygen_grenades)
	cost = 100
	containertype = /obj/structure/closet/crate/engineering
	containername = "emergency damage control crate"

// MARK: Firefighting
/datum/supply_packs/emergency/firefighting
	name = "Firefighting Crate"
	contains = list(/mob/living/basic/bot/firebot,
					/mob/living/basic/bot/firebot,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/head/hardhat/red,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/clothing/suit/fire/firefighter,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/tank/internals/oxygen/red,
					/obj/item/flashlight,
					/obj/item/flashlight,
					/obj/item/extinguisher,
					/obj/item/extinguisher,
					/obj/item/grenade/chem_grenade/firefighting,
					/obj/item/grenade/chem_grenade/firefighting)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "firefighting crate"

/datum/supply_packs/engineering/backpack_firefighter_tank
	name = "Backpack Firefighting Tank Crate"
	contains = list(/obj/item/watertank/atmos)
	cost = 100
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "backpack firefighting tank crate"
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/foamtank
	name = "Firefighting Foam Tank Crate"
	contains = list(/obj/structure/reagent_dispensers/watertank/firetank)
	cost = 150
	containertype = /obj/structure/largecrate
	containername = "firefighting foam tank crate"

// MARK: Misc
/datum/supply_packs/emergency/weedcontrol
	name = "Weed Control Crate"
	contains = list(/obj/item/scythe,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/gloves/botanic_leather,
					/obj/item/grenade/chem_grenade/antiweed,
					/obj/item/grenade/chem_grenade/antiweed)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "weed control crate"
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))
	department_restrictions = list(DEPARTMENT_SERVICE)

/datum/supply_packs/emergency/specialops
	name = "Special Ops Supplies"
	contains = list(/obj/item/storage/box/emps,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/grenade/smokebomb,
					/obj/item/pen/sleepy,
					/obj/item/grenade/chem_grenade/incendiary)
	cost = 150 // This is hard enough to get, let's make it easier to buy.
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	hidden = TRUE

