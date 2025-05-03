// Designs
/datum/design/dnaforensics
	name = "Machine Design (DNA analyzer)"
	desc = "DNA analyzer for forensic DNA analysis of objects."
	id = "dnaforensics"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dnaforensics
	category = list("Misc. Machinery")

/obj/item/circuitboard/dnaforensics
	name = "circuit board (DNA analyzer)"
	build_path = /obj/machinery/dnaforensics
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)

/datum/design/microscope
	name = "Machine Design (Forensic Microscope)"
	desc = "Microscope capable of magnifying images 3000 times"
	id = "microscope"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microscope
	category = list("Misc. Machinery")

/obj/item/circuitboard/microscope
	name = "circuit board (Microscope)"
	build_path = /obj/machinery/microscope
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

// DNA machine
/obj/machinery/dnaforensics
	name = "\improper DNA analyzer"
	desc = "A high-tech machine that is designed to sequence DNA samples."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "dnaopen"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	new_attack_chain = FALSE

	var/obj/item/forensics/swab = null
	///is currently scanning
	var/scanning = FALSE
	///Global number of reports ran from that machine type
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
	. += "<span class='notice'>You can <b>Alt-Click</b> to eject the current sample. <b>Click while holding a sample</b> to insert a sample. <b>Click with an empty hand</b> to operate.</span>"

/obj/machinery/dnaforensics/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob)

	if(swab)
		to_chat(user, "<span class='warning'>There is already a test tube inside the scanner.</span>")
		return

	if(istype(W, /obj/item/forensics/swab))
		to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
		user.unequip(W)
		W.forceMove(src)
		swab = W
		update_icon()
		return
	else
		to_chat(user, "<span class='notice'>This is not a compatable sample!</span>")

	..()

/obj/machinery/dnaforensics/attack_hand(mob/user)

	if(!swab)
		to_chat(user, "<span class='warning'>The scanner is empty!</span>")
		return
	scanning = TRUE
	update_icon()
	to_chat(user, "<span class='notice'>The scanner begins to hum and analyze the contents of the tube containing [swab].</span>")

	if(!do_after(user, 2.5 SECONDS, src) || !swab)
		to_chat(user, "<span class='notice'>You have stopped analyzing [swab]</span>")
		scanning = FALSE
		update_icon()

		return

	to_chat(user, "<span class='notice'>Printing report...</span>")
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.overlays = list("paper_stamped")
	report_num++

	if(swab)
		var/obj/item/forensics/swab/bloodswab = swab
		report.name = ("DNA scanner report no.[++report_num]: [bloodswab.name]")
		//dna data itself
		var/data = "No analysis data available."
		if(!isnull(bloodswab.dna))
			data = "Spectrometric analysis on the provided sample determined the presence of DNA strands in the amount [bloodswab.dna.len].<br><br>"
			for(var/blood in bloodswab.dna)
				data += "<span class='notice'>Blood type: [bloodswab.dna[blood]]<br>\nDNA: [blood]<br><br></span>"
		else
			data += "\nNo DNA found.<br>"
		report.info = "<b>Report number: [report_num] по \n[src]</b><br>"
		report.info += "<b>\nAnalyzed object:</b><br>[bloodswab.name]<br>[bloodswab.desc]<br><br>" + data
		report.forceMove(src.loc)
		report.update_icon()
		scanning = FALSE
		update_icon()

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, "<span class='warning'>There is no sample inside the scanner!</span>")
		return
	to_chat(remover, "<span class='notice'>you removed out [swab] from the scanner.</span>")
	swab.forceMove(get_turf(src))
	remover.put_in_hands(swab)
	swab = null
	update_icon()

/obj/machinery/dnaforensics/AltClick()
	remove_sample(usr)

/obj/machinery/dnaforensics/MouseDrop(atom/other)
	if(usr == other)
		remove_sample(usr)
	else
		return ..()

/obj/machinery/dnaforensics/update_icon_state()
	icon_state = "dnaopen"
	if(swab)
		icon_state = "dnaclosed"
		if(scanning)
			icon_state = "dnaworking"

/obj/machinery/dnaforensics/screwdriver_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_screwdriver(user, "dnaopenunpowered", "dnaopen", I)

/obj/machinery/dnaforensics/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/dnaforensics/crowbar_act(mob/user, obj/item/I)
	if(swab)
		return
	. = TRUE
	default_deconstruction_crowbar(user, I)

// Microscope code itself
// This is the output of the stringpercent(print) proc, and means about 80% of
// the print must be there for it to be complete.  (Prints are 32 digits)
/obj/machinery/microscope
	name = "\improper Microscope"
	desc = "A microscope capable of magnifying images up to 3000 times."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE
	new_attack_chain = FALSE

	var/obj/item/sample = null
	var/report_num = FALSE
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
	. += "<span class='notice'>You can <b>Alt-Click</b> to eject the current sample. <b>Click while holding a sample</b> to insert a sample. <b>Click with an empty hand</b> to operate.</span>"

/obj/machinery/microscope/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob)

	if(sample)
		to_chat(user, "<span class='warning'>There is already a sample in the microscope!</span>")
		return

	if(istype(W, /obj/item/forensics/swab)|| istype(W, /obj/item/sample/fibers) || istype(W, /obj/item/sample/print))
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You inserted [W] into the microscope.</span>")
		user.unequip(W)
		W.forceMove(src)
		sample = W
		update_icon()

		return
	..()

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, "<span class='warning'>There is no sample in the microscope to analyze.</span>")
		return

	add_fingerprint(user)
	to_chat(user, "<span class='notice'>The microscope buzzes while you analyze [sample].</span>")

	if(!do_after(user, 25, src) || !sample)
		to_chat(user, "<span class='notice'>You stop analyzing [sample].</span>")
		return

	to_chat(user, "<span class='notice'>Printing Report...</span>")
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.overlays = list("paper_stamped")
	report_num++

	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample

		report.name = ("Forensic report no.[++report_num]: [swab.name]")
		report.info = "<b>Analyzed object:</b><br>[swab.name]<br><br>"

		if(swab.gsr)
			report.info += "Gunpowder residue found. Caliber: [swab.gsr]."
		else
			report.info += "Powder residue from the bullet was not found."

	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		report.name = ("Report on tissue fragment no.[++report_num]: [fibers.name]")
		report.info = "<b>Analyzed object:</b><br>[fibers.name]<br><br>"
		if(fibers.evidence)
			report.info = "Molecular analysis on the provided sample determined the presence of unique fiber strings.<br><br>"
			for(var/fiber in fibers.evidence)
				report.info += "<span class='notice'>Most Likely Match: [fiber]<br><br></span>"
		else
			report.info += "No fibers found."
	else if(istype(sample, /obj/item/sample/print))
		report.name = ("Fingerprint Analysis Report No.[report_num]: [sample.name]")
		report.info = "<b>Fingerprint Analysis Report No. [report_num]</b>: [sample.name]<br>"
		var/obj/item/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			report.info += "<br>Surface analysis identified the following unique fingerprint strings:<br><br>"
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
	update_icon()

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
