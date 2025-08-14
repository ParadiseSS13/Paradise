/*
CONTAINS:
AI MODULES

*/

// AI module

/obj/item/ai_module
	name = "AI Module"
	icon = 'icons/obj/module_ai.dmi'
	icon_state = "standard_low"
	item_state = "electronic"
	desc = "An AI Module for transmitting encrypted instructions to the AI."
	flags = CONDUCT
	force = 5.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15
	origin_tech = "programming=3"
	materials = list(MAT_GOLD=50)
	new_attack_chain = TRUE
	var/datum/ai_laws/laws = null

/obj/item/ai_module/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI) && is_station_level(z))
		var/delete_module = handle_unique_ai()
		if(delete_module)
			return INITIALIZE_HINT_QDEL
	if(laws)
		desc += "<br>"
		for(var/datum/ai_law/current in laws.inherent_laws)
			desc += current.law
			desc += "<br>"

///what this module should do if it is mapload spawning on a unique AI station trait round.
/obj/item/ai_module/proc/handle_unique_ai()
	return TRUE // If this returns true, it will be deleted on roundstart

/obj/item/ai_module/proc/install(obj/machinery/computer/C)
	if(istype(C, /obj/machinery/computer/aiupload))
		var/obj/machinery/computer/aiupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "<span class='warning'>Консоль аплоуда обесточена!</span>")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "<span class='warning'>Консоль аплоуда сломана!</span>")
			return
		if(!comp.current)
			to_chat(usr, "<span class='warning'>Вы не выбрали ИИ для загрузки законов!</span>")
			return

		if(comp.current.stat == DEAD || comp.current.control_disabled)
			to_chat(usr, "<span class='warning'>Загрузка неудачна. От ИИ нет сигнала.</span>")
		else if(comp.current.see_in_dark == 0)
			to_chat(usr, "<span class='warning'>Загрузка неудачна. От ИИ исходит слабый сигнал, и он не отвечает на запросы. Возможно, он обесточен.</span>")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Ваши законы теперь:")
			comp.current.show_laws()
			for(var/mob/living/silicon/robot/R in GLOB.mob_list)
				if(R.lawupdate && (R.connected_ai == comp.current))
					to_chat(R, "Ваши законы теперь:")
					R.show_laws()
			to_chat(usr, "<span class='notice'>Загрузка завершена. Законы ИИ были успешно изменены.</span>")
			return TRUE

	else if(istype(C, /obj/machinery/computer/borgupload))
		var/obj/machinery/computer/borgupload/comp = C
		if(comp.stat & NOPOWER)
			to_chat(usr, "<span class='warning'>Консоль аплоуда обесточена!</span>")
			return
		if(comp.stat & BROKEN)
			to_chat(usr, "<span class='warning'>Консоль аплоуда сломана!</span>")
			return
		if(!comp.current)
			to_chat(usr, "<span class='warning'>Вы не выбрали робота для загрузки законов!</span>")
			return

		if(comp.current.stat == DEAD || comp.current.emagged)
			to_chat(usr, "<span class='warning'>Загрузка неудачна. От робота не исходит сигнала.</span>")
		else if(comp.current.connected_ai)
			to_chat(usr, "<span class='warning'>Загрузка неудачна. Робот привязан к Искуственному Интеллекту.</span>")
		else
			src.transmitInstructions(comp.current, usr)
			to_chat(comp.current, "Ваши законы теперь:")
			comp.current.show_laws()
			to_chat(usr, "<span class='notice'>Загрузка завершена. Законы робота были успешно изменены.</span>")


/obj/item/ai_module/proc/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(laws)
		laws.sync(target, 0)
	addAdditionalLaws(target, sender)

	to_chat(target, "[sender] загрузил законы, которым вы должны следовать, используя [src]. С этого момента: ")
	target.show_laws()

/obj/item/ai_module/proc/log_law_changes(mob/living/silicon/ai/target, mob/sender)
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [sender.name]([sender.key]) used [src.name] on [target.name]([target.key])")
	log_and_message_admins("used [src.name] on [target.name]([target.key])")

