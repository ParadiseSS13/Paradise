/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = FALSE
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/patchamount = 10
	var/bottlesprite = "bottle"
	var/pillsprite = "1"
	var/client/has_sprites = list()
	var/printing = FALSE

/obj/machinery/chem_master/New()
	..()
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

/obj/machinery/chem_master/update_icon()
	overlays.Cut()
	icon_state = "mixer[beaker ? "1" : "0"][powered() ? "" : "_nopower"]"
	if(powered())
		overlays += "waitlight"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if(prob(50))
		qdel(src)

/obj/machinery/chem_master/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	update_icon()

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	if(panel_open)
		to_chat(user, "<span class='warning'>You can't use the [name] while it's panel is opened!</span>")
		return TRUE

	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine.</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[I] is stuck to you!</span>")
			return
		beaker = I
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine!</span>")
		SSnanoui.update_uis(src)
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
		SSnanoui.update_uis(src)
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
	if(default_unfasten_wrench(user, I))
		power_change()
		return TRUE

/obj/machinery/chem_master/Topic(href, href_list)
	if(..())
		return TRUE

	add_fingerprint(usr)
	usr.set_machine(src)


	if(href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.forceMove(loc)
			loaded_pill_bottle = null
	else if(href_list["change_pillbottle"])
		if(loaded_pill_bottle)
			var/list/wrappers = list("Default wrapper", "Red wrapper", "Green wrapper", "Pale green wrapper", "Blue wrapper", "Light blue wrapper", "Teal wrapper", "Yellow wrapper", "Orange wrapper", "Pink wrapper", "Brown wrapper")
			var/chosen = input(usr, "Select a pillbottle wrapper", "Pillbottle wrapper", wrappers[1]) as null|anything in wrappers
			if(!chosen)
				return
			var/color
			switch(chosen)
				if("Default wrapper")
					loaded_pill_bottle.cut_overlays()
					return
				if("Red wrapper")
					color = COLOR_RED
				if("Green wrapper")
					color = COLOR_GREEN
				if("Pink wrapper")
					color = COLOR_PINK
				if("Teal wrapper")
					color = COLOR_TEAL
				if("Blue wrapper")
					color = COLOR_BLUE
				if("Brown wrapper")
					color = COLOR_MAROON
				if("Light blue wrapper")
					color = COLOR_CYAN_BLUE
				if("Yellow wrapper")
					color = COLOR_YELLOW
				if("Pale green wrapper")
					color = COLOR_PALE_BTL_GREEN
				if("Orange wrapper")
					color = COLOR_ORANGE
			loaded_pill_bottle.wrapper_color = color;
			loaded_pill_bottle.apply_wrap();
	else if(href_list["close"])
		usr << browse(null, "window=chem_master")
		onclose(usr, "chem_master")
		usr.unset_machine()
		return

	if(href_list["print_p"])
		if(!printing)
			printing = TRUE
			visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			var/obj/item/paper/P = new /obj/item/paper(loc)
			P.info = "<CENTER><B>Chemical Analysis</B></CENTER><BR>"
			P.info += "<b>Time of analysis:</b> [station_time_timestamp()]<br><br>"
			P.info += "<b>Chemical name:</b> [href_list["name"]]<br>"
			if(href_list["name"] == "Blood")
				var/datum/reagents/R = beaker.reagents
				var/datum/reagent/blood/G
				for(var/datum/reagent/F in R.reagent_list)
					if(F.name == href_list["name"])
						G = F
						break
				var/B = G.data["blood_type"]
				var/C = G.data["blood_DNA"]
				P.info += "<b>Description:</b><br>Blood Type: [B]<br>DNA: [C]"
			else
				P.info += "<b>Description:</b> [href_list["desc"]]"
			P.info += "<br><br><b>Notes:</b><br>"
			P.name = "Chemical Analysis - [href_list["name"]]"
			printing = FALSE

	if(beaker)
		var/datum/reagents/R = beaker.reagents
		if(href_list["analyze"])
			var/dat = ""
			if(!condi)
				if(href_list["name"] == "Blood")
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in R.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]"
				else
					dat += "<TITLE>Chemmaster 3000</TITLE>Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]"
				dat += "<BR><BR><A href='?src=[UID()];print_p=1;desc=[href_list["desc"]];name=[href_list["name"]]'>(Print Analysis)</A><BR>"
				dat += "<A href='?src=[UID()];main=1'>(Back)</A>"
			else
				dat += "<TITLE>Condimaster 3000</TITLE>Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=[UID()];main=1'>(Back)</A>"
			usr << browse(dat, "window=chem_master;size=575x500")
			return

		else if(href_list["add"])

			if(href_list["amount"])
				var/id = href_list["add"]
				var/amount = text2num(href_list["amount"])
				R.trans_id_to(src, id, amount)

		else if(href_list["addcustom"])

			var/id = href_list["addcustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			Topic(null, list("amount" = "[useramount]", "add" = "[id]"))

		else if(href_list["remove"])

			if(href_list["amount"])
				var/id = href_list["remove"]
				var/amount = text2num(href_list["amount"])
				if(mode)
					reagents.trans_id_to(beaker, id, amount)
				else
					reagents.remove_reagent(id, amount)


		else if(href_list["removecustom"])

			var/id = href_list["removecustom"]
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			useramount = isgoodnumber(useramount)
			Topic(null, list("amount" = "[useramount]", "remove" = "[id]"))

		else if(href_list["toggle"])
			mode = !mode

		else if(href_list["main"])
			attack_hand(usr)
			return
		else if(href_list["eject"])
			if(beaker)
				beaker.forceMove(get_turf(src))
				if(Adjacent(usr) && !issilicon(usr))
					usr.put_in_hands(beaker)
				beaker = null
				reagents.clear_reagents()
				update_icon()
		else if(href_list["createpill"] || href_list["createpill_multiple"])
			if(!condi)
				var/count = 1
				if(href_list["createpill_multiple"])
					count = input("Select the number of pills to make.", 10, pillamount) as num|null
					if(count == null)
						return
					count = isgoodnumber(count)
				if(count > 20)
					count = 20	//Pevent people from creating huge stacks of pills easily. Maybe move the number to defines?
				if(count <= 0)
					return
				var/amount_per_pill = reagents.total_volume / count
				if(amount_per_pill > 100)
					amount_per_pill = 100
				var/name = clean_input("Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill]u)")
				if(!name)
					return
				name = reject_bad_text(name)
				while(count--)
					if(reagents.total_volume <= 0)
						to_chat(usr, "<span class='notice'>Not enough reagents to create these pills!</span>")
						return
					var/obj/item/reagent_containers/food/pill/P = new/obj/item/reagent_containers/food/pill(loc)
					if(!name)
						name = reagents.get_master_reagent_name()
					P.name = "[name] pill"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					P.icon_state = "pill"+pillsprite
					reagents.trans_to(P, amount_per_pill)
					if(loaded_pill_bottle && loaded_pill_bottle.type == /obj/item/storage/pill_bottle)
						if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
							P.forceMove(loaded_pill_bottle)
							updateUsrDialog()
			else
				var/name = clean_input("Name:", "Name your bag!", reagents.get_master_reagent_name())
				if(!name)
					return
				name = reject_bad_text(name)
				var/obj/item/reagent_containers/food/condiment/pack/P = new/obj/item/reagent_containers/food/condiment/pack(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.originalname = name
				P.name = "[name] pack"
				P.desc = "A small condiment pack. The label says it contains [name]."
				reagents.trans_to(P, 10)
		else if(href_list["createpatch"] || href_list["createpatch_multiple"])
			if(!condi)
				var/count = 1
				if(href_list["createpatch_multiple"])
					count = input("Select the number of patches to make.", 10, patchamount) as num|null
					if(count == null)
						return
					count = isgoodnumber(count)
				if(!count || count <= 0)
					return
				if(count > 20)
					count = 20	//Pevent people from creating huge stacks of patches easily. Maybe move the number to defines?
				var/amount_per_patch = reagents.total_volume/count
				if(amount_per_patch > 40)
					amount_per_patch = 40
				var/name = clean_input("Name:", "Name your patch!", "[reagents.get_master_reagent_name()] ([amount_per_patch]u)")
				if(!name)
					return
				name = reject_bad_text(name)
				var/is_medical_patch = chemical_safety_check(reagents)
				while(count--)
					var/obj/item/reagent_containers/food/pill/patch/P = new/obj/item/reagent_containers/food/pill/patch(loc)
					if(!name) name = reagents.get_master_reagent_name()
					P.name = "[name] patch"
					P.pixel_x = rand(-7, 7) //random position
					P.pixel_y = rand(-7, 7)
					reagents.trans_to(P,amount_per_patch)
					if(is_medical_patch)
						P.instant_application = TRUE
						P.icon_state = "bandaid_med"
					if(loaded_pill_bottle && loaded_pill_bottle.type == /obj/item/storage/pill_bottle/patch_pack)
						if(loaded_pill_bottle.contents.len < loaded_pill_bottle.storage_slots)
							P.forceMove(loaded_pill_bottle)
							updateUsrDialog()

		else if(href_list["createbottle"])
			if(!condi)
				var/name = clean_input("Name:", "Name your bottle!", reagents.get_master_reagent_name())
				if(!name)
					return
				name = reject_bad_text(name)
				var/obj/item/reagent_containers/glass/bottle/reagent/P = new/obj/item/reagent_containers/glass/bottle/reagent(loc)
				if(!name)
					name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = bottlesprite
				reagents.trans_to(P, 50)
			else
				var/obj/item/reagent_containers/food/condiment/P = new/obj/item/reagent_containers/food/condiment(loc)
				reagents.trans_to(P, 50)
		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 20 //max icon state of the pill sprites
			var/dat = "<table>"
			var/j = 0
			for(var/i = 1 to MAX_PILL_SPRITE)
				j++
				if(j == 1)
					dat += "<tr>"
				dat += "<td><a href=\"?src=[UID()]&pill_sprite=[i]\"><img src=\"pill[i].png\" /></a></td>"
				if(j == 5)
					dat += "</tr>"
					j = 0
			dat += "</table>"
			usr << browse(dat, "window=chem_master_iconsel;size=225x193")
			return
		else if(href_list["change_bottle"])
			var/dat = "<table>"
			var/j = 0
			for(var/i in list("bottle", "small_bottle", "wide_bottle", "round_bottle", "reagent_bottle"))
				j++
				if(j == 1)
					dat += "<tr>"
				dat += "<td><a href=\"?src=[UID()]&bottle_sprite=[i]\"><img src=\"[i].png\" /></a></td>"
				if(j == 5)
					dat += "</tr>"
					j = 0
			dat += "</table>"
			usr << browse(dat, "window=chem_master_iconsel;size=225x193")
			return
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
			usr << browse(null, "window=chem_master_iconsel")
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
			usr << browse(null, "window=chem_master_iconsel")

	SSnanoui.update_uis(src)

/obj/machinery/chem_master/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_master/attack_ghost(mob/user)
	if(user.can_admin_interact())
		return attack_hand(user)

/obj/machinery/chem_master/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	var/datum/asset/chem_master/assets = get_asset_datum(/datum/asset/chem_master)
	assets.send(user)

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "chem_master.tmpl", name, 575, 500)
		ui.open()

/obj/machinery/chem_master/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["condi"] = condi
	data["loaded_pill_bottle"] = (loaded_pill_bottle ? 1 : 0)
	if(loaded_pill_bottle)
		data["loaded_pill_bottle_contents_len"] = loaded_pill_bottle.contents.len
		data["loaded_pill_bottle_storage_slots"] = loaded_pill_bottle.storage_slots

	data["beaker"] = (beaker ? 1 : 0)
	if(beaker)
		var/list/beaker_reagents_list = list()
		data["beaker_reagents"] = beaker_reagents_list
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beaker_reagents_list[++beaker_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)
		var/list/buffer_reagents_list = list()
		data["buffer_reagents"] = buffer_reagents_list
		for(var/datum/reagent/R in reagents.reagent_list)
			buffer_reagents_list[++buffer_reagents_list.len] = list("name" = R.name, "volume" = R.volume, "id" = R.id, "description" = R.description)

	data["pillsprite"] = pillsprite
	data["bottlesprite"] = bottlesprite
	data["mode"] = mode

	return data

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
		return 0

/obj/machinery/chem_master/proc/chemical_safety_check(datum/reagents/R)
	var/all_safe = TRUE
	for(var/datum/reagent/A in R.reagent_list)
		if(!GLOB.safe_chem_list.Find(A.id))
			all_safe = FALSE
	return all_safe

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	condi = TRUE

/obj/machinery/chem_master/condimaster/New()
	..()
	QDEL_LIST(component_parts)
	component_parts += new /obj/item/circuitboard/chem_master/condi_master(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
