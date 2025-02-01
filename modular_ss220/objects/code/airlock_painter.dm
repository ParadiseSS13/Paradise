// Tweak for multi-tile airlocks, to make them paintable

/obj/machinery/door/airlock/multi_tile
	paintable = TRUE

/datum/painter/airlock
	var/static/list/multi_paint_jobs = list(
		"Atmospherics" = /obj/machinery/door/airlock/multi_tile/atmospheric,
		"Command" = /obj/machinery/door/airlock/multi_tile/command,
		"Engineering" = /obj/machinery/door/airlock/multi_tile/engineering,
		"Mining" = /obj/machinery/door/airlock/multi_tile/supply,
		"Public" = /obj/machinery/door/airlock/multi_tile,
		"Security" = /obj/machinery/door/airlock/multi_tile/security,
	)

// Special behavior for multi-tile airlocks
/datum/painter/airlock/paint_atom(atom/target, mob/user)
	if(!istype(target, /obj/machinery/door/airlock/multi_tile))
		return ..()

	if(!paint_setting)
		to_chat(user, span_warning("Сперва вам нужно выбрать стиль покраски."))
		return

	var/obj/machinery/door/airlock/A = target
	if(!A.paintable)
		to_chat(user, span_warning("Этот тип шлюза не может быть покрашен."))
		return

	var/obj/machinery/door/airlock/airlock = multi_paint_jobs["[paint_setting]"]
	if(isnull(airlock))
		to_chat(user, span_warning("У выбранного стиля шлюзов нету двойной версии."))
		return

	var/obj/structure/door_assembly/assembly = initial(airlock.assemblytype)
	if(A.assemblytype == assembly)
		to_chat(user, span_notice("Этот шлюз уже покрашен в цветовую схему \"[paint_setting]\"!"))
		return

	if(do_after_once(user, 2 SECONDS, FALSE, A))
		A.icon = initial(airlock.icon)
		A.overlays_file = initial(airlock.overlays_file)
		A.assemblytype = initial(airlock.assemblytype)
		A.update_icon()
		return TRUE
