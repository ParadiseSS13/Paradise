// Designs
/datum/design/dnaforensics
	name = "Machine Design (Анализатор ДНК)"
	desc = "Анализатор ДНК для точного анализа ДНК объектов."
	id = "dnaforensics"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/dnaforensics
	category = list ("Misc. Machinery")

/obj/item/circuitboard/dnaforensics
	name = "circuit board (Анализатор ДНК)"
	build_path = /obj/machinery/dnaforensics
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,)

/datum/design/microscope
	name = "Machine Design (Электронный микроскоп)"
	desc = "Электронный микроскоп, способный увеличивать изображение в 3000 раз."
	id = "microscope"
	req_tech = list("programming" = 2, "combat" = 2, "magnets" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/microscope
	category = list ("Misc. Machinery")

/obj/item/circuitboard/microscope
	name = "circuit board (Электронный микроскоп)"
	build_path = /obj/machinery/microscope
	board_type = "machine"
	origin_tech = "programming=2;combat=2"
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

// DNA machine
/obj/machinery/dnaforensics
	name = "\improper Анализатор ДНК"
	desc = "Высокотехнологичная машина, которая предназначена для правильного считывания образцов ДНК."
	icon = 'modular_ss220/detective_rework/icons/forensics.dmi'
	icon_state = "dnaopen"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

	var/obj/item/forensics/swab = null
	var/scanning = FALSE
	var/report_num = FALSE

/obj/machinery/dnaforensics/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/dnaforensics(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/dnaforensics/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob)

	if(swab)
		to_chat(user, span_warning("Внутри сканера уже есть пробирка."))
		return

	if(istype(W, /obj/item/forensics/swab))
		to_chat(user, span_notice("Вы вставляете [W] в ДНК анализатор."))
		user.unequip(W)
		W.forceMove(src)
		swab = W
		update_icon()
		return
	..()

/obj/machinery/dnaforensics/attack_hand(mob/user)

	if(!swab)
		to_chat(user, span_warning("Сканер пуст!"))
		return
	scanning = TRUE
	update_icon()
	to_chat(user, span_notice("Сканер начинает с жужением анализировать содержимое пробирки [swab]."))

	if(!do_after(user, 25, src) || !swab)
		to_chat(user, span_notice("Вы перестали анализировать [swab]."))
		scanning = FALSE
		update_icon()

		return

	to_chat(user, span_notice("Печать отчета..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.overlays = list("paper_stamped")
	report_num++

	if(swab)
		var/obj/item/forensics/swab/bloodswab = swab
		report.name = ("Отчет ДНК сканера №[++report_num]: [bloodswab.name]")
		//dna data itself
		var/data = "Нет доступных данных по анализу."
		if(bloodswab.dna != null)
			data = "Спектрометрический анализ на предоставленном образце определил наличие нитей ДНК в количестве [bloodswab.dna.len].<br><br>"
			for(var/blood in bloodswab.dna)
				data += span_notice("Группа крови: [bloodswab.dna[blood]]<br>\nДНК: [blood]<br><br>")
		else
			data += "\nДНК не найдено.<br>"
		report.info = "<b>Отчет №[report_num] по \n[src]</b><br>"
		report.info += "<b>\nАнализируемый объект:</b><br>[bloodswab.name]<br>[bloodswab.desc]<br><br>" + data
		report.forceMove(src.loc)
		report.update_icon()
		scanning = FALSE
		update_icon()
	return

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, span_warning("Внутри сканера нет образца!."))
		return
	to_chat(remover, span_notice("Вы вытащили [swab] из сканера."))
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
	name = "\improper Электронный микроскоп"
	desc = "Высокотехнологичный микроскоп, способный увеличивать изображение до 3000 раз."
	icon = 'modular_ss220/detective_rework/icons/forensics.dmi'
	icon_state = "microscope"
	anchored = TRUE
	density = TRUE

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

/obj/machinery/microscope/attackby__legacy__attackchain(obj/item/W as obj, mob/user as mob)

	if(sample)
		to_chat(user, span_warning("В микроскопе уже есть образец!"))
		return

	if(istype(W, /obj/item/forensics/swab)|| istype(W, /obj/item/sample/fibers) || istype(W, /obj/item/sample/print))
		add_fingerprint(user)
		to_chat(user, span_notice("Вы вставили [W] в микроскоп."))
		user.unequip(W)
		W.forceMove(src)
		sample = W
		update_icon()

		return
	..()

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, span_warning("В микроскопе нет образца для анализа."))
		return

	add_fingerprint(user)
	to_chat(user, span_notice("Микроскоп жужжит, пока вы анализируете [sample]."))

	if(!do_after(user, 25, src) || !sample)
		to_chat(user, span_notice("Вы перестаёте анализировать [sample]."))
		return

	to_chat(user, span_notice("Печать отчета..."))
	var/obj/item/paper/report = new(get_turf(src))
	report.stamped = list(/obj/item/stamp)
	report.overlays = list("paper_stamped")
	report_num++

	if(istype(sample, /obj/item/forensics/swab))
		var/obj/item/forensics/swab/swab = sample

		report.name = ("Криминалистический отчет №[++report_num]: [swab.name]")
		report.info = "<b>Анализируемый объект:</b><br>[swab.name]<br><br>"

		if(swab.gsr)
			report.info += "Определен остаток от пули [swab.gsr] калибра."
		else
			report.info += "Пороховой остаток от пули не найден."

	else if(istype(sample, /obj/item/sample/fibers))
		var/obj/item/sample/fibers/fibers = sample
		report.name = ("Отчет по фрагменту ткани №[++report_num]: [fibers.name]")
		report.info = "<b>Анализируемый объект:</b><br>[fibers.name]<br><br>"
		if(fibers.evidence)
			report.info = "Молекулярный анализ на предоставленном образце определил наличие уникальных волоконных струн.<br><br>"
			for(var/fiber in fibers.evidence)
				report.info += span_notice("Наиболее вероятное совпадение: [fiber]<br><br>")
		else
			report.info += "Волокна не найдены."
	else if(istype(sample, /obj/item/sample/print))
		report.name = ("Отчет по анализу отпечатков пальцев №[report_num]: [sample.name]")
		report.info = "<b>Отчет об анализе отпечатков пальцев №[report_num]</b>: [sample.name]<br>"
		var/obj/item/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			report.info += "<br>Поверхностный анализ определил следующие уникальные строки отпечатков пальцев:<br><br>"
			for(var/prints in card.evidence)
				report.info += span_notice("Строка отпечатков пальцев: ")
				if(!is_complete_print(prints))
					report.info += "НЕПОЛНЫЙ ОТПЕЧАТОК"
				else
					report.info += "[prints]"
				report.info += "<br>"
		else
			report.info += "Информация по анализу отсутствует."

	if(report)
		report.update_icon()
		if(report.info)
			to_chat(user, report.info)
	return

/obj/machinery/microscope/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!sample)
		to_chat(remover, span_warning("Внутри микроскопа нет образца!"))
		return
	to_chat(remover, span_notice("Вы вытащили [sample] из микроскопа."))
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

