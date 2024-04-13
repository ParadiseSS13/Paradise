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

/obj/item/id_skin/donut
	name = "\improper пончиковая наклейка на карту"
	icon_state = "donut"
	pronoun_name = "пончиковую наклейку"
	info = "На ней пончиковая наклейка. С глазурью!"

/obj/item/id_skin/silver
	name = "\improper серебрянная наклейка на карту"
	icon_state = "silver"
	pronoun_name = "серебрянную наклейку"
	info = "На ней серебрянная наклейка."

/obj/item/id_skin/colored/silver
	name = "\improper серебрянная голо-наклейка"
	desc = "Голографическая наклейка на карту, изготовленная из специального материала, похожего на серебро. Вы можете выбрать цвет который она примет."
	pronoun_name = "серебрянную голо-наклейку"
	icon_state = "colored_shiny"
	info = "На ней металлическая голо-наклейка."

/obj/item/id_skin/gold
	name = "\improper золотая наклейка на карту"
	desc = "Можно продать какому-то дураку за баснословные деньги. Ой..."
	icon_state = "gold"
	pronoun_name = "золотую наклейку"
	info = "На ней золотая наклейка."

/obj/item/id_skin/business
	name = "\improper бизнесменская наклейка на карту"
	desc = "Осталось раздобыть портмоне и стильный костюм."
	icon_state = "business"
	pronoun_name = "бизнесменскую наклейку"
	info = "На ней бизнесменская наклейка."

/obj/item/id_skin/lifetime
	name = "\improper стильная наклейка на карту"
	desc = "Ничего особенного, но что-то в этом есть..."
	icon_state = "lifetime"
	pronoun_name = "стильную наклейку"
	info = "На ней стильная наклейка."

/obj/item/id_skin/ussp
	name = "\improper коммунистическая наклейка на карту"
	desc = "Партия гордится вами! Возьмите своя миска-рис в ближайшем баре."
	icon_state = "ussp"
	pronoun_name = "коммунистическую наклейку"
	info = "На ней коммунистическая наклейка."

/obj/item/id_skin/clown
	name = "\improper клоунская наклейка на карту"
	desc = "HONK!"
	icon_state = "clown"
	pronoun_name = "клоунскую наклейку"
	info = "На ней клоунская наклейка. HONK!"

/obj/item/id_skin/neon
	name = "\improper неоновая наклейка на карту"
	desc = "Неоновая наклейка в цианово-розовых цветах."
	icon_state = "neon"
	pronoun_name = "неоновую наклейку"
	info = "Кажется будто она светится."

/obj/item/id_skin/colored/neon
	name = "\improper неоновая голо-наклейка на карту"
	desc = "Какая же она яркая... Ещё и цвета меняет!"
	icon_state = "colored_neon"
	pronoun_name = "неоновую наклейку"
	info = "Кажется будто она светится."

/obj/item/id_skin/missing
	name = "\improper чёрно-розовая наклейка на карту"
	desc = "Текстура пропала..."
	icon_state = "missing"
	pronoun_name = "чёрно-розовую наклейку"
	info = "А где?"

/obj/item/id_skin/ouija
	name = "\improper Уиджи наклейка на карту"
	desc = "Ходят легенты, что тот кто наклеит это на карту, может общаться с духами..."
	icon_state = "ouija"
	pronoun_name = "наклейку в виде доски Уиджи"
	info = "Умеет ли он общаться с призраками?"

/obj/item/id_skin/paradise
	name = "\improper пляжная наклейка на карту"
	desc = "Хола!"
	icon_state = "paradise"
	pronoun_name = "пляжную наклейку"
	info = "На ней пляжная наклейка."

/obj/item/id_skin/rainbow
	name = "\improper радужная наклейка на карту"
	desc = "Переливается всеми цветами радуги!"
	icon_state = "rainbow"
	pronoun_name = "радужную наклейку"
	info = "На ней радужная наклейка. Одобряемо."

/obj/item/id_skin/space
	name = "\improper КОСМИЧЕСКАЯ наклейка на карту"
	desc = "Яркая, блестящая и бескрайняя. Прямо как хозяин карты на которую её приклеят."
	icon_state = "space"
	pronoun_name = "КОСМИЧЕСКУЮ наклейку"
	info = "Есть 3 вещи на которые можно смотреть вечно. Это четвёртая."

/obj/item/id_skin/kitty
	name = "\improper кото-клейка на карту"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. UwU."
	icon_state = "kitty"
	pronoun_name = "кото-клейку"
	info = "Так и хочется погладить, жаль это всего-лишь наклейка..."

/obj/item/id_skin/colored/kitty
	name = "\improper голо-кото-клейка на карту"
	desc = "Прекрасная наклейка, которая делает вашу карту похожей на котика. Эта может менять цвет."
	icon_state = "colored_kitty"

/obj/item/id_skin/cursedmiku
	name = "\improper аниме наклейка на карту"
	desc = "Kawaii!!!"
	icon_state = "cursedmiku"
	pronoun_name = "анимешную наклейку"
	info = "На ней анимешная наклейка. AYAYA!"

/obj/item/id_skin/colored/snake
	name = "\improper бегущая наклейка на карту"
	desc = "Она что-то загружает?"
	icon_state = "snake"
	pronoun_name = "бегущую наклейку"
	info = "Бегает и бегает..."

/obj/item/id_skin/magic
	name = "\improper магическая наклейка на карту"
	desc = "EI NATH!"
	icon_state = "magic"
	pronoun_name = "магическую наклейку"
	info = "Кто-то до сих пор девственник..."

