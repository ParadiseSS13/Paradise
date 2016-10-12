#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

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
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/busy = 0
	var/prod_coeff
	var/datum/wires/autolathe/wires = null

	var/list/being_built = list()
	var/datum/research/files
	var/list/datum/design/matching_designs
	var/selected_category
	var/screen = 1

	var/datum/material_container/materials

	var/list/categories = list(
							"Communication",
							"Construction",
							"Electronics",
							"Medical",
							"Miscellaneous",
							"Security",
							"Tools",
							"Imported"
							)

/obj/machinery/autolathe/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	materials = new /datum/material_container(src, list(MAT_METAL=1, MAT_GLASS=1))
	RefreshParts()

	wires = new(src)
	files = new /datum/research/autolathe(src)
	matching_designs = list()

/obj/machinery/autolathe/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/autolathe(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/autolathe/Destroy()
	qdel(wires)
	wires = null
	qdel(materials)
	materials = null
	return ..()

/obj/machinery/autolathe/interact(mob/user)
	if(shocked && !(stat & NOPOWER))
		shock(user,50)

	user.set_machine(src)
	var/dat

	if(panel_open)
		dat = wires.GetInteractWindow()

	else
		switch(screen)
			if(AUTOLATHE_MAIN_MENU)
				dat = main_win(user)
			if(AUTOLATHE_CATEGORY_MENU)
				dat = category_win(user,selected_category)
			if(AUTOLATHE_SEARCH_MENU)
				dat = search_win(user)

	var/datum/browser/popup = new(user, "autolathe", name, 800, 500)
	popup.set_content(dat)
	popup.open()

	return

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if(panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			materials.retrieve_all()
			default_deconstruction_crowbar(O)
			return 1
		else
			attack_hand(user)
			return 1
	if(stat)
		return 1

	// Disks in general
	if(istype(O, /obj/item/weapon/disk))
		if(istype(O, /obj/item/weapon/disk/design_disk))
			var/obj/item/weapon/disk/design_disk/D = O
			if(D.blueprint)
				user.visible_message("[user] begins to load \the [O] in \the [src]...",
					"You begin to load a design from \the [O]...",
					"You hear the chatter of a floppy drive.")
				playsound(get_turf(src), "sound/goonstation/machines/printer_dotmatrix.ogg", 50, 1)
				busy = 1
				if(do_after(user, 14.4, target = src))
					files.AddDesign2Known(D.blueprint)
				busy = 0
			else
				to_chat(user, "<span class='warning'>That disk does not have a design on it!</span>")
			return 1
		else
			// So that people who are bad at computers don't shred their disks
			to_chat(user, "<span class='warning'>This is not the correct type of disk for the autolathe!</span>")
			return 1

	var/material_amount = materials.get_item_material_amount(O)
	if(!material_amount)
		to_chat(user, "<span class='warning'>This object does not contain sufficient amounts of metal or glass to be accepted by the autolathe.</span>")
		return 1
	if(!materials.has_space(material_amount))
		to_chat(user, "<span class='warning'>The autolathe is full. Please remove metal or glass from the autolathe in order to insert more.</span>")
		return 1
	if(!user.unEquip(O))
		to_chat(user, "<span class='warning'>\The [O] is stuck to you and cannot be placed into the autolathe.</span>")
		return 1

	busy = 1
	var/inserted = materials.insert_item(O)
	if(inserted)
		if(istype(O,/obj/item/stack))
			if(O.materials[MAT_METAL])
				flick("autolathe_o",src)//plays metal insertion animation
			if(O.materials[MAT_GLASS])
				flick("autolathe_r",src)//plays glass insertion animation
			to_chat(user, "<span class='notice'>You insert [inserted] sheet[inserted>1 ? "s" : ""] to the autolathe.</span>")
			use_power(inserted*100)
		else
			to_chat(user, "<span class='notice'>You insert a material total of [inserted] to the autolathe.</span>")
			use_power(max(500,inserted/10))
			qdel(O)
	busy = 0
	src.updateUsrDialog()

/obj/machinery/autolathe/attack_ghost(mob/user)
	interact(user)

/obj/machinery/autolathe/attack_hand(mob/user)
	if(..(user, 0))
		return
	interact(user)

/obj/machinery/autolathe/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["menu"])
		screen = text2num(href_list["menu"])

	if(href_list["category"])
		selected_category = href_list["category"]

	if(href_list["make"])
		BuildTurf = loc

		/////////////////
		//href protection
		var/datum/design/design_last_ordered
		design_last_ordered = files.FindDesignByID(href_list["make"]) //check if it's a valid design
		if(!design_last_ordered)
			return
		if(!(design_last_ordered.build_type & AUTOLATHE))
			return

		//multiplier checks : only stacks can have one and its value is 1, 10 ,25 or max_multiplier
		var/multiplier = text2num(href_list["multiplier"])
		var/max_multiplier = min(design_last_ordered.maxstack, design_last_ordered.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/design_last_ordered.materials[MAT_METAL]):INFINITY,design_last_ordered.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/design_last_ordered.materials[MAT_GLASS]):INFINITY)
		var/is_stack = ispath(design_last_ordered.build_path, /obj/item/stack)

		if(!is_stack && (multiplier > 1))
			return
		if(!(multiplier in list(1,10,25,max_multiplier))) //"enough materials ?" is checked in the build proc
			return
		/////////////////

		if((queue.len+1)<queue_max_len)
			add_to_queue(design_last_ordered,multiplier)
		else
			to_chat(usr, "\red The autolathe queue is full!")
		if(!busy)
			busy = 1
			process_queue()
			busy = 0

	if(href_list["remove_from_queue"])
		var/index = text2num(href_list["remove_from_queue"])
		if(isnum(index) && IsInRange(index,1,queue.len))
			remove_from_queue(index)
	if(href_list["queue_move"] && href_list["index"])
		var/index = text2num(href_list["index"])
		var/new_index = index + text2num(href_list["queue_move"])
		if(isnum(index) && isnum(new_index))
			if(IsInRange(new_index,1,queue.len))
				queue.Swap(index,new_index)
	if(href_list["clear_queue"])
		queue = list()
	if(href_list["search"])
		matching_designs.Cut()

		for(var/v in files.known_designs)
			var/datum/design/D = files.known_designs[v]
			if(findtext(D.name,href_list["to_search"]))
				matching_designs.Add(D)


	src.updateUsrDialog()

	return

