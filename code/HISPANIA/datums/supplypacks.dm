/datum/supply_packs/engineering/inducers
	name = "Inducers Crate"
	cost = 60
	contains = list(/obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/high; opened = 0}, /obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/high; opened = 0}) //FALSE doesn't work in modified type paths apparently.
	containername = "inducer crate"
	containertype = /obj/structure/closet/crate/secure/engineering
	access = access_engine

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
