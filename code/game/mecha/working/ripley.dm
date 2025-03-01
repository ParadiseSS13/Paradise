/obj/mecha/working/ripley
	desc = "Автономная тяговая механизированная единица «Рипли». Эта новая модель оснащена мощной защитой от опасностей, связанных с процессом добычи полезных ископаемых в открытом космосе."
	name = "APLU \"Ripley\""
	icon_state = "ripley"
	initial_icon = "ripley"
	step_in = 4 //Move speed, lower is faster.
	var/fast_pressure_step_in = 2 //step_in while in normal pressure conditions
	var/slow_pressure_step_in = 4 //step_in while in better pressure conditions
	mech_enter_time = 3 SECONDS
	max_temperature = 20000
	max_integrity = 200
	lights_power = 7
	deflect_chance = 15
	armor = list(MELEE = 40, BULLET = 20, LASER = 10, ENERGY = 20, BOMB = 40, RAD = 0, FIRE = 100, ACID = 100)
	max_equip = 6
	wreckage = /obj/structure/mecha_wreckage/ripley
	var/list/cargo = list()
	var/cargo_capacity = 15

	/// How many goliath hides does the Ripley have? Does not stack with other armor
	var/hides = 0

	/// How many drake hides does the Ripley have? Does not stack with other armor
	var/drake_hides = 0

	/// How many plates does the Ripley have? Does not stack with other armor
	var/plates = 0

/obj/mecha/working/ripley/Move()
	. = ..()
	if(.)
		collect_ore()
	update_pressure()

/obj/mecha/working/ripley/proc/collect_ore()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in equipment)
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in cargo
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, src))
				if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc)) //we can reach it and it's in front of us? grab it!
					ore.forceMove(ore_box)

/obj/mecha/working/ripley/Destroy()
	for(var/i in 1 to hides)
		new /obj/item/stack/sheet/animalhide/goliath_hide(get_turf(src))  //If a armor-plated ripley gets killed, all the armor drop
	for(var/i in 1 to plates)
		new /obj/item/stack/sheet/animalhide/armor_plate(get_turf(src))
	for(var/i in 1 to drake_hides)
		new /obj/item/stack/sheet/animalhide/ashdrake(get_turf(src))
	for(var/mob/M in src)
		if(M == occupant)
			continue
		M.loc = get_turf(src)
		M.loc.Entered(M)
		step_rand(M)
	for(var/atom/movable/A in cargo)
		A.loc = get_turf(src)
		var/turf/T = get_turf(A)
		if(T)
			T.Entered(A)
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/go_out()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/ripley/update_desc()
	. = ..()
	if(!hides && !plates && !drake_hides) // Just in case if armor is removed
		desc = initial(desc)
		return

	// Goliath hides
	if(hides)
		if(hides == HIDES_COVERED_FULL)
			desc = "Автономная тяговая механизированная единица «Рипли». На него установлен устрашающий панцирь, полностью состоящий из пластин шкуры голиафа — его пилот, должно быть, опытный охотник на монстров."
		else
			desc = "Автономная тяговая механизированная единица «Рипли». Его броня усилена пластинами из кожи голиафа."
		return

	// Metal plates
	if(plates)
		if(plates == PLATES_COVERED_FULL)
			desc = "Автономная тяговая механизированная единица «Рипли». Его броня полностью покрыта металлическими пластинами."
		else
			desc = "Автономная тяговая механизированная единица «Рипли». Его броня усилена металлическими пластинами."
		return

	// Drake hides
	if(drake_hides)
		if(drake_hides == DRAKE_HIDES_COVERED_FULL)
			desc = "Автономная тяговая механизированная единица «Рипли». Каждый уголок экзокостюма покрыт древней шкурой, создавая мощный щит. Пилот этого экзокостюма должен быть готов к сражениям на уровне легенд."
		if(drake_hides == DRAKE_HIDES_COVERED_MODERATE)
			desc = "Автономная тяговая механизированная единица «Рипли». Его броня украшена пластинами из драконьей кожи, внушая страх врагам и защищая пилота."
		if(drake_hides == DRAKE_HIDES_COVERED_SLIGHT)
			desc = "Автономная тяговая механизированная единица «Рипли». Броня этого экзокостюма лишь напоминает легенду: несколько пластин из драконьей кожи украшают его обшивку, словно редкие трофеи воина."
		return

/obj/mecha/working/ripley/update_overlays()
	. = ..()
// hides
	if(hides)
		if(hides == HIDES_COVERED_FULL)
			. += occupant ? "ripley-g-full" : "ripley-g-full-open"
		else
			. += occupant ? "ripley-g" : "ripley-g-open"
//plates
	if(plates)
		if(plates == PLATES_COVERED_FULL)
			. += occupant ? "ripley-m-full" : "ripley-m-full-open"
		else
			. += occupant ? "ripley-m" : "ripley-m-open"
//drake hides
	if(drake_hides)
		if(drake_hides == DRAKE_HIDES_COVERED_FULL)
			underlays.Cut()
			underlays += emissive_appearance(emissive_appearance_icon, occupant ? "ripley-d-full_lightmask" : "ripley-d-full-open_lightmask")
			. += occupant ? "ripley-d-full" : "ripley-d-full-open"
		else if(drake_hides == DRAKE_HIDES_COVERED_MODERATE)
			. += occupant ? "ripley-d-2" : "ripley-d-2-open"
		else if(drake_hides == DRAKE_HIDES_COVERED_SLIGHT)
			. += occupant ? "ripley-d" : "ripley-d-open"

