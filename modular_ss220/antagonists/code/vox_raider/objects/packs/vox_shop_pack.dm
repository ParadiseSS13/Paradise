/datum/vox_pack
	var/name = "DEBUG Vox Pack"
	var/desc = "Описание отсутствует. Сообщите разработчику."
	var/reference = null
	var/cost = -1	// -1 = hide
	var/is_need_trader_cost = TRUE // Is need an additional cost on top of the cost from the “trader machine”
	var/time_until_available = 0 // How long does it take from the start of the round? In MINUTES
	var/limited_stock = -1 // Can you only buy so many? -1 allows for infinite purchases
	var/purchased = 0	// How much have you already bought?
	var/discount_div = 0	// Процент скидки на паки за покупку набора
	var/amount = 1
	var/category = VOX_PACK_MISC
	var/list/contains = list()

/datum/vox_pack/New()
	. = ..()
	update_pack()

/datum/vox_pack/proc/update_pack()
	if(discount_div <= 0)
		return
	cost = round(initial(cost) * discount_div)

/datum/vox_pack/proc/get_items_list()
	var/list/items_list = list()
	for(var/typepath in contains)
		if(!typepath)
			continue
		for(var/i in 1 to amount)
			items_list.Add(typepath)
	return items_list

/datum/vox_pack/proc/check_possible_buy(amount)
	if(limited_stock >= 0 && (purchased + amount > limited_stock))
		return FALSE
	return TRUE

/datum/vox_pack/proc/check_time_available()
	var/round_time_minutes = ROUND_TIME
	if(round_time_minutes < time_until_available MINUTES)
		return FALSE
	return TRUE

/datum/vox_pack/proc/get_time_available()
	var/t = SSticker.time_game_started + time_until_available MINUTES
	return "[round(t / 36000)]:[add_zero(num2text(t / 600 % 60), 2)]"

/datum/vox_pack/proc/get_time_left()
	var/t = SSticker.time_game_started + time_until_available MINUTES - ROUND_TIME
	return "[round(t / 36000)]:[add_zero(num2text(t / 600 % 60), 2)]:[add_zero(num2text(t / 10 % 60), 2)]"

/datum/vox_pack/proc/description()
	if(!desc)
		desc = replacetext(desc, "\n", "<br>")
	if(!check_time_available())
		desc += " \[Заказ возможен после [get_time_available()] от начала рейда.\]"
	return desc
