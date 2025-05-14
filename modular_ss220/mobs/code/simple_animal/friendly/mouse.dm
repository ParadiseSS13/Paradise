
// Коэфицент питательности еды, чтобы полностью не копировать сложную систему питание людей.
#define NUTRITION_COEF 20
#define MAX_FEADING_TIME 7 SECONDS
#define MIN_FEADING_TIME 3 SECONDS
// Сколько нутриентов должно быть в мыше, перед тем как мы её гибнем
#define GIB_FEED_LEVEL NUTRITION_LEVEL_FULL * 1.35
#define STATUS_FAT "fat"
#define STATUS_FULL "full"
#define STATUS_WELL_FED "well_fed"
#define STATUS_FED "fed"
#define STATUS_HUNGRY "hungry"
#define STATUS_STARVING "starving"

/datum/hud/simple_animal_mouse/New(mob/user)
	..()

	mymob.healths = new /atom/movable/screen/healths()
	infodisplay += mymob.healths

	mymob.nutrition_display = new /atom/movable/screen/nutrition()
	mymob.nutrition_display.screen_loc = "EAST-1:26,CENTER-1:15"
	// "EAST-2:32,CENTER-1:13"
	mymob.nutrition_display.icon = 'modular_ss220/mobs/code/simple_animal/friendly/screen_hunger_ui_for_mouse.dmi'

	infodisplay += mymob.nutrition_display

	var/atom/movable/screen/using
	using = new /atom/movable/screen/act_intent/simple_animal()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	user.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/stretch/see_through_darkness)

/mob/living/simple_animal/mouse
	icon = 'modular_ss220/mobs/icons/mob/animal.dmi'
	death_sound = 'modular_ss220/mobs/sound/creatures/rat_death.ogg'
	talk_sound = list('modular_ss220/mobs/sound/creatures/rat_talk.ogg')
	damaged_sound = list('modular_ss220/mobs/sound/creatures/rat_wound.ogg')
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/food/meat/mouse = 1)
	// hungry mouse
	hud_type = /datum/hud/simple_animal_mouse
	// Стартовый уровень голода
	nutrition = NUTRITION_LEVEL_HUNGRY + 10
	// Скорость, с которой снижается наш голод
	// Мышка тратит 1800 nutrition в час, при hunger_drain = 1. Одно блюдо восполняет где-то 100-200 nutrition
	hunger_drain = HUNGER_FACTOR * 1.66
	var/const/bitesize = 2
	var/hunger_status
	var/busy = FALSE
	var/non_standard = FALSE // for no "mouse_" with mouse_color

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list("[squeak_sound]" = 1), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE) //as quiet as a mouse or whatever

	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

	mouse_color = initial(mouse_color) // сбрасываем из-за наследования чтобы своим проком переписать
	color_pick()
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

// Отслеживаем, что призрак попал в мышку.
/mob/living/simple_animal/mouse/Login()
	. = ..()
	// Теперь мышка будет обрабатыватся в цикле life, обычные мышки не будут обрабатывать голод.
	reagents = new()

/mob/living/simple_animal/mouse/proc/color_pick()
	if(!mouse_color)
		mouse_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[mouse_color]"
	icon_living = "mouse_[mouse_color]"
	icon_dead = "mouse_[mouse_color]_dead"
	icon_resting = "mouse_[mouse_color]_sleep"

/mob/living/simple_animal/mouse/splat(obj/item/item = null, mob/living/user = null)
	if(non_standard)
		var/temp_state = initial(icon_state)
		icon_dead = "[temp_state]_splat"
		icon_state = "[temp_state]_splat"
	else
		..()

	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(item)
			item.add_mob_blood(src)
		if(user)
			user.add_mob_blood(src)

/mob/living/simple_animal/mouse/death(gibbed)
	if(gibbed)
		make_remains()
	. = ..(gibbed)

/mob/living/simple_animal/mouse/proc/make_remains()
	var/obj/effect/decal/remains = new /obj/effect/decal/remains/mouse(src.loc)
	remains.pixel_x = pixel_x
	remains.pixel_y = pixel_y

// Вызывается циклически из прока `Life`. Отвечает за обработку голода
/mob/living/simple_animal/mouse/handle_chemicals_in_body()
	adjust_nutrition(-hunger_drain)

	switch(nutrition)
		if(GIB_FEED_LEVEL to INFINITY)
			visible_message("[src] разорвало от обжорства!", "Ваши внутренности не выдерживают и лопаются!")
			gib()
			return
		if(NUTRITION_LEVEL_FULL to GIB_FEED_LEVEL)
			if(hunger_status != STATUS_FAT)
				hunger_status = STATUS_FAT
				to_chat(src, span_userdanger("Ты чувствуешь, что в тебя больше не влезет и кусочка"))
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			if(hunger_status != STATUS_FULL)
				hunger_status = STATUS_FULL
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			if(hunger_status != STATUS_WELL_FED)
				hunger_status = STATUS_WELL_FED
				to_chat(src, span_notice("Ты чувствуешь себя превосходно!"))
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			if(hunger_status != STATUS_FED)
				hunger_status = STATUS_FED
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			if(hunger_status != STATUS_HUNGRY)
				hunger_status = STATUS_HUNGRY
				to_chat(src, span_warning("Твой живот угрюмо урчит, лучше найти что-то поесть"))
		else
			if(hunger_status != STATUS_STARVING)
				hunger_status = STATUS_STARVING
				to_chat(src, span_userdanger("Ты смертельно голоден!"))
			adjustHealth(nutrition > NUTRITION_LEVEL_HYPOGLYCEMIA ? 0.02 : 0.05)

	handle_nutrition_alerts()
	update_appearance(UPDATE_NAME|UPDATE_DESC)

