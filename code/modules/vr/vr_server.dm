// The server

var/vr_server_status = VR_SERVER_OFF
var/vr_server_admin_disabled = FALSE

/obj/machinery/vr_server
	name = "N.T.S.R.S. Server"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "server"
	var/active = VR_SERVER_OFF
	emagged = 0
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 100
	var/obj/machinery/telecomms/relay/internal_relay = null


/obj/machinery/vr_server/update_icon()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "server-nopower"
	else if(emagged)
		icon_state = "server-emag"
	else if(!active)
		icon_state = "server-off"
	else
		icon_state = "server-on"
	if(panel_open)
		icon_state = "[icon_state]_o"
	return

/obj/machinery/vr_server/attack_ghost(mob/dead/observer/user as mob)
	if(user.can_admin_interact())
		attack_hand(user)
	
/obj/machinery/vr_server/attack_hand(user as mob)
	if(check_rights(R_ADMIN))
		switch(alert("Are you sure you want to push the power button on the Virtual Reality Server?", "VR Server", "Yes", "No", "Admin [vr_server_admin_disabled ? "Enable" : "Disable"] Globally"))
			if("Admin Disable Globally")
				vr_server_admin_disabled = TRUE
				set_state(VR_SERVER_OFF)
			if("Admin Enable Globally")
				vr_server_admin_disabled = FALSE
			if("Yes")
				if(vr_server_admin_disabled)
					to_chat(user, "Bluespace override detected. N.T.S.R.S. central server offline.")
				else if(vr_server_status != VR_SERVER_OFF && !active)
					to_chat(user, "Only one Virtual Reality Server can be online at a time.")
				else
					to_chat(user, "You toggle the Virtual Reality Server from [active ? "On" : "Off"] to [active ? "Off" : "On"]")
					if(!active)
						if(!emagged)
							set_state(VR_SERVER_ON)
						else
							set_state(VR_SERVER_EMAG)
					else
						if(!emagged)
							set_state(VR_SERVER_OFF)
						else
							to_chat(user, "The server refuses to respond to your commands and the main circuit board appears to be fried.")
	else
		switch(alert("Are you sure you want to push the power button on the Virtual Reality Server?", "VR Server", "Yes", "No"))
			if("Yes")
				if(vr_server_admin_disabled)
					to_chat(user, "Bluespace override detected. N.T.S.R.S. central server offline.")
				else if(vr_server_status != VR_SERVER_OFF && !active)
					to_chat(user, "Only one Virtual Reality Server can be online at a time.")
				else
					to_chat(user, "You toggle the Virtual Reality Server from [active ? "On" : "Off"] to [active ? "Off" : "On"]")
					if(!active)
						if(!emagged)
							set_state(VR_SERVER_ON)
						else
							set_state(VR_SERVER_EMAG)
					else
						if(!emagged)
							set_state(VR_SERVER_OFF)
						else
							to_chat(user, "The server refuses to respond to your commands and the main circuit board appears to be fried.")
	return

/obj/machinery/vr_server/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/circuitboard/vr_server) && emagged)
		emagged = FALSE
		desc = null
		qdel(I)
		to_chat(user, "You replace the burnt out circuit board with a fresh one, discarding the destroyed board.")
		if(active)
			set_state(VR_SERVER_ON)
	if(istype(I, /obj/item/screwdriver))
		playsound(loc, I.usesound, 50, 1)
		panel_open = !panel_open
		update_icon()
		to_chat(user, "<span class='notice'>You [panel_open ? "close" : "open"] the maintenance hatch of [src].</span>")
		return 1
	if(panel_open)
		if(istype(I, /obj/item/crowbar))
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/vr_server/Destroy()
	if(active)
		set_state(VR_SERVER_OFF)
	return ..()

/obj/machinery/vr_server/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/vr_server(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/cell(null)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	component_parts += new /obj/item/stack/cable_coil(null,1)
	RefreshParts()
	internal_relay = new /obj/machinery/telecomms/relay/preset/vr(src)
	internal_relay.toggled = 0
	if(vr_server_status == VR_SERVER_OFF)
		if(vr_server_admin_disabled)
			visible_message("Bluespace override detected. N.T.S.R.S. central server offline.")
		else
			set_state(VR_SERVER_ON)
	update_icon()

/obj/machinery/vr_server/power_change()
	..()
	if(stat & NOPOWER)
		set_state(VR_SERVER_OFF)

/obj/machinery/vr_server/process()
	if(active && (stat & BROKEN))
		set_state(VR_SERVER_OFF)
		return
	update_icon()
	return

/obj/machinery/vr_server/proc/set_state(var/state)
	active = state
	vr_server_status = state
	internal_relay.toggled = 0
	if(vr_server_status == VR_SERVER_OFF)
		vr_kick_all_players()
	else if(vr_server_status == VR_SERVER_ON)
		internal_relay.toggled = 1
	update_icon()

/obj/machinery/vr_server/emag_act(user as mob)
	if(active)
		set_state(VR_SERVER_EMAG)
	playsound(src.loc, "sparks", 100, 1)
	emagged = TRUE
	to_chat(user, "You fry the containment circuits trapping all the players and releasing all the prisoners.")
	desc = "Its main circuit board appears to be fried."
	for(var/mob/living/carbon/human/virtual_reality/player in vr_all_players)
		to_chat(player, "ERROR: Containment protocal has encountered a fatal exception.")
