/obj/structure/billboard
	name = "\improper Пустой билборд"
	desc = "Пустой рекламный щит, на котором есть место для любой рекламы."
	icon = 'modular_ss220/objects/icons/billboard.dmi'
	icon_state = "billboard_blank"
	layer = ABOVE_ALL_MOB_LAYER
	max_integrity = 1000
	bound_width = 96
	bound_height = 32
	density = TRUE
	anchored = TRUE

/obj/structure/billboard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 1, 2, 0)

/obj/structure/billboard/donk_n_go
	name = "\improper Билборд Donk-n-Go"
	desc = "Рекламный щит, рекламирующий Donk-n-Go, вечно актуальное и вечно нездоровое предприятие быстрого питания Donk Co: ЗАШЕЛ, НАЕЛСЯ, УШЕЛ!"
	icon_state = "billboard_donk_n_go"

/obj/structure/billboard/space_cola
	name = "\improper Билборд Space Cola"
	desc = "Рекламный щит с рекламой Space Cola: Расслабьтесь, выпейте колы."
	icon_state = "billboard_space_cola"

/obj/structure/billboard/nanotrasen
	name = "\improper Билборд Nanotrasen"
	desc = "Рекламный щит с рекламой Nanotrasen. Лучшее завтра - сегодня."
	icon_state = "billboard_nanotrasen"

/obj/structure/billboard/nanotrasen/defaced
	name = "\improper Обезображенный билборд Nanotrasen"
	desc = "Рекламный щит, рекламирующий Nanotrasen. Кто-то намалевал на нем сообщение: Нахуй Корпоратских Свиней."
	icon_state = "billboard_fuck_corps"

/obj/structure/billboard/azik
	name = "\improper Билборд Azik Interstellar"
	desc = "Рекламный щит, рекламирующий компанию Azik Interstellar и ее новейшую модель - солнечный парусник Autocrat. Azik Interstellar: Тизирийские технологии для галактических нужд."
	icon_state = "billboard_azik"

/obj/structure/billboard/cvr
	name = "\improper Билборд Charlemagne von Rheinland"
	desc = "Рекламный щит, рекламирующий супер-яхту класса Germania компании Charlemagne von Rheinland. Карл Великий из Рейнланда: верфь королей."
	icon_state = "billboard_cvr"

/obj/structure/billboard/twenty_four_seven
	name = "\improper Билборд 24-Seven"
	desc = "Рекламный щит, рекламирующий новую линейку лимитированных вкусов Slushee от 24-Seven. 24-Seven: Весь день, каждый день."
	icon_state = "billboard_twenty_four_seven"

/obj/structure/billboard/starway
	name = "\improper Билборд Starway Transit"
	desc = "Рекламный щит, рекламирующий прямой рейс Starway Transit из Новой Москвы в Нью-Йорк: всего 2000 кредитов за место в эконом-классе. Starway: Ваш билет к звездам."
	icon_state = "billboard_starway"

/obj/structure/billboard/lizards_gas
	name = "\improper Билборд The Lizard's Gas"
	desc = "Рекламный щит с надписью о заправке, известной как 'The Lizard's Gas'. Она была утрачена со временем, и это единственная известная заправка такого типа. По качеству рекламного щита трудно понять, почему она провалилась."
	icon_state = "billboard_lizards_gas"

/obj/structure/billboard/lizards_gas/defaced
	desc = "Рекламный щит с надписью о заправке, известной как 'The Lizard's Gas'. Душевно нарисованный рекламный щит был измазан граффити, и добрый незнакомец закрасил его."
	icon_state = "billboard_lizards_gas_defaced"

/obj/structure/billboard/roadsign
	name = "\improper Билборд Roadsign"
	desc = "Рекламный щит, уведомляющий читателя о том, сколько километров осталось до заправки. Однако этот щит, похоже, пустой."
	icon_state = "billboard_roadsign_blank"

/obj/structure/billboard/roadsign/two
	desc = "Рекламный щит, информирующий читателя о том, сколько километров осталось до следующей заправки. Трудно понять, для чего вообще нужен этот знак."
	icon_state = "billboard_roadsign_two"

/obj/structure/billboard/roadsign/twothousand
	desc = "Рекламный щит, информирующий читателя о том, сколько километров осталось до следующей заправки. Увидев такое, вы наверняка захотите запастись едой и бензином."
	icon_state = "billboard_roadsign_twothousand"

/obj/structure/billboard/roadsign/twomillion
	desc = "Рекламный щит, информирующий читателя о том, сколько километров осталось до следующей заправки. Если вы способны преодолевать многомиллионные расстояния, это не должно вызвать у вас затруднений! Если же нет..."
	icon_state = "billboard_roadsign_twomillion"

/obj/structure/billboard/roadsign/error
	desc = "Рекламный щит, информирующий читателя о том, сколько километров осталось до следующей заправки. Это статичная надпись, так что остается только гадать, какой человек мог бы ее напечатать и повесить."
	icon_state = "billboard_roadsign_error"

/obj/structure/billboard/smoothies
	name = "\improper Билборд Spinward Smoothies"
	desc = "Рекламный щит с рекламой Spinward Smoothies."
	icon_state = "billboard_smoothies"

/obj/structure/billboard/fortune_telling
	name = "\improper Билборд Fortune Teller"
	desc = "Рекламный щит с рекламой гаданий. Оказывается, это делают настоящие экстрасенсы!"
	icon_state = "billboard_fortune_tell"

/obj/structure/billboard/Phone_booth
	name = "\improper Билборд Holophone"
	desc = "Рекламный щит, рекламирующий голофоны. Межзвездные вызовы по доступной цене 49,99 кредитов с беспошлинными закусками!"
	icon_state = "billboard_phone"

/obj/structure/billboard/american_diner
	name = "\improper Билборд All-American Diner"
	desc = "Рекламный щит, рекламирующий франшизу ресторана старой школы 1950-х годов \"All-American Diner\"."
	icon_state = "billboard_american_diner"

