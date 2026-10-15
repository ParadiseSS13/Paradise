/datum/supply_packs/materials
	name = "HEADER"
	group = SUPPLY_MATERIALS
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk", "Atmospherics"))


/datum/supply_packs/materials/metal
	name = "50 Metal Sheets Crate"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 100
	containername = "metal sheets crate"

/datum/supply_packs/materials/glass
	name = "50 Glass Sheets Crate"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 100
	containername = "glass sheets crate"

/datum/supply_packs/materials/wood
	name = "50 Wood Planks Crate"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 100
	containername = "wood planks crate"

/datum/supply_packs/materials/cardboard
	name = "50 Cardboard Sheets Crate"
	contains = list(/obj/item/stack/sheet/cardboard)
	amount = 50
	cost = 30
	containername = "cardboard sheets crate"

/datum/supply_packs/materials/sandstone
	name = "50 Sandstone Blocks Crate"
	contains = list(/obj/item/stack/sheet/mineral/sandstone)
	amount = 50
	cost = 100
	containername = "sandstone blocks crate"

// In order for crew to profit from this, it'd need to be worth 29 Cr. Making this into crates and reselling it is break-even.
/datum/supply_packs/materials/plastic
	name = "50 Plastic Sheets Crate"
	contains = list(/obj/item/stack/sheet/plastic)
	amount = 50
	cost = 30
	containername = "plastic sheets crate"

/datum/supply_packs/materials/platinum
	name = "20 Platinum Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/platinum)
	amount = 20
	cost = 500
	containername = "platinum sheets crate"

/datum/supply_packs/materials/palladium
	name = "20 Palladium Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/palladium)
	amount = 20
	cost = 500
	containername = "palladium sheets crate"

/datum/supply_packs/materials/iridium
	name = "20 Iridium Sheets Crate"
	contains = list(/obj/item/stack/sheet/mineral/iridium)
	amount = 20
	cost = 500
	containername = "iridium sheets crate"
