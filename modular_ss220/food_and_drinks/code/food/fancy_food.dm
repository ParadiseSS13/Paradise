/**
 * MARK: | Fancy Food
 * Fancy food need to be opened first.
 */
/obj/item/food/fancy
	/// Description when opened.
	var/desc_open
	/// Is it ready to be eaten?
	var/opened = FALSE
	/// Does it need to be taken out of the box?
	var/need_takeout = FALSE
	/// The sound that will be played when you open a food.
	var/open_sound = 'modular_ss220/aesthetics_sounds/sound/food_open.ogg'
	COOLDOWN_DECLARE(try_open)

/obj/item/food/fancy/update_icon_state()
	if(opened)
		icon_state = "[initial(icon_state)]_open"

/obj/item/food/fancy/attack(mob/M, mob/user, def_zone)
	if(!opened)
		to_chat(user, span_warning("[src] сначала нужно открыть!"))
		return FALSE
	if(opened && need_takeout)
		to_chat(user, span_warning("Сначала вытащите еду из упаковки!"))
		return FALSE
	return ..()

/obj/item/food/fancy/attack_self(mob/user)
	AltClick(user)

/obj/item/food/fancy/examine(mob/user)
	. = ..()
	if(!opened)
		. += span_notice("Нажмите <b>Alt-Click</b>, чтобы открыть.")
	if(opened && need_takeout)
		. += span_notice("Нажмите <b>Alt-Click</b>, чтобы достать еду из упаковки.")

/obj/item/food/fancy/AltClick(mob/user)
	if(!try_open(user))
		return

	if(opened && !opened_act(user))
		to_chat(user, span_warning("[src] уже открыт!"))
		return

	open(user)
	update_icon(UPDATE_ICON_STATE)

/**
 * Try to open food box
 * Returns TRUE if it can be opened
 */
/obj/item/food/fancy/proc/try_open(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained())
		to_chat(user, span_warning("У вас нет возможности открыть [src]!"))
		return FALSE

	if(!COOLDOWN_FINISHED(src, try_open))
		return FALSE

	return TRUE

/**
 * Opens food box
 */
