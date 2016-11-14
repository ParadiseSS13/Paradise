// ----------------------------
//  Drying Rack 'drying_rack'
// ----------------------------
/obj/machinery/drying_rack
	name = "drying rack"
	icon = 'hyntatmta/icons/obj/hydrophonics/drying_rack.dmi'
	icon_state = "drying_rack_on"
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 200
	var/max_n_of_items = 1500
	var/icon_on = "drying_rack_on"
	var/icon_off = "drying_rack"
	var/drying = 0

/*******************
*   Item Adding
********************/

/obj/machinery/drying_rack/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, "drying_rack_open", "drying_rack", O))
		return

	if(default_deconstruction_crowbar(O))
		updateUsrDialog()
		return

	if(contents.len >= max_n_of_items)
		user << "<span class='warning'>\The [src] is full!</span>"
		return 0

	if(accept_check(O))
		load(O)
		user.visible_message("[user] has added \the [O] to \the [src].", "<span class='notice'>You add \the [O] to \the [src].</span>")
		updateUsrDialog()
		return 1

	if(istype(O, /obj/item/weapon/storage/bag))
		var/obj/item/weapon/storage/P = O
		var/loaded = 0
		for(var/obj/G in P.contents)
			if(contents.len >= max_n_of_items)
				break
			if(accept_check(G))
				load(G)
				loaded++
		updateUsrDialog()

		if(loaded)
			if(contents.len >= max_n_of_items)
				user.visible_message("[user] loads \the [src] with \the [O].", \
								 "<span class='notice'>You fill \the [src] with \the [O].</span>")
			else
				user.visible_message("[user] loads \the [src] with \the [O].", \
									 "<span class='notice'>You load \the [src] with \the [O].</span>")
			if(O.contents.len > 0)
				user << "<span class='warning'>Some items are refused.</span>"
			return 1
		else
			user << "<span class='warning'>There is nothing in [O] to put in [src]!</span>"
			return 0

	if(user.a_intent != "harm")
		user << "<span class='warning'>\The [src] smartly refuses [O].</span>"
		updateUsrDialog()
		return 0
	else
		return ..()



/obj/machinery/drying_rack/proc/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/) || istype(O,/obj/item/seeds/) || istype(O,/obj/item/weapon/grown/))
		return 1
	return 0

/obj/machinery/drying_rack/proc/load(obj/item/O)
	if(istype(O.loc,/mob))
		var/mob/M = O.loc
		if(!M.unEquip(O))
			usr << "<span class='warning'>\the [O] is stuck to your hand, you cannot put it in \the [src]!</span>"
			return
	else if(istype(O.loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = O.loc
		S.remove_from_storage(O,src)

	O.loc = src

/obj/machinery/drying_rack/attack_ai(mob/user)
	return 0

/obj/machinery/drying_rack/attack_hand(mob/user)
	user.set_machine(src)
	interact(user)

/obj/machinery/drying_rack/interact(mob/user)
	var/dat = "<TT><b>Select an item:</b><br>"

	if (contents.len == 0)
		dat += "<font color = 'red'>No product loaded!</font>"
	else
		var/listofitems = list()
		for (var/atom/movable/O in contents)
			if (listofitems[O.name])
				listofitems[O.name]++
			else
				listofitems[O.name] = 1
		sortList(listofitems)

		for (var/O in listofitems)
			if(listofitems[O] <= 0)
				continue
			var/N = listofitems[O]
			var/itemName = url_encode(O)
			dat += "<FONT color = 'blue'><B>[capitalize(O)]</B>:"
			dat += " [N] </font>"
			dat += "<a href='byond://?src=\ref[src];vend=[itemName];amount=1'>Vend</A> "
			if(N > 5)
				dat += "(<a href='byond://?src=\ref[src];vend=[itemName];amount=5'>x5</A>)"
				if(N > 10)
					dat += "(<a href='byond://?src=\ref[src];vend=[itemName];amount=10'>x10</A>)"
					if(N > 25)
						dat += "(<a href='byond://?src=\ref[src];vend=[itemName];amount=25'>x25</A>)"
			if(N > 1)
				dat += "(<a href='?src=\ref[src];vend=[itemName];amount=[N]'>All</A>)"

			dat += "<br>"
		dat += "<br>"
		dat += "<a href='byond://?src=\ref[src];dry=1'>Toggle Drying</A> "
		user << browse("<HEAD><TITLE>[src] supplies</TITLE></HEAD><TT>[dat]</TT>", "window=drying_rack")
	return

/obj/machinery/drying_rack/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)

	var/N = href_list["vend"]
	var/amount = text2num(href_list["amount"])

	var/i = amount
	for(var/obj/O in contents)
		if(i <= 0)
			break
		if(O.name == N)
			O.loc = src.loc
			i--
	if(href_list["dry"])
		toggle_drying()
	updateUsrDialog()

/obj/machinery/drying_rack/load() //For updating the filled overlay
	..()
	update_icon()

/obj/machinery/drying_rack/update_icon()
	if(!stat)
		icon_state = icon_on
	else
		icon_state = icon_off
	overlays = 0
	if(drying)
		overlays += image(icon_state="drying_rack_drying")
	if(contents.len)
		overlays += image(icon_state="drying_rack_filled")

/obj/machinery/drying_rack/process()
	..()
	if(drying)
		if(rack_dry())//no need to update unless something got dried
			update_icon()

/obj/machinery/drying_rack/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/))
		var/obj/item/weapon/reagent_containers/food/snacks/S = O
		if(S.dried_type)
			return 1
	return 0

/obj/machinery/drying_rack/proc/toggle_drying(forceoff = 0)
	if(drying || forceoff)
		drying = 0
	else
		drying = 1
	update_icon()

/obj/machinery/drying_rack/proc/rack_dry()
	for(var/obj/item/weapon/reagent_containers/food/snacks/S in contents)
		if(S.dried_type == S.type)//if the dried type is the same as the object's type, don't bother creating a whole new item...
			S.color = "#ad7257"
			S.dry = 1
			S.loc = get_turf(src)
		else
			var/dried = S.dried_type
			new dried(src.loc)
			qdel(S)
		return 1
	return 0

/obj/machinery/drying_rack/emp_act(severity)
	..()
	atmos_spawn_air(SPAWN_HEAT, 1000)
