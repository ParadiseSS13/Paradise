/// Особая клонёрка для ниндзя.
/* Суть этой машины в том, что она позволяет ниндзя при покупке соответствующей абилки - 1 раз восстать из мёртвых.
 * В новом костюме и с новой катаной. Она не работает как типичная клонёрка и зависит только от того купил ли ниндзя - абилку.
 * На карте обязательно должна быть одна такая в додзё ниндзя.
 */
/obj/machinery/ninja_clonepod
	anchored = TRUE
	name = "Spider-Clan medical pod"
	desc = "A special pod, said to teleport a dead body of an assassin and revive it. \
	Thou many assassins suspects, it's just a cloning machine. But unironically, they don't care. \
	Mission success and their clan, is much more important for them then own life."
	density = TRUE
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_cloning_off"
	/// Нельзя чтобы такая дорогая технология была сломана игроком по фану
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | NO_MALF_EFFECT
	/// Записи о Ниндзя - купивших эту способность, для автовоскрешения оных.
	var/list/records = null
	/// Записи костюмов ниндзя для копирования на новый костюм при воскрешении оных.
	var/list/suits_data = null
	/// Новое тело ниндзя. Для авто-активации клонирования - оно должно быть null. Используется в процессе "Клонирования"
	var/mob/living/carbon/human/ninja
	/// Разум клонируемого
	var/datum/mind/clonemind
	/// Отвечает за то клонируем ли мы сейчас или нет. Нам не нужно чтобы клонёрка хватала одновременно двух ниндзя... Или одного 10 раз
	var/attempting = FALSE

	light_color = LIGHT_COLOR_LIGHTBLUE
	light_range = 5

/obj/machinery/ninja_clonepod/Initialize()
	. = ..()
	records = list()
	suits_data = list()

/obj/machinery/ninja_clonepod/process()
	if(!LAZYLEN(records))
		return

	if(!(ninja))
		for(var/datum/dna2/record/ninja_dna_record in records)
			if(revive_ninja(ninja_dna_record))
				records.Remove(ninja_dna_record)

// Автоматически вызываемое - оживление ниндзя!
/obj/machinery/ninja_clonepod/proc/revive_ninja(datum/dna2/record/ninja_dna_record)
	if(attempting)
		return FALSE
	clonemind = locate(ninja_dna_record.mind)
	if(!istype(clonemind))	//not a mind
		return FALSE
	if(clonemind.current && clonemind.current.stat != DEAD)	//mind is associated with a non-dead body
		return FALSE
	if(!clonemind.is_revivable()) //Other reasons for being unrevivable
		return FALSE
	if(clonemind.active)	//somebody is using that mind
		if(ckey(clonemind.key) != ninja_dna_record.ckey )
			return FALSE
	var/mob/dead/observer/ninja_ghost = clonemind.get_ghost()
	var/datum/ninja_suit_cloning_data/ninja_suit_data = find_suit_data(ckey(clonemind.key))
	if(!ninja_ghost)
		return FALSE
	if(!ninja_suit_data)
		return FALSE

	attempting = TRUE //One at a time!!
	icon_state = "ninja_cloning_on"
	ninja_ghost.forceMove(src.loc)
	ninja = ninja_ghost.incarnate_ghost()
	SSticker.mode.equip_space_ninja(ninja)
	SSticker.mode.give_ninja_datum(ninja.mind)
	ninja.faction = list(ROLE_NINJA)
	ninja.forceMove(src)
	ninja.Sleeping(7.5)
	playsound(src, 'sound/machines/initialisation.ogg', 50, FALSE)
	//Перенос скопированных данных в новый костюм
	var/obj/item/clothing/suit/space/space_ninja/n_suit = ninja.wear_suit

	n_suit.actions_types = ninja_suit_data.actions_types
	n_suit.blocked_TGUI_rows = ninja_suit_data.blocked_TGUI_rows
	n_suit.ninja_martial = ninja_suit_data.ninja_martial
	n_suit.design_choice = ninja_suit_data.design_choice
	n_suit.color_choice = ninja_suit_data.color_choice
	n_suit.preferred_clothes_gender = ninja_suit_data.preferred_clothes_gender
	n_suit.preferred_scarf_over_hood = ninja_suit_data.preferred_scarf_over_hood
	n_suit.style_preview_icon_state = ninja_suit_data.style_preview_icon_state
	//Выдача купленных ранее абилок
	var/list/ability_blacklist = list(	/datum/action/item_action/advanced/ninja/SpiderOS,
										/datum/action/item_action/advanced/ninja/ninja_autodust,
										/datum/action/item_action/ninjastatus,
										/datum/action/item_action/advanced/ninja/ninja_sword_recall)
	var/action_path
	for(action_path in n_suit.actions_types)
		if(action_path in ability_blacklist)
			continue
		var/datum/action/ninja_action = new action_path(n_suit, n_suit.action_icon[action_path], n_suit.action_icon_state[action_path])
		ninja_action.Grant(ninja)
	//Обновление боевого исскуства
	//Хоть БИ и в одном ряду с клонёркой.
	//Но пусть всё равно клонёрка выдаёт БИ если оно было по любым причинам.
	if(n_suit.ninja_martial)
		QDEL_NULL(ninja.mind.martial_art)
		var/datum/martial_art/ninja_martial_art/creeping_widow = new
		creeping_widow.teach(ninja)
		creeping_widow.my_suit = n_suit
		creeping_widow.my_energy_katana = n_suit.energyKatana
	//Проверка и перевыдача бомбы
	SSticker.mode.basic_ninja_needs_check(ninja.mind)
	//Пробуждение из клонёрки
	addtimer(CALLBACK(src, .proc/force_ninja_out), 150)
	suits_data.Remove(ninja_suit_data)
	return TRUE