/obj/item/food/fancy/proc/open(mob/user)
	COOLDOWN_START(src, try_open, 2 SECONDS) // Prevent sound spamming
	if(src.loc != user)
		return

	playsound(loc, open_sound, 50)
	if(!do_after(user, 1 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		return

	opened = TRUE
	if(desc_open)
		desc = desc_open

/**
 * Second action on Alt+Click.
 * Called only when food is opened
 */
/obj/item/food/fancy/proc/opened_act(mob/user)
	return FALSE

// MARK: Doshik
/obj/item/food/fancy/doshik
	name = "\improper дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "doshik"
	trash = /obj/item/trash/doshik
	bitesize = 3
	junkiness = 25
	list_reagents = list("dry_ramen" = 30)
	tastes = list("курятина" = 1, "лапша" = 1)

/obj/item/food/fancy/doshik_spicy
	name = "\improper острый дошик"
	desc = "Очень известная лапша быстрого приготовления. При открытии заваривается моментально. Вау. Кажется, что в ней есть острые специи."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "doshikspicy"
	trash = /obj/item/trash/doshik
	bitesize = 3
	junkiness = 30
	list_reagents = list("dry_ramen" = 30, "capsaicin" = 5)
	tastes = list("говядина" = 1, "лапша" = 1)

/obj/item/trash/doshik
	name = "\improper упаковка из-под дошика"
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "doshik-empty"
	desc = "Всё ещё вкусно пахнет."

// MARK: MacVulpix
/obj/item/food/fancy/macvulpix_original
	name = "\improper MacVulpix Original Taste"
	desc = "Классический вкус вульпиксов, проверенный временем, в удобной порционной упаковке."
	desc_open = "Пластиковый контейнер, доверху наполненный вкуснейшими и ароматными мясными шариками с кетчупом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV-vulpixs"
	trash = /obj/item/trash/macvulpix
	bitesize = 2
	junkiness = 20
	list_reagents = list("nutriment" = 4, "protein" = 4)
	tastes = list("напоминающего курицу" = 2, "кетчуп" = 2)

/obj/item/food/fancy/macvulpix_cheese
	name = "\improper MacVulpix Triple-Cheese"
	desc = "Классические вульпиксы - теперь с тройной сырной добавкой!"
	desc_open = "Пластиковый контейнер, доверху наполненный вкуснейшими и ароматными мясными шариками с сырным соусом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV-vulpixs-cheese"
	trash = /obj/item/trash/macvulpix
	bitesize = 2
	junkiness = 20
	list_reagents = list("nutriment" = 4, "protein" = 4)
	tastes = list("напоминающего курицу" = 2, "сыр" = 6)

/obj/item/trash/macvulpix
	name = "\improper упаковка из-под MacVulpix"
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "MV-vulpixs"
	desc = "Всё ещё вкусно пахнет."

/**
 * MARK: | Packed Fancy Food
 * This type of food should be double opened
 */
/obj/item/food/fancy/packed
	need_takeout = TRUE
	var/list/possible_food

/obj/item/food/fancy/packed/Initialize(mapload)
	. = ..()
	LAZYINITLIST(possible_food)
	return INITIALIZE_HINT_LATELOAD

/obj/item/food/fancy/packed/LateInitialize()
	if(!LAZYLEN(possible_food))
		stack_trace("List 'possible_food' is empty or not initialized in [src.type] subtype! Deleting...")
		qdel(src)
		return
	// Picks random from the list, works also if one item is in the list
	var/item = pick(possible_food)
	new item(src)

/obj/item/food/fancy/packed/opened_act(mob/user)
	user.drop_item()

	for(var/obj/item/food/internal_food in contents)
		if(!user.get_active_hand() && Adjacent(user))
			user.put_in_hands(internal_food)
		else
			internal_food.forceMove(get_turf(user))

	qdel(src)
	return TRUE

// MARK: MacVulpBurger
/obj/item/food/fancy/packed/macvulpburger
	name = "\improper MacVulpBurger Gourmet"
	desc = "Особый бургер из линейки “Большой Укус” с трюфельно-ягодным соусом, только для ценителей необычного!"
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV-burgerbox"
	open_sound = 'sound/machines/cardboard_box.ogg'
	possible_food = list(/obj/item/food/burger/macvulp)

/obj/item/food/burger/macvulp
	name = "\improper MacVulpBurger Gourmet"
	desc = "Огромный аппетитный и сочащийся соками бургер с двойной говяжьей котлетой и трюфельно-ягодным соусом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "MV_burger"
	bitesize = 2
	list_reagents = list("nutriment" = 6, "protein" = 6, "vitamin" = 1)
	tastes = list("булка" = 1, "говядина" = 4, "трюфельный соус" = 1, "ягодный соус" = 1)

// MARK: NT Food
/obj/item/food/fancy/packed/foodpack_nt
	name = "\improper Nanotrasen Foodpack"
	desc = "Большой набор еды с различным содержимым."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodpack_nt"
	open_sound = 'sound/machines/cardboard_box.ogg'
	possible_food = list(
		/obj/item/food/foodtray_sad_steak,
		/obj/item/food/foodtray_chicken_sandwich,
		/obj/item/food/foodtray_noodle,
		/obj/item/food/foodtray_sushi,
		/obj/item/food/foodtray_beef_and_rice,
		/obj/item/food/foodtray_pesto_pizza,
		/obj/item/food/foodtray_rice_and_grilled_cheese,
		/obj/item/food/foodtray_fried_shrooms
	)

/obj/item/food/foodtray_sad_steak
	name = "\improper mashed potatoes and steak"
	desc = "Суховатое пюре с таким себе стейком, скорее всего это даже не мясо."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_sad_steak"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 8, "protein" = 4, "vitamin" = 8)
	tastes = list("соус" = 1, "картофель" = 1, "напоминающего мяса" = 4)

/obj/item/food/foodtray_chicken_sandwich
	name = "\improper chicken sandwich"
	desc = "Сэндвич с безвкусной курицей."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_chicken_sandwich"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 8, "protein" = 4, "vitamin" = 5)
	tastes = list("соус" = 1, "булка" = 1, "курица" = 1)

/obj/item/food/foodtray_noodle
	name = "\improper noodles"
	desc = "Спагетти Болоньезе, или нет... Но очень похоже."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_noodle"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 5, "vitamin" = 3)
	tastes = list("соус болоньезе" = 4, "спагетти" = 1)

/obj/item/food/foodtray_sushi
	name = "\improper sushi"
	desc = "Свежие суши с неплохим балансом между рисом и рыбой."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_sushi"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 10, "protein" = 2, "vitamin" = 5)
	tastes = list("рыба" = 4, "рис" = 2, "водоросли" = 1)

/obj/item/food/foodtray_beef_and_rice
	name = "\improper beef and rice"
	desc = "Питательная порция говядины с рисом."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_beef_and_rice"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 10, "protein" = 20, "vitamin" = 5)
	tastes = list("говядина" = 4, "рис" = 2, "специи" = 1)

/obj/item/food/foodtray_pesto_pizza
	name = "\improper pesto pizza"
	desc = "Пицца с песто. В меру питательная и слегка пресная. Хороший выбор для тех, кто не ждет многого от обеда."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_pesto_pizza"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("песто" = 3, "сыр" = 2, "тесто" = 1)

/obj/item/food/foodtray_rice_and_grilled_cheese
	name = "\improper rice and grilled cheese"
	desc = "Странное сочетание риса и жареного сыра."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_rice_and_grilled_cheese"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 2)
	tastes = list("рис" = 2, "жареный сыр" = 3)

/obj/item/food/foodtray_fried_shrooms
	name = "\improper fried shrooms"
	desc = "Простая порция жареных грибов, хрустящих снаружи и мягких внутри. Непритязательное, но питательное блюдо."
	icon = 'modular_ss220/food_and_drinks/icons/food.dmi'
	icon_state = "foodtray_fried_shrooms"
	trash = /obj/item/trash/foodtray
	bitesize = 2
	list_reagents = list("nutriment" = 10, "vitamin" = 5)
	tastes = list("грибы" = 4, "масло" = 2)

/obj/item/trash/foodtray
	name = "\improper food tray"
	desc = "Пустой лоток из-под еды."
	icon = 'modular_ss220/food_and_drinks/icons/trash.dmi'
	icon_state = "foodtray"
