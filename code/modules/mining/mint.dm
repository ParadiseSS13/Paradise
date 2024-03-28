/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coin_press"
	density = TRUE
	anchored = TRUE
	/// How many coins the machine made in it's last load.
	var/total_coins = 0
	/// Is it creating coins now?
	var/processing = FALSE
	/// Which material will be used to make coins.
	var/chosen_material = MAT_METAL
	/// How many coins will be produced.
	var/produce_amount = 10
	/// Inserted money bag.
	var/obj/item/storage/bag/money/money_bag

/obj/machinery/mineral/mint/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_PLASMA, MAT_SILVER, MAT_GOLD, MAT_URANIUM, MAT_DIAMOND, MAT_BANANIUM, MAT_TRANQUILLITE), MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack)

/obj/machinery/mineral/mint/wrench_act(mob/user, obj/item/I)
	default_unfasten_wrench(user, I, time = 4 SECONDS)
	return TRUE

/obj/machinery/mineral/mint/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/mint/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CoinMint", name)
		ui.open()

/obj/machinery/mineral/mint/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/materials)
	)

/obj/machinery/mineral/mint/ui_data(mob/user)
	var/list/data = list()

	data["processing"] = processing
	data["produceAmount"] = produce_amount
	data["chosenMaterial"] = chosen_material
	data["totalCoins"] = total_coins
	data["moneyBag"] = !!money_bag

	if(money_bag)
		data["moneyBagContent"] = length(money_bag.contents)
		data["moneyBagMaxContent"] = money_bag.storage_slots

	return data

/obj/machinery/mineral/mint/ui_static_data(mob/user)
	var/list/static_data = list()

	var/list/material_list = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/mat_id in materials.materials)
		var/datum/material/material = materials.materials[mat_id]
		material_list += list(list(
			"name" = material.name,
			"amount" = material.amount,
			"id" = material.id
		))
	static_data["materials"] = material_list

	return static_data

/obj/machinery/mineral/mint/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	switch(action)
		if("selectMaterial")
			if(!materials.materials[params["material"]])
				return FALSE
			chosen_material = params["material"]
			return TRUE
		if("selectAmount")
			produce_amount = clamp(produce_amount + text2num(params["amount"]), 0, 1000)
			return TRUE
		if("activate")
			processing = !processing
			update_icon(UPDATE_ICON_STATE)
			if(!processing)
				return FALSE
			make_coins()
			return TRUE
		if("ejectBag")
			eject_bag()
			return TRUE

/obj/machinery/mineral/mint/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/mineral/mint/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mineral/mint/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/storage/bag/money))
		if(money_bag)
			to_chat(user, "<span class='notice'>There is already [money_bag.name] inside!</span>")
			return
		to_chat(user, "<span class='notice'>You put a [money_bag.name] into a [src] </span>")
		money_bag = I
		I.forceMove(src)
		SStgui.update_uis(src)

/obj/machinery/mineral/mint/update_icon_state()
	if(processing)
		icon_state = "coin_press-active"
	else
		icon_state = "coin_press"

/obj/machinery/mineral/mint/proc/make_coins()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/coins_amount = produce_amount
	var/coin_mat = MINERAL_MATERIAL_AMOUNT * 0.2
	var/datum/material/material = materials.materials[chosen_material]
	if(!material || !material.coin_type)
		return
	while(coins_amount > 0 && materials.can_use_amount(coin_mat, chosen_material))
		if(!money_bag)
			visible_message("<span class='warning'>[src] can't work without a money bag!</span>")
			break
		if(length(money_bag.contents) < money_bag.storage_slots)
			visible_message("<span class='notice'>[src] stops printing to prevent an overflow.</span>")
			break
		materials.use_amount_type(coin_mat, chosen_material)
		coins_amount--
		total_coins++
		SStgui.update_uis(src)
		addtimer(CALLBACK(src, PROC_REF(print_coin), material.coin_type), 1 SECONDS)
	processing = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/mineral/mint/proc/print_coin(coin_type)
	if(!money_bag)
		return
	var/obj/item/coin = new coin_type(src)
	coin.forceMove(money_bag)

/obj/machinery/mineral/mint/proc/eject_bag(mob/user)
	if(!money_bag || (!user && !iscarbon(user) && !user.Adjacent(src)))
		return
	if(user.put_in_hands(money_bag))
		to_chat(user, "<span class='cult'>You take a [money_bag.name] out of [src].</span>")
	else
		var/turf/T = get_step(src, output_dir)
		money_bag.forceMove(T)
	money_bag = null
	SStgui.update_uis(src)
