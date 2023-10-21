/mob/living/silicon
	var/obj/item/inventory_head

	var/hat_offset_y = -3
	var/is_centered = FALSE // центрирован ли синтетик. Если нет, то шляпа будет растянута

	var/list/blacklisted_hats = list( // Запрещенные шляпы на ношение для боргов с большими головами
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/snowman,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bomb_hood,
		/obj/item/clothing/head/blob,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/corgi,
		/obj/item/clothing/head/cueball,
		/obj/item/clothing/head/hardhat/pumpkinhead,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/papersack,
		/obj/item/clothing/head/human_head,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/hardhat/reindeer,
		/obj/item/clothing/head/cardborg,
	)

	var/hat_icon_file = 'icons/mob/clothing/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/can_be_hatted = FALSE
	var/can_wear_blacklisted_hats = FALSE

/mob/living/silicon/robot/drone
	hat_offset_y = -15
	is_centered = TRUE
	can_be_hatted = TRUE
	can_wear_blacklisted_hats = TRUE

/mob/living/silicon/ai
	hat_offset_y = 3
	is_centered = TRUE
	can_be_hatted = TRUE

/mob/living/silicon/robot/proc/robot_module_hat_offset(module)
	switch(module)
		// хуманоидные броботы с шляпами
		if("Engineering", "Miner_old", "JanBot2", "Medbot", "engineerrobot", "maximillion", "secborg", "Hydrobot")
			can_be_hatted = FALSE
			hat_offset_y = -1
		if("Noble-CLN", "Noble-SRV", "Noble-DIG", "Noble-MED", "Noble-SEC", "Noble-ENG", "Noble-STD") //Высотой: 32 пикселя
			can_be_hatted = TRUE
			can_wear_blacklisted_hats = TRUE
			hat_offset_y = 4
		if("droid-medical") // Высотой: 32 пикселя
			can_be_hatted = TRUE
			can_wear_blacklisted_hats = TRUE
			hat_offset_y = 4
		if("droid-miner", "mk2", "mk3") // Высотой: 32 большая голова, шарообразные
			can_be_hatted = TRUE
			is_centered = TRUE
			hat_offset_y = 3
		if("bloodhound", "nano_bloodhound", "syndie_bloodhound", "ertgamma")//Высотой: 31
			can_be_hatted = TRUE
			hat_offset_y = 1
		if("Cricket-SEC", "Cricket-MEDI", "Cricket-JANI", "Cricket-ENGI", "Cricket-MINE", "Cricket-SERV") //Высотой: 31
			can_be_hatted = TRUE
			hat_offset_y = 2
		if("droidcombat-shield", "droidcombat") // Высотой: 31
			can_be_hatted = TRUE
			hat_alpha = 255
			hat_offset_y = 2
		if("droidcombat-roll")
			can_be_hatted = TRUE
			hat_alpha = 0
			hat_offset_y = 2
		if("syndi-medi", "surgeon", "toiletbot") // Высотой: 30
			can_be_hatted = TRUE
			is_centered = TRUE
			hat_offset_y = 1
		if("Security", "janitorrobot", "medicalrobot") // Высотой: 29
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_blacklisted_hats = TRUE
			hat_offset_y = -1
		if("Brobot", "Service", "robot+o+c", "robot_old", "securityrobot",	//Высотой: 28
			"rowtree-engineering", "rowtree-lucy", "rowtree-medical", "rowtree-security") //Бабоботы
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_blacklisted_hats = TRUE
			hat_offset_y = -1
		if("Miner", "lavaland")	// Высотой: 27
			can_be_hatted = TRUE
			hat_offset_y = -1
		if("robot", "Standard", "Standard-Secy", "Standard-Medi", "Standard-Engi",
			"Standard-Jani", "Standard-Serv", "Standard-Mine", "xenoborg-state-a") //Высотой: 26
			can_be_hatted = TRUE
			hat_offset_y = -3
		if("droid")	// Высотой: 25
			can_be_hatted = TRUE
			is_centered = TRUE
			can_wear_blacklisted_hats = TRUE
			hat_offset_y = -3
		if("landmate", "syndi-engi") // Высотой: 24 пикселя макушка
			can_be_hatted = TRUE
			hat_offset_y = -3
		if("mopgearrex") // Высотой: 22
			can_be_hatted = TRUE
			hat_offset_y = -6

	if(inventory_head)
		if (!can_be_hatted)
			remove_from_head(usr)
			return
		if (!can_wear_blacklisted_hats && is_type_in_list(inventory_head, blacklisted_hats))
			remove_from_head(usr)
			return

