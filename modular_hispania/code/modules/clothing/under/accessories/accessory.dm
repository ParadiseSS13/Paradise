/// Ties by Danaleja2005 ///

/obj/item/clothing/accessory/blue_alt
	name = "blue striped tie"
	desc = "A blue striped tie made of silk. Made by D&N Corp."
	icon = 'modular_hispania/icons/obj/clothing/ties.dmi'
	icon_state = "blue1"
	item_state = "blue1"
	item_color = "blue1"
	hispania_icon = TRUE
	sprite_sheets = list(
		"Vox" = 'modular_hispania/icons/mob/species/vox/ties.dmi',
		"Grey" = 'modular_hispania/icons/mob/species/grey/ties.dmi'
	)

/obj/item/clothing/accessory/red_alt
	name = "red striped tie"
	desc = "A red striped tie made of silk. Made by D&N Corp."
	icon = 'modular_hispania/icons/obj/clothing/ties.dmi'
	hispania_icon = TRUE
	icon_state = "red1"
	item_state = "red1"
	item_color = "red1"

/obj/item/clothing/accessory/medal/gold/sheriff
	name = "sheriff emblem"
	desc = "A prestigious golden medal for the heroes of the justice."

/obj/item/clothing/accessory/medal/gold/sheriff/on_attached(obj/item/clothing/under/S, mob/user as mob)
	. = ..()
	to_chat(user,"<span class='danger'>YEHAAAAAAAAAAAAAAW.</span>")
