#define AUTOLATHE_MAIN_MENU		1
#define AUTOLATHE_CATEGORY_MENU	2
#define AUTOLATHE_SEARCH_MENU	3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/operating = 0.0
	var/list/queue = list()
	var/queue_max_len = 12
	var/turf/BuildTurf
	anchored = 1.0
	var/list/L = list()
	var/list/LL = list()
	var/hacked = 0
	var/disabled = 0
	var/shocked = 0
	var/hack_wire
	var/disable_wire
	var/shock_wire
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = FALSE
	var/prod_coeff
	var/datum/wires/autolathe/wires = null

	var/list/being_built = list()
	var/datum/research/files
	var/list/imported = list() // /datum/design.id -> boolean
	var/list/datum/design/matching_designs
	var/temp_search
	var/selected_category
	var/list/recipiecache = list()

	var/list/categories = list("Tools", "Electronics", "Construction", "Communication", "Security", "Machinery", "Medical", "Miscellaneous", "Dinnerware", "Imported")

/obj/machinery/autolathe/New()
	AddComponent(/datum/component/material_container, list(MAT_METAL, MAT_GLASS), _show_on_examine=TRUE, _after_insert=CALLBACK(src, .proc/AfterMaterialInsert))
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/autolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

	wires = new(src)
	files = new /datum/research/autolathe(src)
	matching_designs = list()

/obj/machinery/autolathe/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/autolathe(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/autolathe/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/autolathe/interact(mob/user)
	if(shocked && !(stat & NOPOWER))
		if(shock(user, 50))
			return

	if(panel_open)
		wires.Interact(user)
	else if(!disabled)
		ui_interact(user)

/obj/machinery/autolathe/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Autolathe", name, 750, 700, master_ui, state)
		ui.open()


/obj/machinery/autolathe/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = categories
	if(!recipiecache.len)
		var/list/recipes = list()
		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			var/list/cost_list = design_cost_data(D)
			var/list/matreq = list()
			for(var/list/x in cost_list)
				if(!x["amount"])
					continue
				if(x["name"] == "metal") // Do not use MAT_METAL or MAT_GLASS here.
					matreq["metal"] = x["amount"]
				if(x["name"] == "glass")
					matreq["glass"] = x["amount"]
			var/obj/item/I = D.build_path
			var/maxmult = 1
			if(ispath(D.build_path, /obj/item/stack))
				maxmult = D.maxstack

			var/list/default_categories = D.category
			var/list/categories = istype(default_categories) ? default_categories.Copy() : list()

			if(imported[D.id])
				categories |= "Imported"

			recipes.Add(list(list(
				"name" = D.name,
				"category" = categories,
				"uid" = D.UID(),
				"requirements" =  matreq,
				"hacked" = ("hacked" in categories) ? TRUE : FALSE,
				"max_multiplier" = maxmult,
				"image" = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))]"
			)))
		recipiecache = recipes
	data["recipes"] = recipiecache
	return data

/obj/machinery/autolathe/ui_data(mob/user)
	var/list/data = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	data["total_amount"] = materials.total_amount
	data["max_amount"] = materials.max_amount
	data["fill_percent"] = round((materials.total_amount / materials.max_amount) * 100)
	data["metal_amount"] = materials.amount(MAT_METAL)
	data["glass_amount"] = materials.amount(MAT_GLASS)
	data["busyname"] =  FALSE
	data["busyamt"] = 1
	if(length(being_built) > 0)
		var/datum/design/D = being_built[1]
		data["busyname"] =  istype(D) && D.name ? D.name : FALSE
		data["busyamt"] = length(being_built) > 1 ? being_built[2] : 1
	data["showhacked"] = hacked ? TRUE : FALSE
	data["buildQueue"] = queue
	data["buildQueueLen"] = queue.len
	return data

