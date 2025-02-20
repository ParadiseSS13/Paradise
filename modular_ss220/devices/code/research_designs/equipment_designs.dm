/datum/design/tray_scanner_range
	name = "Extended T-ray"
	desc = "Расширенный T-ray сканер с увеличенной дальностью и стандартной продолжительностью отображения скрытых инженерных коммуникаций."
	id = "tray_range"
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/mod/extended_range
	category = list("Equipment")

/datum/design/tray_scanner_pulse
	name = "Pulse T-ray"
	desc = "Пульсовый T-ray сканер с увеличенной длительностью и стандартной дальностью отображения скрытых инженерных коммуникаций."
	id = "tray_pulse"
	req_tech = list("magnets" = 3, "programming" = 3, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_DIAMOND = 200)
	build_path = /obj/item/t_scanner/mod/pulse
	category = list("Equipment")

/datum/design/tray_scanner_advanced
	name = "Advanced T-ray"
	desc = "Продвинутый T-ray сканер с увеличенной длительностью и дальностью отображения скрытых инженерных коммуникаций."
	id = "tray_advanced"
	req_tech = list("magnets" = 6, "programming" = 6, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 1000, MAT_DIAMOND = 500)
	build_path = /obj/item/t_scanner/mod/advanced
	category = list("Equipment")

/datum/design/tray_scanner_science
	name = "Science T-ray"
	desc = "Научный T-ray сканер, дальнейшее развитие улучшенного T-ray сканнера."
	id = "tray_science"
	req_tech = list("magnets" = 7, "programming" = 7, "engineering" = 7) // вершина ветки развития сканнеров, сложно открыть
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 2000, MAT_DIAMOND = 1500)
	build_path = /obj/item/t_scanner/mod/science
	category = list("Equipment")

/datum/design/sec_tray_scanner
	name = "Security T-ray"
	desc = "Специальный вариант T-ray сканера, используемый для обнаружения биологических объектов. Устройство уязвимо для ЭМИ излучения."
	id = "sec_tray"
	req_tech = list("magnets" = 7, "programming" = 7, "engineering" = 7, "biotech" = 7) // вариант научного сканнера с упором на биообъекты
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500, MAT_SILVER = 2000, MAT_DIAMOND = 1500)
	build_path = /obj/item/t_scanner/mod/security
	category = list("Equipment")