/mob/living/silicon/proc/hat_icons()
	if(inventory_head)
		overlays += get_hat_overlay()

/mob/living/silicon/regenerate_icons()
	overlays.Cut()
	..()

	if(inventory_head)
		var/image/head_icon

		if(inventory_head.icon_override)	// Для модульных шапок
			hat_icon_file = inventory_head.icon_override
		if(!hat_icon_state)
			hat_icon_state = inventory_head.icon_state
		if(!hat_alpha)
			hat_alpha = inventory_head.alpha
		if(!hat_color)
			hat_color = inventory_head.color

		head_icon = get_hat_overlay()

		add_overlay(head_icon)

/mob/living/silicon/proc/get_hat_overlay()
	if(hat_icon_file && hat_icon_state)
		var/image/borgI = image(hat_icon_file, hat_icon_state)
		borgI.alpha = hat_alpha
		borgI.color = hat_color
		borgI.pixel_y = hat_offset_y
		if (!is_centered)
			borgI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
		return borgI

/mob/living/silicon/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(!item_to_add)
		user.visible_message(span_notice("[user] похлопывает по голове [src]."), span_notice("Вы положили руку на голову [src]."))
		if(flags_2 & HOLOGRAM_2)
			return FALSE
		return FALSE

	if(!istype(item_to_add, /obj/item/clothing/head/))
		to_chat(user, span_warning("[item_to_add] нельзя надеть на голову [src]!"))
		return FALSE

	if(!can_be_hatted)
		to_chat(user, span_warning("[item_to_add] нельзя надеть на голову [src]! Похоже у него уже есть встроенная шляпа."))
		return FALSE

	if(inventory_head)
		if(user)
			to_chat(user, span_warning("Нельзя надеть больше одного головного убора на голову [src]!"))
		return FALSE

	if(user && !user.unEquip(item_to_add))
		to_chat(user, span_warning("[item_to_add] застрял в ваших руках, вы не можете его надеть на голову [src]!"))
		return FALSE

	if (!can_wear_blacklisted_hats && is_type_in_list(item_to_add, blacklisted_hats))
		to_chat(user, span_warning("[item_to_add] не помещается на голову [src]!"))
		return FALSE

	user.visible_message(span_notice("[user] надевает [item_to_add] на голову [real_name]."),
		span_notice("Вы надеваете [item_to_add] на голову [real_name]."),
		span_italics("Вы слышите как что-то нацепили."))
	item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()

	return TRUE

/mob/living/silicon/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(inventory_head.flags & NODROP)
			to_chat(user, span_warning("[inventory_head.name] застрял на головном корпусе [src]! Его невозможно снять!"))
			return TRUE

		to_chat(user, span_warning("Вы сняли [inventory_head.name] с головного корпуса [src]."))
		user.put_in_hands(inventory_head)

		null_hat()

		regenerate_icons()
	else
		to_chat(user, span_warning("На головном корпусе [src] нет головного убора!"))
		return FALSE

	return TRUE

/mob/living/silicon/proc/drop_hat()
	if(inventory_head)
		unEquip(inventory_head)
		null_hat()
		regenerate_icons()

/mob/living/silicon/proc/null_hat()
	inventory_head = null
	hat_icon_state = null
	hat_alpha = null
	hat_color = null
