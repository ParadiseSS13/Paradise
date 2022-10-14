/datum/species/golem
	name = "Голем"
	name_plural = "Golems"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, NOGUNS, PIERCEIMMUNE)
	dies_at_threshold = TRUE
	speed_mod = 2
	brute_mod = 0.45 //55% damage reduction
	burn_mod = 0.45
	tox_mod = 0.45
	clone_mod = 0.45
	brain_mod = 0.45
	stamina_mod = 0.45
	siemens_coeff = 0
	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	nojumpsuit = TRUE

	reagent_tag = PROCESS_ORG

	warning_low_pressure = -INFINITY
	hazard_low_pressure = -INFINITY
	hazard_high_pressure = INFINITY
	warning_high_pressure = INFINITY

	cold_level_1 = -INFINITY
	cold_level_2 = -INFINITY
	cold_level_3 = -INFINITY

	heat_level_1 = INFINITY
	heat_level_2 = INFINITY
	heat_level_3 = INFINITY

	blood_color = "#515573"
	flesh_color = "#137E8F"
	skinned_type = /obj/item/stack/sheet/metal

	blacklisted = TRUE // To prevent golem subtypes from overwhelming the odds when random species changes, only the Random Golem type can be chosen
	dangerous_existence = TRUE

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator
		) //Has standard darksight of 2.

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/unbreakable/sturdy),
		"groin" =  list("path" = /obj/item/organ/external/groin/unbreakable/sturdy),
		"head" =   list("path" = /obj/item/organ/external/head/unbreakable/sturdy),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/unbreakable/sturdy),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/unbreakable/sturdy),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/unbreakable/sturdy),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/unbreakable/sturdy),
		"l_hand" = list("path" = /obj/item/organ/external/hand/unbreakable/sturdy),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/unbreakable/sturdy),
		"l_foot" = list("path" = /obj/item/organ/external/foot/unbreakable/sturdy),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/unbreakable/sturdy))

	suicide_messages = list(
		"рассыпается в прах!",
		"разбивает своё тело на части!")

	var/golem_colour = rgb(170, 170, 170)
	var/info_text = "Будучи <span class='danger'>железным големом</span>, вы не обладаете отличительными особенностями."
	var/random_eligible = TRUE
	var/prefix = "Железн" 		// неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	var/prefix_type = 1			// Тип гендеризации префикса для более гладких переводов. 1-й = "-ый", 2-й = "-ой", 3-й = ""

	var/gender_name = MALE 	// Пол для имени голема. Default - мужской
	var/chance_name_male = 80	// Шанс на выпадение пола для имени
	var/chance_name_female = 60
	var/chance_name_neuter = 5

	var/list/special_names = list(
		MALE = list("Человек", "Биба", "Боба", "Ржавчик", "Утюг", "Металлист", "Мужик", "Сплав", "Брусок", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)

	var/human_surname_chance = 5
	var/special_name_chance = 10
	var/owner //dobby is a free golem

/datum/species/golem/get_random_name()
	//определяем случайный пол для ИМЕНИ голема. Если же все шансы провалились, то берется дефолтное значение пола
	if (prob(chance_name_male))
		gender_name = MALE
	else if (prob(chance_name_female))
		gender_name = FEMALE
	else if (prob(chance_name_neuter))
		gender_name = NEUTER

	var/golem_surname //Имя голема

	//выбираем изначально случайное големское имя аля "Андезит"
	switch (gender_name)
		if (MALE)
			if (length(GLOB.golem_male)) //Бйонд имеет привычку с отваливанием файлов. Чтобы такого не допустить, мы проверяем длину файла
				golem_surname = "[pick(GLOB.golem_male)]"
		if (FEMALE)
			if (length(GLOB.golem_female))
				golem_surname = "[pick(GLOB.golem_female)]"
		if (NEUTER)
			if (length(GLOB.golem_neuter))
				golem_surname = "[pick(GLOB.golem_neuter)]"


	//10% шанс выбрать спец. имя или имя выдастся если оно до сих пор пустое, с условием что у голема имеются спец. имена для данного гендера
	if(special_names && special_names.len && (prob(special_name_chance) || (golem_surname == null)))
		golem_surname = pick(special_names[gender_name])

	// 5% шанс выбрать человеческое имя или фамилию, ну или если голем до сих пор не имеет имени
	if(prob(human_surname_chance) || (golem_surname == null) || golem_surname == "" || golem_surname == " ") //игра по прежнему не считает строчные пустые элементы != null элементами. Из-за чего нужна такая проверка
		switch (gender_name)
			if (MALE)
				if (prob(50)) //выбираем мужское имя или фамилию
					golem_surname = pick(GLOB.first_names_male)
				else
					golem_surname = pick(GLOB.last_names)
			if (FEMALE)
				if (prob(50)) //выбираем женское имя или фамилию
					golem_surname = pick(GLOB.first_names_female)
				else
					golem_surname = pick(GLOB.last_names_female)
		 	if (NEUTER)
			 	golem_surname = pick("Нечто", "Чудо") //Средний пол голема

	//устанавливаем окончание прилагательных префиксов (золотой мужик теперь золотОЙ, а не золотЫЙ)
	var/end_pr
	switch (prefix_type)
		if (1)
			end_pr = genderize_ru(gender_name,"ый","ая","ое","ые")
		if (2)
			end_pr = genderize_ru(gender_name,"ой","ая","ое","ые")
		if (3)
			end_pr = ""

	//гендеризируем прилагательное-префикс и приписываем наше половое имя
	var/golem_name
	if(prefix_type == 3)
		golem_name = "[prefix][end_pr]-[golem_surname]"
	else
		golem_name = "[prefix][end_pr] [golem_surname]"
	return golem_name

/datum/species/golem/on_species_gain(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.assigned_role = "Golem"
		if(owner)
			H.mind.special_role = SPECIAL_ROLE_GOLEM
		else
			H.mind.special_role = SPECIAL_ROLE_FREE_GOLEM
	H.real_name = get_random_name()
	H.name = H.real_name
	to_chat(H, info_text)

//Random Golem

/datum/species/golem/random
	name = "Случайный Голем"
	blacklisted = FALSE
	dangerous_existence = FALSE
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)

//Golem subtypes

//Leader golems, can resonate to communicate with all other golems
/datum/species/golem/adamantine
	name = "Адамантиновый Голем"
	skinned_type = /obj/item/stack/sheet/mineral/adamantine
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator,
		"vocal_cords" = /obj/item/organ/internal/vocal_cords/adamantine
		)
	golem_colour = rgb(68, 238, 221)
	info_text = "Будучи <span class='danger'>адамантиновым големом</span>, вы обладаете особыми голосовыми связками, позволяющие вам «резонировать» послания всем големам."
	prefix = "Адамантинов" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Плазменный Голем"
	skinned_type = /obj/item/stack/ore/plasma
	golem_colour = rgb(170, 51, 221)
	heat_level_1 = 360
	heat_level_2 = 400
	heat_level_3 = 460
	info_text = "Будучи <span class='danger'>плазменным големом</span>, вы легко сгораете. Будьте осторожны, если вы сильно нагреетесь &mdash; взорвётесь!"
	heatmod = 0 //fine until they blow up
	prefix = "Плазменн" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Потоп", "Прилив", "Разлив", "Залив", "Мужик", "Наводнение", "Поток", "Ливень", "Пожар", "Стержень", "Минерал", "Мужик", "Горец", "Сгоратель", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/handle_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>Вы чувствуете, что можете взорваться в любой момент!</span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>Вы чувствуете себя стабильней.</span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H), 1, 2, 4, flame_range = 5, cause = H)
		add_attack_logs(H, null, "exploded", ATKLOG_FEW)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Подожгите себя и достигните взрыва!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, "<span class='notice'>Вы подожгли себя!</span>")
		else
			to_chat(owner, "<span class='warning'>Вы попытались поджечь себя, но неудачно!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Алмазный Голем"
	golem_colour = rgb(0, 255, 255)
	brute_mod = 0.3 //70% damage reduction up from 55%
	burn_mod = 0.3
	tox_mod = 0.3
	clone_mod = 0.3
	brain_mod = 0.3
	stamina_mod = 0.3
	skinned_type = /obj/item/stack/ore/diamond
	info_text = "Будучи <span class='danger'>алмазным големом</span>, вы прочнее обычных големов."
	prefix = "Алмазн" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	chance_name_male = 50
	chance_name_female = 80
	chance_name_neuter = 10
	special_name_chance = 60

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Золотой Голем"
	golem_colour = rgb(204, 204, 0)
	speed_mod = 1
	brute_mod = 0.75 //25% damage reduction down from 55%
	burn_mod = 0.75
	tox_mod = 0.75
	clone_mod = 0.75
	brain_mod = 0.75
	stamina_mod = 0.75
	skinned_type = /obj/item/stack/ore/gold
	info_text = "Будучи <span class='danger'>золотым големом</span>, вы более быстры, но менее прочны, нежели обычный голем."
	prefix = "Золот" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	prefix_type = 2
	special_names = list(
		MALE = list("Мальчик", "Мужик", "Человек", "Ручник", "Молодежник", "Понтовщик", "Мост", "Яблочник", "Ювелир", "Дорогуша", "Дурак", "Брусок", "Закат", "Дым", "Шелк", "Сплав", "Ремесленник", "Мёд", "Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева", "Рука", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	special_name_chance = 80

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Серебрянный Голем"
	golem_colour = rgb(221, 221, 221)
	punchstunthreshold = 9 //60% chance, from 40%
	skinned_type = /obj/item/stack/ore/silver
	info_text = "Будучи <span class='danger'>серебряным големом</span>, вы с большей вероятностью можете оглушить противников атаками."
	prefix = "Серебрян" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Серфер", "Чарриот", "Мужик", "Глушитель", "Тихон", "Анестетик", "Ювелир", "Пупс"),
		FEMALE = list("Дева", "Ювелирка", "Драгоценность", "Серёжка"),
		NEUTER = list("Украшение", "Кольцо")
		)
	chance_name_male = 70
	chance_name_female = 60
	chance_name_neuter = 10
	special_name_chance = 40

//Harder to stun, deals more damage, but it's even slower
/datum/species/golem/plasteel
	name = "Пласталиевый Голем"
	golem_colour = rgb(187, 187, 187)
	stun_mod = 0.4
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 //still 40% stun chance
	speed_mod = 4 //pretty fucking slow
	skinned_type = /obj/item/stack/ore/iron
	info_text = "Будучи <span class='danger'>пласталиевым големом</span>, вы медлительны, но вас сложнее оглушить, а ваши кулаки причиняют серьёзные повреждения."
	prefix = "Пласталиев" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Сплав", "Брусок", "Мужик", "Кусок", "Минерал", "Кирпич", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)
	unarmed_type = /datum/unarmed_attack/golem/plasteel

/datum/unarmed_attack/golem/plasteel
	attack_verb = list("smash")
	attack_sound = 'sound/effects/meteorimpact.ogg'

//More resistant to burn damage and immune to ashstorm
/datum/species/golem/titanium
	name = "Титановый Голем"
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "Будучи <span class='danger'>титановым големом</span>, вы частично устойчивы к ожогам и невосприимчивы к пепельным бурям."
	burn_mod = 0.405
	prefix = "Титанов" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Диоксид", "Сплав", "Брусок", "Мужик", "Минерал", "Кусок", "Кирпич", "Буреходец", "Пожарник", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)

/datum/species/golem/titanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "ash"

/datum/species/golem/titanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"

//Even more resistant to burn damage and immune to ashstorms and lava
/datum/species/golem/plastitanium
	name = "Пластитановый Голем"
	golem_colour = rgb(136, 136, 136)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "Будучи <span class='danger'>пластитановым големом</span>, вы крайне устойчивы к ожогам и невосприимчивы к пепельным бурям и лаве."
	burn_mod = 0.36
	prefix = "Пластитанов" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Сплав", "Брусок", "Кусок", "Мужик", "Кирпич", "Минерал", "Буреходец", "Пожарник", "Лавоходец", "Лавоплавунец", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
		FEMALE = list("Дева"),
		NEUTER = null
		)

/datum/species/golem/plastitanium/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.weather_immunities |= "lava"
	C.weather_immunities |= "ash"

/datum/species/golem/plastitanium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.weather_immunities -= "ash"
	C.weather_immunities -= "lava"

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Голем из инопланетных сплавов"
	golem_colour = rgb(51, 51, 51)
	skinned_type = /obj/item/stack/sheet/mineral/abductor
	language = "Golem Mindlink"
	default_language = "Golem Mindlink"
	speed_mod = 1 //faster
	info_text = "Будучи <span class='danger'>големом из инопланетных сплавов</span>, вы быстрее двигаетесь и со временем регенерируете. Однако, вы можете разговаривать только с големами из того же материала, что и вы."
	prefix = "Инопланетн" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Инопришеленец", "Технологичный Голем", "Наблюдатель", "Незнакомец", "Странник", "Чужак", "Посланник", "Минерал", "Мужик", "Пришеленец", "Пупс"),
		FEMALE = null,
		NEUTER = null
		)
	special_name_chance = 40
	chance_name_male = 80
	chance_name_female = 30

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.adjustBruteLoss(-2)
	H.adjustFireLoss(-2)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

