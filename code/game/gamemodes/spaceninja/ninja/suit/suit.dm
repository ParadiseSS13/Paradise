/**
 * # Ninja Suit
 *
 * Space ninja's suit.  Gives space ninja all his iconic powers, which are mostly kept in
 * the folder ninja_equipment_actions.  Has a lot of unique stuff going on, so make sure to check
 * the variables. Check suit_attackby to see uranium interactions, disk copying, and cell replacement.
 *
 */
/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vacuum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	tts_seed = "Sorceress"
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "ninja_suit"
	item_state = "ninja_suit"
	allowed = list(
		/obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank,
		/obj/item/stock_parts/cell, /obj/item/grenade/plastic/c4/ninja)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20,"energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 30, "fire" = 100, "acid" = 100)
	strip_delay = 12
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEGLOVES|HIDEJUMPSUIT|HIDETAIL
	/// Абилки костюма
	actions_types = list(
		/datum/action/item_action/advanced/ninja/SpiderOS,
		/datum/action/item_action/advanced/ninja/ninja_autodust,
		/datum/action/item_action/ninjastatus,
		/datum/action/item_action/advanced/ninja/ninja_sword_recall,
/*		/datum/action/item_action/advanced/ninja/ninja_stealth, Не используется
		/datum/action/item_action/advanced/ninja/ninja_chameleon,
		/datum/action/item_action/advanced/ninja/ninja_spirit_form,
		/datum/action/item_action/advanced/ninja/ninjaboost,
		/datum/action/item_action/advanced/ninja/ninjaheal,
		/datum/action/item_action/advanced/ninja/ninja_clones,
		/datum/action/item_action/advanced/ninja/ninjapulse,
		/datum/action/item_action/advanced/ninja/ninja_smoke_bomb,
		/datum/action/item_action/advanced/ninja/ninja_caltrops,
		/datum/action/item_action/advanced/ninja/ninja_emergency_blink,
		/datum/action/item_action/advanced/ninja/johyo,
		/datum/action/item_action/advanced/ninja/ninjanet,
		/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode
		/datum/action/item_action/ninjastar, */ )

	/// Мы не хотим чтобы ниндзю замедлял его же костюм!
	slowdown = 0
	/// If this is a path, this gets created as an object in Initialize.
	var/obj/item/stock_parts/cell/cell = /obj/item/stock_parts/cell/high
	/// The person wearing the suit
	var/mob/living/carbon/human/affecting = null
	/// The suit's spark system, used for... sparking.
	var/datum/effect_system/spark_spread/spark_system
	/// The suit's smoke system. For the tactical smoke escapes and other smokey things!
	var/datum/effect_system/smoke_spread/bad/smoke_system

	/// The katana registered with the suit, used for recalling and catching the katana.  Set when the ninja outfit is created.
	var/obj/item/melee/energy_katana/energyKatana

	/// Одежда ниндзя.
	/// Большая часть этой одежды блокируется на нём при включении костюма
	/// The space ninja's hood.
	var/obj/item/clothing/head/helmet/space/space_ninja/n_hood
	/// The space ninja's scarf. An alternative wear if ninja doesn't want to cover his hairs with hood.
	var/obj/item/clothing/neck/ninjascarf/n_scarf
	/// The space ninja's shoes.
	var/obj/item/clothing/shoes/space_ninja/n_shoes
	/// The space ninja's gloves.
	var/obj/item/clothing/gloves/space_ninja/n_gloves
	/// The space ninja's mask.
	var/obj/item/clothing/mask/gas/space_ninja/n_mask
	/// The space ninja's headset
	var/obj/item/radio/headset/ninja/n_headset
	/// The space ninja's backpack
	var/obj/item/radio/headset/ninja/n_backpack
	/// The space ninja's chameleon id card
	/// used only to fake sechuds while using chameleon
	var/obj/item/card/id/ninja/n_id_card

	/// Создаются способностями и помещаются в руку
	/// Удаляются полностью при убирании из руки
	var/obj/item/gun/energy/shuriken_emitter/shuriken_emitter
	var/obj/item/ninja_chameleon_scanner/chameleon_scanner
	var/obj/item/ninja_net_emitter/net_emitter
	var/obj/item/gun/magic/johyo/integrated_harpoon

	/// Референс для компьютера шатла
	var/obj/machinery/computer/shuttle/ninja/shuttle_controller

	/// Референс клонёрки. Если куплена способность. Ниндзя записывается в неё при активации костюма. И 1 раз клонируется
	var/obj/machinery/ninja_clonepod/cloning_ref
	/// Купил ли ниндзя клон абилку?
	var/ninja_clonable = FALSE
	/// Купил ли ниндзя боевое исскуство?
	var/ninja_martial = FALSE
	/// Встроенный в костюм джетпак
	var/obj/item/tank/jetpack/suit/jetpack = /obj/item/tank/jetpack/suit/ninja

	/// UI stuff ///
	/// Флаги отвечающие за то - показываем мы или нет интерфейс заряда и концентрации ниндзя
	var/show_concentration_UI = TRUE
	var/show_charge_UI = TRUE
	/// Флаг отвечающий за то, можно ли сейчас купить ещё абилку.
	/// Нужен для предотвращения уязвимости позволяющей потенциально купить все абилки
	/// Стандартно должен быть FALSE
	var/bying_ability = FALSE
	/// Контроллер текущего состояния интерфейса
	/// NINJA_TGUI_MAIN_SCREEN_STATE = Покупка абилок, управление шаттлом, советы и кнопка для активации костюма
	/// NINJA_TGUI_LOADING_STATE = Экран загрузки при включении/выключении костюма
	var/suit_tgui_state = NINJA_TGUI_MAIN_SCREEN_STATE
	/// Для отслеживание инициализации/деинициализации отдельно для TGUI
	/// Ибо из-за быстрого обновления данных в TGUI он может застрять на экране загрузки
	var/s_TGUI_initialized = FALSE
	var/current_initialisation_phase = 0
	var/current_initialisation_text = null
	/// Для хранения заблокированных рядов в таблице покупки навыков
	var/list/blocked_TGUI_rows = list(FALSE,FALSE,FALSE,FALSE,FALSE)

	/// Для персонализации скина костюма
	var/list/designs = list("classic","new")
	var/list/colors = list("green", "red", "blue")
	var/list/genders = list("male", "female")
	var/design_choice = "new"
	var/scarf_design_choice = "new"
	var/color_choice = "green"
	var/preferred_clothes_gender = "male"
	var/preferred_scarf_over_hood = FALSE

	/// Лист доступных спрайтов из 'icons/mob/actions/actions_ninja.dmi' для tgui.
	var/static/list/allowed_states = list(
		"shuriken", "ninja_cloak", "ninja_spirit_form", "dust", "chameleon",
		"kunai", "smoke", "adrenal", "energynet", "emergency_blink",
		"ninja_clones", "emp", "chem_injector", "healthstatus", "caltrop",
		"cloning", "spider_green", "spider_red", "spider_blue", "work_in_progress",
		"ninja_sleeper", "ai_face", "ninja_borg", "server", "buckler",
		"cash", "handcuff", "spider_charge", "ninja_teleport", "headset_green",
		"BSM", "changeling", "vampire", "syndicate")

	/// Превью отображающееся сейчас в tgui.
	/// Позволяет предпросмотреть настройки внешности костюма
	var/style_preview_icon_state = "ninja_preview_new_hood_green"

	/// Лист доступных спрайтов из 'icons/mob/ninja_previews.dmi' для tgui.
	var/static/list/allowed_preview_states = list(
		// Шарфа нет
		"ninja_preview_classic_hood_green", "ninja_preview_classic_hood_red", "ninja_preview_classic_hood_blue",
		"ninja_preview_classic_hood_green_f", "ninja_preview_classic_hood_red_f", "ninja_preview_classic_hood_blue_f",
		"ninja_preview_new_hood_green", "ninja_preview_new_hood_blue", "ninja_preview_new_hood_red",
		"ninja_preview_new_hood_green_f", "ninja_preview_new_hood_blue_f", "ninja_preview_new_hood_red_f",
		// Шарф отличается от стиля костюма
		"ninja_preview_new_scarf_classic_green", "ninja_preview_new_scarf_classic_blue", "ninja_preview_new_scarf_classic_red",
		"ninja_preview_new_scarf_classic_green_f", "ninja_preview_new_scarf_classic_blue_f", "ninja_preview_new_scarf_classic_red_f",
		"ninja_preview_classic_scarf_new_green", "ninja_preview_classic_scarf_new_red", "ninja_preview_classic_scarf_new_blue",
		"ninja_preview_classic_scarf_new_green_f", "ninja_preview_classic_scarf_new_red_f", "ninja_preview_classic_scarf_new_blue_f",
		// Шарф имеет такой же стиль как и костюм
		"ninja_preview_classic_scarf_classic_green", "ninja_preview_classic_scarf_classic_red", "ninja_preview_classic_scarf_classic_blue",
		"ninja_preview_classic_scarf_classic_green_f", "ninja_preview_classic_scarf_classic_red_f", "ninja_preview_classic_scarf_classic_blue_f",
		"ninja_preview_new_scarf_new_green", "ninja_preview_new_scarf_new_blue", "ninja_preview_new_scarf_new_red",
		"ninja_preview_new_scarf_new_green_f", "ninja_preview_new_scarf_new_blue_f", "ninja_preview_new_scarf_new_red_f")
	// Сообщения при включении костюма
	var/static/list/ninja_initialize_messages = list(
		"Инициализация...",
		"Установка связи с нейронами пользователя...	Успех.",
		"Расширение нейронной связи...	Успех.",
		"Установка наблюдения за мозговой активностью...	Успех.",
		"Активация механизма внешней блокировки костюма...	Успех.",
		"Блокировка костюма...",										//NINJA_INIT_LOCK_PHASE
		// Текст блокировки
		"Успех.",
		"Персонализация костюма...",									//NINJA_INIT_ICON_GENERATE_PHASE
		// Текст персонализации
		"Успех.",
		"Инициализация модулей...",										//NINJA_INIT_MODULES_PHASE
		// Текст каждого модуля кодом вписывается сюда
		"Успех.",
		"Статус основных систем...	ONLINE",
		"Статус резервных систем...	ONLINE",
		"Текущий запас энергии: ",	//Кодом должно дописаться - сколько энергии
		"Все системы в норме. Добро пожаловать в SpiderOS, ",//Кодом должно дописаться - имя пользователя костюма
		)

	// Сообщения при выключении костюма
	var/static/list/ninja_deinitialize_messages = list(
		"Деинициализация...",
		"Отключение SpiderOS",
		"Статус основных систем...	OFFLINE",
		"Остановка потребления энергии...	Успех.",
		"Отключение модулей...",										//NINJA_DEINIT_MODULES_PHASE
		// Текст каждого модуля кодом вписывается сюда
		"Успех.",
		"Возвращение костюма к стандартной форме...",					//NINJA_DEINIT_ICON_REGENERATE_PHASE
		// Текст персонализации
		"Успех.",
		"Разблокировка костюма...",										//NINJA_DEINIT_UNLOCK_PHASE
		// Текст блокировки
		"Успех.",
		"Остановка наблюдения за мозговой активностью...	Успех.",
		"Остановка связи с нейронами пользователя...	Успех.",
		"Статус резервных систем...	OFFLINE",
		"Все системы отключены. Операция успешно завершена.",
		)
	/// UI stuff end ///

	/// Может ли костюм применять кто угодно или только Ниндзя с datum-ом в mind-е?
	var/anyone = FALSE
	/// Активирован ли костюм? В начале всегда деактивирован.
	var/s_initialized = FALSE
	/// Как много энергии тратит костюм каждый тик
	var/s_cost = 5
	/// Дополнительные затраты энергии за активированные хамелион и/или невидимость за тик
	var/s_acost = 8
	/// Процент энергии тратящийся формой духа каждый тик process
	var/s_spirit_form__percent_cost = 0.02
	/// Как быстро костюм выполняет некоторые задачи. Преимущественно влияет на скорость активации/деактивации костюма.
	var/s_delay = 40
	/// Whether or not the wearer is in the middle of an action, like hacking.
	var/s_busy = FALSE

	/// Флаги состояний ниндзя.
	/// Флаг невидимости.
	/// Не даёт невидимость сам по себе как и другие подобные флаги ниже
	/// Лишь сообщает костюму - "Мы сейчас невидимы"
	var/stealth = FALSE
	/// Шанс выдачи флавор намёка о том что рядом ниндзя в инвизе. В процентах.
	var/stealth_ambient_chance = 2
	/// Если у нас есть способность выпускать дым, этот флаг отвечает за то будут ли другие способности пытаться делать это сами
	/// Переключается игроком, через отдельный action
	var/auto_smoke = FALSE
	/// Флаг Формы духа
	var/spirited = FALSE
	/// Флаг Хамелиона
	var/disguise_active = FALSE
	/// Записанная маскировка для хамелиона
	var/datum/icon_snapshot/disguise = null

	/// Адреналин. Для удобства обращения к нему костюма.
	var/datum/action/item_action/advanced/ninja/ninjaboost/a_boost = null
	/// Фразы выкрикиваемые носящим при активации адреналина
	var/list/boost_phrases = list(
		"A CORNERED FOX IS MORE DANGEROUS THAN A JACKAL!",
		"I'M A SHADOW, ONE THAT NO LIGHT WILL SHINE ON!",
		"HURT ME MOOORRREEE!", "IMPRESSIVE!",
		"MY POWER IS ABSOLUTE!", "SHOW ME YOUR MOTIVATION!",
		"I'LL CUT YOU IN TWO!", "I'M FUCKING INVINCIBLE!",
		"I'M LIGHTNING! THE RAIN TRANSFORMED!")

	/// Лечащие химикаты. Для удобства обращения к ним костюма.
	var/datum/action/item_action/advanced/ninja/ninjaheal/heal_chems = null
	/// Сколько кусков урана требуется для восстановления адреналина/лечащего коктейля?
	/// От этой цифры так же зависит объём радия вводимый в тело после адренала
	var/a_transfer = 10

	/// Будет ли или не будет автоматически убит ниндзя когда достигнет критического состояния здоровья.
	var/auto_dust = FALSE
	/// Сколько у ниндзя должно быть здоровья, чтобы его автоматически убило. (Переключается между -90 и 0)
	var/health_threshold = -90
	/// Флаг дающий защиту от некоторых способностей вампира пока на нас костюм
	var/vamp_protection_active = FALSE

