/obj/machinery/computer/cloning
	name = "cloning console"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "dna"
	circuit = /obj/item/circuitboard/cloning
	req_access = list(access_heads) //Only used for record deletion right now.
	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/list/pods = list() //Linked cloning pods.
	var/temp = ""
	var/scantemp = "Scanner ready."
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/disk/data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text
	var/obj/machinery/clonepod/selected_pod
	// 0: Standard body scan
	// 1: The "Best" scan available
	var/scan_mode = 1

	light_color = LIGHT_COLOR_DARKBLUE

/obj/machinery/computer/cloning/Initialize()
	..()
	updatemodules()

/obj/machinery/computer/cloning/Destroy()
	releasecloner()
	return ..()

/obj/machinery/computer/cloning/process()
	if(!scanner || !pods.len || stat & NOPOWER)
		return

	if(scanner.occupant)
		scan_mob(scanner.occupant)

	for(var/obj/machinery/clonepod/pod in pods)
		if(!(pod.occupant || pod.mess) && (pod.efficiency > 5))
			for(var/datum/dna2/record/R in records)
				if(!(pod.occupant || pod.mess))
					if(pod.growclone(R))
						records.Remove(R)

/obj/machinery/computer/cloning/proc/updatemodules()
	scanner = findscanner()
	releasecloner()
	findcloner()
	if(!selected_pod && pods.len)
		selected_pod = pods[1]

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	//Try to find scanner on adjacent tiles first
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))
		if(scannerf)
			return scannerf

	//Then look for a free one in the area
	if(!scannerf)
		for(var/obj/machinery/dna_scannernew/S in get_area(src))
			return S

	return 0

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
	if(istype(W, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if(!diskette)
			user.drop_item()
			W.loc = src
			diskette = W
			to_chat(user, "You insert [W].")
			SSnanoui.update_uis(src)
			return
	else if(istype(W, /obj/item/multitool))
		var/obj/item/multitool/M = W
		if(M.buffer && istype(M.buffer, /obj/machinery/clonepod))
			var/obj/machinery/clonepod/P = M.buffer
			if(P && !(P in pods))
				pods += P
				P.connected = src
				P.name = "[initial(P.name)] #[pods.len]"
				to_chat(user, "<span class='notice'>You connect [P] to [src].</span>")
	else
		..()
	return


/obj/machinery/computer/cloning/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user as mob)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()
	ui_interact(user)

/obj/machinery/computer/cloning/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (NOPOWER|BROKEN))
		return

	// Set up the Nano UI
	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "cloning_console.tmpl", "Cloning Console UI", 640, 520)
		ui.open()

