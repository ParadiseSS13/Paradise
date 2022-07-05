/datum/keybinding/human
	category = KB_CATEGORY_HUMAN

/datum/keybinding/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/human/toggle_holster
	name = "Toggle Holster"
	keys = list("H")

/datum/keybinding/human/toggle_holster/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	if(!M.w_uniform)
		return
	var/obj/item/clothing/accessory/holster/H = locate() in M.w_uniform
	H?.holster_verb()

/datum/keybinding/human/rest
	name = "Rest"
	keys = list("V")

/datum/keybinding/human/rest/down(client/C)
	. = ..()
	var/mob/living/carbon/human/M = C.mob
	M.rest()
