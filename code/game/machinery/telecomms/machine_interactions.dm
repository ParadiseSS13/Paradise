//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32


/*

	All telecommunications interactions:

*/


/obj/machinery/telecomms
	var/temp = "" // output message
	var/construct_op = 0


/obj/machinery/telecomms/attackby(obj/item/P as obj, mob/user as mob, params)

	// Using a multitool lets you access the receiver's interface
	if(istype(P, /obj/item/device/multitool))
		attack_hand(user)


	switch(construct_op)
		if(0)
			if(istype(P, /obj/item/weapon/screwdriver))
				to_chat(user, "You unfasten the bolts.")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op++
		if(1)
			if(istype(P, /obj/item/weapon/screwdriver))
				to_chat(user, "You fasten the bolts.")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				construct_op--
			if(istype(P, /obj/item/weapon/wrench))
				to_chat(user, "You dislodge the external plating.")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				construct_op++
		if(2)
			if(istype(P, /obj/item/weapon/wrench))
				to_chat(user, "You secure the external plating.")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				construct_op--
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
				to_chat(user, "You remove the cables.")
				construct_op++
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( user.loc )
				A.amount = 5
				stat |= BROKEN // the machine's been borked!
		if(3)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/A = P
				if(A.amount >= 5)
					to_chat(user, "You insert the cables.")
					A.amount -= 5
					if(A.amount <= 0)
						user.drop_item()
						qdel(A)
					construct_op--
					stat &= ~BROKEN // the machine's not borked anymore!
			if(istype(P, /obj/item/weapon/crowbar))
				to_chat(user, "You begin prying out the circuit board other components...")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				if(do_after(user,60, target = src))
					to_chat(user, "You finish prying out the components.")

					// Drop all the component stuff
					if(component_parts)
						for(var/obj/I in component_parts)
							if(I.reliability != 100 && crit_fail)
								I.crit_fail = 1
							I.loc = src.loc
					else
						// If the machine wasn't made during runtime, probably doesn't have components:
						// manually find the components and drop them!
						var/obj/item/weapon/circuitboard/C = new circuitboard
						for(var/I in C.req_components)
							for(var/i = 1, i <= C.req_components[I], i++)
								var/obj/item/s = new I
								s.loc = src.loc
								if(istype(s, /obj/item/stack/cable_coil))
									var/obj/item/stack/cable_coil/A = s
									A.amount = 1

						// Drop a circuit board too
						C.loc = src.loc

					// Create a machine frame and delete the current machine
					var/obj/machinery/constructable_frame/machine_frame/F = new
					F.loc = src.loc
					qdel(src)

/obj/machinery/telecomms/proc/formatInput(var/label,var/varname, var/input)
	var/value = vars[varname]
	if(!value || value=="")
		value="-----"
	return "<b>[label]:</b> <a href=\"?src=\ref[src];input=[varname]\">[value]</a>"

/obj/machinery/telecomms/attack_ai(var/mob/user as mob)
	attack_hand(user)

/obj/machinery/telecomms/attack_hand(var/mob/user as mob)
	update_multitool_menu(user)

