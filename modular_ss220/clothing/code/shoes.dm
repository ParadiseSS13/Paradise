/datum/action/item_action/change_color
	name = "Change color"

/obj/item/clothing/shoes/black/neon
	name = "неоновые кросовки"
	desc = "Пара чёрных кросовок с светодиодными вставками."
	icon = 'modular_ss220/clothing/icons/object/shoes.dmi'
	icon_state = "neon"
	icon_override = 'modular_ss220/clothing/icons/mob/shoes.dmi'
	lefthand_file = 'modular_ss220/clothing/icons/inhands/left_hand.dmi'
	righthand_file = 'modular_ss220/clothing/icons/inhands/right_hand.dmi'
	actions_types = list(/datum/action/item_action/toggle_light, /datum/action/item_action/change_color)
	dyeable = FALSE
	color = null
	var/glow_active = FALSE
	var/brightness_on = 2

/obj/item/clothing/shoes/black/neon/attack_self(mob/living/user)
	var/choice = tgui_input_list(user, "Что вы хотите сделать?", "Неоновые кросовки", list("Переключить подсветку", "Сменить цвет"))
	switch(choice)
		if("Переключить подсветку")
			turn_glow()
		if("Сменить цвет")
			change_color()

/obj/item/clothing/shoes/black/neon/update_icon_state()
	. = ..()

/obj/item/clothing/shoes/black/neon/proc/turn_glow()
	if(!glow_active)
		set_light(brightness_on)
		var/mutable_appearance/neon_overlay = mutable_appearance('modular_ss220/clothing/icons/mob/shoes.dmi',"neon_overlay")
		neon_overlay.color = color
		add_overlay(neon_overlay)
		glow_active = TRUE
	else
		set_light(0)
		cut_overlays()
		glow_active = FALSE
	update_icon_state()

/obj/item/clothing/shoes/black/neon/proc/change_color(mob/living/user as mob)
	var/temp = input(usr, "Пожалуйста, выберите цвет.", "Цвет кросовок") as color
	color = temp
	light_color = temp
	update_icon_state()

/obj/item/clothing/shoes/black/neon/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/change_color)
		change_color()
	else if(actiontype == /datum/action/item_action/toggle_light)
		turn_glow()

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