/obj/mecha/working/ripley/examine_more(mob/user)
	. = ..()
	. += "<i>«Рипли» — это прочный и надёжный экзокостюм, первоначально произведенный Hephaestus Industries. \
	Сейчас он широко используется в секторе Ориона и за его пределами, являясь одним из самых распространённых экзокостюмов, когда-либо созданных. \
	Вскоре после начала производства Hephaestus передала права на выпуск «Рипли» другим корпорациям, получая отчисления по мере роста популярности экзокостюма.</i>"
	. += ""
	. += "<i>В зависимости от конфигурации «Рипли» можно использовать для многих целей, включая добычу полезных ископаемых, строительство и даже транспортировку грузов. \
	По сей день он остается одним из самых популярных мехов, когда-либо созданных, и Hephaestus получает значительную прибыль от продаж этой устаревшей, но прочной конструкции. \
	Как в случаях со всеми станционными мехами, Nanotrasen приобрела лицензию на производство «Рипли» на своих предприятиях.</i>"

/obj/mecha/working/ripley/firefighter
	desc = "Автономная тяговая механизированная единица «Огнеборец». Основан на базовом шасси «Рипли», обладает усовершенствованной термальной защитой и цистерной"
	name = "APLU \"Firefighter\""
	icon_state = "firefighter"
	initial_icon = "firefighter"
	max_temperature = 65000
	max_integrity = 250
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	lights_power = 7
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 60, RAD = 70, FIRE = 100, ACID = 100)
	max_equip = 5 // More armor, less tools
	wreckage = /obj/structure/mecha_wreckage/ripley/firefighter

/obj/mecha/working/ripley/firefighter/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Основанный на шасси «Рипли», первоначально разработанном Hephaestus Industries, «Огнеборец» представляет собой модификацию, созданную Nanotrasen по мере расширения горнодобывающих предприятий и необходимости в прочном, огнестойком экзокостюме. \
	Оборудованный термостойкой защитой «Огнеборец» стал популярным экзокостюмом среди горнодобывающих компаний, работающих в опасных условиях.</i>"
	. += ""
	. += "<i>С момента экспансии Nanotrasen на Эпсилон Эридана и их горнодобывающих операций на Лаваленде, «Огнеборец» стал более популярным среди опытных шахтеров, ищущих более безопасный и надёжный способ добычи полезных ископаемых даже в самых жарких условиях. \
	Кроме того, он нашел некоторое применение среди атмосферных техников, которые ценят его способность контролировать даже самые сильные плазменные пожары, одновременно защищая своего пилота.</i>"

/obj/mecha/working/ripley/deathripley
	name = "DEATH-RIPLEY"
	desc = "ОХ БЛЯДЬ, ЭТО ОТРЯД СМЕРТИ, НАМ ВСЕМ ПИЗДЕЦ!"
	icon_state = "deathripley"
	initial_icon = "deathripley"
	step_in = 3
	slow_pressure_step_in = 3
	opacity=0
	max_temperature = 65000
	max_integrity = 300
	lights_power = 7
	armor = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 0, BOMB = 70, RAD = 0, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/ripley/deathripley
	step_energy_drain = 0
	normal_step_energy_drain = 0

/obj/mecha/working/ripley/deathripley/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)
	return

/obj/mecha/working/ripley/deathripley/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Функциональный, искусно выполненный коллекционный реквизит для популярного головид-шоу «Отряд смерти», финансируемого Nanotrasen. \
	Модернизированное и перекрашенное шасси «Рипли», «Рипли Смерти» был создан и использован лидером Отряда Смерти, мастер-сержантом Киллджоем, во время решающей битвы с Паучьей Королевой «Ксеркс» в конце 4-го сезона. \
	На мехе стоит подпись инженера команды, капрала Айронхеда, который помогал Киллджою в его постройке.</i>"
	. += ""
	. += "<i>Подобные копии являются предметом коллекционирования среди самых преданных поклонников «Отряда Смерти». \
	Даже произошла ссора, когда человек, одетый в плохо сшитый костюм Киллджоя, попытался убить коллекционера, чтобы получить «Рипли Смерти», которого позже отправили в психиатрическую больницу после крика: «ОТРЯД СМЕРТИ РЕАЛЕН!»</i>"

/obj/mecha/working/ripley/mining
	name = "APLU \"Miner\""

/obj/mecha/working/ripley/mining/proc/prepare_equipment()
	SHOULD_CALL_PARENT(FALSE)

	// Diamond drill as a treat
	var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
	D.attach(src)

	// Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	// Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	prepare_equipment()

/obj/mecha/working/ripley/mining/old
	desc = "Старый, пыльный шахтёрский «Рипли»."
	name = "APLU \"Miner\""
	obj_integrity = 75 //Low starting health

/obj/mecha/working/ripley/mining/old/add_cell()
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge

/obj/mecha/working/ripley/mining/old/prepare_equipment()
	//Attach drill
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)
	QDEL_LIST_CONTENTS(trackers) //Deletes the beacon so it can't be found easily

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	if(..())
		return
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"])
		if(O && (O in cargo))
			occupant_message("<span class='notice'>Вы выгрузили [O.declent_ru(ACCUSATIVE)].</span>")
			O.loc = get_turf(src)
			cargo -= O
			var/turf/T = get_turf(O)
			if(T)
				T.Entered(O)
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - length(cargo)]")

/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(length(cargo))
		for(var/obj/O in cargo)
			output += "<a href='byond://?src=[UID()];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/ex_act(severity)
	..()
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30 / severity))
			cargo -= O
			O.forceMove(drop_location())

/obj/mecha/working/ripley/proc/update_pressure()
	if(thrusters_active)
		return // Don't calculate this if they have thrusters on, this is calculated right after domove because of course it is

	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

/obj/mecha/working/ripley/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		desc += "</br><span class='danger'>Оборудование меха опасно искрится!</span>"
	return ..()
