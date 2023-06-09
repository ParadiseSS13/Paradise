/obj/item/stack/spacecash
	name = "1 Credit"
	desc = "Money money money."
	icon = 'icons/goonstation/objects/money.dmi'
	icon_state = "cashgreen"
	hitsound = "swing_hit"
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	singular_name = "credit"
	max_amount = 1000000
	merge_type = /obj/item/stack/spacecash

/obj/item/stack/spacecash/update_icon()
	..()
	name = "[amount == max_amount ? "1000000" : amount] Credit[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount < 10)
		icon_state = "cashgreen"
	else if(amount >= 10 && amount < 50)
		icon_state = "spacecash"
	else if(amount >= 50 && amount < 500)
		icon_state = "cashblue"
	else if(amount >= 500 && amount < 1000)
		icon_state = "cashindi"
	else if(amount >= 1000 && amount < 1000000)
		icon_state = "cashpurp"
	else
		icon_state = "cashrbow"

/obj/item/stack/spacecash/c10
	amount = 10

/obj/item/stack/spacecash/c20
	amount = 20

/obj/item/stack/spacecash/c50
	amount = 50

/obj/item/stack/spacecash/c100
	amount = 100

/obj/item/stack/spacecash/c200
	amount = 200

/obj/item/stack/spacecash/c500
	amount = 500

/obj/item/stack/spacecash/c1000
	amount = 1000

/obj/item/stack/spacecash/c1000000
	amount = 1000000

///// USSP space cash

/obj/item/stack/spacecash/ussp
	name = "1 Soviet Credit"
	desc = "An old shabby paper Soviet Credit."
	icon_state = "usspcash"
	singular_name = "Stovpira"
	merge_type = /obj/item/stack/spacecash/ussp

/obj/item/stack/spacecash/ussp/c10
	amount = 10

/obj/item/stack/spacecash/ussp/c50
	amount = 50

/obj/item/stack/spacecash/ussp/c100
	amount = 100

/obj/item/stack/spacecash/ussp/c1000
	amount = 1000

/obj/item/stack/spacecash/ussp/New(loc, amt = null)
	..()
	update_icon()

/obj/item/stack/spacecash/ussp/update_icon()
	..()
	name = "[amount == max_amount ? "1000000" : amount] Ruble[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount < 10)
		icon_state = "usspcash"
	else if(amount >= 10 && amount < 50)
		icon_state = "usspcash10"
	else if(amount >= 50 && amount < 500)
		icon_state = "usspcash50"
	else if(amount >= 500 && amount < 1000)
		icon_state = "usspcash500"
	else if(amount >= 1000 && amount < 1000000)
		icon_state = "usspcash1000"
	else
		icon_state = "usspcash1000"
