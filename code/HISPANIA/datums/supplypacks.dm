/datum/supply_packs/engineering/inducers
	name = "Inducers Crate"
	cost = 60
	contains = list(/obj/item/inducerapc, /obj/item/inducerapc)
	containername = "inducer crate"
	containertype = /obj/structure/closet/crate/secure/engineering
	access = ACCESS_ENGINE

//Med//

//Rolledbed//

datum/supply_packs/medical/rolledbed
    name = "Rolled Bed Crate"
    contains = list(/obj/item/roller,
                    /obj/item/roller)
    cost = 15
    containername = "rolled bed crate"


//Sec///

datum/supply_packs/security/spacesuit
    name = "Security Space Suit Crate"
    contains = list(/obj/item/clothing/suit/space/hardsuit/security,
                    /obj/item/clothing/suit/space/hardsuit/security,
                    /obj/item/clothing/mask/breath,
                    /obj/item/clothing/mask/breath)
    cost = 70
    containername = "security space suit crate"

//Emergency//

/datum/supply_packs/engineering/energy_shi
	name = "Emergency Shield Crate"
	cost = 120
	contains = list(/obj/machinery/shieldgen, /obj/machinery/shieldgen, /obj/machinery/shieldgen, /obj/machinery/shieldgen)
	containername = "emergency shield crate"
	containertype = /obj/structure/closet/crate/secure/engineering
	access = ACCESS_ENGINE

/datum/supply_packs/emergency/panic_control
	name = "Blackout Crate"
	contains = list(/obj/item/storage/fancy/flare_box/full,
					/obj/item/storage/fancy/flare_box/full
					)
	cost = 60
	containername = "blackout shutdown"
