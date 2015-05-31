#define AUTOLATHE_MAIN_MENU       1
#define AUTOLATHE_CATEGORY_MENU   2
#define AUTOLATHE_SEARCH_MENU     3

/obj/machinery/autolathe
	name = "autolathe"
	desc = "It produces items using metal and glass."
	icon_state = "autolathe"
	density = 1

	var/m_amount = 0.0
	var/max_m_amount = 150000.0

	var/g_amount = 0.0
	var/max_g_amount = 75000.0

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

	var/list/categories = list(
							"Communication",
							"Construction",
							"Electronics",
							"Medical",
							"Miscellaneous",
							"Security",
							"Tools"
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
	if (busy)
		user << "<span class=\"alert\">The autolathe is busy. Please wait for completion of previous operation.</span>"
		return 1

	if(default_deconstruction_screwdriver(user, "autolathe_t", "autolathe", O))
		updateUsrDialog()
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(istype(O, /obj/item/weapon/crowbar))
			if(m_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(m_amount / MINERAL_MATERIAL_AMOUNT)
			if(g_amount >= MINERAL_MATERIAL_AMOUNT)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(g_amount / MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(O)
			return 1
		else
			attack_hand(user)
			return 1
	if (stat)
		return 1

	if (src.m_amount + O.m_amt > max_m_amount)
		user << "<span class=\"alert\">The autolathe is full. Please remove metal from the autolathe in order to insert more.</span>"
		return 1
	if (src.g_amount + O.g_amt > max_g_amount)
		user << "<span class=\"alert\">The autolathe is full. Please remove glass from the autolathe in order to insert more.</span>"
		return 1
	if (O.m_amt == 0 && O.g_amt == 0)
		user << "<span class=\"alert\">This object does not contain significant amounts of metal or glass, or cannot be accepted by the autolathe due to size or hazardous materials.</span>"
		return 1

	var/amount = 1
	var/obj/item/stack/stack
	var/m_amt = O.m_amt
	var/g_amt = O.g_amt
	if (istype(O, /obj/item/stack))
		stack = O
		amount = stack.amount
		if (m_amt)
			amount = min(amount, round((max_m_amount-src.m_amount)/m_amt))
			flick("autolathe_o",src)//plays metal insertion animation
		if (g_amt)
			amount = min(amount, round((max_g_amount-src.g_amount)/g_amt))
			flick("autolathe_r",src)//plays glass insertion animation
		stack.use(amount)
	else
		if(!user.unEquip(O))
			user << "<span class='notice'>/the [O] is stuck to your hand, you can't put it in \the [src]!</span>"
		O.loc = src
	icon_state = "autolathe"
	busy = 1
	use_power(max(1000, (m_amt+g_amt)*amount/10))
	src.m_amount += m_amt * amount
	src.g_amount += g_amt * amount
	user << "You insert [amount] sheet[amount>1 ? "s" : ""] to the autolathe."
	if (O && O.loc == src)
		qdel(O)
	busy = 0
	src.updateUsrDialog()

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
		BuildTurf = get_step(src.loc, get_dir(src,usr))

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
		var/max_multiplier = min(50, design_last_ordered.materials["$metal"] ?round(m_amount/design_last_ordered.materials["$metal"]):INFINITY,design_last_ordered.materials["$glass"]?round(g_amount/design_last_ordered.materials["$glass"]):INFINITY)
		var/is_stack = ispath(design_last_ordered.build_path, /obj/item/stack)

		if(!is_stack && (multiplier > 1))
			return
		if (!(multiplier in list(1,10,25,max_multiplier))) //"enough materials ?" is checked in the build proc
			return
		/////////////////

		if((queue.len+1)<queue_max_len)
			add_to_queue(design_last_ordered,multiplier)
		else
			usr << "\red The autolathe queue is full!"
		if (!busy)
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

		for(var/datum/design/D in files.known_designs)
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
	max_m_amount = tot_rating * 2
	max_g_amount = tot_rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		prod_coeff += M.rating - 1

/obj/machinery/autolathe/proc/get_coeff(var/datum/design/D)
	var/coeff = (ispath(D.build_path,/obj/item/stack) ? 1 : 2 ** prod_coeff)//stacks are unaffected by production coefficient
	return coeff

/obj/machinery/autolathe/proc/build_item(var/datum/design/D, var/multiplier)
	desc = initial(desc)+"\nIt's building \a [initial(D.name)]."
	var/is_stack = ispath(D.build_path, /obj/item/stack)
	var/coeff = get_coeff(D)
	var/metal_cost = D.materials["$metal"]
	var/glass_cost = D.materials["$glass"]
	var/power = max(2000, (metal_cost+glass_cost)*multiplier/5)
	if (can_build(D,multiplier))
		being_built = list(D,multiplier)
		use_power(power)
		icon_state = "autolathe"
		flick("autolathe_n",src)
		if(is_stack)
			m_amount -= metal_cost*multiplier
			g_amount -= glass_cost*multiplier
		else
			m_amount -= metal_cost/coeff
			g_amount -= glass_cost/coeff
		updateUsrDialog()
		sleep(32/coeff)
		if(is_stack)
			var/obj/item/stack/S = new D.build_path(BuildTurf)
			S.amount = multiplier
		else
			var/obj/item/new_item = new D.build_path(BuildTurf)
			new_item.m_amt /= coeff
			new_item.g_amt /= coeff
		if(m_amount < 0)
			m_amount = 0
		if(g_amount < 0)
			g_amount = 0
	updateUsrDialog()
	desc = initial(desc)

/obj/machinery/autolathe/proc/can_build(var/datum/design/D,var/multiplier=1,var/custom_metal,var/custom_glass)
	var/coeff = get_coeff(D)

	var/metal_amount = m_amount
	if(custom_metal)
		metal_amount = custom_metal
	var/glass_amount = g_amount
	if(custom_glass)
		glass_amount = custom_glass

	if(D.materials["$metal"] && (metal_amount < (multiplier*D.materials["$metal"] / coeff)))
		return 0
	if(D.materials["$glass"] && (glass_amount < (multiplier*D.materials["$glass"] / coeff)))
		return 0
	return 1

/obj/machinery/autolathe/proc/get_design_cost_as_list(var/datum/design/D,var/multiplier=1)
	var/list/OutputList = list(0,0)
	var/coeff = get_coeff(D)
	if(D.materials["$metal"])
		OutputList[1] = (D.materials["$metal"] / coeff)*multiplier
	if(D.materials["$glass"])
		OutputList[2] = (D.materials["$glass"] / coeff)*multiplier
	return OutputList

/obj/machinery/autolathe/proc/get_processing_line()
	var/datum/design/D = being_built[1]
	var/multiplier = being_built[2]
	var/is_stack = (multiplier>1)
	var/output = "PROCESSING: [initial(D.name)][is_stack?" (x[multiplier])":null]"
	return output

/obj/machinery/autolathe/proc/get_queue()
	var/temp_metal = m_amount
	var/temp_glass = g_amount
	var/output = "<td valign='top' style='width: 300px'>"
	output += "<div class='statusDisplay'>"
	output += "<b>Queue contains:</b>"
	if (!istype(queue) || !queue.len)
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
			output += "<li[!can_build(D,multiplier,temp_metal,temp_glass)?" style='color: #f00;'":null]>[initial(D.name)][is_stack?" (x[multiplier])":null] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"
			temp_metal = max(temp_metal-LL[1],1)
			temp_glass = max(temp_glass-LL[2],1)

		output += "</ol>"
		output += "<a href='?src=\ref[src];clear_queue=1'>Clear queue</a>"
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
			visible_message("\icon[src] <b>\The [src]</b> beeps, \"Not enough resources. Queue processing terminated.\"")
			queue = list()
			being_built = new /list()
			return 0

		remove_from_queue(1)
		build_item(D,multiplier)
		D = listgetindex(listgetindex(queue, 1),1)
		multiplier = listgetindex(listgetindex(queue,1),2)
	being_built = new /list()
	//visible_message("\icon[src] <b>\The [src]</b> beeps, \"Queue processing finished successfully.\"")

/obj/machinery/autolathe/proc/main_win(mob/user)
	var/dat = "<table style='width:100%'><tr>"
	dat += "<td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'><h3>Autolathe Menu:</h3><br>"
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup>"

	dat += "<form name='search' action='?src=\ref[src]'> \
	<input type='hidden' name='src' value='\ref[src]'> \
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

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[AUTOLATHE_CATEGORY_MENU]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/category_win(mob/user,var/selected_category)
	var/dat = "<table style='width:100%'><tr><td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'>"
	dat += "<A href='?src=\ref[src];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<h3>Browsing [selected_category]:</h3><br>"
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup><hr>"

	for(var/datum/design/D in files.known_designs)
		if(!(selected_category in D.category))
			continue

		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(50, D.materials["$metal"] ?round(m_amount/D.materials["$metal"]):INFINITY,D.materials["$glass"]?round(g_amount/D.materials["$glass"]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/search_win(mob/user)
	var/dat = "<table style='width:100%'><tr><td valign='top' style='margin-right: 300px'>"
	dat += "<div class='statusDisplay'>"
	dat += "<A href='?src=\ref[src];menu=[AUTOLATHE_MAIN_MENU]'>Return to main menu</A>"
	dat += "<h3>Search results:</h3><br>"
	dat += "<b>Metal amount:</b> [src.m_amount] / [max_m_amount] cm<sup>3</sup><br>"
	dat += "<b>Glass amount:</b> [src.g_amount] / [max_g_amount] cm<sup>3</sup><hr>"

	for(var/datum/design/D in matching_designs)
		if(disabled || !can_build(D))
			dat += "<span class='linkOff'>[D.name]</span>"
		else
			dat += "<a href='?src=\ref[src];make=[D.id];multiplier=1'>[D.name]</a>"

		if(ispath(D.build_path, /obj/item/stack))
			var/max_multiplier = min(50, D.materials["$metal"] ?round(m_amount/D.materials["$metal"]):INFINITY,D.materials["$glass"]?round(g_amount/D.materials["$glass"]):INFINITY)
			if (max_multiplier>10 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=10'>x10</a>"
			if (max_multiplier>25 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=25'>x25</a>"
			if(max_multiplier > 0 && !disabled)
				dat += " <a href='?src=\ref[src];make=[D.id];multiplier=[max_multiplier]'>x[max_multiplier]</a>"

		dat += "[get_design_cost(D)]<br>"

	dat += "</div>"
	dat += "</td>"
	dat += get_queue()
	dat += "</tr></table>"
	return dat

/obj/machinery/autolathe/proc/get_design_cost(var/datum/design/D)
	var/coeff = get_coeff(D)
	var/dat
	if(D.materials["$metal"])
		dat += "[D.materials["$metal"] / coeff] metal "
	if(D.materials["$glass"])
		dat += "[D.materials["$glass"] / coeff] glass"
	return dat

/obj/machinery/autolathe/proc/shock(mob/user, prb)
	if(stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if (electrocute_mob(user, get_area(src), src, 0.7))
		return 1
	else
		return 0

/obj/machinery/autolathe/proc/adjust_hacked(var/hack)
	hacked = hack

	if(hack)
		for(var/datum/design/D in files.possible_designs)
			if((D.build_type & AUTOLATHE) && ("hacked" in D.category))
				files.known_designs += D
	else
		for(var/datum/design/D in files.known_designs)
			if("hacked" in D.category)
				files.known_designs -= D
