#define LEGENDARY_SWORDS_CKEY_WHITELIST list("mooniverse")

/obj/item/melee/rapier/cane_rapier
	name = "Трость-рапира"
	desc = "Стилизованная под трость рапира, чье элегантное и обоюдоострое лезвие усажено на роскошно украшенную рукоять. Одни лишь инкрустированные в неё драгоценные камни стоят как целая звездная система."
	icon = 'modular_ss220/prime_only/icons/saber.dmi'
	icon_state = "trrapier"
	item_state = "trrapier"
	force = 25
	lefthand_file = 'modular_ss220/prime_only/icons/saber_left.dmi'
	righthand_file = 'modular_ss220/prime_only/icons/saber_right.dmi'

/obj/item/storage/belt/rapier/cane_rapier
	name = "Трость-рапира"
	desc = "Ножны стилизованной под трость рапиры. Их корпус вырезан из черного дерева и щедро украшен позолотой. Их владелец обладает неоспоримый богатством и властью в известной Галактике."
	icon_state = "trsheath"
	item_state = "trsheath"
	icon = 'modular_ss220/prime_only/icons/saber.dmi'
	lefthand_file = 'modular_ss220/prime_only/icons/saber_left.dmi'
	righthand_file = 'modular_ss220/prime_only/icons/saber_right.dmi'
	can_hold = list(/obj/item/melee/rapier/cane_rapier)

/obj/item/storage/belt/rapier/cane_rapier/populate_contents()
	new /obj/item/melee/rapier/cane_rapier(src)
	update_icon()

/obj/item/dualsaber/legendary_saber
	name = "Злоба"
	desc = "\"Злоба\" - один из легендарных энергетических мечей Галактики. Словно источая мистическую энергию, \"Злоба\" является олицетворением самой Тьмы, вызывающей трепет и ужас врагов её владельца. Гладкая и простая рукоять меча не может похвастаться орнаментами, узорами или древними рунами, но способна выплескивать рванный энергетический клинок кроваво-красного света, словно кричащий о непокорности и ярости своего владельца.  Некоторые истории гласят, что в этом клинке прибывает сама темная сущность могущества и бесконечного гнева, готовая исполнить волю своего хозяина даже за пределами пространства и времени. \n Создатель: Согда К'Трим. Текущий владелец: Миднайт Блэк."
	icon = 'modular_ss220/prime_only/icons/saber.dmi'
	lefthand_file = 'modular_ss220/prime_only/icons/saber_left.dmi'
	righthand_file = 'modular_ss220/prime_only/icons/saber_right.dmi'
	icon_state = "mid_dualsaber0"
	blade_color = "midnight"
	colormap = LIGHT_COLOR_RED
	wieldsound = 'modular_ss220/prime_only/sound/weapons/mid_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/mid_saberoff.ogg'
	var/saber_name = "mid"
	var/hit_wield = 'modular_ss220/prime_only/sound/weapons/mid_saberhit.ogg'
	var/hit_unwield = "swing_hit"
	var/ranged = FALSE
	var/power = 1
	var/refusal_text = "Злоба неподвластна твоей воле, усмрить её сможет лишь сильнейший."
	var/datum/enchantment/enchant = new/datum/enchantment/dash

/obj/item/dualsaber/legendary_saber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ckey_and_role_locked_pickup, TRUE, LEGENDARY_SWORDS_CKEY_WHITELIST, pickup_damage = 10, refusal_text = refusal_text)

/obj/item/dualsaber/legendary_saber/update_icon_state()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		icon_state = "[saber_name]_dualsaber[blade_color]1"
		set_light(brightness_on, l_color=colormap)
	else
		icon_state = "[saber_name]_dualsaber0"
		set_light(0)

/obj/item/dualsaber/legendary_saber/on_wield(obj/item/source, mob/living/carbon/user)
	if(user && HAS_TRAIT(user, TRAIT_HULK))
		to_chat(user, "<span class='warning'>You lack the grace to wield this!</span>")
		return COMPONENT_TWOHANDED_BLOCK_WIELD

	hitsound = hit_wield
	w_class = w_class_on

/obj/item/dualsaber/legendary_saber/on_unwield()
	hitsound = hit_unwield
	w_class = initial(w_class)

