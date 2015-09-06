var/global/list/body_accessory_by_name = list("None" = null)

/hook/startup/proc/initalize_body_accessories()
	//each accessory subtype needs it's own loop
	for(var/type in subtypesof(/datum/body_accessory/body))
		var/datum/body_accessory/ac1 = new type
		if(istype(ac1))
			body_accessory_by_name["[ac1.name]"] = ac1

	for(var/type in subtypesof(/datum/body_accessory/tail))
		var/datum/body_accessory/ac2 = new type
		if(istype(ac2))
			body_accessory_by_name["[ac2.name]"] = ac2

	if(body_accessory_by_name.len)
		if(initialize_body_accessory_by_species())
			return 1

	return 0 //fail if no bodies are found

var/global/list/body_accessory_by_species = list("None" = null)

/proc/initialize_body_accessory_by_species()
	for(var/B in body_accessory_by_name)
		var/datum/body_accessory/accessory = body_accessory_by_name[B]
		if(!istype(accessory))	continue
		for(var/A in accessory.allowed_species)
			body_accessory_by_species[A] += accessory

	if(body_accessory_by_species.len)
		return 1
	return 0


/datum/body_accessory
	var/name = "default"

	var/icon = null
	var/icon_state = ""

	var/animated_icon = null
	var/animated_icon_state = ""

	var/blend_mode = null

	var/list/pixel_offsets = list("x" = 0, "y" = 0)

	var/list/allowed_species = list()

/datum/body_accessory/proc/try_restrictions(var/mob/living/carbon/human/H)
	return 1

/datum/body_accessory/proc/get_pixel_x(var/mob/living/carbon/human/H)
	return pixel_offsets["x"]

/datum/body_accessory/proc/get_pixel_y(var/mob/living/carbon/human/H)
	return pixel_offsets["y"]


//Bodies
/datum/body_accessory/body
	blend_mode = ICON_MULTIPLY

/datum/body_accessory/body/snake
	name = "Snake"

	icon = 'icons/mob/body_accessory_64.dmi'
	icon_state = "naga"

	pixel_offsets = list("x" = -16, "y" = 0)

//Tails
/datum/body_accessory/tail
	blend_mode = ICON_ADD

/datum/body_accessory/tail/try_restrictions(var/mob/living/carbon/human/H)
	if(!H.wear_suit || !(H.wear_suit.flags_inv & HIDETAIL) && !istype(H.wear_suit, /obj/item/clothing/suit/space))
		return 1
	return 0