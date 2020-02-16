/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/vending.dmi'
	icon_state = "smartfridge"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	var/max_n_of_items = 1500
	var/item_quants = list()
	var/seconds_electrified = 0
	var/shoot_inventory = FALSE
	var/locked = FALSE
	var/scan_id = TRUE
	var/is_secure = FALSE
	var/can_dry = FALSE
	var/drying = FALSE
	var/visible_contents = TRUE
	var/datum/wires/smartfridge/wires = null

/obj/machinery/smartfridge/New()
	..()
	create_reagents()
	reagents.set_reacting(FALSE)
	component_parts = list()
	var/obj/item/circuitboard/smartfridge/board = new(null)
	board.set_type(type)
	component_parts += board
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/smartfridge/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_n_of_items = 1500 * B.rating

/obj/machinery/smartfridge/secure
	is_secure = 1

/obj/machinery/smartfridge/New()
	..()
	if(is_secure)
		wires = new/datum/wires/smartfridge/secure(src)
	else
		wires = new/datum/wires/smartfridge(src)

/obj/machinery/smartfridge/Destroy()
	QDEL_NULL(wires)
	for(var/atom/movable/A in contents)
		A.forceMove(loc)
	return ..()

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(istype(O,/obj/item/reagent_containers/food/snacks/grown/) || istype(O,/obj/item/seeds/) || istype(O,/obj/item/grown/))
		return 1
	return 0

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/vending.dmi'
	icon_state = "seeds"

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.

/obj/machinery/smartfridge/medbay/accept_check(obj/item/O)
	if(istype(O,/obj/item/reagent_containers/glass))
		return 1
	if(istype(O,/obj/item/reagent_containers/iv_bag))
		return 1
	if(istype(O,/obj/item/storage/pill_bottle))
		return 1
	if(ispill(O))
		return 1
	return 0

/obj/machinery/smartfridge/secure/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts"
	req_access_txt = "47"

/obj/machinery/smartfridge/secure/extract/accept_check(obj/item/O)
	if(istype(O,/obj/item/slime_extract))
		return 1
	return 0

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Secure Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	req_one_access_txt = "5;33"

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O)
	if(istype(O,/obj/item/reagent_containers/glass))
		return 1
	if(istype(O,/obj/item/reagent_containers/iv_bag))
		return 1
	if(istype(O,/obj/item/storage/pill_bottle))
		return 1
	if(ispill(O))
		return 1
	return 0

/obj/machinery/smartfridge/secure/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	req_access_txt = "33"
	var/list/spawn_meds = list()

/obj/machinery/smartfridge/secure/chemistry/New()
	..()
	for(var/typekey in spawn_meds)
		var/amount = spawn_meds[typekey]
		if(isnull(amount)) amount = 1
		while(amount)
			var/obj/item/I = new typekey(src)
			if(item_quants[I.name])
				item_quants[I.name]++
			else
				item_quants[I.name] = 1
			SSnanoui.update_uis(src)
			amount--
	update_icon()

/obj/machinery/smartfridge/secure/chemistry/accept_check(obj/item/O)
	if(istype(O,/obj/item/storage/pill_bottle) || istype(O,/obj/item/reagent_containers))
		return 1
	return 0

/obj/machinery/smartfridge/secure/chemistry/preloaded
	spawn_meds = list(
		/obj/item/reagent_containers/food/pill/epinephrine = 12,
		/obj/item/reagent_containers/food/pill/charcoal = 5,
		/obj/item/reagent_containers/glass/bottle/epinephrine = 1,
		/obj/item/reagent_containers/glass/bottle/charcoal = 1)

/obj/machinery/smartfridge/secure/chemistry/preloaded/syndicate
	req_access_txt = null
	req_access = list(access_syndicate)

/obj/machinery/smartfridge/disks
	name = "disk compartmentalizer"
	desc = "A machine capable of storing a variety of disks. Denoted by most as the DSU (disk storage unit)."
	icon_state = "disktoaster"
	pass_flags = PASSTABLE
	visible_contents = FALSE

/obj/machinery/smartfridge/disks/accept_check(obj/item/O)
	return istype(O, /obj/item/disk)

// ----------------------------
// Virology Medical Smartfridge
// ----------------------------
/obj/machinery/smartfridge/secure/chemistry/virology
	name = "Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."
	req_access_txt = "39"
	spawn_meds = list(/obj/item/reagent_containers/syringe/antiviral = 4,
					  /obj/item/reagent_containers/glass/bottle/cold = 1,
					  /obj/item/reagent_containers/glass/bottle/flu_virion = 1,
					  /obj/item/reagent_containers/glass/bottle/mutagen = 1,
					  /obj/item/reagent_containers/glass/bottle/plasma = 1,
					  /obj/item/reagent_containers/glass/bottle/diphenhydramine = 1)

/obj/machinery/smartfridge/secure/chemistry/virology/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/syringe) || istype(O, /obj/item/reagent_containers/glass/bottle) || istype(O, /obj/item/reagent_containers/glass/beaker))
		return 1
	return 0

