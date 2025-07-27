#define TAB_MAIN 1
#define TAB_DAMAGES_BREAKDOWN 2

/obj/machinery/computer/cloning
	name = "cloning console"
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
	/// Is the scanner currently scanning someone?
	var/currently_scanning = FALSE
	COOLDOWN_DECLARE(scancooldown)

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()

	if(length(pods) && scanner)
		return

	if(!mapload)
		return //cloning setups built by players need to be linked manually

	pods += locate(/obj/machinery/clonepod, orange(5, src))
	scanner = locate(/obj/machinery/clonescanner, orange(5, src))
	selected_pod = pick(pods)

	new /obj/item/book/manual/medical_cloning(get_turf(src)) //hopefully this stems the tide of mhelps during the TM...

/obj/machinery/computer/cloning/Destroy()
	if(scanner)
		scanner.console = null
	if(pods)
		for(var/obj/machinery/clonepod/P in pods)
			P.console = null
	return ..()

/obj/machinery/computer/cloning/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!ismultitool(used))
		return ..()

	var/obj/item/multitool/M = used
	if(!M.buffer)
		to_chat(user, "<span class='warning'>[M]'[M.p_s()] buffer is empty!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(M.buffer, /obj/machinery/clonepod))
		var/obj/machinery/clonepod/buffer_pod = M.buffer
		if(buffer_pod.console == src)
			to_chat(user, "<span class='warning'>[M.buffer] is already linked!</span>")
			return ITEM_INTERACT_COMPLETE

		pods += M.buffer
		buffer_pod.console = src
		to_chat(user, "<span class='notice'>[M.buffer] was successfully added to the cloning pod array.</span>")
		if(!selected_pod)
			selected_pod = buffer_pod
		return ITEM_INTERACT_COMPLETE

	if(istype(M.buffer, /obj/machinery/clonescanner))
		var/obj/machinery/clonescanner/buffer_scanner = M.buffer
		if(scanner)
			to_chat(user, "<span class='warning'>There's already a linked scanner!</span>")
			return ITEM_INTERACT_COMPLETE

		scanner = buffer_scanner
		buffer_scanner.console = src
		to_chat(user, "<span class='notice'>[M.buffer] was successfully linked.</span>")
		return ITEM_INTERACT_COMPLETE

	to_chat(user, "<span class='warning'>[M.buffer] cannot be linked to [src].</span>")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/computer/cloning/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user)
	. = ..()
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	ui_interact(user)

/obj/machinery/computer/cloning/proc/generate_healthy_data(datum/cloning_data/patient_data)
	var/datum/cloning_data/desired_data = new

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

/obj/machinery/computer/cloning/proc/extract_damage_data(datum/cloning_data/patient_data)
	var/datum/cloning_data/desired_data = new

	for(var/limb in patient_data.limbs)
		var/list/limb_data = patient_data.limbs[limb]
		desired_data.limbs[limb] = limb_data.Copy()

	for(var/organ in patient_data.organs)
		var/list/organ_data = patient_data.organs[organ]
		desired_data.organs[organ] = organ_data.Copy()

	return desired_data

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui = null)
	if(stat & (NOPOWER|BROKEN))
		return

	var/datum/asset/simple/cloning/assets = get_asset_datum(/datum/asset/simple/cloning)
	assets.send(user)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning Console")
		ui.open()

/obj/machinery/computer/cloning/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/cloning)
	)