/obj/item/clothing/suit/space/space_ninja/examine(mob/ninja)
	. = ..()
	if(!s_initialized)
		return
	if(!ninja == affecting)
		return
	. += "All systems operational. Current energy capacity: <B>[cell.charge]</B>.\n"
	if(locate(/datum/action/item_action/advanced/ninja/ninja_stealth) in actions)
		. += "The Cloak-Tech Device is <B>[stealth?"active":"inactive"]</B>.\n"
	if(locate(/datum/action/item_action/advanced/ninja/ninja_chameleon) in actions)
		. += "The Kitsune - Adaptive Chameleon Device is <B>[disguise_active?"active":"inactive"]</B>.\n"
	if(locate(/datum/action/item_action/advanced/ninja/ninja_spirit_form) in actions)
		. += "Spirit Form Prototype Module is <B>[spirited?"active":"inactive"]</B>.\n"
	if(locate(/datum/action/item_action/advanced/ninja/ninjaboost) in actions)
		. += "[a_boost.charge_counter ? "Integrated Adrenaline Injector is available to use.":"There is no adrenaline boost available. Try refilling the suit with uranium sheets."]\n"
	if(locate(/datum/action/item_action/advanced/ninja/ninjaheal) in actions)
		. += "[heal_chems.charge_counter ? "Integrated Restorative Cocktail Mixer is available to use. Charges: [heal_chems.charge_counter]/[heal_chems.charge_max]":"There is no healing chemicals available. Try refilling the suit with bluespace crystal sheets."]\n"
	if(ninja_clonable)
		. += "You have bought a Second chance for yourself. \n"

