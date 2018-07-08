/obj/machinery/computer/vr_pvp
	name = "VR PVP console"
	desc = "You should not see this."
	icon_screen = "comm_logs"

	light_color = LIGHT_COLOR_DARKGREEN

/obj/machinery/computer/vr_pvp/New()
	..()

/obj/machinery/computer/vr_pvp/Destroy()
	return ..()

/obj/machinery/computer/vr_pvp/attack_ai(mob/user)
	interact(user)

/obj/machinery/computer/vr_pvp/attack_hand(mob/user)
	interact(user)

/obj/machinery/computer/vr_pvp/interact(mob/user)
	ui_interact(user)

/obj/machinery/computer/vr_pvp/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vr_pvp.tmpl", name, 400, 300)
		ui.open()

obj/machinery/computer/vr_pvp/Topic(href, href_list)
	var/datum/vr_room/room = vr_rooms_official[name]
	if(..())
		return 0

	if(href_list["toggle_ready"])
		if(usr in room.waitlist)
			room.waitlist.Remove(usr)
		else if(!(usr in room.waitlist))
			room.waitlist.Add(usr)
		.=1

/obj/machinery/computer/vr_pvp/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	var/datum/vr_room/room = vr_rooms_official[name]
	data["user_in_room"] = (user in room.waitlist)
	var/players[0]
	for(var/mob/living/carbon/human/virtual_reality/player in room.waitlist)
		players.Add(list(list("name" = player.name))) // list in a list because Byond merges the first list..
	data["players"] = players
	data["playercount"] = room.waitlist.len
	return data

/obj/machinery/computer/vr_pvp/roman
	name = "Roman Arena"
	desc = "Ready up here for the roman arena."

/obj/machinery/computer/vr_pvp/ship
	name = "Ship Arena"
	desc = "Ready up here for the ship arena."


/obj/machinery/status_display/vr
	name = "VR round timer"
	var/room_name = "VR Room here"
	ignore_friendc = 1
	var/datum/vr_room/myroom

/obj/machinery/status_display/vr/update()
	var/timeleft
	if(myroom)
		timeleft = (myroom.round_end - world.time)/10
		timeleft = "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		timeleft = "ERROR"
	message1 = "Arena"
	message2 = "[timeleft]"
	if(lentext(message2) > CHARS_PER_LINE)
		message2 = "Wait"
	update_display(message1, message2)

/obj/machinery/status_display/vr/roman
	name = "roman arena timer"
	room_name = "Roman Arena"

/obj/machinery/status_display/vr/ship
	name = "ship arena timer"
