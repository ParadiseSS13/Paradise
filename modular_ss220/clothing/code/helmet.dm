/obj/item/clothing/head/helmet/bike_helmet
	name = "байкерский шлем"
	desc = "Крутой шлем."
	icon = 'modular_ss220/clothing/icons/object/hats.dmi'
	icon_state = "bike_helmet"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	toggle_message = "Вы опустили защитное стекло"
	alt_toggle_message = "Вы подняли защитное стекло"
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	can_toggle = TRUE
	toggle_sound = 'sound/weapons/tap.ogg'
	dog_fashion = null
	sprite_sheets = list(
		"Abductor" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Ancient Skeleton" 	= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Diona" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Drask" 			= 	'modular_ss220/clothing/icons/mob/species/drask/helmet.dmi',
		"Golem" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Grey" 				= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Human" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Kidan" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Machine"			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Monkey" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Nian" 				= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Plasmaman" 		= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Shadow" 			= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Skrell" 			= 	'modular_ss220/clothing/icons/mob/species/skrell/helmet.dmi',
		"Slime People" 		= 	'modular_ss220/clothing/icons/mob/hats.dmi',
		"Tajaran" 			= 	'modular_ss220/clothing/icons/mob/species/tajaran/helmet.dmi',
		"Unathi" 			= 	'modular_ss220/clothing/icons/mob/species/unathi/helmet.dmi',
		"Vox" 				= 	'modular_ss220/clothing/icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" 		= 	'modular_ss220/clothing/icons/mob/species/vulpkanin/helmet.dmi',
		)

/obj/item/clothing/head/helmet/bike_helmet/replica
	desc = "Крутой шлем. На вид хлипкий..."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

