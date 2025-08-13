// "Микро-компонент" модульности ради...? Возможно, и, скорее всего, плохая идея.
// Не использовал squeak.dm ибо у squeak есть регистрация COMSIG_ACTIVATE_SELF, который мешает использовать attack_self() с проверкой интентов
/datum/component/plushtoy/Initialize()
	. = ..()
	// Пищит при ударах
	RegisterSignal(parent, list(COMSIG_ATOM_HULK_ATTACK, COMSIG_ATTACK_BY, COMSIG_MOVABLE_BUMP, COMSIG_ATTACK, COMSIG_ATTACK_OBJ), PROC_REF(play_squeak))

	// Пищит при наступании
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(play_squeak_crossed),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)

// Пищание
/datum/component/plushtoy/proc/play_squeak()
	playsound(parent, 'sound/items/squeaktoy.ogg', 50, TRUE, -10)

// Стащенный кусок кода для фикса большого числа писков в зависимости от числа хамптеров в инвентаре
/datum/component/plushtoy/proc/play_squeak_crossed(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.flags & ABSTRACT)
			return
		else if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			if(P.original != parent)
				return
	if(ismob(AM))
		var/mob/M = AM
		if(HAS_TRAIT(M, TRAIT_FLYING))
			return
		if(isliving(AM))
			var/mob/living/L = M
			if(L.floating)
				return
	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()

// Спавнер рандомного хамптера для карты
/obj/effect/spawner/random/toy/hampter
	name = "random hampter toy"
	icon = 'modular_ss220/objects/icons/plushies.dmi'
	icon_state = "hampter"
	loot_type_path = /obj/item/toy/hampter

// Хамптер
/obj/item/toy/hampter
	name = "хамптер"
	desc = "Просто плюшевый хамптер. Самый обычный."
	icon = 'modular_ss220/objects/icons/plushies.dmi'
	icon_state = "hampter"
	icon_override = 'modular_ss220/objects/icons/inhead/head.dmi'
	lefthand_file = 'modular_ss220/objects/icons/inhands/plushies_lefthand.dmi'
	righthand_file = 'modular_ss220/objects/icons/inhands/plushies_righthand.dmi'
	slot_flags = ITEM_SLOT_HEAD
	w_class = WEIGHT_CLASS_TINY
	blood_color = "#d42929"
	var/squeak = 'sound/items/squeaktoy.ogg'
	var/cooldown = 0

// Добавляем наш "микро-компонент" хамптеру
/obj/item/toy/hampter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plushtoy)

// Действия при взаимодействии в руке при разных интентах
/obj/item/toy/hampter/activate_self(mob/user)
	. = ..()
	if(. || cooldown >= world.time - 1 SECONDS)
		return
	switch(user.a_intent)
		// Если выбрано что угодно кроме харма - жмякаем с писком хамптера
		if(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
			playsound(get_turf(src), squeak, 50, 1, -10)

		// Если выбран харм, сжимаем хамптера до "краски" (?) в его туловище
		if(INTENT_HARM)
			if(istype(user, /mob/living/carbon/human))
				var/mob/living/carbon/human/human = user

				// Прописываю это здесь ибо иначе хомяки будут отмечаться кровавыми в игре
				blood_DNA = "Plush hampter's paint"
				human.visible_message(
					span_warning("[human] раздавил хамптера в своей руке!"),
					span_warning("Вы раздавили хамптера в своей руке!"))
				playsound(get_turf(src), "bonebreak", 50, TRUE, -10)
				human.hand_blood_color = blood_color
				human.transfer_blood_dna(blood_DNA)

				// Сколько бы я не хотел ставить 0 - не выйдет. Нельзя будет отмыть руки в раковине
				human.bloody_hands = 1
				human.update_inv_gloves()
				qdel(src)
	cooldown = world.time

// Подвиды
/obj/item/toy/hampter/assistant
	name = "хамптер ассистент"
	desc = "Плюшевый хамптер ассистент. Зачем ему изольки?"
	icon_state = "hampter_ass"

/obj/item/toy/hampter/security
	name = "хамптер офицер"
	desc = "Плюшевый хамптер офицер службы безопасности. У него станбатон!"
	icon_state = "hampter_sec"

/obj/item/toy/hampter/medical
	name = "хамптер врач"
	desc = "Плюшевый хамптер врач. Тащите дефибриллятор!"
	icon_state = "hampter_med"

/obj/item/toy/hampter/janitor
	name = "хамптер уборщик"
	desc = "Плюшевый хамптер уборщик. Переключись на шаг."
	icon_state = "hampter_jan"

/obj/item/toy/hampter/old_captain
	name = "хамптер старый капитан"
	desc = "ПЛюшевый хамптер капитан в старой униформе. Это какой год?"
	icon_state = "hampter_old-cap"

/obj/item/toy/hampter/captain
	name = "хамптер капитан"
	desc = "Плюшевый хамптер капитан. Где его запасная карта?"
	icon_state = "hampter_cap"

/obj/item/toy/hampter/syndicate
	name = "хамптер Синдиката"
	desc = "Плюшевый хамптер агент Синдиката. Ваши активы пострадают."
	icon_state = "hampter_sdy"

/obj/item/toy/hampter/deadsquad
	name = "хамптер Дедсквада"
	desc = "Плюшевый хамптер Отряда Смерти. Все контракты расторгнуты."
	icon_state = "hampter_ded"

/obj/item/toy/hampter/ert
	name = "хамптер ОБР"
	desc = "Плюшевый хамптер ОБР. Доложите о ситуации на станции."
	icon_state = "hampter_ert"
