//Put all your tacticool gun gadgets here. So far it's pretty empty


/obj/item/suppressor
	name = "suppressor"
	desc = "A universal syndicate small-arms suppressor for maximum espionage."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"
	item_state = "suppressor"
	w_class = WEIGHT_CLASS_SMALL
	var/oldsound = null
	var/initial_w_class = null
	origin_tech = "combat=2;engineering=2"

/obj/item/suppressor/specialoffer
	name = "cheap suppressor"
	desc = "A foreign knock-off suppressor, it feels flimsy, cheap, and brittle. Still fits all weapons."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "suppressor"

GLOBAL_LIST_EMPTY(guns_registry)
GLOBAL_VAR_INIT(sibsys_automode, TRUE)

#define SIBSYS_REGISTRY	0	// Guns registry table
#define SIBSYS_DETAILS	1	// Show log for gun

/obj/item/sibyl_system_mod
	name = "модуль Sibyl System"
	desc = "Проприетарный модуль от правоохранительной организации на энергетические оружия для подключения к системе Sibyl System"
	icon = 'icons/obj/guns/sibyl.dmi'
	icon_state = "sibyl_chip"
	item_state = "sibyl_chip"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "combat=4;magnets=3;engineering=3"
	hitsound = "swing_hit"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/item/gun/energy/weapon = null
	var/obj/item/card/id/user = null
	var/integrity = 0 // 0=uninstalled/crowbar_act, 1=welder_act, 2=screwdriver_act, 3=installed. Note: from 0 immediately becomes 3, from 3 to 0 changes gradually.
	var/lock = TRUE
	var/force_lock = FALSE
	var/limit = SIBYL_NONLETHAL
	var/list/log = list()
	var/emagged = FALSE

	var/voice_is_enabled = TRUE
	var/voice_user = 'sound/voice/dominator/user.ogg'
	var/voice_link = 'sound/voice/dominator/link.ogg'
	var/voice_battery = 'sound/voice/dominator/battery.ogg'
	var/is_playing = FALSE

	var/list/available = list()
	var/list/nonlethal_names = list("stun", "disabler", "disable", "non-lethal paralyzer", "practice", "ion",
								"energy", "bluetag", "redtag", "yield", "mutation",
								"goddamn meteor", "plasma burst", "blue", "orange",
								"lightning beam", "clown", "teleport beam", "gun mimic",
								"kinetic")
	var/list/lethal_names = list("kill", "lethal-eliminator", "scatter", "anti-vehicle",
								"snipe", "precise", "declone", "mindfuck", "bolt",
								"heavy bolt", "toxic dart", "spraydown", "accelerator")
	var/list/destructive_names = list("destroy", "execution-slaughter", "annihilate")

/obj/item/sibyl_system_mod/proc/install(obj/item/gun/energy/W, mob/U = null)
	if(integrity == 0)
		if(!isnull(U) && !U.unEquip(src))
			return
		src.loc = W
		W.sibyl_mod = src
		weapon = W
		W.verbs += /obj/item/gun/energy/proc/toggle_voice
		integrity = 3
		register()
		check_unknown_names()
		sync_limit()
		W.update_icon()
		add_log_entity("Модуль установлен в [W]. Установка доступных режимов в соответствии с уровнем опасности ([get_security_level_ru()]).")
		if(!isnull(U))
			to_chat(U, "<span class='notice'>Вы установили [src] в [W]. Установка доступных режимов в соответствии с уровнем опасности ([get_security_level_ru()]).</span>")
			if(isnull(user))
				to_chat(U, "<span class='notice'>Требуется авторизация! Приложите ID-карту.</span>")
	else
		integrity++
	return integrity

/obj/item/sibyl_system_mod/proc/register()
	if(!isnull(GLOB.guns_registry))
		for(var/obj/item/sibyl_system_mod/mod in GLOB.guns_registry)
			if(mod.UID() == src.UID())
				return FALSE
	GLOB.guns_registry += list(src)
	spawn(40)
		if(isnull(user) && voice_is_enabled)
			sound_to_user(sound(voice_link, volume=50))
	return TRUE

