//This is the output of the stringpercent(print) proc, and means about 80% of
//the print must be there for it to be complete.  (Prints are 32 digits)

//microscope code itself
/obj/machinery/microscope
	name = "Электронный микроскоп"
	desc = "Высокотехнологичный микроскоп, способный увеличивать изображение до 3000 раз."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "microscope"
	anchored = 1
	density = 1

	var/obj/item/sample = null
	var/report_num = 0
	var/fingerprint_complete = 6

/obj/machinery/microscope/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/microscope(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)

/obj/machinery/microscope/attackby(obj/item/W as obj, mob/user as mob)

	if(sample)
		to_chat(user, "<span class='warning'>В микроскопе уже есть образец!</span>")
		return

	if(istype(W, /obj/item/forensics/swab)|| istype(W, /obj/item/sample/fibers) || istype(W, /obj/item/sample/print))
		to_chat(user, "<span class='notice'>Вы вставили \the [W] в микроскоп.</span>")
		user.unEquip(W)
		W.forceMove(src)
		sample = W
		update_icon()

		return
	..()

/obj/machinery/microscope/attack_hand(mob/user)

	if(!sample)
		to_chat(user, "<span class='warning'>В микроскопе нет образца для анализа.</span>")
		return

	to_chat(user, "<span class='notice'>Микроскоп жужжит, пока вы анализируете \the [sample].</span>")

	if(!do_after(user, 25, src) || !sample)
		to_chat(user, "<span class='notice'>Вы перестаёте анализировать \the [sample].</span>")
		return

	to_chat(user, "<span class='notice'>Печать отчета...</span>")
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
				report.info += "<span class='notice'>Наиболее вероятное совпадение: [fiber]</span><br><br>"
		else
			report.info += "Волокна не найдены."
	else if(istype(sample, /obj/item/sample/print))
		report.name = ("Отчет по анализу отпечатков пальцев №[report_num]: [sample.name]")
		report.info = "<b>Отчет об анализе отпечатков пальцев №[report_num]</b>: [sample.name]<br>"
		var/obj/item/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			report.info += "<br>Поверхностный анализ определил следующие уникальные строки отпечатков пальцев:<br><br>"
			for(var/prints in card.evidence)
				report.info += "<span class='notice'>Строка отпечатков пальцев: </span>"
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
		to_chat(remover, "<span class='warning'>Внутри микроскопа нет образца!</span>")
		return
	to_chat(remover, "<span class='notice'>Вы вытащили \the [sample] из микроскопа.</span>")
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

/obj/machinery/microscope/update_icon()
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
