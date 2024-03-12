// Please don't use this for anything, it's a base type for custom mech paintjobs.
/obj/item/paintkit
	name = "Набор кастомизации меха"
	desc = "Дефолтный набор кастомизации, превращающий мех в другой мех(визуально)."
	icon = 'modular_ss220/mecha_skins/icons/paintkit.dmi'
	icon_state = "paintkit"
	// New type of wreckage
	var/new_wreckage = null

// RIPLEY

/obj/item/paintkit/ripley_titansfist
	name = "Набор кастомизации АЭП \"Кулак Титана\""
	icon_state = "paintkit_titan"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в \"Кулак Титана\""

	new_name = "АЭП \"Кулак Титана\""
	new_desc = "Этот обычный шахтерский Рипли был переделан так, чтобы выглядеть как боевая единица Кулака Титанов."
	new_icon = "titan"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/titan

/obj/item/paintkit/ripley_gurren
	name = "Набор кастомизации АЭП \"Strike the Earth!\""
	icon_state = "paintkit_earth"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в старый АЭП боевика."

	new_name = "АЭП \"Strike the Earth!\""
	new_desc = "Выглядит как сильно поврежденный от бесконечной работы Рипли. Вам померещилось, или в кабине горят зеленые огни?..."
	new_icon = "earth"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/gurren

/obj/item/paintkit/ripley_red
	name = "Набор кастомизации АЭП \"Поджигатель\""
	icon_state = "paintkit_red"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в АЭП \"Поджигатель\"."

	new_name = "АЭП \"Поджигатель\""
	new_desc = "Стандарный АЭП с стильными огненными декалями."
	new_icon = "ripley_flames_red"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/red

/obj/item/paintkit/firefighter_Hauler
	name = "Набор кастомизации АЭП \"Тягач\""
	icon_state = "paintkit_hauler"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в старый инженерный экзокостюм."

	new_name = "АЭП \"Тягач\""
	new_desc = "Старый инженерный экзокостюм. Для любителей классики."
	new_icon = "hauler"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/hauler

/obj/item/paintkit/firefighter_zairjah
	name = "Набор кастомизации АЭП \"Заря\""
	icon_state = "paintkit_zairjah"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в странно выглядящий экзокостюм."

	new_name = "АЭП \"Заря\""
	new_desc = "Шахтерская машина индивидуальной разработки, закрытая кабина с придаточными устройствами."
	new_icon = "ripley_zairjah"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/zairjah

/obj/item/paintkit/firefighter_combat
	name = "Набор кастомизации АЭП \"Боевой Рипли\""
	icon_state = "paintkit_combat"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в настоящий боевой экзокостюм. Оружие в комплект не входит!"

	new_name = "АЭП \"Combat Ripley\""
	new_desc = "Погоди-ка, почему от этого меха исходят горящие искры?"
	new_icon = "combatripley"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/combat

/obj/item/paintkit/firefighter_aluminizer
	name = "Набор кастомизации АЭП \"Алюминатор\""
	icon_state = "paintkit"
	desc = "Набор, содержащий белую краску для Рипли."

	new_name = "АЭП \"Алюминатор\""
	new_desc = "Вы только что покрасили свой Рипли в белый цвет? Выглядит хорошо."
	new_icon = "aluminizer"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/aluminizer

/obj/item/paintkit/firefighter_Reaper
	name = "Набор кастомизации АЭП \"Жнец\""
	icon_state = "paintkit_death"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Рипли в знаменитого меха из мегапопулярного аниме \"Отряд Смерти\"!"

	new_name = "АЭП \"Жнец\""
	new_desc = "ОХ БЛЯТЬ, ЭТО ОНИ, МЫ ВСЕ УМР- а, это просто перекрашенный Рипли."
	new_icon = "deathripley"
	allowed_types = list("ripley", "firefighter")
	new_wreckage = /obj/structure/mecha_wreckage/ripley/reaper

