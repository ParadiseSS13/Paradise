/obj/machinery/computer/vr_ticket
	name = "VR Tickt Machine"
	desc = "Your one stop shot for VR arena tickets"
	icon_screen = "comm_logs"

	light_color = LIGHT_COLOR_DARKGREEN


/obj/machinery/computer/vr_control/New()
	..()

/obj/machinery/computer/vr_control/Destroy()
	return ..()

/obj/machinery/computer/vr_control/attack_ai(mob/user)
	attack_hand(user)
	ui_interact(user)


/obj/machinery/computer/vr_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/vr_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	switch(alert("What would you like to do?", "VR Control", "Join Room", "Make Room", "Cancel"))
		if("Join Room")
			var/datum/vr_room/room = input(user, "Choose a room to join.","Select Level") as null|anything in vr_rooms
			room = vr_rooms[room]
			spawn_vr_avatar(user, room)
			if(!(user.ckey))
				qdel(user)
		if("Make Room")
			var/name = input(user, "Name your new Room","Name here.") as null|text
			var/datum/vr_room/room = input(user, "Choose a Level to load into your new Room.","Select Level") as null|anything in vr_templates
			make_vr_room(name, room, 1)
		if("Cancel")
			return


/obj/item/weapon/vr_ticket
	name = "vr ticket"
	desc = "This should not exist, report to an admin."
	icon = 'icons/obj/arcade.dmi'
	icon_state = "tickets_1"
	force = 0
	throwforce = 0
	throw_speed = 1
	throw_range = 1
	w_class = WEIGHT_CLASS_TINY

/obj/item/weapon/vr_ticket/roman
	name = "roman ticket"
	desc = "A ticket for the Roman Arena"

/obj/item/weapon/vr_ticket/gauntlet
	name = "gauntlet ticket"
	desc = "A ticket for the Gauntlet"