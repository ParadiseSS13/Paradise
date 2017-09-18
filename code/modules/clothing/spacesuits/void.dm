
//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "A high tech, NASA Centcom branch designed, dark red space suit helmet. Used for AI satellite maintenance."
	icon_state = "void"
	item_state = "void"
	species_fit = list("Vulpkanin")
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/species/Vulpkanin/helmet.dmi'
		)

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A high tech, NASA Centcom branch designed, dark red Space suit. Used for AI satellite maintenance."
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/multitool)
	species_fit = list("Vulpkanin")
	sprite_sheets = list(
		"Vulpkanin" = 'icons/mob/species/Vulpkanin/suit.dmi'
		)