/mob/living/simple_animal/mouse/proc/handle_nutrition_alerts()
	switch(nutrition)
		if(NUTRITION_LEVEL_FULL to GIB_FEED_LEVEL)
			nutrition_display.icon_state = STATUS_FAT
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			nutrition_display.icon_state = STATUS_FULL
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			nutrition_display.icon_state = STATUS_WELL_FED
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			nutrition_display.icon_state = STATUS_FED
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			nutrition_display.icon_state = STATUS_HUNGRY
		else
			nutrition_display.icon_state = STATUS_STARVING

/mob/living/simple_animal/mouse/update_name()
	. = ..()
	var/tag
	if(nutrition >= NUTRITION_LEVEL_FULL)
		tag = "жирная " // Мешаем англиский с русским
	if(nutrition <= NUTRITION_LEVEL_HUNGRY)
		tag = "костлявая "
	name = "[tag][initial(name)]"

/mob/living/simple_animal/mouse/update_desc()
	. = ..()
	desc = "It's a small [mouse_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."
	if(nutrition >= NUTRITION_LEVEL_FULL)
		desc += " Господи! Она же огромная!"
	if(nutrition <= NUTRITION_LEVEL_HUNGRY)
		desc += " Вы можете увидеть рёбра через её кожу."

// Вызывается, когда мышка кликает на еду, можно кушать только одну еду за раз.
/mob/living/simple_animal/mouse/proc/consume(obj/item/food/F)
	if(busy)
		to_chat(src, span_warning("Сначала доешь то, что уже жуёшь."))
		return

	busy = TRUE
	// linear scale from (MIN_FEADING_TIME, to MAX_FEADING_TIME)
	var/eat_time = MIN_FEADING_TIME + (MAX_FEADING_TIME - MIN_FEADING_TIME) * (nutrition / GIB_FEED_LEVEL)
	to_chat(src, span_notice("Ты начинаешь употреблять [F]."))
	if(!do_after_once(src, eat_time, target = F, needhand = FALSE))
		to_chat(src, span_notice("Не доедая, ты перестаёшь жевать [F]!"))
		busy = FALSE
		return

	busy = FALSE
	playsound(loc, 'sound/items/eatfood.ogg', 30, FALSE, frequency = 1.5)
	var/nutriment = F.reagents.get_reagent_amount("nutriment")
	// Добавляю только нутриенты т.к. яды и другие вещества не обрабатываются по умолчанию.

	if(istype(F, /obj/item/food/sliced/cheesewedge) || istype(F, /obj/item/food/sliceable/cheesewheel))
		Druggy(2 SECONDS)
		custom_emote(EMOTE_VISIBLE, pick("дёргается.", "быстро вертит хвостиком.", "издаёт продолжительный писк."))

	if(nutriment > bitesize)
		F.reagents.remove_reagent("nutriment", bitesize, TRUE)
		visible_message("[src] съедает часть [F].", "Ты съедаешь часть [F].")
		adjust_nutrition(bitesize * NUTRITION_COEF)
	else
		visible_message("[src] заканчивает есть [F].", "Ты доедаешь [F].")
		F.reagents.remove_reagent("nutriment", nutriment, TRUE)
		adjust_nutrition(nutriment * NUTRITION_COEF)
		F.generate_trash(F)
		qdel(F)


/mob/living/simple_animal/mouse/brown/tom
	maxHealth = 10
	health = 10

/mob/living/simple_animal/mouse/fluff/clockwork
	name = "Chip"
	real_name = "Chip"
	mouse_color = "clockwork"
	icon_state = "mouse_clockwork"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	gold_core_spawnable = NO_SPAWN
	can_collar = 0
	butcher_results = list(/obj/item/stack/sheet/metal = 1)
	maxHealth = 20
	health = 20

#undef NUTRITION_COEF
#undef MAX_FEADING_TIME
#undef MIN_FEADING_TIME
#undef GIB_FEED_LEVEL
#undef STATUS_FAT
#undef STATUS_FULL
#undef STATUS_WELL_FED
#undef STATUS_FED
#undef STATUS_HUNGRY
#undef STATUS_STARVING
