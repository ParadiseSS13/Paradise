/obj/mecha/combat/gygax
	desc = "Легкий боевой экзокостюм. Популярен среди частных и корпоративных служб безопасности"
	name = "Gygax"
	icon_state = "gygax"
	initial_icon = "gygax"
	step_in = 3
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 5
	armor = list(melee = 25, bullet = 20, laser = 30, energy = 15, bomb = 0, rad = 0, fire = 100, acid = 75)
	max_temperature = 25000
	infra_luminosity = 6
	leg_overload_coeff = 2
	wreckage = /obj/structure/mecha_wreckage/gygax
	internal_damage_threshold = 35
	max_equip = 3
	maxsize = 2
	step_energy_drain = 3
	normal_step_energy_drain = 3

/obj/mecha/combat/gygax/GrantActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Grant(user, src)

/obj/mecha/combat/gygax/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	overload_action.Remove(user)

/obj/mecha/combat/gygax/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)

/obj/mecha/combat/gygax/examine_more(mob/user)
	. = ..()
	. += "<i>Легкий, быстрый и дешевый боевой экзокостюм, разработанный и произведенный Shellguard Munitions. \
	Первоначально разработан как мобильный мех для сценариев открытого боя, однако существенный недостаток в системе ускорения ног привёл к плохим продажам. \
	При использовании этой системы ноги Гигакса склонны к перегреву и повреждению остальной части экзокостюма, в результате чего чрезмерно усердные пилоты наносят больше вреда себе, чем противнику.</i>"
	. += ""
	. += "<i>Несмотря на этот недостаток, Shellguard Munitions смогли пересмотреть использование этого робота и начали рекламировать его как экзокостюм для гражданской обороны и полиции. \
	Популярность резко возросла, особенно среди таких корпораций, как Nanotrasen, которые искали легкую, быструю и дешевую конструкцию для оснащения своих служб безопасности. \
	Как в случаях со всеми станционными мехами, Nanotrasen приобрела лицензию на производство Гигакса на своих предприятиях.</i>"

/obj/mecha/combat/gygax/dark
	desc = "Легкий экзокостюм, окрашенный в темные тона. Эта модель, похоже, имеет некоторые модификации."
	name = "Dark Gygax"
	icon_state = "darkgygax"
	initial_icon = "darkgygax"
	max_integrity = 300
	deflect_chance = 20
	armor = list(melee = 40, bullet = 40, laser = 50, energy = 35, bomb = 20, rad =20, fire = 100, acid = 100)
	max_temperature = 35000
	leg_overload_coeff = 100
	operation_req_access = list(ACCESS_SYNDICATE)
	wreckage = /obj/structure/mecha_wreckage/gygax/dark
	max_equip = 5
	maxsize = 2
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	destruction_sleep_duration = 2 SECONDS

/obj/mecha/combat/gygax/dark/trader
	operation_req_access = list() //Jailbroken mech

/obj/mecha/combat/gygax/dark/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot/syndie
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/thrusters
	ME.attach(src)

/obj/mecha/combat/gygax/dark/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/combat/gygax/dark/examine_more(mob/user)
	..()
	. = list()
	. += "<i>Легкий, быстрый и дешевый боевой экзокостюм, разработанный и произведенный Shellguard Munitions, хотя он выглядит модифицированным. \
	С небольшими изменениями в снаряжении, броне и гладкой черной окраске этот вариант выглядит угрожающе, а его владелец явно не из тех, с кем вам следует связываться.</i>"
	. += ""
	. += "<i>Несмотря на недостатки базовой модели, этот модифицированный Гигакс является быстрой и опасной машиной для убийств. \
	Подобные модели распространены среди преступных группировок, и модификации, безусловно, являются незаконными.</i>"