/datum/species/golem/alloy/can_understand(mob/other) //Can understand everyone, but they can only speak over their mindlink
	return TRUE

/datum/species/golem/alloy/on_species_gain(mob/living/carbon/human/H)
	..()
	H.languages.Cut()
	H.add_language("Golem Mindlink")

//Regenerates like dionas, less resistant
/datum/species/golem/wood
	name = "Деревянный Голем"
	golem_colour = rgb(158, 112, 75)
	skinned_type = /obj/item/stack/sheet/wood
	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, NOGUNS, PIERCEIMMUNE, IS_PLANT)
	//Can burn and take damage from heat
	brute_mod = 0.7 //30% damage reduction down from 55%
	burn_mod = 0.875
	tox_mod = 0.7
	clone_mod = 0.7
	brain_mod = 0.7
	stamina_mod = 0.7
	heatmod = 1.5

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	info_text = "Будучи <span class='danger'>деревянным големом</span>, вы обладаете некоторыми особенностями растений: Вы получаете урон от экстремальных температур, вас можно поджечь и у вас меньше брони, чем у обычного голема. Вы регенерируете на свету и увядаете во тьме."
	prefix = "Деревянн" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Короед", "Грут", "Пень", "Дубень", "Дуболом", "Дуб", "Рогоз", "Сок", "Клен", "Вяз", "Тополь ", "Осина", "Ясень", "Бук", "Каштан", "Кедр", "Каштан", "Кипарис", "Пихта", "Боярышник", "Гикори", "Айронвуд", "Можжевельник", "Лист", "Мангровый Лес", "Тополь", "Редбад", "Сассафрас", "Ель", "Сумак", "Ствол", "Орех", "Тис", "Пупс"),
		FEMALE = list("Дева", "Ива", "Катальпа", "Ветка", "Тростинка", "Палка", "Береза", "Лиственница", "Липа", "Лещина", "Пальма", "Азимина", "Сосна"),
		NEUTER = list("Красное Дерево", "Редкое Дерево", "Древо")
		)
	human_surname_chance = 0
	chance_name_male = 80
	chance_name_female = 70
	special_name_chance = 100