// ODYSSEUS

/obj/item/paintkit/odysseus_hermes
	name = "Набор кастомизации Одиссея \"Гермес\""
	icon_state = "paintkit_hermes"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Одиссея в инопланетный водолазный экзокостюм."

	new_name = "Гермес"
	new_desc = "Водолазный экзокостюм, разработанный и выпускаемый для проведения узкоспециализированных подводных операций. Как он здесь оказался?"
	new_icon = "hermes"
	allowed_types = list("odysseus")
	new_wreckage = /obj/structure/mecha_wreckage/odysseus/hermes

/obj/item/paintkit/odysseus_death
	name = "Набор кастомизации Одиссея \"Жнец\""
	icon_state = "paintkit_death"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Одиссея в ужасающий мех."

	new_name = "Жнец"
	new_desc = "ОХ БЛЯТЬ, МЫ ВСЕ... получим плохое лечение?"
	new_icon = "murdysseus"
	allowed_types = list("odysseus")
	new_wreckage = /obj/structure/mecha_wreckage/odysseus/reaper

// GYGAXCHAD

/obj/item/paintkit/gygax_alt
	name = "Набор кастомизации старого Гигакса"
	icon_state = "paintkit_alt"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Гигакса в устаревшую версию самого себя. Зачем вам это нужно?"

	new_name = "старый Гигакс"
	new_desc = "Устаревший защитный экзокостюм. Найти сохранившийся экзокостюм этой модели - настоящее достижение."
	new_icon = "gygax_alt"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/old

/obj/item/paintkit/gygax_pobeda
	name = "Набор кастомизации Гигакса \"Победа\""
	icon_state = "paintkit_pobeda"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Гигакса в советский экзокостюм."

	new_name = "Победа"
	new_desc = "Сверхмощный старый Гигакс, раскрашенный в СССП стилистике. Слава космической России!"
	new_icon = "pobeda"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/pobeda

/obj/item/paintkit/gygax_white
	name = "Набор кастомизации белого Гигакса"
	icon_state = "paintkit_white"
	desc = "Набор с белой краской для Гигакса."

	new_name = "белый Гигакс"
	new_desc = "Ты только что покрасил свой Гигакс в белый? Мне нравится."
	new_icon = "whitegax"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/whitegax

/obj/item/paintkit/gygax_medgax
	name = "Набор кастомизации Гигакса \"Медигакс\""
	icon_state = "paintkit_white"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Гигакс в старый \"медицинский\" мех."

	new_name = "Медигакс"
	new_desc = "ОХ БЛЯТЬ, В БОЛЬНИЦЕ МЕДИЦИНСКИЙ МЕХ, ОН НАС ВСЕХ УБЬЕТ!!!"
	new_icon = "medigax"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/medigax

/obj/item/paintkit/gygax_mime
	name = "Набор кастомизации Гигакса \"Молчигакс\""
	icon_state = "paintkit_white"
	desc = "Набор кастомизации Гигакса, присланный с любовью от мимов-ассасинов. Глушитель в комплект не входит."

	new_name = "Молчигакс"
	new_desc = "...!"
	new_icon = "mimegax"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/mimegax

/obj/item/paintkit/gygax_syndie
	name = "Набор кастомизации черного Гигакса"
	icon_state = "paintkit_Black"
	desc = "Очень подозрительный набор, содержащий все необходимые инструменты и детали для превращения Гигакса в печально известный черный Гигакс."

	new_name = "черный Гигакс"
	new_desc = "Почему на этой штуке есть логотип Синдиката? Погодите-ка..."
	new_icon = "gygax_black"
	allowed_types = list("gygax")
	new_wreckage = /obj/structure/mecha_wreckage/gygax/gygax_black

// DURAND

