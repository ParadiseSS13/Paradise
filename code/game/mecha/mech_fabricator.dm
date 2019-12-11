
#define MECHFAB_MAIN_MENU		1
#define MECHFAB_CATEGORY_MENU	2
#define MECHFAB_SEARCH_MENU		3
#define MECHFAB_MATERIALS_MENU	4

/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	var/time_coeff = 1.15  // Determines build time for parts
	var/component_coeff = 1.20  // Determines cost of parts
	var/datum/research/files
	var/fabricator_type = MECHFAB
	var/temp_search
	var/wait_message // Used for popping up a wait message when the user presses sync
	var/wait_message_timer
	var/datum/design/being_built // The design currently being built
	var/list/queue = list()  // list of designs currently in the queue
	var/screen = MECHFAB_MAIN_MENU  // Which screen the mechfab is at. 1 is main menu, 2 is category etc. From the #defines
	var/selected_category  // Which category the mechfab is currently displaying. See list below
	var/list/categories = list("Cyborg", "Cyborg Repair", "Cyborg Upgrade Modules", "Ripley", "Firefighter", "Odysseus", "Gygax", "Durand", \
							   "H.O.N.K", "Reticence", "Phazon", "Exosuit Equipment", "Medical", "Misc")

/obj/machinery/mecha_part_fabricator/New()
	var/datum/component/material_container/materials = AddComponent(
		/datum/component/material_container,
		list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TRANQUILLITE, MAT_TITANIUM, MAT_BLUESPACE),
		0,
		FALSE,
		/obj/item/stack,
		CALLBACK(src, .proc/is_insertion_ready),
		CALLBACK(src, .proc/AfterMaterialInsert)
	)
	materials.precise_insertion = TRUE
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/mecha_part_fabricator/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mechfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mecha_part_fabricator/Destroy()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	return ..()

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0

	//maximum stocking amount (default 300000, 600000 at T4)
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.max_amount = (200000 + (T*50000))

	// build time adjustment coefficient (1 -> 0.85 -> 0.7 -> 0.55)
	for(var/obj/item/stock_parts/micro_laser/Ml in component_parts)
		time_coeff = initial(time_coeff) - Ml.rating*0.15

	// resource cost adjustment coefficient (1 -> 0.8 -> 0.6 -> 0.4)
	for(var/obj/item/stock_parts/manipulator/Ma in component_parts)
		component_coeff = initial(component_coeff) - Ma.rating*0.20

/obj/machinery/mecha_part_fabricator/interact(mob/user)
	ui_interact(user)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "mech_fabricator.tmpl", name, 900, 600)
		ui.open()

/obj/machinery/mecha_part_fabricator/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	var/data[0]

	files.RefreshResearch()

	GET_COMPONENT(materials, /datum/component/material_container)
	data["screen"] = screen
	data["total_amount"] = materials.total_amount
	data["max_amount"] = materials.max_amount
	data["wait_message"] = wait_message

	switch(screen)
		if(MECHFAB_MAIN_MENU)
			data["uid"] = UID()
			data["categories"] = categories

		if(MECHFAB_CATEGORY_MENU)
			var/list/designs = list()
			for(var/I in files.known_designs)
				var/datum/design/D = files.known_designs[I]
				if(!(D.build_type & fabricator_type) || !(selected_category in D.category))
					continue
				var/list/current_design = list()
				designs[++designs.len] = current_design
				current_design["name"] = D.name
				current_design["id"] = D.id
				current_design["materials"] = design_cost_data(D)
			data["designs"] = designs
			data["selected_category"] = selected_category
			data["designs_len"] = designs.len

		if(MECHFAB_SEARCH_MENU)
			var/list/designs = list()
			for(var/I in files.known_designs)
				var/datum/design/D = files.known_designs[I]
				if(!(D.build_type & fabricator_type))
					continue
				if(findtext(D.name, temp_search))
					var/list/current_design = list()
					designs[++designs.len] = current_design
					current_design["name"] = D.name
					current_design["id"] = D.id
					current_design["materials"] = design_cost_data(D)
			data["designs"] = designs
			data["search"] = temp_search
			data["designs_len"] = designs.len

		if(MECHFAB_MATERIALS_MENU)
			var/list/materials_list = list()
			var/list/mats = materials.materials // Materials list in the material_container component. Shortening the name to make it less abnoxious.
			for(var/M in mats)
				materials_list[++materials_list.len] = list("name" = mats[M].name, "id" = mats[M].id, "amount" = mats[M].amount)
			data["loaded_materials"] = materials_list

	data["processing"] = being_built ? "PROCESSING: [initial(being_built.name)]" : null
	var/list/data_queue = list()
	if(queue?.len)
		for(var/datum/design/D in queue)
			data_queue[++data_queue.len] = list("name" = initial(D.name), "can_build" = can_build(D))
		data["queue"] = data_queue
	else
		data["queue"] = null

	return data