/datum/species/golem/wood/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0)
			H.clear_alert("nolight")
		else
			H.throw_alert("nolight", /obj/screen/alert/nolight)
		H.adjust_nutrition(light_amount * 10)
		if(H.nutrition > NUTRITION_LEVEL_ALMOST_FULL)
			H.set_nutrition(NUTRITION_LEVEL_ALMOST_FULL)
		if(light_amount > 0.2 && !H.suiciding) //if there's enough light, heal
			H.adjustBruteLoss(-1)
			H.adjustFireLoss(-1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.adjustBruteLoss(2)
	..()

/datum/species/golem/wood/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "glyphosate" || R.id == "atrazine")
		H.adjustToxLoss(3) //Deal aditional damage
		return TRUE
	return ..()

//Radioactive
/datum/species/golem/uranium
	name = "Урановый Голем"
	golem_colour = rgb(119, 255, 0)
	skinned_type = /obj/item/stack/ore/uranium
	info_text = "Будучи <span class='danger'>урановым големом</span>, вы излучаете радиацию. Это не вредит другим големам, но влияет на органические формы жизни."
	prefix = "Уранов" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Оксид", "Стержень", "Мужик", "Сплав", "Расплав", "Светоч", "Сиятель", "Свет", "Блеск", "Лучезарец", "Луч", "Блестатель", "Пупс"),
		FEMALE = list("Яркость", "Светлость", "Яркость"),
		NEUTER = list("Сияние", "Светило")
		)
	chance_name_male = 80
	chance_name_female = 40
	chance_name_neuter = 10
	special_name_chance = 60

