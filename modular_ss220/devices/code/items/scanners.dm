/obj/item/t_scanner
	icon = 'modular_ss220/devices/icons/device.dmi'

//исключаем изменение шахтерского сканера
/obj/item/t_scanner/adv_mining_scanner
	icon = 'icons/obj/device.dmi'

// debug
/obj/item/t_scanner/mod
	name = "Модификация T-ray сканера"
	desc = "Предмодифицированный сканер, который не должен был попасть в ваши руки. Отнесите его в ближайший научный отдел \
	\nдля изучения кодерами."
	icon_state = "t-ray0"
	origin_tech = "magnets=3;engineering=3"
	var/scan_range = 3
	var/pulse_duration = 8

/obj/item/t_scanner/mod/scan()
	t_ray_scan(loc, pulse_duration, scan_range)

// new scanners
/obj/item/t_scanner/mod/extended_range
	name = "Расширенный T-ray сканер"
	desc = "Расширенный T-ray сканер с увеличенной дальностью и стандартной продолжительностью отображения скрытых инженерных коммуникаций."
	icon_state = "t-ray-range0"
	scan_range = 5
	origin_tech = "magnets=3;engineering=3"

/obj/item/t_scanner/mod/pulse
	name = "Пульсовый T-ray сканер"
	desc = "Пульсовый T-ray сканер с увеличенной длительностью и стандартной дальностью отображения скрытых инженерных коммуникаций."
	icon_state = "t-ray-pulse0"
	pulse_duration = 2 SECONDS
	origin_tech = "magnets=3;engineering=3"

/obj/item/t_scanner/mod/advanced
	name = "Продвинутый T-ray сканер"
	desc = "Продвинутый T-ray сканер с увеличенной длительностью и дальностью отображения скрытых инженерных коммуникаций."
	icon_state = "t-ray-advanced0"
	pulse_duration = 2 SECONDS
	scan_range = 5
	origin_tech = "magnets=5;engineering=5"

/obj/item/t_scanner/mod/science
	name = "Научный T-ray сканер"
	desc = "Научный T-ray сканер, дальнейшее развитие улучшенного T-ray сканера."
	icon_state = "t-ray-science0"
	scan_range = 7
	pulse_duration = 5 SECONDS
	origin_tech = "magnets=6;engineering=6"
	materials = list(MAT_METAL=500)

/obj/item/t_scanner/mod/security
	name = "Специализированный био T-ray сканер"
	desc = "Специализированный вариант T-ray сканера, используемый для обнаружения биологических объектов. Устройство уязвимо для ЭМИ излучения."
	lefthand_file = 'modular_ss220/devices/icons/inhands/items_lefthand.dmi'
	righthand_file = 'modular_ss220/devices/icons/inhands/items_righthand.dmi'
	item_state = "sb_t-ray"
	icon_state = "sb_t-ray0"
	scan_range = 4
	pulse_duration = 15
	var/was_alerted = FALSE // Protection against spam alerts from this scanner
	var/burnt = FALSE // Did emp break us?
	var/datum/effect_system/spark_spread/spark_system	//The spark system, used for generating... sparks?
	origin_tech = "magnets=6;engineering=6;biotech=6"

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
