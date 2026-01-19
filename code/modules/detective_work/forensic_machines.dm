// DNA machine
/obj/machinery/dnaforensics
	name = "\improper DNA analyzer"
	desc = "A high-tech machine that is designed to sequence DNA samples."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "dna-open"
	anchored = TRUE
	density = TRUE

	var/obj/item/sample/swab/swab = null
	/// is currently scanning
	var/scanning = FALSE
	/// Global number of reports ran from that machine type
	var/report_num = FALSE
	var/list/allowed_types = list(
		/obj/item/sample/swab/dna
	)

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
	. += SPAN_NOTICE("<b>Click while holding a sample</b> to insert a sample.")
	. += SPAN_NOTICE("<b>Alt-Click</b> to eject the current sample.")
	. += SPAN_NOTICE("<b>Click with an empty hand</b> to analyze the current sample.")

/obj/machinery/dnaforensics/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_type_in_list(used, allowed_types))
		to_chat(user, SPAN_WARNING("This is not a compatible sample!"))
		return ..()

	if(panel_open)
		to_chat(user, SPAN_WARNING("You must close the panel!"))
		return ITEM_INTERACT_COMPLETE

	if(swab)
		to_chat(user, SPAN_WARNING("There is already a sample inside the scanner."))
		return ITEM_INTERACT_COMPLETE

	to_chat(user, SPAN_NOTICE("You insert [used] into [src]."))
	user.unequip(used)
	used.forceMove(src)
	swab = used
	update_icon()
	return ITEM_INTERACT_COMPLETE

/obj/machinery/dnaforensics/attack_hand(mob/user)
	if(!swab)
		to_chat(user, SPAN_WARNING("The scanner is empty!"))
		return

	scanning = TRUE
	update_appearance(UPDATE_ICON)
	to_chat(user, SPAN_NOTICE("The scanner begins to hum as you analyze [swab]."))
	playsound(src, 'sound/machines/banknote_counter.ogg', 30, FALSE)

	if(!do_after(user, 2.5 SECONDS, target = src) || QDELETED(swab))
		to_chat(user, SPAN_NOTICE("You have stopped analyzing [swab || "the swab"]."))
		scanning = FALSE
		update_appearance(UPDATE_ICON)
		return

	to_chat(user, SPAN_NOTICE("Printing report..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report_num++

	swab.report(report, src, report_num)

	report.forceMove(get_turf(src))
	report.update_icon()
	scanning = FALSE
	update_appearance(UPDATE_ICON)

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || HAS_TRAIT(remover, TRAIT_HANDS_BLOCKED) || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, SPAN_WARNING("There is no sample inside the scanner!"))
		return
	to_chat(remover, SPAN_NOTICE("You remove [swab] from the scanner."))
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
	desc = "A microscope capable of magnifying images up to 3000 times. Used in analyzing fibers, fingerprints, and gunpower residue samples."
	icon = 'icons/obj/forensics/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE
	var/obj/item/sample/sample
	var/report_num = 0
	var/list/allowed_types = list(
		/obj/item/sample/fibers,
		/obj/item/sample/print,
		/obj/item/sample/swab/gunpowder
	)

/obj/machinery/microscope/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microscope(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/microscope/examine(mob/user)
	. = ..()
	. += SPAN_NOTICE("<b>Click while holding a sample</b> to insert a sample.")
	. += SPAN_NOTICE("<b>Alt-Click</b> to eject the current sample.")
	. += SPAN_NOTICE("<b>Click with an empty hand</b> to study the current sample.")

/obj/machinery/microscope/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_type_in_list(used, allowed_types))
		return ..()

	if(panel_open)
		to_chat(user, SPAN_WARNING("You must close the panel!"))
		return ITEM_INTERACT_COMPLETE

	if(sample)
		to_chat(user, SPAN_WARNING("There is already a sample in the microscope!"))
		return ITEM_INTERACT_COMPLETE

	add_fingerprint(user)
	to_chat(user, SPAN_NOTICE("You insert [used] into the microscope."))
	user.unequip(used)
	used.forceMove(src)
	sample = used
	update_appearance(UPDATE_ICON_STATE)
	return ITEM_INTERACT_COMPLETE

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, SPAN_WARNING("There is no sample in the microscope to study."))
		return

	add_fingerprint(user)
	to_chat(user, SPAN_NOTICE("The microscope buzzes as you study [sample]."))

	playsound(src, 'sound/machines/terminal_processing.ogg', 15, TRUE)
	if(!do_after(user, 2.5 SECONDS, target = src) || !sample)
		to_chat(user, SPAN_NOTICE("You stop studying [sample]."))
		return

	to_chat(user, SPAN_NOTICE("Printing Report..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report_num++

	sample.report(report, src, report_num)

	if(report)
		report.update_icon()
		if(report.info)
			to_chat(user, chat_box_notice(report.info))
	return



/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, SPAN_WARNING("There is no sample inside the microscope!"))
		return
	to_chat(remover, SPAN_NOTICE("you removed [sample] from the microscope."))
	sample.forceMove(get_turf(src))
	remover.put_in_hands(sample)
	sample = null
	update_appearance(UPDATE_ICON_STATE)

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