/datum/species/golem/uranium/handle_life(mob/living/carbon/human/H)
	for(var/mob/living/L in range(2, H))
		if(ishuman(L))
			var/mob/living/carbon/human/I = L
			if(!(RADIMMUNE in I.dna.species.species_traits))
				L.apply_effect(10, IRRADIATE)
				if(prob(25)) //reduce spam
					to_chat(L, "<span class='danger'>Вас окутывает мягкое зелёное свечение, исходящее от [H].</span>")
	..()

//Ventcrawler
/datum/species/golem/plastic
	name = "Пластиковый Голем"
	prefix = "Пластиков" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Стаканчик", "Сервиз"),
		FEMALE = list("Тарелка", "Посуда", "Утварь"),
		NEUTER = null
		)
	ventcrawler = VENTCRAWLER_NUDE
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/sheet/plastic
	info_text = "Будучи <span class='danger'>пластиковым големом</span>, вы способны ползать по вентиляции, если вы раздеты."

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Песчаный Голем"
	golem_colour = rgb(255, 220, 143)
	skinned_type = /obj/item/stack/ore/glass //this is sand
	brute_mod = 0.25
	burn_mod = 3 //melts easily
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Будучи <span class='danger'>песчаным големом</span>, вы невосприимчивы к физическим боеприпасам и получаете очень мало грубого урона. Однако вы чрезвычайно уязвимы к лучам лазерного и энергетического оружия, а также к ожогам. К тому же, вы превратитесь в песок после смерти, что предотвратит любую форму восстановления."
	unarmed_type = /datum/unarmed_attack/golem/sand
	prefix = "Песчан" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Замок", "Берег", "Домик", "Вихрь", "Мужик", "Ураган", "Смерч", "Волчок", "Бархан", "Червь", "Шторм", "Пупс"),
		FEMALE = list("Башня"),
		NEUTER = null
		)
	special_name_chance = 30

