// translate
/obj/item/t_scanner
	name = "T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов под полом, таких как кабели и трубы."

// debug
/obj/item/t_scanner/mod
	name = "Модификация T-ray сканнера"
	desc = "Предмодифицированный сканнер, который не должен был попасть в ваши руки. Отнесите его в ближайший научный отдел \
	\nдля изучения кодерами."
	icon = 'modular_ss220/devices/icons/device.dmi'
	icon_state = "t-ray0"
	origin_tech = "magnets=3;engineering=3"
	var/scan_range = 3
	var/pulse_duration = 8

/obj/item/t_scanner/mod/scan()
	t_ray_scan(loc, pulse_duration, scan_range)

// new scanners
/obj/item/t_scanner/mod/extended_range
	name = "Расширенный T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nОбразец с расширенным радиусов воздействия."
	icon_state = "t-ray-range0"
	scan_range = 5
	origin_tech = "magnets=3;engineering=3"

/obj/item/t_scanner/mod/pulse
	name = "Пульсовой T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nОбразец с продолжительным пульсаром."
	icon_state = "t-ray-pulse0"
	pulse_duration = 20
	origin_tech = "magnets=5;engineering=3"

/obj/item/t_scanner/mod/advanced
	name = "Продвинутый T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nОбразец с расширенным радиусом воздействия и продолжительным пульсаром."
	icon_state = "t-ray-advanced0"
	pulse_duration = 20
	scan_range = 5
	origin_tech = "magnets=7;engineering=3"

/obj/item/t_scanner/mod/science
	name = "Научный T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nНаучный образец сканнера с расширенным радиусом действия и продолжительным пульсаром."
	icon_state = "t-ray-science0"
	scan_range = 7
	pulse_duration = 50
	origin_tech = "magnets=8;engineering=5"
	materials = list(MAT_METAL=500)

/obj/item/t_scanner/mod/experimental	//a high-risk that cannot be disassembled, since this garbage was invented by, well, you know who.
	name = "Экспериментальный T-ray сканнер"
	desc = "Излучатель и сканер терагерцового излучения, используемый для обнаружения скрытых объектов и объектов под полом, таких как кабели и трубы. \
	\nЭкспериментальный образец сканнера с расширенным радиусом действия и продолжительным пульсаром. \
	\nСудя по его виду, эта вещь изобретена безумными учеными, взятая буквально с экспериментами. Вы можете представить больное воображение ученого который это сделал? \
	\nЦенная находка в практическом и научном пользовании. \
	\nНо её не может изучить даже самый продвинутый разборщик, требуется тщательное исследование."
	icon_state = "t-ray-experimental0"
	scan_range = 5
	pulse_duration = 80
	origin_tech = null
	materials = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

// /datum/theft_objective/experimental
// 	name = "experimental T-ray scanner"
// 	typepath = /obj/item/t_scanner/mod/experimental
// 	protected_jobs = list("Research Director")
// 	location_override = "кабинет Директора Исследований"

/obj/item/t_scanner/mod/security
	name = "Противо-маскировочное ТГц устройство"
	desc = "Излучатель терагерцевого типа используемый для сканирования области на наличие замаскированных биоорганизмов. Устройство уязвимо для ЭМИ излучения."
	icon = 'modular_ss220/devices/icons/device.dmi'
	lefthand_file = 'modular_ss220/devices/icons/inhands/items_lefthand.dmi'
	righthand_file = 'modular_ss220/devices/icons/inhands/items_righthand.dmi'
	item_state = "sb_t-ray"
	icon_state = "sb_t-ray0"
	scan_range = 4
	pulse_duration = 15
	var/was_alerted = FALSE // Protection against spam alerts from this scanner
	var/burnt = FALSE // Did emp break us?
	var/datum/effect_system/spark_spread/spark_system	//The spark system, used for generating... sparks?
	origin_tech = "combat=3;magnets=5;biotech=5"

/obj/item/t_scanner/mod/security/Initialize(mapload)
	. = ..()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/t_scanner/mod/security/toggle_on()
	if(!burnt)
		on = !on
		icon_state = copytext(icon_state, 1, length(icon_state))+"[on]"
	if(on)
		START_PROCESSING(SSobj, src)

/obj/item/t_scanner/mod/security/emp_act(severity)
	. = ..()
	if(prob(25) && !burnt)
		burnt = TRUE
		on = FALSE;
