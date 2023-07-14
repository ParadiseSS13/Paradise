#define MENU_MAIN 1
#define MENU_RECORDS 2

/obj/machinery/computer/cloning
	name = "cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/cloning

	//A list of linked cloning pods.
	var/list/pods = list()
	//Our linked cloning scanner.
	var/obj/machinery/clonescanner/scanner
	//datum for testing
	var/datum/cloning_data/healthy_data = new /datum/cloning_data/

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()

	if(length(pods) && scanner)
		return

	if(!mapload)
		return //cloning setups built by players need to be linked manually

	pods += locate(/obj/machinery/clonepod, orange(5, src))

	scanner = locate(/obj/machinery/clonescanner, orange(5, src))

	healthy_data.limbs = list(
		"head"   = list(0, 5, 0, FALSE),
		"chest"  = list(5, 0, 0, FALSE),
		"groin"  = list(0, 0, 0, FALSE),
		"r_arm"  = list(0, 0, 0, FALSE),
		"r_hand" = list(0, 0, 0, FALSE),
		"l_arm"  = list(0, 0, 0, FALSE),
		"l_hand" = list(0, 0, 0, FALSE),
		"r_leg"  = list(0, 0, 0, FALSE),
		"r_foot" = list(0, 0, 0, FALSE),
		"l_leg"  = list(0, 0, 0, FALSE),
		"l_foot" = list(0, 0, 0, FALSE)
	)

	healthy_data.organs = list(
		"heart"    = list(0, 0, FALSE),
		"lungs"    = list(0, 0, FALSE),
		"liver"    = list(0, 0, FALSE),
		"kidneys"  = list(0, 0, FALSE),
		"brain"    = list(0, 0, FALSE),
		"appendix" = list(0, 0, FALSE),
		"eyes"     = list(0, 0, FALSE)
	)

/obj/machinery/computer/cloning/Destroy()
	return ..()

/obj/machinery/computer/cloning/process()
	. = ..()

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(!ismultitool(W))
		return ..()
	var/obj/item/multitool/M = W
	if(!M.buffer)
		to_chat(user, "<span class='warning'>[M]'[M.p_s()] buffer is empty!</span>")
		return

	if(istype(M.buffer, /obj/machinery/clonepod))
		var/obj/machinery/clonepod/buffer_pod = M.buffer
		if(buffer_pod.console == src)
			to_chat(user, "<span class='warning'>[M.buffer] is already linked!</span>")
			return

		pods += M.buffer
		buffer_pod.console = src
		to_chat(user, "<span class='notice'>[M.buffer] was successfully added to the cloning pod array.</span>")
		return

	if(istype(M.buffer, /obj/machinery/clonescanner))
		var/obj/machinery/clonescanner/buffer_scanner = M.buffer
		if(scanner)
			to_chat(user, "<span class='warning'>There's already a linked scanner!</span>")
			return

		scanner = buffer_scanner
		buffer_scanner.console = src
		to_chat(user, "<span class='notice'>[M.buffer] was successfully linked.</span>")
		return

	to_chat(user, "<span class='warning'>[M.buffer] cannot be linked to [src].</span>")
	return

/obj/machinery/computer/cloning/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	switch(alert(user, "What machine to interact with?", "TGUI Stand-In", "Cloning Pod", "Cloning Scanner"))
		if("Cloning Pod")
			switch(alert(user, "What proc to test?", "TGUI Stand-In", "get_cloning_cost()", "start_cloning()", "get_stored_organ()"))
				if("get_cloning_cost()")
					var/obj/machinery/clonepod/pod = pick(pods)
					var/list/cost = pod.get_cloning_cost(scanner.scan(scanner.occupant), healthy_data)
					to_chat(user, "Biomass: [cost[1]], Sanguine Reagent: [cost[2]], Osseous Reagent: [cost[3]]")
				if("start_cloning()")
					var/obj/machinery/clonepod/pod = pick(pods)
					pod.start_cloning(scanner.scan(scanner.occupant), healthy_data)
				if("get_stored_organ()")
					var/obj/machinery/clonepod/pod = pick(pods)
					to_chat(user, "[pod.get_stored_organ("heart")]")
	//ui_interact(user)

