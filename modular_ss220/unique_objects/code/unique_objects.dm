// =========== statues ===========
/obj/structure/statue/bananium/clown/unique
	name = "статуя великого Хонкера"
	desc = "Искусно слепленная статуя из бананиума, бананового сока и непонятного белого материала. Судя по его выдающейся улыбки, двум золотым гудкам в руках и наряду, он был лучшим стендапером и шутником на станции. Полное имя, к сожалению плохо читаемо и затерто, похоже кто-то явно завидовал его таланту."
	icon = 'modular_ss220/unique_objects/icons/statue.dmi'
	icon_state = "clown_unique"
	oreAmount = 20

/obj/structure/statue/tranquillite/mime/unique
	name = "статуя гордости пантомимы"
	desc = "Искусно слепленная статуя из транквилиума, если приглядеться, то на статую надета старая униформа мима, перекрашенная под текстуру материала, а рот статуи заклеен скотчем. Похоже кто-то полностью отдавал себя искусству пантомимы. На груди виднеется медаль с еле различимой закрашенной надписью \"За Отвагу\", поверх которой написано \"За Военные Преступления\"."
	icon = 'modular_ss220/unique_objects/icons/statue.dmi'
	icon_state = "mime_unique"
	oreAmount = 20

/obj/structure/statue/elwycco
	name = "Camper Hunter"
	desc = "Похоже это какой-то очень важный человек, или очень значимый для многих людей. Вы замечаете огроменный топор в его руках, с выгравированным числом 220. Что это число значит? Каждый понимает по своему, однако по слухам оно означает количество его жертв. \n Надпись на табличке - Мы с тобой, Шустрила! Аве, Легион!"
	icon = 'modular_ss220/unique_objects/icons/statue.dmi'
	icon_state = "elwycco"
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/ell_good
	name = "Mr.Буум"
	desc = "Загадочный клоун с жёлтым оттенком кожи и выразительными зелёными глазами. Лучший двойной агент синдиката, получивший власть над множеством фасилити. \
			Его имя часто произносят неправильно из-за чего его заслуги по документам принадлежат сразу нескольким Буумам. \
			Так же знаменит тем, что убедил руководство НТ тратить время, силы и средства, на золотой унитаз."
	icon = 'modular_ss220/unique_objects/icons/statuelarge.dmi'
	icon_state = "ell_good"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/mooniverse
	name = "Неизвестный агент"
	desc = "Информация на табличке под статуей исцарапана и нечитабельна... Поверх написано невнятное словосочетание из слов \"Moon\" и \"Universe\""
	icon = 'modular_ss220/unique_objects/icons/statuelarge.dmi'
	icon_state = "mooniverse"
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

/obj/structure/statue/themis
	name = "Фемида"
	desc = "Статуя древнегреческой богини правосудия."
	icon = 'modular_ss220/unique_objects/icons/statuelarge.dmi'
	icon_state = "themis"
	layer = ABOVE_MOB_LAYER
	pixel_y = 7
	anchored = TRUE
	oreAmount = 0

// Cyberiad statue
/obj/structure/statue/cyberiad
	name = "статуя Кибериады"
	desc = "Гигантская модель научной станции «Кибериада». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_ss220/unique_objects/icons/cyberiad.dmi'
	anchored = TRUE
	max_integrity = 500
	oreAmount = 0

/obj/structure/statue/cyberiad/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/cyberiad/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/cyberiad/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/cyberiad/nw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/cyberiad/north/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/cyberiad/ne/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/cyberiad/w
	icon_state = "west"

/obj/structure/statue/cyberiad/c
	icon_state = "center"

/obj/structure/statue/cyberiad/e
	icon_state = "east"

/obj/structure/statue/cyberiad/sw
	icon_state = "sw"

/obj/structure/statue/cyberiad/s
	icon_state = "south"

/obj/structure/statue/cyberiad/se
	icon_state = "se"

// Delta statue
/obj/structure/statue/delta
	name = "статуя Кербероса"
	desc = "Гигантская модель научной станции «Керберос». Судя по отличиям в конструкции, станцию несколько раз перестраивали."
	icon = 'modular_ss220/unique_objects/icons/delta.dmi'
	anchored = TRUE
	max_integrity = 500
	oreAmount = 0

/obj/structure/statue/delta/nw
	icon_state = "nw"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/delta/north
	icon_state = "north"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