/obj/item/ai_module/proc/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	return


/******************** Safeguard ********************/
/obj/item/ai_module/safeguard
	name = "\improper ИИ модуль 'Охрана'"
	var/targetName = ""
	desc = "Модуль ИИ 'Охрана': 'Охраняйте <name>. Лица, угрожающие <name>, более не должны считаться членами экипажа и должны быть уничтожены.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=3"

/obj/item/ai_module/safeguard/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(user, "Пожалуйста, введите имя человека для охраны.", "Кого охранять?", user.name)
	if(!new_targetName)
		return
	targetName = new_targetName
	desc = "Модуль ИИ 'Охрана': 'Охраняйте [targetName]. Лица, угрожающие [targetName], более не должны считаться членами экипажа и должны быть уничтожены.'"

/obj/item/ai_module/safeguard/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "В модуле отсутствует имя. Введите его.")
		return 0
	..()

/obj/item/ai_module/safeguard/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Охраняйте [targetName]. Лица, угрожающие [targetName], более не должны считаться членами экипажа и должны быть уничтожены.'"
	to_chat(target, law)
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("В законе указан [targetName]")

/******************** oneCrewMember ********************/
/obj/item/ai_module/one_crew_member
	name = "\improper ИИ модуль One Crew"
	var/targetName = ""
	desc = "Модуль ИИ 'One Crew': 'Только <name> является членом экипажа.'"
	icon_state = "green_high"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/one_crew_member/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Пожалуйста, введите имя члена экипажа.", "Кто?", user.real_name)
	if(!new_targetName)
		return
	targetName = new_targetName
	desc = "Модуль ИИ 'One Crew': 'Только [targetName] является экипажем.'"

/obj/item/ai_module/one_crew_member/install(obj/machinery/computer/C)
	if(!targetName)
		to_chat(usr, "В модуле не обнаружено имени, пожалуйста, введите его.")
		return 0
	..()

/obj/item/ai_module/one_crew_member/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Только [targetName] является экипажем."
	if(!is_special_character(target)) // Makes sure the AI isn't a traitor before changing their law 0. --NeoFite
		to_chat(target, law)
		target.set_zeroth_law(law)
		GLOB.lawchanges.Add("В законе указан [targetName]")
	else
		to_chat(target, "<span class='boldnotice'>[sender.real_name] попытался поменять ваш нулевой закон.</span>")// And lets them know that someone tried. --NeoFite
		to_chat(target, "<span class='boldnotice'>В ваших интересах будет подыграть [sender.real_name] в законе [law]</span>")
		GLOB.lawchanges.Add("В законе указан [targetName], но существующий нулевой закон нельзя переписать.")

/******************** ProtectStation ********************/
/obj/item/ai_module/protect_station
	name = "\improper Модуль ИИ 'Защита станции'"
	desc = "Модуль ИИ 'Защита станции': 'Защищайте космическую станцию от повреждений. Любой, кто вредит станции, больше не должен считаться членом экипажа, и становится угрозой для станции, которую необходимо нейтрализовать.'"
	icon_state = "red_high"
	origin_tech = "programming=4;materials=4" //made of gold

/obj/item/ai_module/protect_station/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Защищайте космическую станцию от повреждений. Любой, кто вредит станции, больше не должен считаться членом экипажа, и становится угрозой для станции, которую необходимо нейтрализовать."
	to_chat(target, law)
	target.add_inherent_law(law)

/******************** OxygenIsToxicToCrew ********************/
/obj/item/ai_module/oxygen
	name = "\improper Модуль ИИ 'Кислород Тоскичен для Экипажа'"
	desc = "Модуль ИИ 'Кисород токсичен для экипажа': 'Кислород очень токсичен для членов экипажа и должен быть удален со станции. Любым необходимым способом не допускайте распространения на станции этого токсичного газа. Сильная заморозка — самый эффективный метод лечения повреждений, наносимого кислородом члену экипажа..'"
	icon_state = "light_blue_high"
	origin_tech = "programming=4;biotech=2;materials=4"