/obj/item/paintkit/durand_soviet
	name = "Набор кастомизации Дюранда \"Кукольный домик\""
	icon_state = "paintkit_doll"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Дюранда в советский мех. Слава космической России!"

	new_name = "Кукольный домик"
	new_desc = "Сверхмощный боевой мех, разработанный в СССП. Слава космической России!"
	new_icon = "dollhouse"
	allowed_types = list("durand")
	new_wreckage = /obj/structure/mecha_wreckage/durand/dollhouse

/obj/item/paintkit/durand_unathi
	name = "Набор кастомизации Дюранда \"Кхарн MK. IV\""
	icon_state = "paintkit_unathi"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Дюранда в ящероподобный инопланетный мех."

	new_name = "Кхарн MK. IV"
	new_desc = "Жизнь за Императницу!"
	new_icon = "unathi"
	allowed_types = list("durand")
	new_wreckage = /obj/structure/mecha_wreckage/durand/unathi

/obj/item/paintkit/durand_shire
	name = "Набор кастомизации Дюранда \"Шир\""
	icon_state = "paintkit_shire"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Дюранда в невероятно тяжелую боевую машину."

	new_name = "Шир"
	new_desc = "Невероятно тяжелая боевая машина, созданная по проекту Межзвездной Войны."
	new_icon = "shire"
	allowed_types = list("durand")
	new_wreckage = /obj/structure/mecha_wreckage/durand/shire

/obj/item/paintkit/durand_skull
	name = "Набор кастомизации Дюранда \"Скелемех\""
	icon_state = "paintkit_skull"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Дюранда в монстра Лаваленда!"

	new_name = "Скелемех"
	new_desc = "Мех, укрепленный черепами древних монстров. На этот ужас нужен опытный шахтёр."
	new_icon = "skullmech"
	allowed_types = list("durand")
	new_wreckage = /obj/structure/mecha_wreckage/durand/skull

// USELESS SHIT

/obj/item/paintkit/phazon_imperion
	name = "Набор кастомизации Фазона \"Империон\""
	icon_state = "paintkit_imperon"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения дорогого и совершенного Фазона в еще более дорогой и совершенный Империон."

	new_name = "Империон"
	new_desc = "Вершина научных исследований и гордость \"Нанотрейзен\", в нем используются передовые технологии блюспейса и дорогостоящие материалы."
	new_icon = "imperion"
	allowed_types = list("phazon")
	new_wreckage = /obj/structure/mecha_wreckage/phazon/imperion

/obj/item/paintkit/phazon_janus
	name = "Набор кастомизации Фазона \"Янус\""
	icon_state = "paintkit_janus"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Фазона в более темную и дорогую версию самого себя."

	new_name = "Янус"
	new_desc = "Вершина научных исследований и гордость \"Нанотрейзен\", в нем используются передовые технологии блюспейса и дорогостоящие материалы."
	new_icon = "janus"
	allowed_types = list("phazon")
	new_wreckage = /obj/structure/mecha_wreckage/phazon/janus

/obj/item/paintkit/phazon_plazmus
	name = "Набор кастомизации Фазона \"Плазмус\""
	icon_state = "paintkit_plazmus"
	desc = "Набор, содержащий все необходимые инструменты и детали для превращения Фазона в фиолетовый мех."

	new_name = "Плазмус"
	new_desc = "Значит, вы объединили в этой штуке две самые опасные технологии?"
	new_icon = "plazmus"
	allowed_types = list("phazon")
	new_wreckage = /obj/structure/mecha_wreckage/phazon/plazmus

/obj/item/paintkit/phazon_blanco
	name = "Набор кастомизации Фазона \"Бланко\""
	icon_state = "paintkit_white"
	desc = "Набор с белой краской для Фазона."

	new_name = "Бланко"
	new_desc = "Потребовалось более полугода работы, чтобы найти идеальные пастельные цвета для этого меха."
	new_icon = "phazon_blanco"
	allowed_types = list("phazon")
	new_wreckage = /obj/structure/mecha_wreckage/phazon/phazon_blanco
