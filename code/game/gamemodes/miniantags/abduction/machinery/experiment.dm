/obj/machinery/abductor/experiment
	name = "experimentation machine"
	desc = "A large man-sized tube sporting a complex array of surgical apparatus."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	anchored = TRUE
	density = TRUE
	var/points = 0
	var/credits = 0
	var/list/history = list()
	var/list/abductee_minds = list()
	var/flash = "Idle."
	var/obj/machinery/abductor/console/console
	var/mob/living/carbon/human/occupant
	COOLDOWN_DECLARE(spam_cooldown)

/obj/machinery/abductor/experiment/Destroy()
	eject_abductee()
	return ..()

/obj/machinery/abductor/experiment/update_icon_state()
	if(occupant)
		icon_state = "experiment"
	else
		icon_state = "experiment-open"

/obj/machinery/abductor/experiment/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	if(isabductor(target))
		return
	if(occupant)
		to_chat(user, "<span class='notice'>[src] is already occupied.</span>")
		return TRUE
	if(target.buckled)
		return
	if(target.has_buckled_mobs()) //mob attached to us
		to_chat(user, "<span class='warning'>[target] will not fit into [src] because [target.p_they()] [target.p_have()] a slime latched onto [target.p_their()] head.</span>")
		return TRUE
	visible_message("<span class='notice'>[user] puts [target] into [src].</span>")

	QDEL_LIST_CONTENTS(target.grabbed_by)
	target.forceMove(src)
	occupant = target
	flash = "Machine ready."
	update_icon(UPDATE_ICON_STATE)
	add_fingerprint(user)
	return TRUE

/obj/machinery/abductor/experiment/attack_hand(mob/user)
	if(!isabductor(user))
		to_chat(user, "<span class='warning'>You don't understand any of the alien writing!</span>")
		return
	ui_interact(user)

/obj/machinery/abductor/experiment/proc/dissection_icon(mob/living/carbon/human/H)
	var/icon/I = icon(H.stand_icon)

	var/icon/splat = icon(H.dna.species.damage_overlays, "30")
	splat.Blend(icon(H.dna.species.damage_mask, "torso"), ICON_MULTIPLY)
	splat.Blend(H.dna.species.blood_color, ICON_MULTIPLY)
	I.Blend(splat, ICON_OVERLAY)

	return I

/obj/machinery/abductor/experiment/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/abductor/experiment/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/abductor/experiment/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ExperimentConsole", name)
		ui.open()

/obj/machinery/abductor/experiment/ui_data(mob/user)
	var/list/data = list()
	data["open"] = occupant ? TRUE : FALSE
	data["feedback"] = flash
	data["occupant"] = occupant ? TRUE : FALSE
	data["occupant_name"] = null
	data["occupant_status"] = null
	if(occupant)
		var/mob/living/mob_occupant = occupant
		data["occupant_name"] = mob_occupant.name
		data["occupant_status"] = mob_occupant.stat
	return data

/obj/machinery/abductor/experiment/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("door")
			eject_abductee()
			flash = "Specimen ejected!"

		if("experiment")
			if(!occupant)
				return
			var/mob/living/mob_occupant = occupant
			if(mob_occupant.stat == DEAD)
				return
			flash = experiment(mob_occupant, params["experiment_type"], usr)
			return TRUE

/obj/machinery/abductor/experiment/proc/experiment(mob/occupant,type)
	var/mob/living/carbon/human/H = occupant
	var/point_reward = 0
	if(H in history)
		return "Specimen already in database."
	if(H.stat == DEAD)
		atom_say("Specimen deceased - please provide fresh sample.")
		return "Specimen deceased."
	var/obj/item/organ/internal/heart/gland/GlandTest = locate() in H.internal_organs
	if(!GlandTest)
		atom_say("Experimental dissection not detected!")
		return "No glands detected!"
	if(H.mind != null && H.ckey != null)
		history += H
		abductee_minds += H.mind
		atom_say("Processing specimen...")
		sleep(5)
		switch(text2num(type))
			if(1)
				to_chat(H, "<span class='warning'>You feel violated.</span>")
			if(2)
				to_chat(H, "<span class='warning'>You feel yourself being sliced apart and put back together.</span>")
			if(3)
				to_chat(H, "<span class='warning'>You feel intensely watched.</span>")
		sleep(5)
		to_chat(H, "<span class='warning'><b>Your mind snaps!</b></span>")
		to_chat(H, "<big><span class='warning'><b>You can't remember how you got here...</b></span></big>")
		SSticker.mode.abductees += H.mind

		var/objtype = pick(subtypesof(/datum/objective/abductee/))
		var/datum/objective/abductee/O = new objtype()
		H.mind.add_mind_objective(O)
		var/list/messages = H.mind.prepare_announce_objectives()
		to_chat(H, chat_box_red(messages.Join("<br>"))) // let the player know they have a new objective

		var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_ABDUCTOR]
		hud.join_hud(H)
		set_antag_hud(H, "abductee")

		for(var/obj/item/organ/internal/heart/gland/G in H.internal_organs)
			G.Start()
			point_reward++
		if(point_reward > 0)
			eject_abductee()
			send_back(H)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, TRUE)
			points += point_reward
			credits += point_reward
			return "Experiment successful! [point_reward] new data-points collected."
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
			return "Experiment failed! No replacement organ detected."
	else
		atom_say("Brain activity nonexistent - disposing sample...")
		eject_abductee()
		send_back(H)
		return "Specimen braindead - disposed."


