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

/obj/item/implant/objective/nuclear_core
	name = "Nuclear Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a Nuclear Plutonium Core."
	implant_state = "implant-syndicate"

/obj/item/implant/objective/supermatter_sliver
	name = "Supermatter Theft bio-chip"
	desc = "Allows you to smuggle in a set of tools designed to assist in the theft of a sliver of the Supermatter Engine."
	implant_state = "implant-syndicate"

/obj/item/implanter/objective/nuclear_core
	name = "bio-chip implanter (nuclear core)"
	implant_type = /obj/item/implant/objective/nuclear_core

/obj/item/implanter/objective/supermatter_sliver
	name = "bio-chip implanter (supermatter sliver)"
	implant_type = /obj/item/implant/objective/supermatter_sliver

/obj/item/implant/objective/nuclear_core/proc/spawn_items(turf/loc)

	return new /obj/item/storage/box/syndie_kit/nuke(loc)

/obj/item/implant/objective/supermatter_sliver/proc/spawn_items(turf/loc)

	return new /obj/item/storage/box/syndie_kit/supermatter(loc)

/obj/item/implant/objective/nuclear_core/activate()
	uses--

	to_chat(imp_in, "You feel a faint click. A box suddenly appears in your hands!")
	imp_in.put_in_any_hand_if_possible(spawn_items(imp_in.loc))

	if(!uses)
		qdel(src)

/obj/item/implant/objective/supermatter_sliver/activate()
	uses--

	to_chat(imp_in, "You feel a faint click. A box suddenly appears in your hands!")
	imp_in.put_in_any_hand_if_possible(spawn_items(imp_in.loc))

	if(!uses)
		qdel(src)
