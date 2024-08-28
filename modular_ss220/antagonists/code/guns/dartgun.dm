/obj/item/gun/syringe/dart_gun
	name = "dart gun"
	desc = "Компактный метатель дротиков для доставки химических коктейлей."
	icon = 'modular_ss220/antagonists/icons/guns/vox_guns.dmi'
	lefthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_ss220/antagonists/icons/guns/inhands/guns_righthand.dmi'
	icon_state = "dartgun"
	item_state = "dartgun"
	var/cartridge_overlay = "dartgun_cartridge_overlay"
	max_syringes = 5
	var/list/valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
		)
	var/valid_dart_type = /obj/item/reagent_containers/syringe/dart
	var/obj/item/storage/dart_cartridge/cartridge_loaded
	var/pixel_y_overlay_div = 5	// сколько у нас делений для спрайта оверлея ("Позиций")
	var/pixel_y_overlay_offset = 2 // на сколько пикселей смещаем оверлей при полном делении
	var/is_vox_private = FALSE

/obj/item/gun/syringe/dart_gun/pickup(mob/user)
	. = ..()
	if(!is_vox_private)
		is_vox_private = TRUE
		to_chat(user, span_notice("Оружие инициализировало вас, более никто кроме Воксов не сможет им воспользоваться."))

/obj/item/gun/syringe/dart_gun/afterattack(atom/target, mob/living/user, flag, params)
	if(is_vox_private && !isvox(user))
		if(prob(20))
			to_chat(user, span_notice("Оружие отказывается с вами работать и не активируется."))
		return FALSE
	. = ..()

/obj/item/gun/syringe/dart_gun/Destroy()
	qdel(cartridge_loaded)
	. = ..()

/obj/item/gun/syringe/dart_gun/update_overlays()
	. = ..()
	if(cartridge_loaded)
		var/pixel_y_offset = 0
		var/num = length(syringes)
		if(num)
			pixel_y_offset = -(pixel_y_overlay_div - pixel_y_overlay_div * num / max_syringes) * pixel_y_overlay_offset
		. += image(icon = icon, icon_state = cartridge_overlay,  pixel_y = pixel_y_offset)
		if(cartridge_loaded.overlay_state_color)
			. += image(icon = icon, icon_state = "[cartridge_overlay]_[cartridge_loaded.overlay_state_color]",  pixel_y = pixel_y_offset)
		. += icon_state

/obj/item/gun/syringe/dart_gun/attackby(obj/item/A, mob/user, params, show_msg)
	if(cartridge_loaded)
		for(var/hold_type in cartridge_loaded.can_hold)
			if(!istype(A, hold_type))
				continue
			if(insert_syringe_to_cartridge(A) && user && user.unEquip(A))
				to_chat(user, span_notice("Вы загрузили [A] в [cartridge_loaded] в [src]!"))
				return ..()
		to_chat(user, "Картридж [src] полон!")
		return FALSE
	else
		for(var/cartridge_type in valid_cartridge_types)
			if(istype(A, cartridge_type))
				if("[A.type]" != "[cartridge_type]")	// Исключаем сабтипы
					continue
				if(user && !user.unEquip(A))
					return TRUE
				to_chat(user, span_notice("Вы вставили [A] в [src]!"))
				cartridge_load(A)
				return ..()
	if(!chambered.BB && istype(A, valid_dart_type) && length(syringes) < max_syringes)
		return ..()
	if(user)
		to_chat(user, "[A] не вмещается в [src]!")
	return TRUE

/obj/item/gun/syringe/dart_gun/proc/insert_syringe_to_cartridge(obj/item/syringe)
	if(length(syringes) >= max_syringes)
		return FALSE
	syringe.forceMove(cartridge_loaded)
	syringes.Add(syringe)
	process_chamber()
	return TRUE

/obj/item/gun/syringe/dart_gun/proc/cartridge_load(obj/item/A, mob/user)
	A.forceMove(src)
	cartridge_loaded = A
	for(var/obj/item/I in A.contents)
		syringes.Add(I)
	process_chamber()

/obj/item/gun/syringe/dart_gun/proc/cartridge_unload(mob/user)
	if(!cartridge_loaded)
		return FALSE
	user.put_in_hands(cartridge_loaded)
	//user.unEquip(cartridge_loaded)
	syringes.Cut()
	cartridge_loaded.update_icon()
	cartridge_loaded = null
	update_icon()

/obj/item/gun/syringe/dart_gun/attack_self(mob/living/user)
	if(cartridge_loaded)
		playsound(src, 'modular_ss220/antagonists/sound/guns/m79_unload.ogg', 50, 1)
		to_chat(user, span_notice("Вы выгрузили [cartridge_loaded] с [src]."))
		cartridge_unload(user)
		process_chamber()
		return TRUE
	return ..()

/obj/item/gun/syringe/dart_gun/process_chamber()
	. = ..()
	if(!cartridge_loaded)
		update_icon()
		return

	// Вышвыриваем картридж
	if(!length(syringes))
		var/turf/current_turf = get_turf(src)
		cartridge_loaded.forceMove(current_turf)
		cartridge_loaded.throw_at(target = current_turf, range = 3, speed = 1)
		cartridge_loaded.pixel_x = rand(-10, 10)
		cartridge_loaded.pixel_y = rand(-4, 16)
		cartridge_loaded.update_icon()
		cartridge_loaded = null
		update_icon()
		playsound(src, 'modular_ss220/antagonists/sound/guns/m79_break_open.ogg', 50, 1)
		return

	playsound(src, 'modular_ss220/antagonists/sound/guns/m79_reload.ogg', 50, 1)
	update_icon()


// ============== Шприцеметы ==============

/obj/item/gun/syringe/dart_gun/extended
	name = "extended dart gun"
	desc = "Расширенный метатель дротиков и шприцов для доставки химических коктейлей."
	icon_state = "dartgun_ext"
	valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
		/obj/item/storage/dart_cartridge/extended
		)

/obj/item/gun/syringe/dart_gun/big
	name = "capacious dart gun"
	desc = "Вместительный метатель дротиков для доставки химических коктейлей."
	icon_state = "dartgun_big"
	max_syringes = 10
	valid_cartridge_types = list(
		/obj/item/storage/dart_cartridge,
		/obj/item/storage/dart_cartridge/combat,
		/obj/item/storage/dart_cartridge/drugs,
		/obj/item/storage/dart_cartridge/medical,
		/obj/item/storage/dart_cartridge/pain,
		/obj/item/storage/dart_cartridge/big,
		/obj/item/storage/dart_cartridge/big/random
		)