/obj/item/sibyl_system_mod/proc/uninstall(obj/item/gun/energy/W, mob/U)
	integrity--
	lock(TRUE)
	if(integrity == 0)
		src.loc = get_turf(U)
		W.verbs -= /obj/item/gun/energy/proc/toggle_voice
		W.sibyl_mod = null
		weapon = null
		set_limit(SIBYL_NONLETHAL)
		W.update_icon()
		add_log_entity("Модуль снят с [W].")
	return integrity

/obj/item/sibyl_system_mod/proc/toggle_voice()
	voice_is_enabled = !voice_is_enabled
	say_to_user("<span class='notice'>Голосовая подсистема [voice_is_enabled ? "включена" : "отключена"].</span>")

/obj/item/sibyl_system_mod/proc/toggle_force_lock()
	if(force_lock)
		force_lock = FALSE
		add_log_entity("Принудительная блокировка состояния ОТКЛЮЧЕНА.")
	else
		force_lock = TRUE
		add_log_entity("Принудительная блокировка состояния ВКЛЮЧЕНА")

/obj/item/sibyl_system_mod/proc/lock(silent = FALSE)
	if(emagged)
		return FALSE
	if(force_lock)
		return FALSE
	lock = TRUE
	weapon.update_icon()
	add_log_entity("[weapon] заблокирован.")
	if(!silent)
		say_to_user("<span class='notice'>Блокировка [weapon] включена.</span>")
	return TRUE

/obj/item/sibyl_system_mod/proc/unlock(silent = FALSE)
	if(integrity != 3)
		return FALSE
	if(force_lock && !emagged)
		return FALSE
	lock = FALSE
	weapon.update_icon()
	add_log_entity("[weapon] разблокирован.")
	if(!silent)
		say_to_user("<span class='notice'>Блокировка [weapon] отключена.</span>")
	return TRUE

/obj/item/sibyl_system_mod/proc/toggleAuthorization(obj/item/card/id/ID, mob/U)
	if(integrity != 3)
		return FALSE
	if(isnull(user))
		user = ID
		add_log_entity("Выполнена авторизация [weapon] на имя [user.registered_name].")
		unlock()
		to_chat(U, "<span class='notice'>Вы авторизировали [weapon] в системе Sibyl System под именем [user.registered_name].</span>")
		spawn(20)
			if(!isnull(user) && voice_is_enabled)
				sound_to_user(sound(voice_user, volume=50))
	else if(user == ID)
		user = null
		add_log_entity("Выполнена деавторизация [weapon].")
		lock()
		to_chat(U, "<span class='notice'>Вы деавторизировали [weapon] в системе Sibyl System.</span>")
	else if(ACCESS_ARMORY in ID.GetAccess())
		user = null
		add_log_entity("Выполнена принудительная деавторизация [weapon] ([ID.registered_name]).")
		lock()
		to_chat(U, "<span class='notice'>Вы принудительно деавторизировали [weapon] в системе Sibyl System.</span>")
	weapon.update_icon()
	return TRUE

/obj/item/sibyl_system_mod/proc/check_select()
	if(isnull(weapon))
		return FALSE
	var/select_name = weapon.ammo_type[weapon.select].select_name
	if(lowertext(select_name) in available)
		return TRUE
	else
		check_unknown_names()
	say_to_user("<span class='warning'>Данный режим недоступен в текущий момент!</span>")
	return FALSE

/obj/item/sibyl_system_mod/proc/can_shoot(can_shoot)
	if(isnull(weapon))
		return FALSE
	if(!emagged)
		if(lock)
			if(isnull(user))
				say_to_user("<span class='warning'>Требуется авторизация! Приложите ID-карту.</span>")
			return FALSE
		if(ishuman(weapon.loc))
			if(!find_and_compare_id_cards(weapon.loc, user))
				say_to_user("<span class='warning'>Ваша ID-карта не совпадает с авторизованной.</span>")
				return FALSE
		if(!check_select())
			return FALSE
	if(!can_shoot)
		if(voice_is_enabled)
			sound_to_user(sound(voice_battery, volume=50), TRUE)
		return FALSE
	return TRUE

/obj/item/sibyl_system_mod/proc/find_and_compare_id_cards(var/mob/living/carbon/human/H, var/obj/item/card/id/card)
	ASSERT(istype(H))
	ASSERT(istype(card))

	var/list/places = list(H.wear_id, H.wear_pda, H.l_hand, H.r_hand)
	for(var/place in places)
		var/obj/item/card/id/C = place
		if(istype(C, /obj/item/pda))
			var/obj/item/pda/pda = C
			C = pda.id
		if(istype(C) && C.registered_name == card.registered_name)
			return TRUE

	return FALSE

