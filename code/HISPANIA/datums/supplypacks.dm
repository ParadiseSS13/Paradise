/datum/supply_packs/engineering/inducers
	name = "Inducers Crate"
	cost = 60
	contains = list(/obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/high; opened = 0}, /obj/item/inducer/sci {cell_type = /obj/item/stock_parts/cell/high; opened = 0}) //FALSE doesn't work in modified type paths apparently.
	containername = "inducer crate"
	containertype = /obj/structure/closet/crate/secure/engineering
	access = access_engine
