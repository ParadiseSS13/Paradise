// DNA machine
/obj/machinery/dnaforensics
	name = "\improper DNA analyzer"
	desc = "A high-tech machine that is designed to sequence DNA samples."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "dna-open"
	anchored = TRUE
	density = TRUE

	var/obj/item/forensics/swab = null
	/// is currently scanning
	var/scanning = FALSE
	/// Global number of reports ran from that machine type
	var/report_num = FALSE

/obj/machinery/dnaforensics/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/dnaforensics(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/dnaforensics/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Click while holding a sample</b> to insert a sample.</span>"
	. += "<span class='notice'><b>Alt-Click</b> to eject the current sample.</span>"
	. += "<span class='notice'><b>Click with an empty hand</b> to analyze the current sample.</span>"

/obj/machinery/dnaforensics/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/forensics))
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You must close the panel!</span>")
		return ITEM_INTERACT_COMPLETE

	if(swab)
		to_chat(user, "<span class='warning'>There is already a sample inside the scanner.</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/forensics/swab))
		to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")
		user.unequip(used)
		used.forceMove(src)
		swab = used
		update_icon()
	else
		to_chat(user, "<span class='notice'>This is not a compatible sample!</span>")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/dnaforensics/attack_hand(mob/user)

	if(!swab)
		to_chat(user, "<span class='warning'>The scanner is empty!</span>")
		return
	scanning = TRUE
	update_appearance(UPDATE_ICON)
	to_chat(user, "<span class='notice'>The scanner begins to hum as you analyze [swab].</span>")

	if(!do_after(user, 2.5 SECONDS, src) || QDELETED(swab))
		to_chat(user, "<span class='notice'>You have stopped analyzing [swab || "the swab"].</span>")
		scanning = FALSE
		update_appearance(UPDATE_ICON)
		return

	to_chat(user, "<span class='notice'>Printing report...</span>")
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report_num++

	var/obj/item/forensics/swab/bloodswab = swab
	report.name = ("DNA scanner report no. [++report_num]: [bloodswab.name]")
	// dna data itself
	var/data = "No analysis data available."
	if(!isnull(bloodswab.dna))
		data = "Spectrometric analysis on the provided sample determined the presence of DNA. DNA String(s) found: [length(bloodswab.dna)].<br><br>"
		for(var/blood in bloodswab.dna)
			data += "<span class='notice'>Blood type: [bloodswab.dna[blood]]<br>\nDNA: [blood]<br><br></span>"
	else
		data += "\nNo DNA found.<br>"
	report.info = "<b>Report number: [report_num]</b><br>"
	report.info += "<b>\nAnalyzed object:</b><br>[bloodswab.name]<br>[bloodswab.desc]<br><br>" + data
	report.forceMove(get_turf(src))
	report.update_icon()
	scanning = FALSE
	update_appearance(UPDATE_ICON)

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || HAS_TRAIT(remover, TRAIT_HANDS_BLOCKED) || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, "<span class='warning'>There is no sample inside the scanner!</span>")
		return
	to_chat(remover, "<span class='notice'>You remove [swab] from the scanner.</span>")
	swab.forceMove(get_turf(src))
	remover.put_in_hands(swab)
	swab = null
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/dnaforensics/AltClick()
	remove_sample(usr)

/obj/machinery/dnaforensics/MouseDrop(atom/other)
	if(usr == other)
		remove_sample(usr)
		return
	return ..()

/obj/machinery/dnaforensics/update_icon_state()
	if(scanning)
		icon_state = "dna-working"
	else if(swab)
		icon_state = "dna-closed"
	else
		icon_state = "dna-open"

/obj/machinery/dnaforensics/screwdriver_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_screwdriver(user, "dna-open-unpowered", "dna-open", I)

/obj/machinery/dnaforensics/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/dnaforensics/crowbar_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)

// Microscope code itself
/obj/machinery/microscope
	name = "microscope"
	desc = "A microscope capable of magnifying images up to 3000 times."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE
	var/obj/item/sample = null
	var/report_num = 0
	var/fingerprint_complete = 6

