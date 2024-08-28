/obj/machinery/vox_shop
	name = "Киконсоль Закиказов"
	desc = "Технология связывающая воксов на дальних рубежах."
	icon = 'modular_ss220/antagonists/icons/trader_machine.dmi'
	icon_state = "shop"
	max_integrity = 5000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	density = TRUE
	var/cash_stored = 0

	var/list/packs_cats = list()	// Категории по предметам - ui_static_data
	var/list/packs_items = list()	// Все доступные предметы

	var/list/cart_list
	var/list/cart_data


// ============ DATA ============

/obj/machinery/vox_shop/Initialize(mapload)
	. = ..()
	generate_pack_items()
	generate_pack_lists()

/obj/machinery/vox_shop/proc/generate_pack_items()
	var/list/shop_items = list()
	var/obj/machinery/vox_trader/trader = locate() in GLOB.machines
	for(var/path in subtypesof(/datum/vox_pack))
		var/datum/vox_pack/pack = new path
		if(pack.cost < 0)
			continue
		if(pack.is_need_trader_cost)
			var/list/pack_contents = list()
			for(var/object_type in pack.contains)
				var/obj/O = new object_type()
				pack_contents.Add(O)
			var/pack_trader_cost = trader.get_value(null, pack_contents, TRUE)
			QDEL_LIST_CONTENTS(pack_contents)
			pack.cost += pack_trader_cost
		if(!shop_items[pack.category])
			shop_items[pack.category] = list()
		shop_items[pack.category] += pack

	packs_items = shop_items

/obj/machinery/vox_shop/proc/generate_pack_lists()
	var/list/cats = list()
	for(var/category in packs_items)
		cats[++cats.len] = list("cat" = category, "items" = list())
		for(var/datum/vox_pack/pack in packs_items[category])
			cats[cats.len]["items"] += list(list(
				"name" = sanitize(pack.name),
				"desc" = sanitize(pack.description()),
				"cost" = pack.cost,
				"obj_path" = pack.reference
				))
			packs_items[pack.reference] = pack

	packs_cats = cats
	SStgui.update_uis(src)


// ======= Interaction ==========

/obj/machinery/vox_shop/attack_hand(mob/user)
	if(!check_usable(user))
		return
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/vox_shop/proc/check_usable(mob/user)
	. = FALSE
	if(issilicon(user))
		return
	if(!isvox(user))
		to_chat(user, span_notice("Вы осматриваете [src] и не понимаете как оно работает и куда сувать свои пальцы..."))
		return
	return TRUE

/obj/machinery/vox_shop/attack_ai(mob/user)
	return FALSE

/obj/machinery/vox_shop/attackby(obj/item/O, mob/user, params)
	if(isvoxcash(O))
		user.do_attack_animation(src)
		insert_cash(O, user)
		return TRUE
	. = ..()

/obj/machinery/vox_shop/proc/insert_cash(obj/item/stack/vox_cash, mob/user)
	visible_message("<span class='info'>[user] загрузил [vox_cash] в [src].</span>")
	cash_stored += vox_cash.amount
	vox_cash.use(vox_cash.amount)
	return TRUE

/// Размещение предметов в отдельные емкости
/obj/machinery/vox_shop/proc/make_container(mob/user, list/typepath_objects)
	var/is_heavy = FALSE
	var/list/objs_for_contain = list()

	// Создаем объекты
	for(var/typepath in typepath_objects)
		var/obj/obj = new typepath()
		objs_for_contain.Add(obj)
		if(is_heavy)
			continue
		if(isitem(obj))
			var/obj/item/item = obj
			if(item.w_class >= WEIGHT_CLASS_NORMAL)
				is_heavy = TRUE

	// Размещаем по емкостям
	if(length(objs_for_contain) > 2)
		var/container_type = is_heavy ? /obj/structure/closet/crate/trashcart : /obj/item/storage/box
		var/obj/container = new container_type(get_turf(src))
		for(var/obj/obj in objs_for_contain)
			obj.forceMove(container)
	else if(length(objs_for_contain))
		for(var/obj/obj as anything in objs_for_contain)
			if(isitem(obj))
				if(!user.put_in_any_hand_if_possible(obj) && ishuman(user))
					var/mob/living/carbon/human/H = user
					H.equip_or_collect(obj, SLOT_HUD_IN_BACKPACK)
			else
				obj.forceMove(get_turf(src))

	do_sparks(5, 1, get_turf(src))


// ============= UI =============

/obj/machinery/vox_shop/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Shop", name)
		ui.open()

