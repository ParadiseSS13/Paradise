/obj/item/clothing/under/suit
	icon = 'icons/obj/clothing/under/suit.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/suit.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/suit.dmi'
		)

/obj/item/clothing/under/suit/Initialize(mapload)
	. = ..()
	// better than nothing! ghetto surgery time
	AddComponent(/datum/component/surgery_initiator/cloth, null, 0.1)

/obj/item/clothing/under/suit/black
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state = "bl_suit"
	item_color = "black_suit"

/obj/item/clothing/under/suit/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	item_color = "really_black_suit"

/obj/item/clothing/under/suit/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_fem"
	item_state = "black_suit_fem"
	item_color = "black_suit_fem"

/obj/item/clothing/under/suit/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"
	item_state = "navy_suit"
	item_color = "navy_suit"

/obj/item/clothing/under/suit/tan
	name = "tan suit"
	desc = "A tan suit with a yellow tie. Smart, but casual."
	icon_state = "tan_suit"
	item_state = "tan_suit"
	item_color = "tan_suit"

/obj/item/clothing/under/suit/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"
	item_state = "burgundy_suit"
	item_color = "burgundy_suit"

/obj/item/clothing/under/suit/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and blue tie. Very professional."
	icon_state = "charcoal_suit"
	item_state = "charcoal_suit"
	item_color = "charcoal_suit"

/obj/item/clothing/under/suit/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	item_state = "checkered_suit"
	item_color = "checkered_suit"

/obj/item/clothing/under/suit/mafia
	name = "mafia outfit"
	desc = "The business of the mafia is business."
	icon_state = "mafia"
	item_state = "mafia"
	item_color = "mafia"

/obj/item/clothing/under/suit/mafia/vest
	name = "mafia vest"
	desc = "Extreme problems often require extreme solutions."
	icon_state = "mafiavest"
	item_state = "mafiavest"
	item_color = "mafiavest"

/obj/item/clothing/under/suit/mafia/white
	name = "white mafia outfit"
	desc = "The best defense against the treacherous is treachery."
	icon_state = "mafiawhite"
	item_state = "mafiawhite"
	item_color = "mafiawhite"

/obj/item/clothing/under/suit/mafia/tan
	name = "tan mafia outfit"
	desc = "The big drum sounds good only from a distance."
	icon_state = "tan_suit"
	item_state = "tan_suit"
	item_color = "tan_suit"

/obj/item/clothing/under/suit/victsuit
	name = "victorian suit"
	desc = "A victorian style suit, fancy!"
	icon_state = "victorianvest"
	item_state = "victorianvest"
	item_color = "victorianvest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/suit/victsuit/redblk
	name = "red and black victorian suit"
	icon_state = "victorianblred"
	item_state = "victorianblred"
	item_color = "victorianblred"

/obj/item/clothing/under/suit/victsuit/red
	name = "red victorian suit"
	icon_state = "victorianredvest"
	item_state = "victorianredvest"
	item_color = "victorianredvest"
