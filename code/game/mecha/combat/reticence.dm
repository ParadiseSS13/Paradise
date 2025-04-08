/obj/mecha/combat/reticence
	desc = "Бесшумный и быстрый экзокостюм для мимов. Популярен среди мимов."
	name = "\improper Reticence"
	icon_state = "mime"
	initial_icon = "mime"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 150
	deflect_chance = 30
	armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 15, BOMB = 0, RAD = 0, FIRE = 100, ACID = 75)
	max_temperature = 15000
	wreckage = /obj/structure/mecha_wreckage/reticence
	operation_req_access = list(ACCESS_MIME)
	add_req_access = 0
	internal_damage_threshold = 60
	max_equip = 3
	step_energy_drain = 3
	normal_step_energy_drain = 3
	stepsound = null
	turnsound = null
	starting_voice = /obj/item/mecha_modkit/voice/silent

/obj/mecha/combat/reticence/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/mimercd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)

/obj/mecha/combat/reticence/examine_more(mob/user)
	. = ..()
	. += "<i>Суровая, бесцветная модификация шасси Гигакса, Молчун — это зрелище, на которое стоит смотреть… или не смотреть. \
	Он использует таинственное поглощающее поле, чтобы сохранять полную тишину при движении по любой местности, что делает его излюбленным оружием для тихих убийц.</i>"
	. += ""
	. += "<i>Вооружен Т.С.С. Карабин «Тихий час», совершенно бесшумным оружием, которое способно истощить цель. \
	В качестве второстепенного инструмента он оснащен УБС мима, устройством, способным воспроизводить таинственную способность пантомимы создавать непроницаемые, невидимые стены. \
	Как ни странно, Молчун, похоже, присутствует на каждой станции Nanotrasen, хотя никто не знает, с какой целью.</i>"
