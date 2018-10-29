/datum/computer_file/program/aidiag
	filename = "aidiag"
	filedesc = "AI Maintenance Utility"
	program_icon_state = "generic"
	extended_desc = "This program is capable of reconstructing damaged AI systems. Requires direct AI connection via intellicard slot."
	size = 12
	requires_ntnet = 0
	usage_flags = PROGRAM_CONSOLE
	transfer_access = access_heads
	available_on_ntnet = 1
	var/restoring = FALSE

/datum/computer_file/program/aidiag/proc/get_ai(cardcheck)

	var/obj/item/computer_hardware/ai_slot/ai_slot

	if(computer)
		ai_slot = computer.all_components[MC_AI]

	if(computer && ai_slot && ai_slot.check_functionality())
		if(cardcheck == 1)
			return ai_slot
		if(ai_slot.enabled && ai_slot.stored_card)
			if(cardcheck == 2)
				return ai_slot.stored_card
			if(locate(/mob/living/silicon/ai) in ai_slot.stored_card)
				return locate(/mob/living/silicon/ai) in ai_slot.stored_card

	return null

/datum/computer_file/program/aidiag/Topic(href, list/href_list)
	if(..())
		return TRUE

	var/mob/living/silicon/ai/A = get_ai()
	if(!A)
		restoring = FALSE

	switch(href_list["action"])
		if("PRG_beginReconstruction")
			if(A && A.health < 100)
				restoring = TRUE
			return TRUE
		if("PRG_eject")
			if(computer.all_components[MC_AI])
				var/obj/item/computer_hardware/ai_slot/ai_slot = computer.all_components[MC_AI]
				if(ai_slot && ai_slot.stored_card)
					ai_slot.try_eject(0,usr)
					return TRUE

/datum/computer_file/program/aidiag/process_tick()
	..()
	if(!restoring)	//Put the check here so we don't check for an ai all the time
		return
	var/obj/item/aicard/cardhold = get_ai(2)

	var/obj/item/computer_hardware/ai_slot/ai_slot = get_ai(1)


	var/mob/living/silicon/ai/A = get_ai()
	if(!A || !cardhold)
		restoring = FALSE	// If the AI was removed, stop the restoration sequence.
		if(ai_slot)
			ai_slot.locked = FALSE
		return

	if(cardhold.flush)
		ai_slot.locked = FALSE
		restoring = FALSE
		return
	ai_slot.locked = TRUE
	A.adjustOxyLoss(-1)
	A.adjustFireLoss(-1)
	A.adjustToxLoss(-1)
	A.adjustBruteLoss(-1)
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.stat = CONSCIOUS
		A.lying = 0
		GLOB.dead_mob_list -= A
		GLOB.living_mob_list += A
	// Finished restoring
	if(A.health >= 100)
		ai_slot.locked = FALSE
		restoring = FALSE

	return TRUE


/datum/computer_file/program/aidiag/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/silicon/ai/AI
	// A shortcut for getting the AI stored inside the computer. The program already does necessary checks.
	AI = get_ai()

	var/obj/item/aicard/aicard = get_ai(2)

	if(!aicard)
		data["nocard"] = TRUE
		data["error"] = "Please insert an intelliCard."
	else
		if(!AI)
			data["error"] = "No AI located"
		else
			var/obj/item/aicard/cardhold = AI.loc
			if(cardhold.flush)
				data["error"] = "Flush in progress"
			else
				data["name"] = AI.name
				data["restoring"] = restoring
				data["health"] = (AI.health + 100) / 2
				data["isDead"] = AI.stat == DEAD

				var/list/all_laws[0]
				for(var/datum/ai_law/L in AI.laws.all_laws())
					all_laws.Add(list(list(
					"index" = L.index,
					"text" = L.law
					)))

				data["ai_laws"] = all_laws

	return data

/datum/computer_file/program/aidiag/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/headers)
		assets.send(user)
		ui = new(user, src, ui_key, "ai_restorer.tmpl", "Integrity Restorer", 600, 400)
		ui.set_auto_update(1)
		ui.set_layout_key("program")
		ui.open()

/datum/computer_file/program/aidiag/kill_program(forced)
	restoring = FALSE
	return ..(forced)