/obj/machinery/telecomms/multitool_menu(var/mob/user,var/obj/item/device/multitool/P)
	// You need a multitool to use this, or be silicon
	if(!issilicon(user))
		// istype returns false if the value is null
		if(!istype(user.get_active_hand(), /obj/item/device/multitool))
			return

	if(stat & (BROKEN|NOPOWER))
		return

	var/dat

	dat = {"
		<p>[temp]</p>
		<p><b>Power Status:</b> <a href='?src=\ref[src];input=toggle'>[src.toggled ? "On" : "Off"]</a></p>"}
	if(on && toggled)
		dat += {"
			<p>[formatInput("Identification String","id","id")]</p>
			<p>[formatInput("Network","network","network")]</p>
			<p><b>Prefabrication:</b> [autolinkers.len ? "TRUE" : "FALSE"]</p>
		"}
		if(hide)
			dat += "<p>Shadow Link: ACTIVE</p>"

		//Show additional options for certain machines.
		dat += Options_Menu()

		dat += {"<h2>Linked Network Entities:</h2> <ol>"}
		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !src.hide)
				continue
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\telecomms\machine_interactions.dm:140: dat += "</ol>"
		dat += {"</ol>
			<h2>Filtering Frequencies:</h2>"}
		// END AUTOFIX
		i = 0
		if(length(freq_listening))
			dat += "<ul>"
			for(var/x in freq_listening)
				dat += "<li>[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a></li>"
			dat += "</ul>"
		else
			dat += "<li>NONE</li>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\machinery\telecomms\machine_interactions.dm:155: dat += "<br>  <a href='?src=\ref[src];input=freq'>\[Add Filter\]</a>"
		dat += {"<p><a href='?src=\ref[src];input=freq'>\[Add Filter\]</a></p>
			<hr />"}
		// END AUTOFIX

	return dat

/obj/machinery/telecomms/canLink(var/obj/O)
	return istype(O,/obj/machinery/telecomms)

/obj/machinery/telecomms/isLinkedWith(var/obj/O)
	return O != null && O in links

/obj/machinery/telecomms/getLink(var/idx)
	return (idx >= 1 && idx <= links.len) ? links[idx] : null

// Off-Site Relays
//
// You are able to send/receive signals from the station's z level (changeable in the STATION_Z #define) if
// the relay is on the telecomm satellite (changable in the TELECOMM_Z #define)


/obj/machinery/telecomms/relay/proc/toggle_level()

	var/turf/position = get_turf(src)

	// Toggle on/off getting signals from the station or the current Z level
	// TODO: Tie into space manager
	if(src.listening_level == ZLEVEL_STATION) // equals the station
		src.listening_level = position.z
		return 1
	else if(position.z == ZLEVEL_TELECOMMS)
		src.listening_level = ZLEVEL_STATION
		return 1
	return 0

// Returns a multitool from a user depending on their mobtype.

/obj/machinery/telecomms/proc/get_multitool(mob/user as mob)

	var/obj/item/device/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_hand(), /obj/item/device/multitool))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(isrobot(user) && in_range(user, src))
		if(istype(user.get_active_hand(), /obj/item/device/multitool))
			P = user.get_active_hand()
	return P

// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.

/obj/machinery/telecomms/proc/Options_Menu()
	return ""

/*
// Add an option to the processor to switch processing mode. (COMPRESS -> UNCOMPRESS or UNCOMPRESS -> COMPRESS)
/obj/machinery/telecomms/processor/Options_Menu()
	var/dat = "<br>Processing Mode: <A href='?src=\ref[src];process=1'>[process_mode ? "UNCOMPRESS" : "COMPRESS"]</a>"
	return dat
*/
// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return

/*
/obj/machinery/telecomms/processor/Options_Topic(href, href_list)

	if(href_list["process"])
		temp = "<font color = #666633>-% Processing mode changed. %-</font color>"
		src.process_mode = !src.process_mode
*/

// RELAY

/obj/machinery/telecomms/relay/Options_Menu()
	var/dat = ""
	if(src.z == ZLEVEL_TELECOMMS)
		dat += "<br>Signal Locked to Station: <A href='?src=\ref[src];change_listening=1'>[listening_level == ZLEVEL_STATION ? "TRUE" : "FALSE"]</a>"
	dat += "<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>"
	dat += "<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"
	return dat

/obj/machinery/telecomms/relay/Options_Topic(href, href_list)

	if(href_list["receive"])
		receiving = !receiving
		temp = "<font color = #666633>-% Receiving mode changed. %-</font color>"
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color = #666633>-% Broadcasting mode changed. %-</font color>"
	if(href_list["change_listening"])
		//Lock to the station OR lock to the current position!
		//You need at least two receivers and two broadcasters for this to work, this includes the machine.
		var/result = toggle_level()
		if(result)
			temp = "<font color = #666633>-% [src]'s signal has been successfully changed.</font color>"
		else
			temp = "<font color = #666633>-% [src] could not lock it's signal onto the station. Two broadcasters or receivers required.</font color>"

// BUS

/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=\ref[src];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat

/obj/machinery/telecomms/bus/Options_Topic(href, href_list)

	if(href_list["change_freq"])

		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(canAccess(usr))
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					change_frequency = newfreq
					temp = "<font color = #666633>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font color>"
			else
				change_frequency = 0
				temp = "<font color = #666633>-% Frequency changing deactivated %-</font color>"


/obj/machinery/telecomms/Topic(href, href_list)

	if(!issilicon(usr))
		if(!istype(usr.get_active_hand(), /obj/item/device/multitool))
			return

	if(stat & (BROKEN|NOPOWER))
		return

	var/obj/item/device/multitool/P = get_multitool(usr)

	if(href_list["input"])
		switch(href_list["input"])

			if("toggle")

				src.toggled = !src.toggled
				temp = "<font color = #666633>-% [src] has been [src.toggled ? "activated" : "deactivated"].</font color>"
				update_power()

			/*
			if("hide")
				src.hide = !hide
				temp = "<font color = #666633>-% Shadow Link has been [src.hide ? "activated" : "deactivated"].</font color>"
			*/

			if("id")
				var/newid = copytext(reject_bad_text(input(usr, "Specify the new ID for this machine", src, id) as null|text),1,MAX_MESSAGE_LEN)
				if(newid && canAccess(usr))
					id = newid
					temp = "<font color = #666633>-% New ID assigned: \"[id]\" %-</font color>"

			if("network")
				var/newnet = input(usr, "Specify the new network for this machine. This will break all current links.", src, network) as null|text
				if(newnet && canAccess(usr))

					if(length(newnet) > 15)
						temp = "<font color = #666633>-% Too many characters in new network tag %-</font color>"

					else
						for(var/obj/machinery/telecomms/T in links)
							T.links.Remove(src)

						network = newnet
						links = list()
						temp = "<font color = #666633>-% New network tag assigned: \"[network]\" %-</font color>"


			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && canAccess(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
					if(!(newfreq in freq_listening) && newfreq < 10000)
						freq_listening.Add(newfreq)
						temp = "<font color = #666633>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font color>"

	if(href_list["delete"])

		// changed the layout about to workaround a pesky runtime -- Doohl

		var/x = text2num(href_list["delete"])
		temp = "<font color = #666633>-% Removed frequency filter [x] %-</font color>"
		freq_listening.Remove(x)

	if(href_list["unlink"])

		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			temp = "<font color = #666633>-% Removed \ref[T] [T.name] from linked entities. %-</font color>"

			// Remove link entries from both T and src.

			if(src in T.links)
				T.links.Remove(src)
			links.Remove(T)

	if(href_list["link"])

		if(P)
			if(P.buffer && P.buffer != src)
				if(!(src in P.buffer:links))
					P.buffer:links.Add(src)

				if(!(P.buffer in src.links))
					src.links.Add(P.buffer)

				temp = "<font color = #666633>-% Successfully linked with \ref[P.buffer] [P.buffer.name] %-</font color>"

			else
				temp = "<font color = #666633>-% Unable to acquire buffer %-</font color>"

	if(href_list["buffer"])

		P.buffer = src
		temp = "<font color = #666633>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font color>"


	if(href_list["flush"])

		temp = "<font color = #666633>-% Buffer successfully flushed. %-</font color>"
		P.buffer = null

	src.Options_Topic(href, href_list)

	usr.set_machine(src)
	src.add_fingerprint(usr)

	updateUsrDialog()

/obj/machinery/telecomms/proc/canAccess(var/mob/user)
	if(issilicon(user) || in_range(user, src))
		return 1
	return 0