/obj/item/clothing/suit/space/space_ninja/Initialize(mapload)
	. = ..()

	// Spark Init
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	// Smoke Init
	smoke_system = new
	smoke_system.attach(src)
	// Jetpack initialize
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)

	if(!mapload)

	//Shuttle Init
		for(var/obj/machinery/computer/shuttle/ninja/shuttle in GLOB.machines)
			shuttle_controller = shuttle

	//Cloning Init
		for(var/obj/machinery/ninja_clonepod/clonepod in GLOB.machines)
			cloning_ref = clonepod

		if(!cloning_ref)
			stack_trace("[src] tried to find a Spider Clan cloning machine, but there is none in the world. Potential Mapping mistake.")
			message_admins("[src] tried to find a Spider Clan cloning machine, but there is none in the world. Potential Mapping mistake.")

	//Cell Init
	if(ispath(cell))
		cell = new cell(src)
	cell.charge = 9000
	cell.name = "black power cell"
	cell.icon_state = "bscell"

/obj/item/clothing/suit/space/space_ninja/Destroy()
	QDEL_NULL(cell)
	affecting = null
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)
	energyKatana = null
	n_hood = null
	n_scarf = null
	n_shoes = null
	n_gloves = null
	n_mask = null
	n_headset = null
	n_backpack = null
	QDEL_NULL(shuriken_emitter)
	QDEL_NULL(chameleon_scanner)
	QDEL_NULL(net_emitter)
	QDEL_NULL(integrated_harpoon)
	shuttle_controller = null
	cloning_ref = null
	QDEL_NULL(disguise)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/clothing/suit/space/space_ninja/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!jetpack)
		to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
		return
	if(src == user.get_item_by_slot(slot_wear_suit))
		to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
		return
	jetpack.turn_off(user)
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")

