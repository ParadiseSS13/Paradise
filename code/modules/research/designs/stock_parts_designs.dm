////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor
	category = list("Stock Parts")

/datum/design/basic_sensor
	name = "Basic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_sensor"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module
	category = list("Stock Parts")

/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1, "programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator
	category = list("Stock Parts")

/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser
	category = list("Stock Parts")

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list("$metal" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin
	category = list("Stock Parts")

/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Stock Parts")

/datum/design/adv_sensor
	name = "Advanced Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_sensor"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Stock Parts")

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano
	category = list("Stock Parts")

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$glass" = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high
	category = list("Stock Parts")

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv
	category = list("Stock Parts")

/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	build_type = PROTOLATHE
	reliability_base = 71
	materials = list("$metal" = 50, "$glass" = 50, "$gold" = 20)
	build_path = /obj/item/weapon/stock_parts/capacitor/super
	category = list("Stock Parts")

/datum/design/phasic_sensor
	name = "Phasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_sensor"
	req_tech = list("magnets" = 5, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 20, "$silver" = 10)
	reliability_base = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic
	category = list("Stock Parts")

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30)
	reliability_base = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/pico
	category = list("Stock Parts")

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 10, "$glass" = 20, "$uranium" = 10)
	reliability_base = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra
	category = list("Stock Parts")

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 80)
	reliability_base = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/super
	category = list("Stock Parts")
	
/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"
	req_tech = list("engineering" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 15000, "$glass" = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer
	category = list("Stock Parts")