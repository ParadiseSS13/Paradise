/obj/machinery/computer3/robotics
	default_prog = /datum/file/program/borg_control
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/networking/radio)
	icon_state = "frame-rnd"

/datum/file/program/borg_control
	name = "Cyborg Control"
	desc = "Used to remotely lockdown or detonate linked Cyborgs."
	active_state = "robot"
	var/id = 0.0
	var/temp = null
	var/status = 0
	var/timeleft = 60
	var/stop = 0.0
	var/screen = 0 // 0 - Main Menu, 1 - Cyborg Status, 2 - Kill 'em All! -- In text
	req_access = list(access_robotics)

	proc/start_sequence()
		do
			if(src.stop)
				src.stop = 0
				return
			src.timeleft--
			sleep(10)
		while(src.timeleft)

		for(var/mob/living/silicon/robot/R in mob_list)
			if(!R.scrambledcodes)
				R.self_destruct()
		return


	interact()
		if(!interactable() || computer.z > 6)
			return
		var/dat
		if (src.temp)
			dat = "<TT>[src.temp]</TT><BR><BR><A href='?src=\ref[src];temp=1'>Clear Screen</A>"
		else
			if(screen == 0)
				//dat += "<h3>Cyborg Control Console</h3><BR>"
				dat += "<A href='?src=\ref[src];screen=1'>1. Cyborg Status</A><BR>"
				dat += "<A href='?src=\ref[src];screen=2'>2. Emergency Full Destruct</A><BR>"
			if(screen == 1)
				for(var/mob/living/silicon/robot/R in mob_list)
					if(istype(usr, /mob/living/silicon/ai))
						if (R.connected_ai != usr)
							continue
					if(istype(usr, /mob/living/silicon/robot))
						if (R != usr)
							continue
					if(R.scrambledcodes)
						continue

					dat += "[R.name] |"
					if(R.stat)
						dat += " Not Responding |"
					else if (!R.canmove)
						dat += " Locked Down |"
					else
						dat += " Operating Normally |"
					if (!R.canmove)
					else if(R.cell)
						dat += " Battery Installed ([R.cell.charge]/[R.cell.maxcharge]) |"
					else
						dat += " No Cell Installed |"
					if(R.module)
						dat += " Module Installed ([R.module.name]) |"
					else
						dat += " No Module Installed |"
					if(R.connected_ai)
						dat += " Slaved to [R.connected_ai.name] |"
					else
						dat += " Independent from AI |"
					if (istype(usr, /mob/living/silicon))
						if(issilicon(usr) && is_special_character(usr) && !R.emagged)
							dat += "<A href='?src=\ref[src];magbot=\ref[R]'>(<i>Hack</i>)</A> "
					dat += "<A href='?src=\ref[src];stopbot=\ref[R]'>(<i>[R.canmove ? "Lockdown" : "Release"]</i>)</A> "
					dat += "<A href='?src=\ref[src];killbot=\ref[R]'>(<i>Destroy</i>)</A>"
					dat += "<BR>"
				dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"
			if(screen == 2)
				if(!src.status)
					dat += {"<BR><B>Emergency Robot Self-Destruct</B><HR>\nStatus: Off<BR>
					\n<BR>
					\nCountdown: [src.timeleft]/60 <A href='?src=\ref[src];reset=1'>\[Reset\]</A><BR>
					\n<BR>
					\n<A href='?src=\ref[src];killall'>Start Sequence</A><BR>
					\n<BR>
					\n<A href='?src=\ref[usr];close'>Close</A>"}
				else
					dat = {"<B>Emergency Robot Self-Destruct</B><HR>\nStatus: Activated<BR>
					\n<BR>
					\nCountdown: [src.timeleft]/60 \[Reset\]<BR>
					\n<BR>\n<A href='?src=\ref[src];stop=1'>Stop Sequence</A><BR>
					\n<BR>
					\n<A href='?src=\ref[usr];mach_close=computer'>Close</A>"}
				dat += "<A href='?src=\ref[src];screen=0'>(Return to Main Menu)</A><BR>"

		popup.set_content(dat)
		popup.open()
		return

	Topic(var/href, var/list/href_list)
		if(!interactable() || ..(href,href_list))
			return

		if ("killall" in href_list)
			src.temp = {"Destroy Robots?<BR>
			<BR><B><A href='?src=\ref[src];do_killall'>\[Swipe ID to initiate destruction sequence\]</A></B><BR>
			<A href='?src=\ref[src];temp=1'>Cancel</A>"}

		if ("do_killall" in href_list)
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (istype(I))
				if(src.check_access(I))
					if (!status)
						message_admins("\blue [key_name_admin(usr)] has initiated the global cyborg killswitch!")
						log_game("\blue [key_name(usr)] has initiated the global cyborg killswitch!")
						src.status = 1
						src.start_sequence()
						src.temp = null

				else
					usr << "\red Access Denied."

		if ("stop" in href_list)
			src.temp = {"
			Stop Robot Destruction Sequence?<BR>
			<BR><A href='?src=\ref[src];stop2=1'>Yes</A><BR>
			<A href='?src=\ref[src];temp=1'>No</A>"}

		if ("stop2" in href_list)
			src.stop = 1
			src.temp = null
			src.status = 0

		if ("reset" in href_list)
			src.timeleft = 60

		if ("temp" in href_list)
			src.temp = null
		if ("screen" in href_list)
			switch(href_list["screen"])
				if("0")
					screen = 0
				if("1")
					screen = 1
				if("2")
					screen = 2
		if ("killbot" in href_list)
			if(computer.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["killbot"])
				if(R)
					var/choice = input("Are you certain you wish to detonate [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							if(R.mind && R.mind.special_role && R.emagged)
								R << "Extreme danger.  Termination codes detected.  Scrambling security codes and automatic AI unlink triggered."
								R.ResetSecurityCodes()

							else
								message_admins("\blue [key_name_admin(usr)] detonated [R.name]!")
								log_game("\blue [key_name_admin(usr)] detonated [R.name]!")
								R.self_destruct()
			else
				usr << "\red Access Denied."

		if ("stopbot" in href_list)
			if(computer.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["stopbot"])
				if(R && istype(R)) // Extra sancheck because of input var references
					var/choice = input("Are you certain you wish to [R.canmove ? "lock down" : "release"] [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
							message_admins("\blue [key_name_admin(usr)] [R.canmove ? "locked down" : "released"] [R.name]!")
							log_game("[key_name(usr)] [R.canmove ? "locked down" : "released"] [R.name]!")
							R.canmove = !R.canmove
							if (R.lockcharge)
							//	R.cell.charge = R.lockcharge
								R.lockcharge = !R.lockcharge
								R << "Your lockdown has been lifted!"
							else
								R.lockcharge = !R.lockcharge
						//		R.cell.charge = 0
								R << "You have been locked down!"

			else
				usr << "\red Access Denied."

		if ("magbot" in href_list)
			if(computer.allowed(usr))
				var/mob/living/silicon/robot/R = locate(href_list["magbot"])
				if(R)
					var/choice = input("Are you certain you wish to hack [R.name]?") in list("Confirm", "Abort")
					if(choice == "Confirm")
						if(R && istype(R))
//							message_admins("\blue [key_name_admin(usr)] emagged [R.name] using robotic console!")
							log_game("[key_name(usr)] emagged [R.name] using robotic console!")
							R.emagged = 1
							if(R.mind.special_role)
								R.verbs += /mob/living/silicon/robot/proc/ResetSecurityCodes

		interact()
		return



