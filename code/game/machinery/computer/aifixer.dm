/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "ai-fixer"
	circuit = /obj/item/circuitboard/aifixer
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_HEADS)
	var/mob/living/silicon/ai/occupant = null
	var/active = FALSE

	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/aifixer/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		if(stat & BROKEN)
			return ..()
		if(stat & NOPOWER)
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge.</span>")
		else
			to_chat(user, "<span class='warning'>The screws on [name]'s screen won't budge and it emits a warning beep!.</span>")
		return TRUE
	else
		return ..()

/obj/machinery/computer/aifixer/attack_ai(mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/aifixer/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/aifixer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AIFixer", name, 550, 500, master_ui, state)
		ui.open()

/obj/machinery/computer/aifixer/ui_data(mob/user)
	var/data[0]
	data["occupant"] = (occupant ? occupant.name : null) // a null occupant isn't passed on if this is below the if.
	if(occupant)
		data["reference"] = "\ref[occupant]"
		data["integrity"] = (occupant.health+100)/2
		data["stat"] = occupant.stat
		data["active"] = active
		data["wireless"] = occupant.control_disabled
		data["radio"] = occupant.aiRadio.disabledAi

		var/laws[0]
		for(var/datum/ai_law/law in occupant.laws.all_laws())
			if(law in occupant.laws.ion_laws) // If we're an ion law, give it an ion index code
				laws.Add(ionnum() + ". " + law.law)
			else
				laws.Add(num2text(law.get_index()) + ". " + law.law)
		data["laws"] = laws
		data["has_laws"] = length(laws)

	return data

/obj/machinery/computer/aifixer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("fix")
			if(occupant.suiciding)
				to_chat(usr, "<span class='warning'>Memory corruption detected in recovery partition, likely due to a sudden self-induced shutdown. AI is unrecoverable.</span>")
				return
			if(active) // Prevent from starting a fix while fixing.
				to_chat(usr, "<span class='warning'>You are already fixing this AI!</span>")
				return
			active = TRUE
			INVOKE_ASYNC(src, PROC_REF(fix_ai))
			add_fingerprint(usr)

		if("wireless")
			occupant.control_disabled = !occupant.control_disabled

		if("radio")
			occupant.aiRadio.disabledAi = !occupant.aiRadio.disabledAi

	update_icon(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/computer/aifixer/proc/fix_ai() // Can we fix it? Probrably.
	while(occupant.health < 100 || occupant.stat == DEAD)
		occupant.adjustOxyLoss(-1, FALSE)
		occupant.adjustFireLoss(-1, FALSE)
		occupant.adjustToxLoss(-1, FALSE)
		occupant.adjustBruteLoss(-1, FALSE)
		occupant.updatehealth()
		if(occupant.health >= 0 && occupant.stat == DEAD)
			occupant.update_revive()
			update_icon(UPDATE_OVERLAYS)
		sleep(10)
	active = FALSE

/obj/machinery/computer/aifixer/update_overlays()
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		return
	if(active)
		. += "ai-fixer-on"
	if(occupant)
		switch(occupant.stat)
			if(0)
				. += "ai-fixer-full"
			if(2)
				. += "ai-fixer-404"
	else
		. += "ai-fixer-empty"

/obj/machinery/computer/aifixer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(stat & (NOPOWER|BROKEN))
			to_chat(user, "[src] is offline and cannot take an AI at this time!")
			return
		AI.forceMove(src)
		occupant = AI
		AI.control_disabled = TRUE
		AI.aiRadio.disabledAi = TRUE
		to_chat(AI, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		update_icon(UPDATE_OVERLAYS)

	else //Uploading AI from terminal to card
		if(occupant && !active)
			to_chat(occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
			occupant.forceMove(card)
			occupant = null
			update_icon(UPDATE_OVERLAYS)
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
