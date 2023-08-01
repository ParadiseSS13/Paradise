#define CASH1 1
#define CASH2 10
#define CASH3 50
#define CASH4 500
#define CASH5 1000
#define CASHMAX 1000000

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
	max_amount = CASHMAX
	merge_type = /obj/item/stack/spacecash

/obj/item/stack/spacecash/update_icon()
	..()
	name = "[amount == CASHMAX ? "[CASHMAX]" : amount] Credit[amount > 1 ? "s" : ""]"
	switch(amount)
		if(CASH1 to CASH2 - 1)
			icon_state = "cashgreen"
		if(CASH2 to CASH3 - 1)
			icon_state = "spacecash"
		if(CASH3 to CASH4 - 1)
			icon_state = "cashblue"
		if(CASH4 to CASH5 - 1)
			icon_state = "cashindi"
		if(CASH5 to CASHMAX - 1)
			icon_state = "cashpurp"
		else
			icon_state = "cashrbow"

/obj/item/stack/spacecash/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(throwingdatum?.thrower?.mind?.martial_art, /datum/martial_art/mr_chang))
		throwingdatum.thrower.say(pick("Бесплатные деньги!!", "Настоящий денежный дождь!!",\
								 "Деньги, деньги, деньги!!!", "Это лучшая сделка!!"))
		switch(amount)
			if(CASH1 to CASH2 - 1)
				throwforce = 5
			if(CASH2 to CASH3 - 1)
				throwforce = 6
			if(CASH3 to CASH4 - 1)
				throwforce = 7
			if(CASH4 to CASH5 - 1)
				throwforce = 8
			if(CASH5 to CASHMAX - 1)
				throwforce = 9
			if(CASHMAX to INFINITY)
				throwforce = 10
	. = ..()

/obj/item/stack/spacecash/after_throw(datum/callback/callback)
	throwforce = initial(throwforce)
	. = ..()

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
	name = "[amount == CASHMAX ? "[CASHMAX]" : amount] Ruble[amount > 1 ? "s" : ""]"
	switch(amount)
		if(CASH1 to CASH2 - 1)
			icon_state = "usspcash"
		if(CASH2 to CASH3 - 1)
			icon_state = "usspcash10"
		if(CASH3 to CASH4 - 1)
			icon_state = "usspcash50"
		if(CASH4 to CASH5 - 1)
			icon_state = "usspcash500"
		if(CASH5 to CASHMAX - 1)
			icon_state = "usspcash1000"
		else
			icon_state = "usspcash1000"

#undef CASH1
#undef CASH2
#undef CASH3
#undef CASH4
#undef CASH5
#undef CASHMAX
