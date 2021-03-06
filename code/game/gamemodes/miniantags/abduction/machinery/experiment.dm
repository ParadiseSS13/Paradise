/obj/machinery/abductor/experiment
	name = "experimentation machine"
	desc = "A large man-sized tube sporting a complex array of surgical apparatus."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "experiment-open"
	anchored = TRUE
	density = TRUE
	occupy_whitelist = list(/mob/living/carbon/human)
	var/points = 0
	var/credits = 0
	var/list/history = list()
	var/list/abductee_minds = list()
	var/flash = " - || - "
	var/obj/machinery/abductor/console/console

/obj/machinery/abductor/experiment/attack_hand(mob/user)
	if(..())
		return

	experimentUI(user)

/obj/machinery/abductor/experiment/proc/dissection_icon(mob/living/carbon/human/H)
	var/icon/I = icon(H.stand_icon)

	var/icon/splat = icon(H.dna.species.damage_overlays, "30")
	splat.Blend(icon(H.dna.species.damage_mask, "torso"), ICON_MULTIPLY)
	splat.Blend(H.dna.species.blood_color, ICON_MULTIPLY)
	I.Blend(splat, ICON_OVERLAY)

	return I

/obj/machinery/abductor/experiment/proc/experimentUI(mob/user)
	var/dat
	dat += "<h3> Experiment </h3>"
	if(occupant)
		var/icon/H = icon(dissection_icon(occupant), dir = SOUTH)
		if(H)
			user << browse_rsc(H, "dissection_img.png")
			dat += "<table><tr><td>"
			dat += "<img src='dissection_img.png' height='80' width='80'>"
			dat += "</td><td>"
		else
			dat += "ERR: Unable to retrieve image data for occupant."
		dat += "<a href='?src=[UID()];experiment=1'>Probe</a><br>"
		dat += "<a href='?src=[UID()];experiment=2'>Dissect</a><br>"
		dat += "<a href='?src=[UID()];experiment=3'>Analyze</a><br>"
		dat += "</td></tr></table>"
	else
		dat += "<span class='linkOff'>Experiment </span>"

	if(!occupant)
		dat += "<h3>Machine Unoccupied</h3>"
	else
		dat += "<h3>Subject Status : </h3>"
		dat += "[occupant.name] => "
		switch(occupant.stat)
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>Deceased</span>"
	dat += "<br>"
	dat += "[flash]"
	dat += "<br>"
	dat += "<a href='?src=[UID()];refresh=1'>Scan</a>"
	dat += "<a href='?src=[UID()];[occupant ? "eject=1'>Eject Occupant</a>" : "unoccupied=1'>Unoccupied</a>"]"
	var/datum/browser/popup = new(user, "experiment", "Probing Console", 300, 300)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/experiment/Topic(href, href_list)
	if(..() || usr == occupant)
		return
	usr.set_machine(src)
	if(href_list["refresh"])
		updateUsrDialog()
		return
	if(href_list["eject"])
		unoccupy(usr)
		return
	if(occupant && occupant.stat != DEAD)
		if(href_list["experiment"])
			flash = Experiment(occupant,href_list["experiment"])
	updateUsrDialog()
	add_fingerprint(usr)

/obj/machinery/abductor/experiment/proc/Experiment(mob/occupant,type)
	var/mob/living/carbon/human/H = occupant
	var/point_reward = 0
	if(H in history)
		return "<span class='bad'>Specimen already in database.</span>"
	if(H.stat == DEAD)
		atom_say("Specimen deceased - please provide fresh sample.")
		return "<span class='bad'>Specimen deceased.</span>"
	var/obj/item/organ/internal/heart/gland/GlandTest = locate() in H.internal_organs
	if(!GlandTest)
		atom_say("Experimental dissection not detected!")
		return "<span class='bad'>No glands detected!</span>"
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
		var/objtype = pick(subtypesof(/datum/objective/abductee/))
		var/datum/objective/abductee/O = new objtype()
		SSticker.mode.abductees += H.mind
		H.mind.objectives += O
		var/obj_count = 1
		to_chat(H, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in H.mind.objectives)
			to_chat(H, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
		SSticker.mode.update_abductor_icons_added(H.mind)

		for(var/obj/item/organ/internal/heart/gland/G in H.internal_organs)
			G.Start()
			point_reward++
		if(point_reward > 0)
			unoccupy(force = TRUE)
			SendBack(H)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			points += point_reward
			credits += point_reward
			return "<span class='good'>Experiment successful! [point_reward] new data-points collected.</span>"
		else
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 1)
			return "<span class='bad'>Experiment failed! No replacement organ detected.</span>"
	else
		atom_say("Brain activity nonexistant - disposing sample...")
		unoccupy(force = TRUE)
		SendBack(H)
		return "<span class='bad'>Specimen braindead - disposed.</span>"


/obj/machinery/abductor/experiment/proc/SendBack(mob/living/carbon/human/H)
	H.Sleeping(8)
	if(console && console.pad && console.pad.teleport_target)
		H.forceMove(console.pad.teleport_target)
		H.uncuff()
		return
	//Area not chosen / It's not safe area - teleport to arrivals
	H.forceMove(pick(GLOB.latejoin))
	H.uncuff()
	return

/obj/machinery/abductor/experiment/can_occupy(mob/living/M, mob/user)
	if(isabductor(M))
		return FALSE
	return ..()

/obj/machinery/abductor/experiment/occupy(mob/living/M, mob/user)
	. = ..()
	if(.)
		icon_state = "experiment"

/obj/machinery/abductor/experiment/unoccupy(mob/user, force)
	. = ..()
	if(.)
		icon_state = "experiment-open"
