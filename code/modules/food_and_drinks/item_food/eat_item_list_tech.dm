//===== Vox food =====
//Bad tech
/obj/item/flashlight
	material_type = MATERIAL_CLASS_TECH
	max_bites = 8
	nutritional_value = 2
	is_only_grab_intent = TRUE	//всё-таки используется в подсвечивании глаз тенеморфам

/obj/item/clothing/head/hardhat
	material_type = MATERIAL_CLASS_TECH
	max_bites = 8
	nutritional_value = 2

/obj/item/holosign_creator
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 3

/obj/item/signmaker
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 3

/obj/item/pipe_painter
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 3

/obj/item/airlock_painter
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 3

/obj/item/laser_pointer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 15
	is_only_grab_intent = TRUE	//лазером можно светить в глаза

/obj/item/radio
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 5

/obj/item/gps
	material_type = MATERIAL_CLASS_TECH
	max_bites = 15
	nutritional_value = 3



//Medium tech
/obj/item/t_scanner
	material_type = MATERIAL_CLASS_TECH
	max_bites = 2
	nutritional_value = 20

/obj/item/slime_scanner
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

/obj/item/sensor_device
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

/obj/item/mining_scanner
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 15

/obj/item/pinpointer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20

//Используемые на карбонах
/obj/item/healthanalyzer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 4
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/bodyanalyzer/advanced
	nutritional_value = 50

/obj/item/plant_analyzer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 4
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/autopsy_scanner
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 20
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 15
	is_only_grab_intent = TRUE

/obj/item/reagent_scanner/adv
	nutritional_value = 40

/obj/item/analyzer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 15

/obj/item/melee/baton
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 10
	is_only_grab_intent = TRUE

/obj/item/melee/baton/cattleprod
	nutritional_value = 5



//Good tech
/obj/item/circuitboard
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 20

/obj/item/borg/upgrade
	material_type = MATERIAL_CLASS_TECH
	max_bites = 3
	nutritional_value = 20

/obj/item/multitool
	material_type = MATERIAL_CLASS_TECH
	max_bites = 5
	nutritional_value = 10

/obj/item/multitool/abductor
	nutritional_value = 50

/obj/item/multitool/ai_detect
	nutritional_value = 50

/obj/item/radio/headset
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 20
	is_only_grab_intent = TRUE	//чтобы случайно не надкусили

/obj/item/pda
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 5
	is_only_grab_intent = TRUE

/obj/item/paicard
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15

/obj/item/machineprototype
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 15

/obj/item/mobcapsule //lazarus
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 30

/obj/item/camera_bug	//Hakuna matata
	material_type = MATERIAL_CLASS_TECH
	max_bites = 4
	nutritional_value = 30
	is_only_grab_intent = TRUE

/obj/item/door_remote
	material_type = MATERIAL_CLASS_TECH
	max_bites = 5
	nutritional_value = 80
	is_only_grab_intent = TRUE

/obj/item/encryptionkey
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 30

/obj/item/implanter
	max_bites = 1
	nutritional_value = 15

/obj/item/radio/beacon
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 30

/obj/item/aicard	//тяжело жуется
	material_type = MATERIAL_CLASS_TECH
	max_bites = 40
	nutritional_value = 5

/obj/item/holder/drone
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 15



//Parts
/obj/item/pod_parts/core
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 10

/obj/item/airlock_electronics
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 10

/obj/item/airalarm_electronics
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 10

/obj/item/apc_electronics
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 15

/obj/item/assembly
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 20

/obj/item/stock_parts
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1
	nutritional_value = 5

/obj/item/stock_parts/capacitor/adv
	nutritional_value = 15
/obj/item/stock_parts/scanning_module/adv
	nutritional_value = 15
/obj/item/stock_parts/manipulator/nano
	nutritional_value = 15
/obj/item/stock_parts/micro_laser/high
	nutritional_value = 15
/obj/item/stock_parts/matter_bin/adv
	nutritional_value = 15

/obj/item/stock_parts/capacitor/super
	nutritional_value = 30
/obj/item/stock_parts/scanning_module/phasic
	nutritional_value = 30
/obj/item/stock_parts/manipulator/pico
	nutritional_value = 30
/obj/item/stock_parts/micro_laser/ultra
	nutritional_value = 30
/obj/item/stock_parts/matter_bin/super
	nutritional_value = 30

/obj/item/stock_parts/capacitor/quadratic
	nutritional_value = 60
/obj/item/stock_parts/scanning_module/triphasic
	nutritional_value = 60
/obj/item/stock_parts/manipulator/femto
	nutritional_value = 60
/obj/item/stock_parts/micro_laser/quadultra
	nutritional_value = 60
/obj/item/stock_parts/matter_bin/bluespace
	nutritional_value = 60



//Syndie devices
/obj/item/rad_laser	//health analyzer с радиацией. Смаковать таким одно удовольствие. Если конечно найдут.
	material_type = MATERIAL_CLASS_TECH
	max_bites = 20
	nutritional_value = 30
	is_only_grab_intent = TRUE

/obj/item/jammer
	material_type = MATERIAL_CLASS_TECH
	max_bites =	6
	nutritional_value = 80

/obj/item/teleporter	//Нет, это не хайриск, это синди-телепортер
	material_type = MATERIAL_CLASS_TECH
	max_bites = 8
	nutritional_value = 120

/obj/item/batterer
	material_type = MATERIAL_CLASS_TECH
	max_bites = 6
	nutritional_value = 100
	is_only_grab_intent = TRUE

/obj/item/card/emag		//Каждый кусочек по ощущениям растекается словно мед по твоим воксовым кубам...
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 200
	is_only_grab_intent = TRUE

/obj/item/card/emag_broken
	material_type = MATERIAL_CLASS_TECH
	max_bites = 10
	nutritional_value = 50

/obj/item/card/data/clown
	material_type = MATERIAL_CLASS_TECH
	max_bites = 1000
	nutritional_value = 1

