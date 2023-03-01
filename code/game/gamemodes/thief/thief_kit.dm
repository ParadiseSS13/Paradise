// ========== STORAGE BOX WITH CHOOSEN ITEMS ==========
/obj/item/storage/box/thief_kit
	name = "набор гильдии воров"
	desc = "Ничем не примечательная коробка."
	icon_state = "box_thief"
	item_state = "syringe_kit"

/obj/item/storage/box/thief_kit/New()
	..()
	new /obj/item/clothing/gloves/color/black/thief(src)
	new /obj/item/storage/backpack/satchel_flat(src)
	new /obj/item/coin/twoheaded/thief(src)
	new /obj/item/paper/thief(src)

// ========== CHOOSE ITEMS ==========
/obj/item/thief_kit
	name = "набор гильдии воров"
	desc = "Ничем не примечательная увесистая коробка. Тяжелая. Набор вора-шредингера. Неизвестно что внутри, пока не заглянешь и не определишься."
	icon = 'icons/obj/storage.dmi'
	icon_state = "box_thief"
	item_state = "syringe_kit"
	w_class = WEIGHT_CLASS_TINY
	var/possible_uses = 2
	var/uses = 0
	var/multi_uses = FALSE
	var/list/datum/thief_kit/choosen_kit_list = list()
	var/list/datum/thief_kit/all_kits = list()

/obj/item/thief_kit/multi/multi_uses = TRUE
/obj/item/thief_kit/five/possible_uses = 5
/obj/item/thief_kit/five/multi/multi_uses = TRUE
/obj/item/thief_kit/ten/possible_uses = 10
/obj/item/thief_kit/ten/multi/multi_uses = TRUE
/obj/item/thief_kit/twenty
	possible_uses = 20
	multi_uses = TRUE
/obj/item/thief_kit/fifty
	possible_uses = 50
	multi_uses = TRUE

/obj/item/thief_kit/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ThiefKit", name, 600, 900, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/item/thief_kit/ui_data(mob/user)
	var/list/data = list()

	data["uses"] = uses
	data["possible_uses"] = possible_uses
	data["multi_uses"] = multi_uses

	return data

/obj/item/thief_kit/ui_static_data(mob/user)
	var/list/data = list()

	if(!length(all_kits))
		//var/index_count = 0
		for(var/kit_type in subtypesof(/datum/thief_kit))
			var/datum/thief_kit/kit = new kit_type
			all_kits.Add(kit)

	data["kits"] = list()
	for(var/datum/thief_kit/kit in all_kits)
		data["kits"] += list(list(
			"name" = kit.name,
			"desc" = kit.desc,
			"was_taken" = kit.was_taken,
			"type" = kit.type
		))

	data["choosen_kits"] = list()
	for(var/datum/thief_kit/kit in choosen_kit_list)
		data["choosen_kits"] += list(list(
			"name" = kit.name,
			"desc" = kit.desc,
			"was_taken" = kit.was_taken,
			"type" = kit.type
		))

	return data

/obj/item/thief_kit/attack_self(mob/user)
	interact(user)

/obj/item/thief_kit/interact(mob/user)
	if(!ishuman(user))
		to_chat(user, "Вы даже не гуманоид... Вы не понимаете как это открыть")
		return 0

	if(user.stat || user.restrained())
		return 0

	if(loc == user || (in_range(src, user) && isturf(loc)))
		ui_interact(user)

/obj/item/thief_kit/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("open")
			openKit(usr)
		if("clear")
			clearKit(usr)
		if("randomKit")
			randomKit()
		if("takeKit")
			pickKit(params["item"])
		if("undoKit")
			undoKit(params["item"])

/obj/item/thief_kit/proc/openKit(var/mob/user)
	if(uses >= possible_uses)
		var/obj/item/storage/box/thief_kit/kit = new(src)

		for(var/datum/thief_kit/kit_type in choosen_kit_list)
			for(var/item_type in kit_type.item_list)
				kit.contents.Add(new item_type(src))

		user.put_in_hands(kit)
		kit.AltClick(user)
		SStgui.close_uis(src)
		qdel(src)
	else
		to_chat(user,"<span class = 'warning'>Вы не определили все предметы в коробке!</span>")

/obj/item/thief_kit/proc/clearKit(var/mob/user)
	for(var/datum/thief_kit/kit in choosen_kit_list)
		undoKit(kit)
	uses = 0
	to_chat(user,"<span class = 'warning'>Вы очистили выбор! Наверное в коробке лежали другие наборы?</span>")

/obj/item/thief_kit/proc/pickKit(var/kit_type)
	if(uses >= possible_uses)
		return FALSE
	var/datum/thief_kit/kit = convert_kit_type(kit_type, all_kits)
	if(kit)
		choosen_kit_list.Add(kit)
		if(!multi_uses)
			kit.was_taken = TRUE
		uses++

		SStgui.close_uis(src)
		interact(usr)

/obj/item/thief_kit/proc/undoKit(var/kit_type)
	if(uses <= 0)
		return FALSE
	var/datum/thief_kit/kit = convert_kit_type(kit_type, choosen_kit_list)
	if(kit)
		choosen_kit_list.Remove(kit)
		kit.was_taken = FALSE
		uses--

		SStgui.close_uis(src)
		interact(usr)


/obj/item/thief_kit/proc/randomKit(var/kit_type)
	var/list/possible_kits = list()
	for(var/datum/thief_kit/kit in all_kits)
		if(kit.was_taken)
			continue
		possible_kits.Add(kit)
	if(possible_kits)
		pickKit(pick(possible_kits))
	else
		to_chat(usr,"<span class = 'warning'>Превышен допустимый лимит наборов!</span>")

