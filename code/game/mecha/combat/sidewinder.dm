/obj/mecha/combat/sidewinder // если вдруг будет введен оригинал, просьба заменить адрес на sidewinder/full_load для соблюдения логики и избежания ошибок
	name = "\improper Экспериментальный Сайдвиндер"
	desc = "Экпериментальная разработка НТ, стоимость которой сравнится со всей станцией Керберос и всем её содержимым. Смотря на это чудо, вы нутром понимаете последствия, если она поломается. Они будут печальными. Очень. Для всех."
	icon_state = "sidewinder"
	initial_icon = "sidewinder"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 1000 // мы ОЧЕНЬ хотим пострелять
	deflect_chance = 0 // никакого рандома
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0) // мех для тестов, не для боя
	max_temperature = 15000
	wreckage = /obj/structure/mecha_wreckage/sidewinder
	maint_access = 1
	internal_damage_threshold = 100 // для тестов внутренних повреждений
	max_equip = 27 //а хули вы хотели, 60 тонн!
	starting_voice = /obj/item/mecha_modkit/voice/nanotrasen

/obj/mecha/combat/sidewinder/add_cell()
	cell = new /obj/item/stock_parts/cell/infinite/abductor(src)

/obj/mecha/combat/sidewinder/New() // мех для тестов всех модулей, пихаемых в конкретно боевые мехи. Если будете вводить/удалять модули - просьба трогать эту строчку.
	..()
	//mime
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/mimercd //HAHA IT MAKES WALLS GET IT
	ME.attach(src)
	//henk
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	ME.attach(src)
	//non-lethal
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bola // учтите, сайдвиндер с йогов мех ближнего боя, если будете вводить - не забудьте отредачить.
	ME.attach(src)
	//lethal
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/ionshotgun
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/xray/triple
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/amlg
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/medium
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang/clusterbang
	ME.attach(src)
