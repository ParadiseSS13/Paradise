/obj/item/autopsy_scanner
	name = "autopsy scanner"
	desc = "Extracts information on wounds."
	icon = 'icons/obj/autopsy_scanner.dmi'
	icon_state = ""
	flags = CONDUCT
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "magnets=1;biotech=1"
	var/list/datum/autopsy_data_scanner/wdata = list()
	var/list/chemtraces = list()
	var/target_name = null
	var/timeofdeath = null

/obj/item/autopsy_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(wdata)
	return ..()

/datum/autopsy_data_scanner
	var/weapon = null // this is the DEFINITE weapon type that was used
	var/list/organs_scanned = list() // this maps a number of scanned organs to
									 // the wounds to those organs with this data's weapon type
	var/organ_names = ""

/datum/autopsy_data_scanner/Destroy()
	QDEL_LIST_ASSOC_VAL(organs_scanned)
	return ..()

/datum/autopsy_data
	var/weapon = null
	var/pretend_weapon = null
	var/damage = 0
	var/hits = 0
	var/time_inflicted = 0

/datum/autopsy_data/proc/copy()
	var/datum/autopsy_data/W = new()
	W.weapon = weapon
	W.pretend_weapon = pretend_weapon
	W.damage = damage
	W.hits = hits
	W.time_inflicted = time_inflicted
	return W

/obj/item/autopsy_scanner/proc/add_data(obj/item/organ/external/O)
	if(!O.autopsy_data.len && !O.trace_chemicals.len)
		return

	for(var/V in O.autopsy_data)
		var/datum/autopsy_data/W = O.autopsy_data[V]

		if(!W.pretend_weapon)
			if(1)
				W.pretend_weapon = W.weapon
			else
				W.pretend_weapon = pick("mechanical toolbox", "wirecutters", "revolver", "crowbar", "fire extinguisher", "tomato soup", "oxygen tank", "emergency oxygen tank", "laser", "bullet")


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

	for(var/V in O.trace_chemicals)
		if(O.trace_chemicals[V] > 0 && !chemtraces.Find(V))
			chemtraces += V

/obj/item/autopsy_scanner/attackby(obj/item/P, mob/user)
	if(istype(P, /obj/item/pen))
		var/dead_name = input("Insert name of deceased individual")
		var/dead_rank = input("Insert rank of deceased individual")
		var/dead_tod = input("Insert time of death")
		var/dead_cause = input("Insert cause of death")
		var/dead_chems = input("Insert any chemical traces")
		var/dead_notes = input("Insert any relevant notes")
		var/obj/item/paper/R = new(user.loc)
		R.name = "Official Coroner's Report - [dead_name]"
		R.info = "<b>NanoTrasen Science Station Cyberiad - Coroner's Report</b><br><br><b>Name of Deceased:</b> [dead_name]</br><br><b>Rank of Deceased:</b> [dead_rank]<br><br><b>Time of Death:</b> [dead_tod]<br><br><b>Cause of Death:</b> [dead_cause]<br><br><b>Trace Chemicals:</b> [dead_chems]<br><br><b>Additional Coroner's Notes:</b> [dead_notes]<br><br><b>Coroner's Signature:</b> <span class=\"paper_field\">"
		playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
		sleep(10)
		user.put_in_hands(R)

/obj/item/autopsy_scanner/attack_self(mob/user)
	if(!wdata.len && !chemtraces.len)
		return

	var/scan_data = ""

	if(timeofdeath)
		scan_data += "<b>Time of death:</b> [station_time_timestamp("hh:mm:ss", timeofdeath)]<br><br>"

	var/n = 1
	for(var/wdata_idx in wdata)
		var/datum/autopsy_data_scanner/D = wdata[wdata_idx]
		var/total_hits = 0
		var/total_score = 0
		var/list/weapon_chances = list() // maps weapon names to a score
		var/age = 0

		for(var/wound_idx in D.organs_scanned)
			var/datum/autopsy_data/W = D.organs_scanned[wound_idx]
			total_hits += W.hits

			var/wname = W.pretend_weapon

			if(wname in weapon_chances)
				weapon_chances[wname] += W.damage
			else
				weapon_chances[wname] = max(W.damage, 1)
			total_score+=W.damage


			var/wound_age = W.time_inflicted
			age = max(age, wound_age)

		var/damage_desc

		var/damaging_weapon = (total_score != 0)

		// total score happens to be the total damage
		switch(total_score)
			if(0)
				damage_desc = "Unknown"
			if(1 to 5)
				damage_desc = "<font color='green'>negligible</font>"
			if(5 to 15)
				damage_desc = "<font color='green'>light</font>"
			if(15 to 30)
				damage_desc = "<font color='orange'>moderate</font>"
			if(30 to 1000)
				damage_desc = "<font color='red'>severe</font>"

		if(!total_score)
			total_score = D.organs_scanned.len

		scan_data += "<b>Weapon #[n]</b><br>"
		if(damaging_weapon)
			scan_data += "Severity: [damage_desc]<br>"
			scan_data += "Hits by weapon: [total_hits]<br>"
		scan_data += "Approximate time of wound infliction: [station_time(age)]<br>"
		scan_data += "Affected limbs: [D.organ_names]<br>"
		scan_data += "Possible weapons:<br>"
		for(var/weapon_name in weapon_chances)
			scan_data += "\t[100*weapon_chances[weapon_name]/total_score]% [weapon_name]<br>"

		scan_data += "<br>"

		n++

	if(chemtraces.len)
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

/obj/item/autopsy_scanner/attack(mob/living/carbon/human/M, mob/living/carbon/user)
	if(!istype(M))
		return

	if(!can_operate(M))
		return

	if(target_name != M.name)
		target_name = M.name
		wdata.Cut()
		chemtraces.Cut()
		timeofdeath = null
		to_chat(user, "<span class='warning'>A new patient has been registered. Purging data for previous patient.</span>")

	timeofdeath = M.timeofdeath

	var/obj/item/organ/external/S = M.get_organ(user.zone_sel.selecting)
	if(!S)
		to_chat(user, "<span class='warning'>You can't scan this body part.</span>")
		return
	M.visible_message("<span class='warning'>[user] scans the wounds on [M]'s [S] with [src]</span>")

	add_data(S)
	return 1
