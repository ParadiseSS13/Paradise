// ----------------------------
//  Drying Rack 'smartfridge'
// ----------------------------
/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	icon = 'hyntatmta/icons/obj/hydrophonics/drying_rack.dmi'
	icon_state = "drying_rack_on"
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 200
	icon_on = "drying_rack_on"
	icon_off = "drying_rack"
	var/drying = 0

/obj/machinery/smartfridge/drying_rack/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	interact(user)

/obj/machinery/smartfridge/drying_rack/interact(mob/user as mob)
	var/dat = ..()
	if(dat)
		dat += "<br>"
		dat += "<a href='byond://?src=\ref[src];dry=1'>Toggle Drying</A> "
		user << browse("<HEAD><TITLE>[src] supplies</TITLE></HEAD><TT>[dat]</TT>", "window=smartfridge")
	onclose(user, "smartfridge")

/obj/machinery/smartfridge/drying_rack/Topic(href, list/href_list)
	..()
	if(href_list["dry"])
		toggle_drying()
	src.updateUsrDialog()

/obj/machinery/smartfridge/drying_rack/power_change()
	if(powered() && anchored)
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
		toggle_drying(1)
	update_icon()

/obj/machinery/smartfridge/drying_rack/load() //For updating the filled overlay
	..()
	update_icon()

/obj/machinery/smartfridge/drying_rack/update_icon()
	..()
	overlays = 0
	if(drying)
		overlays += image(icon_state="drying_rack_drying")
	if(contents.len)
		overlays += image(icon_state="drying_rack_filled")

/obj/machinery/smartfridge/drying_rack/process()
	..()
	if(drying)
		if(rack_dry())//no need to update unless something got dried
			update_icon()

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/))
		var/obj/item/weapon/reagent_containers/food/snacks/S = O
		if(S.dried_type)
			return 1
	return 0

/obj/machinery/smartfridge/drying_rack/proc/toggle_drying(forceoff = 0)
	if(drying || forceoff)
		drying = 0
		use_power = 1
	else
		drying = 1
		use_power = 2
	update_icon()

/obj/machinery/smartfridge/drying_rack/proc/rack_dry()
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

/obj/machinery/smartfridge/drying_rack/emp_act(severity)
	..()
	atmos_spawn_air(SPAWN_HEAT, 1000)