/obj/machinery/autolathe/RefreshParts()
	var/tot_rating = 0
	prod_coeff = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/MB in component_parts)
		tot_rating += MB.rating
	tot_rating *= 25000
	materials.max_amount = tot_rating * 3
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/proc/get_coeff(var/datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)//stacks are unaffected by production coefficient
	return coeff

/obj/machinery/autolathe/proc/build_item(var/datum/design/D, var/multiplier)
	desc = initial(desc)+"\nIt's building \a [initial(D.name)]."
	var/is_stack = ispath(D.build_path, /obj/item/stack)
	var/coeff = get_coeff(D)
	var/metal_cost = D.materials[MAT_METAL]
	var/glass_cost = D.materials[MAT_GLASS]
	var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)
	if(can_build(D,multiplier))
		being_built = list(D,multiplier)
		use_power(power)
		icon_state = "autolathe"
		flick("autolathe_n",src)
		if(is_stack)
			var/list/materials_used = list(MAT_METAL=metal_cost*multiplier, MAT_GLASS=glass_cost*multiplier)
			materials.use_amount(materials_used)
		else
			var/list/materials_used = list(MAT_METAL=metal_cost/coeff, MAT_GLASS=glass_cost/coeff)
			materials.use_amount(materials_used)
		updateUsrDialog()
		sleep(32/coeff)
		if(is_stack)
			var/obj/item/stack/S = new D.build_path(BuildTurf)
			S.amount = multiplier
		else
			var/obj/item/new_item = new D.build_path(BuildTurf)
			new_item.materials[MAT_METAL] /= coeff
			new_item.materials[MAT_GLASS] /= coeff
	updateUsrDialog()
	desc = initial(desc)

/obj/machinery/autolathe/proc/can_build(var/datum/design/D,var/multiplier=1,var/custom_metal,var/custom_glass)
	var/coeff = get_coeff(D)

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

/obj/machinery/autolathe/proc/get_design_cost_as_list(var/datum/design/D,var/multiplier=1)
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

