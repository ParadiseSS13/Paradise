/obj/item/clothing/under/rank/captain
	name = "captain's jumpsuit"
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	icon = 'icons/obj/clothing/under/captain.dmi'
	icon_state = "captain"
	item_state = "caparmor"
	item_color = "captain"

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/captain.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/captain.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/captain.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/captain.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/captain.dmi',
		)

/obj/item/clothing/under/rank/captain/dress
	name = "captain's dress"
	desc = "Feminine fashion for the style conscious captain."
	icon_state = "captain_dress"
	item_color = "captain_dress"
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/captain/parade
	name = "captain's parade uniform"
	desc = "A captain's luxury-wear, for special occasions."
	icon_state = "captain_parade"
	item_state = "by_suit"
	item_color = "captain_parade"