// Gets the cost of each material type from the design as a list
/obj/machinery/mecha_part_fabricator/proc/design_cost_data(datum/design/D)
	GET_COMPONENT(materials, /datum/component/material_container)
	var/list/data = list()
	var/material_name
	var/material_amount

	for(var/R in D.materials)
		material_amount = get_resource_cost_w_coeff(D, R)
		material_name = CallMaterialName(R) // Formatted name so it looks nice. Ex: Metal, Solid Plasma
		data[++data.len] = list("name" = material_name, "amount" = material_amount, "is_red" = materials.amount(R) < material_amount)
	return data

// Returns true if the mech fab can build the specified design
/obj/machinery/mecha_part_fabricator/proc/can_build(datum/design/D)
	GET_COMPONENT(materials, /datum/component/material_container)
	if(materials.has_materials(get_all_resources_w_coeff(D)))
		return TRUE
	return FALSE

/obj/machinery/mecha_part_fabricator/proc/get_all_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		resources[R] = get_resource_cost_w_coeff(D, R)
	return resources

/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, resource, roundto = 1)
	return round(D.materials[resource] * component_coeff, roundto)

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(datum/design/D, roundto = 1) //aran
	return round(initial(D.construction_time) * time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D)
	being_built = D
	desc = "It's building \a [initial(D.name)]."
	var/list/res_coef = get_all_resources_w_coeff(D)

	GET_COMPONENT(materials, /datum/component/material_container)
	materials.use_amount(res_coef)
	overlays += "fab-active"
	use_power = ACTIVE_POWER_USE
	SSnanoui.update_uis(src)
	sleep(get_construction_time_w_coeff(D))
	use_power = IDLE_POWER_USE
	overlays -= "fab-active"
	desc = initial(desc)

	var/obj/item/I = new D.build_path(loc)
	if(D.locked)
		var/obj/item/storage/lockbox/research/large/L = new /obj/item/storage/lockbox/research/large(get_step(src, SOUTH))
		I.forceMove(L)
		L.name += " ([I.name])"
		L.origin_tech = I.origin_tech
	else
		I.forceMove(get_step(src, SOUTH))
	if(istype(I))
		I.materials = res_coef
	atom_say("[I] is complete.")
	being_built = null

	SSnanoui.update_uis(src)
	return TRUE

// Add a single part to the queue
/obj/machinery/mecha_part_fabricator/proc/add_to_queue(datum/design/D)
	if(!istype(queue))
		queue = list()
	if(D && istype(D))
		queue[++queue.len] = D
		return TRUE
	return FALSE

// Removes an item from the queue at the specified index
/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index < 1 || index > queue.len))
		return FALSE
	queue.Cut(index, index + 1)
	return TRUE

// Starts building whatever is in the queue
/obj/machinery/mecha_part_fabricator/proc/process_queue()
	var/datum/design/D = queue[1]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	while(D)
		if(stat & (NOPOWER|BROKEN))
			return FALSE
		if(!can_build(D))
			atom_say("Not enough resources. Queue processing stopped.")
			return FALSE
		remove_from_queue(1)
		build_part(D)
		D = listgetindex(queue, 1)
	atom_say("Queue processing finished successfully.")

// Syncs with the local R&D console in the area
/obj/machinery/mecha_part_fabricator/proc/sync()
	add_wait_message("Syncing with local R&D database...", 30)
	SSnanoui.update_uis(src) // To get the wait message to show up
	sleep(30) //only sleep if called by user
	var/area/localarea = get_area(src)

	for(var/obj/machinery/computer/rdconsole/RDC in localarea.contents)
		if(!RDC.sync)
			continue
		RDC.files.push_data(files)
		SSnanoui.update_uis(src)
		atom_say("Successfully synchronized with R&D server.")

	SSnanoui.update_uis(src)
	atom_say("Failed to sync with R&D server.")
	return FALSE

// The two procs below are copied exactly from the R&D console (rdconsole.dm). See documentation written there if you need to learn more
/obj/machinery/mecha_part_fabricator/proc/add_wait_message(message, delay)
	wait_message = message
	wait_message_timer = addtimer(CALLBACK(src, .proc/clear_wait_message), delay, TIMER_UNIQUE | TIMER_STOPPABLE)