/obj/item/sibyl_system_mod/proc/process_fire()
	if(!isnull(weapon))
		var/select_name = weapon.ammo_type[weapon.select].select_name
		add_log_entity("Выполнен выстрел из [weapon] в режиме [select_name].")

/obj/item/sibyl_system_mod/proc/set_limit(mode)
	if(isnull(weapon))
		return FALSE
	if(force_lock)
		return FALSE

	limit = mode
	switch(mode)
		if(SIBYL_NONLETHAL)
			available = nonlethal_names
		if(SIBYL_LETHAL)
			available = nonlethal_names + lethal_names
		if(SIBYL_DESTRUCTIVE)
			available = nonlethal_names + lethal_names + destructive_names

	var/message = "Для [weapon] теперь доступны только данные режимы: [get_available_text()]!"
	weapon.update_icon()
	add_log_entity(message)
	if(ismob(weapon.loc))
		to_chat(weapon.loc, "<span class='notice'>[message]</span>")
	return TRUE

/obj/item/sibyl_system_mod/proc/sync_limit()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			set_limit(SIBYL_NONLETHAL)
		if(SEC_LEVEL_BLUE)
			set_limit(SIBYL_LETHAL)
		if(SEC_LEVEL_RED)
			set_limit(SIBYL_LETHAL)
		if(SEC_LEVEL_GAMMA)
			set_limit(SIBYL_DESTRUCTIVE)
		if(SEC_LEVEL_EPSILON)
			set_limit(SIBYL_DESTRUCTIVE)
		if(SEC_LEVEL_DELTA)
			set_limit(SIBYL_DESTRUCTIVE)

/obj/item/sibyl_system_mod/proc/check_unknown_names()
	if(isnull(weapon))
		return FALSE

	for(var/obj/item/ammo_casing/energy/ammo in weapon.ammo_type)
		if(ammo.select_name in nonlethal_names)
			continue
		if(ammo.select_name in lethal_names)
			continue
		if(ammo.select_name in destructive_names)
			continue
		nonlethal_names += list(ammo.select_name)

/obj/item/sibyl_system_mod/proc/limit_up()
	var/mode = limit
	switch(mode)
		if(SIBYL_NONLETHAL)
			mode = SIBYL_LETHAL
		if(SIBYL_LETHAL)
			mode = SIBYL_DESTRUCTIVE
		if(SIBYL_DESTRUCTIVE)
			return FALSE
	set_limit(mode)

/obj/item/sibyl_system_mod/proc/limit_down()
	var/mode = limit
	switch(mode)
		if(SIBYL_NONLETHAL)
			return FALSE
		if(SIBYL_LETHAL)
			mode = SIBYL_NONLETHAL
		if(SIBYL_DESTRUCTIVE)
			mode = SIBYL_LETHAL
	set_limit(mode)

/obj/item/sibyl_system_mod/proc/get_available_text(glue = ", ")
	if(isnull(weapon))
		return FALSE
	var/list/names = list()
	for(var/obj/item/ammo_casing/energy/ammo in weapon.ammo_type)
		if(ammo.select_name in available)
			names += list(ammo.select_name)
	return names.Join(glue)

/obj/item/sibyl_system_mod/proc/add_log_entity(message)
	log += list("\[[station_time_timestamp()]\] " + message)

/obj/item/sibyl_system_mod/proc/say_to_user(message)
	if(ismob(weapon.loc))
		to_chat(weapon.loc, message)

/obj/item/sibyl_system_mod/proc/sound_to_user(sound/S, check_playing = FALSE, length = 30)
	if(!ismob(weapon.loc))
		return FALSE
	S.x = 0
	S.y = 0
	S.z = 0
	S.environment = -1
	S.wait = TRUE
	S.channel = CHANNEL_SIBYL_SYSTEM

	if(check_playing && !is_playing)
		is_playing = TRUE
		weapon.loc << S
		spawn(length)
			is_playing = FALSE
	else
		weapon.loc << S

/obj/item/sibyl_system_mod/Destroy()
	GLOB.guns_registry -= list(src)
	return ..()
