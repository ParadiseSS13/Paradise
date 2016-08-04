////////////////////////////////////////
/////////////Stock Parts////////////////
////////////////////////////////////////

/datum/design/basic_capacitor
	name = "Basic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "basic_capacitor"
	req_tech = list("powerstorage" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/basic_sensor
	name = "Basic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "basic_sensor"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/micro_mani
	name = "Micro Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "micro_mani"
	req_tech = list("materials" = 1, "programming" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/basic_micro_laser
	name = "Basic Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "basic_micro_laser"
	req_tech = list("magnets" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/basic_matter_bin
	name = "Basic Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "basic_matter_bin"
	req_tech = list("materials" = 1)
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/adv_capacitor
	name = "Advanced Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "adv_capacitor"
	req_tech = list("powerstorage" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/weapon/stock_parts/capacitor/adv
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/adv_sensor
	name = "Advanced Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "adv_sensor"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/weapon/stock_parts/scanning_module/adv
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/nano_mani
	name = "Nano Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "nano_mani"
	req_tech = list("materials" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30)
	build_path = /obj/item/weapon/stock_parts/manipulator/nano
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/high_micro_laser
	name = "High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "high_micro_laser"
	req_tech = list("magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20)
	build_path = /obj/item/weapon/stock_parts/micro_laser/high
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/adv_matter_bin
	name = "Advanced Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "adv_matter_bin"
	req_tech = list("materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/weapon/stock_parts/matter_bin/adv
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/super_capacitor
	name = "Super Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "super_capacitor"
	req_tech = list("powerstorage" = 5, "materials" = 4)
	build_type = PROTOLATHE
	reliability = 71
	materials = list(MAT_METAL = 50, MAT_GLASS = 50, MAT_GOLD = 20)
	build_path = /obj/item/weapon/stock_parts/capacitor/super
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/phasic_sensor
	name = "Phasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "phasic_sensor"
	req_tech = list("magnets" = 5, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20, MAT_SILVER = 10)
	reliability = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/phasic
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/pico_mani
	name = "Pico Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "pico_mani"
	req_tech = list("materials" = 5, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30)
	reliability = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/pico
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/ultra_micro_laser
	name = "Ultra-High-Power Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "ultra_micro_laser"
	req_tech = list("magnets" = 5, "materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20, MAT_URANIUM = 10)
	reliability = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/ultra
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/super_matter_bin
	name = "Super Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "super_matter_bin"
	req_tech = list("materials" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 80)
	reliability = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/super
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/quadratic_capacitor
	name = "Quadratic Capacitor"
	desc = "A stock part used in the construction of various devices."
	id = "quadratic_capacitor"
	req_tech = list("powerstorage" = 6, "materials" = 5)
	build_type = PROTOLATHE
	reliability = 71
	materials = list(MAT_METAL = 100, MAT_GLASS = 100, MAT_DIAMOND = 40)
	build_path = /obj/item/weapon/stock_parts/capacitor/quadratic
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/triphasic_scanning
	name = "Triphasic Scanning Module"
	desc = "A stock part used in the construction of various devices."
	id = "triphasic_scanning"
	req_tech = list("magnets" = 6, "materials" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 40, MAT_DIAMOND = 20)
	reliability = 72
	build_path = /obj/item/weapon/stock_parts/scanning_module/triphasic
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/femto_mani
	name = "Femto Manipulator"
	desc = "A stock part used in the construction of various devices."
	id = "femto_mani"
	req_tech = list("materials" = 6, "programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 60, MAT_DIAMOND = 30)
	reliability = 73
	build_path = /obj/item/weapon/stock_parts/manipulator/femto
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/quadultra_micro_laser
	name = "Quad-Ultra Micro-Laser"
	desc = "A stock part used in the construction of various devices."
	id = "quadultra_micro_laser"
	req_tech = list("magnets" = 6, "materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 40, MAT_URANIUM = 20, MAT_DIAMOND = 20)
	reliability = 70
	build_path = /obj/item/weapon/stock_parts/micro_laser/quadultra
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/bluespace_matter_bin
	name = "Bluespace Matter Bin"
	desc = "A stock part used in the construction of various devices."
	id = "bluespace_matter_bin"
	req_tech = list("materials" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 160, MAT_DIAMOND = 200)
	reliability = 75
	build_path = /obj/item/weapon/stock_parts/matter_bin/bluespace
	category = list("Stock Parts")
	lathe_time_factor = 5

/datum/design/RPED
	name = "Rapid Part Exchange Device"
	desc = "Special mechanical module made to store, sort, and apply standard machine parts."
	id = "rped"
	req_tech = list("engineering" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 5000) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer
	category = list("Stock Parts")

/datum/design/BS_RPED
	name = "Bluespace RPED"
	desc = "Powered by bluespace technology, this RPED variant can upgrade buildings from a distance, without needing to remove the panel first."
	id = "bs_rped"
	req_tech = list("engineering" = 3, "materials" = 5, "programming" = 3, "bluespace" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 15000, MAT_GLASS = 5000, MAT_SILVER = 2500) //hardcore
	build_path = /obj/item/weapon/storage/part_replacer/bluespace
	category = list("Stock Parts")

/datum/design/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	req_tech = list("abductor" = 1, "materials" = 7, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list("Stock Parts")
	lathe_time_factor = 5