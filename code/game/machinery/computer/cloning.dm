#define MENU_MAIN 1
#define MENU_RECORDS 2

/obj/machinery/computer/cloning
	name = "cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/cloning
	req_access = list(ACCESS_HEADS) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods = null //Linked cloning pods.
	var/list/temp = null
	var/list/scantemp = null
	var/menu = MENU_MAIN //Which menu screen to display
	var/list/records = null
	var/datum/dna2/record/active_record = null
	var/loading = 0 // Nice loading text
	var/autoprocess = 0
	var/obj/machinery/clonepod/selected_pod
	// 0: Standard body scan
	// 1: The "Best" scan available
	var/scan_mode = 1

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()
	pods = list()
	records = list()
	set_scan_temp("Scanner ready.", "good")
	updatemodules()

/obj/machinery/computer/cloning/Destroy()
	releasecloner()
	return ..()

/obj/machinery/computer/cloning/process()
	if(!scanner || !pods.len || !autoprocess || stat & NOPOWER)
		return

	if(scanner.occupant && can_autoprocess())
		scan_mob(scanner.occupant)

	if(!LAZYLEN(records))
		return

	for(var/obj/machinery/clonepod/pod in pods)
		if(!(pod.occupant || pod.mess) && (pod.efficiency > 5))
			for(var/datum/dna2/record/R in records)
				if(!(pod.occupant || pod.mess))
					if(pod.growclone(R))
						records.Remove(R)

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	releasecloner()
	findcloner()
	if(!selected_pod && pods.len)
		selected_pod = pods[1]

/obj/machinery/computer/cloning/proc/findscanner()
	//Try to find scanner on adjacent tiles first
	for(var/obj/machinery/dna_scannernew/scanner in orange(1, src))
		return scanner

	//Then look for a free one in the area
	for(var/obj/machinery/dna_scannernew/S in get_area(src))
		return S

	return FALSE

/obj/machinery/computer/cloning/proc/releasecloner()
	for(var/obj/machinery/clonepod/P in pods)
		P.connected = null
		P.name = initial(P.name)
	pods.Cut()

/obj/machinery/computer/cloning/proc/findcloner()
	var/num = 1
	for(var/obj/machinery/clonepod/P in get_area(src))
		if(!P.connected)
			pods += P
			P.connected = src
			P.name = "[initial(P.name)] #[num++]"

/obj/machinery/computer/cloning/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/clonepod))
			var/obj/machinery/clonepod/P = M.buffer
			if(P && !(P in pods))
				pods += P
				P.connected = src
				P.name = "[initial(P.name)] #[pods.len]"
				to_chat(user, "<span class='notice'>You connect [P] to [src].</span>")
	else
		return ..()


/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()
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

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob, scan_brain = 0)
	if(stat & NOPOWER)
		return
	if(scanner.stat & (NOPOWER|BROKEN))
		return
	if(scan_brain && !can_brainscan())
		return
	if(isnull(subject) || (!(ishuman(subject))) || (!subject.dna))
		if(isalien(subject))
			set_scan_temp("Safety interlocks engaged. Nanotrasen Directive 7b forbids the cloning of biohazardous alien species.", "bad")
			SStgui.update_uis(src)
			return
		// can add more conditions for specific non-human messages here
		else
			set_scan_temp("Subject species is not clonable.", "bad")
			SStgui.update_uis(src)
			return
	if(subject.get_int_organ(/obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/Brn = subject.get_int_organ(/obj/item/organ/internal/brain)
		if(istype(Brn))
			if(Brn.dna.species.name == "Machine")
				set_scan_temp("No organic tissue detected within subject. Alternative revival methods recommended.", "bad")
				SStgui.update_uis(src)
				return
			if(NO_CLONESCAN in Brn.dna.species.species_traits)
				set_scan_temp("[Brn.dna.species.name_plural] are not clonable. Alternative revival methods recommended.", "bad")
				SStgui.update_uis(src)
				return
	if(!subject.get_int_organ(/obj/item/organ/internal/brain))
		set_scan_temp("No brain detected in subject.", "bad")
		SStgui.update_uis(src)
		return
	if(subject.suiciding)
		set_scan_temp("Subject has committed suicide and is not clonable.", "bad")
		SStgui.update_uis(src)
		return
	if(HAS_TRAIT(subject, TRAIT_BADDNA) && src.scanner.scan_level < 2)
		set_scan_temp("Insufficient level of biofluids detected within subject. Scanner upgrades may be required to improve scan capabilities.", "bad")
		SStgui.update_uis(src)
		return
	if(HAS_TRAIT(subject, TRAIT_HUSK) && src.scanner.scan_level < 2)
		set_scan_temp("Subject is husked. Treat condition or upgrade scanning module to proceed with scan.", "bad")
		SStgui.update_uis(src)
		return
	if((!subject.ckey) || (!subject.client))
		set_scan_temp("Subject's brain is not responding. Further attempts after a short delay may succeed.", "bad")
		SStgui.update_uis(src)
		return
	if(!isnull(find_record(subject.ckey)))
		set_scan_temp("Subject already in database.")
		SStgui.update_uis(src)
		return
	if(subject.stat != DEAD)
		set_scan_temp("Subject is not dead.", "bad")
		SStgui.update_uis(src)
		return

	for(var/obj/machinery/clonepod/pod in pods)
		if(pod.occupant && pod.clonemind == subject.mind)
			set_scan_temp("Subject already getting cloned.")
			SStgui.update_uis(src)
			return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.ckey = subject.ckey
	var/extra_info = ""
	if(scan_brain)
		var/obj/item/organ/B = subject.get_int_organ(/obj/item/organ/internal/brain)
		B.dna.check_integrity()
		R.dna=B.dna.Clone()
		if(NO_CLONESCAN in R.dna.species.species_traits)
			extra_info = "Proper genetic interface not found, defaulting to genetic data of the body."
			R.dna.species = new subject.dna.species.type
		R.id= copytext(md5(B.dna.real_name), 2, 6)
		R.name=B.dna.real_name
	else
		R.dna=subject.dna.Clone()
		R.id= copytext(md5(subject.real_name), 2, 6)
		R.name=R.dna.real_name

	R.types=DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	R.languages=subject.languages
	//Add an implant if needed
	var/obj/item/implant/health/imp = locate(/obj/item/implant/health, subject)
	if(!imp)
		imp = new /obj/item/implant/health(subject)
		imp.implant(subject)
	R.implant = "\ref[imp]"

	if(!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	set_scan_temp("Subject successfully scanned. [extra_info]", "good")
	SStgui.update_uis(src)

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if(R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/proc/can_autoprocess()
	return (scanner && scanner.scan_level > 2)

/obj/machinery/computer/cloning/proc/can_brainscan()
	return (scanner && scanner.scan_level > 3)

/**
  * Sets a temporary message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * style - The style of the message: (color name), info, success, warning, danger
  */
/obj/machinery/computer/cloning/proc/set_temp(text = "", style = "info", update_now = FALSE)
	temp = list(text = text, style = style)
	if(update_now)
		SStgui.update_uis(src)

/**
  * Sets a temporary scan message to display to the user
  *
  * Arguments:
  * * text - Text to display, null/empty to clear the message from the UI
  * * color - The color of the message: (color name)
  */
/obj/machinery/computer/cloning/proc/set_scan_temp(text = "", color = "", update_now = FALSE)
	scantemp = list(text = text, color = color)
	if(update_now)
		SStgui.update_uis(src)

#undef MENU_MAIN
#undef MENU_RECORDS
