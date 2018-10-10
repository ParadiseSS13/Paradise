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
	var/obj/item/radio/radio = null


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
		desc = null
		qdel(I)

/obj/machinery/vr_server/Destroy()
	set_state(VR_SERVER_OFF)
	return ..()

/obj/machinery/vr_server/New()
	if(vr_server_status == VR_SERVER_OFF)
		set_state(VR_SERVER_ON)
	radio = new /obj/item/radio/internal/vr(src)
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
	to_chat(user, "You fry the containment circuits trapping all the players and releasing all the prisoners.")
	desc = "Its main circuit board appears to be fried."
	for(var/mob/living/carbon/human/virtual_reality/player in vr_all_players)
		to_chat(player, "ERROR: Containment protocal has encountered a fatal exception.")

/obj/item/radio/internal/vr
	channels = list("Common" = 1, "Science" = 1, "Command" = 1, "Medical" = 1, "Engineering" = 1, "Security" = 1, "Response Team" = 1, "Special Ops" = 1,
		"Syndicate" = 1, "SyndTeam" = 1, "Supply" = 1, "Service" = 1, "AI Private"= 1, "Medical(I)"= 1, "Security(I)"= 1)

/obj/item/radio/internal/vr/get_listening_turfs(freq)
	var/list/listening_turfs = list()
	for(var/mob/living/carbon/human/virtual_reality/P in vr_all_players)
		var/turf/T = P.loc
		if(freq && P.real_me)
			for(var/obj/item/radio/headset/H in P.real_me.get_head_slots())
				for(var/channel in H.channels)
					if(radiochannels[channel] == freq)
						listening_turfs[T] = T
		else
			listening_turfs[T] = T
	return listening_turfs

/obj/item/radio/internal/vr/send_hear(freq, level)
	var/list/listening_mobs = list()
	for(var/mob/living/carbon/human/virtual_reality/P in vr_all_players)
		if(freq && P.real_me)
			for(var/obj/item/radio/headset/H in P.real_me.get_head_slots())
				for(var/channel in H.channels)
					if(radiochannels[channel] == freq)
						listening_mobs += P
		else
			listening_mobs += P
	return listening_mobs