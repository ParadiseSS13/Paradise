/* Datums */
/datum/action/item_action/change_color
	name = "Change Color"

/* Neon Shoes */
/obj/item/clothing/shoes/black/neon
	name = "неоновые кроссовки"
	desc = "Пара чёрных кроссовок с светодиодными вставками."
	icon = 'modular_ss220/clothing/icons/object/shoes.dmi'
	icon_state = "neon"
	icon_override = 'modular_ss220/clothing/icons/mob/shoes.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	actions_types = list(/datum/action/item_action/toggle_light, /datum/action/item_action/change_color)
	dyeable = FALSE
	color = null
	/// Does it emit light?
	var/glow_active = FALSE
	/// Neon overlay that applies on mob
	var/mutable_appearance/neon_overlay

/obj/item/clothing/shoes/black/neon/ui_action_click(mob/user, actiontype)
	switch(actiontype)
		if(/datum/action/item_action/change_color)
			change_color(user)
		if(/datum/action/item_action/toggle_light)
			toggle_glow(user)

/obj/item/clothing/shoes/black/neon/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Что вы хотите сделать?", "Неоновые кроссовки", list("Переключить подсветку", "Сменить цвет"))
	switch(choice)
		if("Переключить подсветку")
			toggle_glow(user)
		if("Сменить цвет")
			change_color(user)

/obj/item/clothing/shoes/black/neon/equipped(mob/user, slot)
	. = ..()
	if(!neon_overlay && glow_active && slot == SLOT_HUD_SHOES)
		apply_neon_overlay(user)

/obj/item/clothing/shoes/black/neon/dropped(mob/user)
	. = ..()
	if(neon_overlay)
		remove_neon_overlay(user)

/obj/item/clothing/shoes/black/neon/Destroy()
	var/mob/living/user
	if(neon_overlay)
		remove_neon_overlay(user)
	return ..()

/// Applies neon overlay and gets color on it
/obj/item/clothing/shoes/black/neon/proc/apply_neon_overlay(mob/user)
	if(!user)
		return
	neon_overlay = mutable_appearance('modular_ss220/clothing/icons/mob/shoes.dmi', "neon_overlay")
	neon_overlay.color = color
	user.add_overlay(neon_overlay)

/// Completely removes the neon overlay
/obj/item/clothing/shoes/black/neon/proc/remove_neon_overlay(mob/user)
	if(!user)
		return
	user.cut_overlay(neon_overlay)
	QDEL_NULL(neon_overlay)

/// Reloads neon overlay (usually used after a color change)
/obj/item/clothing/shoes/black/neon/proc/reload_neon_overlay(mob/user)
	if(!user)
		return
	if(!neon_overlay)
		return

	remove_neon_overlay(user)
	if(user.get_item_by_slot(SLOT_HUD_SHOES))
		apply_neon_overlay(user)

/// Toggles neon overlay and light emit
/obj/item/clothing/shoes/black/neon/proc/toggle_glow(mob/user)
	if(!user)
		return
	// Toggle neon overlay
	if(!glow_active && user.get_item_by_slot(SLOT_HUD_SHOES))
		apply_neon_overlay(user)
	else if(neon_overlay)
		remove_neon_overlay(user)
	// Toggle light emit
	if(!glow_active)
		set_light(2)
		glow_active = TRUE
	else
		set_light(0)
		glow_active = FALSE

	update_icon_state()

/// Opens user input for changing neon color
/obj/item/clothing/shoes/black/neon/proc/change_color(mob/user)
	var/temp = input(user, "Пожалуйста, выберите цвет.", "Цвет кроссовок") as color
	color = temp
	light_color = temp
	reload_neon_overlay(user)
	update_icon_state()

/* Shark Shoes */
/obj/item/clothing/shoes/shark
	name = "акульи тапочки"
	desc = "Эти тапочки сделаны из акульей кожи, или нет?"
	icon = 'modular_ss220/clothing/icons/object/shoes.dmi'
	icon_state = "shark"
	icon_override = 'modular_ss220/clothing/icons/mob/shoes.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'

/obj/item/clothing/shoes/shark/light
	name = "светло-голубые акульи тапочки"
	icon_state = "shark_light"

/obj/item/clothing/shoes/clown_shoes/moffers
	name = "moffers"
	desc = "Ни одна моль не пострадала во время создания этих ботинок."
	icon = 'modular_ss220/clothing/icons/object/shoes.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	icon_state = "moffers"
	item_state = "moffers"
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/shoes.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/shoes.dmi',
	)

/obj/item/clothing/shoes/clown_shoes/moffers/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('modular_ss220/clothing/sounds/moffstep01.ogg' = 1), 50, falloff_exponent = 20)

/datum/crafting_recipe/moffers
	name = "Moffers"
	reqs = list(
		/obj/item/clothing/shoes/clown_shoes = 1,
		/obj/item/stack/sheet/animalhide/mothroach = 2,
	)
	result = list(/obj/item/clothing/shoes/clown_shoes/moffers = 1)
	blacklist = list(
		/obj/item/clothing/shoes/clown_shoes/false_cluwne_shoes,
		/obj/item/clothing/shoes/clown_shoes/magical,
		/obj/item/clothing/shoes/clown_shoes/moffers,
		/obj/item/clothing/shoes/clown_shoes/nodrop,
		/obj/item/clothing/shoes/clown_shoes/slippers,
	)
	category = CAT_CLOTHING

/* EI shoes */
/obj/item/clothing/shoes/ei_shoes
	name = "ботинки Gold On Black"
	desc = "Черный ботинки в классическом стиле с легким золотым напылением от корпорации Etamin Industry."
	icon = 'modular_ss220/clothing/icons/object/shoes.dmi'
	icon_state = "ei_shoes"
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/shoes.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/shoes.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/shoes.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/shoes.dmi',
	)