/obj/structure/statue/delta/ne
	icon_state = "ne"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER

// Adds transparency when the player gets behind an object, or is near it
/obj/structure/statue/delta/nw/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/delta/north/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/delta/ne/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, -3, -2, 6, 4)

/obj/structure/statue/delta/w
	icon_state = "west"

/obj/structure/statue/delta/c
	icon_state = "center"

/obj/structure/statue/delta/e
	icon_state = "east"

/obj/structure/statue/delta/sw
	icon_state = "sw"

/obj/structure/statue/delta/s
	icon_state = "south"

/obj/structure/statue/delta/se
	icon_state = "se"

// =========== items ===========
/obj/item/clothing/head/helmet/skull/Yorick
	name = "Йорик"
	desc = "Бедный Йорик..."

/obj/item/bikehorn/rubberducky/captain
	name = "уточка-капитан"
	desc = "Капитан всех уточек на этой станции. Крайне важная и престижная уточка. Выпущены в ограниченном тираже и только для капитанов. Ценная находка для коллекционеров."
	icon = 'modular_ss220/unique_objects/icons/watercloset.dmi'
	icon_state = "captain_rubberducky"
	item_state = "captain_rubberducky"

// =========== toilets ===========
/obj/structure/toilet
	var/is_nt = FALSE
	var/is_final = FALSE

/obj/structure/toilet/material
	name = "Унитаз"
	desc = "Особенный унитаз для особенных особ."
	icon = 'modular_ss220/unique_objects/icons/watercloset.dmi'

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(try_construct(I, user))
		return TRUE

/obj/structure/toilet/proc/try_construct(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/stack))
		return FALSE

	if(is_final)
		to_chat(user, span_warning("Этот унитаз достиг пика великолепия и безвкусия. Нельзя больше улучшить."))
		return FALSE

	var/obj/item/stack/M = I

	var/list/possible_materials = list(
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/ore/bluespace_crystal/refined,
		)
	var/is_correct = FALSE
	for(var/P in possible_materials)
		if(istype(M, P))
			is_correct = TRUE
			break

	if(!is_correct)
		to_chat(user, span_warning("Неподходящий материал для улучшения."))
		return FALSE

	var/is_rare = istype(M, /obj/item/stack/ore/bluespace_crystal/refined)
	var/need_amount = is_rare ? 2 : 5
	if(M.get_amount() < need_amount)
		to_chat(user, span_warning("Недостаточно материала, нужно хотя бы [need_amount] шт."))
		return FALSE

	switch(type)
		if(/obj/structure/toilet)
			switch(M.type)
				if(/obj/item/stack/sheet/mineral/gold)
					construct(M, user, /obj/structure/toilet/material/gold, need_amount)
				if(/obj/item/stack/sheet/mineral/silver)
					construct(M, user, /obj/structure/toilet/material/captain, need_amount)
				if(/obj/item/stack/ore/bluespace_crystal/refined)
					construct(M, user, /obj/structure/toilet/material/bluespace, need_amount)
		if(/obj/structure/toilet/material/gold)
			if(M.type == /obj/item/stack/sheet/mineral/gold)
				construct(M, user, /obj/structure/toilet/material/gold/nt, need_amount)
		if(/obj/structure/toilet/material/gold/nt)
			if(M.type == /obj/item/stack/sheet/mineral/silver)
				construct(M, user, /obj/structure/toilet/material/captain, need_amount)
		if(/obj/structure/toilet/material/captain)
			if(M.type == /obj/item/stack/sheet/mineral/gold)
				construct(M, user, /obj/structure/toilet/material/king, need_amount)
		if(/obj/structure/toilet/material/king)
			if(M.type == /obj/item/stack/sheet/mineral/gold)
				construct(M, user, /obj/structure/toilet/material/king/nt, need_amount)
		if(/obj/structure/toilet/material/bluespace)
			if(M.type == /obj/item/stack/ore/bluespace_crystal/refined)
				construct(M, user, /obj/structure/toilet/material/bluespace/nt, need_amount)
		else
			to_chat(user, span_warning("Неподходящая цель для гравировки."))
	return TRUE

/obj/structure/toilet/proc/construct(obj/item/stack/M, mob/living/user, build_type, amount)
	if(do_after(user, 2 SECONDS, target = src))
		M.use(amount)
		var/obj/structure/T = new build_type(loc)
		T.dir = dir
		qdel(src)

