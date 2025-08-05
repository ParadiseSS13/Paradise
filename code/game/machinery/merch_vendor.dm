/obj/machinery/economy/merch
	name = "Nanotrasen Merchandise Vendor"
	desc = "The one-stop-shop for all your Nanotrasen swag."
	icon = 'icons/obj/vending.dmi'
	icon_state = "nt_merch"
	light_color = LIGHT_COLOR_GREEN

	var/static/list/merchandise = list()
	var/static/list/imagelist = list()
	var/list/merch_categories = list(
		MERCH_CAT_APPAREL,
		MERCH_CAT_TOY,
		MERCH_CAT_DECORATION,
	)

/obj/machinery/economy/merch/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/economy/merch/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/economy/merch/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/economy/merch/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/merch(null)
	if(!length(merchandise))
		for(var/merch_path in subtypesof(/datum/merch_item))
			var/datum/merch_item/merch = new merch_path()
			merchandise[merch.category] += list(merch)
			var/obj/item/I = merch.typepath
			var/pp = replacetext(replacetext("[merch.typepath]", "/obj/item/", ""), "/", "-")
			imagelist[pp] = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))]"

/obj/machinery/economy/merch/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(isspacecash(used))
		insert_cash(used, user)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/economy/merch/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	default_unfasten_wrench(user, I, time = 6 SECONDS)

/obj/machinery/economy/merch/proc/do_purchase(datum/merch_item/merch, mob/user)
	if(!merch)
		return FALSE

	if(!attempt_transaction(merch, user))
		return FALSE

	deliver(merch, user)
	return TRUE

/obj/machinery/economy/merch/proc/attempt_transaction(datum/merch_item/merch, mob/user)
	if(cash_transaction >= merch.cost)
		if(pay_with_cash(merch.cost, "Purchase of [merch.name]", name, user, account_database.vendor_account))
			give_change(user)
			return TRUE
		return FALSE

	var/mob/living/carbon/human/H = user
	if(istype(H))
		var/obj/item/card/id/C = H.get_idcard(TRUE)
		if(!C || !pay_with_card(C, merch.cost, "Purchase of [merch.name]", "NAS Trurl Merchandising", user, account_database.vendor_account))
			return FALSE
	else
		to_chat(user, "<span class='warning'>Payment failure: you have no ID or other method of payment.</span>")
		return FALSE
	return TRUE

/obj/machinery/economy/merch/proc/deliver(datum/merch_item/item, mob/user)
	var/obj/item/merch = new item.typepath(get_turf(src))
	var/obj/item/small_delivery/D = new(get_turf(src))
	D.name = "small parcel - 'Your Nanotrasen Swag'"
	D.wrapped = merch
	merch.forceMove(D)
	user.put_in_hands(D)
	SSeconomy.total_vendor_transactions++

/obj/machinery/economy/merch/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/economy/merch/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MerchVendor", name)
		ui.open()

/obj/machinery/economy/merch/ui_data(mob/user)
	var/list/data = list()

	data["inserted_cash"] = cash_transaction
	var/datum/money_account/user_account = user.get_worn_id_account()
	data["user_cash"] = user_account?.credit_balance

	return data

/obj/machinery/economy/merch/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["imagelist"] = imagelist
	static_data["products"] = list()
	for(var/category in merch_categories)
		static_data["products"][category] = list()
		for(var/datum/merch_item/merch in merchandise[category])
			var/list/product_data = list(
				"name" = merch.name,
				"price" = merch.cost,
				"desc" = merch.desc,
				"category" = merch.category,
				"path" = replacetext(replacetext("[merch.typepath]", "/obj/item/", ""), "/", "-"),
			)
			static_data["products"][category] += list(product_data)

	return static_data

/obj/machinery/economy/merch/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = FALSE
	var/mob/living/user = ui.user

	switch(action)
		if("purchase")
			. = TRUE
			for(var/datum/merch_item/merch in merchandise[params["category"]])
				if(merch.name == params["name"])
					if(do_purchase(merch, user)) //null checking done in proc
						to_chat(user, "<span class='notice'>You've successfully purchased the item. It should be in your hands or on the floor.</span>")
					break
		if("change")
			. = TRUE
			give_change(user)

	if(.)
		add_fingerprint(user)
