//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = WEIGHT_CLASS_TINY
	desc = "This is rubbish."
	resistance_flags = FLAMMABLE

/obj/item/trash/raisins
	name = "4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "Candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "Cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "Chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "Popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "Syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "Waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "Plate"
	icon_state = "plate"
	resistance_flags = NONE

/obj/item/trash/snack_bowl
	name = "Snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/fried_vox
	name = "Kentucky Fried Vox"
	icon_state = "fried_vox_empty"

/obj/item/trash/pistachios
	name = "Pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "Semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "Tray"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" ration"
	icon_state = "liquidfood"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	var/is_glass = 0
	var/is_plastic = 0
	resistance_flags = NONE

/obj/item/trash/gum
	name = "chewed gum"
	desc = "NOT free candy."
	icon_state = "gum"

/obj/item/trash/tastybread
	name = "bread tube"
	icon_state = "tastybread"

/obj/item/trash/spentcasing
	icon = 'icons/obj/ammo.dmi'
	name = "bullet casing"
	desc = "A spent bullet casing. Smells like cordite."
	icon_state = "gshell"

/obj/item/trash/tapetrash
	name = "old duct tape"
	icon_state = "tape"
	desc = "Not sticky anymore."
	throw_range = 1

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return
