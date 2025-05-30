/obj/item/stack/vox_cash
	name = "Кикиридиты"
	desc = "Криптографический чип доступа к адресам транзакций рассчетных средств воксов."
	icon = 'modular_ss220/antagonists/icons/trader_machine.dmi'
	icon_state = "vox_key"
	hitsound = "swing_hit"
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_TINY
	max_amount = MAX_STACKABLE_CASH*10
	merge_type = /obj/item/stack/vox_cash

/obj/item/stack/vox_cash/proc/rename_amount()
	name = "[initial(name)] ([get_amount()])"

/obj/item/stack/vox_cash/Initialize(mapload, new_amount, merge)
	. = ..()
	rename_amount()

/obj/item/stack/vox_cash/merge(obj/item/stack/S)
	. = ..()
	rename_amount()

/obj/item/stack/vox_cash/use(used, check = TRUE)
	. = ..()
	rename_amount()

/obj/item/stack/vox_cash/add(newamount)
	. = ..()
	rename_amount()

/obj/item/stack/vox_cash/c5
	amount = 5

/obj/item/stack/vox_cash/c10
	amount = 10

/obj/item/stack/vox_cash/c20
	amount = 20

/obj/item/stack/vox_cash/c50
	amount = 50

/obj/item/stack/vox_cash/c100
	amount = 100

/obj/item/stack/vox_cash/c200
	amount = 200

/obj/item/stack/vox_cash/c500
	amount = 500

/obj/item/stack/vox_cash/c1000
	amount = 1000

/obj/item/stack/vox_cash/c10000
	amount = 10000

/obj/item/stack/vox_cash/c25000
	amount = 25000

/obj/item/stack/vox_cash/c50000
	amount = 50000

/obj/item/stack/vox_cash/c100000
	amount = 100000
