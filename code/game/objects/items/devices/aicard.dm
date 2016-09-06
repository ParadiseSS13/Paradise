/obj/item/device/aicard
	name = "inteliCard"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2
	slot_flags = SLOT_BELT
	flags = NOBLUDGEON
	var/flush = null
	origin_tech = "programming=4;materials=4"


/obj/item/device/aicard/afterattack(atom/target, mob/user, proximity)
	..()
	if(!proximity || !target)
		return
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_logs(user, AI, "carded", object="[name]")
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
	update_state() //Whatever happened, update the card's state (icon, name) to match.

/obj/item/device/aicard/proc/update_state()
	var/mob/living/silicon/ai/AI = locate(/mob/living/silicon/ai) in src //AI is inside.
	if(AI)
		name = "intelliCard - [AI.name]"
		if(AI.stat == DEAD)
			icon_state = "aicard-404"
		else
			icon_state = "aicard-full"
		AI.cancel_camera() //AI are forced to move when transferred, so do this whenver one is downloaded.
	else
		icon_state = "aicard"
		name = "intelliCard"
		overlays.Cut()

/obj/item/device/aicard/attack_self(mob/user)
	ui_interact(user)


/obj/item/device/aicard/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = inventory_state)
	var/data[0]

	var/mob/living/silicon/ai/AI = locate() in src
	if(istype(AI))
		data["has_ai"] = 1
		data["name"] = AI.name
		data["hardware_integrity"] = ((AI.health + 100) / 2)
		data["radio"] = !AI.aiRadio.disabledAi
		data["wireless"] = !AI.control_disabled
		data["operational"] = AI.stat != DEAD
		data["flushing"] = flush

		var/laws[0]
		for(var/datum/ai_law/AL in AI.laws.all_laws())
			laws[++laws.len] = list("index" = AL.get_index(), "law" = sanitize(AL.law))
		data["laws"] = laws
		data["has_laws"] = laws.len

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "aicard.tmpl", "[name]", 600, 400, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)


/obj/item/device/aicard/Topic(href, href_list, nowindow, state)
	if(..())
		return 1

	var/mob/living/silicon/ai/AI = locate() in src
	if(!istype(AI))
		return 1

	var/user = usr

	if(href_list["wipe"])
		var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
		if(confirm == "Yes" && (CanUseTopic(user, state) == STATUS_INTERACTIVE))
			msg_admin_attack("[key_name_admin(user)] wiped [key_name_admin(AI)] with \the [src].")
			flush = 1
			AI.suiciding = 1
			to_chat(AI, "Your core files are being wiped!")
			while(AI && AI.stat != DEAD)
				AI.adjustOxyLoss(2)
				AI.updatehealth()
				sleep(10)
			flush = 0

	if(href_list["radio"])
		AI.aiRadio.disabledAi = text2num(href_list["radio"])
		to_chat(AI, "<span class='warning'>Your Subspace Transceiver has been [AI.aiRadio.disabledAi ? "disabled" : "enabled"]!</span>")
		to_chat(user, "<span class='notice'>You [AI.aiRadio.disabledAi ? "disable" : "enable"] the AI's Subspace Transceiver.</span>")

	if(href_list["wireless"])
		AI.control_disabled = text2num(href_list["wireless"])
		to_chat(AI, "<span class='warning'>Your wireless interface has been [AI.control_disabled ? "disabled" : "enabled"]!</span>")
		to_chat(user, "<span class='notice'>You [AI.control_disabled ? "disable" : "enable"] the AI's wireless interface.</span>")
		update_icon()

	return 1

/obj/item/device/aicard/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50)) qdel(src)
		if(3.0)
			if(prob(25)) qdel(src)
