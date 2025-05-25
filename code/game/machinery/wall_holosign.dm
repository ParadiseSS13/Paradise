////////////////////HOLOSIGN///////////////////////////////////////
/obj/machinery/holosign
	name = "holosign"
	desc = "Small wall-mounted holographic projector."
	icon = 'icons/obj/holosign.dmi'
	icon_state = "sign_off"
	layer = 4
	anchored = TRUE
	var/lit = FALSE
	var/id = null
	var/on_icon = "sign_on"

/obj/machinery/holosign/proc/toggle()
	if(stat & (BROKEN|NOPOWER))
		return
	lit = !lit
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/holosign/update_icon_state()
	if(!lit)
		icon_state = "sign_off"
	else
		icon_state = on_icon

/obj/machinery/holosign/power_change()
	if(!..())
		return
	if(stat & NOPOWER)
		lit = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/holosign/surgery
	name = "surgery holosign"
	desc = "Small wall-mounted holographic projector. This one reads SURGERY."
	on_icon = "surgery"
////////////////////SWITCH///////////////////////////////////////

/obj/machinery/holosign_switch
	name = "holosign switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light0"
	desc = "A remote control switch for holosign."
	var/id = null
	var/active = FALSE
	anchored = TRUE
	idle_power_consumption = 2
	active_power_consumption = 4

/obj/machinery/holosign_switch/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/holosign_switch/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/detective_scanner))
		return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/holosign_switch/attack_hand(mob/user as mob)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	add_fingerprint(user)

	use_power(5)

	active = !active
	if(active)
		icon_state = "light1"
	else
		icon_state = "light0"

	for(var/obj/machinery/holosign/M in SSmachines.get_by_type(/obj/machinery/holosign))
		if(M.id == src.id)
			spawn( 0 )
				M.toggle()
				return

	return