/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()

	data["tab"] = tab

	if(scanner)
		data["has_scanner"] = TRUE
	else
		data["has_scanner"] = FALSE

	if(scanner)
		data["has_scanned"] = scanner.has_scanned
		data["currently_scanning"] = currently_scanning
	else
		data["has_scanned"] = FALSE

	if(scanner?.last_scan)
		data["patient_limb_data"] = scanner.last_scan.limbs
		var/list/allLimbs = list()
		for(var/limb in scanner.last_scan.limbs)
			allLimbs += limb
		data["limb_list"] = allLimbs

		data["patient_organ_data"] = scanner.last_scan.organs
		var/list/allOrgans = list()
		for(var/organ in scanner.last_scan.organs)
			allOrgans += organ
		data["organ_list"] = allOrgans

	if(desired_data)
		data["desired_limb_data"] = desired_data.limbs
		data["desired_organ_data"] = desired_data.organs

	data["feedback"] = feedback

	if(feedback)
		data["scan_successful"] = feedback["scan_succeeded"]
	else
		data["scan_successful"] = FALSE

	if(scanner?.occupant)
		data["scanner_has_patient"] = TRUE
	else
		data["scanner_has_patient"] = FALSE

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
		data["selected_pod_data"] = list("biomass" = selected_pod.biomass,
										"biomass_storage_capacity" = selected_pod.biomass_storage_capacity,
										"sanguine_reagent" = selected_pod.reagents.get_reagent_amount("sanguine_reagent"),
										"osseous_reagent" = selected_pod.reagents.get_reagent_amount("osseous_reagent"),
										"max_reagent_capacity" = selected_pod.reagents.maximum_volume)
		data["selected_pod_UID"] = selected_pod.UID()
		if(scanner?.last_scan && desired_data)
			var/list/costs = selected_pod.get_cloning_cost(scanner.last_scan, desired_data)
			data["cloning_cost"] = costs
		else
			data["cloning_cost"] = list()

	data["pods"] = pod_data
	data["pod_amount"] = length(pods)

	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	var/datum/cloning_data/patient_data = scanner?.last_scan //For readability, mostly

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
			if(selected_pod.biomass < cost[BIOMASS_COST] || (selected_pod.reagents.get_reagent_amount("sanguine_reagent") < cost[SANGUINE_COST]) || selected_pod.reagents.get_reagent_amount("osseous_reagent") < cost[OSSEOUS_COST])
				feedback = list("text" = "The cloning operation is too expensive!", "color" = "bad", "scan_succeeded" = FALSE)
			else
				selected_pod.start_cloning(scanner.last_scan, desired_data)
				scanner?.update_scan_status()
				feedback = list("text" = "Beginning cloning operation...", "color" = "good", "scan_succeeded" = TRUE)
			return TRUE
		if("scan")
			if(!COOLDOWN_FINISHED(src, scancooldown))
				feedback = list("text" = "The scanning array is still calibrating! Please wait...", "color" = "average", "scan_succeeded" = FALSE)
				return TRUE

			if(!scanner.occupant)
				return FALSE

			currently_scanning = TRUE
			scanner.occupant.notify_ghost_cloning()
			feedback = list("text" = "Scanning occupant! Please wait...", "color" = "good", "scan_succeeded" = FALSE)
			COOLDOWN_START(src, scancooldown, 10 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(do_scan), patient_data), 5 SECONDS)
			addtimer(VARSET_CALLBACK(src, currently_scanning, FALSE), 5 SECONDS) // ABSOLUTELY make sure this is false at the end of this.
			return TRUE

		if("fix_all")
			desired_data = generate_healthy_data(scanner.last_scan)
			return TRUE

		if("fix_none")
			desired_data = extract_damage_data(scanner.last_scan)
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
		if("eject")
			if(scanner?.occupant)
				scanner.remove_mob(scanner.occupant)
				currently_scanning = FALSE
			return TRUE


	add_fingerprint(usr)

/obj/machinery/computer/cloning/proc/do_scan(datum/cloning_data/patient_data)
	currently_scanning = FALSE
	if(!scanner?.occupant)
		return

	var/scanner_result = scanner.try_scan(scanner.occupant)
	switch(scanner_result)
		if(SCANNER_MISC)
			feedback = list("text" = "Unable to analyze patient's genetic sequence.", "color" = "bad", "scan_succeeded" = FALSE)
		if(SCANNER_UNCLONEABLE_SPECIES)
			feedback = list("text" = "[scanner.occupant.dna.species.name_plural] cannot be scanned.", "color" = "bad", "scan_succeeded" = FALSE)
		if(SCANNER_HUSKED)
			feedback = list("text" = "The patient is husked.", "color" = "bad", "scan_succeeded" = FALSE)
		if(SCANNER_ABSORBED)
			feedback = list("text" = "The patient cannot be scanned due to a lack of biofluids.", "color" = "bad", "scan_succeeded" = FALSE)
		if(SCANNER_NO_SOUL)
			feedback = list("text" = "Failed to sequence the patient's brain. Further attempts may succeed.", "color" = "average", "scan_succeeded" = FALSE)
		if(SCANNER_BRAIN_ISSUE)
			feedback = list("text" = "The patient's brain is inactive or missing.", "color" = "bad", "scan_succeeded" = FALSE)
		if(SCANNER_POD_IN_PROGRESS)
			feedback = list("text" = "The selected pod is currently cloning someone.", "color" = "average", "scan_succeeded" = FALSE)
		else
			var/datum/cloning_data/scan = scanner_result

			if((scan.mindUID == patient_data?.mindUID) || (scan.mindUID == selected_pod?.patient_data?.mindUID))
				feedback = list("text" = "Patient has already been scanned.", "color" = "good", "scan_succeeded" = TRUE)
				return TRUE
			feedback = list("text" = "Successfully scanned the patient.", "color" = "good", "scan_succeeded" = TRUE)
			desired_data = generate_healthy_data(scan)

#undef TAB_MAIN
#undef TAB_DAMAGES_BREAKDOWN
