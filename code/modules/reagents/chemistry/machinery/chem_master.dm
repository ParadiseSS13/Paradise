#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
#define MAX_PATCH_SPRITE 21 //max icon state of the patch sprites
#define MAX_CUSTOM_NAME_LEN 64 // Max length of a custom pill/condiment/whatever

#define CUSTOM_NAME_DISABLED null

#define TRANSFER_TO_DISPOSAL 0
#define TRANSFER_TO_BEAKER   1

#define SAFE_MIN_TEMPERATURE T0C+7	// Safe minimum temperature for chemicals before they would start to damage slimepeople.
#define SAFE_MAX_TEMPERATURE T0C+36 // Safe maximum temperature for chemicals before they would start to damage drask.

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	desc = "Used to turn reagents into pills, patches, and store them in bottles."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	idle_power_consumption = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = TRANSFER_TO_BEAKER
	var/condi = FALSE
	var/useramount = 30 // Last used amount
	var/production_mode = null
	var/printing = FALSE
	var/static/list/pill_bottle_wrappers = list(
		COLOR_RED_LIGHT = "Red",
		COLOR_GREEN = "Green",
		COLOR_PALE_BTL_GREEN = "Pale Green",
		COLOR_CYAN_BLUE = "Light Blue",
		COLOR_TEAL = "Teal",
		COLOR_YELLOW = "Yellow",
		COLOR_ORANGE = "Orange",
		COLOR_PINK = "Pink",
		COLOR_MAROON = "Brown",
		COLOR_INDIGO = "Indigo",
		COLOR_VIOLET = "Violet",
		COLOR_PURPLE = "Purple"
	)
	var/list/datum/chemical_production_mode/production_modes = list()

/obj/machinery/chem_master/Initialize(mapload)
	. = ..()
	create_reagents(100)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_master(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
	update_icon()
	if(condi)
		var/datum/chemical_production_mode/new_mode = new /datum/chemical_production_mode/condiment_packs()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/condiment_bottles()
		production_modes[new_mode.mode_id] = new_mode
	else
		var/datum/chemical_production_mode/new_mode = new /datum/chemical_production_mode/pills()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/patches()
		production_modes[new_mode.mode_id] = new_mode
		new_mode = new /datum/chemical_production_mode/bottles()
		production_modes[new_mode.mode_id] = new_mode
	if(isnull(production_mode))
		for(var/key in production_modes)
			production_mode = key
			break

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(loaded_pill_bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity)
	if(severity < EXPLODE_LIGHT)
		if(beaker)
			beaker.ex_act(severity)
		if(loaded_pill_bottle)
			loaded_pill_bottle.ex_act(severity)
		..()

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
	else if(A == loaded_pill_bottle)
		loaded_pill_bottle = null

/obj/machinery/chem_master/update_icon_state()
	icon_state = "mixer[beaker ? "1" : "0"][has_power() ? "" : "_nopower"]"

/obj/machinery/chem_master/update_overlays()
	. = ..()
	if(has_power())
		. += "waitlight"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/power_change()
	if(!..())
		return
	update_icon()

/obj/machinery/chem_master/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't use [src] while it's panel is opened!</span>")
		return ITEM_INTERACT_COMPLETE

	if((istype(used, /obj/item/reagent_containers/glass) || istype(used, /obj/item/reagent_containers/drinks/drinkingglass)) && user.a_intent != INTENT_HARM)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[used] is stuck to you!</span>")
			return ITEM_INTERACT_COMPLETE

		used.forceMove(src)
		if(beaker)
			to_chat(usr, "<span class='notice'>You swap [used] with [beaker] inside.</span>")
			if(Adjacent(usr) && !issilicon(usr)) //Prevents telekinesis from putting in hand
				user.put_in_hands(beaker)
			else
				beaker.forceMove(loc)
		else
			to_chat(user, "<span class='notice'>You add [used] to the machine.</span>")
		beaker = used
		SStgui.update_uis(src)
		update_icon()

		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "<span class='warning'>A [loaded_pill_bottle] is already loaded into the machine.</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[used] is stuck to you!</span>")
			return ITEM_INTERACT_COMPLETE

		loaded_pill_bottle = used
		used.forceMove(src)
		to_chat(user, "<span class='notice'>You add [used] into the dispenser slot!</span>")
		SStgui.update_uis(src)
		return ITEM_INTERACT_COMPLETE

	else
		return ..()