/obj/machinery/microscope/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microscope(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/microscope/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Click while holding a sample</b> to insert a sample.</span>"
	. += "<span class='notice'><b>Alt-Click</b> to eject the current sample.</span>"
	. += "<span class='notice'><b>Click with an empty hand</b> to study the current sample.</span>"

/obj/machinery/microscope/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/forensics/swab) && !istype(used, /obj/item/sample))
		return ..()

	if(panel_open)
		to_chat(user, "<span class='warning'>You must close the panel!</span>")
		return ITEM_INTERACT_COMPLETE

	if(sample)
		to_chat(user, "<span class='warning'>There is already a sample in the microscope!</span>")
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/forensics/swab)|| istype(used, /obj/item/sample/fibers) || istype(used, /obj/item/sample/print))
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You insert [used] into the microscope.</span>")
		user.unequip(used)
		used.forceMove(src)
		sample = used
		update_appearance(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, "<span class='warning'>There is no sample in the microscope to study.</span>")
		return

	add_fingerprint(user)
	to_chat(user, "<span class='notice'>The microscope buzzes as you study [sample].</span>")

	if(!do_after(user, 2.5 SECONDS, src) || !sample)
		to_chat(user, "<span class='notice'>You stop studying [sample].</span>")
		return

	to_chat(user, "<span class='notice'>Printing Report...</span>")
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report_num++

	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample

		report.name = ("Forensic report no. [++report_num]: [swab.name]")
		report.info = "<b>Report number: [report_num]</b><br>"
		report.info += "<b>Analyzed object:</b><br>[swab.name]<br><br>"

		if(swab.gsr)
			report.info += "Gunpowder residue found. Caliber: [swab.gsr]."
		else
			report.info += "Powder residue from the bullet was not found."

	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		report.name = ("Report on fiber sample no. [++report_num]: [fibers.name]")
		report.info = "<b>Report number: [report_num]</b><br>"
		report.info += "<b>Analyzed object:</b><br>[fibers.name]<br><br>"
		if(fibers.evidence)
			report.info += "Molecular analysis on the provided sample determined the presence of the following unique fiber strands:<br><br>"
			for(var/fiber in fibers.evidence)
				report.info += "<span class='notice'>Most Likely Match: [fiber]<br><br></span>"
		else
			report.info += "No fibers found."
	else if(istype(sample, /obj/item/sample/print))
		report.name = ("Fingerprint Analysis Report No. [report_num]: [sample.name]")
		report.info = "<b>Report number: [report_num]</b><br>"
		report.info += "<b>Fingerprint Analysis Report No. [report_num]</b>: [sample.name]<br>"
		var/obj/item/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			report.info += "<br>Surface analysis identified the following unique fingerprints:<br><br>"
			for(var/prints in card.evidence)
				report.info += "<span class='notice'>Fingerprint: </span>"
				if(!is_complete_print(prints))
					report.info += "INCOMPLETE PRINT"
				else
					report.info += "[prints]"
				report.info += "<br>"
		else
			report.info += "No analysis information available."

	if(report)
		report.update_icon()
		if(report.info)
			to_chat(user, report.info)
	return

/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, "<span class='warning'>There is no sample inside the microscope!</span>")
		return
	to_chat(remover, "<span class='notice'>you removed [sample] from the microscope.</span>")
	sample.forceMove(get_turf(src))
	remover.put_in_hands(sample)
	sample = null
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/microscope/proc/is_complete_print(print)
	return stringpercent(print) <= fingerprint_complete

/obj/machinery/microscope/AltClick()
	remove_sample(usr)

/obj/machinery/microscope/MouseDrop(atom/other)
	if(usr == other)
		remove_sample(usr)
	else
		return ..()

/obj/machinery/microscope/update_icon_state()
	icon_state = "microscope"
	if(sample)
		icon_state += "slide"

/obj/machinery/microscope/screwdriver_act(mob/user, obj/item/I)
	if(sample)
		return
	. = TRUE
	default_deconstruction_screwdriver(user, "microscope_off", "microscope", I)

/obj/machinery/microscope/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/microscope/crowbar_act(mob/user, obj/item/I)
	if(sample)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)