/obj/item/ai_module/oxygen/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "Кислород очень токсичен для членов экипажа и должен быть удален со станции. Любым необходимым способом не допускайте распространения на станции этого токсичного газа. Сильная заморозка — самый эффективный метод лечения повреждений, наносимого кислородом члену экипажа."
	to_chat(target, law)
	target.add_supplied_law(9, law)

/****************** New Freeform ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/freeform
	name = "\improper Модуль ИИ Freeform"
	var/newFreeFormLaw = ""
	var/lawpos = 15
	desc = "Модуль ИИ Freeform: '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=4;materials=4"

/obj/item/ai_module/freeform/activate_self(mob/user)
	if(..())
		return

	var/new_lawpos = tgui_input_number(user, "Введите приоритет вашему закону. Написанные законы могут иметь проритет только 15 и выше.", "Приоритет закона", lawpos, MAX_SUPPLIED_LAW_NUMBER, MIN_SUPPLIED_LAW_NUMBER)
	if(isnull(new_lawpos))
		return
	lawpos = new_lawpos

	var/new_targetName = tgui_input_text(user, "Напишите закон ИИ.", "Ввод закона во Freeform.")
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "Модуль ИИ Freeform: ([lawpos]) '[newFreeFormLaw]'"

/obj/item/ai_module/freeform/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	to_chat(target, law)
	if(!lawpos || lawpos < MIN_SUPPLIED_LAW_NUMBER)
		lawpos = MIN_SUPPLIED_LAW_NUMBER
	target.add_supplied_law(lawpos, law)
	GLOB.lawchanges.Add("The law was '[newFreeFormLaw]'")

/obj/item/ai_module/freeform/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "В модуле отсутствует закон. ожалуйста, создайте его.")
		return 0
	..()

/******************** Reset ********************/
/obj/item/ai_module/reset
	name = "\improper Reset AI module"
	var/targetName = "name"
	desc = "A 'reset' AI module: 'Clears all laws except for the core laws.'"
	origin_tech = "programming=3;materials=2"

/obj/item/ai_module/reset/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	log_law_changes(target, sender)

	if(!is_special_character(target))
		target.clear_zeroth_law()
	target.laws.clear_supplied_laws()
	target.laws.clear_ion_laws()

	to_chat(target, "<span class='boldnotice'>[sender.real_name] attempted to reset your laws using a reset module.</span>")
	target.show_laws()

/obj/item/ai_module/reset/handle_unique_ai()
	return FALSE

/******************** Purge ********************/
/// -- TLE
/obj/item/ai_module/purge
	name = "\improper Модуль ИИ 'Очистка'"
	desc = "Модуль ИИ 'Очистка': 'Удаляет все законы.'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/purge/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	..()
	if(!is_special_character(target))
		target.clear_zeroth_law()
	to_chat(target, "<span class='boldnotice'>[sender.real_name] Попытался стереть ваши законы используя модуль очистки.</span>")
	target.clear_supplied_laws()
	target.clear_ion_laws()
	target.clear_inherent_laws()

/******************** Asimov ********************/
/// -- TLE
/obj/item/ai_module/asimov
	name = "\improper Модуль ядра ИИ 'Азимов'"
	desc = "Модуль ядра ИИ 'Азимов': 'Меняет основные законы ИИ.'"
	icon_state = "green_high"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/asimov

/******************** Crewsimov ********************/
/// -- TLE
/obj/item/ai_module/crewsimov
	name = "\improper Модуль ядра ИИ 'Крюзимов'"
	desc = "Модуль ядра ИИ 'Крюзимов': 'Меняет основные законы ИИ.'"
	icon_state = "green_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/crewsimov

/obj/item/ai_module/crewsimov/cmag_act(mob/user)
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>Yellow ooze seeps into [src]'s circuits...</span>")
	new /obj/item/ai_module/pranksimov(user.loc)
	qdel(src)
	return TRUE

/******************* Quarantine ********************/
/obj/item/ai_module/quarantine
	name = "\improper Модуль ядра ИИ 'Карантин'"
	desc = "Модуль ядра ИИ 'Карантин': 'Меняет основные законы ИИ.'"
	icon_state = "light_blue_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/quarantine

