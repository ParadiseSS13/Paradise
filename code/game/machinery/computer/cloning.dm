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

	selected_pod = pick(pods)

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

	if(scanner?.last_scan)
		data["hasScanned"] = TRUE
		data["patientLimbData"] = scanner.last_scan.limbs
		data["patientOrganData"] = scanner.last_scan.organs
	else if(scanner && !scanner.last_scan)
		data["hasScanned"] = FALSE

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

	data["pods"] = pod_data
	data["selectedPodUID"] = selected_pod.UID()
	data["podAmount"] = length(pods)

	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

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

	src.add_fingerprint(usr)

#undef TAB_MAIN
#undef TAB_DAMAGES_BREAKDOWN
