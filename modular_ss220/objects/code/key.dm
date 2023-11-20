
/obj/item/door_remote/key
	desc = "Обычный немного ржавый ключ."
	icon = 'modular_ss220/objects/icons/key.dmi'
	icon_state = "key"
	/// Are you already using the key?
	var/busy = FALSE
	/// How fast does the key open an airlock.
	var/hack_speed = 1 SECONDS

/obj/item/door_remote/key/attack_self(mob/user)
	return

/obj/item/door_remote/key/afterattack(obj/machinery/door/airlock/attacked_airlock, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(attacked_airlock))
		return

	if(HAS_TRAIT(attacked_airlock, TRAIT_CMAGGED))
		to_chat(user, span_danger("[src] не вставляется в панель доступа [attacked_airlock], тут повсюду слизь!"))
		return

	if(attacked_airlock.is_special)
		to_chat(user, span_danger("[src] не помещается в панель доступа [attacked_airlock]!"))
		return

	if(!attacked_airlock.arePowerSystemsOn())
		to_chat(user, span_danger("[attacked_airlock] без питания!"))
		return

	if(busy)
		to_chat(user, span_warning("Ты уже используешь [src] на панели доступа [attacked_airlock]!"))
		return

	playsound(src, 'sound/items/keyring_unlock.ogg', 50)
	attacked_airlock.add_fingerprint(user)

	busy = TRUE
	if(!do_after(user, hack_speed, target = attacked_airlock, progress = 1))
		busy = FALSE
		return
	busy = FALSE

	if(!attacked_airlock.check_access(ID))
		to_chat(user, span_danger("[src] похоже не подходит к панели доступа [attacked_airlock]!"))
		return

	if(!attacked_airlock.density)
		attacked_airlock.close()
		return
	attacked_airlock.open()

/obj/item/door_remote/key/engineer
	name = "\proper ключ от инженерного отдела"
	icon_state = "eng"
	additional_access = list(ACCESS_ENGINE,ACCESS_CONSTRUCTION)

/obj/item/door_remote/key/medical
	name = "\proper ключ от медицинского отдела"
	icon_state = "med"
	additional_access = list(ACCESS_MEDICAL)

/obj/item/door_remote/key/supply
	name = "\proper ключ от отдела снабжения"
	icon_state = "supply"
	additional_access = list(ACCESS_CARGO, ACCESS_MINING)

/obj/item/door_remote/key/rnd
	name = "\proper ключ от отдела исследований"
	icon_state = "rnd"
	additional_access = list(ACCESS_RESEARCH)

/obj/item/door_remote/key/sec
	name = "\proper ключ от отдела службы безопасности"
	icon_state = "sec"
	additional_access = list(ACCESS_SEC_DOORS)

/obj/item/door_remote/key/service
	name = "\proper ключ от отдела сервиса"
	icon_state = "service"
	additional_access = list(ACCESS_KITCHEN, ACCESS_BAR, ACCESS_HYDROPONICS, ACCESS_JANITOR)

/obj/item/door_remote/key/command
	name = "\proper ключ командования"
	icon_state = "com"
	additional_access = list(ACCESS_HEADS)

/obj/item/storage/box/keys
	name = "коробка с ключами"
	desc = "Коробка с ключами к отделам. Имеют неполный доступ к шлюзам."

/obj/item/storage/box/keys/populate_contents()
	new /obj/item/door_remote/key/sec(src)
	new /obj/item/door_remote/key/sec(src)
	new /obj/item/door_remote/key/supply(src)
	new /obj/item/door_remote/key/supply(src)
	new /obj/item/door_remote/key/service(src)
	new /obj/item/door_remote/key/service(src)
	new /obj/item/door_remote/key/engineer(src)
	new /obj/item/door_remote/key/engineer(src)
	new /obj/item/door_remote/key/rnd(src)
	new /obj/item/door_remote/key/rnd(src)
	new /obj/item/door_remote/key/command(src)
	new /obj/item/door_remote/key/command(src)
	new /obj/item/door_remote/key/medical(src)
	new /obj/item/door_remote/key/medical(src)

