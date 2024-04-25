/obj/item/card/id
	var/skinable = TRUE
	var/obj/item/id_skin/skin_applied = null

/obj/item/card/id/guest
	skinable = FALSE

/obj/item/card/id/data
	skinable = FALSE

/obj/item/card/id/away
	skinable = FALSE

/obj/item/card/id/thunderdome
	skinable = FALSE

/obj/item/card/id/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(!istype(item, /obj/item/id_skin))
		return .

	return apply_skin(item, user)

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(skin_applied)
		. += span_notice("Нажмите <b>Alt-Click</b> на карту, чтобы снять наклейку.")

/obj/item/card/id/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained())
		to_chat(user, span_warning("У вас нет возможности снять наклейку!"))
		return

	if(!skin_applied)
		to_chat(user, span_warning("На карте нет наклейки!"))
		return

	if(user.a_intent == INTENT_HARM)
		to_chat(user, span_warning("Вы срываете наклейку с карты!"))
		playsound(user.loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
		remove_skin(delete = TRUE)
	else
		to_chat(user, span_notice("Вы начинаете аккуратно снимать наклейку с карты."))
		if(!do_after(user, 5 SECONDS, target = src, progress = TRUE))
			return FALSE

		to_chat(user, span_notice("Вы сняли наклейку с карты."))

		if(!user.get_active_hand() && Adjacent(user))
			user.put_in_hands(skin_applied)
		else
			skin_applied.forceMove(get_turf(user))
		remove_skin()

/obj/item/card/id/proc/apply_skin(obj/item/id_skin/skin, mob/user)
	if(skin_applied)
		to_chat(usr, span_warning("На карте уже есть наклейка, сначала соскребите её!"))
		return FALSE

	if(!skinable)
		to_chat(usr, span_warning("Наклейка не подходит для [src]!"))
		return FALSE

	to_chat(user, span_notice("Вы начинаете наносить наклейку на карту."))
	if(!do_after(user, 2 SECONDS, target = src, progress = TRUE, allow_moving = TRUE))
		return FALSE

	var/mutable_appearance/card_skin = mutable_appearance(skin.icon, skin.icon_state)
	card_skin.color = skin.color
	to_chat(user, span_notice("Вы наклеили [skin.pronoun_name] на [src]."))
	desc += "<br>[skin.info]"
	user.drop_item()
	skin.forceMove(src)
	skin_applied = skin
	add_overlay(card_skin)
	return TRUE

/obj/item/card/id/proc/remove_skin(delete = FALSE)
	if(delete)
		qdel(skin_applied)
	skin_applied = null
	desc = initial(desc)
	overlays.Cut()

/obj/item/id_skin
	name = "\improper наклейка на карту"
	desc = "Этим можно изменить внешний вид своей карты! Покажи службе безопасности какой ты стильный."
	icon = 'modular_ss220/objects/icons/id_skins.dmi'
	icon_state = ""
	var/pronoun_name = "наклейку"
	var/info = "На ней наклейка."

/obj/item/id_skin/Initialize(mapload)
	. = ..()
	pixel_y = rand(-5, 5)
	pixel_x = rand(-5, 5)

/obj/item/id_skin/colored
	name = "\improper голо-наклейка на карту"
	desc = "Голографическая наклейка на карту. Вы можете выбрать цвет который она примет."
	icon_state = "colored"
	pronoun_name = "голо-наклейку"
	info = "На ней голо-наклейка."
	var/static/list/color_list = list(
		"Красный" = LIGHT_COLOR_RED,
		"Зелёный" = LIGHT_COLOR_GREEN,
		"Синий" = LIGHT_COLOR_LIGHTBLUE,
		"Жёлтый" = LIGHT_COLOR_HOLY_MAGIC,
		"Оранжевый" = LIGHT_COLOR_ORANGE,
		"Фиолетовый" = LIGHT_COLOR_LAVENDER,
		"Голубой" = LIGHT_COLOR_LIGHT_CYAN,
		"Циановый" = LIGHT_COLOR_CYAN,
		"Аквамариновый" = LIGHT_COLOR_BLUEGREEN,
		"Розовый" = LIGHT_COLOR_PINK)

/obj/item/id_skin/colored/Initialize(mapload)
	. = ..()
	if(color)
		return .

	color = color_list[pick(color_list)]

/obj/item/id_skin/colored/attack_self(mob/living)
	var/choice = tgui_input_list(usr, "Какой цвет предпочитаете?", "Выбор цвета", list("Выбрать предустановленный", "Выбрать вручную"))
	if(!choice)
		return
	switch(choice)
		if("Выбрать предустановленный")
			choice = tgui_input_list(usr, "Выберите цвет", "Выбор цвета", color_list)
			var/color_to_set = color_list[choice]
			if(!color_to_set)
				return

			color = color_to_set

		if("Выбрать вручную")
			color = input(usr,"Выберите цвет") as color
