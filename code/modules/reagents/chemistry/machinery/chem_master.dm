#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
#define MAX_MULTI_AMOUNT 20 // Max number of pills/patches that can be made at once
#define MAX_UNITS_PER_PILL 100 // Max amount of units in a pill
#define MAX_UNITS_PER_PATCH 30 // Max amount of units in a patch
#define MAX_CUSTOM_NAME_LEN 64 // Max length of a custom pill/condiment/whatever

#define TRANSFER_TO_DISPOSAL 0
#define TRANSFER_TO_BEAKER   1

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
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
	var/bottlesprite = 1
	var/pillsprite = 1
	var/printing = FALSE
	var/static/list/pill_bottle_wrappers
	var/static/list/bottle_styles
	var/list/safe_chem_list = list("antihol", "charcoal", "epinephrine", "insulin", "teporone", "silver_sulfadiazine", "salbutamol",
									"omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									"spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									"mitocholide", "rezadone", "menthol")

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

	if((istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass)) && user.a_intent != INTENT_HARM)
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return
		beaker = I
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
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
	if(default_unfasten_wrench(user, I, time = 4 SECONDS))
		power_change()
		return TRUE

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
			var/obj/item/reagent_containers/food/condiment/P = new(loc)
			reagents.trans_to(P, 50)
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

