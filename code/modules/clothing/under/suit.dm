/obj/item/clothing/under/suit
	icon = 'icons/obj/clothing/under/suit.dmi'
	worn_icon = 'icons/mob/clothing/under/suit.dmi'
	inhand_icon_state = "bl_suit"
	sprite_sheets = list(
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

/obj/item/clothing/under/suit/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the station's finest."
	icon_state = "really_black_suit"

/obj/item/clothing/under/suit/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the station's finest."
	icon_state = "black_suit_fem"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/suit/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"

/obj/item/clothing/under/suit/tan
	name = "tan suit"
	desc = "A tan suit with a yellow tie. Smart, but casual."
	icon_state = "tan_suit"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/suit/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"

/obj/item/clothing/under/suit/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and blue tie. Very professional."
	icon_state = "charcoal_suit"

/obj/item/clothing/under/suit/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/suit/mafia
	name = "mafia outfit"
	desc = "The business of the mafia is business."
	icon_state = "mafia"

/obj/item/clothing/under/suit/mafia/vest
	name = "mafia vest"
	desc = "Extreme problems often require extreme solutions."
	icon_state = "mafiavest"

/obj/item/clothing/under/suit/mafia/white
	name = "white mafia outfit"
	desc = "The best defense against the treacherous is treachery."
	icon_state = "mafiawhite"

/obj/item/clothing/under/suit/mafia/tan
	name = "tan mafia outfit"
	desc = "The big drum sounds good only from a distance."
	icon_state = "tan_suit"
	inhand_icon_state = "lb_suit"

/obj/item/clothing/under/suit/victsuit
	name = "victorian suit"
	desc = "A victorian style suit, fancy!"
	icon_state = "victorianvest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/suit/victsuit/redblk
	name = "red and black victorian suit"
	icon_state = "victorianblred"

/obj/item/clothing/under/suit/victsuit/red
	name = "red victorian suit"
	icon_state = "victorianredvest"
