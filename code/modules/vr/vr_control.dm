/obj/machinery/computer/vr_control
	name = "N.T.S.R.S. console"
	desc = "A list and control panel for all virtual servers."
	icon_screen = "comm_logs"
	var/making_room = 0
	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/vr_control/Destroy()
	return ..()

/obj/machinery/computer/vr_control/attack_ai(mob/user)
	interact(user)

/obj/machinery/computer/vr_control/attack_hand(mob/user)
	interact(user)

/obj/machinery/computer/vr_control/interact(mob/user)
	ui_interact(user)

/obj/machinery/computer/vr_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vr_control.tmpl", "User Created Rooms", 500, 400)
		ui.open()

/obj/machinery/computer/vr_control/Topic(href, href_list)
	if(..())
		return 0

	if(href_list["toggle_making"])
		making_room = !making_room
		.=1
	if(href_list["join_room"])
		var/datum/vr_room/room = vr_rooms[href_list["join_room"]]
		if(room)
			if(room.password)
				var/password = input(usr, "Enter Password","") as null|text
				if(password == room.password || check_rights(R_ADMIN))
					spawn_vr_avatar(usr, room)
					if(!(usr.ckey))
						usr.death()
				else
					to_chat(usr, "<span class='danger'>Incorrect Password!</span>")
			else
				spawn_vr_avatar(usr, room)
				if(!(usr.ckey))
					usr.death()
		.=1

	if(href_list["make_room"])
		var/name = input(usr, "","Name your new Room.") as null|text
		if(length(name) > 15)
			to_chat(usr, "That name is too long, please try again!")
			return 0
		var/password = input(usr, "(Leave Blank for unlocked)","Password protect your new Room?") as null|text
		if(!name)
			return 0
		for(var/datum/vr_room/R in vr_rooms)
			if(R.creator == usr.ckey && 0)
				to_chat(usr, "The system only supports one room per client. Please try again once your current room has expired or after deleting it.")
				return 0
		make_vr_room(name, href_list["make_room"], 1, usr.ckey, password)
		.=1

	if(href_list["delete"])
		var/datum/vr_room/room = vr_rooms[href_list["delete"]]
		if(room.creator == usr.ckey || check_rights(R_ADMIN))
			room.cleanup()
		else
			to_chat(usr, "You do not have permission to delete this room.")
		.=1

/obj/machinery/computer/vr_control/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["user_ckey"] = user.ckey
	data["making_room"] = making_room
	var/templates[0]
	for(var/R in vr_templates)
		var/datum/map_template/vr/level/temp = vr_templates[R]
		if(temp.system)
			continue
		templates.Add(list(list("name" = temp, "id" = temp.id, "description" = temp.description))) // list in a list because Byond merges the first list..
	data["templates"] = templates
	var/rooms[0]
	for(var/R in vr_rooms)
		var/datum/vr_room/temp = vr_rooms[R]
		var/locked = FALSE
		if(length(temp.password) > 0)
			locked = TRUE
		rooms.Add(list(list("name" = temp, "template" = temp.template, "creator" = temp.creator, "players" = temp.players.len, "password" = locked))) // list in a list because Byond merges the first list..
	data["rooms"] = rooms
	return data