/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	var/datum/asset/chem_master/assets = get_asset_datum(/datum/asset/chem_master)
	assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemMaster", name, 575, 500)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user)
	var/data[0]

	data["condi"] = condi
	data["loaded_pill_bottle"] = loaded_pill_bottle ? TRUE : FALSE
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_name"] = loaded_pill_bottle.name
		data["loaded_pill_bottle_contents_len"] = loaded_pill_bottle.contents.len
		data["loaded_pill_bottle_storage_slots"] = loaded_pill_bottle.storage_slots

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

	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["mode"] = mode
	data["printing"] = printing

	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

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
				if("change_pill_bottle_style")
					if(!loaded_pill_bottle)
						return
					if(!pill_bottle_wrappers)
						pill_bottle_wrappers = list(
							"CLEAR" = "Default",
							COLOR_RED = "Red",
							COLOR_GREEN = "Green",
							COLOR_PALE_BTL_GREEN = "Pale green",
							COLOR_BLUE = "Blue",
							COLOR_CYAN_BLUE = "Light blue",
							COLOR_TEAL = "Teal",
							COLOR_YELLOW = "Yellow",
							COLOR_ORANGE = "Orange",
							COLOR_PINK = "Pink",
							COLOR_MAROON = "Brown"
						)
					var/current = pill_bottle_wrappers[loaded_pill_bottle.wrapper_color] || "Default"
					ui_modal_choice(src, id, "Please select a wrapper color:", null, arguments, current, pill_bottle_wrappers)
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
				if("create_pill")
					if(condi || !reagents.total_volume)
						return

					var/num = arguments["num"] || 1 // Multi puts a string in `num`, single leaves it null
					num = clamp(round(text2num(num)), 0, MAX_MULTI_AMOUNT)
					if(!num)
						return
					arguments["num"] = num

					var/amount_per_pill = clamp(reagents.total_volume / num, 0, MAX_UNITS_PER_PILL)
					var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_pill]u)"
					var/pills_text = num == 1 ? "new pill" : "[num] new pills"
					ui_modal_input(src, id, "Please name your [pills_text]:", null, arguments, default_name, MAX_CUSTOM_NAME_LEN)
				if("create_pill_multiple")
					if(condi || !reagents.total_volume)
						return
					ui_modal_input(src, id, "Please enter the amount of pills to make (max [MAX_MULTI_AMOUNT] at a time):", null, arguments, pillamount, 5)
				if("change_pill_style")
					var/list/choices = list()
					for(var/i = 1 to MAX_PILL_SPRITE)
						choices += "pill[i].png"
					ui_modal_bento(src, id, "Please select the new style for pills:", null, arguments, pillsprite, choices)
				if("create_patch")
					if(condi || !reagents.total_volume)
						return

					var/num = arguments["num"] || 1 // Multi puts a string in `num`, single leaves it null
					num = clamp(round(text2num(num)), 0, MAX_MULTI_AMOUNT)
					if(!num)
						return
					arguments["num"] = num

					var/amount_per_patch = clamp(reagents.total_volume / num, 0, MAX_UNITS_PER_PATCH)
					var/default_name = "[reagents.get_master_reagent_name()] ([amount_per_patch]u)"
					var/patches_text = num == 1 ? "new patch" : "[num] new patches"
					ui_modal_input(src, id, "Please name your [patches_text]:", null, arguments, default_name, MAX_CUSTOM_NAME_LEN)
				if("create_patch_multiple")
					if(condi || !reagents.total_volume)
						return
					ui_modal_input(src, id, "Please enter the amount of patches to make (max [MAX_MULTI_AMOUNT] at a time):", null, arguments, pillamount, 5)
				if("create_bottle")
					if(condi || !reagents.total_volume)
						return
					ui_modal_input(src, id, "Please name your bottle:", null, arguments, reagents.get_master_reagent_name(), MAX_CUSTOM_NAME_LEN)
				if("change_bottle_style")
					if(!bottle_styles)
						bottle_styles = list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle")
					var/list/bottle_styles_png = list()
					for(var/style in bottle_styles)
						bottle_styles_png += "[style].png"
					ui_modal_bento(src, id, "Please select the new style for bottles:", null, arguments, bottlesprite, bottle_styles_png)
				else
					return FALSE
		if(UI_MODAL_ANSWER)
			var/answer = params["answer"]
			switch(id)
				if("change_pill_bottle_style")
					if(!pill_bottle_wrappers || !loaded_pill_bottle) // wat?
						return
					var/color = "CLEAR"
					for(var/col in pill_bottle_wrappers)
						var/col_name = pill_bottle_wrappers[col]
						if(col_name == answer)
							color = col
							break
					if(length(color) && color != "CLEAR")
						loaded_pill_bottle.wrapper_color = color
						loaded_pill_bottle.apply_wrap()
					else
						loaded_pill_bottle.wrapper_color = null
						loaded_pill_bottle.cut_overlays()
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
					var/obj/item/reagent_containers/food/condiment/pack/P = new(loc)
					P.originalname = answer
					P.name = "[answer] pack"
					P.desc = "A small condiment pack. The label says it contains [answer]."
					reagents.trans_to(P, 10)
				if("create_pill")
					if(condi || !reagents.total_volume)
						return
					var/count = text2num(arguments["num"])
					if(!count)
						return

					if(!length(answer))
						answer = reagents.get_master_reagent_name()
					var/amount_per_pill = clamp(reagents.total_volume / count, 0, MAX_UNITS_PER_PILL)
					while(count--)
						if(reagents.total_volume <= 0)
							to_chat(usr, "<span class='notice'>Not enough reagents to create these pills!</span>")
							return

						var/obj/item/reagent_containers/food/pill/P = new(loc)
						P.name = "[answer] pill"
						P.pixel_x = rand(-7, 7) // Random position
						P.pixel_y = rand(-7, 7)
						P.icon_state = "pill[pillsprite]"
						reagents.trans_to(P, amount_per_pill)
						// Load the pills in the bottle if there's one loaded
						if(istype(loaded_pill_bottle) && loaded_pill_bottle.can_be_inserted(P, TRUE))
							P.forceMove(loaded_pill_bottle)
				if("create_pill_multiple")
					if(condi || !reagents.total_volume)
						return
					ui_act("modal_open", list("id" = "create_pill", "arguments" = list("num" = answer)), ui, state)
				if("change_pill_style")
					var/new_style = clamp(text2num(answer) || 0, 0, MAX_PILL_SPRITE)
					if(!new_style)
						return
					pillsprite = new_style
				if("create_patch")
					if(condi || !reagents.total_volume)
						return
					var/count = text2num(arguments["num"])
					if(!count)
						return

					if(!length(answer))
						answer = reagents.get_master_reagent_name()
					var/amount_per_patch = clamp(reagents.total_volume / count, 0, MAX_UNITS_PER_PATCH)
					var/is_medical_patch = chemical_safety_check(reagents)
					while(count--)
						if(reagents.total_volume <= 0)
							to_chat(usr, "<span class='notice'>Not enough reagents to create these patches!</span>")
							return

						var/obj/item/reagent_containers/food/pill/patch/P = new(loc)
						P.name = "[answer] patch"
						P.pixel_x = rand(-7, 7) // random position
						P.pixel_y = rand(-7, 7)
						reagents.trans_to(P, amount_per_patch)
						if(is_medical_patch)
							P.instant_application = TRUE
							P.icon_state = "bandaid_med"
						// Load the patches in the bottle if there's one loaded
						if(istype(loaded_pill_bottle) && loaded_pill_bottle.can_be_inserted(P, TRUE))
							P.forceMove(loaded_pill_bottle)
				if("create_patch_multiple")
					if(condi || !reagents.total_volume)
						return
					ui_act("modal_open", list("id" = "create_patch", "arguments" = list("num" = answer)), ui, state)
				if("create_bottle")
					if(condi || !reagents.total_volume)
						return

					if(!length(answer))
						answer = reagents.get_master_reagent_name()
					var/obj/item/reagent_containers/glass/bottle/reagent/P = new(loc)
					P.name = "[answer] bottle"
					P.pixel_x = rand(-7, 7) // random position
					P.pixel_y = rand(-7, 7)
					P.icon_state = length(bottle_styles) && bottle_styles[bottlesprite] || "bottle"
					reagents.trans_to(P, 50)
				if("change_bottle_style")
					if(!bottle_styles)
						return
					var/new_sprite = text2num(answer) || 1
					if(new_sprite < 1 || new_sprite > length(bottle_styles))
						return
					bottlesprite = new_sprite
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
#undef MAX_MULTI_AMOUNT
#undef MAX_UNITS_PER_PILL
#undef MAX_UNITS_PER_PATCH
#undef MAX_CUSTOM_NAME_LEN

#undef TRANSFER_TO_DISPOSAL
#undef TRANSFER_TO_BEAKER
