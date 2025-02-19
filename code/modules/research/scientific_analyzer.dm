/*
Scientific Analyzer

It is used to analyze hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/scientific_analyzer
	name = "Scientific Analyzer"
	desc = "Learn science by analyzing things!"
	icon_state = "s_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/scientific_analyzer/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/scientific_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/r_n_d/scientific_analyzer/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/scientific_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	RefreshParts()

/obj/machinery/r_n_d/scientific_analyzer/Destroy()
	if(linked_console)
		linked_console.linked_analyzer = null
	return ..()

/obj/machinery/r_n_d/scientific_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T


/obj/machinery/r_n_d/scientific_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/scientific_analyzer/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/storage/part_replacer) || istype(used, /obj/item/gripper))
		return ..()

	if(default_deconstruction_screwdriver(user, "s_analyzer_t", "s_analyzer", used))
		if(linked_console)
			linked_console.linked_analyzer = null
			linked_console = null
		return ITEM_INTERACT_COMPLETE

	// TODO: Almost positive this doesn't need to do the same exchange parts shit as /obj/machinery
	if(exchange_parts(user, used))
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_crowbar(user, used))
		return ITEM_INTERACT_COMPLETE

	if(!linked_console)
		to_chat(user, "<span class='warning'>[src] must be linked to an R&D console first!</span>")
		return ITEM_INTERACT_COMPLETE

	if(busy)
		to_chat(user, "<span class='warning'>[src] is busy right now.</span>")
		return ITEM_INTERACT_COMPLETE

	if(isitem(used) && !loaded_item)
		if(!used.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return ITEM_INTERACT_COMPLETE

		var/list/temp_tech = ConvertReqString2List(used.origin_tech)
		if(length(temp_tech) == 0)
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return ITEM_INTERACT_COMPLETE

		if(!user.transfer_item_to(used, src))
			to_chat(user, "<span class='warning'>[used] is stuck to your hand, you cannot put it in [src]!</span>")
			return ITEM_INTERACT_COMPLETE

		busy = TRUE
		loaded_item = used
		to_chat(user, "<span class='notice'>You add [used] to [src]!</span>")
		SStgui.update_uis(linked_console)
		flick("s_analyzer_la", src)
		spawn(10)
			icon_state = "s_analyzer_l"
			busy = FALSE

		return ITEM_INTERACT_COMPLETE