/obj/machinery/autolathe/proc/get_queue()
	var/temp_metal = materials.amount(MAT_METAL)
	var/temp_glass = materials.amount(MAT_GLASS)
	var/output = "<td valign='top' style='width: 300px'>"
	output += "<div class='statusDisplay'>"
	output += "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		if(being_built.len)
			output += "<ol><li>"
			output += get_processing_line()
			output += "</li></ol>"
		else
			output += "<br>Nothing"
	else
		output += "<ol>"
		if(being_built.len)
			output += "<li>"
			output += get_processing_line()
			output += "</li>"
		var/i = 0
		var/datum/design/D
		for(var/list/L in queue)
			i++
			D = L[1]
			var/multiplier = L[2]
			var/list/LL = get_design_cost_as_list(D,multiplier)
			var/is_stack = (multiplier>1)
			output += "<li[!can_build(D,multiplier,temp_metal,temp_glass)?" style='color: #f00;'":null]>[initial(D.name)][is_stack?" (x[multiplier])":null] - [i>1?"<a href='?src=[UID()];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=[UID()];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=[UID()];remove_from_queue=[i]'>Remove</a></li>"
			temp_metal = max(temp_metal-LL[1],1)
			temp_glass = max(temp_glass-LL[2],1)

		output += "</ol>"
		output += "<a href='?src=[UID()];clear_queue=1'>Clear queue</a>"
	output += "</div></td>"
	return output

/obj/machinery/autolathe/proc/add_to_queue(D,var/multiplier)
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
		if(stat&(NOPOWER|BROKEN))
			being_built = new /list()
			return 0
		if(!can_build(D,multiplier))
			visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Not enough resources. Queue processing terminated.\"")
			queue = list()
			being_built = new /list()
			return 0

		remove_from_queue(1)
		build_item(D,multiplier)
		D = listgetindex(listgetindex(queue, 1),1)
		multiplier = listgetindex(listgetindex(queue,1),2)
	being_built = new /list()
	//visible_message("[bicon(src)] <b>\The [src]</b> beeps, \"Queue processing finished successfully.\"")

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<table style='width:100%'><tr>"
	dat += "<td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	dat += "<form name='search' action='?src=[UID()]'> \
	<input type='hidden' name='src' value='[UID()]'> \
	<input type='hidden' name='search' value='to_search'> \
	<input type='hidden' name='menu' value='[AUTOLATHE_SEARCH_MENU]'> \
	<input type='text' name='to_search'> \
	<input type='submit' value='Search'> \
	</form><hr>"

	var/line_length = 1
	dat += "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=[UID()];category=[C];menu=[AUTOLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/category_win(mob/user,var/selected_category)
	var/dat = "<table style='width:100%'><tr><td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'>"
	dat += "<A href='?src=[UID()];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<h3>Browsing [selected_category]:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	for(var/v in files.known_designs)
		var/datum/design/D = files.known_designs[v]
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=[UID()];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY)
			if(max_multiplier>10 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=10'>x10</a>"
			if(max_multiplier>25 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/search_win(mob/user)
	var/dat = "<table style='width:100%'><tr><td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'>"
	dat += "<A href='?src=[UID()];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<h3>Search results:</h3><br>"
	dat += "<b>Total amount:</b> [materials.total_amount] / [materials.max_amount] cm<sup>3</sup><br>"
	dat += "<b>Metal amount:</b> [materials.amount(MAT_METAL)] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [materials.amount(MAT_GLASS)] cm<sup>3</sup><br>"

	for(var/datum/design/D in matching_designs)
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=[UID()];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(D.maxstack, D.materials[MAT_METAL] ?round(materials.amount(MAT_METAL)/D.materials[MAT_METAL]):INFINITY,D.materials[MAT_GLASS]?round(materials.amount(MAT_GLASS)/D.materials[MAT_GLASS]):INFINITY)
			if(max_multiplier>10 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=10'>x10</a>"
			if(max_multiplier>25 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=[UID()];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/get_design_cost(var/datum/design/D)
	var/coeff = get_coeff(D)
	var/dat
	if(D.materials[MAT_METAL])
		dat += "[D.materials[MAT_METAL] / coeff] metal "
	if(D.materials[MAT_GLASS])
		dat += "[D.materials[MAT_GLASS] / coeff] glass"
	return dat

/obj/machinery/autolathe/proc/adjust_hacked(var/hack)
	hacked = hack

	if(hack)
		for(var/datum/design/D in files.possible_designs)
			if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
				files.AddDesign2Known(D)
	else
		for(var/datum/design/D in files.known_designs)
			if("hacked" in D.category)
				files.known_designs -= D.id
