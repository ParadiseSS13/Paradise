var/list/chatrooms = list(new /datum/chatroom("General Discussion"))

/datum/chatroom
	var/name = "Generic Chatroom"
	var/list/users = list()
	var/list/invites = list()
	var/list/logs = list() // chat logs
	var/topic = "Discussion" // topic message for the chatroom
	var/is_public = 1
	var/announcer = "CyberiadAI"

/datum/chatroom/New(n)
	name = n

/datum/chatroom/proc/post(user, message, username)
	if(!user || !message)
		return

	if(!username)
		if(istype(user, /datum/data/pda/app/chatroom))
			var/datum/data/pda/app/chatroom/c = user
			if(!c.pda.owner)
				return
			username = c.pda.owner
		else
			return

	logs += list(list(username = username, message = message))

	for(var/datum/data/pda/app/chatroom/u in users)
		spawn()
			if(u.messaging_available() && !u.toff && user != u)
				u.notify("<b>Post from [username] in #[name], </b>\"[message]\" (<a href='?src=[u.UID()];choice=Post;target=\ref[src]'>Post</a>)")

/datum/chatroom/proc/announce(user, message)
	post(user, "<span class='average'>[message]</span>", announcer)

/datum/chatroom/proc/login(datum/data/pda/app/chatroom/user)
	if(!user || !user.pda.owner)
		return 0

	if(user in users)
		return 1

	if(!is_public && !(user in invites))
		return 0

	users |= user
	announce(user, "[user.pda.owner] has entered #[name].")
	return 1

/datum/chatroom/proc/logout(datum/data/pda/app/chatroom/user)
	if(!user || !user.pda.owner || !(user in users))
		return

	users -= user
	invites -= user
	announce(user, "[user.pda.owner] has left #[name].")

/datum/data/pda/app/chatroom
	name = "Chatbuddy"
	icon = "hashtag"
	notify_icon = "comments"
	template = "pda_chatroom"
	var/toff = 0
	var/datum/chatroom/current_room = null
	var/inviting = 0
	var/channels_created = 0
	var/max_channels_created = 3
	var/latest_post = 0
	var/auto_scroll = 1
	var/disconnected = 0

/datum/data/pda/app/chatroom/Destroy()
	for(var/C in chatrooms)
		var/datum/chatroom/ch = C
		if(src in ch.users)
			ch.users -= src
		if(src in ch.invites)
			ch.invites -= src

/datum/data/pda/app/chatroom/start()
	. = ..()
	unnotify()
	latest_post = 0

/datum/data/pda/app/chatroom/update_ui(mob/user as mob, list/data)
	data["silent"] = notify_silent
	data["toff"] = toff
	if(disconnected || !messaging_available(1))
		data["no_server"] = 1
		has_back = 0
	else if(current_room)
		data["room"] = current_room.name
		data["topic"] = current_room.topic
		if(inviting)
			data["inviting"] = 1
			var/list/pdas = list()
			for(var/A in PDAs)
				var/obj/item/device/pda/P = A
				var/datum/data/pda/app/chatroom/C = P.find_program(/datum/data/pda/app/chatroom)
				var/datum/data/pda/app/messenger/PM = P.find_program(/datum/data/pda/app/messenger)

				if(!P.owner || P == pda || PM.m_hidden || (C in current_room.invites) || (C in current_room.users))
					continue
				pdas += list(list(name = "[P.owner] ([P.ownjob])", ref = "\ref[C]"))
			data["people"] = pdas
		else
			data["history"] = current_room.logs
			var/list/users[0]
			for(var/U in current_room.users)
				var/datum/data/pda/app/chatroom/ch = U
				users += "<span class='good'>[ch.pda.owner]</span>"
			for(var/U in (current_room.invites - current_room.users))
				var/datum/data/pda/app/chatroom/ch = U
				users += "<span class='average'>[ch.pda.owner]</span>"
			data["users"] = users
			data["auto_scroll"] = auto_scroll
			data["latest_post"] = latest_post
			latest_post = current_room.logs.len
		has_back = 1
	else
		var/list/rooms[0]
		for(var/datum/chatroom/c in chatrooms)
			if((src in c.users) || (src in c.invites) || c.is_public)
				rooms += list(list(name = "[c]", ref = "\ref[c]"))
		data["rooms"] = rooms
		has_back = 0

