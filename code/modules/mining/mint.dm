#define COIN_COST MINERAL_MATERIAL_AMOUNT * 0.2

/obj/machinery/mineral/mint
	name = "coin press"
	icon = 'icons/obj/economy.dmi'
	icon_state = "coin_press"
	density = TRUE
	anchored = TRUE
	/// How many coins did the machine make in total.
	var/total_coins = 0
	/// Is it creating coins now?
	var/active = FALSE
	/// Which material will be used to make coins or for ejecting.
	var/chosen_material
	/// Inserted money bag.
	var/obj/item/storage/bag/money/money_bag

/obj/machinery/mineral/mint/Initialize(mapload)
	. = ..()
	var/static/list/coin_materials = list()
	if(!length(coin_materials))
		for(var/datum/material/coin_mat as anything in subtypesof(/datum/material))
			var/obj/item/coin/coin_type = coin_mat.coin_type
			if(!coin_type)
				continue
			coin_materials += coin_mat.id

	AddComponent(/datum/component/material_container, coin_materials, MINERAL_MATERIAL_AMOUNT * 50, FALSE, /obj/item/stack, _after_insert = CALLBACK(src, PROC_REF(material_insert)))
	chosen_material = pick(coin_materials[1])

/obj/machinery/mineral/mint/Destroy()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/mineral/mint/update_icon_state()
	if(active)
		icon_state = "coin_press-active"
	else
		icon_state = "coin_press"

/obj/machinery/mineral/mint/wrench_act(mob/user, obj/item/I)
	default_unfasten_wrench(user, I, time = 4 SECONDS)
	return TRUE

/obj/machinery/mineral/mint/attack_hand(mob/user)
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/mineral/mint/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mineral/mint/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/mint/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CoinMint", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/mineral/mint/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/materials)
	)

/obj/machinery/mineral/mint/ui_data(mob/user)
	var/list/data = list()

	data["active"] = active
	data["chosenMaterial"] = chosen_material
	data["totalCoins"] = total_coins
	data["moneyBag"] = !!money_bag

	if(money_bag)
		data["moneyBagContent"] = length(money_bag.contents)
		data["moneyBagMaxContent"] = money_bag.storage_slots

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	data["totalMaterials"] = materials.total_amount
	data["maxMaterials"] = materials.max_amount

	var/list/material_list = list()
	for(var/mat_id in materials.materials)
		var/datum/material/material = materials.materials[mat_id]
		material_list += list(list(
			"name" = material.name,
			"amount" = material.amount / MINERAL_MATERIAL_AMOUNT,
			"id" = material.id
		))
	data["materials"] = material_list

	return data

/obj/machinery/mineral/mint/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	. = TRUE

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	switch(action)
		if("selectMaterial")
			if(!materials.materials[params["material"]])
				return
			chosen_material = params["material"]
		if("activate")
			if(active)
				active = FALSE
			else
				try_make_coins()
			update_icon(UPDATE_ICON_STATE)
		if("ejectMat")
			var/datum/material/material = materials.materials[chosen_material]
			if(material.amount < MINERAL_MATERIAL_AMOUNT)
				to_chat(usr, "<span class='warning'>Not enough [material.name] to eject!</span>")
				return
			var/num_sheets = tgui_input_number(usr, "How many sheets do you want to eject?", "Ejecting [material.name]", max_value = round(material.amount / MINERAL_MATERIAL_AMOUNT), min_value = 1)
			if(isnull(num_sheets))
				return
			materials.retrieve_sheets(num_sheets, chosen_material)
		if("ejectBag")
			eject_bag(usr)

/obj/machinery/mineral/mint/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/bag/money))
		if(money_bag)
			to_chat(user, "<span class='notice'>There is already a [money_bag.name] inside!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You put a [used.name] into a [src].</span>")
		used.forceMove(src)
		money_bag = used
		SStgui.update_uis(src)

		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/mineral/mint/process()
	if(!active)
		return
	if(length(money_bag.contents) >= money_bag.storage_slots)
		active = FALSE
		visible_message("<span class='notice'>[src] stops printing to prevent an overflow.</span>")
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)
		return

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/datum/material/material = materials.materials[chosen_material]
	if(!materials.can_use_amount(COIN_COST, chosen_material))
		active = FALSE
		visible_message("<span class='notice'>[src] ceased production due to a lack of material.</span>")
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)
		return

	materials.use_amount_type(COIN_COST, chosen_material)
	new material.coin_type(money_bag)
	total_coins++
	SStgui.update_uis(src)

/obj/machinery/mineral/mint/proc/try_make_coins(mob/user)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	if(!money_bag)
		visible_message("<span class='warning'>[src] cannot work without a money bag!</span>")
		return
	if(length(money_bag.contents) == money_bag.storage_slots)
		visible_message("<span class='warning'>[money_bag.name] is full!</span>")
		return
	if(!materials.can_use_amount(COIN_COST, chosen_material))
		visible_message("<span class='warning'>Lack of selected material for production!</span>")
		return
	active = TRUE

/obj/machinery/mineral/mint/proc/eject_bag(mob/user)
	if(!money_bag || !(user && iscarbon(user) && user.Adjacent(src)))
		return
	if(active)
		active = FALSE
	if(user.put_in_hands(money_bag))
		to_chat(user, "<span class='notice'>You take a [money_bag.name] out of [src].</span>")
	else
		var/turf/T = get_step(src, output_dir)
		money_bag.forceMove(T)
	money_bag = null
	SStgui.update_uis(src)

/obj/machinery/mineral/mint/proc/material_insert()
	SStgui.update_uis(src)

#undef COIN_COST