/obj/machinery/mecha_part_fabricator/proc/clear_wait_message()
	wait_message = ""
	if(wait_message_timer)
		deltimer(wait_message_timer)
		wait_message_timer = 0
	SSnanoui.update_uis(src)

/obj/machinery/mecha_part_fabricator/attack_ghost(mob/user)
	interact(user)

/obj/machinery/mecha_part_fabricator/attack_hand(mob/user)
	if(..())
		return 1
	if(!allowed(user) && !isobserver(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 1
	return interact(user)

/obj/machinery/mecha_part_fabricator/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["menu"]) // Main menu
		screen = MECHFAB_MAIN_MENU

	if(href_list["category"]) // Inside a "category": cyborg parts, medical etc.
		selected_category = href_list["category"]
		screen = MECHFAB_CATEGORY_MENU

	if(href_list["search"])
		if(href_list["to_search"])
			temp_search = href_list["to_search"]
		if(!temp_search)
			return
		screen = MECHFAB_SEARCH_MENU

	if(href_list["add_to_queue"])
		var/design = href_list["add_to_queue"]
		for(var/I in files.known_designs)
			var/datum/design/D = files.known_designs[I]
			if(!(D.build_type & fabricator_type))
				continue
			if(D.id == design)
				add_to_queue(D)
				break

	if(href_list["category_add_all"])
		for(var/I in files.known_designs)
			var/datum/design/D = files.known_designs[I]
			if((D.build_type & fabricator_type) && selected_category in D.category)
				add_to_queue(D)

	if(href_list["main_menu_add_all"])
		selected_category = href_list["main_menu_add_all"]
		for(var/I in files.known_designs)
			var/datum/design/D = files.known_designs[I]
			if((D.build_type & fabricator_type) && selected_category in D.category)
				add_to_queue(D)
		selected_category = null

	if(href_list["remove_from_queue"])
		var/index = text2num(href_list["remove_from_queue"])
		remove_from_queue(index)

	if(href_list["process_queue"])
		spawn(0)
			if(being_built)
				return FALSE
			process_queue()

	if(href_list["clear_queue"])
		queue.Cut()

	if(href_list["curr_index"] && href_list["new_index"])
		var/curr_index = text2num(href_list["curr_index"])
		var/new_index = text2num(href_list["new_index"])
		if(isnum(curr_index) && isnum(new_index))
			if(IsInRange(curr_index, 1, queue.len) && IsInRange(new_index, 1, queue.len))
				queue.Swap(curr_index, new_index)

	if(href_list["sync"])
		sync()

	if(href_list["material_storage"])
		screen = MECHFAB_MATERIALS_MENU

	if(href_list["remove_mat"])
		GET_COMPONENT(materials, /datum/component/material_container)
		var/desired_num_sheets
		if(href_list["remove_mat_amount"] == "custom")
			desired_num_sheets = input("How many sheets would you like to eject from the machine?", "How much?", 1) as null|num
			if(!desired_num_sheets)
				return
		else
			desired_num_sheets = text2num(href_list["remove_mat_amount"])

		if(!isnum(desired_num_sheets))
			CRASH("A non-number got passed to a mach fabricator's remove_mat section")
		desired_num_sheets = max(0, desired_num_sheets) // If you input too high of a number, the mineral datum will take care of it either way
		desired_num_sheets = round(desired_num_sheets) // No partial-sheet goofery
		materials.retrieve_sheets(desired_num_sheets, href_list["remove_mat"])

	SSnanoui.update_uis(src)
	return

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	var/stack_name = material2name(id_inserted)
	overlays += "fab-load-[stack_name]"
	sleep(10)
	overlays -= "fab-load-[stack_name]"
	SSnanoui.update_uis(src)

/obj/machinery/mecha_part_fabricator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return TRUE

	else
		return ..()

/obj/machinery/mecha_part_fabricator/proc/material2name(ID)
	return copytext(ID,2)

/obj/machinery/mecha_part_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE

	return TRUE

/obj/machinery/mecha_part_fabricator/spacepod
	name = "spacepod fabricator"
	fabricator_type = PODFAB
	categories = list("Pod_Weaponry", "Pod_Armor", "Pod_Cargo", "Pod_Parts", "Pod_Frame", "Misc")
	req_access = list(ACCESS_MECHANIC)

/obj/machinery/mecha_part_fabricator/spacepod/New()
	..()
	QDEL_LIST(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/podfab(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()
	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/mecha_part_fabricator/spacepod/interact(mob/user)
	. = ..()

/obj/machinery/mecha_part_fabricator/robot
	name = "Robotic Fabricator"
	categories = list("Cyborg")

/obj/machinery/mecha_part_fabricator/robot/interact(mob/user)
	. = ..()
