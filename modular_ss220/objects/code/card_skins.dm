/obj/item/card/id
	var/have_skin = FALSE
	var/skinable = TRUE

/obj/item/card/id/guest
	skinable = FALSE

/obj/item/card/id/data
	skinable = FALSE

/obj/item/card/id/away
	skinable = FALSE

/obj/item/card/id/thunderdome
	skinable = FALSE

/obj/item/card/id/attackby(obj/item/item as obj, mob/user as mob, params)
	. = ..()
	if(istype(item, /obj/item/id_skin))
		if(have_skin)
			to_chat(usr, span_warning("На карте уже есть наклейка, сначала соскребите её!"))
			return
		if(!skinable)
			to_chat(usr, span_warning("Наклейка не подходит для [src]!"))
			return
		else
			var/obj/item/id_skin/skin = item
			var/mutable_appearance/card_skin = mutable_appearance(skin.icon, skin.icon_state)
			card_skin.color = skin.color
			to_chat(user, "Вы наклеили [skin.pronoun_name] на [src].")
			desc = initial(desc)
			desc += "<br>[skin.info]"
			add_overlay(card_skin)
			have_skin = TRUE
			qdel(skin)
			return

/obj/item/card/id/verb/remove_skin()
	set name = "Соскрести наклейку"
	set category = "Object"
	set src in range(0)

	if(usr.stat || HAS_TRAIT(usr, TRAIT_UI_BLOCKED) || usr.restrained())
		return

	if(have_skin)
		to_chat(usr, span_notice("Вы начинаете соскребать наклейку с карты."))
		if(do_after(usr, 5 SECONDS, target = src, progress = TRUE))
			to_chat(usr, span_notice("Вы соскребаете наклейку с карты."))
			src.overlays.Cut()
			have_skin = FALSE
	else
		to_chat(usr, span_warning("На карте нет наклейки!"))

/obj/item/id_skin
	name = "\improper наклейка на карту"
	desc = "Этим можно изменить внешний вид своей карты! Покажи службе безопасности какой ты стильный."
	icon = 'modular_ss220/objects/icons/id_skins.dmi'
	icon_state = ""
	var/pronoun_name = "наклейку"
	var/info = "На ней наклейка."

/obj/item/id_skin/colored
	name = "\improper голо-наклейка на карту"
	desc = "Голографическая наклейка на карту, вы можете выбрать цвет который она примет. После наклеивания на карту, сменить цвет нельзя!"
	icon_state = "colored"
	pronoun_name = "голо-наклейку"
	info = "На ней голо-наклейка."
	var/list/color_list = list("Красный", "Зелёный", "Синий", "Жёлтый", "Оранжевый", "Фиолетовый", "Голубой", "Циановый", "Аквамариновый", "Розовый")

/obj/item/id_skin/colored/shiny
	name = "\improper металлическая голо-наклейка"
	icon_state = "colored_shiny"

/obj/item/id_skin/colored/attack_self(mob/living/user as mob)
	var/choice = input(user, "Какой цвет предпочитаете?", "Выбор цвета") as null|anything in list("Выбрать предустановленный", "Выбрать вручную")
	if(!choice)
		return
	switch(choice)
		if("Выбрать предустановленный")
			choice = input(user, "Выберите цвет", "Выбор цвета") as null|anything in color_list
			if(!choice)
				return
			switch(choice)
				if("Красный")
					color = LIGHT_COLOR_RED
				if("Зелёный")
					color = LIGHT_COLOR_GREEN
				if("Синий")
					color = LIGHT_COLOR_LIGHTBLUE
				if("Жёлтый")
					color = LIGHT_COLOR_HOLY_MAGIC
				if("Оранжевый")
					color = LIGHT_COLOR_ORANGE
				if("Фиолетовый")
					color = LIGHT_COLOR_LAVENDER
				if("Голубой")
					color = LIGHT_COLOR_LIGHT_CYAN
				if("Циановый")
					color = LIGHT_COLOR_CYAN
				if("Аквамариновый")
					color = LIGHT_COLOR_BLUEGREEN
				if("Розовый")
					color = LIGHT_COLOR_PINK
		if("Выбрать вручную")
			color = input(user,"Выберите цвет") as color

/obj/item/id_skin/prisoner
	name = "\improper тюремная наклейка на карту"
	icon_state = "prisoner"
	pronoun_name = "тюремную наклейку"
	info = "На ней тюремная наклейка."

/obj/item/id_skin/silver
	name = "\improper серебрянная наклейка на карту"
	icon_state = "silver"
	pronoun_name = "серебрянную наклейку"
	info = "На ней серебрянная наклейка."

/obj/item/id_skin/gold
	name = "\improper золотая наклейка на карту"
	icon_state = "gold"
	pronoun_name = "золотую наклейку"
	info = "На ней золотая наклейка."

/obj/item/id_skin/business
	name = "\improper бизнесменская наклейка на карту"
	icon_state = "business"
	pronoun_name = "бизнесменскую наклейку"
	info = "На ней бизнесменская наклейка."

/obj/item/id_skin/lifetime
	name = "\improper стильная наклейка на карту"
	icon_state = "lifetime"
	pronoun_name = "стильную наклейку"
	info = "На ней стильная наклейка."

/obj/item/id_skin/ussp
	name = "\improper коммунистическая наклейка на карту"
	icon_state = "ussp"
	pronoun_name = "коммунистическую наклейку"
	info = "На ней коммунистическая наклейка."

/obj/item/id_skin/clown
	name = "\improper клоунская наклейка на карту"
	icon_state = "clown"
	pronoun_name = "клоунскую наклейку"
	info = "На ней клоунская наклейка."

/obj/item/id_skin/rainbow
	name = "\improper радужная наклейка на карту"
	icon_state = "rainbow"
	pronoun_name = "радужную наклейку"
	info = "На ней радужная наклейка."

/obj/item/id_skin/space
	name = "\improper КОСМИЧЕСКАЯ наклейка на карту"
	icon_state = "space"
	pronoun_name = "КОСМИЧЕСКУЮ наклейку"
	info = "На ней КОСМИЧЕСКАЯ наклейка."
