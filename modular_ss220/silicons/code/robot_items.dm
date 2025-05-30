/* Engineer */
// Небольшой багфикс "непрозрачного открытого шлюза"
/obj/structure/inflatable/door/operate()
	. = ..()
	opacity = FALSE

// Голопроектор и улучшенные варианты //
/obj/item/holosign_creator/atmos/robot
	name = "Модульный ATMOS голопроектор"
	desc = "Стандартный модуль ATMOS голопроектора, предназначенный для использования инженерными киборгами. Создаваемые голопроекции полностью блокируют перемещение газов.\
		<br>Количество создаваемых голопроекций снижено относительно немодульного аналога в целях снижения энергопотребления."
	max_signs = 1

/obj/item/holosign_creator/atmos/robot/better
	name = "Улучшенный модульный ATMOS голопроектор"
	desc = "Улучшенный модуль ATMOS голопроектора, предназначенный для использования инженерными киборгами.\
		<br>Количество создаваемых голопроекций увеличено до 3 за счёт применения улучшенных материалов."
	icon = 'modular_ss220/silicons/icons/robot_tools.dmi'
	icon_state = "atmos_holofan_better"
	max_signs = 3

/obj/item/holosign_creator/atmos/robot/best
	name = "Продвинутый модульный ATMOS голопроектор"
	desc = "Продвинутый модуль ATMOS голопроектора, предназначенный для использования инженерными киборгами.\
		<br>Количество создаваемых голопроекций увеличено до 5 за счёт точечной оптимизации микросхем и применения редких материалов."
	icon = 'modular_ss220/silicons/icons/robot_tools.dmi'
	icon_state = "atmos_holofan_best"
	max_signs = 5

/* Medical */
/obj/item/reagent_containers/borghypo/basic
	name = "Basic Cyborg Hypospray"
	desc = "A very basic cyborg hypospray, capable of providing simple medical treatment in emergencies."
	reagent_ids = list("salglu_solution", "epinephrine", "charcoal", "sal_acid")
	volume = 30

/obj/item/reagent_containers/borghypo
	name = "Upgraded Cyborg Hypospray"
	desc = "Upgraded cyborg hypospray, capable of providing standart medical treatment."
	volume = 60

/* Service */
/obj/item/rsf/attack_self__legacy__attackchain(mob/user)
	if(..() && power_mode >= 3000)
		power_mode /= 2

/obj/item/eftpos/cyborg
	name = "Silicon EFTPOS"
	desc = "Проведите ID картой для оплаты налогов."
	transaction_purpose = "Оплата счета от робота."

/obj/item/eftpos/cyborg/Initialize(mapload)
	. = ..()
	transaction_purpose = "Оплата счета от [usr.name]."

/obj/item/eftpos/ui_act(action, list/params, datum/tgui/ui)
	var/mob/living/user = ui.user

	switch(action)
		if("toggle_lock")
			if(transaction_locked)
				if(!check_user_position(user))
					return
				transaction_locked = FALSE
				transaction_paid = FALSE
			else if(linked_account)
				transaction_locked = TRUE
			else
				to_chat(user, span_warning("[bicon(src)]No account connected to send transactions to.<"))
			return TRUE
	. = ..()