/datum/species/golem/sand/handle_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] рассыпал[genderize_ru(H.gender,"ся","ась","ось","ись")] в кучу песка!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == "bullet" || P.flag == "bomb")
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>[P.name] тонет в песчаном теле [H] без видимого вреда здоровью!</span>", \
			"<span class='userdanger'>[P.name] тонет в песчаном теле [H] без видимого вреда здоровью!</span>")
			return FALSE
	return TRUE

/datum/unarmed_attack/golem/sand
	attack_sound = 'sound/effects/shovel_dig.ogg'

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Стеклянный Голем"
	golem_colour = rgb(90, 150, 180)
	skinned_type = /obj/item/shard
	brute_mod = 3 //very fragile
	burn_mod = 0.25
	tox_mod = 1
	clone_mod = 1
	brain_mod = 1
	stamina_mod = 1
	info_text = "Будучи <span class='danger'>стеклянным големом</span>, вы отражаете лучи лазерного и энергетического оружия, а также крайне устойчивы к ожогам. Однако вы чрезвычайно уязвимы к грубому урону и баллистическому оружию. К тому же, после смерти вы разобьётесь без всякой надежды на восстановление."
	unarmed_type = /datum/unarmed_attack/golem/glass
	prefix = "Стеклянн" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = list("Изолятор", "Изолятор Тока", "Преломлятор", "Пупс"),
		FEMALE = list("Линза", "Призма", "Бусинка", "Жемчужина", "Оптика"),
		NEUTER = list("Преломление", "Отражение", "Волокно")
		)
	chance_name_male = 50
	chance_name_female = 50
	chance_name_neuter = 30
	special_name_chance = 50

