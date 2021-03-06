/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "rd_key"
	icon_screen = "ai-fixer"
	circuit = /obj/item/circuitboard/aifixer
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_HEADS)
	var/mob/living/silicon/ai/ai_occupant = null
	var/active = 0

	light_color = LIGHT_COLOR_PURPLE

/obj/machinery/computer/aifixer/attackby(I as obj, user as mob, params)
	if(ai_occupant && istype(I, /obj/item/screwdriver))
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

/obj/machinery/computer/aifixer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AIFixer", name, 550, 500, master_ui, state)
		ui.open()

/obj/machinery/computer/aifixer/ui_data(mob/user)
	var/data[0]
	data["ai_occupant"] = (ai_occupant ? ai_occupant.name : null) // a null ai_occupant isn't passed on if this is below the if.
	if(ai_occupant)
		data["reference"] = "\ref[ai_occupant]"
		data["integrity"] = (ai_occupant.health+100)/2
		data["stat"] = ai_occupant.stat
		data["active"] = active
		data["wireless"] = ai_occupant.control_disabled
		data["radio"] = ai_occupant.aiRadio.disabledAi

		var/laws[0]
		for(var/datum/ai_law/law in ai_occupant.laws.all_laws())
			if(law in ai_occupant.laws.ion_laws) // If we're an ion law, give it an ion index code
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
			if(active) // Prevent from starting a fix while fixing.
				to_chat(usr, "<span class='warning'>You are already fixing this AI!</span>")
				return
			active = TRUE
			INVOKE_ASYNC(src, .proc/fix_ai)
			add_fingerprint(usr)

		if("wireless")
			ai_occupant.control_disabled = !ai_occupant.control_disabled

		if("radio")
			ai_occupant.aiRadio.disabledAi = !ai_occupant.aiRadio.disabledAi

	update_icon()
	return TRUE

/obj/machinery/computer/aifixer/proc/fix_ai() // Can we fix it? Probrably.
	while(ai_occupant.health < 100)
		ai_occupant.adjustOxyLoss(-1, FALSE)
		ai_occupant.adjustFireLoss(-1, FALSE)
		ai_occupant.adjustToxLoss(-1, FALSE)
		ai_occupant.adjustBruteLoss(-1, FALSE)
		ai_occupant.updatehealth()
		if(ai_occupant.health >= 0 && ai_occupant.stat == DEAD)
			ai_occupant.update_revive()
			ai_occupant.lying = FALSE
			update_icon()
		sleep(10)
	active = FALSE

/obj/machinery/computer/aifixer/update_icon()
	..()
	if(stat & (NOPOWER|BROKEN))
		return
	else
		var/overlay_layer = LIGHTING_LAYER+0.2 // +0.1 from the default computer overlays
		if(active)
			overlays += image(icon,"ai-fixer-on",overlay_layer)
		if(ai_occupant)
			switch(ai_occupant.stat)
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
		AI.forceMove(src)
		ai_occupant = AI
		AI.control_disabled = 1
		AI.aiRadio.disabledAi = 1
		to_chat(AI, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		update_icon()

	else //Uploading AI from terminal to card
		if(ai_occupant && !active)
			to_chat(ai_occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [ai_occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
			ai_occupant.forceMove(card)
			ai_occupant = null
			update_icon()
		else if(active)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: Reconstruction in progress.")
		else if(!ai_occupant)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: Unable to locate artificial intelligence.")

/obj/machinery/computer/aifixer/Destroy()
	if(ai_occupant)
		ai_occupant.ghostize()
		QDEL_NULL(ai_occupant)
	return ..()

/obj/machinery/computer/aifixer/emp_act()
	if(ai_occupant)
		ai_occupant.ghostize()
		QDEL_NULL(ai_occupant)
	else
		..()
