/obj/item/stack/spacechips
	name = "Poker Chips"
	desc = "Chips for playing poker"
	icon = 'icons/goonstation/objects/pokerchips.dmi'
	icon_state = "c1000"
	hitsound = "swing_hit"
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	singular_name = "chip"
	max_amount = 1000000
	merge_type = /obj/item/stack/spacechips

/obj/item/stack/spacechips/New(loc, amt = null)
	..()
	update_icon()

/obj/item/stack/spacechips/update_icon()//changes icon depending on the amount of chips
	..()
	name = "[amount == max_amount ? "1000000" : amount] Chip[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount <= 20)
		icon_state = "c20"
	else if(amount > 20 && amount <= 50)
		icon_state = "c50"
	else if(amount > 50 && amount <= 100)
		icon_state = "c100"
	else if(amount > 100 && amount <= 200)
		icon_state = "c200"
	else if(amount > 200 && amount <= 500)
		icon_state = "c500"
	else
		icon_state = "c1000"

/obj/item/stack/spacechips/c10
	amount = 10

/obj/item/stack/spacechips/c20
	amount = 20

/obj/item/stack/spacechips/c50
	amount = 50

/obj/item/stack/spacechips/c100
	amount = 100

/obj/item/stack/spacechips/c200
	amount = 200

/obj/item/stack/spacechips/c500
	amount = 500

/obj/item/stack/spacechips/c1000
	amount = 1000
	
/obj/item/stack/spacechips/c2000
	amount = 2000
	
/obj/item/stack/spacechips/c5000
	amount = 5000
	
/obj/item/stack/spacechips/c6000
	amount = 6000

/obj/item/stack/spacechips/c8000
	amount = 8000

/obj/item/stack/spacechips/c1000000
	amount = 1000000