/obj/machinery/smartfridge/secure/chemistry/virology/preloaded
	spawn_meds = list(
		/obj/item/reagent_containers/syringe/antiviral = 4,
		/obj/item/reagent_containers/glass/bottle/cold = 1,
		/obj/item/reagent_containers/glass/bottle/flu_virion = 1,
		/obj/item/reagent_containers/glass/bottle/mutagen = 1,
		/obj/item/reagent_containers/glass/bottle/plasma = 1,
		/obj/item/reagent_containers/glass/bottle/reagent/synaptizine = 1,
		/obj/item/reagent_containers/glass/bottle/reagent/formaldehyde = 1)

/obj/machinery/smartfridge/secure/chemistry/virology/preloaded/syndicate
	req_access_txt = null
	req_access = list(access_syndicate)

/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O)
	if(istype(O,/obj/item/reagent_containers/glass) || istype(O,/obj/item/reagent_containers/food/drinks) || istype(O,/obj/item/reagent_containers/food/condiment))
		return 1

/obj/machinery/smartfridge/process()
	if(stat & (BROKEN|NOPOWER))
		return
	if(seconds_electrified > 0)
		seconds_electrified--
	if(shoot_inventory && prob(2))
		throw_item()

/obj/machinery/smartfridge/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/smartfridge/update_icon()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "[initial(icon_state)]-off"
	else if(visible_contents)
		switch(contents.len)
			if(0)
				icon_state = "[initial(icon_state)]"
			if(1 to 25)
				icon_state = "[initial(icon_state)]1"
			if(26 to 75)
				icon_state = "[initial(icon_state)]2"
			if(76 to INFINITY)
				icon_state = "[initial(icon_state)]3"
	else
		icon_state = "[initial(icon_state)]"

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/default_deconstruction_screwdriver(mob/user, obj/item/screwdriver/S)
	. = ..(user, icon_state, icon_state, S)

	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