/obj/machinery/autolathe/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE

	add_fingerprint(usr)

	. = TRUE
	switch(action)
		if("clear_queue")
			queue = list()
		if("remove_from_queue")
			var/index = text2num(params["remove_from_queue"])
			if(isnum(index) && ISINRANGE(index, 1, queue.len))
				remove_from_queue(index)
				to_chat(usr, "<span class='notice'>Removed item from queue.</span>")
		if("make")
			BuildTurf = loc
			var/datum/design/design_last_ordered
			design_last_ordered = locateUID(params["make"])
			if(!istype(design_last_ordered))
				to_chat(usr, "<span class='warning'>Invalid design</span>")
				return
			if(!(design_last_ordered.id in files.known_designs))
				to_chat(usr, "<span class='warning'>Invalid design (not in autolathe's known designs, report this error.)</span>")
				return
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/coeff = get_coeff(design_last_ordered)
			if(design_last_ordered.materials["$metal"] / coeff > materials.amount(MAT_METAL))
				to_chat(usr, "<span class='warning'>Invalid design (not enough metal)</span>")
				return
			if(design_last_ordered.materials["$glass"] / coeff > materials.amount(MAT_GLASS))
				to_chat(usr, "<span class='warning'>Invalid design (not enough glass)</span>")
				return
			if(!hacked && ("hacked" in design_last_ordered.category))
				to_chat(usr, "<span class='warning'>Invalid design (lathe requires hacking)</span>")
				return
			//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
			var/multiplier = text2num(params["multiplier"])
			var/max_multiplier = min(design_last_ordered.maxstack, design_last_ordered.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/design_last_ordered.materials[MAT_METAL]):INFINITY,design_last_ordered.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/design_last_ordered.materials[MAT_GLASS]):INFINITY)
			var/is_stack = ispath(design_last_ordered.build_path, /obj/item/stack)

			if(!is_stack && (multiplier > 1))
				return
			if(!(multiplier in list(1, 10, 25, max_multiplier))) //"enough materials ?" is checked in the build proc
				message_admins("Player [key_name_admin(usr)] attempted to pass invalid multiplier [multiplier] to an autolathe in ui_act. Possible href exploit.")
				return
			if((queue.len + 1) < queue_max_len)
				add_to_queue(design_last_ordered, multiplier)
			else
				to_chat(usr, "<span class='warning'>The autolathe queue is full!</span>")
			if(!busy)
				busy = TRUE
				process_queue()
				busy = FALSE

/obj/machinery/autolathe/ui_status(mob/user, datum/ui_state/state)
	. = disabled ? STATUS_DISABLED : STATUS_INTERACTIVE

	return min(..(), .)

/obj/machinery/autolathe/proc/design_cost_data(datum/design/D)
	var/list/data = list()
	var/coeff = get_coeff(D)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/has_metal = 1
	if(D.materials[MAT_METAL] && (materials.amount(MAT_METAL) < (D.materials[MAT_METAL] / coeff)))
		has_metal = 0
	var/has_glass = 1
	if(D.materials[MAT_GLASS] && (materials.amount(MAT_GLASS) < (D.materials[MAT_GLASS] / coeff)))
		has_glass = 0

	data[++data.len] = list("name" = "metal", "amount" = D.materials[MAT_METAL] / coeff, "is_red" = !has_metal)
	data[++data.len] = list("name" = "glass", "amount" = D.materials[MAT_GLASS] / coeff, "is_red" = !has_glass)

	return data