/obj/machinery/chem_master/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/chem_master/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		if(beaker)
			beaker.forceMove(get_turf(src))
			beaker = null
			reagents.clear_reagents()
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(get_turf(src))
			loaded_pill_bottle = null
		return TRUE

/obj/machinery/chem_master/wrench_act(mob/user, obj/item/I)
	if(panel_open)
		return
	return default_unfasten_wrench(user, I, 4 SECONDS)

/obj/machinery/chem_master/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if(ui_act_modal(action, params, ui, state))
		return TRUE

	add_fingerprint(usr)

	. = TRUE
	switch(action)
		if("toggle")
			mode = !mode
		if("ejectp")
			if(loaded_pill_bottle)
				loaded_pill_bottle.forceMove(loc)
				loaded_pill_bottle = null
		if("print")
			if(printing || condi)
				return

			var/idx = text2num(params["idx"]) || 0
			var/from_beaker = text2num(params["beaker"]) || FALSE
			var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
			if(idx < 1 || idx > length(reagent_list))
				return

			var/datum/reagent/R = reagent_list[idx]

			printing = TRUE
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

			var/obj/item/paper/P = new /obj/item/paper(loc)
			P.info = "<center><b>Chemical Analysis</b></center><br>"
			P.info += "<b>Time of analysis:</b> [station_time_timestamp()]<br><br>"
			P.info += "<b>Chemical name:</b> [R.name]<br>"
			if(istype(R, /datum/reagent/blood))
				var/datum/reagent/blood/B = R
				P.info += "<b>Description:</b> N/A<br><b>Blood Type:</b> [B.data["blood_type"]]<br><b>DNA:</b> [B.data["blood_DNA"]]"
			else
				P.info += "<b>Description:</b> [R.description]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Chemical Analysis - [R.name]"
			spawn(50)
				printing = FALSE
		if("set_production_mode")
			var/new_production_mode = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[new_production_mode]
			if(isnull(M))
				return
			production_mode = new_production_mode

		if("set_sprite_style")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			if(!M.sprites)
				return
			var/new_style = text2num(params["style"])
			if(!ISINDEXSAFE(M.sprites, new_style))
				return
			M.set_sprite = new_style
		if("set_items_amount")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			var/new_amount = text2num(params["amount"])
			if(isnull(new_amount) || new_amount < 1 || new_amount > M.max_items_amount)
				return
			M.set_items_amount = new_amount
		if("set_items_name")
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			if(M.set_name == CUSTOM_NAME_DISABLED)
				return
			var/new_name = sanitize(params["name"])
			// Allow name to be set to empty
			if(length(new_name) < 0 || length(new_name) > MAX_CUSTOM_NAME_LEN)
				return
			M.set_name = new_name

		// Container Customization
		if("clear_container_style")
			if(!loaded_pill_bottle)
				return
			loaded_pill_bottle.wrapper_color = null
			loaded_pill_bottle.cut_overlays()
		if("set_container_style")
			if(!loaded_pill_bottle) // wat?
				return
			var/new_color = params["style"]
			if(pill_bottle_wrappers[new_color])
				loaded_pill_bottle.wrapper_color = new_color
				loaded_pill_bottle.apply_wrap()
		else
			. = FALSE

	if(. || !beaker)
		return

	. = TRUE
	var/datum/reagents/R = beaker.reagents
	switch(action)
		if("add")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			R.trans_id_to(src, id, amount)
		if("remove")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(!id || !amount)
				return
			if(mode)
				reagents.trans_id_to(beaker, id, amount)
			else
				reagents.remove_reagent(id, amount)
		if("eject")
			if(!beaker)
				return
			beaker.forceMove(get_turf(src))
			if(Adjacent(usr) && !issilicon(usr))
				usr.put_in_hands(beaker)
			beaker = null
			reagents.clear_reagents()
			update_icon()
		if("create_items")
			if(!reagents.total_volume)
				return
			var/production_mode_key = params["production_mode"]
			var/datum/chemical_production_mode/M = production_modes[production_mode_key]
			if(isnull(M))
				return
			M.synthesize(ui.user, loc, reagents, loaded_pill_bottle)
		else
			return FALSE

