/obj/machinery/computer/aifixer
	name = "AI System Integrity Restorer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "ai-fixer"
	circuit = /obj/item/weapon/circuitboard/aifixer
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/aifixer/attackby(I as obj, user as mob, params)
	if(occupant && istype(I, /obj/item/weapon/screwdriver))
		if(stat & (NOPOWER|BROKEN))
			user << "<span class='warning'>The screws on [name]'s screen won't budge.</span>"
		else
			user << "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep.</span>"
		return
	else
		..()
		
/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	return interact(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	if(..())
		return
		
	interact(user)

/obj/machinery/computer/aifixer/interact(mob/user)	
	var/dat = "<h3>AI System Integrity Restorer</h3><br><br>"

	if (src.occupant)
		var/laws
		dat += "Stored AI: [src.occupant.name]<br>System integrity: [(src.occupant.health+100)/2]%<br>"

		if (src.occupant.laws.zeroth)
			laws += "0: [src.occupant.laws.zeroth]<BR>"

		var/number = 1
		for (var/index = 1, index <= src.occupant.laws.inherent.len, index++)
			var/law = src.occupant.laws.inherent[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		for (var/index = 1, index <= src.occupant.laws.supplied.len, index++)
			var/law = src.occupant.laws.supplied[index]
			if (length(law) > 0)
				laws += "[number]: [law]<BR>"
				number++

		dat += "Laws:<br>[laws]<br>"

		if (src.occupant.stat == 2)
			dat += "<b>AI nonfunctional</b>"
		else
			dat += "<b>AI functional</b>"
		if (!src.active)
			dat += {"<br><br><A href='byond://?src=\ref[src];fix=1'>Begin Reconstruction</A>"}
		else
			dat += "<br><br>Reconstruction in process, please wait.<br>"
	dat += {" <A href='?src=\ref[user];mach_close=computer'>Close</A>"}

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return 1
	if (href_list["fix"])
		src.active = 1
		while (src.occupant.health < 100)
			src.occupant.adjustOxyLoss(-1)
			src.occupant.adjustFireLoss(-1)
			src.occupant.adjustToxLoss(-1)
			src.occupant.adjustBruteLoss(-1)
			src.occupant.updatehealth()
			if (src.occupant.health >= 0 && src.occupant.stat == 2)
				src.occupant.stat = 0
				src.occupant.lying = 0
				dead_mob_list -= src.occupant
				living_mob_list += src.occupant
			src.updateUsrDialog()
			sleep(10)
		src.active = 0
		src.add_fingerprint(usr)
	src.updateUsrDialog()
	update_icon()
	return

/obj/machinery/computer/aifixer/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	else
		var/overlay_layer = LIGHTING_LAYER+0.2 // +0.1 from the default computer overlays
		if(active)
			overlays += image(icon,"ai-fixer-on",overlay_layer) 
		if (occupant)
			switch (occupant.stat)
				if (0)
					overlays += image(icon,"ai-fixer-full",overlay_layer) 
				if (2)
					overlays += image(icon,"ai-fixer-404",overlay_layer) 
		else
			overlays += image(icon,"ai-fixer-empty",overlay_layer) 
			
/obj/machinery/computer/aifixer/transfer_ai(var/interaction, var/mob/user, var/mob/living/silicon/ai/AI, var/obj/item/device/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(stat & (NOPOWER|BROKEN))
			user << "[src] is offline and cannot take an AI at this time!"
			return
		AI.loc = src
		occupant = AI
		AI.control_disabled = 1
		AI.aiRadio.disabledAi = 1 
		AI << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
		user << "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."
		update_icon()

	else //Uploading AI from terminal to card
		if(occupant && !active)
			occupant << "You have been downloaded to a mobile storage device. Still no remote access."
			user << "<span class='boldnotice'>Transfer successful</span>: [occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
			occupant.loc = card
			occupant = null
			update_icon()
		else if (active)
			user << "<span class='boldannounce'>ERROR</span>: Reconstruction in progress."
		else if (!occupant)
			user << "<span class='boldannounce'>ERROR</span>: Unable to locate artificial intelligence."
			