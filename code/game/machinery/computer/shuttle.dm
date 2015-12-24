/obj/machinery/computer/emergency_shuttle
	name = "emergency shuttle console"
	desc = "For shuttle control."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	var/auth_need = 3
	var/list/authorized = list()

/obj/machinery/computer/emergency_shuttle/attackby(obj/item/weapon/card/W, mob/user, params)
	if(stat & (BROKEN|NOPOWER))	return
	if(!istype(W, /obj/item/weapon/card))
		return
	if(shuttle_master.emergency.mode != SHUTTLE_DOCKED)
		return
	if(!user)
		return
	if(shuttle_master.emergency.timeLeft() < 11)
		return
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			W = pda.id
		if (!W:access) //no access
			user << "The access level of [W:registered_name]\'s card is not high enough. "
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			user << "The access level of [W:registered_name]\'s card is not high enough. "
			return

		if(!(access_heads in W:access)) //doesn't have this access
			user << "The access level of [W:registered_name]\'s card is not high enough. "
			return 0

		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", src.auth_need - src.authorized.len), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		if(shuttle_master.emergency.mode != SHUTTLE_DOCKED || user.get_active_hand() != W)
			return 0

		var/seconds = shuttle_master.emergency.timeLeft()
		if(seconds <= 10)
			return 0

		switch(choice)
			if("Authorize")
				if(!authorized.Find(W:registered_name))
					authorized += W:registered_name
					if(auth_need - authorized.len > 0)
						message_admins("[key_name_admin(user)] has authorized early shuttle launch.")
						log_game("[key_name(user)] has authorized early shuttle launch in ([x], [y], [z]).")
						minor_announcement.Announce("[auth_need - authorized.len] more authorization(s) needed until shuttle is launched early")
					else
						message_admins("[key_name_admin(user)] has launched the emergency shuttle [seconds] seconds before launch.")
						log_game("[key_name(user)] has launched the emergency shuttle in ([x], [y], [z]) [seconds] seconds before launch.")
						minor_announcement.Announce("The emergency shuttle will launch in 10 seconds")
						shuttle_master.emergency.setTimer(100)

			if("Repeal")
				if(authorized.Remove(W:registered_name))
					minor_announcement.Announce("[auth_need - authorized.len] authorizations needed until shuttle is launched early")

			if("Abort")
				if(authorized.len)
					minor_announcement.Announce("All authorizations to launch the shuttle early have been revoked.")
					authorized.Cut()

/obj/machinery/computer/emergency_shuttle/emag_act(mob/user)
	if(!emagged && shuttle_master.emergency.mode == SHUTTLE_DOCKED)
		var/time = shuttle_master.emergency.timeLeft()
		message_admins("[key_name_admin(user)] has emagged the emergency shuttle: [time] seconds before launch.")
		log_game("[key_name(user)] has emagged the emergency shuttle in ([x], [y], [z]): [time] seconds before launch.")
		minor_announcement.Announce("The emergency shuttle will launch in 10 seconds", "SYSTEM ERROR:")
		shuttle_master.emergency.setTimer(100)
		emagged = 1