/*
/obj/machinery/computer/cloning/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if(stat & (NOPOWER|BROKEN))
		return

	var/datum/asset/cloning/assets = get_asset_datum(/datum/asset/cloning)
	assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CloningConsole", "Cloning Console", 640, 520)
		ui.open()

/obj/machinery/computer/cloning/ui_data(mob/user)
	var/data[0]
	data["menu"] = src.menu
	data["scanner"] = sanitize("[src.scanner]")

	var/canpodautoprocess = 0
	if(pods.len)
		data["numberofpods"] = src.pods.len

		var/list/tempods[0]
		for(var/obj/machinery/clonepod/pod in pods)
			if(pod.efficiency > 5)
				canpodautoprocess = 1

			var/status = "idle"
			if(pod.mess)
				status = "mess"
			else if(pod.occupant && !(pod.stat & NOPOWER))
				status = "cloning"
			tempods.Add(list(list(
				"pod" = "\ref[pod]",
				"name" = sanitize(capitalize(pod.name)),
				"biomass" = pod.biomass,
				"status" = status,
				"progress" = (pod.occupant && pod.occupant.stat != DEAD) ? pod.get_completion() : 0
			)))
			data["pods"] = tempods

	data["loading"] = loading
	data["autoprocess"] = autoprocess
	data["can_brainscan"] = can_brainscan() // You'll need tier 4s for this
	data["scan_mode"] = scan_mode

	if(scanner && pods.len && ((scanner.scan_level > 2) || canpodautoprocess))
		data["autoallowed"] = 1
	else
		data["autoallowed"] = 0
	if(src.scanner)
		data["occupant"] = src.scanner.occupant
		data["locked"] = src.scanner.locked
	data["temp"] = temp
	data["scantemp"] = scantemp
	data["selected_pod"] = "\ref[selected_pod]"
	var/list/temprecords[0]
	for(var/datum/dna2/record/R in records)
		var/tempRealName = R.dna.real_name
		temprecords.Add(list(list("record" = "\ref[R]", "realname" = sanitize(tempRealName))))
	data["records"] = temprecords

	if(selected_pod && (selected_pod in pods) && selected_pod.biomass >= CLONE_BIOMASS)
		data["podready"] = 1
	else
		data["podready"] = 0

	data["modal"] = ui_modal_data(src)

	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(ui_modal_act(src, action, params))
		if(UI_MODAL_ANSWER)
			if(params["id"] == "del_rec" && text2num(params["answer"]) && active_record)
				if(!allowed(usr))
					set_temp("Access denied.", "danger")
					return

				records.Remove(active_record)
				qdel(active_record)
				set_temp("Record deleted.", "success")
				menu = MENU_RECORDS
			return

	switch(action)
		if("scan")
			if(!scanner || !scanner.occupant || loading)
				return
			set_scan_temp("Scanner ready.", "good")
			loading = TRUE

			spawn(20)
				if(can_brainscan() && scan_mode)
					scan_mob(scanner.occupant, scan_brain = TRUE)
				else
					scan_mob(scanner.occupant)
				loading = FALSE
				SStgui.update_uis(src)
		if("autoprocess")
			autoprocess = text2num(params["on"]) > 0
		if("lock")
			if(isnull(scanner) || !scanner.occupant) //No locking an open scanner.
				return
			scanner.locked = !scanner.locked
		if("view_rec")
			var/ref = params["ref"]
			if(!length(ref))
				return
			active_record = locate(ref)
			if(istype(active_record))
				if(isnull(active_record.ckey))
					qdel(active_record)
					set_temp("Error: Record corrupt.", "danger")
				else
					var/obj/item/implant/health/H = null
					if(active_record.implant)
						H = locate(active_record.implant)
					var/list/payload = list(
						activerecord = "\ref[active_record]",
						health = (H && istype(H)) ? H.sensehealth() : "",
						realname = sanitize(active_record.dna.real_name),
						unidentity = active_record.dna.uni_identity,
						strucenzymes = active_record.dna.struc_enzymes,
					)
					ui_modal_message(src, action, "", null, payload)
			else
				active_record = null
				set_temp("Error: Record missing.", "danger")
		if("del_rec")
			if(!active_record)
				return
			ui_modal_boolean(src, action, "Please confirm that you want to delete the record:", yes_text = "Delete", no_text = "Cancel")
		if("refresh")
			SStgui.update_uis(src)
		if("selectpod")
			var/ref = params["ref"]
			if(!length(ref))
				return
			var/obj/machinery/clonepod/selected = locate(ref)
			if(istype(selected) && (selected in pods))
				selected_pod = selected
		if("clone")
			var/ref = params["ref"]
			if(!length(ref))
				return
			var/datum/dna2/record/C = locate(ref)
			//Look for that player! They better be dead!
			if(istype(C))
				ui_modal_clear(src)
				//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
				if(!length(pods))
					set_temp("Error: No cloning pod detected.", "danger")
				else
					var/obj/machinery/clonepod/pod = selected_pod
					var/cloneresult
					if(!selected_pod)
						set_temp("Error: No cloning pod selected.", "danger")
					else if(pod.occupant)
						set_temp("Error: The cloning pod is currently occupied.", "danger")
					else if(pod.biomass < CLONE_BIOMASS)
						set_temp("Error: Not enough biomass.", "danger")
					else if(pod.mess)
						set_temp("Error: The cloning pod is malfunctioning.", "danger")
					else if(!GLOB.configuration.general.enable_cloning)
						set_temp("Error: Unable to initiate cloning cycle.", "danger")
					else
						cloneresult = pod.growclone(C)
						if(cloneresult)
							set_temp("Initiating cloning cycle...", "success")
							records.Remove(C)
							qdel(C)
							menu = MENU_MAIN
						else
							set_temp("Error: Initialisation failure.", "danger")
			else
				set_temp("Error: Data corruption.", "danger")
		if("menu")
			menu = clamp(text2num(params["num"]), MENU_MAIN, MENU_RECORDS)
		if("toggle_mode")
			if(loading)
				return
			if(can_brainscan())
				scan_mode = !scan_mode
			else
				scan_mode = FALSE
		if("eject")
			if(usr.incapacitated() || !scanner || loading)
				return
			scanner.eject_occupant(usr)
			scanner.add_fingerprint(usr)
		if("cleartemp")
			temp = null
		else
			return FALSE

	src.add_fingerprint(usr)

*/
#undef MENU_MAIN
#undef MENU_RECORDS