/obj/item/id_skin/terminal
	name = "\improper наклейка на карту в виде терминала"
	desc = "HACKERMAN."
	icon_state = "terminal"
	pronoun_name = "наклейку в виде терминала"
	info = "Эта карта похожа на терминал."

/obj/item/id_skin/jokerge
	name = "\improper джокерге наклейка на карту"
	desc = "Jokerge."
	icon_state = "jokerge"
	pronoun_name = "наклейку в виде Джокерге"
	info = "Jokerge."

/obj/item/id_skin/boykisser
	name = "\improper бойкиссерская наклейка на карту"
	desc = "Наклеив её на карту, у вас с почти 100% вероятностью, появится желание целовать мальчиков."
	icon_state = "boykisser"
	pronoun_name = "наклейку в виде бойкиссера"
	info = "Он любит целовать мальчиков."

// Supply Crate
/datum/supply_packs/misc/randomised/id_skins
	name = "Наклейки на карточку"
	containertype = /obj/structure/closet/crate/plastic
	num_contained = 10
	contains = list(
		/obj/item/id_skin/colored,
		/obj/item/id_skin/colored,
		/obj/item/id_skin/colored,
		/obj/item/id_skin/colored,
		/obj/item/id_skin/donut,
		/obj/item/id_skin/donut,
		/obj/item/id_skin/donut,
		/obj/item/id_skin/donut,
		/obj/item/id_skin/ussp,
		/obj/item/id_skin/ussp,
		/obj/item/id_skin/business,
		/obj/item/id_skin/business,
		/obj/item/id_skin/colored/silver,
		/obj/item/id_skin/colored/silver,
		/obj/item/id_skin/silver,
		/obj/item/id_skin/silver,
		/obj/item/id_skin/gold,
		/obj/item/id_skin/lifetime,
		/obj/item/id_skin/clown,
		/obj/item/id_skin/neon,
		/obj/item/id_skin/colored/neon,
		/obj/item/id_skin/missing,
		/obj/item/id_skin/ouija,
		/obj/item/id_skin/paradise,
		/obj/item/id_skin/rainbow,
		/obj/item/id_skin/space,
		/obj/item/id_skin/kitty,
		/obj/item/id_skin/colored/kitty,
		/obj/item/id_skin/cursedmiku,
		/obj/item/id_skin/colored/snake,
		/obj/item/id_skin/magic,
		/obj/item/id_skin/terminal,
		/obj/item/id_skin/jokerge,
		/obj/item/id_skin/boykisser)
	cost = 2000
	containername = "ящик с наклейками"

// Spawner
/obj/effect/spawner/random_spawners/id_skins
	name = "Случайная наклейка на карту"
	icon = 'modular_ss220/maps220/icons/spawner_icons.dmi'
	icon_state = "ID_Random"
	result = list(
	/obj/item/id_skin/colored = 10,
	/obj/item/id_skin/donut = 5,
	/obj/item/id_skin/business = 5,
	/obj/item/id_skin/ussp = 5,
	/obj/item/id_skin/colored/silver = 5,
	/obj/item/id_skin/silver = 5,
	/obj/item/id_skin/gold = 1,
	/obj/item/id_skin/lifetime = 1,
	/obj/item/id_skin/clown = 1,
	/obj/item/id_skin/neon = 1,
	/obj/item/id_skin/colored/neon = 1,
	/obj/item/id_skin/missing = 1,
	/obj/item/id_skin/ouija = 1,
	/obj/item/id_skin/paradise = 1,
	/obj/item/id_skin/rainbow = 1,
	/obj/item/id_skin/space = 1,
	/obj/item/id_skin/kitty = 1,
	/obj/item/id_skin/colored/kitty = 1,
	/obj/item/id_skin/cursedmiku = 1,
	/obj/item/id_skin/colored/snake = 1,
	/obj/item/id_skin/magic = 1,
	/obj/item/id_skin/terminal = 1,
	/obj/item/id_skin/jokerge = 1,
	/obj/item/id_skin/boykisser = 1)

/obj/effect/spawner/random_spawners/id_skins/no_chance
	result = list(
	/datum/nothing = 80,
	/obj/item/id_skin/colored = 10,
	/obj/item/id_skin/donut = 5,
	/obj/item/id_skin/business = 5,
	/obj/item/id_skin/ussp = 5,
	/obj/item/id_skin/colored/silver = 5,
	/obj/item/id_skin/silver = 5,
	/obj/item/id_skin/gold = 1,
	/obj/item/id_skin/lifetime = 1,
	/obj/item/id_skin/clown = 1,
	/obj/item/id_skin/neon = 1,
	/obj/item/id_skin/colored/neon = 1,
	/obj/item/id_skin/missing = 1,
	/obj/item/id_skin/ouija = 1,
	/obj/item/id_skin/paradise = 1,
	/obj/item/id_skin/rainbow = 1,
	/obj/item/id_skin/space = 1,
	/obj/item/id_skin/kitty = 1,
	/obj/item/id_skin/colored/kitty = 1,
	/obj/item/id_skin/cursedmiku = 1,
	/obj/item/id_skin/colored/snake = 1,
	/obj/item/id_skin/magic = 1,
	/obj/item/id_skin/terminal = 1,
	/obj/item/id_skin/jokerge = 1,
	/obj/item/id_skin/boykisser = 1)