/obj/item/thief_kit/proc/convert_kit_type(var/kit_type, var/list/kits_list)
	if(istype(kit_type, /datum/thief_kit))
		return kit_type
	for(var/datum/thief_kit/kit in kits_list)
		if("[kit.type]" == kit_type)
			return kit
	return FALSE


//=============== KITS ================
/datum/thief_kit
	var/name = "Безымянный кит (перешлите это разработчику)"
	var/desc = "Описание кита"
	var/list/obj/item/item_list = list()
	var/was_taken = FALSE

/datum/thief_kit/pinpointer
	name = "Целевой Пинпоинтер"
	desc = "Позволяет найти все интересные для гильдии объекты."
	item_list = list(
		/obj/item/pinpointer/thief,
		)

/datum/thief_kit/falsification
	name = "Набор Фальсификаций"
	desc = "Набор для подделывания подписей, печатей и  облика. Нескользящие ботинки в комплект включены."
	item_list = list(
		/obj/item/flag/chameleon,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/stamp/chameleon,
		/obj/item/pen/fakesign,
		/obj/item/chameleon,
		)

/datum/thief_kit/chamelleon
	name = "Набор Хамелеона"
	desc = "Набор одежды-хамелеона для скрытных внедрений. Нескользящие ботинки в комплект не включены."
	item_list = list(
		/obj/item/storage/box/syndie_kit/chameleon,
		)

/datum/thief_kit/agent
	name = "Набор Агента"
	desc = "Набор с инструментами и личными вещами, любезно позаимствованный у неудачливого агента одной организации."
	item_list = list(
		/obj/item/card/id/syndicate,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,

		//syndi trash
		/obj/item/toy/syndicateballoon,
		/obj/item/soap/syndie,
		/obj/item/clothing/shoes/combat,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/mask/gas/syndicate,
		/obj/item/tank/internals/emergency_oxygen/engi/syndi,
		/obj/item/flashlight/flare/glowstick/red,
		)

/datum/thief_kit/haker
	name = "Набор Хакера"
	desc = "Набор для наблюдений за синтетиками и взломов электроники."
	item_list = list(
		/obj/item/encryptionkey/binary,
		/obj/item/multitool/ai_detect,
		/obj/item/storage/belt/military/traitor/hacker,	//default red instruments
		)

/datum/thief_kit/radio
	name = "Набор Связиста"
	desc = "Набор для подслушиваний и контроля связи."
	item_list = list(
		/obj/item/encryptionkey/syndicate,
		/obj/item/jammer,
		)

/datum/thief_kit/vision
	name = "Набор Слежки"
	desc = "Контроль камер и базы данных служб безопасности"
	item_list = list(
		/obj/item/clothing/glasses/hud/security/chameleon,
		/obj/item/camera_bug
		)

/datum/thief_kit/gas
	name = "Набор Газовика"
	desc = "Набор с нелетальными газами для особых случаев."
	item_list = list(
		/obj/item/clothing/mask/gas/explorer,
		/obj/item/storage/belt/grenade/nonlethal,
		)

/datum/thief_kit/safe_breaker
	name = "Набор Медвежатника"
	desc = "Отличный выбор для грубого вскрытия сейфов и проделывания дыр с С4."
	item_list = list(
		/obj/item/clothing/suit/storage/lawyer/blackjacket/armored,
		/obj/item/clothing/gloves/color/latex/nitrile,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/thermal_drill/diamond_drill,
		/obj/item/storage/box/syndie_kit/c4,
		)

/datum/thief_kit/safe_breaker_quiet
	name = "Набор Педанта"
	desc = "Отличный выбор для тихого вскрытия сейфов. Термит включен в набор."
	item_list = list(
		/obj/item/clothing/gloves/color/latex/nitrile,
		/obj/item/clothing/mask/balaclava,
		/obj/item/clothing/accessory/stethoscope,
		/obj/item/book/manual/engineering_hacking,
		/obj/item/storage/box/syndie_kit/t4,
		)

/datum/thief_kit/sleepy
	name = "Набор Сонника"
	desc = "Набор для тех, кто не желает чтобы рядом стоящие держали глаза открытыми."
	item_list = list(
		/obj/item/pen/sleepy,
		/obj/item/gun/syringe, //default x1
		/obj/item/reagent_containers/syringe/pancuronium,
		/obj/item/reagent_containers/syringe/pancuronium,
		/obj/item/reagent_containers/syringe/capulettium_plus,
		/obj/item/reagent_containers/syringe/capulettium_plus,
		/obj/item/reagent_containers/glass/bottle/ether,
		/obj/item/reagent_containers/glass/bottle/ether,
		)

/datum/thief_kit/mutant
	name = "Набор Мутанта"
	desc = "Специфический набор включающий в себя 3 мутагенных шприца с генами телепатии, удаленного наблюдения и гена карликовости."
	item_list = list(
		/obj/item/dnainjector/telemut,
		/obj/item/dnainjector/antitele,
		/obj/item/dnainjector/remoteview,
		/obj/item/dnainjector/antiremoteview,
		/obj/item/dnainjector/midgit,
		/obj/item/dnainjector/antimidgit,
		)

/datum/thief_kit/thermal
	name = "Термальные Очки"
	desc = "Солнцезащитные термальные очки для наблюдения за всем, что происходит за стенами и звездами. Гильдия Воров вложила любимые конфетки любителей термалов."
	item_list = list(
		/obj/item/clothing/glasses/thermal/sunglasses,
		/obj/item/storage/box/candythief,
		)