/obj/machinery/ninja_clonepod/proc/force_ninja_out()
	icon_state = initial(icon_state)
	ninja.forceMove(get_turf(src))
	ninja.flash_eyes(visual = 1)
	add_game_logs("Ninja-cloned at [COORD(src)]", ninja)
	to_chat(ninja, "[span_notice("Вы чувствуете себя как совершенно новое существо... Так вот какого быть клоном... Но все эти мысли не имеют значения. Миссия и клан... Гораздо важнее!")]")
	attempting = FALSE
	ninja = null

// Вызываемое костюмом добавление ниндзя в БД клонёрки для будущего оживления
/obj/machinery/ninja_clonepod/proc/scan_mob(mob/living/carbon/human/subject as mob)
	// Нет ДНК, либо самого сканируемого, либо он не хуман.
	if(isnull(subject) || (!(ishuman(subject))) || (!subject.dna))
		return
	// Нет мозга
	if(!subject.get_int_organ(/obj/item/organ/internal/brain))
		return
	// Нет сикея или самого игрока
	if((!subject.ckey) || (!subject.client))
		return
	// Уже есть в бд
	if(!isnull(find_record(subject.ckey)) && !isnull(find_suit_data(subject.ckey)))
		return
	// Мы уже его клонируем
	if(ninja && clonemind == subject.mind)
		return
	// Нет костюма, либо костюм - не костюм ниндзя
	var/obj/item/clothing/suit/space/space_ninja/n_suit = subject.wear_suit
	if(n_suit && !istype(n_suit))
		return

	// Копируем данные самого ниндзя
	// По большей части - это копипаст кода клонёрки
	subject.dna.check_integrity()

	var/datum/dna2/record/ninja_dna_record = new()
	ninja_dna_record.ckey = subject.ckey
	var/obj/item/organ/ninja_brain = subject.get_int_organ(/obj/item/organ/internal/brain)
	ninja_brain.dna.check_integrity()
	ninja_dna_record.dna = ninja_brain.dna.Clone()
	if(NO_SCAN in ninja_dna_record.dna.species.species_traits)
		ninja_dna_record.dna.species = new subject.dna.species.type
	ninja_dna_record.id = copytext(md5(ninja_brain.dna.real_name), 2, 6)
	ninja_dna_record.name = ninja_brain.dna.real_name
	ninja_dna_record.types = DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE
	ninja_dna_record.languages = subject.languages
	//Add an implant if needed
	var/obj/item/implant/health/imp = locate(/obj/item/implant/health, subject)
	if(!imp)
		imp = new /obj/item/implant/health(subject)
		imp.implant(subject)
	ninja_dna_record.implant = "\ref[imp]"

	if(!isnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		ninja_dna_record.mind = "\ref[subject.mind]"

	records += ninja_dna_record

	//Копируем данные костюма ниндзя
	var/datum/ninja_suit_cloning_data/ninja_suit_data = new()
	ninja_suit_data.ckey = subject.ckey
	ninja_suit_data.actions_types = n_suit.actions_types
	ninja_suit_data.blocked_TGUI_rows = n_suit.blocked_TGUI_rows
	ninja_suit_data.ninja_martial = n_suit.ninja_martial
	ninja_suit_data.design_choice = n_suit.design_choice
	ninja_suit_data.color_choice = n_suit.color_choice
	ninja_suit_data.preferred_clothes_gender = n_suit.preferred_clothes_gender
	ninja_suit_data.preferred_scarf_over_hood = n_suit.preferred_scarf_over_hood
	ninja_suit_data.style_preview_icon_state = n_suit.style_preview_icon_state

	suits_data += ninja_suit_data

/obj/machinery/ninja_clonepod/proc/find_record(var/find_key)
	var/selected_record = null
	for(var/datum/dna2/record/ninja_dna_record in src.records)
		if(ninja_dna_record.ckey == find_key)
			selected_record = ninja_dna_record
			break
	return selected_record

/obj/machinery/ninja_clonepod/proc/find_suit_data(var/find_key)
	var/selected_suit = null
	for(var/datum/ninja_suit_cloning_data/ninja_suit_data in src.suits_data)
		if(ninja_suit_data.ckey == find_key)
			selected_suit = ninja_suit_data
			break
	return selected_suit

// Датум - Хранилище важных данных с костюма ниндзя
/datum/ninja_suit_cloning_data
	// Данные хозяина костюма
	var/ckey = null
	// Данные костюма
	var/list/actions_types = null
	var/list/blocked_TGUI_rows = null
	var/ninja_martial = null
	var/design_choice = null
	var/color_choice = null
	var/preferred_clothes_gender = null
	var/preferred_scarf_over_hood = null
	var/style_preview_icon_state = null
