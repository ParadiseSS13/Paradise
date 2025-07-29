/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	put_on_delay = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion
	var/datum/martial_art/boxing/style

/obj/item/clothing/gloves/boxing/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H, TRUE)
		ADD_TRAIT(user, TRAIT_CHUNKYFINGERS, CLOTHING_TRAIT)

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)
		REMOVE_TRAIT(user, TRAIT_CHUNKYFINGERS, CLOTHING_TRAIT)

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
