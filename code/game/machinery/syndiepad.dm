/obj/machinery/syndiepad
	name = "Syndicate quantum pad"
	desc = "Syndicate redspace quantumpads! Can transport goods through galaxies and completely ignores bluespace interference!"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "sqpad-idle"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	var/teleport_cooldown = 250 //if 400, cd = 30 seconds due to base parts
	var/teleport_speed = 25
	var/last_teleport //to handle the cooldown
	var/teleporting = 0 //if it's in the process of teleporting
	var/power_efficiency = 1
	var/obj/machinery/syndiepad/linked_pad = null
	var/receive = 0 // получающий ли посылки это телепад или отправляющий.
	var/force_ignore_teleport_blocking = TRUE //Этот флаг позволяет обходить запреты зоны на телепорт. Лучше его не выключать для этих падов
	var/id = null //id телепада для приёма им посылок
	var/target_id = null //id телепада на который будут отправлены посылки
	var/allow_humans = FALSE // Может ли телепад телепортировать живые организмы? Админ Флаг, не изменяемый игроками.
	var/console_link = FALSE // Привязан ли телепад к консоли?

/obj/machinery/syndiepad/receivepad
	name = "syndicate quantum pad #receive"
	id = "syndie_cargo_receive"
	console_link = TRUE
	receive = 1

/obj/machinery/syndiepad/loadpad
	name = "syndicate quantum pad #load"
	id = "syndie_cargo_load"
	console_link = TRUE

/obj/machinery/syndiepad/admin/receivepad
	id = "syndie_cargo_load" //админский синдипад получающий посылки
	receive = 1

/obj/machinery/syndiepad/admin/loadpad
	target_id = "syndie_cargo_receive" //админский синдипад отправляющий посылки
	allow_humans = TRUE

/obj/machinery/syndiepad/Initialize()
	..()
	GLOB.syndiepads += src
	component_parts = list()
	component_parts += new /obj/item/circuitboard/quantumpad/syndiepad(null)
	component_parts += new /obj/item/stack/telecrystal(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)

	RefreshParts()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/syndiepad/LateInitialize()
	pad_sync()

/obj/machinery/syndiepad/Destroy()
	linked_pad = null
	GLOB.syndiepads -= src
	return ..()

/obj/machinery/syndiepad/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	power_efficiency = E
	E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	teleport_speed = initial(teleport_speed)
	teleport_speed -= (E*10)
	teleport_cooldown = initial(teleport_cooldown)
	teleport_cooldown -= (E * 56.25) //Это число гарантирует кулдаун в 2.5 секунды у телепада и в 20 секунд у карго с 8 телепадами при максимальных деталях
	if(console_link)
		var/datum/syndie_data_storage/S = LocateDataStorage()
		S?.sync()

/obj/machinery/syndiepad/proc/LocateDataStorage()
	var/area/src_area = get_area(src)
	for(var/obj/machinery/computer/syndie_supplycomp/SC in GLOB.syndie_cargo_consoles)
		if(get_area(SC) != src_area)
			continue
		var/datum/syndie_data_storage/S = SC.data_storage
		return S
	return null

/obj/machinery/syndiepad/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return
	return ..()

/obj/machinery/syndiepad/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/syndiepad/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE

	if(panel_open)
		if(console_link)
			if(alert("Отвязать телепад от консоли?",, "Да", "Нет") == "Нет")
				return
			console_link = FALSE
			var/datum/syndie_data_storage/S = LocateDataStorage()
			S?.sync()
		else if(!console_link)
			if(alert("Привязать телепад к консоли?",, "Да", "Нет") == "Нет")
				return
			console_link = TRUE
			var/datum/syndie_data_storage/S = LocateDataStorage()
			S?.sync()


