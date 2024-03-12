/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/paintkit))
		return ..()
	if(occupant)
		to_chat(user, span_warning("Вы не можете кастомизировать экзокостюм, пока кто-то его пилотирует - это небезопасно!"))
		return

	var/obj/item/paintkit/P = W
	var/found = null

	for(var/type in P.allowed_types)
		if(type == initial_icon)
			found = 1
			break

	if(!found)
		to_chat(user, span_warning("Этот комплект не предназначен для использования на экзокостюме данного класса."))
		return

	user.visible_message(span_notice("[user] открывает [P] и проводит некоторое время за кастомизацией [src]."), span_notice("Вы открываете [P] и начинаете кастомизировать [src]."))
	if(!do_after_once(user, 3 SECONDS, target = src))
		to_chat(user, span_warning("Вы должны стоять смирно при настройке экзокостюма!"))
		return
	name = P.new_name
	desc = P.new_desc
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	initial_icon = P.new_icon
	wreckage = P.new_wreckage
	reset_icon()
	qdel(P)

/obj/mecha/go_out(forced, atom/newloc = loc)
	. = ..()
	icon_state = reset_icon(icon_state)+"-open"

// RIP AND PEPPERONI

/obj/structure/mecha_wreckage/ripley/titan
	name = "\improper Обломки \"Кулака Титана\""
	desc = "А что вы ожидали от реплики?"
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "titan-broken"

/obj/structure/mecha_wreckage/ripley/gurren
	name = "\improper Обломки \"Strike The Earth!\""
	desc = "Настоящий мех не умрет, даже если его разрушить. Не должно мужчине ходить повесив голову, Симон!"
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "earth-broken"

/obj/structure/mecha_wreckage/ripley/red
	name = "\improper Обломки \"Поджигателя\""
	desc = "А горит то как..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "ripley_flames_red-broken"

/obj/structure/mecha_wreckage/ripley/hauler
	name = "\improper Обломки \"Тягача\""
	desc = "Этот мех отработал своё..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "hauler-broken"

/obj/structure/mecha_wreckage/ripley/zairjah
	name = "\improper Обломки \"Зари\""
	desc = "Впрочем, никакая модификация не спасет вас от реальности."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "ripley_zairjah-broken"

/obj/structure/mecha_wreckage/ripley/combat
	name = "\improper Обломки боевого Рипли"
	desc = "Надо было ставить больше ракет..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "combatripley-broken"

/obj/structure/mecha_wreckage/ripley/aluminizer
	name = "\improper Обломки \"Алюминатора\""
	desc = "Слишком выделялся..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "aluminizer-broken"

/obj/structure/mecha_wreckage/ripley/reaper
	name = "\improper Обломки \"Жнеца\""
	desc = "От греха подальше эти обломки лучше еще и взорвать..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "deathripley-broken"

// ODYSSEUS`S ASS

/obj/structure/mecha_wreckage/odysseus/hermes
	name = "\improper Обломки \"Гермеса\""
	desc = "Рождённый плавать бегать не умеет.."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "hermes-broken"

/obj/structure/mecha_wreckage/odysseus/reaper
	name = "\improper Обломки \"Жнеца\""
	desc = ".. а пыль развеять по ветру."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "murdysseus-broken"

// GYGAXCHAD

/obj/structure/mecha_wreckage/gygax/medigax
	name = "\improper Обломки \"Медигакса\""
	desc = "Шприц был не лучшим оружием на перестрелке."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "medigax-broken"

/obj/structure/mecha_wreckage/gygax/old
	name = "\improper Обломки старого Гигакса"
	desc = "Удивительно, как он не развалился раньше."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "gygax_alt-broken"

/obj/structure/mecha_wreckage/gygax/pobeda
	name = "\improper Обломки \"Победы\""
	desc = "Не выдержал проверку временем.."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "pobeda-broken"

/obj/structure/mecha_wreckage/gygax/whitegax
	name = "\improper Обломки белого Гигакса"
	desc = "Краска не повреждена. Забавно."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "whitegax-broken"

/obj/structure/mecha_wreckage/gygax/mimegax
	name = "\improper Обломки \"Молчигакса\""
	desc = "..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "mimegax-broken"

/obj/structure/mecha_wreckage/gygax/gygax_black
	name = "\improper Обломки черного Гигакса"
	desc = "Логотип Синдиката все ещё на месте. Хм..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "gygax_black-broken"

// DURAND

/obj/structure/mecha_wreckage/durand/dollhouse
	name = "\improper Обломки \"Кукольного домика\""
	desc = "Теперь больше похож на дырявый сарай.."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "dollhouse-broken"

/obj/structure/mecha_wreckage/durand/unathi
	name = "\improper Обломки \"Кхарн MK. IV\""
	desc = "Душу за Императницу!"
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "unathi-broken"

/obj/structure/mecha_wreckage/durand/shire
	name = "\improper Обломки \"Шир\""
	desc = "Это всего лишь тестовый образец.."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "shire-broken"

/obj/structure/mecha_wreckage/durand/skull
	name = "\improper Обломки \"Скелемеха\""
	desc = "Ужасающие останки нечто, похожего на одного из боссов Лаваленда..."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "skullmech-broken"

// USELESS SHIT

/obj/structure/mecha_wreckage/phazon/imperion
	name = "\improper Обломки \"Империона\""
	desc = "Великая трагедия \"Нанотрейзен\", которая не останется незамеченной."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "imperion-broken"

/obj/structure/mecha_wreckage/phazon/janus
	name = "\improper Обломки \"Януса\""
	desc = "Великая трагедия \"Нанотрейзен\", которая не останется незамеченной." //да у них одинаковое описание
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "janus-broken"

/obj/structure/mecha_wreckage/phazon/plazmus
	name = "\improper Обломки \"Плазмуса\""
	desc = "Как жаль что даже этого не хватило."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "plazmus-broken"

/obj/structure/mecha_wreckage/phazon/phazon_blanco
	name = "\improper Обломки \"Бланко\""
	desc = "Обломки полугода работы бедного художника и трех лет одобрения этого дизайна. Издевательство.."
	icon = 'modular_ss220/mecha_skins/icons/mecha.dmi'
	icon_state = "phazon_blanco-broken"