/datum/data/pda/app/chatroom/proc/messaging_available(cheap = 0)
	. = 0
	if(message_servers)
		for(var/A in message_servers)
			var/obj/machinery/message_server/MS = A
			if(MS.active)
				. = cheap || pda.test_telecomms()
	disconnected = !.

/datum/data/pda/app/chatroom/proc/check_messaging_available()
	. = messaging_available()
	if(!.)
		to_chat(usr, "<span class='notice'>ERROR: Messaging server is not responding.</span>")

/datum/data/pda/app/chatroom/Topic(href, list/href_list)
	if(!pda.can_use())
		return
	unnotify()

	switch(href_list["choice"])
		if("Toggle Chatroom")
			toff = !toff
		if("Toggle Ringer")
			notify_silent = !notify_silent
		if("Back")
			if(inviting)
				inviting = 0
			else
				current_room = null
				latest_post = 0
		if("Join")
			if(href_list["room"])
				current_room = locate(href_list["room"])
			if(!(src in current_room.users))
				if(!current_room.login(src))
					current_room = null
			latest_post = 0
		if("Post")
			var/datum/chatroom/target
			if(href_list["target"])
				target = locate(href_list["target"])
			else
				target = current_room

			if(!target)
				return

			var/t = input("Please enter message", target) as text|null
			spawn()
				if(!t || !check_messaging_available())
					return
				t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
				t = readd_quotes(t)
				if(!t || !pda.can_use())
					return

				target.post(src, t)
		if("Topic")
			if(!current_room)
				return

			var/t = input("Enter new topic:", current_room, current_room.topic) as text|null
			spawn()
				if(!t || !check_messaging_available() || !pda.can_use())
					return
				t = sanitize(copytext(t, 1, MAX_MESSAGE_LEN))
				t = readd_quotes(t)
				if(!t)
					return

				current_room.topic = t
				current_room.announce(src, "Topic has been changed to '[t]' by [pda.owner].")
		if("Leave")
			if(!current_room)
				return

			current_room.logout(src)
			current_room = null
			latest_post = 0
		if("Invite")
			if(!current_room)
				return

			inviting = 1
		if("Invite PDA")
			spawn()
				if(!check_messaging_available() || !current_room || !href_list["user"])
					return

				var/datum/data/pda/app/chatroom/C = locate(href_list["user"])
				if(C)
					current_room.invites |= C
					spawn()
						if(C.messaging_available() && !C.toff)
							C.notify("<b>Invite to #[current_room]</b> (<a href='?src=[C.UID()];choice=Join;room=\ref[current_room]'>Join</a>)")
		if("New Room")
			if(channels_created >= max_channels_created)
				alert("This PDA has already reached its maximum channels created.", name)
				return

			var/t = input("Enter room name:", name) as text|null
			if(!t)
				return
			t = sanitize(copytext(t, 1, MAX_NAME_LEN))
			t = readd_quotes(t)

			var/access = input("Room access?", current_room) as null|anything in list("Public", "Private")
			if(!access)
				return

			spawn()
				if(!t || !check_messaging_available() || !pda.can_use())
					return

				// check if already taken
				for(var/datum/chatroom/C in chatrooms)
					if(C.name == t)
						alert("Channel with that name already exists.", name)
						return

				channels_created++
				current_room = new /datum/chatroom(t)
				chatrooms += current_room
				latest_post = 0

				current_room.invites |= src
				current_room.is_public = access == "Public"
				current_room.login(src)
				if(!current_room.is_public)
					current_room.announce(src, "Users must be invited to join this room.")
		if("Autoscroll")
			auto_scroll = !auto_scroll
		if("Reconnect")
			spawn()
				messaging_available()