/obj/machinery/vox_shop/ui_data(mob/user)
	var/list/data = list()

	data["cash"] = cash_stored
	data["cart"] = generate_tgui_cart()
	data["cart_price"] = calculate_cart_cash()

	var/list/vox_raider_members = list()
	for(var/datum/team/vox_raiders/team in subtypesof(/datum/team/vox_raiders))
		vox_raider_members.Add(team.members)
	data["vox_members"] = vox_raider_members
	// data["crewmembers"] = GLOB.crew_repository.health_data(viewing_current_z_level)
	// data["critThreshold"] = HEALTH_THRESHOLD_CRIT

	return data

/obj/machinery/vox_shop/ui_static_data(mob/user)
	var/list/static_data = list()

	if(!packs_cats || !packs_items)
		generate_pack_lists(user)
	//static_data["packs"] = packs_items
	static_data["cats"] = packs_cats

	return static_data

/obj/machinery/vox_shop/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return

	. = TRUE

	switch(action)
		if("add_to_cart")
			add_to_cart(params, ui.user)

		if("remove_from_cart")
			remove_from_cart(params)

		if("set_cart_item_quantity")
			set_cart_item_quantity(params)

		if("purchase_cart")
			if(!LAZYLEN(cart_list))
				return
			var/cart_cash = calculate_cart_cash()
			if(cart_cash > cash_stored)
				to_chat(ui.user, "<span class='warning'>[src] недостаточно кикиридитов! Неси больше!</span>")
				return

			var/list/bought_typepath_objects = list()
			for(var/reference in cart_list)
				var/datum/vox_pack/pack = packs_items[reference]
				var/amount = cart_list[reference]
				if(amount <= 0)
					continue
				var/list/purchase_list = mass_purchase(pack, pack ? pack.reference : "", amount)
				if(!length(purchase_list))
					to_chat(ui.user, span_warning("[pack.name] - превысил допустимое возможное количество для покупки."))
					return
				bought_typepath_objects += purchase_list

			// Обновляем количество купленного товара
			for(var/reference in cart_list)
				var/datum/vox_pack/pack = packs_items[reference]
				if(pack.limited_stock < 0)
					continue
				var/amount = pack.purchased + cart_list[reference]
				pack.purchased += amount

			// Завершение покупки
			make_container(ui.user, bought_typepath_objects)
			cash_stored -= cart_cash
			empty_cart()
			SStgui.update_uis(src)

		if("empty_cart")
			empty_cart()


// ========== UI Procs ==========

/obj/machinery/vox_shop/proc/mass_purchase(datum/vox_pack/pack, reference, amount = 1)
	if(!pack)
		return
	if(amount <= 0)
		return
	if(!pack.check_possible_buy(amount))
		return
	if(!pack.check_time_available())
		return
	var/list/bought_objects = list()
	for(var/i in 1 to amount)
		var/list/items_list = pack.get_items_list()
		if(!length(items_list))
			break
		bought_objects += items_list
	return bought_objects

/obj/machinery/vox_shop/proc/calculate_cart_cash()
	. = 0
	for(var/reference in cart_list)
		var/datum/vox_pack/item = packs_items[reference]
		var/amount = cart_list[reference]
		. += item.cost * amount

/obj/machinery/vox_shop/proc/generate_tgui_cart(update = FALSE)
	if(!update)
		return cart_data

	if(!length(cart_list))
		cart_list = null
		cart_data = null
		return cart_data

	cart_data = list()
	for(var/reference in cart_list)
		var/datum/vox_pack/pack = packs_items[reference]
		cart_data += list(list(
			"name" = sanitize(pack.name),
			"desc" = sanitize(pack.description()),
			"cost" = pack.cost,
			"obj_path" = pack.reference,
			"amount" = cart_list[reference],
			"limit" = pack.limited_stock,
			"is_time_available" = pack.check_time_available()
			))

/obj/machinery/vox_shop/proc/add_to_cart(params, mob/user)
	var/item = params["item"]
	var/amount = 1
	var/datum/vox_pack/pack = packs_items[item]
	if(LAZYIN(cart_list, item))
		amount += cart_list[item]
	if(!pack.check_possible_buy(amount))
		to_chat(user, span_warning("[pack.name] больше невозможно купить!"))
		return
	if(!pack.check_time_available())
		to_chat(user, span_warning("[pack.name] будет доступен к покупке в [pack.get_time_available()], осталось [pack.get_time_left()]"))
		return
	LAZYSET(cart_list, item, max(amount, 1))
	generate_tgui_cart(TRUE)

/obj/machinery/vox_shop/proc/remove_from_cart(params)
	LAZYREMOVE(cart_list, params["item"])
	generate_tgui_cart(TRUE)

/obj/machinery/vox_shop/proc/empty_cart()
	cart_list = null
	generate_tgui_cart(TRUE)

/obj/machinery/vox_shop/proc/set_cart_item_quantity(params)
	var/amount = text2num(params["quantity"])
	if(amount <= 0)
		remove_from_cart(params)
		return
	LAZYSET(cart_list, params["item"], max(amount, 0))
	generate_tgui_cart(TRUE)