/obj/machinery/autolathe/proc/queue_data(list/data)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/temp_metal = materials.amount(MAT_METAL)
	var/temp_glass = materials.amount(MAT_GLASS)
	data["processing"] = being_built.len ? get_processing_line() : null
	if(istype(queue) && queue.len)
		var/list/data_queue = list()
		for(var/list/L in queue)
			var/datum/design/D = L[1]
			var/list/LL = get_design_cost_as_list(D, L[2])
			data_queue[++data_queue.len] = list("name" = initial(D.name), "can_build" = can_build(D, L[2], temp_metal, temp_glass), "multiplier" = L[2])
			temp_metal = max(temp_metal - LL[1], 1)
			temp_glass = max(temp_glass - LL[2], 1)
		data["queue"] = data_queue
		data["queue_len"] = data_queue.len
	else
		data["queue"] = null
	return data

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class='alert'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1
	if(exchange_parts(user, O))
		return
	if(stat)
		return 1

	// Disks in general
	if(istype(O, /obj/item/disk))
		if(istype(O, /obj/item/disk/design_disk))
			var/obj/item/disk/design_disk/D = O
			if(D.blueprint)
				var/datum/design/design = D.blueprint // READ ONLY!!

				if(design.id in files.known_designs)
					to_chat(user, "<span class='warning'>This design has already been loaded into the autolathe.</span>")
					return 1

				if(!files.CanAddDesign2Known(design))
					to_chat(user, "<span class='warning'>This design is not compatible with the autolathe.</span>")
					return 1
				user.visible_message("[user] begins to load \the [O] in \the [src]...",
					"You begin to load a design from \the [O]...",
					"You hear the chatter of a floppy drive.")
				playsound(get_turf(src), 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
				busy = TRUE
				if(do_after(user, 14.4, target = src))
					imported[design.id] = TRUE
					files.AddDesign2Known(design)
					recipiecache = list()
					SStgui.close_uis(src) // forces all connected users to re-open the TGUI. Imported entries won't show otherwise due to static_data
				busy = FALSE
			else
				to_chat(user, "<span class='warning'>That disk does not have a design on it!</span>")
			return 1
		else
			// So that people who are bad at computers don't shred their disks
			to_chat(user, "<span class='warning'>This is not the correct type of disk for the autolathe!</span>")
			return 1

	return ..()

/obj/machinery/autolathe/crowbar_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(busy)
		to_chat(user, "<span class='alert'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return
	if(panel_open)
		default_deconstruction_crowbar(user, I)

/obj/machinery/autolathe/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(busy)
		to_chat(user, "<span class='alert'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return
	default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", I)

/obj/machinery/autolathe/wirecutter_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(busy)
		to_chat(user, "<span class='alert'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return
	interact(user)

/obj/machinery/autolathe/multitool_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	if(busy)
		to_chat(user, "<span class='alert'>The autolathe is busy. Please wait for completion of previous operation.</span>")
		return
	interact(user)

/obj/machinery/autolathe/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	switch(id_inserted)
		if(MAT_METAL)
			flick("autolathe_o", src)//plays metal insertion animation
		if(MAT_GLASS)
			flick("autolathe_r", src)//plays glass insertion animation
	use_power(min(1000, amount_inserted / 100))
	SStgui.update_uis(src)

/obj/machinery/autolathe/attack_ghost(mob/user)
	interact(user)

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..(user, 0))
		return
	interact(user)

/obj/machinery/autolathe/RefreshParts()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.max_amount = tot_rating * 3
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1
	recipiecache = list()
	SStgui.close_uis(src) // forces all connected users to re-open the TGUI. Imported entries won't show otherwise due to static_data

/obj/machinery/autolathe/proc/get_coeff(datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)//stacks are unaffected by production coefficient
	return coeff

/obj/machinery/autolathe/proc/build_item(datum/design/D, multiplier)
	desc = initial(desc)+"\nIt's building \a [initial(D.name)]."
	var/is_stack = ispath(D.build_path, /obj/item/stack)
	var/coeff = get_coeff(D)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/metal_cost = D.materials[MAT_METAL]
	var/glass_cost = D.materials[MAT_GLASS]
	var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)
	if(can_build(D, multiplier))
		being_built = list(D, multiplier)
		use_power(power)
		icon_state = "autolathe"
		flick("autolathe_n",src)
		if(is_stack)
			var/list/materials_used = list(MAT_METAL=metal_cost*multiplier, MAT_GLASS=glass_cost*multiplier)
			materials.use_amount(materials_used)
		else
			var/list/materials_used = list(MAT_METAL=metal_cost/coeff, MAT_GLASS=glass_cost/coeff)
			materials.use_amount(materials_used)
		SStgui.update_uis(src)
		sleep(32/coeff)
		if(is_stack)
			var/obj/item/stack/S = new D.build_path(BuildTurf)
			S.amount = multiplier
		else
			var/obj/item/new_item = new D.build_path(BuildTurf)
			new_item.update_materials_coeff(coeff)
	SStgui.update_uis(src)
	desc = initial(desc)

/obj/machinery/autolathe/proc/can_build(datum/design/D, multiplier = 1, custom_metal, custom_glass)
	if(D.make_reagents.len)
		return 0

	var/coeff = get_coeff(D)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/metal_amount = materials.amount(MAT_METAL)
	if(custom_metal)
		metal_amount = custom_metal
	var/glass_amount = materials.amount(MAT_GLASS)
	if(custom_glass)
		glass_amount = custom_glass

	if(D.materials[MAT_METAL] && (metal_amount < (multiplier*D.materials[MAT_METAL] / coeff)))
		return 0
	if(D.materials[MAT_GLASS] && (glass_amount < (multiplier*D.materials[MAT_GLASS] / coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost_as_list(datum/design/D, multiplier = 1)
	var/list/OutputList = list(0,0)
	var/coeff = get_coeff(D)
	if(D.materials[MAT_METAL])
		OutputList[1] = (D.materials[MAT_METAL] / coeff)*multiplier
	if(D.materials[MAT_GLASS])
		OutputList[2] = (D.materials[MAT_GLASS] / coeff)*multiplier
	return OutputList

/obj/machinery/autolathe/proc/get_processing_line()
	var/datum/design/D = being_built[1]
	var/multiplier = being_built[2]
	var/is_stack = (multiplier>1)
	var/output = "PROCESSING: [initial(D.name)][is_stack?" (x[multiplier])":null]"
	return output

/obj/machinery/autolathe/proc/add_to_queue(D, multiplier)
	if(!istype(queue))
		queue = list()
	if(D)
		queue.Add(list(list(D,multiplier)))
	return queue.len

/obj/machinery/autolathe/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/autolathe/proc/process_queue()
	var/datum/design/D = queue[1][1]
	var/multiplier = queue[1][2]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	while(D)
		if((stat & (NOPOWER|BROKEN)) || disabled)
			being_built = new /list()
			return 0
		if(!can_build(D, multiplier))
			visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Not enough resources. Queue processing terminated.\"")
			queue = list()
			being_built = new /list()
			return 0

		remove_from_queue(1)
		build_item(D,multiplier)
		D = listgetindex(listgetindex(queue, 1),1)
		multiplier = listgetindex(listgetindex(queue,1),2)
	being_built = new /list()

/obj/machinery/autolathe/proc/adjust_hacked(hack)
	hacked = hack

	if(hack)
		for(var/datum/design/D in files.possible_designs)
			if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
				files.AddDesign2Known(D)
	else
		for(var/datum/design/D in files.known_designs)
			if("hacked" in D.category)
				files.known_designs -= D.id
	SStgui.close_uis(src) // forces all connected users to re-open the TGUI, thus adding/removing hacked entries from lists
	recipiecache = list()

/obj/machinery/autolathe/proc/check_hacked_callback()
	if(!wires.is_cut(WIRE_AUTOLATHE_HACK))
		adjust_hacked(FALSE)

/obj/machinery/autolathe/proc/check_electrified_callback()
	if(!wires.is_cut(WIRE_ELECTRIFY))
		shocked = FALSE

/obj/machinery/autolathe/proc/check_disabled_callback()
	if(!wires.is_cut(WIRE_AUTOLATHE_DISABLE))
		disabled = FALSE

/obj/machinery/autolathe/security
	name = "Security Autolathe"
	desc = "Autolathe with preloaded open recipes"
	icon = 'icons/obj/machines/sec_autolathe.dmi'

/obj/machinery/autolathe/security/New()
	. = ..()
	for (wires)
		wires.cut(WIRE_AUTOLATHE_HACK)
	adjust_hacked(TRUE)

