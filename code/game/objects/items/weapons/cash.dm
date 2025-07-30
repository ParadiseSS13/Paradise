/obj/item/stack/spacecash
	name = "1 Credit"
	desc = "Money money money."
	icon = 'icons/obj/money.dmi'
	icon_state = "cash"
	hitsound = "swing_hit"
	throw_speed = 1
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
	name = "[amount] Credit[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount < 50)
		icon_state = "cash"
	else if(amount >= 50 && amount < 100)
		icon_state = "cash2"
	else if(amount >= 100 && amount < 500)
		icon_state = "cash3"
	else if(amount >= 500 && amount < 1000)
		icon_state = "cash4"
	else if(amount >= 1000 && amount < 10000)
		icon_state = "cash5"
	else
		icon_state = "cash6"

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
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
