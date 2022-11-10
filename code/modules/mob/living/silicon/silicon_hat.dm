/mob/living/silicon
	var/obj/item/inventory_head

	var/hat_offset_y = -3
	var/isCentered = FALSE //центрирован ли синтетик. Если нет, то шляпа будет растянута

	var/list/blacklisted_hats = list( //Запрещенные шляпы на ношение для боргов с большими головами
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
		/obj/item/clothing/head/cardborg
	)

	var/hat_icon_file = 'icons/mob/head.dmi'
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/canBeHatted = FALSE
	var/canWearBlacklistedHats = FALSE

/mob/living/silicon/robot/drone
	hat_offset_y = -15
	isCentered = TRUE
	canBeHatted = TRUE
	canWearBlacklistedHats = TRUE

/mob/living/silicon/robot/cogscarab
	hat_offset_y = -15
	isCentered = TRUE
	canBeHatted = TRUE

/mob/living/silicon/ai
	hat_offset_y = 3
	isCentered = TRUE
	canBeHatted = TRUE

/mob/living/silicon/robot/proc/robot_module_hat_offset(var/module)
	switch(module)
		//хуманоидные броботы с шляпами
		if("Engineering", "Miner_old", "JanBot2", "Medbot", "engineerrobot", "maximillion", "secborg", "Hydrobot")
			canBeHatted = FALSE
			hat_offset_y = -1
		if("Noble-CLN", "Noble-SRV", "Noble-DIG", "Noble-MED", "Noble-SEC", "Noble-ENG", "Noble-STD") //Высотой: 32 пикселя
			canBeHatted = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = 4
		if("droid-medical") //Высотой: 32 пикселя
			canBeHatted = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = 4
		if("droid-miner", "mk2", "mk3") //Высотой: 32 большая голова, шарообразные
			canBeHatted = TRUE
			isCentered = TRUE
			hat_offset_y = 3
		if("bloodhound", "nano_bloodhound", "syndie_bloodhound", "ertgamma")//Высотой: 31
			canBeHatted = TRUE
			hat_offset_y = 1
		if("Cricket-SEC", "Cricket-MEDI", "Cricket-JANI", "Cricket-ENGI", "Cricket-MINE", "Cricket-SERV") //Высотой: 31
			canBeHatted = TRUE
			hat_offset_y = 2
		if("droidcombat-shield", "droidcombat") //Высотой: 31
			canBeHatted = TRUE
			hat_alpha = 255
			hat_offset_y = 2
		if("droidcombat-roll")
			canBeHatted = TRUE
			hat_alpha = 0
			hat_offset_y = 2
		if("syndi-medi", "surgeon", "toiletbot") //Высотой: 30
			canBeHatted = TRUE
			isCentered = TRUE
			hat_offset_y = 1
		if("Security", "janitorrobot", "medicalrobot") //Высотой: 29
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -1
		if("Brobot", "Service", "robot+o+c", "robot_old", "securityrobot",	//Высотой: 28
			"rowtree-engineering", "rowtree-lucy", "rowtree-medical", "rowtree-security") //Бабоботы
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -1
		if("Miner", "lavaland")	//Высотой: 27
			canBeHatted = TRUE
			hat_offset_y = -1
		if("robot", "Standard", "Standard-Secy", "Standard-Medi", "Standard-Engi",
			"Standard-Jani", "Standard-Serv", "Standard-Mine", "xenoborg-state-a") //Высотой: 26
			canBeHatted = TRUE
			hat_offset_y = -3
		if("droid")	//Высотой: 25
			canBeHatted = TRUE
			isCentered = TRUE
			canWearBlacklistedHats = TRUE
			hat_offset_y = -3
		if("landmate", "syndi-engi") //Высотой: 24 пикселя макушка
			canBeHatted = TRUE
			hat_offset_y = -3
		if("mopgearrex") //Высотой: 22
			canBeHatted = TRUE
			hat_offset_y = -6

	if(inventory_head)
		if (!canBeHatted)
			remove_from_head(usr)
			return
		if (!canWearBlacklistedHats && is_type_in_list(inventory_head, blacklisted_hats))
			remove_from_head(usr)
			return

