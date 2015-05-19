/obj/item/weapon/paintkit //Please don't use this for anything, it's a base type for custom mech paintjobs.
	name = "mecha customisation kit"
	desc = "A generic kit containing all the needed tools and parts to turn a mech into another mech."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "royce_kit"

	var/new_name = "mech"    //What is the variant called?
	var/new_desc = "A mech." //How is the new mech described?
	var/new_icon = "ripley"  //What base icon will the new mech use?
	var/removable = null     //Can the kit be removed?
	var/list/allowed_types = list() //Types of mech that the kit will work on.

/obj/item/weapon/paintkit/titansfist
	name = "Ripley customisation kit"
	desc = "A kit containing all the needed tools and parts to turn an APLU Ripley into a Titan's Fist worker mech."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "royce_kit"

	new_name = "APLU \"Titan's Fist\""
	new_desc = "This ordinary mining Ripley has been customized to look like a unit of the Titans Fist."
	new_icon = "titan"
	allowed_types = list("ripley","firefighter")

/obj/item/weapon/paintkit/mercenary
	name = "Mercenary APLU kit"
	desc = "A kit containing all the needed tools and parts to turn an APLU Ripley into an old Mercenaries APLU."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sven_kit"

	new_name = "APLU \"Strike the Earth!\""
	new_desc = "Looks like an over worked, under maintained Ripley with some horrific damage."
	new_icon = "earth"
	allowed_types = list("ripley","firefighter")