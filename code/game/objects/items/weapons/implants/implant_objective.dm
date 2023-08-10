/**
 * # Objective Implant
 *
 * Implant which allows you to summon either the Nuclear Core Theft Tools or the Supermatter Sliver Theft Tools.
 */

 /obj/item/implant/objective
	name = "Objective bio-chip"
	desc = "INFORM CODERS - YOU SHOULDNT BE SEEING THIS."
	implant_state = "implant-syndicate"
	uses = 1
	implant_data =
	actions_types =

/obj/item/implant/objective/nuclear_core
	name = "Nuclear Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a Nuclear Plutonium Core."
	implant_state = "implant-syndicate"

/obj/item/implant/objective/supermatter_sliver
	name = "Supermatter Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a sliver of the Supermatter Engine."
	implant_state = "implant-syndicate"

/obj/item/implant/objective/nuclear_core/activate()

	to_chat(imp_in, "You feel a faint click. A box suddenly appears in your hands!")
	return new /obj/item/storage/box/syndie_kit/nuke(loc)

	if(!uses)
		qdel(src)

/obj/item/implant/objective/supermatter_sliver/activate()

	to_chat(imp_in, "You feel a faint click. A box suddenly appears in your hands!")
	return new /obj/item/storage/box/syndie_kit/supermatter(loc)

	if(!uses)
		qdel(src)