/obj/machinery/computer/cloning/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	var/data[0]
	data["menu"] = menu
	data["scanner"] = sanitize("[scanner]")

	if(pods.len)
		data["numberofpods"] = pods.len

		var/list/tempods[0]
			for(var/obj/machinery/clonepod/pod in pods)
				tempods.Add(list(list("pod" = "\ref[pod]", "name" = sanitize(capitalize(pod.name)), "biomass" = pod.biomass)))
				data["pods"] = tempods

	data["loading"] = loading
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
	data["disk"] = diskette
	data["selected_pod"] = "\ref[selected_pod]"
	var/list/temprecords[0]
	for(var/datum/dna2/record/R in records)
		var tempRealName = R.dna.real_name
		temprecords.Add(list(list("record" = "\ref[R]", "realname" = sanitize(tempRealName))))
	data["records"] = temprecords

	if(menu == 3)
		if(active_record)
			data["activerecord"] = "\ref[active_record]"
			var/obj/item/implant/health/H = null
			if(active_record.implant)
				H = locate(active_record.implant)

			if((H) && (istype(H)))
				data["health"] = H.sensehealth()
			data["realname"] = sanitize(active_record.dna.real_name)
			data["unidentity"] = active_record.dna.uni_identity
			data["strucenzymes"] = active_record.dna.struc_enzymes
		if(selected_pod && (selected_pod in pods) && selected_pod.biomass >= CLONE_BIOMASS)
			data["podready"] = 1
		else
			data["podready"] = 0

	return data

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return 1

	if(loading)
		return

	if(href_list["scan"] && scanner && scanner.occupant)
		scantemp = "Scanner ready."

		loading = 1

		spawn(20)
			if(can_brainscan() && scan_mode)
				scan_mob(scanner.occupant, scan_brain = 1)
			else
				scan_mob(scanner.occupant)

			loading = 0
			SSnanoui.update_uis(src)


	//No locking an open scanner.
	else if((href_list["lock"]) && (!isnull(scanner)))
		if((!scanner.locked) && (scanner.occupant))
			scanner.locked = 1
		else
			scanner.locked = 0

	else if(href_list["view_rec"])
		active_record = locate(href_list["view_rec"])
		if(istype(active_record,/datum/dna2/record))
			if((isnull(active_record.ckey)))
				qdel(active_record)
				temp = "<span class=\"bad\">Error: Record corrupt.</span>"
			else
				menu = 3
		else
			active_record = null
			temp = "<span class=\"bad\">Error: Record missing.</span>"

	else if(href_list["del_rec"])
		if((!active_record) || (menu < 3))
			return
		if(menu == 3) //If we are viewing a record, confirm deletion
			temp = "Please confirm that you want to delete the record?"
			menu = 4

		else if(menu == 4)
			var/obj/item/card/id/C = usr.get_active_hand()
			if(istype(C)||istype(C, /obj/item/pda))
				if(check_access(C))
					records.Remove(active_record)
					qdel(active_record)
					temp = "Record deleted."
					menu = 2
				else
					temp = "<span class=\"bad\">Error: Access denied.</span>"

	else if(href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if((isnull(diskette)) || isnull(diskette.buf))
					temp = "<span class=\"bad\">Error: The disk's data could not be read.</span>"
					SSnanoui.update_uis(src)
					return
				if(isnull(active_record))
					temp = "<span class=\"bad\">Error: No active record was found.</span>"
					menu = 1
					SSnanoui.update_uis(src)
					return

				active_record = diskette.buf.copy()

				temp = "Load successful."

			if("eject")
				if(!isnull(diskette))
					diskette.loc = loc
					diskette = null

	else if(href_list["save_disk"]) //Save to disk!
		if((isnull(diskette)) || (diskette.read_only) || (isnull(active_record)))
			temp = "<span class=\"bad\">Error: The data could not be saved.</span>"
			SSnanoui.update_uis(src)
			return

		// DNA2 makes things a little simpler.
		diskette.buf=active_record.copy()
		diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				diskette.buf.types=DNA2_BUF_UI
			if("ue")
				diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				diskette.buf.types=DNA2_BUF_SE
		diskette.name = "data disk - '[active_record.dna.real_name]'"
		temp = "Save \[[href_list["save_disk"]]\] successful."

	else if(href_list["refresh"])
		SSnanoui.update_uis(src)

	else if(href_list["selectpod"])
		var/obj/machinery/clonepod/selected = locate(href_list["selectpod"])
		if(istype(selected) && (selected in pods))
			selected_pod = selected

	else if(href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pods.len)
				temp = "<span class=\"bad\">Error: No cloning pod detected.</span>"
			else
				var/obj/machinery/clonepod/pod = selected_pod
				var/cloneresult
				if(!selected_pod)
					temp = "<span class=\"bad\">Error: No cloning pod selected.</span>"
				else if(pod.occupant)
					temp = "<span class=\"bad\">Error: The cloning pod is currently occupied.</span>"
				else if(pod.biomass < CLONE_BIOMASS)
					temp = "<span class=\"bad\">Error: Not enough biomass.</span>"
				else if(pod.mess)
					temp = "<span class=\"bad\">Error: The cloning pod is malfunctioning.</span>"
				else if(!config.revival_cloning)
					temp = "<span class=\"bad\">Error: Unable to initiate cloning cycle.</span>"
				else
					cloneresult = pod.growclone(C)
					if(cloneresult)
						if(cloneresult > 0)
							temp = "Initiating cloning cycle..."
						records.Remove(C)
						qdel(C)
						menu = 1
					else
						temp = "[C.name] => <font class='bad'>Initialisation failure.</font>"

		else
			temp = "<span class=\"bad\">Error: Data corruption.</span>"

	else if(href_list["menu"])
		menu = text2num(href_list["menu"])
		temp = ""
		scantemp = "Scanner ready."
	else if(href_list["toggle_mode"])
		if(can_brainscan())
			scan_mode = !scan_mode
		else
			scan_mode = 0

	add_fingerprint(usr)
	SSnanoui.update_uis(src)
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject as mob, var/scan_brain = 0)
	if(stat & NOPOWER)
		return
	if(scanner.stat & (NOPOWER|BROKEN))
		return
	if(scan_brain && !can_brainscan())
		return
	if(subject.stat != DEAD)
		scantemp = "<span class=\"bad\">Error: Unable to scan living specimens.</span>"
		SSnanoui.update_uis(src)
		return
	if((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna) || (NO_SCAN in subject.dna.species.species_traits))
		scantemp = "<span class=\"bad\">Error: Unable to locate valid genetic data.</span>"
		SSnanoui.update_uis(src)
		return
	if(subject.get_int_organ(/obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/Brn = subject.get_int_organ(/obj/item/organ/internal/brain)
		if(istype(Brn))
			if(NO_SCAN in Brn.dna.species.species_traits)
				scantemp = "<span class=\"bad\">Error: Subject's brain is incompatible.</span>"
				SSnanoui.update_uis(src)
				return
	if(!subject.get_int_organ(/obj/item/organ/internal/brain))
		scantemp = "<span class=\"bad\">Error: No signs of intelligence detected.</span>"
		SSnanoui.update_uis(src)
		return
	if(subject.suiciding)
		scantemp = "<span class=\"bad\">Error: Subject's brain is not responding to scanning stimuli.</span>"
		SSnanoui.update_uis(src)
		return
	if((!subject.ckey) || (!subject.client))
		scantemp = "<span class=\"bad\">Error: Mental interface failure.</span>"
		SSnanoui.update_uis(src)
		return
	if((NOCLONE in subject.mutations) && scanner.scan_level < 2)
		scantemp = "<span class=\"bad\">Error: Mental interface failure.</span>"
		SSnanoui.update_uis(src)
		return
	if(scan_brain && !subject.get_int_organ(/obj/item/organ/internal/brain))
		scantemp = "<span class=\"bad\">Error: No brain found.</span>"
		SSnanoui.update_uis(src)
		return
	if(!isnull(find_record(subject.ckey)))
		scantemp = "Subject already in database."
		SSnanoui.update_uis(src)
		return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.ckey = subject.ckey
	var/extra_info = ""
	if(scan_brain)
		var/obj/item/organ/B = subject.get_int_organ(/obj/item/organ/internal/brain)
		B.dna.check_integrity()
		R.dna=B.dna.Clone()
		if(NO_SCAN in R.dna.species.species_traits)
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

	records += R
	scantemp = "Subject successfully scanned. " + extra_info
	SSnanoui.update_uis(src)

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in records)
		if(R.ckey == find_key)
			selected_record = R
			break
	return selected_record


/obj/machinery/computer/cloning/proc/can_brainscan()
	return (scanner && scanner.scan_level > 3)
