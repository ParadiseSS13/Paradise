// The server

var/vr_server_status = VR_SERVER_OFF

/obj/machinery/vr_server
	name = "vr server"
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

	return

/obj/machinery/vr_server/attack_hand(user as mob)
	switch(alert("Are you sure you want to push the power button on the Virtual Reality Server?", "VR Server", "Yes", "No"))
		if("Yes")
			if(vr_server_status != VR_SERVER_OFF && !active)
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
				update_icon()
	return

/obj/machinery/vr_server/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/circuitboard/vr_server) && emagged)
		set_state(VR_SERVER_ON)
		emagged = FALSE
		internal_relay.toggled = 1
		desc = null
		qdel(I)

/obj/machinery/vr_server/Destroy()
	set_state(VR_SERVER_OFF)
	return ..()

/obj/machinery/vr_server/New()
	if(vr_server_status == VR_SERVER_OFF)
		set_state(VR_SERVER_ON)
	internal_relay = new /obj/machinery/telecomms/relay/preset/vr(src)
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
	if(vr_server_status == VR_SERVER_OFF)
		vr_kick_all_players()
	if(vr_server_status == VR_SERVER_EMAG)
		if(!emagged)
			emagged = TRUE
			playsound(src.loc, "sparks", 100, 1)

/obj/machinery/vr_server/emag_act(user as mob)
	set_state(VR_SERVER_EMAG)
	internal_relay.toggled = 0
	to_chat(user, "You fry the containment circuits trapping all the players and releasing all the prisoners.")
	desc = "Its main circuit board appears to be fried."
	for(var/mob/living/carbon/human/virtual_reality/player in vr_all_players)
		to_chat(player, "ERROR: Containment protocal has encountered a fatal exception.")