/obj/item/clothing/suit/space/space_ninja/equipped(mob/user, slot)
	. = ..()
	if(jetpack)
		if(slot == slot_wear_suit)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/space_ninja/dropped(mob/user)
	. = ..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/space_ninja/proc/start()
	if(!s_initialized)
		START_PROCESSING(SSfastprocess, src)
		s_initialized = TRUE

/obj/item/clothing/suit/space/space_ninja/proc/stop()
	if(s_initialized)
		STOP_PROCESSING(SSfastprocess, src)
		s_initialized = FALSE

/obj/item/clothing/suit/space/space_ninja/process()
	var/mob/living/carbon/human/ninja = src.loc
	if(!ninja || !ishuman(ninja) || !(ninja.wear_suit == src))
		return

	// Проверка во избежание потенциальных абузов инвиза
	// Как например если после сканирования t-ray сканером сразу выключить инвиз...
	// Что приводило к бесплатному инвизу.
	if(ninja.alpha == NINJA_ALPHA_INVISIBILITY || ninja.alpha == NINJA_ALPHA_SPIRIT_FORM)
		if(!stealth && !spirited)
			ninja.alpha = NINJA_ALPHA_NORMAL
	//Safe checks to prevent potential abuse of power.
	if(!is_teleport_allowed(ninja.z) && spirited)
		to_chat(ninja, span_warning("This place forcibly stabilizes your body somehow! You can't use \"Spirit Form\" there!"))
		cancel_spirit_form()
	// Check for energy usage
	var/used_power = s_cost  // s_cost is the default energy cost each ntick, usually 5.
	if(s_initialized)
		if(!affecting)	//Чтобы уничтожить костюм и всё связанное в случае совершенно неправильной активации костюма
			terminate()
		else if(ninja.health <= health_threshold && auto_dust)
			ninja_autodust()
			stop()	//Чтобы не превращало в пыль 200 раз в секунду
		else if(cell.charge > 0)
			if(stealth) // If stealth is active.
				stealth_creepy_effects()
				used_power += s_acost
			else if(stealth_ambient_chance > initial(stealth_ambient_chance) && prob(stealth_ambient_chance))
				stealth_ambient_chance -= 0.5
				if(stealth_ambient_chance == initial(stealth_ambient_chance))
					to_chat(ninja, span_notice("Нагрузка костюма вернулась в норму!"))
			if(disguise_active) // If chameleon is active.
				used_power += s_acost
			if(spirited) // If spirit form is active.
				if(istype(ninja.r_hand, /obj/item/grab))
					ninja.unEquip(ninja.r_hand, TRUE)
					to_chat(ninja, span_warning("You can't hold anyone that tight, when \"Spirit Form\" is active!"))
				if(istype(ninja.l_hand, /obj/item/grab))
					ninja.unEquip(ninja.l_hand, TRUE)
					to_chat(ninja, span_warning("You can't hold anyone that tight, when \"Spirit Form\" is active!"))
				used_power += cell.maxcharge * s_spirit_form__percent_cost //that shit is NOT cheap
			if(cell.charge < used_power) // Проверка на случай когда он не может отнять энергию до нуля и в итоге вечно торчит в инвизе/форме духа/хамелионе
				cell.charge = 0
			cell.use(used_power)
		else
			cell.charge = 0
			if(stealth) // If stealth is active.
				cancel_stealth()
			if(disguise_active) // If chameleon is active.
				restore_form()
			if(spirited)
				cancel_spirit_form()

	ninja.adjust_bodytemperature(BODYTEMP_NORMAL - ninja.bodytemperature)

