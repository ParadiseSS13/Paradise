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
	resistance_flags = FLAMMABLE
	singular_name = "credit"
	max_amount = MAX_STACKABLE_CASH
	merge_type = /obj/item/stack/spacecash

/obj/item/stack/spacecash/Initialize(mapload)
	. = ..()
	SSeconomy.space_credits_created += amount
	SSeconomy.total_space_cash += amount
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/spacecash/Destroy()
	SSeconomy.total_space_cash -= amount
	SSeconomy.space_credits_destroyed += amount
	return ..()

/obj/item/stack/spacecash/merge(obj/item/stack/S)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/spacecash/change_stack(mob/living/user)
	. = ..()
	var/obj/item/stack/spacecash/new_dosh = .
	if(istype(new_dosh))
		new_dosh.update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/spacecash/update_icon_state()
	name = "[amount == max_amount ? "10000" : amount] Credit[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount < 10)
		icon_state = "cashgreen"
	else if(amount >= 10 && amount < 50)
		icon_state = "spacecash"
	else if(amount >= 50 && amount < 500)
		icon_state = "cashblue"
	else if(amount >= 500 && amount < 1000)
		icon_state = "cashindi"
	else if(amount >= 1000 && amount <= 10000)
		icon_state = "cashpurp"
	else
		icon_state = "cashrbow"

/obj/item/stack/spacecash/c5
	amount = 5

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

/obj/item/stack/spacecash/c10000
	amount = 10000

/obj/item/cash_pile
	name = "Pile of Cash"

/obj/item/cash_pile/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
