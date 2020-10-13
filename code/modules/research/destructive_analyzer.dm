/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Learn science by destroying things!"
	icon_state = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(shocked)
		if(shock(user,50))
			return TRUE
	if(default_deconstruction_screwdriver(user, "d_analyzer_t", "d_analyzer", O))
		if(linked_console)
			linked_console.linked_destroy = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(disabled)
		return
	if(!linked_console)
		to_chat(user, "<span class='warning'>The [src.name] must be linked to an R&D console first!</span>")
		return
	if(busy)
		to_chat(user, "<span class='warning'>The [src.name] is busy right now.</span>")
		return
	if(istype(O, /obj/item) && !loaded_item)
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>\The [O] is stuck to your hand, you cannot put it in the [src.name]!</span>")
			return
		busy = 1
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>You add the [O.name] to the [src.name]!</span>")
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0

/obj/machinery/r_n_d/destructive_analyzer/proc/user_try_decon_id(id, mob/user)
	if(!istype(loaded_item) || !istype(linked_console))
		return FALSE
	if(id)
		var/datum/techweb_node/TN = SSresearch.get_techweb_node_by_id(id)
		if(!istype(TN))
			return FALSE
		var/list/pos1 = techweb_item_boost_check(loaded_item)
		if(isnull(pos1[id]))
			return FALSE
		var/dpath = loaded_item.type
		if(isnull(TN.boost_item_paths[dpath]))
			return FALSE
		var/dboost = TN.boost_item_paths[dpath]
		var/choice = input("Are you sure you want to destroy [loaded_item.name] for a boost of [dboost? 0 : dboost] in node [TN.display_name]") in list("Proceed", "Cancel")
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
			return FALSE
		linked_console.stored_research.boost_with_path(SSresearch.get_techweb_node_by_id(TN.id), dpath)
	else
		var/point_value = techweb_item_point_check(loaded_item)
		if(linked_console.stored_research.deconstructed_items[loaded_item.type])
			point_value = 0
		var/choice = input("Are you sure you want to destroy [loaded_item.name] for [point_value] points?") in list("Proceed", "Cancel")
		if(choice == "Cancel")
			return FALSE
		if(QDELETED(loaded_item) || QDELETED(linked_console) || !user.Adjacent(linked_console) || QDELETED(src))
			return FALSE
		var/dtype = loaded_item.type
		linked_console.stored_research.research_points += point_value
		linked_console.stored_research.deconstructed_items[dtype] = point_value
	return TRUE