/obj/item/clothing/suit/space/space_ninja/ui_action_click(mob/ninja, action)
	if(!isninja(ninja) && !anyone)
		to_chat(ninja, span_danger("<B>fÄTaL ÈÈRRoR</B>: 382200-*#00CÖDE <B>RED</B>\nUNAUHORIZED USÈ DETÈCeD\nCoMMÈNCING SUB-R0UIN3 13...\nTÈRMInATING U-U-USÈR..."))
		ninja.dust()
		return FALSE
	if(action == /datum/action/item_action/advanced/ninja/SpiderOS)
		ui_interact(ninja)
		return TRUE
	if(!s_initialized)
		to_chat(ninja, span_warning("<b>ERROR</b>: suit offline. Please activate suit."))
		return FALSE
	switch(action)
		if(/datum/action/item_action/advanced/ninja/ninja_autodust)
			ninja_toggle_autodust()
			return TRUE
		if(/datum/action/item_action/ninjastatus)
			ninjastatus()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninjaboost)
			ninjaboost()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninjaheal)
			ninjaheal()
			return TRUE
		if(/datum/action/item_action/ninjastar)
			ninjastar()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode)
			toggle_shuriken_fire_mode()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_clones)
			start_ninja_clones()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninjapulse)
			ninjapulse()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninjanet)
			toggle_ninja_net_emitter()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_sword_recall)
			ninja_sword_recall()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_stealth)
			toggle_stealth()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_chameleon)
			toggle_chameleon_scanner_mode()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb)
			prime_smoke()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_smoke_bomb_toggle_auto)
			toggle_smoke()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_caltrops)
			scatter_caltrops()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/johyo)
			toggle_harpoon()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_emergency_blink)
			emergency_blink()
			return TRUE
		if(/datum/action/item_action/advanced/ninja/ninja_spirit_form)
			if(!is_teleport_allowed(ninja.z))	//Дублирую и тут, потому что спамом абилки можно на доли секунды врубить её и пройти сквозь стену
				to_chat(ninja, span_warning("This place forcibly stabilizes your body somehow! You can't use \"Spirit Form\" there!"))
				return FALSE
			toggle_spirit_form()
			return TRUE
	return FALSE

