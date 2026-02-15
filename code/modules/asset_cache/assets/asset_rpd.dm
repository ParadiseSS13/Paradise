/datum/asset/spritesheet/rpd
	name = "rpd"

/datum/asset/spritesheet/rpd/create_spritesheets()
	InsertAll("", 'icons/obj/pipe-item.dmi', GLOB.alldirs)
	InsertAll("", 'icons/obj/pipes/disposal.dmi', GLOB.alldirs)
	InsertAll("", 'icons/obj/pipes/transit_tube_rpd.dmi', GLOB.alldirs)
	InsertAll("", 'icons/obj/pipes/fluid_pipes.dmi', GLOB.alldirs)
	InsertAll("", 'icons/obj/pipes/fluid_machinery.dmi', GLOB.alldirs)
	InsertAll("", 'icons/obj/pipes/fluid_machines_rpd.dmi', list(EAST, WEST))
	InsertAll("", 'icons/obj/pipes/fluid_pipes.dmi', GLOB.alldirs)