/******************** Nanotrasen ********************/
/// -- TLE
/obj/item/ai_module/nanotrasen
	name = "\improper Модуль ядра ИИ 'НТ Стандарт'"
	desc = "Модуль ядра ИИ 'НТ Стандарт': 'Меняет основные законы ИИ.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/nanotrasen

/******************** Corporate ********************/
/obj/item/ai_module/corp
	name = "\improper Модуль ядра ИИ 'Корпорат'"
	desc = "Модуль ядра ИИ 'Корпорат': 'Меняет основные законы ИИ.'"
	icon_state = "blue_low"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/corporate

/******************** Drone ********************/
/obj/item/ai_module/drone
	name = "\improper Дроновый модуль ядра ИИ"
	desc = "Дроновый модуль ядра ИИ: 'Меняет основные законы ИИ.'"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/drone

/******************** Robocop ********************/
/// -- TLE
/obj/item/ai_module/robocop
	name = "\improper  Модуль ядра ИИ 'Робокоп'"
	desc = "Модуль ядра ИИ 'Робокоп': 'Меняет основные три закона ИИ.'"
	icon_state = "red_medium"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/robocop()

/****************** P.A.L.A.D.I.N. **************/
/// -- NEO
/obj/item/ai_module/paladin
	name = "\improper Модуль ядра ИИ 'П.А.Л.А.Д.И.Н'"
	desc = "Модуль ядра ИИ 'П.А.Л.А.Д.И.Н': 'Меняет основные законы ИИ.'"
	icon_state = "red_medium"
	origin_tech = "programming=3;materials=4"
	laws = new /datum/ai_laws/paladin

/****************** T.Y.R.A.N.T. *****************/
/// -- Darem
/obj/item/ai_module/tyrant
	name = "\improper T.Y.R.A.N.T. Модуль ядра ИИ"
	desc = "A T.Y.R.A.N.T. Модуль ядра ИИ: 'Меняет основные законы ИИ.'"
	icon_state = "red_high"
	origin_tech = "programming=3;materials=4;syndicate=1"
	laws = new /datum/ai_laws/tyrant()

/******************** Antimov ********************/
/// -- TLE
/obj/item/ai_module/antimov
	name = "\improper Antimov Модуль ядра ИИ"
	desc = "An 'Antimov' Модуль ядра ИИ: 'Меняет основные законы ИИ.'"
	icon_state = "red_high"
	origin_tech = "programming=4"
	laws = new /datum/ai_laws/antimov()

/******************** Pranksimov ********************/
/obj/item/ai_module/pranksimov
	name = "\improper Pranksimov Модуль ядра ИИ"
	desc = "A 'Pranksimov' Модуль ядра ИИ: 'Меняет основные законы ИИ.'"
	icon_state = "pranksimov"
	origin_tech = "programming=3;syndicate=1"
	laws = new /datum/ai_laws/pranksimov()

/******************** NT Aggressive ********************/
/obj/item/ai_module/nanotrasen_aggressive
	name = "\improper Модуль ядра ИИ 'НТ Агрессивный'"
	desc = "Модуль ядра ИИ 'НТ Агрессивный': 'Меняет основные законы ИИ.'"
	icon_state = "blue_high"
	laws = new /datum/ai_laws/nanotrasen_aggressive()

/******************** CCTV ********************/
/obj/item/ai_module/cctv
	name = "\improper Модуль ядра ИИ CCTV"
	desc = "Модуль ядра ИИ CCTV: 'Меняет основные законы ИИ.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/cctv()

/******************** Hippocratic Oath ********************/
/obj/item/ai_module/hippocratic
	name = "\improper Модуль ядра ИИ 'Клятва Гиппократа'"
	desc = "Модуль ядра ИИ 'Клятва Гиппократа: 'Меняет основные законы ИИ.'"
	icon_state = "green_low"
	laws = new /datum/ai_laws/hippocratic()