/obj/structure/toilet/material/bluespace/update_overlays()
	. = ..()
	if(open)
		. += singulo_layer

/obj/structure/toilet/material/gold
	name = "Золотой унитаз"
	desc = "Особенный унитаз для особенных особ."
	icon_state = "gold_toilet00"

/obj/structure/toilet/material/gold/nt
	name = "Золотой унитаз Nanotrasen"
	desc = "Особенный унитаз для лучших из Nanotrasen."
	icon_state = "gold_toilet00-NT"
	is_nt = TRUE

/obj/structure/toilet/material/gold/update_icon_state()
	. = ..()
	icon_state = "gold_toilet[open][cistern][is_nt ? "-NT" : ""]"

/obj/structure/toilet/material/captain
	name = "Унитаз Капитана"
	desc = "Престижное седалище для престижной персоны. Судя по форме, был идеально подготовлен под седальное место Капитана."
	icon_state = "captain_toilet00"

/obj/structure/toilet/material/captain/update_icon_state()
	. = ..()
	icon_state = "captain_toilet[open][cistern]"

/obj/structure/toilet/material/king
	name = "Королевский Унитаз"
	desc = "Только самые снобные снобы и люди не имеющие вкуса будут восседать на этом троне."
	icon_state = "king_toilet00"

/obj/structure/toilet/material/king/nt
	name = "Унитаз Верховного Командования Nanotrasen"
	desc = "Говорят что на таких восседают самые верховные верхушки которые бы даже не посмотрели на того, кто смог соорудить такую безвкусицу. Но главное - статус!"
	icon_state = "king_toilet00-NT"
	is_nt = TRUE
	is_final = TRUE

/obj/structure/toilet/material/king/update_icon_state()
	. = ..()
	icon_state = "king_toilet[open][cistern][is_nt ? "-NT" : ""]"

//Bluspace Tolkan
/obj/structure/toilet/material/bluespace
	name = "Научный унитаз"
	desc = "Загадка современной науки о возникновении данного научного экземпляра."
	icon_state = "bluespace_toilet00"
	var/singulo_layer = "bluespace_toilet_singularity"
	var/teleport_sound = 'sound/magic/lightning_chargeup.ogg'
	var/tp_range = 1

/obj/structure/toilet/material/bluespace/nt
	name = "Воронка Бездны Синего Космоса"
	desc = "То, ради чего наука и была создана и первый гуманоид ударил палку о камень. Главное не смотреть в бездну."
	icon_state = "bluespace_toilet00-NT"
	tp_range = 3
	is_nt = TRUE
	is_final = TRUE

/obj/structure/toilet/material/bluespace/emag_act(mob/user)
	if(!emagged)
		to_chat(user, span_notice("Блюспейс начал переливаться красными вкраплениями."))
		if(do_after(user, 2 SECONDS, target = src))
			emagged = TRUE
			tp_range = initial(tp_range) * 3
			singulo_layer = "bluespace_toilet_singularity-emagged"
			update_icon(UPDATE_ICON_STATE)
			playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			visible_message(span_warning("Блюспейс начал переливаться словно редспейс."))

/obj/structure/toilet/material/bluespace/update_icon_state()
	. = ..()
	icon_state = "bluespace_toilet[open][cistern][is_nt ? "-NT" : ""]"
	update_icon(UPDATE_OVERLAYS)

/obj/structure/toilet/material/bluespace/attack_hand(mob/living/user)
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	if(open)
		if(do_after(user, 10 SECONDS, target = src))
			teleport(tp_range)

/obj/structure/toilet/material/bluespace/proc/teleport(range_dist = 1)
	playsound(loc, teleport_sound, 100, 1)
	var/ext_range = range_dist * 3

	var/list/objects = range(range_dist, src)

	var/turf/simulated/floor/F = find_safe_turf(zlevels = src.z)
	for(var/mob/living/H in objects)
		do_teleport(H, F, H.loc == loc ? 0 : ext_range)
		investigate_log("teleported [key_name_log(H)] to [COORD(H)], with range in: [COORD(F)]")
	for(var/obj/O in objects)
		if(!O.anchored && O.invisibility == 0 && prob(50))
			do_teleport(O, F, O.loc == loc ? 0 : ext_range)

	do_teleport(src, F)

/obj/structure/toilet/material/bluespace/Destroy()
	teleport(tp_range * 3)
	. = ..()
