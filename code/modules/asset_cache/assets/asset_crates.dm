/datum/asset/spritesheet/crates
	name = "crates"

/datum/asset/spritesheet/crates/create_spritesheets()
	for(var/obj/structure/closet/crate/crate as anything in subtypesof(/obj/structure/closet/crate))
		Insert(crate.icon_state, 'icons/obj/crates.dmi', crate.icon_state)