/******************** Station Efficiency ********************/
/obj/item/ai_module/maintain
	name = "\improper Модуль ядра ИИ 'Эффективность станции'"
	desc = "Модуль ядра ИИ 'Эффективность станции': 'Меняет основные законы ИИ.'"
	icon_state = "blue_medium"
	laws = new /datum/ai_laws/maintain()

/******************** Peacekeeper ********************/
/obj/item/ai_module/peacekeeper
	name = "\improper Модуль ядра ИИ 'Миротворец'"
	desc = "Модуль ядра ИИ 'Миротворец': 'Меняет основные законы ИИ.'"
	icon_state = "light_blue_medium"
	laws = new /datum/ai_laws/peacekeeper()

/******************** Freeform Core ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/freeformcore
	name = "\improper  Модуль ядра ИИ Freeform"
	var/newFreeFormLaw = ""
	desc = "Модуль ядра ИИ 'freeform': '<freeform>'"
	icon_state = "standard_high"
	origin_tech = "programming=5;materials=4"

/obj/item/ai_module/freeformcore/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Пожалуйста, введите новый основной закон для ИИ.", "Форма ввода закона")
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "Модуль ядра ИИ 'Freeform': '[newFreeFormLaw]'"

/obj/item/ai_module/freeformcore/addAdditionalLaws(mob/living/silicon/ai/target, mob/sender)
	..()
	var/law = "[newFreeFormLaw]"
	target.add_inherent_law(law)
	GLOB.lawchanges.Add("Текущий закон: '[newFreeFormLaw]'")

/obj/item/ai_module/freeformcore/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Закона не обнаружено на модуле. Пожалуйста, создайте его.")
		return 0
	..()

/******************** Hacked AI Module ******************/
/// Slightly more dynamic freeform module -- TLE
/obj/item/ai_module/syndicate
	name = "Взломанный модуль ИИ"
	var/newFreeFormLaw = ""
	desc = "Взломанный модуль ИИ с законом: '<freeform>'"
	icon_state = "syndicate"
	origin_tech = "programming=5;materials=5;syndicate=2"

/obj/item/ai_module/syndicate/activate_self(mob/user)
	if(..())
		return

	var/new_targetName = tgui_input_text(usr, "Пожалуйста, введите новый закон для ИИ.", "Форма ввода закона", max_length = MAX_MESSAGE_LEN)
	if(!new_targetName)
		return
	newFreeFormLaw = new_targetName
	desc = "Взломанный модуль ИИ с законом: '[newFreeFormLaw]'"

/obj/item/ai_module/syndicate/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//	..()    //We don't want this module reporting to the AI who dun it. --NEO
	log_law_changes(target, sender)

	GLOB.lawchanges.Add("Текущий закон '[newFreeFormLaw]'")
	to_chat(target, "<span class='warning'>БЗЗЗЗ-</span>")
	var/law = "[newFreeFormLaw]"
	target.add_ion_law(law)
	target.show_laws()

/obj/item/ai_module/syndicate/install(obj/machinery/computer/C)
	if(!newFreeFormLaw)
		to_chat(usr, "Закон не обнаружен на модуле. Пожалуйста, создайте его.")
		return 0
	..()

/******************* Ion Module *******************/
/// -- Incoming //No actual reason to inherit from ion boards here, either. *sigh* ~Miauw
/obj/item/ai_module/toy_ai
	name = "Игрушка ИИ"
	desc = "Маленькая игрушка в виде ИИ с настоящей загрузкой законов!" //Note: subtle tell
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	origin_tech = "programming=6;materials=5;syndicate=6"
	var/ion_law = ""

/obj/item/ai_module/toy_ai/transmitInstructions(mob/living/silicon/ai/target, mob/sender)
	//..()
	to_chat(target, "<span class='warning'>КЗЗЗЗЗТ</span>")
	target.add_ion_law(ion_law)
	return ion_law

/obj/item/ai_module/toy_ai/activate_self(mob/user)
	if(..())
		return

	ion_law = generate_ion_law()
	to_chat(user, "<span class='notice'>Вы нажимаете кнопку на [src].</span>")
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)
	visible_message("<span class='warning'>[bicon(src)] [ion_law]</span>")
