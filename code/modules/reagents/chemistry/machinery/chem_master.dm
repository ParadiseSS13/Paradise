#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
#define MAX_UNITS_PER_PILL 100 // Max amount of units in a pill
#define MAX_UNITS_PER_PATCH 30 // Max amount of units in a patch
#define MAX_UNITS_PER_BOTTLE 50 // Max amount of units in a bottle
#define MAX_CUSTOM_NAME_LEN 64 // Max length of a custom pill/condiment/whatever

#define CHEMMASTER_PRODUCTION_MODE_PILLS 1
#define CHEMMASTER_PRODUCTION_MODE_PATCHES 2
#define CHEMMASTER_PRODUCTION_MODE_BOTTLES 3
#define CHEMMASTER_MIN_PRODUCTION_MODE 1
#define CHEMMASTER_MAX_PRODUCTION_MODE 3
#define CHEMMASTER_MAX_PILLS 20
#define CHEMMASTER_MAX_PATCHES 20
#define CHEMMASTER_MAX_BOTTLES 5

#define TRANSFER_TO_DISPOSAL 0
#define TRANSFER_TO_BEAKER   1

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
	var/pillamount = 10
	var/patchamount = 10
	var/bottleamount = 1
	var/pillname = ""
	var/patchname = ""
	var/bottlename = ""
	var/bottlesprite = 1
	var/production_mode = CHEMMASTER_PRODUCTION_MODE_PILLS
	var/pillsprite = 1
	var/printing = FALSE
	var/static/list/pill_bottle_wrappers = list(
		COLOR_RED = "Red",
		COLOR_GREEN = "Green",
		COLOR_PALE_BTL_GREEN = "Pale Green",
		COLOR_BLUE = "Blue",
		COLOR_CYAN_BLUE = "Light Blue",
		COLOR_TEAL = "Teal",
		COLOR_YELLOW = "Yellow",
		COLOR_ORANGE = "Orange",
		COLOR_PINK = "Pink",
		COLOR_MAROON = "Brown"
	)
	var/static/list/bottle_styles = list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle")
	var/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "silver_sulfadiazine", "salbutamol",
									"omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									"spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									"mitocholide", "rezadone", "menthol", "diphenhydramine", "ephedrine", "iron", "sanguine_reagent")

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

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(loaded_pill_bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity)
	if(severity < 3)
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

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't use [src] while it's panel is opened!</span>")
		return TRUE

	if((istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/drinks/drinkingglass)) && user.a_intent != INTENT_HARM)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return
		I.forceMove(src)
		if(beaker)
			user.put_in_hands(beaker)
			to_chat(user, "<span class='notice'>You swap [I] with [beaker] inside.</span>")
		else
			to_chat(user, "<span class='notice'>You add [I] to the machine.</span>")
		beaker = I
		SStgui.update_uis(src)
		update_icon()

	else if(istype(I, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "<span class='warning'>A [loaded_pill_bottle] is already loaded into the machine.</span>")
			return

		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return

		loaded_pill_bottle = I
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You add [I] into the dispenser slot!</span>")
		SStgui.update_uis(src)
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
			var/new_mode = text2num(params["mode"])
			if(isnull(new_mode))
				return
			production_mode = clamp(new_mode, CHEMMASTER_MIN_PRODUCTION_MODE, CHEMMASTER_MAX_PRODUCTION_MODE)

		// Pills
		if("set_pills_style")
			var/new_style = text2num(params["style"])
			if(isnull(new_style))
				return
			pillsprite = clamp(new_style, 1, MAX_PILL_SPRITE)
		if("set_pills_amount")
			var/new_amount = text2num(params["amount"])
			if(isnull(new_amount))
				return
			pillamount = clamp(new_amount, 1, CHEMMASTER_MAX_PILLS)
		if("set_pills_name")
			var/new_name = sanitize(params["name"])
			// Allow name to be set to empty
			if(length(new_name) < 0 || length(new_name) > MAX_CUSTOM_NAME_LEN)
				return
			pillname = new_name

		// Patches
		if("set_patches_amount")
			var/new_amount = text2num(params["amount"])
			if(isnull(new_amount))
				return
			patchamount = clamp(new_amount, 1, CHEMMASTER_MAX_PATCHES)
		if("set_patches_name")
			var/new_name = sanitize(params["name"])
			// Allow name to be set to empty
			if(length(new_name) < 0 || length(new_name) > MAX_CUSTOM_NAME_LEN)
				return
			patchname = new_name

		// Bottles
		if("set_bottles_style")
			var/new_style = text2num(params["style"])
			if(isnull(new_style))
				return
			bottlesprite = clamp(new_style, 1, length(bottle_styles))
		if("set_bottles_amount")
			var/new_amount = text2num(params["amount"])
			if(isnull(new_amount))
				return
			bottleamount = clamp(new_amount, 1, CHEMMASTER_MAX_BOTTLES)
		if("set_bottles_name")
			var/new_name = sanitize(params["name"])
			// Allow name to be set to empty
			if(length(new_name) < 0 || length(new_name) > MAX_CUSTOM_NAME_LEN)
				return
			bottlename = new_name

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
		if("create_condi_bottle")
			if(!condi || !reagents.total_volume)
				return
			var/obj/item/reagent_containers/condiment/P = new(loc)
			reagents.trans_to(P, 50)
		if("create_pills")
			var/medicine_name = pillname
			var/count = pillamount
			var/amount_per_pill = clamp(reagents.total_volume / count, 0, MAX_UNITS_PER_PILL)
			if(length(pillname) <= 0 || isnull(pillname))
				medicine_name = "[reagents.get_master_reagent_name()] ([amount_per_pill]u)"

			if(condi || !reagents.total_volume)
				return

			for(var/i in 1 to count)
				if(reagents.total_volume <= 0)
					to_chat(ui.user, "<span class='notice'>Not enough reagents to create these pills!</span>")
					return

				var/obj/item/reagent_containers/pill/P = new(loc)
				P.name = "[medicine_name] pill"
				P.pixel_x = rand(-7, 7) // Random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill[pillsprite]"
				reagents.trans_to(P, amount_per_pill)
				// Load the pills in the bottle if there's one loaded
				if(istype(loaded_pill_bottle) && loaded_pill_bottle.can_be_inserted(P, TRUE))
					P.forceMove(loaded_pill_bottle)
		if("create_patches")
			if(condi || !reagents.total_volume)
				return

			var/medicine_name = patchname
			var/count = patchamount
			var/amount_per_patch = clamp(reagents.total_volume / count, 0, MAX_UNITS_PER_PATCH)
			if(length(medicine_name) <= 0 || isnull(medicine_name))
				medicine_name = "[reagents.get_master_reagent_name()] ([amount_per_patch]u)"
			var/is_medical_patch = chemical_safety_check(reagents)
			for(var/i in 1 to count)
				if(reagents.total_volume <= 0)
					to_chat(ui.user, "<span class='notice'>Not enough reagents to create these patches!</span>")
					return

				var/obj/item/reagent_containers/patch/P = new(loc)
				P.name = "[medicine_name] patch"
				P.pixel_x = rand(-7, 7) // random position
				P.pixel_y = rand(-7, 7)
				reagents.trans_to(P, amount_per_patch)
				if(is_medical_patch)
					P.instant_application = TRUE
					P.icon_state = "bandaid_med"
				// Load the patches in the bottle if there's one loaded
				if(istype(loaded_pill_bottle) && loaded_pill_bottle.can_be_inserted(P, TRUE))
					P.forceMove(loaded_pill_bottle)
		if("create_bottles")
			if(condi || !reagents.total_volume)
				return

			var/medicine_name = bottlename
			var/count = bottleamount
			if(length(medicine_name) <= 0 || isnull(medicine_name))
				medicine_name = reagents.get_master_reagent_name()
			var/amount_per_bottle = clamp(reagents.total_volume / count, 0, MAX_UNITS_PER_BOTTLE)
			for(var/i in 1 to count)
				if(reagents.total_volume <= 0)
					to_chat(ui.user, "<span class='notice'>Not enough reagents to create these bottles!</span>")
					return

				var/obj/item/reagent_containers/glass/bottle/reagent/P = new(loc)
				P.name = "[medicine_name] bottle"
				P.pixel_x = rand(-7, 7) // random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = length(bottle_styles) && bottle_styles[bottlesprite] || "bottle"
				reagents.trans_to(P, amount_per_bottle)
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
		data["loaded_pill_bottle_name"] = loaded_pill_bottle.name
		data["loaded_pill_bottle_contents_len"] = loaded_pill_bottle.contents.len
		data["loaded_pill_bottle_storage_slots"] = loaded_pill_bottle.storage_slots
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

	data["pillamount"] = pillamount
	data["patchamount"] = patchamount
	data["bottleamount"] = bottleamount
	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["mode"] = mode
	data["printing"] = printing

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	data["production_mode"] = production_mode

	data["pillname"] = pillname
	data["patchname"] = patchname
	data["bottlename"] = bottlename

	data["maxpills"] = CHEMMASTER_MAX_PILLS
	data["maxpatches"] = CHEMMASTER_MAX_PATCHES
	data["maxbottles"] = CHEMMASTER_MAX_BOTTLES

	if(reagents.total_volume)
		var/amount_per_pill = clamp(reagents.total_volume / pillamount, 0, MAX_UNITS_PER_PILL)
		data["pillplaceholdername"] = "[reagents.get_master_reagent_name()] ([amount_per_pill]u)"
		var/amount_per_patch = clamp(reagents.total_volume / patchamount, 0, MAX_UNITS_PER_PATCH)
		data["patchplaceholdername"] = "[reagents.get_master_reagent_name()] ([amount_per_patch]u)"
		data["bottleplaceholdername"] = reagents.get_master_reagent_name()

	return data

/obj/machinery/chem_master/ui_static_data(mob/user)
	var/list/data = list()

	data["maxnamelength"] = MAX_CUSTOM_NAME_LEN

	var/pill_styles = list()
	for(var/i in 1 to MAX_PILL_SPRITE)
		pill_styles += list(list(
			"id" = i,
			"sprite" = "pill[i]",
		))
	data["pillstyles"] = pill_styles

	var/bottle_styles_with_sprite = list()
	var/bottle_style_indexer = 0
	for(var/style in bottle_styles)
		bottle_style_indexer++
		bottle_styles_with_sprite += list(list(
			"id" = bottle_style_indexer,
			"sprite" = "[style]",
		))
	data["bottlestyles"] = bottle_styles_with_sprite

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
				if("create_condi_pack")
					if(!condi || !reagents.total_volume)
						return
					ui_modal_input(src, id, "Please name your new condiment pack:", null, arguments, reagents.get_master_reagent_name(), MAX_CUSTOM_NAME_LEN)
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
				if("create_condi_pack")
					if(!condi || !reagents.total_volume)
						return
					if(!length(answer))
						answer = reagents.get_master_reagent_name()
					var/obj/item/reagent_containers/condiment/pack/P = new(loc)
					P.originalname = answer
					P.name = "[answer] pack"
					P.desc = "A small condiment pack. The label says it contains [answer]."
					reagents.trans_to(P, 10)
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

/obj/machinery/chem_master/proc/chemical_safety_check(datum/reagents/R)
	var/all_safe = TRUE
	for(var/datum/reagent/A in R.reagent_list)
		if(!safe_chem_list.Find(A.id))
			all_safe = FALSE
	return all_safe

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

#undef MAX_PILL_SPRITE
#undef MAX_UNITS_PER_PILL
#undef MAX_UNITS_PER_PATCH
#undef MAX_UNITS_PER_BOTTLE
#undef MAX_CUSTOM_NAME_LEN

#undef CHEMMASTER_PRODUCTION_MODE_PILLS
#undef CHEMMASTER_PRODUCTION_MODE_PATCHES
#undef CHEMMASTER_PRODUCTION_MODE_BOTTLES
#undef CHEMMASTER_MIN_PRODUCTION_MODE
#undef CHEMMASTER_MAX_PRODUCTION_MODE
#undef CHEMMASTER_MAX_PILLS
#undef CHEMMASTER_MAX_PATCHES
#undef CHEMMASTER_MAX_BOTTLES

#undef TRANSFER_TO_DISPOSAL
#undef TRANSFER_TO_BEAKER