/mob/living/silicon/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/clothing/head) && user.a_intent == INTENT_HELP)
		place_on_head(user.get_active_hand(), user)
		return
	. = ..()

/mob/living/silicon/proc/hat_icons()
	if(inventory_head)
		overlays += get_hat_overlay()

/mob/living/silicon/Topic(href, href_list)
	if(..())
		return 1

	if(!(iscarbon(usr) || usr.incapacitated() || !Adjacent(usr)))
		usr << browse(null, "window=mob[UID()]")
		usr.unset_machine()
		return

	if (!canBeHatted)
		return 0

	if(href_list["remove_inv"])
		var/remove_from = href_list["remove_inv"]
		switch(remove_from)
			if("head")
				remove_from_head(usr)
		show_inv(usr)

	else if(href_list["add_inv"])
		var/add_to = href_list["add_inv"]
		switch(add_to)
			if("head")
				place_on_head(usr.get_active_hand(), usr)
		show_inv(usr)

	if(usr != src)
		return 1

/mob/living/silicon/regenerate_icons()
	overlays.Cut()
	..()

	if(inventory_head)
		var/image/head_icon

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
		if (!isCentered)
			borgI.transform = matrix(1.125, 0, 0.5, 0, 1, 0)
		return borgI

/mob/living/silicon/show_inv(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	user.set_machine(src)

	var/dat = 	{"<meta charset="UTF-8"><div align='center'><b>Inventory of [name]</b></div><p>"}
	dat += "<br><B>Head:</B> <A href='?src=[UID()];[inventory_head ? "remove_inv=head'>[inventory_head]" : "add_inv=head'>Nothing"]</A>"

	var/datum/browser/popup = new(user, "mob[UID()]", "[src]", 440, 250)
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] похлопывает по голове [src].</span>", "<span class='notice'>Вы положили руку на голову [src].</span>")
		if(flags_2 & HOLOGRAM_2)
			return 0
		return 0

	if(!istype(item_to_add, /obj/item/clothing/head/))
		to_chat(user, "<span class='warning'>[item_to_add] нельзя надеть на голову [src]!</span>")
		return 0

	if(!canBeHatted)
		to_chat(user, "<span class='warning'>[item_to_add] нельзя надеть на голову [src]! Похоже у него уже есть встроенная шляпа.</span>")
		return 0

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>Нельзя надеть больше одного головного убора на голову [src]!</span>")
		return 0

	if(user && !user.unEquip(item_to_add))
		to_chat(user, "<span class='warning'>[item_to_add] застрял в ваших руках, вы не можете его надеть на голову [src]!</span>")
		return 0

	if (!canWearBlacklistedHats && is_type_in_list(item_to_add, blacklisted_hats))
		to_chat(user, "<span class='warning'>[item_to_add] не помещается на голову [src]!</span>")
		return 0

	user.visible_message("<span class='notice'>[user] надевает [item_to_add] на голову [real_name].</span>",
		"<span class='notice'>Вы надеваете [item_to_add] на голову [real_name].</span>",
		"<span class='italics'>Вы слышите как что-то нацепили.</span>")
	item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()

	return 1

/mob/living/silicon/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(inventory_head.flags & NODROP)
			to_chat(user, "<span class='warning'>[inventory_head.name] застрял на голове [src]! Его невозможно снять!</span>")
			return TRUE

		to_chat(user, "<span class='warning'>Вы сняли [inventory_head.name] с головы [src].</span>")
		user.put_in_hands(inventory_head)

		null_hat()

		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>На голове [src] нет головного убора!</span>")
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

//Если вдруг кто-то захочет сразу спавнить боргов с шапками
/mob/living/silicon/New()
	..()
	regenerate_icons()

//Определяем шапочные свойства для сразу готовых боргов (синди-борги, борги дезсквад, дестроеры)
/mob/living/silicon/robot/New()
	..()
	robot_module_hat_offset(icon_state)
