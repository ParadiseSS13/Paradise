/**
 * # Objective Implant
 *
 * Implant which allows you to summon either the Nuclear Core Theft Tools or the Supermatter Sliver Theft Tools.
 */

 /obj/item/implant/objective_storage
	name = "Objective bio-chip"
	desc = "INFORM CODERS - YOU SHOULDNT BE SEEING THIS."
	implant_state = "implant-syndicate"
	uses = 1

/obj/item/implant/objective_storage/nuclear_core
	name = "Nuclear Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a Nuclear Plutonium Core."
	implant_state = "implant-syndicate"

/obj/item/implant/objective_storage/supermatter_sliver
	name = "Supermatter Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a sliver of the Supermatter Engine."
	implant_state = "implant-syndicate"

/obj/item/implant/objective_storage/activate()
	to_chat(imp_in, "You feel a faint click. A box suddenly appears in your hands!")

	if(!uses)
		qdel(src)

/obj/item/implant/objective_storage/nuclear_core/activate()
	return new /obj/item/storage/box/syndie_kit/nuke(loc)
	. = ..()


/obj/item/implant/objective_storage/supermatter_sliver/activate()
	return new /obj/item/storage/box/syndie_kit/supermatter(loc)
	. = ..()
