/obj/mecha/combat/durand
	desc = "Тяжело бронированный экзокостюм, разработанный для боевых действий на передовой."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(MELEE = 40, BULLET = 35, LASER = 15, ENERGY = 10, BOMB = 20, RAD = 50, FIRE = 100, ACID = 75)
	max_temperature = 30000
	infra_luminosity = 8
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)

/obj/mecha/combat/durand/examine_more(mob/user)
	. = ..()
	. += "<i>Надежный тяжелый боевой робот, разработанный и произведенный Defiance Arms. \
	Дюранд является устаревшей моделью среди боевых мехов Defiance Arms и изначально создавался для прорыва обороны противника. \
	Вытесненные более новыми, более совершенными моделями, эти старые экзокостюмы оказались на открытом рынке и пользуются популярностью среди корпораций, частных охранных фирм и планетарной милиции.</i>"
	. += ""
	. += "<i>Дюранд способен нести широкий спектр тяжелого оружия и защитных инструментов, потому Nanotrasen использует его в качестве машины для противодействия биологическим опасностям, враждебным инопланетным формам жизни, а так же для защиты новых исследовательских станций или для отражения враждебной фауны и флоры. \
	Как в случаях со всеми станционными мехами, Nanotrasen приобрела лицензию на производство Дюранда на своих предприятиях.</i>"

/obj/mecha/combat/durand/old
	desc = "Списанный экзокостюм третьего поколения, разработанный компанией Defiance Arms для боевых действий. Изначально создан для борьбы с враждебными инопланетными формами жизни."
	name = "Old Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	armor = list(MELEE = 50, BULLET = 35, LASER = 15, ENERGY = 15, BOMB = 20, RAD = 50, FIRE = 100, ACID = 100)
	wreckage = /obj/structure/mecha_wreckage/durand/old

/obj/mecha/combat/durand/old/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Настоящая реликвия среди мехов, когда-то произведенная Defiance Arms в 2470-х годах. \
	Сейчас его ищут как коллекционеры, так и музеи, и за десятилетия, прошедшие с тех пор, как его заменили более поздние версии, он попал в руки многих черных рынков.</i>"
	. += ""
	. += "<i>Созданные изначально для уничтожения нашествий ксеноморфов, существуют более крупные и эффективные боевые экзокостюмы. \
	Но многие до сих пор считают эту версию Дюранда непреодолимой классикой, и найти такую ​​неповрежденную и функциональную модель становится все сложнее.</i>"
