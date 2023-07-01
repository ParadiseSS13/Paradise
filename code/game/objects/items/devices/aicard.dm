/obj/item/aicard
	name = "inteliCard"
	desc = "A handy pocket card used to extract an artificial intelligence for transport."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	flags = NOBLUDGEON
	var/flush = null
	origin_tech = "programming=3;materials=3"

/obj/item/aicard/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_attack_logs(user, AI, "Carded with [src]")
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	update_state() //Whatever happened, update the card's state (icon, name) to match.

/obj/item/aicard/proc/update_state()
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src //AI is inside.
	update_icon(UPDATE_OVERLAYS)
	if(AI)
		name = "intelliCard - [AI.name]"
		AI.cancel_camera() //AI are forced to move when transferred, so do this whenver one is downloaded.
	else
		name = "intelliCard"

/obj/item/aicard/update_overlays()
	. = ..()
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src //AI is inside.
	if(AI)
		var/list/aicard_icon_state_names = icon_states(icon)
		var/aicard_new_display = AI.icon_state

		if(aicard_new_display in aicard_icon_state_names)
			. += aicard_new_display
		else if(AI.stat == DEAD)
			. += "ai_dead"
		else
			. += "ai"

/obj/item/aicard/attack_self(mob/user)
	ui_interact(user)

/obj/item/aicard/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "AICard", "[name]", 600, 394,  master_ui, state)
		ui.open()

/obj/item/aicard/ui_data(mob/user)
	var/list/data = list()

	var/mob/living/silicon/ai/AI = locate() in src
	if(istype(AI))
		data["has_ai"] = TRUE
		data["name"] = AI.name
		data["integrity"] = ((AI.health + 100) / 2)
		data["radio"] = !AI.aiRadio.disabledAi
		data["wireless"] = !AI.control_disabled
		data["operational"] = AI.stat != DEAD
		data["flushing"] = flush

		var/laws[0]
		for(var/datum/ai_law/law in AI.laws.all_laws())
			if(law in AI.laws.ion_laws) // If we're an ion law, give it an ion index code
				laws.Add(ionnum() + ". " + law.law)
			else
				laws.Add(num2text(law.get_index()) + ". " + law.law)
		data["laws"] = laws
		data["has_laws"] = length(AI.laws.all_laws())

	else
		data["has_ai"] = FALSE // If this isn't passed to tgui, it won't show there isn't a AI in the card.

	return data

/obj/item/aicard/ui_act(action, params)
	if(..())
		return

	var/mob/living/silicon/ai/AI = locate() in src
	if(!istype(AI))
		return

	var/user = usr
	switch(action)
		if("wipe")
			if(flush) // Don't doublewipe.
				to_chat(user, "<span class='warning'>You are already wiping this AI!</span>")
				return
			var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
			if(confirm == "Yes" && (ui_status(user, GLOB.inventory_state) == STATUS_INTERACTIVE)) // And make doubly sure they want to wipe (three total clicks)
				msg_admin_attack("[key_name_admin(user)] wiped [key_name_admin(AI)] with \the [src].", ATKLOG_FEW)
				add_attack_logs(user, AI, "Wiped with [src].")
				INVOKE_ASYNC(src, PROC_REF(wipe_ai))

		if("radio")
			AI.aiRadio.disabledAi = !AI.aiRadio.disabledAi
			to_chat(AI, "<span class='warning'>Your Subspace Transceiver has been [AI.aiRadio.disabledAi ? "disabled" : "enabled"]!</span>")
			to_chat(user, "<span class='notice'>You [AI.aiRadio.disabledAi ? "disable" : "enable"] the AI's Subspace Transceiver.</span>")

		if("wireless")
			AI.control_disabled = !AI.control_disabled
			to_chat(AI, "<span class='warning'>Your wireless interface has been [AI.control_disabled ? "disabled" : "enabled"]!</span>")
			to_chat(user, "<span class='notice'>You [AI.control_disabled ? "disable" : "enable"] the AI's wireless interface.</span>")
			update_icon()

	return TRUE

/obj/item/aicard/proc/wipe_ai()
	var/mob/living/silicon/ai/AI = locate() in src
	flush = TRUE
	AI.suiciding = TRUE
	to_chat(AI, "Your core files are being wiped!")
	while(AI && AI.stat != DEAD)
		AI.adjustOxyLoss(2)
		sleep(10)
	flush = FALSE

/obj/item/aicard/add_tape()
	var/mob/living/silicon/ai/AI = locate() in src
	if(!AI)
		return
	QDEL_NULL(AI.builtInCamera)

/obj/item/aicard/remove_tape()
	var/mob/living/silicon/ai/AI = locate() in src
	if(!AI)
		return
	AI.builtInCamera = new /obj/machinery/camera/portable(AI)
	AI.builtInCamera.c_tag = AI.name
	AI.builtInCamera.network = list("SS13")
