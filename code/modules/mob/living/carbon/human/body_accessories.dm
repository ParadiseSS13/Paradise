
var/global/list/body_accessory_by_name = list("None" = null)

/hook/startup/proc/initalize_body_accessories()

	__init_body_accessory(/datum/body_accessory/body)
	__init_body_accessory(/datum/body_accessory/tail)

	if(body_accessory_by_name.len)
		if(initialize_body_accessory_by_species())
			return 1

	return 0 //fail if no bodies are found

var/global/list/body_accessory_by_species = list("None" = null)

/proc/initialize_body_accessory_by_species()
	for(var/B in body_accessory_by_name)
		var/datum/body_accessory/accessory = body_accessory_by_name[B]
		if(!istype(accessory))	continue

		for(var/species in accessory.allowed_species)
			if(!body_accessory_by_species["[species]"])	body_accessory_by_species["[species]"] = list()
			body_accessory_by_species["[species]"] += accessory

	if(body_accessory_by_species.len)
		return 1
	return 0

/proc/__init_body_accessory(var/ba_path)
	if(ispath(ba_path))
		var/_added_counter = 0

		for(var/A in subtypesof(ba_path))
			var/datum/body_accessory/B = new A
			if(istype(B))
				body_accessory_by_name[B.name] += B
				++_added_counter

		if(_added_counter)
			return 1
	return 0


/datum/body_accessory
	var/name = "default"

	var/icon = null
	var/icon_state = ""

	var/animated_icon = null
	var/animated_icon_state = ""

	var/blend_mode = null

	var/pixel_x_offset = 0
	var/pixel_y_offset = 0

	var/list/allowed_species = list()

/datum/body_accessory/proc/try_restrictions(var/mob/living/carbon/human/H)
	return 1

/datum/body_accessory/proc/get_animated_icon() //return animated if it has it, return static if it does not.
	if(animated_icon)
		return animated_icon

	else	return icon

/datum/body_accessory/proc/get_animated_icon_state()
	if(animated_icon_state)
		return animated_icon_state

	else	return icon_state


//Bodies
/datum/body_accessory/body
	blend_mode = ICON_MULTIPLY

/datum/body_accessory/body/snake
	name = "Snake"

	icon = 'icons/mob/body_accessory_64.dmi'
	icon_state = "snake"

	pixel_x_offset = -16



//Tails
/datum/body_accessory/tail
	icon = 'icons/mob/body_accessory.dmi'
	animated_icon = 'icons/mob/body_accessory.dmi'
	blend_mode = ICON_ADD
	icon_state = "null"
	animated_icon_state = "null"

/datum/body_accessory/tail/try_restrictions(var/mob/living/carbon/human/H)
	if(!H.wear_suit || !(H.wear_suit.flags_inv & HIDETAIL))
		return 1
	return 0


/datum/body_accessory/tail/wingler_tail // Jay wingler fluff tail
	name = "Striped Tail"

	icon_state = "winglertail"
	animated_icon_state = "winglertail_a"
	allowed_species = list("Tajaran")


//Vulpkanin
/datum/body_accessory/tail/vulpkanin_2
	name = "Vulpkanin Alt 1 (Bushy)"
	icon_state = "vulptail2"
	animated_icon_state = "vulptail2_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/vulpkanin_3
	name = "Vulpkanin Alt 2 (Straight)"
	icon_state = "vulptail3"
	animated_icon_state = "vulptail3_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/vulpkanin_4
	name = "Vulpkanin Alt 3 (Tiny)"
	icon_state = "vulptail4"
	animated_icon_state = "vulptail4_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/vulpkanin_5
	name = "Vulpkanin Alt 4 (Short)"
	icon_state = "vulptail5"
	animated_icon_state = "vulptail5_a"
	allowed_species = list("Vulpkanin")

/datum/body_accessory/tail/vulpkanin_6
	name = "Vulpkanin Alt 5 (Straight Bushy)"
	icon_state = "vulptail6"
	animated_icon_state = "vulptail6_a"
	allowed_species = list("Vulpkanin")