/obj/item/dualsaber/legendary_saber/sorrow_catcher
	name = "Ловец Скорби"
	desc = "\"Ловец  Скорби\"  (Второе название \"Плакса\") -  один из легендарных энергетических мечей Галактики. Он символизирует не только силу власти и могущества, но и является предметом гордости своего обладателя.  Искусно выполненный клинок излучает мягкий голубой свет, словно призывая к миру и согласию, но при этом скрывает в себе силу и решимость защитить своего хозяина любой ценой. Рукоять меча сконструирована строго и со вкусом, создана из темного металла с матовым покрытием и украшена фреской логотипа NT. \"Ловец  Скорби\" имеет специфический звук, отдалённо напоминающий женский плач. Поэтому, немногие очевидцы гнева его хозяина дали мечу второе название - \"Плакса.\" \n Создатель: Гаскон-Валлен-Деламот. Текущий владелец: Билл Громов."
	icon_state = "gr_dualsaber0"
	blade_color = "gromov"
	refusal_text = "Ну, заплачь."
	colormap = LIGHT_COLOR_LIGHT_CYAN
	saber_name = "gr"
	wieldsound = 'modular_ss220/prime_only/sound/weapons/gr_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/gr_saberoff.ogg'
	hit_wield = 'modular_ss220/prime_only/sound/weapons/gr_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flame
	name = "Пламя"
	desc = "\"Пламя\" - один из легендарных энергетических мечей Галактики. Он отражает неумолимую справедливость и рьяность характера своего хозяина. В противоречие грозному названию, эфес меча представляет собой аккуратное и \"нежное\" произведение искусства - отполированная нарезная титановая основа завершается золотым навершием, а декоративная гарда выполнен в виде раскрывшегося бутона. Энергетический клинок источает яркий фиолетовый свет, несущий очищение и упокоение своим врагам. Рукоять меча крайне хорошо сбалансирована и отдает дань аристократическим традициям человеческого прошлого. \n Создатель: Гаскон-Валлен-Деламот. Текущий владелец: Шарлотта Дитерхис."
	icon_state = "sh_dualsaber0"
	blade_color = "sharlotta"
	refusal_text = "Кровь и свет принадлежат лишь одному."
	colormap = LIGHT_COLOR_LAVENDER
	saber_name = "sh"
	wieldsound = 'modular_ss220/prime_only/sound/weapons/sh_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/sh_saberoff.ogg'
	hit_wield = 'modular_ss220/prime_only/sound/weapons/sh_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/devotion
	name = "Верность клятве"
	desc = "\"Верность Клятве\" - один из легендарных энергетических мечей Галактики. Этот меч в первую очередь является сакральным символом, связывающий своего владельца вечной Клятвой. Его украшенную древними иероглифами человеческой расы рукоять покрывает хромированный сатин, а двойное изумрудно-зелёное лезвие меча требует от своего хозяина виртуозности и мастерства в обращении, в то же время являясь испытанием доблести, чести и силы духа. Одна из историй этого артефакта гласит, что в свечении клинка отражается душа его создателя - Арканона, который проводил долгие годы в изоляции в попытках создать что-то большее, чем просто оружие.  \n Создатель: Арканон.  Текущий владелец: Хель Кириэн."
	icon_state = "kir_dualsaber0"
	blade_color = "kirien"
	refusal_text = "Только достойный узрит свет."
	colormap = LIGHT_COLOR_PURE_GREEN
	saber_name = "kir"
	wieldsound = 'modular_ss220/prime_only/sound/weapons/kir_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/kir_saberoff.ogg'
	hit_wield = 'modular_ss220/prime_only/sound/weapons/kir_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/sister
	name = "Сестра"
	desc = "\"Сестра\" - один из легендарных энергетических мечей Галактики. Являясь \"старшей\" парной частью еще одного легендарного меча - \"Ловца Бегущих\", это оружие представляет собой удивительный артефакт с глубокой историей и мистическими свойствами.  Его лезвие излучает мягкий  золотой свет, который извечно является символом мудрости и мощи. \"Сестра\" - это не просто меч, а символ верности высшим идеалам, дающий своему хозяину силу и решимость. Форма рукояти отсылает к оружию Справедливых Рыцарей древней человеческой истории и обладает строгим стилем, дополняющим своего владельца. Всю свою историю этот меч являлся желанным объектом многих великих существ, но \"Сестра\" способна поистине раскрыться лишь в руках того, кто искренне верит в силу справедливости и не понаслышке знает что такое честь и доблесть. \n Создатель: Коникс`Хеллькикс. Текущий Владелец: Мунивёрс Нормандия."
	icon_state = "norm_dualsaber0"
	blade_color = "normandy"
	refusal_text = "Ты не принадлежишь сестре, верни её законному владельцу."
	colormap = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "norm"
	wieldsound = 'modular_ss220/prime_only/sound/weapons/norm_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/norm_saberoff.ogg'
	hit_wield = 'modular_ss220/prime_only/sound/weapons/norm_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/flee_catcher
	name = "Ловец Бегущих"
	desc = "\"Ловец Бегущих\" - один из легендарных энергетических мечей Галактики. Являясь \"младшей\" парной частью еще одного легендарного меча - \"Сестры\", это оружие представляет собой более грубое и практичное творение. Корпус рукояти, изобилующий царапинами и потёртостями, говорит о тяжелой истории меча. Одной из традиций владельцев этого оружия является рисование под кнопкой включения отметок в виде белых жетонов, коих уже насчитывается семь штук. Рядом с самым первым жетоном выгравирована надпись : \"2361. А.М.\" \n Цвет клинка ярко-желтый,  его рукоять удлинена для комфортного боя как одной, так и двумя руками, навершие Типа \"P\" покрыто золотом и обладает специальным разъёмом для подключения своей старшей \"Сестры\", а гарда представляет собой два закругленных декоративных отростка. Из старых легенд известно, что строптивый и бурный характер меча могли сдержать лишь настоящие мастера, которые использовали хаотичный, но адаптивный под врага стиль боя. \n Создатель: Коникс`Хеллькикс. Текущий Владелец: Мунивёрс Нормандия, в последствии был передан Рицу Келли."
	icon_state = "kel_dualsaber0"
	blade_color = "kelly"
	refusal_text = "Ловец бегущих не слушается тебя, кажется он хочет вернуться к хозяину."
	colormap = LIGHT_COLOR_HOLY_MAGIC
	saber_name = "kel"
	wieldsound = 'modular_ss220/prime_only/sound/weapons/kel_saberon.ogg'
	unwieldsound = 'modular_ss220/prime_only/sound/weapons/kel_saberoff.ogg'
	hit_wield = 'modular_ss220/prime_only/sound/weapons/kel_saberhit.ogg'