/obj/machinery/smartfridge/attackby(obj/item/O, var/mob/user)
	if(default_deconstruction_screwdriver(user, O))
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if(istype(O, /obj/item/multitool)||istype(O, /obj/item/wirecutters))
		if(panel_open)
			attack_hand(user)
		return

	if(stat & NOPOWER)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(load(O, user))
		user.visible_message("<span class='notice'>[user] has added \the [O] to \the [src].</span>", "<span class='notice'>You add \the [O] to \the [src].</span>")
		SSnanoui.update_uis(src)
		update_icon()

	else if(istype(O, /obj/item/storage/bag))
		var/obj/item/storage/bag/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(load(G, user))
				plants_loaded++
		if(plants_loaded)
			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [P].</span>", "<span class='notice'>You load \the [src] with \the [P].</span>")
			if(P.contents.len > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

		SSnanoui.update_uis(src)
		update_icon()

	else if(!istype(O, /obj/item/card/emag))
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [O].</span>")
		return 1

/obj/machinery/smartfridge/proc/load(obj/I, mob/user)
	if(accept_check(I))
		if(contents.len >= max_n_of_items)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return 0
		else
			if(istype(I.loc, /obj/item/storage))
				var/obj/item/storage/S = I.loc
				S.remove_from_storage(I, src)
			else if(istype(I.loc, /mob))
				var/mob/M = I.loc
				if(M.get_active_hand() == I)
					if(!M.drop_item())
						to_chat(user, "<span class='warning'>\The [I] is stuck to you!</span>")
						return 0
				else
					M.unEquip(I)
				I.forceMove(src)
			else
				I.forceMove(src)

			if(item_quants[I.name])
				item_quants[I.name]++
			else
				item_quants[I.name] = 1
			return 1
	return 0

/obj/machinery/smartfridge/attack_ai(mob/user)
	return 0

/obj/machinery/smartfridge/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/smartfridge/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	wires.Interact(user)
	ui_interact(user)

//Drag pill bottle to fridge to empty it into the fridge
/obj/machinery/smartfridge/MouseDrop_T(obj/over_object, mob/user)
	if(!istype(over_object, /obj/item/storage/pill_bottle)) //Only pill bottles, please
		return

	if(stat & NOPOWER)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	var/obj/item/storage/box/pillbottles/P = over_object
	var/items_loaded = 0
	for(var/obj/G in P.contents)
		if(load(G, user))
			items_loaded++
	if(items_loaded)
		user.visible_message( \
		"<span class='notice'>[user] empties \the [P] into \the [src].</span>", \
		"<span class='notice'>You empty \the [P] into \the [src].</span>")
	if(P.contents.len > 0)
		to_chat(user, "<span class='notice'>Some items are refused.</span>")
	SSnanoui.update_uis(src)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", name, 400, 500)
		ui.open()

/obj/machinery/smartfridge/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]

	data["contents"] = null
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure
	data["can_dry"] = can_dry
	data["drying"] = drying

	var/list/items[0]
	for(var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if(count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if(items.len > 0)
		data["contents"] = items

	return data

/obj/machinery/smartfridge/Topic(href, href_list)
	if(..())
		return FALSE

	var/mob/user = usr
	var/datum/nanoui/ui = SSnanoui.get_open_ui(user, src, "main")

	add_fingerprint(user)

	if(href_list["close"])
		user.unset_machine()
		ui.close()
		return FALSE

	if(href_list["vend"])
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/K = item_quants[index]
		var/count = item_quants[K]

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			item_quants[K] = max(count - amount, 0)

			var/i = amount
			if(i == 1 && Adjacent(user) && !issilicon(user))
				for(var/obj/O in contents)
					if(O.name == K)
						if(!user.put_in_hands(O))
							O.forceMove(loc)
							adjust_item_drop_location(O)
						update_icon()
						break
				return TRUE
			else
				for(var/obj/O in contents)
					if(O.name == K)
						O.forceMove(loc)
						adjust_item_drop_location(O)
						update_icon()
						i--
						if(i <= 0)
							return TRUE
		return TRUE
	return FALSE

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.forceMove(loc)
				throw_item = T
				update_icon()
				break
		break
	if(!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target,16,3,src)
	visible_message("<span class='warning'>[src] launches [throw_item.name] at [target.name]!</span>")
	return 1

// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A wooden contraption, used to dry plant products, food and leather."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "drying_rack"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 200
	can_dry = TRUE
	visible_contents = FALSE

/obj/machinery/smartfridge/drying_rack/New()
	..()
	if(component_parts && component_parts.len)
		component_parts.Cut()
	component_parts = null

/obj/machinery/smartfridge/drying_rack/on_deconstruction()
	new /obj/item/stack/sheet/wood(loc, 10)
	..()

/obj/machinery/smartfridge/drying_rack/RefreshParts()
	return

/obj/machinery/smartfridge/drying_rack/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/drying_rack/exchange_parts()
	return

/obj/machinery/smartfridge/drying_rack/spawn_frame()
	return

/obj/machinery/smartfridge/drying_rack/default_deconstruction_crowbar(user, obj/item/crowbar/C, ignore_panel = 1)
	..()

/obj/machinery/smartfridge/drying_rack/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["dryingOn"])
		drying = TRUE
		use_power = ACTIVE_POWER_USE
		update_icon()
		return 1

	if(href_list["dryingOff"])
		drying = FALSE
		use_power = IDLE_POWER_USE
		update_icon()
		return 1
	return 0

/obj/machinery/smartfridge/drying_rack/power_change()
	if(powered() && anchored)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		toggle_drying(TRUE)
	update_icon()

/obj/machinery/smartfridge/drying_rack/load(obj/I, mob/user) //For updating the filled overlay
	if(..())
		update_icon()
		return 1

/obj/machinery/smartfridge/drying_rack/update_icon()
	..()

	overlays.Cut()
	if(drying)
		overlays += "drying_rack_drying"
	if(contents.len)
		overlays += "drying_rack_filled"

/obj/machinery/smartfridge/drying_rack/process()
	..()
	if(drying)
		if(rack_dry())//no need to update unless something got dried
			update_icon()

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = O
		if(S.dried_type)
			return TRUE
	if(istype(O, /obj/item/stack/sheet/wetleather))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff)
	if(drying || forceoff)
		drying = FALSE
		use_power = IDLE_POWER_USE
	else
		drying = TRUE
		use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/smartfridge/drying_rack/proc/rack_dry()
	for(var/obj/item/reagent_containers/food/snacks/S in contents)
		if(S.dried_type == S.type)//if the dried type is the same as the object's type, don't bother creating a whole new item...
			S.color = "#ad7257"
			S.dry = TRUE
			item_quants[S.name]--
			S.forceMove(get_turf(src))
		else
			var/dried = S.dried_type
			new dried(loc)
			item_quants[S.name]--
			qdel(S)
		SSnanoui.update_uis(src)
		return TRUE
	for(var/obj/item/stack/sheet/wetleather/WL in contents)
		var/obj/item/stack/sheet/leather/L = new(loc)
		L.amount = WL.amount
		item_quants[WL.name]--
		qdel(WL)
		SSnanoui.update_uis(src)
		return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	..()
	atmos_spawn_air(SPAWN_HEAT)

/************************
*   Secure SmartFridges
*************************/
/obj/machinery/smartfridge/secure/emag_act(mob/user)
	emagged = 1
	locked = -1
	to_chat(user, "You short out the product lock on [src].")

/obj/machinery/smartfridge/secure/emp_act(severity)
	if(prob(40/severity) && (!emagged) && (locked != -1))
		playsound(loc, 'sound/effects/sparks4.ogg', 60, 1)
		emagged = 1
		locked = -1

/obj/machinery/smartfridge/secure/Topic(href, href_list)
	if(stat & (NOPOWER|BROKEN))
		return 0
	if(usr.contents.Find(src) || (in_range(src, usr) && istype(loc, /turf)))
		if(!allowed(usr) && !emagged && locked != -1 && href_list["vend"])
			to_chat(usr, "<span class='warning'>Access denied.</span>")
			SSnanoui.update_uis(src)
			return 0
	return ..()