/**
 * Proc for changing the suit's appearance to the selected design.
 *
 * Arguments:
 * * ninja - The person wearing the suit.
 */
/obj/item/clothing/suit/space/space_ninja/proc/lockIcons(mob/living/carbon/human/ninja)

	//Костюм
	icon_state = preferred_clothes_gender == "female" ? "[initial(icon_state)]_[design_choice]_[color_choice]_f" : "[initial(icon_state)]_[design_choice]_[color_choice]"
	item_state = preferred_clothes_gender == "female" ? "[initial(item_state)]_[design_choice]_[color_choice]_f" : "[initial(icon_state)]_[design_choice]_[color_choice]"
	//Капюшон
	n_hood.icon_state = "ninja_hood_[design_choice]"
	n_hood.item_state = "ninja_hood_[design_choice]"
	//Перчатки
	n_gloves.icon_state = "[initial(n_gloves.icon_state)]_[design_choice]_[color_choice]"
	n_gloves.item_state = "[initial(n_gloves.item_state)]_[design_choice]_[color_choice]"
	//Маска
	n_mask.visuals_type = design_choice
	var/obj/item/clothing/glasses/ninja/glasses = ninja.glasses				//Маска синхронизирует свой режим с режимом очков
	n_mask.icon_state = "ninja_mask_[design_choice]_[glasses.current_mode]"
	n_mask.item_state = "ninja_mask_[design_choice]_[glasses.current_mode]"
	//Наушник
	if(n_headset && n_headset.loc == ninja)
		n_headset.icon_state = "headset_[color_choice]"
	//Рюкзак
	if(n_backpack && n_backpack.loc == ninja)
		n_backpack.icon_state = "backpack_ninja_[color_choice]"
		n_backpack.item_state = "backpack_ninja_[color_choice]"
	//Катана
	if(energyKatana && energyKatana.loc == ninja)
		energyKatana.icon_state = "energy_katana_[color_choice]"
		energyKatana.item_state = "energy_katana_[color_choice]"
		energyKatana.color_style = color_choice
		energyKatana.jaunt.update_action_style(color_choice)
	//Покраска дыма
	switch(color_choice)
		if("red")
			smoke_system.color = "#af0033"
		if("blue")
			smoke_system.color = "#88aaff"
		if("green")
			smoke_system.color = "#00ff00"

	var/datum/action/item_action/action
	for(action in ninja.actions)
		action.button_icon = 'icons/mob/actions/actions_ninja.dmi'
		action.background_icon_state = "background_[color_choice]"
		if(istype(action, /datum/action/item_action/advanced/ninja))
			var/datum/action/item_action/advanced/ninja/ninja_action = action
			ninja_action.recharge_text_color = color_choice
			ninja_action.icon_state_active = "background_[color_choice]_active"
			ninja_action.icon_state_disabled = "background_[color_choice]"
		if((istype(action, /datum/action/item_action/advanced/ninja/ninjaboost) && a_boost == action) || (istype(action, /datum/action/item_action/advanced/ninja/ninjaheal) && heal_chems == action))
			action.background_icon_state = "background_[color_choice]_active"
	ninja.update_action_buttons_icon()

/**
 * Proc for changing the suit's appearance back to default state.
 *
 * Arguments:
 * * ninja - The person wearing the suit.
 */
