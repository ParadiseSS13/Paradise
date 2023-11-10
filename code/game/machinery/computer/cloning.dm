#define TAB_MAIN 1
#define TAB_DAMAGES_BREAKDOWN 2

/obj/machinery/computer/cloning
	name = "cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/cloning

	/// The currently-selected cloning pod.
	var/obj/machinery/clonepod/selected_pod
	/// A list of all linked cloning pods.
	var/list/pods = list()
	/// Our linked cloning scanner.
	var/obj/machinery/clonescanner/scanner
	/// Which tab we're currently on
	var/tab = TAB_MAIN
	/// What feedback to give for the most recent scan.
	var/feedback
	/// The desired outcome of the cloning process.
	var/datum/cloning_data/desired_data

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()

	if(length(pods) && scanner)
		return

	if(!mapload)
		return //cloning setups built by players need to be linked manually

	pods += locate(/obj/machinery/clonepod, orange(5, src))

	scanner = locate(/obj/machinery/clonescanner, orange(5, src))

	selected_pod = pick(pods)

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

	/*
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
	*/
	ui_interact(user)

/obj/machinery/computer/cloning/proc/generate_healthy_data(datum/cloning_data/patient_data)
	var/datum/cloning_data/desired_data = new /datum/cloning_data()

	for(var/limb in patient_data.limbs)
		desired_data.limbs[limb] = list(0,
										0,
										0,
										FALSE,
										patient_data.limbs[limb][5],
										patient_data.limbs[limb][6])

	for(var/organ in patient_data.organs)
		desired_data.organs[organ] = list(0,
										0,
										FALSE,
										patient_data.organs[organ][4],
										patient_data.organs[organ][5])

	return desired_data

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
	var/list/data = list()

	data["tab"] = tab

	if(scanner)
		data["hasScanner"] = TRUE
	else
		data["hasScanner"] = FALSE

	data["hasScanned"] = scanner.has_scanned

	if(scanner?.last_scan)
		data["patientLimbData"] = scanner.last_scan.limbs
		var/list/allLimbs = list()
		for(var/limb in scanner.last_scan.limbs)
			allLimbs += limb
		data["limbList"] = allLimbs

		data["patientOrganData"] = scanner.last_scan.organs
		var/list/allOrgans = list()
		for(var/organ in scanner.last_scan.organs)
			allOrgans += organ
		data["organList"] = allOrgans

		data["desiredLimbData"] = desired_data.limbs
		data["desiredOrganData"] = desired_data.organs

	data["feedback"] = feedback

	if(feedback && feedback["color"] == "good")
		data["scanSuccessful"] = TRUE
	else
		data["scanSuccessful"] = FALSE

	if(scanner?.occupant)
		data["scannerHasPatient"] = TRUE
	else
		data["scannerHasPatient"] = FALSE

	var/list/pod_data = list()
	if(length(pods))
		for(var/obj/machinery/clonepod/pod in pods)
			pod_data += list(list("uid" = pod.UID(),
							"cloning" = pod.currently_cloning,
							"clone_progress" = pod.clone_progress,
							"biomass" = pod.biomass,
							"biomass_storage_capacity" = pod.biomass_storage_capacity,
							"sanguine_reagent" = pod.reagents.get_reagent_amount("sanguine_reagent"),
							"osseous_reagent" = pod.reagents.get_reagent_amount("osseous_reagent")))

	if(selected_pod)
		data["selectedPodData"] = list("biomass" = selected_pod.biomass,
										"biomass_storage_capacity" = selected_pod.biomass_storage_capacity,
										"sanguine_reagent" = selected_pod.reagents.get_reagent_amount("sanguine_reagent"),
										"osseous_reagent" = selected_pod.reagents.get_reagent_amount("osseous_reagent"),
										"max_reagent_capacity" = selected_pod.reagents.maximum_volume)
		data["selectedPodUID"] = selected_pod.UID()
		if(scanner?.last_scan && desired_data)
			data["cloningCost"] = selected_pod.get_cloning_cost(scanner.last_scan, desired_data)

	data["pods"] = pod_data
	data["podAmount"] = length(pods)

	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	var/datum/cloning_data/patient_data = scanner.last_scan //For readability, mostly

	switch(action)
		if("menu")
			switch(text2num(params["tab"]))
				if(TAB_MAIN)
					tab = TAB_MAIN
					return TRUE
				if(TAB_DAMAGES_BREAKDOWN)
					tab = TAB_DAMAGES_BREAKDOWN
					return TRUE
		if("select_pod")
			selected_pod = locateUID(params["uid"])
			return TRUE
		if("clone")
			var/cost = selected_pod.get_cloning_cost(scanner.last_scan, desired_data)
			if((selected_pod.biomass < cost[1]) || (selected_pod.reagents.get_reagent_amount("sanguine_reagent") < cost[2]) || (selected_pod.reagents.get_reagent_amount("osseous_reagent") < cost[3]))
				feedback = list("text" = "The cloning operation is too expensive!", "color" = "bad")
			else
				selected_pod.start_cloning(scanner.last_scan, desired_data)
			return TRUE
		if("scan")
			switch(scanner.try_scan(scanner.occupant))
				if(SCANNER_MISC)
					feedback = list("text" = "Unable to analyze patient's genetic sequence.", "color" = "bad")
				if(SCANNER_UNCLONEABLE_SPECIES)
					feedback = list("text" = "[scanner.occupant.dna.species.name_plural] cannot be scanned.", "color" = "bad")
				if(SCANNER_HUSKED)
					feedback = list("text" = "The patient is husked.", "color" = "bad")
				if(SCANNER_NO_SOUL)
					feedback = list("text" = "Failed to sequence the patient's brain. Further attempts may succeed.", "color" = "average")
				if(SCANNER_SUCCESSFUL)
					feedback = list("text" = "Successfully scanned the patient.", "color" = "good")
					desired_data = generate_healthy_data(scanner.last_scan)
			return TRUE
		if("fix_all")
			desired_data = generate_healthy_data(scanner.last_scan)
			return TRUE
		if("fix_none")
			desired_data = scanner.last_scan
			return TRUE
		if("toggle_limb_repair")
			switch(params["type"])
				if("replace")
					if(desired_data.limbs[params["limb"]][4])
						desired_data.limbs[params["limb"]][4] = FALSE
					else
						desired_data.limbs[params["limb"]][4] = TRUE
				if("damage")
					if(desired_data.limbs[params["limb"]][1] || desired_data.limbs[params["limb"]][2])
						desired_data.limbs[params["limb"]][1] = 0
						desired_data.limbs[params["limb"]][2] = 0
					else
						desired_data.limbs[params["limb"]][1] = patient_data.limbs[params["limb"]][1]
						desired_data.limbs[params["limb"]][2] = patient_data.limbs[params["limb"]][2]
				if("bone")
					if(desired_data.limbs[params["limb"]][3] & ORGAN_BROKEN)
						desired_data.limbs[params["limb"]][3] &= ~ORGAN_BROKEN
					else
						desired_data.limbs[params["limb"]][3] |= ORGAN_BROKEN
				if("ib")
					if(desired_data.limbs[params["limb"]][3] & ORGAN_INT_BLEEDING)
						desired_data.limbs[params["limb"]][3] &= ~ORGAN_INT_BLEEDING
					else
						desired_data.limbs[params["limb"]][3] |= ORGAN_INT_BLEEDING
				if("critburn")
					if(desired_data.limbs[params["limb"]][3] & ORGAN_BURNT)
						desired_data.limbs[params["limb"]][3] &= ~ORGAN_BURNT
					else
						desired_data.limbs[params["limb"]][3] |= ORGAN_BURNT
			return TRUE
		if("toggle_organ_repair")
			switch(params["type"])
				if("replace")
					if(desired_data.organs[params["organ"]][3] || desired_data.organs[params["organ"]][2])
						desired_data.organs[params["organ"]][3] = FALSE
						desired_data.organs[params["organ"]][2] = 0
					else
						desired_data.organs[params["organ"]][3] = patient_data.organs[params["organ"]][3]
						desired_data.organs[params["organ"]][2] = patient_data.organs[params["organ"]][2]
				if("damage")
					if(desired_data.organs[params["organ"]][1])
						desired_data.organs[params["organ"]][1] = 0
					else
						desired_data.organs[params["organ"]][1] = patient_data.organs[params["organ"]][1]
			return TRUE


	src.add_fingerprint(usr)

#undef TAB_MAIN
#undef TAB_DAMAGES_BREAKDOWN