/datum/species/golem/glass/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] разбил[genderize_ru(H.gender,"ся","ась","ось","ись")] в дребезги!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.is_reflectable)
			H.visible_message("<span class='danger'>[P.name] отражается от стеклянной кожи [H]!</span>", \
			"<span class='userdanger'>[P.name] отражается от стеклянной кожи [H]!</span>")

			P.reflect_back(H)

			return FALSE
	return TRUE

/datum/unarmed_attack/golem/glass
	attack_sound = 'sound/effects/glassbr2.ogg'

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Блюспейс-Голем"
	golem_colour = rgb(51, 51, 255)
	skinned_type = /obj/item/stack/ore/bluespace_crystal
	info_text = "Будучи <span class='danger'>блюспейс-големом</span>, вы пространственно нестабильны: вы будете телепортироваться при получении ударов. Также вы можете телепортироваться вручную на большое расстояние."
	prefix = "Блюспейс"
	prefix_type = 3
	special_names = list(
		MALE = list("Кристалл", "Поликристалл", "Прыгун", "Скакун", "Транзит", "Прыжок", "Скачок", "Разрыв", "Мужик", "Попрыгун", "Пупс"),
		FEMALE = null,
		NEUTER = null
		)
	unarmed_type = /datum/unarmed_attack/golem/bluespace
	special_name_chance = 50
	chance_name_male = 90
	chance_name_female = 20

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0
	var/tele_range = 6

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] телепортировал[genderize_ru(H.gender,"ся","ась","ось","ись")]!</span>", "<span class='danger'>Вы дестабилизируетесь и телепортируетесь!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	return TRUE

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)
	return TRUE

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "blink"
	icon_icon = 'icons/mob/actions/actions.dmi'
	var/activated = FALSE // To prevent spamming
	var/cooldown = 150
	var/last_teleport = 0
	var/tele_range = 6

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown && !activated)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	activated = TRUE
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] начинает вибрировать!</span>", "<span class='danger'>Вы начали заряжать своё блюспейс-ядро…</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/teleport, H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	activated = FALSE
	H.visible_message("<span class='warning'>[H] телепортировал[genderize_ru(H.gender,"ся","ась","ось","ись")]!</span>", "<span class='danger'>Вы телепортировались!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob(H, force = TRUE)
	do_teleport(H, picked)
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	sleep(cooldown + 5)
	UpdateButtonIcon() //action icon looks available again

/datum/unarmed_attack/golem/bluespace
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'

//honk
/datum/species/golem/bananium
	name = "Бананиевый Голем"
	golem_colour = rgb(255, 255, 0)
	punchdamagelow = 0
	punchdamagehigh = 1
	punchstunthreshold = 2 //Harmless and can't stun
	skinned_type = /obj/item/stack/ore/bananium
	info_text = "Будучи <span class='danger'>бананиевым големом</span>, вы созданы для розыгрышей. Ваше тело издает естественные гудки, и удары по людям издают безвредные гудки. Если вас ранить, вы будете бананоточить."
	prefix = "Бананиев" //неполное окончание т.к. гендеризация идет через другую функцию (/datum/species/golem/get_random_name())
	special_names = list(
		MALE = null,
		FEMALE = null,
		NEUTER = null
		)
	unarmed_type = /datum/unarmed_attack/golem/bananium

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/human/H)
	..()
	last_banana = world.time
	last_honk = world.time
	H.mutations.Add(COMIC)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/bikehorn(H), slot_l_store)
	H.AddElement(/datum/element/waddling)

