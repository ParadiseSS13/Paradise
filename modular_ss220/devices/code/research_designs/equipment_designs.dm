/datum/design/tray_scanner_range
	name = "Extended T-ray"
	desc = "Расширенный по дальности Т-сканнер позволяющий визуально обнаружить скрытые объекты."
	id = "tray_range"
	req_tech = list("magnets" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/mod/extended_range
	category = list("Equipment")

/datum/design/tray_scanner_pulse
	name = "Pulse T-ray"
	desc = "Пульсовой Т-сканнер позволяющий гораздо дольше визуально обнаруживать скрытые объекты."
	id = "tray_pulse"
	req_tech = list("magnets" = 5, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/mod/pulse
	category = list("Equipment")

/datum/design/tray_scanner_advanced
	name = "Advanced T-ray"
	desc = "Расширенный по дальности Т-сканнер, более дольше удерживающий пульсар, позволяющий визуально обнаружить скрытые объекты."
	id = "tray_advanced"
	req_tech = list("magnets" = 7, "programming" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 1000, MAT_DIAMOND = 500)
	build_path = /obj/item/t_scanner/mod/advanced
	category = list("Equipment")

/datum/design/tray_scanner_science
	name = "Science T-ray"
	desc = "Научный Т-сканнер совмещающий в себя технологии пульсового и расширенного сканнера."
	id = "tray_science"
	req_tech = list("magnets" = 8, "programming" = 7, "engineering" = 7) // придется постараться чтобы найти 8-й уровень технологий
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 2000, MAT_DIAMOND = 1500)
	build_path = /obj/item/t_scanner/mod/science
	category = list("Equipment")

/datum/design/sec_tray_scanner
	name = "Security T-ray"
	desc = "An advance use of a terahertz-ray to find any invisible biological creature nearby."
	id = "sec_tray"
	req_tech = list("magnets" = 7, "biotech" = 7, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_DIAMOND = 500)
	build_path = /obj/item/t_scanner/mod/security
	category = list("Equipment")