/obj/machinery/chem_master/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/chem_master/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/chem_master/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.open()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/chem_master)
	)

/obj/machinery/chem_master/ui_data(mob/user)
	var/data[0]

	data["condi"] = condi
	data["loaded_pill_bottle"] = loaded_pill_bottle ? TRUE : FALSE
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_style"] = loaded_pill_bottle.wrapper_color

	data["beaker"] = beaker ? TRUE : FALSE
	if(beaker)
		var/list/beaker_reagents_list = list()
		data["beaker_reagents"] = beaker_reagents_list
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_reagents_list[++beaker_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
		var/list/buffer_reagents_list = list()
		data["buffer_reagents"] = buffer_reagents_list
		for(var/datum/reagent/R in reagents.reagent_list)
			buffer_reagents_list[++buffer_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
	else
		data["beaker_reagents"] = list()
		data["buffer_reagents"] = list()

	var/production_data = list()
	for(var/key in production_modes)
		var/datum/chemical_production_mode/M = production_modes[key]
		var/mode_data = list(
			"set_items_amount" = M.set_items_amount,
		)
		if(M.set_name != CUSTOM_NAME_DISABLED)
			mode_data["set_name"] = M.set_name
			if(reagents.total_volume)
				mode_data["placeholder_name"] = M.get_placeholder_name(reagents)
		if(M.sprites)
			mode_data["set_sprite"] = M.set_sprite
		production_data[M.mode_id] = mode_data
	data["production_data"] = production_data

	data["mode"] = mode
	data["printing"] = printing

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	data["production_mode"] = production_mode

	return data

/obj/machinery/chem_master/ui_static_data(mob/user)
	var/list/data = list()

	data["maxnamelength"] = MAX_CUSTOM_NAME_LEN

	var/static_production_data = list()
	for(var/key in production_modes)
		var/datum/chemical_production_mode/M = production_modes[key]
		var/mode_data = list(
			"name" = M.production_name,
			"icon" = M.production_icon,
			"max_items_amount" = M.max_items_amount,
			"max_units_per_item" = M.max_units_per_item,
		)
		if(M.sprites)
			var/sprites = list()
			var/indexer = 0
			for(var/sprite in M.sprites)
				sprites += list(list(
					"id" = ++indexer,
					"sprite" = sprite,
				))
			mode_data["sprites"] = sprites
		static_production_data[M.mode_id] = mode_data
	data["static_production_data"] = static_production_data

	var/pill_bottle_styles[0]
	for(var/style in pill_bottle_wrappers)
		pill_bottle_styles += list(list(
			"color" = style,
			"name" = pill_bottle_wrappers[style],
		))
	data["containerstyles"] = pill_bottle_styles

	return data

/**
  * Called in ui_act() to process modal actions
  *
  * Arguments:
  * * action - The action passed by tgui
  * * params - The params passed by tgui
  */
/obj/machinery/chem_master/proc/ui_act_modal(action, params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE
	var/id = params["id"] // The modal's ID
	var/list/arguments = istext(params["arguments"]) ? json_decode(params["arguments"]) : params["arguments"]
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_OPEN)
			switch(id)
				if("analyze")
					var/idx = text2num(arguments["idx"]) || 0
					var/from_beaker = text2num(arguments["beaker"]) || FALSE
					var/reagent_list = from_beaker ? beaker.reagents.reagent_list : reagents.reagent_list
					if(idx < 1 || idx > length(reagent_list))
						return

					var/datum/reagent/R = reagent_list[idx]
					var/list/result = list("idx" = idx, "name" = R.name, "desc" = R.description)
					if(!condi && istype(R, /datum/reagent/blood))
						var/datum/reagent/blood/B = R
						result["blood_type"] = B.data["blood_type"]
						result["blood_dna"] = B.data["blood_DNA"]

					arguments["analysis"] = result
					ui_modal_message(src, id, "", null, arguments)
				if("addcustom")
					if(!beaker || !beaker.reagents.total_volume)
						return
					ui_modal_input(src, id, "Please enter the amount to transfer to buffer:", null, arguments, useramount)
				if("removecustom")
					if(!reagents.total_volume)
						return
					ui_modal_input(src, id, "Please enter the amount to transfer to [mode ? "beaker" : "disposal"]:", null, arguments, useramount)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("addcustom")
					var/amount = isgoodnumber(text2num(answer))
					if(!amount || !arguments["id"])
						return
					ui_act("add", list("id" = arguments["id"], "amount" = amount), ui, state)
				if("removecustom")
					var/amount = isgoodnumber(text2num(answer))
					if(!amount || !arguments["id"])
						return
					ui_act("remove", list("id" = arguments["id"], "amount" = amount), ui, state)
				else
					return FALSE
		else
			return FALSE

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 1
		else
			num = round(num)
		return num
	else
		return FALSE

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	desc = "Used to remove reagents from that single beaker you're using, or create condiment packs and bottles; your choice."
	condi = TRUE

/obj/machinery/chem_master/condimaster/Initialize(mapload)
	. = ..()
	QDEL_LIST_CONTENTS(component_parts)
	component_parts += new /obj/item/circuitboard/chem_master/condi_master(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()

/datum/chemical_production_mode
	var/mode_id = ""
	var/production_name = ""
	/// FontAwesome icon name
	var/production_icon = ""
	var/obj/item/reagent_containers/item_type
	var/list/sprites
	var/max_items_amount = 0
	var/max_units_per_item = 0
	var/name_suffix = ""

	var/set_sprite = 1
	var/set_name = ""
	var/set_items_amount = 1
	var/placeholder_name = ""

/datum/chemical_production_mode/proc/get_placeholder_name(datum/reagents/reagents)
	return get_base_placeholder_name(reagents, clamp(reagents.total_volume / set_items_amount, 0, max_units_per_item))

/datum/chemical_production_mode/proc/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return "[reagents.get_master_reagent_name()] ([amount_per_item]u)"

/**
	public

	Configures the icon of the specified container P.

	required data Data persistent through invocations in the same loop.
	required R The reagents used to make the item P.
	required P The container to configure.
*/
/datum/chemical_production_mode/proc/configure_item(data, datum/reagents/R, obj/item/reagent_containers/P)
	if(sprites)
		P.icon_state = sprites[set_sprite]

/datum/chemical_production_mode/proc/synthesize(user, location, datum/reagents/reagents, obj/item/storage/S = null)
	if(!reagents.total_volume)
		return

	var/medicine_name = set_name
	var/count = set_items_amount
	var/amount_per_item = clamp(reagents.total_volume / count, 0, max_units_per_item)
	if(!isnull(medicine_name) && length(medicine_name) <= 0)
		medicine_name = get_base_placeholder_name(reagents, amount_per_item)

	var/data = list()
	for(var/i in 1 to count)
		if(reagents.total_volume <= 0)
			to_chat(user, "<span class='warning'>Not enough reagents to create these items!</span>")
			return

		var/obj/item/reagent_containers/P = new item_type(location)
		if(!isnull(medicine_name))
			P.name = "[medicine_name][name_suffix]"
		P.scatter_atom()
		configure_item(data, reagents, P)
		reagents.trans_to(P, amount_per_item)

		// Load the items into the bottle if there's one loaded
		if(istype(S) && S.can_be_inserted(P, TRUE))
			P.forceMove(S)

/datum/chemical_production_mode/pills
	mode_id = "pills"
	production_name = "Pills"
	production_icon = "pills"
	item_type = /obj/item/reagent_containers/pill
	max_items_amount = 20
	max_units_per_item = 100
	name_suffix = " pill"

/datum/chemical_production_mode/pills/New()
	. = ..()
	sprites = list()
	for(var/i in 1 to MAX_PILL_SPRITE)
		sprites += list("pill[i]")

/datum/chemical_production_mode/patches
	mode_id = "patches"
	production_name = "Patches"
	production_icon = "plus-square"
	item_type = /obj/item/reagent_containers/patch
	max_items_amount = 20
	max_units_per_item = 30
	name_suffix = " patch"

	var/static/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "silver_sulfadiazine", "salbutamol",
									"omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									"spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									"mitocholide", "rezadone", "menthol", "diphenhydramine", "ephedrine", "iron", "sanguine_reagent")

/datum/chemical_production_mode/patches/New()
	. = ..()
	sprites = list()
	for(var/i in 1 to MAX_PATCH_SPRITE)
		sprites += list("bandaid[i]")

/datum/chemical_production_mode/patches/proc/safety_check(datum/reagents/R)
	for(var/datum/reagent/A in R.reagent_list)
		if(!safe_chem_list.Find(A.id))
			return FALSE
	if(R.chem_temp < SAFE_MIN_TEMPERATURE || R.chem_temp > SAFE_MAX_TEMPERATURE)
		return FALSE
	return TRUE

/datum/chemical_production_mode/patches/configure_item(data, datum/reagents/R, obj/item/reagent_containers/patch/P)
	. = ..()
	var/chemicals_is_safe = data["chemicals_is_safe"]

	if(isnull(chemicals_is_safe))
		chemicals_is_safe = safety_check(R)
		data["chemicals_is_safe"] = chemicals_is_safe

	if(chemicals_is_safe)
		P.instant_application = TRUE

/datum/chemical_production_mode/bottles
	mode_id = "chem_bottles"
	production_name = "Bottles"
	production_icon = "wine-bottle"
	item_type = /obj/item/reagent_containers/glass/bottle/reagent
	sprites = list("bottle", "reagent_bottle")
	max_items_amount = 5
	max_units_per_item = 50
	name_suffix = " bottle"

/datum/chemical_production_mode/bottles/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return reagents.get_master_reagent_name()

/datum/chemical_production_mode/condiment_bottles
	mode_id = "condi_bottles"
	production_name = "Bottles"
	production_icon = "wine-bottle"
	item_type = /obj/item/reagent_containers/condiment
	max_items_amount = 5
	max_units_per_item = 50

	set_name = CUSTOM_NAME_DISABLED

/datum/chemical_production_mode/condiment_packs
	mode_id = "condi_packets"
	production_name = "Packet"
	production_icon = "bacon"
	item_type = /obj/item/reagent_containers/condiment/pack
	max_items_amount = 10
	max_units_per_item = 10
	name_suffix = " pack"

/datum/chemical_production_mode/condiment_packs/get_base_placeholder_name(datum/reagents/reagents, amount_per_item)
	return reagents.get_master_reagent_name()

#undef MAX_PILL_SPRITE
#undef MAX_PATCH_SPRITE
#undef MAX_CUSTOM_NAME_LEN

#undef CUSTOM_NAME_DISABLED

#undef TRANSFER_TO_DISPOSAL
#undef TRANSFER_TO_BEAKER

#undef SAFE_MIN_TEMPERATURE
#undef SAFE_MAX_TEMPERATURE