/obj/item/dualsaber/legendary_saber/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	enchant?.on_legendary_hit(target, user, proximity_flag, src)

/obj/item/dualsaber/legendary_saber/proc/add_enchantment(new_enchant, mob/living/user, intentional = TRUE)
	var/datum/enchantment/E = new new_enchant
	enchant = E
	E.on_gain(src, user)
	E.power *= power
	if(intentional)
		SSblackbox.record_feedback("nested tally", "saber_enchants", 1, list("[E.name]"))

/datum/enchantment/dash/proc/charge(mob/living/user, atom/chargeat, obj/item/dualsaber/legendary_saber/S)
	if(on_leap_cooldown)
		return
	if(!chargeat)
		return
	var/turf/destination_turf  = get_turf(chargeat)

	if(!destination_turf)
		return
	var/list/targets = list()
	for(var/atom/target in destination_turf.contents)
		targets += target
	charging = TRUE

	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(user.loc, user)
	animate(D, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)

	var/i
	for(i=0, i<5, i++)
		spawn(i * 9 MILLISECONDS)
			step_to(user, destination_turf , 1, movespeed)
			var/obj/effect/temp_visual/decoy/D2 = new /obj/effect/temp_visual/decoy(user.loc, user)
			animate(D2, alpha = 0, color = "#271e77", transform = matrix()*1, time = anim_time, loop = anim_loop)

	spawn(45 MILLISECONDS)
		if(get_dist(user, destination_turf) > 1)
			return
		charge_end(targets, user, S)

/datum/enchantment/dash/proc/charge_end(list/targets = list(), mob/living/user, obj/item/dualsaber/legendary_saber/S)
	charging = FALSE

	for(var/mob/living/L in targets)
		if(!(L == user))
			user.apply_damage(-40, STAMINA)
			S.melee_attack_chain(user, L)

/datum/enchantment/dash
	name = "Рывок"
	desc = "Этот клинок несёт владельца прямо к цели. Никто не уйдёт."
	ranged = TRUE
	var/movespeed = 0.8
	var/on_leap_cooldown = FALSE
	var/charging = FALSE
	var/anim_time = 3 DECISECONDS
	var/anim_loop = 3 DECISECONDS

/datum/enchantment/proc/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(world.time < cooldown)
		return FALSE
	if(!istype(target))
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!ranged && !proximity)
		return FALSE
	cooldown = world.time + initial(cooldown)
	return TRUE

/datum/enchantment/dash/on_legendary_hit(mob/living/target, mob/living/user, proximity, obj/item/dualsaber/legendary_saber/S)
	if(proximity) // don't put it on cooldown if adjacent
		return
	. = ..()
	if(!.)
		return

	if(HAS_TRAIT(S, TRAIT_WIELDED))
		charge(user, target, S)
