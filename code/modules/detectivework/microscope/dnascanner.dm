//DNA machine
/obj/machinery/dnaforensics
	name = "Анализатор ДНК"
	desc = "Высокотехнологичная машина, которая предназначена для правильного считывания образцов ДНК."
	icon = 'icons/obj/forensics.dmi'
	icon_state = "dnaopen"
	layer = BELOW_OBJ_LAYER
	anchored = 1
	density = 1

	var/obj/item/forensics/swab = null
	var/scanning = 0
	var/report_num = 0

/obj/machinery/dnaforensics/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/dnaforensics(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)

/obj/machinery/dnaforensics/attackby(obj/item/W as obj, mob/user as mob)

	if(swab)
		to_chat(user, "<span class='warning'>Внутри сканера уже есть пробирка.</span>")
		return

	if(istype(W, /obj/item/forensics/swab))
		to_chat(user, "<span class='notice'>Вы вставляете \the [W] в ДНК анализатор.</span>")
		user.unEquip(W)
		W.forceMove(src)
		swab = W
		update_icon()
		return
	..()

/obj/machinery/dnaforensics/attack_hand(mob/user)

	if(!swab)
		to_chat(user, "<span class='warning'>Сканер пуст!</span>")
		return
	scanning = 1
	update_icon()
	to_chat(user, "<span class='notice'>Сканер начинает с жужением анализировать содержимое пробирки \the [swab].</span>")

	if(!do_after(user, 25, src) || !swab)
		to_chat(user, "<span class='notice'>Вы перестали анализировать \the [swab].</span>")
		scanning = 0
		update_icon()

		return

	to_chat(user, "<span class='notice'>Печать отчета...</span>")
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
				data += "<span class='notice'>Группа крови: [bloodswab.dna[blood]]<br>\nДНК: [blood]</span><br><br>"
		else
			data += "\nДНК не найдено.<br>"
		report.info = "<b>Отчет №[report_num] по \n[src]</b><br>"
		report.info += "<b>\nАнализируемый объект:</b><br>[bloodswab.name]<br>[bloodswab.desc]<br><br>" + data
		report.forceMove(src.loc)
		report.update_icon()
		scanning = 0
		update_icon()
	return

/obj/machinery/dnaforensics/proc/remove_sample(mob/living/remover)
	if(!istype(remover) || remover.incapacitated() || !Adjacent(remover))
		return
	if(!swab)
		to_chat(remover, "<span class='warning'>Внутри сканера нет образца!.</span>")
		return
	to_chat(remover, "<span class='notice'>Вы вытащили \the [swab] из сканера.</span>")
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

/obj/machinery/dnaforensics/update_icon()
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
