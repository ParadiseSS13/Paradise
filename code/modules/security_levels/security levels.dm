/var/security_level = 0
//0 = code green
//1 = code blue
//2 = code red
//3 = gamma
//4 = epsilon
//5 = code delta

//config.alert_desc_blue_downto
/var/datum/announcement/priority/security/security_announcement_up = new(do_log = 0, do_newscast = 1, new_sound = sound('sound/misc/notice1.ogg'))
/var/datum/announcement/priority/security/security_announcement_down = new(do_log = 0, do_newscast = 1)

/proc/set_security_level(var/level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("gamma")
			level = SEC_LEVEL_GAMMA
		if("epsilon")
			level = SEC_LEVEL_EPSILON
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				security_announcement_down.Announce("All threats to the station have passed. All weapons need to be holstered and privacy laws are once again fully enforced.","Attention! Security level lowered to green.")
				security_level = SEC_LEVEL_GREEN

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "outline")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_green")

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					security_announcement_up.Announce("The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible and random searches are permitted.","Attention! Security level elevated to blue.")
				else
					security_announcement_down.Announce("The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed.","Attention! Security level lowered to blue.")
				security_level = SEC_LEVEL_BLUE

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "outline")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_blue")

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					security_announcement_up.Announce("There is an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.","Attention! Code Red!")
				else
					security_announcement_down.Announce("The station's self-destruct mechanism has been deactivated, but there is still an immediate and serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised.","Attention! Code Red!")
				security_level = SEC_LEVEL_RED

				var/obj/machinery/door/airlock/highsecurity/red/R = locate(/obj/machinery/door/airlock/highsecurity/red) in world
				if(R && is_station_level(R.z))
					R.locked = 0
					R.update_icon()

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "redalert")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_red")

			if(SEC_LEVEL_GAMMA)
				security_announcement_up.Announce("Central Command has ordered the Gamma security level on the station. Security is to have weapons equipped at all times, and all civilians are to immediately seek their nearest head for transportation to a secure location. The station's Gamma armory has been unlocked and is ready for use.","Attention! Gamma security level activated!")
				security_level = SEC_LEVEL_GAMMA

				move_gamma_ship()

				if(security_level < SEC_LEVEL_RED)
					for(var/obj/machinery/door/airlock/highsecurity/red/R in airlocks)
						if(is_station_level(R.z))
							R.locked = 0
							R.update_icon()

				for(var/obj/machinery/door/airlock/hatch/gamma/H in airlocks)
					if(is_station_level(H.z))
						H.locked = 0
						H.update_icon()

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "gammaalert")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_gamma")
						FA.update_icon()

			if(SEC_LEVEL_EPSILON)
				security_announcement_up.Announce("Central Command has ordered the Epsilon security level on the station. Consider all contracts terminated.","Attention! Epsilon security level activated!")
				security_level = SEC_LEVEL_EPSILON

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "epsilonalert")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_epsilon")

			if(SEC_LEVEL_DELTA)
				security_announcement_up.Announce("The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.","Attention! Delta security level reached!")
				security_level = SEC_LEVEL_DELTA

				var/obj/machinery/computer/communications/CC = locate(/obj/machinery/computer/communications,world)
				if(CC)
					CC.post_status("alert", "deltaalert")

				for(var/obj/machinery/firealarm/FA in world)
					if(is_station_contact(FA.z))
						FA.overlays = list()
						FA.overlays += image('icons/obj/monitors.dmi', "overlay_delta")

	else
		return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(var/num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_GAMMA)
			return "gamma"
		if(SEC_LEVEL_EPSILON)
			return "epsilon"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(var/seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("gamma")
			return SEC_LEVEL_GAMMA
		if("epsilon")
			return SEC_LEVEL_EPSILON
		if("delta")
			return SEC_LEVEL_DELTA


/*DEBUG
/mob/verb/set_thing0()
	set_security_level(0)
/mob/verb/set_thing1()
	set_security_level(1)
/mob/verb/set_thing2()
	set_security_level(2)
/mob/verb/set_thing3()
	set_security_level(3)
*/
