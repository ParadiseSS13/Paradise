var/global/list/moneytypes=list(
	/obj/item/weapon/spacecash/c1000 = 1000,
	/obj/item/weapon/spacecash/c500  = 500,
	/obj/item/weapon/spacecash/c200  = 200,
	/obj/item/weapon/spacecash/c100  = 100,
	/obj/item/weapon/spacecash/c50   = 50,
	/obj/item/weapon/spacecash/c20   = 20,
	/obj/item/weapon/spacecash/c10   = 10,
	/obj/item/weapon/spacecash       = 1,
)

/obj/item/weapon/spacecash
	name = "credit chip"
	desc = "Money money money."
	gender = PLURAL
	icon = 'icons/obj/money.dmi'
	icon_state = "cash1"
	opacity = 0
	density = 0
	anchored = 0.0
	force = 1.0
	throwforce = 1.0
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	var/access = list()
	access = access_crate_cash
	var/worth = 1 // Per chip
	var/amount = 1 // number of chips
	var/stack_color = "#4E054F"

/obj/item/weapon/spacecash/New(var/new_loc,var/new_amount=1)
	loc = new_loc
	name = "[worth] credit chip"
	amount = new_amount
	update_icon()

/obj/item/weapon/spacecash/examine(mob/user)
	if(amount>1)
		to_chat(user, "[bicon(src)] This is a stack of [amount] [src]s.")
	else
		to_chat(user, "[bicon(src)] This is \a [src]s.")
	to_chat(user, "It's worth [worth*amount] credits.")

/obj/item/weapon/spacecash/update_icon()
	icon_state = "cash[worth]"
	// Up to 100 items per stack.
	pixel_x=rand(-7,7)
	pixel_y=rand(-14,14)

/obj/item/weapon/spacecash/proc/collect_from(var/obj/item/weapon/spacecash/cash)
	if(cash.worth == src.worth)
		var/taking = min(100-src.amount,cash.amount)
		cash.amount -= taking
		src.amount += taking
		if(cash.amount <= 0)
			qdel(cash)
		return taking
	return 0

/obj/item/weapon/spacecash/afterattack(atom/A as mob|obj, mob/user as mob)
	if(istype(A, /turf) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack))
		var/turf/T = get_turf(A)
		var/collected = 0
		for(var/obj/item/weapon/spacecash/cash in T)
			if(cash.worth == src.worth)
				collected += collect_from(cash)
		if(collected)
			update_icon()
			to_chat(user, "<span class='notice'>You add [collected] credit [amount > 1 ? "chips":"chip"] to your stack of cash.</span>")
	else if(istype(A,/obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/cash = A
		var/collected = src.collect_from(cash)
		if(collected)
			update_icon()
			to_chat(user, "<span class='notice'>You add [collected] credit [amount > 1 ? "chips":"chip"] to your stack of cash.</span>")


/obj/item/weapon/spacecash/proc/get_total()
	return worth * amount

/obj/item/weapon/spacecash/c10
	icon_state = "cash10"
	worth = 10

/obj/item/weapon/spacecash/c20
	icon_state = "cash10"
	worth = 20

/obj/item/weapon/spacecash/c50
	icon_state = "cash10"
	worth = 50

/obj/item/weapon/spacecash/c100
	icon_state = "cash100"
	worth = 100

/obj/item/weapon/spacecash/c200
	icon_state = "cash200"
	worth = 200

/obj/item/weapon/spacecash/c500
	icon_state = "cash500"
	worth = 500

/obj/item/weapon/spacecash/c1000
	icon_state = "cash1000"
	worth = 1000

/proc/dispense_cash(var/amount, var/loc)
	for(var/cashtype in moneytypes)
		var/slice = moneytypes[cashtype]
		var/dispense_count = Floor(amount/slice)
		amount = amount % slice
		while(dispense_count>0)
			var/dispense_this_time = min(dispense_count,100)
			if(dispense_this_time > 0)
				new cashtype(loc,dispense_this_time)
				dispense_count -= dispense_this_time

/proc/count_cash(var/list/cash)
	. = 0
	for(var/obj/item/weapon/spacecash/C in cash)
		. += C.get_total()