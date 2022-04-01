/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	desc = "Изучайте науку, разрушая предметы!"
	icon_state = "d_analyzer"
	icon_open = "d_analyzer_t"
	icon_closed = "d_analyzer"
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_d_analyzer"
		icon_open = "syndie_d_analyzer_t"
		icon_closed = "syndie_d_analyzer"

/obj/machinery/r_n_d/destructive_analyzer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	RefreshParts()
	if(is_taipan(z))
		icon_state = "syndie_d_analyzer"
		icon_open = "syndie_d_analyzer_t"
		icon_closed = "syndie_d_analyzer"

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
	if(default_deconstruction_screwdriver(user, icon_open, icon_closed, O))
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
		to_chat(user, "<span class='warning'>[src.name] сперва требуется подключить к R&D консоли!</span>")
		return
	if(busy)
		to_chat(user, "<span class='warning'>[src.name] сейчас занят.</span>")
		return
	if(istype(O, /obj/item) && !loaded_item)
//Ядра аномалий можно разобрать только при улучшеном автомате. 3x4(femto-manipulator,quad-ultra micro-laser,triphasic scanning module)
		if(istype(O,/obj/item/assembly/signaler/anomaly) && (decon_mod < 12))
			to_chat(user, "<span class='warning'>[src.name] не может обработать такой сложный предмет!</span>")
			return
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>Предмет не имеет технологического происхождения!</span>")
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if(temp_tech.len == 0)
			to_chat(user, "<span class='warning'>Вы не можете разобрать этот предмет!</span>")
			return
		if(!user.drop_item())
			to_chat(user, "<span class='warning'>[O] прилип к вашей руке и вы не можете поместить его в [src.name]!</span>")
			return
		busy = 1
		loaded_item = O
		O.loc = src
		to_chat(user, "<span class='notice'>[O.name] установлен в [src.name]!</span>")
		flick("[icon_state]_la", src)
		spawn(10)
			icon_state = "[icon_state]_l"
			busy = 0
