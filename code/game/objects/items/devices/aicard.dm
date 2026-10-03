/obj/item/aicard
	name = "intelliCard"
	desc = "A handy pocket card used to extract an artificial intelligence for transport."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "aicard" // aicard-full
	worn_icon_state = "electronic"
	inhand_icon_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	flags = NOBLUDGEON
	var/flush = null
	origin_tech = "programming=3;materials=3"
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 200)
	new_attack_chain = TRUE
	var/mob/living/silicon/ai/held_ai

/obj/item/aicard/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!target)
		return NONE

	if(!(istype(target, /obj/machinery/computer/aifixer) || \
		istype(target, /obj/structure/ai_core) || \
		istype(target, /obj/mecha) || \
		istype(target, /obj/structure/mecha_wreckage) || \
		istype(target, /mob/living/silicon/ai) || \
		istype(target, /obj/machinery/computer/emergency_shuttle)
	))
		return NONE

	if(held_ai) // AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, held_ai, src)
		add_attack_logs(user, held_ai, "Carded with [src]")

	else // No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)
		if(held_ai)
			held_ai.cancel_camera() // AI are forced to move when transferred, so do this whenever one is downloaded.

	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS) // Whatever happened, update the card's state (icon, name) to match.
	return ITEM_INTERACT_COMPLETE

/obj/item/aicard/update_name()
	. = ..()
	name = "intelliCard"
	if(held_ai)
		name += " - [held_ai.name]"

/obj/item/aicard/update_overlays()
	. = ..()
	if(held_ai)
		var/list/aicard_icon_state_names = icon_states(icon)
		var/aicard_new_display = held_ai.icon_state

		if(aicard_new_display in aicard_icon_state_names)
			. += aicard_new_display
		else if(held_ai.stat == DEAD)
			. += "ai_dead"
		else
			. += "ai"

/obj/item/aicard/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	ui_interact(user)
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/aicard/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/aicard/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AICard", "[name]")
		ui.open()

/obj/item/aicard/ui_data(mob/user)
	var/list/data = list()

	if(istype(held_ai))
		data["has_ai"] = TRUE
		data["name"] = held_ai.name
		data["integrity"] = ((held_ai.health + 100) / 2)
		data["radio"] = !held_ai.aiRadio.disabledAi
		data["wireless"] = !held_ai.control_disabled
		data["operational"] = held_ai.stat != DEAD
		data["flushing"] = flush

		var/laws[0]
		for(var/datum/ai_law/law in held_ai.laws.all_laws())
			if(law in held_ai.laws.ion_laws) // If we're an ion law, give it an ion index code
				laws.Add(ionnum() + ". " + law.law)
			else
				laws.Add(num2text(law.get_index()) + ". " + law.law)
		data["laws"] = laws
		data["has_laws"] = length(held_ai.laws.all_laws())

	else
		data["has_ai"] = FALSE // If this isn't passed to tgui, it won't show there isn't a AI in the card.

	return data

/obj/item/aicard/ui_act(action, params)
	if(..())
		return

	if(!istype(held_ai))
		return

	var/user = usr
	switch(action)
		if("wipe")
			if(flush) // Don't doublewipe.
				to_chat(user, SPAN_WARNING("You are already wiping this AI!"))
				return
			var/confirm = tgui_alert(user, "Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", list("Yes", "No"))
			if(confirm == "Yes" && (ui_status(user, GLOB.inventory_state) == UI_INTERACTIVE)) // And make doubly sure they want to wipe (three total clicks)
				msg_admin_attack("[key_name_admin(user)] wiped [key_name_admin(held_ai)] with \the [src].", ATKLOG_FEW)
				add_attack_logs(user, held_ai, "Wiped with [src].")
				INVOKE_ASYNC(src, PROC_REF(wipe_ai))

		if("radio")
			held_ai.aiRadio.disabledAi = !held_ai.aiRadio.disabledAi
			to_chat(held_ai, SPAN_WARNING("Your Subspace Transceiver has been [held_ai.aiRadio.disabledAi ? "disabled" : "enabled"]!"))
			to_chat(user, SPAN_NOTICE("You [held_ai.aiRadio.disabledAi ? "disable" : "enable"] the AI's Subspace Transceiver."))

		if("wireless")
			held_ai.control_disabled = !held_ai.control_disabled
			to_chat(held_ai, SPAN_WARNING("Your wireless interface has been [held_ai.control_disabled ? "disabled" : "enabled"]!"))
			to_chat(user, SPAN_NOTICE("You [held_ai.control_disabled ? "disable" : "enable"] the AI's wireless interface."))
			update_icon()

	return TRUE

/obj/item/aicard/examine(mob/user)
	. = ..()
	if(!held_ai)
		return

	if(!GetComponent(/datum/component/ducttape) && held_ai.builtInCamera)
		. += SPAN_NOTICE("You see a small [held_ai]'s camera staring at you.")
		. += SPAN_NOTICE("You can use a <b>tape roll</b> on [src] to tape the camera lens.")

/obj/item/aicard/proc/wipe_ai()
	flush = TRUE
	held_ai.suiciding = TRUE
	to_chat(held_ai, "Your core files are being wiped!")
	while(held_ai && held_ai.stat != DEAD)
		held_ai.adjustOxyLoss(2)
		sleep(10)
	flush = FALSE

/obj/item/aicard/add_tape()
	if(!held_ai)
		return

	if(held_ai.cracked_camera)
		return // we dont crack camera if its already cracked

	QDEL_NULL(held_ai.builtInCamera)

/obj/item/aicard/remove_tape()
	if(!held_ai)
		return

	if(held_ai.cracked_camera)
		return // we dont fix camera if malf AI cracked it

	held_ai.builtInCamera = new /obj/machinery/camera/portable(held_ai)
	held_ai.builtInCamera.c_tag = held_ai.name
	held_ai.builtInCamera.network = list("SS13")
