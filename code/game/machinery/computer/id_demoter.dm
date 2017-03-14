/obj/machinery/computer/id_demoter
	name = "ID Demotion Terminal"
	desc = "Allows heads of staff to demote members of their department, by swiping their ID, then the ID of the person they wish to demote."
	density = 0
	icon_state = "guest"
	icon_screen = "pass"
	var/headname = null
	var/headrank = null
	var/list/headaccess = list()

/obj/machinery/computer/id_demoter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/D = I

		if(headaccess.len > 0)
			if(D.registered_name == headname)
				visible_message("<span class='warning'>[src]: You cannot demote your own ID. Swipe the ID of the person you wish to demote on this console.</span>")
				playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
				return
			if(D.assignment == "Civilian")
				visible_message("<span class='warning'>[src]: Civilian IDs cannot be demoted any further using this console.</span>")
				playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
				return
			// Stop heads from demoting the staff of other departments. HoP/Captain can still demote anyone.
			if(!(access_change_ids in headaccess))
				for(var/thisaccess in D.access)
					if(!(thisaccess in headaccess))
						visible_message("<span class='warning'>[src]: [headrank] [headname] cannot use this method to demote [D.assignment] [D.registered_name]. Contact the Head of Personnel.</span>")
						playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
						return
			visible_message("<span class='notice'>[src]: [headrank] [headname] has demoted [D.registered_name] from [D.assignment] to Civilian. Remember to recover any job-specific items they may have.</span>")
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			var/datum/job/civilian/C = new/datum/job/civilian
			D.access = C.get_access()
			D.assignment = "Civilian"
			D.name = text("[D.registered_name]'s ID Card ([D.assignment])")
			D.icon_state = "id"

		else
			if(!(D.assignment in command_positions))
				visible_message("<span class='warning'>[src]: Access Denied. You must swipe a head of staff's ID on this machine first, then swipe the ID of the person you wish to demote.</span>")
				playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
				return
			headname = D.registered_name
			headrank = D.assignment
			headaccess = D.access
			if(access_change_ids in headaccess)
				visible_message("<span class='notice'>[src]: [headrank] [headname] recognized. Swipe any ID on this console, and that ID will be demoted to Civilian.</span>")
			else
				visible_message("<span class='notice'>[src]: [headrank] [headname] recognized. Swipe any ID from your department on this console, and that ID will be demoted to Civilian.</span>")
			playsound(src.loc, 'sound/machines/twobeep.ogg', 50, 0)
			spawn(300)
				if(headaccess.len)
					visible_message("<span class='notice'>[src] beeps: [headrank] [headname] has been automatically logged out. Please swipe your ID again if you wish to demote any more IDs.</span>")
					headname = null
					headrank = null
					headaccess = list()
	else
		. = ..()