/obj/item/clothing/suit/space/space_ninja/proc/unlockIcons(mob/living/carbon/human/ninja)
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	if(n_hood)//Should be attached, might not be attached.
		n_hood.icon_state = initial(n_hood.icon_state)
		n_hood.item_state = initial(n_hood.item_state)
	if(n_shoes)	//Хоть сейчас у обуви всегда один скин, нет ничего плохого заранее сделать восстановление скина, в случае появления новых в будущем.
		n_shoes.icon_state = initial(n_shoes.icon_state)
		n_shoes.item_state = initial(n_shoes.item_state)
	if(n_gloves)
		n_gloves.icon_state = initial(n_gloves.icon_state)
		n_gloves.item_state = initial(n_gloves.item_state)
		n_gloves.draining = FALSE
	if(n_mask)
		n_mask.visuals_type = "classic"
		n_mask.icon_state = initial(n_mask.icon_state)
		n_mask.item_state = initial(n_mask.item_state)
	if(n_headset)
		n_headset.icon_state = initial(n_headset.icon_state)
	if(n_backpack)
		n_backpack.icon_state = initial(n_backpack.icon_state)
		n_backpack.item_state = initial(n_backpack.item_state)
	if(energyKatana)
		energyKatana.icon_state = initial(energyKatana.icon_state)
		energyKatana.item_state = initial(energyKatana.item_state)
		energyKatana.color_style = initial(energyKatana.color_style)

/**
 * Proc called to lock the important gear pieces onto space ninja's body.
 *
 * Called during the suit startup to lock all gear pieces onto space ninja.
 * Terminates if a gear piece is not being worn.
 * If the person in the suit isn't a ninja when this is called, this proc just dusts them instead.
 * (Добавила параметр anyone, позволяющий обойти гиб "не ниндзя" через vv)
 *
 * Arguments:
 * * ninja - The person wearing the suit.
 * * Returns false if the locking fails due to lack of all suit parts, and true if it succeeds.
 */