/obj/machinery/abductor/experiment/proc/send_back(mob/living/carbon/human/H)
	H.Sleeping(16 SECONDS)
	if(console && console.pad && console.pad.teleport_target)
		H.forceMove(console.pad.teleport_target)
		H.clear_restraints()
		return
	//Area not chosen / It's not safe area - teleport to arrivals
	H.forceMove(pick(GLOB.latejoin))
	H.clear_restraints()
	return

/obj/machinery/abductor/experiment/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/grab))
		var/obj/item/grab/grabbed = used
		if(!ishuman(grabbed.affecting))
			return ITEM_INTERACT_COMPLETE
		if(isabductor(grabbed.affecting))
			return ITEM_INTERACT_COMPLETE
		if(occupant)
			to_chat(user, "<span class='notice'>[src] is already occupied!</span>")
			return ITEM_INTERACT_COMPLETE
		if(grabbed.affecting.has_buckled_mobs()) //mob attached to us
			to_chat(user, "<span class='warning'>[grabbed.affecting] will not fit into [src] because [grabbed.affecting.p_they()] [grabbed.affecting.p_have()] a slime latched onto [grabbed.affecting.p_their()] head.</span>")
			return ITEM_INTERACT_COMPLETE
		visible_message("<span class='notice'>[user] puts [grabbed.affecting] into [src].</span>")
		var/mob/living/carbon/human/H = grabbed.affecting
		H.forceMove(src)
		occupant = H
		flash = "Machine ready."
		update_icon(UPDATE_ICON_STATE)
		add_fingerprint(user)
		qdel(used)
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/abductor/experiment/ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)
	..()

/obj/machinery/abductor/experiment/handle_atom_del(atom/A)
	..()
	if(A == occupant)
		occupant = null
		updateUsrDialog()
		update_icon(UPDATE_ICON_STATE)

/obj/machinery/abductor/experiment/proc/eject_abductee()
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant = null
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/abductor/experiment/relaymove()
	if(!COOLDOWN_FINISHED(src, spam_cooldown))
		return

	COOLDOWN_START(src, spam_cooldown, 2 SECONDS)
	if(!occupant)
		return
	to_chat(occupant, "<span class='warning'>You start trying to break free!</span>")
	if(!do_after_once(occupant, 20 SECONDS, FALSE, src, hidden = TRUE))
		return
	var/list/possible_results = list(
		CALLBACK(src, PROC_REF(electrocute_abductee)) = 1,
		CALLBACK(src, PROC_REF(sedate_abductee)) = 1,
		CALLBACK(src, PROC_REF(eject_abductee)) = 2
	)
	var/datum/callback/result = pickweight(possible_results)
	result.Invoke()

/obj/machinery/abductor/experiment/proc/electrocute_abductee()
	if(!occupant)
		return
	to_chat(occupant, "<span class='warning'>Something is electrifying you!</span>")
	occupant.electrocute_act(10, src)
	do_sparks(5, TRUE, src)

/obj/machinery/abductor/experiment/proc/sedate_abductee()
	if(!occupant)
		return
	to_chat(occupant, "<span class='warning'>Something is stabbing you in the back!</span>")
	occupant.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
	occupant.reagents.add_reagent("pancuronium", 3)

/obj/machinery/abductor/experiment/force_eject_occupant(mob/target)
	eject_abductee()

/obj/machinery/abductor/experiment/broken
	stat = BROKEN

/obj/machinery/abductor/experiment/broken/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	return
