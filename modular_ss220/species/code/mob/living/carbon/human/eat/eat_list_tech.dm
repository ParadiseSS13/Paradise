/obj/item/pda/afterattack(atom/A as mob|obj|turf|area, mob/user as mob, proximity)
	if(try_item_eat(A, user))
		return FALSE

//===== Vox food =====
//Bad tech
/obj/item/flashlight/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 8
	nutritional_value = 2
	is_only_grab_intent = TRUE	//всё-таки используется в подсвечивании глаз тенеморфам

/obj/item/clothing/head/hardhat/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 8
	nutritional_value = 2

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 3

/obj/item/signmaker/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 3

/obj/item/pipe_painter/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 3

/obj/item/airlock_painter/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 3

/obj/item/laser_pointer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 15
	is_only_grab_intent = TRUE	//лазером можно светить в глаза

/obj/item/radio/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 5

/obj/item/gps/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 15
	nutritional_value = 3



//Medium tech
/obj/item/t_scanner/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 2
	nutritional_value = 20

/obj/item/slime_scanner/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 20

/obj/item/sensor_device/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 20

/obj/item/mining_scanner/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 15

/obj/item/pinpointer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 20

//Используемые на карбонах
/obj/item/healthanalyzer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 3
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 4
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer/advanced/Initialize(mapload)
	. = ..()
	nutritional_value = 50

/obj/item/plant_analyzer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 4
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/autopsy_scanner/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner/adv/Initialize(mapload)
	. = ..()
	nutritional_value = 40

/obj/item/analyzer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 15

/obj/item/melee/baton/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 10
	is_only_grab_intent = TRUE

/obj/item/melee/baton/cattleprod/Initialize(mapload)
	. = ..()
	nutritional_value = 5



//Good tech
/obj/item/circuitboard/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 3
	nutritional_value = 20

/obj/item/borg/upgrade/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 3
	nutritional_value = 20

/obj/item/multitool/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 5
	nutritional_value = 10

/obj/item/multitool/abductor
	nutritional_value = 50

/obj/item/multitool/ai_detect
	nutritional_value = 50

/obj/item/radio/headset/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 20
	is_only_grab_intent = TRUE	//чтобы случайно не надкусили

/obj/item/pda/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 5
	is_only_grab_intent = TRUE

/obj/item/paicard/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 15

/obj/item/machineprototype/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 20
	nutritional_value = 15

/obj/item/mobcapsule/Initialize(mapload) //lazarus
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 30

/obj/item/camera_bug/Initialize(mapload)	//Hakuna matata
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 4
	nutritional_value = 30
	is_only_grab_intent = TRUE

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 5
	nutritional_value = 80
	is_only_grab_intent = TRUE

/obj/item/encryptionkey/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 30

/obj/item/implanter
	bites_limit = 1
	nutritional_value = 15

/obj/item/beacon/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 30

/obj/item/aicard/Initialize(mapload)	//тяжело жуется
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 40
	nutritional_value = 5

/obj/item/holder/drone/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 15



//Parts
/obj/item/pod_parts/core/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 20
	nutritional_value = 10

/obj/item/airlock_electronics/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 10

/obj/item/airalarm_electronics/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 10

/obj/item/apc_electronics/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 15

/obj/item/assembly/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 20

/obj/item/stock_parts/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1
	nutritional_value = 5

/obj/item/stock_parts/capacitor/adv/Initialize(mapload)
	. = ..()
	nutritional_value = 15
/obj/item/stock_parts/scanning_module/adv/Initialize(mapload)
	. = ..()
	nutritional_value = 15
/obj/item/stock_parts/manipulator/nano/Initialize(mapload)
	. = ..()
	nutritional_value = 15
/obj/item/stock_parts/micro_laser/high/Initialize(mapload)
	. = ..()
	nutritional_value = 15
/obj/item/stock_parts/matter_bin/adv/Initialize(mapload)
	. = ..()
	nutritional_value = 15

/obj/item/stock_parts/capacitor/super/Initialize(mapload)
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/scanning_module/phasic/Initialize(mapload)
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/manipulator/pico/Initialize(mapload)
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/micro_laser/ultra/Initialize(mapload)
	. = ..()
	nutritional_value = 30
/obj/item/stock_parts/matter_bin/super/Initialize(mapload)
	. = ..()
	nutritional_value = 30

/obj/item/stock_parts/capacitor/quadratic/Initialize(mapload)
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/scanning_module/triphasic/Initialize(mapload)
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/manipulator/femto/Initialize(mapload)
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/micro_laser/quadultra/Initialize(mapload)
	. = ..()
	nutritional_value = 60
/obj/item/stock_parts/matter_bin/bluespace/Initialize(mapload)
	. = ..()
	nutritional_value = 60



//Syndie devices
/obj/item/rad_laser/Initialize(mapload)	//health analyzer с радиацией. Смаковать таким одно удовольствие. Если конечно найдут.
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 20
	nutritional_value = 30
	is_only_grab_intent = TRUE

/obj/item/jammer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit =	6
	nutritional_value = 80

/obj/item/teleporter/Initialize(mapload)	//Нет, это не хайриск, это синди-телепортер
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 8
	nutritional_value = 120

/obj/item/batterer/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 6
	nutritional_value = 100
	is_only_grab_intent = TRUE

/obj/item/card/emag/Initialize(mapload)		//Каждый кусочек по ощущениям растекается словно мед по твоим воксовым кубам...
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 200
	is_only_grab_intent = TRUE

/obj/item/card/emag_broken/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 10
	nutritional_value = 50

/obj/item/card/data/clown/Initialize(mapload)
	. = ..()
	material_type = MATERIAL_CLASS_TECH
	bites_limit = 1000
	nutritional_value = 1