/obj/machinery/syndiepad/multitool_act(mob/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(console_link)
		to_chat(user, "<span class='notice'>Этот телепад привязан к консоли, воспользуйтесь ею для управления устройством!</span>")
		return
	receive = !receive
	if(receive)
		to_chat(user, "<span class='notice'>Включен режим получения посылок.</span>")
		var/new_id = input("Задайте ID этому телепаду для получения им посылок")
		if(new_id)
			id = new_id
		linked_pad = null
		target_id = null
	else
		to_chat(user, "<span class='notice'>Включен режим отправки посылок.</span>")
		var/new_target_id = input("Задайте ID телепада на который будут приходить посылки.")
		if(new_target_id && new_target_id != id)
			target_id = new_target_id
		linked_pad = null

/obj/machinery/syndiepad/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_deconstruction_screwdriver(user, "pad-idle-o", "sqpad-idle", I)

/obj/machinery/syndiepad/proc/pad_sync()
	for(var/obj/machinery/syndiepad/S in GLOB.machines)
		if(S.console_link && src.console_link) //Мы не хотим привязываться к другим привязанным к консоли телепадам если мы привязаны к консоли
			continue
		if(!S.id)
			continue
		if(S == src)
			continue
		if(S.id == target_id)
			linked_pad = S
			break

/obj/machinery/syndiepad/attack_hand(mob/user)
	if(console_link)
		to_chat(user, "<span class='notice'>Этот телепад привязан к консоли, воспользуйтесь ею для управления устройством!</span>")
	add_fingerprint(user)
	if(!console_link)
		checks(usr)

/obj/machinery/syndiepad/proc/checks(mob/user)

	if(panel_open)
		to_chat(user, "<span class='warning'>The panel must be closed before operating this machine!</span>")
		return

	if(receive)
		if(!console_link)
			to_chat(user, "<span class='warning'>Receive mode is on! Please change mode if you want this pad to deliver your crates!</span>")
			return

	if(!linked_pad || QDELETED(linked_pad))
		to_chat(user, "<span class='notice'>No linked target pad detected! Attempting to link '[src]' to the target!</span>")
		pad_sync()
		if(!linked_pad || target_id == null)
			to_chat(user, "<span class='warning'>Attempt failed! No target with the ID: '[target_id]' was found!</span>")
		else
			if(console_link)
				doteleport(usr)
			to_chat(user, "<span class='notice'>Successfully linked!</span>")
		return

	if(world.time < last_teleport + teleport_cooldown)
		to_chat(user, "<span class='warning'>[src] is recharging power. Please wait [round((last_teleport + teleport_cooldown - world.time) / 10)] seconds.</span>")
		return

	if(teleporting)
		to_chat(user, "<span class='warning'>[src] is charging up. Please wait.</span>")
		return

	if(linked_pad.teleporting)
		to_chat(user, "<span class='warning'>Linked pad is busy. Please wait.</span>")
		return

	if(linked_pad.stat & NOPOWER)
		to_chat(user, "<span class='warning'>Linked pad is not responding to ping.</span>")
		return

	return doteleport(usr)

/obj/machinery/syndiepad/proc/sparks()
	do_sparks(5, 1, get_turf(src))

/obj/machinery/syndiepad/attack_ghost(mob/dead/observer/ghost)
	if(linked_pad)
		ghost.forceMove(get_turf(linked_pad))

/obj/machinery/syndiepad/proc/doteleport(mob/user)
	if(linked_pad)
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
		teleporting = 1
		spawn(teleport_speed)
			if(!src || QDELETED(src))
				teleporting = 0
				return
			if(stat & NOPOWER)
				to_chat(user, "<span class='warning'>[src] is unpowered!</span>")
				teleporting = 0
				return
			if(!linked_pad || QDELETED(linked_pad) || linked_pad.stat & NOPOWER)
				to_chat(user, "<span class='warning'>Linked pad is not responding to ping. Teleport aborted.</span>")
				teleporting = 0
				return

			teleporting = 0
			last_teleport = world.time
			// use a lot of power
			use_power(10000 / power_efficiency)
			sparks()
			linked_pad.sparks()
			flick("sqpad-beam", src)
			playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			flick("sqpad-beam", linked_pad)
			playsound(get_turf(linked_pad), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff = 5)
			var/tele_success = FALSE

			for(var/atom/movable/ROI in get_turf(src))
				// if is living, check if allowed, don't let through if not
				if(isliving(ROI) && allow_humans == FALSE)
					if(!console_link)
						to_chat(user, "<span class='warning'>Error: You cannot teleport living organisms for security reasons!</span>")
					else
						to_chat(user, "<span class='warning'>Error: '[ROI]' was not teleported! You cannot teleport living organisms for security reasons!</span>")
					continue
				// if is living and in container, check if allowed, don't let through if not
				if((ROI.contents) && allow_humans == FALSE)
					var/check = FALSE
					for(var/mob/living/M in ROI.contents)
						if(!console_link)
							to_chat(user, "<span class='warning'>Error: You cannot teleport living organisms for security reasons!</span>")
						else
							to_chat(user, "<span class='warning'>Error: Object '[ROI]' and it's contents were not teleported! You cannot teleport living organisms for security reasons!</span>")
						check = TRUE
						break
					if(check)
						continue
				// if is anchored, don't let through
				if(ROI.anchored)
					if(!istype(ROI, /obj/mecha))
						if(isliving(ROI))
							var/mob/living/L = ROI
							if(L.buckled)
								// TP people on office chairs
								if(L.buckled.anchored)
									continue
							else
								continue
						else if(!isobserver(ROI))
							continue
				tele_success = do_teleport(ROI, get_turf(linked_pad), bypass_area_flag = force_ignore_teleport_blocking)
				if(!tele_success)
					to_chat(user, "<span class='warning'>Object '[ROI]'' was not teleported for unknown reason!</span>")
			return


