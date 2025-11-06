#define PRINT_TIMER 5 SECONDS

/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "autopsy_scanner"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=1;biotech=1"
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/chemtraces = list()
	var/target_name = null
	var/target_UID = null
	var/timeofdeath = null
	var/target_rank = null
	STATIC_COOLDOWN_DECLARE(print_cooldown)
	new_attack_chain = TRUE

/obj/item/autopsy_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(wdata)
	return ..()

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list()	// this maps a number of scanned organs to
										// the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(organs_scanned)
	return ..()

/datum/autopsy_data
	var/weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.damage = damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/obj/item/autopsy_scanner/proc/add_data(obj/item/organ/O)
	if(length(O.autopsy_data))
		for(var/V in O.autopsy_data)
			var/datum/autopsy_data/W = O.autopsy_data[V]

			var/datum/autopsy_data_scanner/D = wdata[V]
			if(!D)
				D = new()
				D.weapon = W.weapon
				wdata[V] = D

			if(!D.organs_scanned[O.name])
				if(D.organ_names == "")
					D.organ_names = O.name
				else
					D.organ_names += ", [O.name]"

			qdel(D.organs_scanned[O.name])
			D.organs_scanned[O.name] = W.copy()

	if(length(O.trace_chemicals))
		for(var/V in O.trace_chemicals)
			if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
				chemtraces += V

/obj/item/autopsy_scanner/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "<span class='notice'>You can use a pen on it to quickly write a coroner's report.</span>"

/obj/item/autopsy_scanner/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_pen(used))
		return ..()

	if(!COOLDOWN_FINISHED(src, print_cooldown))
		to_chat(user, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return ITEM_INTERACT_COMPLETE

	var/dead_name = tgui_input_text(user, "Insert name of deceased individual", default = target_name, title = "Coroner's Report", max_length = 60)
	var/rank = tgui_input_text(user, "Insert rank of deceased individual", default = target_rank, title = "Coroner's Report", max_length = 60)
	var/tod = tgui_input_text(user, "Insert time of death", default = station_time_timestamp("hh:mm", timeofdeath), title = "Coroner's Report", max_length = 60)
	var/cause = tgui_input_text(user, "Insert cause of death", title = "Coroner's Report", max_length = 60)
	var/chems = tgui_input_text(user, "Insert any chemical traces", multiline = TRUE, title = "Coroner's Report")
	var/notes = tgui_input_text(user, "Insert any relevant notes", multiline = TRUE, title = "Coroner's Report")

	COOLDOWN_START(src, print_cooldown, PRINT_TIMER)
	var/obj/item/paper/R = new(user.loc)
	R.name = "Official Coroner's Report - [dead_name]"
	R.info = "<b><center>[station_name()] - Coroner's Report</b></center><br><br><b>Name of Deceased:</b> [dead_name]</br><br><b>Rank of Deceased:</b> [rank]<br><br><b>Time of Death:</b> [tod]<br><br><b>Cause of Death:</b> [cause]<br><br><b>Trace Chemicals:</b> [chems]<br><br><b>Additional Coroner's Notes:</b> [notes]<br><br><b>Coroner's Signature:</b> <span class=\"paper_field\">"
	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	user.put_in_hands(R)

	return ITEM_INTERACT_COMPLETE

/obj/item/autopsy_scanner/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	if(!COOLDOWN_FINISHED(src, print_cooldown))
		to_chat(user, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return

	COOLDOWN_START(src, print_cooldown, PRINT_TIMER)
	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [station_time_timestamp("hh:mm:ss", timeofdeath)]<br><br>"
	else
		scan_data += "<b>Time of death:</b> Unknown / Still alive<br><br>"

	if(length(wdata))
		var/n = 1
		for(var/wdata_idx in wdata)
			var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
			var/total_hits = 0
			var/total_score = 0
			var/age = 0

			for(var/wound_idx in D.organs_scanned)
				var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
				total_hits += W.hits
				total_score+=W.damage


				var/wound_age = W.time_inflicted
				age = max(age, wound_age)

			var/damage_desc
			// total score happens to be the total damage
			switch(total_score)
				if(1 to 5)
					damage_desc = "<font color='green'>negligible</font>"
				if(5 to 15)
					damage_desc = "<font color='green'>light</font>"
				if(15 to 30)
					damage_desc = "<font color='orange'>moderate</font>"
				if(30 to 1000)
					damage_desc = "<font color='red'>severe</font>"
				else
					damage_desc = "Unknown"

			var/damaging_weapon = (total_score != 0)
			scan_data += "<b>Weapon #[n]</b><br>"
			if(damaging_weapon)
				scan_data += "Severity: [damage_desc]<br>"
				scan_data += "Hits by weapon: [total_hits]<br>"
			scan_data += "Approximate time of wound infliction: [station_time_timestamp("hh:mm", age)]<br>"
			scan_data += "Affected limbs: [D.organ_names]<br>"
			scan_data += "Weapon: [D.weapon]<br>"
			scan_data += "<br>"

			n++

	if(length(chemtraces))
		scan_data += "<b>Trace Chemicals: </b><br>"
		for(var/chemID in chemtraces)
			scan_data += chemID
			scan_data += "<br>"
	user.visible_message("<span class='warning'>[src] rattles and prints out a sheet of paper.</span>")

	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	sleep(10)

	var/obj/item/paper/P = new(user.loc)
	P.name = "Autopsy Data ([target_name])"
	P.info = "<tt>[scan_data]</tt>"
	P.overlays += "paper_words"

	user.put_in_hands(P)

/obj/item/autopsy_scanner/interact_with_atom(mob/living/carbon/human/target, mob/living/user, list/modifiers)
	if(!istype(target))
		return ..()

	user.changeNext_move(CLICK_CD_MELEE) // Need this so we don't speedrun autopsies
	if(!on_operable_surface(target))
		return ITEM_INTERACT_COMPLETE

	if(target_UID != target.UID())
		target_UID = target.UID()
		target_name = target.name
		target_rank = target.get_assignment(if_no_id = "Unknown", if_no_job = null)
		wdata.Cut()
		chemtraces.Cut()
		timeofdeath = null
		to_chat(user, "<span class='warning'>A new patient has been registered. Purging data for previous patient.</span>")

	timeofdeath = target.timeofdeath

	var/obj/item/organ/external/S = target.get_organ(user.zone_selected)
	if(!S)
		to_chat(user, "<span class='warning'>You can't scan this body part.</span>")
		return ITEM_INTERACT_COMPLETE
	target.visible_message("<span class='warning'>[user] scans the wounds on [target]'s [S.name] with [src]</span>")

	add_data(S)
	return ITEM_INTERACT_COMPLETE

#undef PRINT_TIMER