/obj/item/clothing/suit/space/space_ninja/proc/lock_suit(mob/living/carbon/human/ninja)
	if(!istype(ninja))
		return FALSE
	if(!istype(ninja.head, /obj/item/clothing/head/helmet/space/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 100113 UNABLE TO LOCATE HEAD GEAR\nABORTING...")
		return FALSE
	if(!istype(ninja.shoes, /obj/item/clothing/shoes/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 122011 UNABLE TO LOCATE FOOT GEAR\nABORTING...")
		return FALSE
	if(!istype(ninja.gloves, /obj/item/clothing/gloves/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 110223 UNABLE TO LOCATE HAND GEAR\nABORTING...")
		return FALSE
	if(!istype(ninja.wear_mask, /obj/item/clothing/mask/gas/space_ninja))
		to_chat(ninja, "[span_userdanger("ERROR")]: 110223 UNABLE TO LOCATE NINJA MASK\nABORTING...")
		return FALSE
	toggle_ninja_nodrop(src)
	n_hood = ninja.head
	toggle_ninja_nodrop(n_hood)
	n_shoes = ninja.shoes
	toggle_ninja_nodrop(n_shoes)
	n_gloves = ninja.gloves
	toggle_ninja_nodrop(n_gloves)
	n_mask = ninja.wear_mask
	//Записываем маску к очкам, чтобы менять ей визуал, вместе с режимами очков
	var/obj/item/clothing/glasses/ninja/wear_glasses = ninja.glasses
	wear_glasses.n_mask = n_mask
	toggle_ninja_nodrop(n_mask)
	return TRUE

/**
 * Proc called to unlock all the gear off space ninja's body.
 * Proc which is essentially the opposite of lock_suit.  Lets you take off all the suit parts.
 */
/obj/item/clothing/suit/space/space_ninja/proc/unlock_suit()
	toggle_ninja_nodrop(src)
	if(n_hood)//Should be attached, might not be attached.
		toggle_ninja_nodrop(n_hood)
	if(n_shoes)
		toggle_ninja_nodrop(n_shoes)
	if(n_gloves)
		toggle_ninja_nodrop(n_gloves)
		n_gloves.draining = FALSE
	if(n_mask)
		toggle_ninja_nodrop(n_mask)

// Задумка такова:
// Этот код вызывается с проверкой флага preferred_scarf_over_hood на да/нет
// Он меняет визуал худа и лишает его скина на персонаже + флаги чтобы не прятал волосы
// Он добавляет и экипирует в слот персонажа шарф
// В случае если флаг стоит на "нет" он наоборот удаляет шарф и добавляет обратно капюшон.
/obj/item/clothing/suit/space/space_ninja/proc/toggle_scarf()
	var/mob/living/carbon/human/ninja = affecting
	if(!n_scarf)
		var/obj/item/clothing/neck/ninjascarf/new_scarf = new
		if(!ninja.equip_to_slot_if_possible(new_scarf, slot_neck, 1))		//Уже что то надето в слоте шеи? Алярма, снимите помеху прежде чем продолжить.
			to_chat(ninja, "[span_userdanger("ERROR")]: 100220 UNABLE TO TRANSFORM HEAD GEAR\nABORTING...")
			return FALSE
		n_scarf = new_scarf
		n_scarf.icon_state="ninja_scarf_[scarf_design_choice]"
		n_scarf.item_state="ninja_scarf_[scarf_design_choice]"
		n_hood.icon_state = "ninja_hood_blocked_[scarf_design_choice]"
		n_hood.flags &= ~BLOCKHAIR
		n_hood.desc = "Even thou your hood now looks like a scarf, it still offers a smart and adaptive protection from damage to your head. And from the other headwear as well..."
		return TRUE
	else
		qdel(n_scarf)
		n_scarf = null
		n_hood.flags |= BLOCKHAIR
		n_hood.desc = initial(n_hood.desc)
		return TRUE

//Блочит определённую часть костюма, чтобы ниндзя не мог её снять
/obj/item/clothing/suit/space/space_ninja/proc/toggle_ninja_nodrop(var/obj/item/ninja_clothing)
	ninja_clothing.flags ^= NODROP
	current_initialisation_text = "[ninja_clothing.flags & NODROP ? "Блокировка" : "Разблокировка"]: [ninja_clothing.name]... Успех"
	playsound(ninja_clothing.loc, 'sound/items/piston.ogg', 10, TRUE)
	sleep(10)
//	to_chat(ninja_clothing.loc, "<span class='notice'>Your [ninja_clothing.name] is now [ninja_clothing.flags & NODROP ? "locked" : "unlocked"].</span>")

//Необходимо дабы костюм "Защищал" от ЕМП взрывов(особенно от своих же) протезы/импланты игрока
/proc/toggle_emp_proof(list/bodyparts, toggle_to)
	for(var/obj/item/organ/bodypart in bodyparts)
		if(toggle_to)
			bodypart.emp_proof = TRUE
		else
			bodypart.emp_proof = initial(bodypart.emp_proof)

//Эффекты призванные "Намекнуть", что рядом есть ниндзя
/obj/item/clothing/suit/space/space_ninja/proc/stealth_creepy_effects()
	var/mob/living/carbon/human/ninja = affecting
	if(prob(stealth_ambient_chance))
		var/sounds = pick(
			'sound/ambience/ambifailure.ogg',
			'sound/ambience/ambigen5.ogg',
			'sound/machines/ventcrawl.ogg',
			'sound/effects/noise_scan.ogg',
			'sound/effects/footstep/wood1.ogg',
			'sound/effects/footstep/wood2.ogg',
			'sound/effects/footstep/wood3.ogg',
			'sound/effects/footstep/wood4.ogg',
			'sound/effects/footstep/wood5.ogg')

		var/random_danger_text = pick(
			"У вас по коже пробежали мурашки...",
			"Такое чувство, что на вас кто-то смотрит...",
			"Кажется вы врезались во что-то!",
			"Кто-то наступил вам на ногу! Или вам причудилось?...",
			"Вы задели кого-то локтем!")
		var/random_subtle_text = pick(
			"Вам кажется вы слышали шаги...",
			"Что то мелькнуло у вас перед глазами...",
			"Это просто был ветер, да?",
			"Кажется рядом кто-то топает...",
			"Крысы в техах шумят что ле...?")
		switch(rand(1,3))
			if(1)
				if(stealth_ambient_chance >= 15)
					spark_system.start()
				else
					for(var/mob/living/carbon/other_mob in view(7,ninja))
						if(other_mob == ninja)
							continue
						to_chat(other_mob, span_info(random_subtle_text))
			if(2)
				if(stealth_ambient_chance >= 40)
					for(var/mob/living/carbon/other_mob in view(7,ninja))
						if(other_mob == ninja)
							continue
						to_chat(other_mob, span_danger(random_danger_text))
				else
					playsound(ninja, sounds, 20, FALSE)
			if(3)
				if(stealth_ambient_chance < 50)
					stealth_ambient_chance += 1
/**
 * Proc used to delete all the attachments and itself.
 * Can be called to entire rid of the suit pieces and the suit itself.
 */
/obj/item/clothing/suit/space/space_ninja/proc/terminate()
	visible_message(span_warning("[src] ignites and evaporates in the air!"))
	QDEL_NULL(n_hood)
	QDEL_NULL(n_gloves)
	QDEL_NULL(n_shoes)
	QDEL_NULL(n_mask)
	QDEL_NULL(n_scarf)
	QDEL_NULL(src)