/datum/species/golem/bananium/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.RemoveElement(/datum/element/waddling)

/datum/species/golem/bananium/get_random_name()
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[prefix][genderize_ru(gender_name,"ый","ая","ое","ые")] [clown_name]" //Без перевода, так как требуется переводы имен роли
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time
	return TRUE

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/handle_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/handle_death(gibbed, mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/unarmed_attack/golem/bananium
	attack_verb = list("HONK")
	attack_sound = 'sound/items/airhorn2.ogg'
	animation_type = ATTACK_EFFECT_DISARM
	harmless = TRUE

//...
/datum/species/golem/tranquillite
	name = "Транквилитовый Голем"
	prefix = "Транквилитов" //требуется перевод имен Мима
	special_names = list(
		MALE = null,
		FEMALE = null,
		NEUTER = null
		)
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/tranquillite
	info_text = "Будучи <span class='danger'>транквилитовым големом</span>, вы можете создавать невидимые стены и регенерировать, выпивая бутылки с ничем."
	unarmed_type = /datum/unarmed_attack/golem/tranquillite

/datum/species/golem/tranquillite/get_random_name()
	var/mime_name = pick(GLOB.mime_names)
	var/golem_name = "[prefix][genderize_ru(gender_name,"ый","ая","ое","ые")] [mime_name]" //Без перевода, так как требуется переводы имен роли
	return golem_name

/datum/species/golem/tranquillite/on_species_gain(mob/living/carbon/human/H)
	..()
	H.equip_to_slot_or_del(new 	/obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_del(new 	/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_r_store)
	H.equip_to_slot_or_del(new 	/obj/item/cane(H), slot_l_hand)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = TRUE

/datum/unarmed_attack/golem/tranquillite
	attack_sound = null


//FOR RATVAR!!!!!
/datum/species/golem/clockwork
	name = "Латунный Голем"
	prefix = "Латунн"
	special_names = null
	golem_colour = rgb(176, 136, 32)
	skinned_type = /obj/item/stack/sheet/brass
	info_text = "Будучи <span class='danger'>латунный големом</span>, вы очень хрупкие, но взамен имеете силу Ратвара."
	special_names = list(
        MALE = list("Сплав", "Брусок", "Кусок", "Мужик", "Кирпич", "Минерал", "Буреходец", "Пожарник", "Лавоходец", "Лавоплавунец", "Тяжеступ", "Работяга", "Тяжеловес", "Увалень", "Бугай", "Пупс"),
        FEMALE = list("Дева"),
        NEUTER = null
        )
	chance_name_male = 70
	chance_name_female = 60
	chance_name_neuter = 10
	special_name_chance = 40

/datum/species/golem/clockwork/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	if(!isclocker(H))
		SSticker.mode.add_clocker(H.mind)

/datum/species/golem/clockwork/handle_death(gibbed, mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] crumbles into cogs and gears! Then leftovers suddenly dusts!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	new /obj/item/clockwork/clockgolem_remains(get_turf(H))
	H.dust() // One-try only
