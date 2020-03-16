/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "ai-fixer"
	circuit = /obj/item/circuitboard/aifixer
	req_access = list(access_captain, access_robotics, access_heads)
	var/mob/living/silicon/ai/occupant = null
	var/active = 0

	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/aifixer/attackby(I as obj, user as mob, params)
	if(occupant && istype(I, /obj/item/screwdriver))
		if(stat & BROKEN)
			..()
		if(stat & NOPOWER)
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge.</span>")
		else
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep!.</span>")
	else
		return ..()

/obj/machinery/computer/aifixer/attack_ai(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/aifixer/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/aifixer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "ai_fixer.tmpl", "AI System Integrity Restorer", 550, 500)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/aifixer/ui_data(mob/user, datum/topic_state/state)
	var/data[0]
	if(occupant)
		data["occupant"] = occupant.name
		data["reference"] = "\ref[occupant]"
		data["integrity"] = (occupant.health+100)/2
		data["stat"] = occupant.stat
		data["active"] = active
		data["wireless"] = occupant.control_disabled
		data["radio"] = occupant.aiRadio.disabledAi

		var/laws[0]
		for(var/datum/ai_law/law in occupant.laws.all_laws())
			laws.Add(list(list("law" = law.law, "number" = law.get_index())))

		data["laws"] = laws

	return data

/obj/machinery/computer/aifixer/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["fix"])
		active = 1
		while(occupant.health < 100)
			occupant.adjustOxyLoss(-1, FALSE)
			occupant.adjustFireLoss(-1, FALSE)
			occupant.adjustToxLoss(-1, FALSE)
			occupant.adjustBruteLoss(-1, FALSE)
			occupant.updatehealth()
			if(occupant.health >= 0 && occupant.stat == DEAD)
				occupant.update_revive()
				occupant.lying = 0
				update_icon()
			sleep(10)
		active = 0
		add_fingerprint(usr)

	if(href_list["wireless"])
		var/wireless = text2num(href_list["wireless"])
		if(wireless == 0 || wireless == 1)
			occupant.control_disabled = wireless

	if(href_list["radio"])
		var/radio = text2num(href_list["radio"])
		if(radio == 0 || radio == 1)
			occupant.aiRadio.disabledAi = radio

	SSnanoui.update_uis(src)
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
		if(occupant)
			switch(occupant.stat)
				if(0)
					overlays += image(icon,"ai-fixer-full",overlay_layer)
				if(2)
					overlays += image(icon,"ai-fixer-404",overlay_layer)
		else
			overlays += image(icon,"ai-fixer-empty",overlay_layer)

/obj/machinery/computer/aifixer/transfer_ai(var/interaction, var/mob/user, var/mob/living/silicon/ai/AI, var/obj/item/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "[src] is offline and cannot take an AI at this time!")
			return
		AI.loc = src
		occupant = AI
		AI.control_disabled = 1
		AI.aiRadio.disabledAi = 1
		to_chat(AI, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		update_icon()

	else //Uploading AI from terminal to card
		if(occupant && !active)
			to_chat(occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
			occupant.loc = card
			occupant = null
			update_icon()
		else if(active)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: Reconstruction in progress.")
		else if(!occupant)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: Unable to locate artificial intelligence.")

/obj/machinery/computer/aifixer/Destroy()
	if(occupant)
		occupant.ghostize()
		QDEL_NULL(occupant)
	return ..()

/obj/machinery/computer/aifixer/emp_act()
	if(occupant)
		occupant.ghostize()
		QDEL_NULL(occupant)
	else
		..()
