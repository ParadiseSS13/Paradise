#define COMSIG_SUBSYSTEM_POST_INITIALIZE "post_initialize"

GLOBAL_LIST_EMPTY(possible_gifts)

/datum/controller/subsystem/holiday/Initialize()
	. = ..()
	SEND_SIGNAL(src, COMSIG_SUBSYSTEM_POST_INITIALIZE)

// Landmark for tree
/obj/effect/spawner/xmastree
	name = "christmas tree spawner"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	layer = LOW_LANDMARK_LAYER
	/// Christmas tree, no presents included.
	var/christmas_tree = /obj/structure/flora/tree/pine/xmas
	/// Christmas tree, presents included.
	var/presents_tree = /obj/structure/flora/tree/pine/xmas/presents

/obj/effect/spawner/xmastree/Initialize(mapload)
	. = ..()
	if(!SSholiday.initialized)
		RegisterSignal(SSholiday, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(place_tree))
	else
		place_tree()

/obj/effect/spawner/xmastree/proc/place_tree()
	if(NEW_YEAR in SSholiday.holidays)
		new presents_tree(get_turf(src))
	else if(CHRISTMAS in SSholiday.holidays)
		new christmas_tree(get_turf(src))
	return qdel(src)

// Gift
/obj/item/gift
	icon = 'modular_ss220/events/icons/xmas.dmi'

/obj/item/a_gift
	icon = 'modular_ss220/events/icons/xmas.dmi'

/obj/item/a_gift/anything
	name = "\improper новогодний подарок"
	desc = "Подарок! Что же тут..."

/obj/item/a_gift/anything/attack_self__legacy__attackchain(mob/M)
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/thing in gift_types_list)
			var/obj/item/item = thing
			if((!initial(item.icon_state)) || (!initial(item.item_state)) || (initial(item.flags) & (ABSTRACT | NODROP)) || (initial(item.w_class) > 6))
				gift_types_list -= thing
			GLOB.possible_gifts = gift_types_list

	var/something = pick(GLOB.possible_gifts)
	var/obj/item/gift = new something(M)
	M.unequip(src, TRUE)
	M.put_in_hands(gift)
	gift.add_fingerprint(M)
	playsound(loc, 'sound/items/poster_ripped.ogg', 100, TRUE)
	qdel(src)
	return

// Xmas Tree
/obj/structure/flora/tree/pine/xmas
	name = "\improper новогодняя ёлка"
	desc = "Превосходная новогодняя ёлка."
	icon = 'modular_ss220/events/icons/xmastree.dmi'
	icon_state = "xmas_tree"
	light_range = 6
	light_power = 1
	resistance_flags = INDESTRUCTIBLE // Protected by the christmas spirit

/obj/structure/flora/tree/pine/xmas/Initialize(mapload)
	. = ..()
	icon_state = initial(icon_state)

/obj/structure/flora/tree/pine/xmas/presents
	icon_state = "xmas_tree_presents"
	desc = "Превосходная новогодняя ёлка. Под ней подарки!"
	var/gift_type = /obj/item/a_gift
	var/unlimited = FALSE
	var/static/list/took_presents // Shared between all xmas trees

/obj/structure/flora/tree/pine/xmas/presents/anything
	gift_type = /obj/item/a_gift/anything

/obj/structure/flora/tree/pine/xmas/presents/Initialize(mapload)
	. = ..()
	if(!took_presents)
		took_presents = list()

/obj/structure/flora/tree/pine/xmas/presents/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.ckey)
		return

	if(took_presents[user.ckey] && !unlimited)
		to_chat(user, span_warning("Ты не видишь подарка со своим именем."))
		return

	to_chat(user, span_notice("Немного покопавшись, ты нашёл подарок со своим именем."))

	if(!unlimited)
		took_presents[user.ckey] = TRUE

	var/obj/item/G = new gift_type(src)
	user.put_in_hands(G)

/obj/structure/flora/tree/pine/xmas/presents/unlimited
	desc = "Превосходная новогодняя ёлка. Кажется под ней нескончаемый запас подарков!"
	unlimited = TRUE

/obj/structure/flora/tree/pine/xmas/presents/anything/unlimited
	desc = "Превосходная новогодняя ёлка. Кажется под ней нескончаемый запас полностью случайных подарков!"
	unlimited = TRUE

// Рождество
/datum/holiday/xmas
	var/light_color = "#FFE6D9"
	var/nightshift_light_color = "#FFC399"
	var/window_edge_overlay_file = 'modular_ss220/events/icons/xmaslights.dmi'
	var/window_light_range = 4
	var/window_light_power = 0.1
	var/window_color = "#6CA66C"

/datum/holiday/xmas/celebrate()
	// Новогоднее освещение
	for(var/obj/machinery/light/lights in GLOB.machines)
		lights.brightness_color = light_color
		lights.nightshift_light_color = nightshift_light_color

	// Гурлянды
	for(var/obj/structure/window/full/reinforced/window in world)
		window.edge_overlay_file = window_edge_overlay_file
		window.light_range = window_light_range
		window.light_power = window_light_power
		window.update_light()
	for(var/obj/structure/window/full/plasmareinforced/window in world)
		window.edge_overlay_file = window_edge_overlay_file
		window.light_range = window_light_range
		window.light_power = window_light_power
		window.update_light()
	for(var/turf/simulated/wall/indestructible/fakeglass/window in world)
		window.edge_overlay_file = window_edge_overlay_file
		window.light_range = window_light_range
		window.light_power = window_light_power
		window.update_light()

	// Новогодний цвет окон
	for(var/obj/structure/window/windows in world)
		windows.color = window_color
	for(var/obj/machinery/door/window/windoor in world)
		windoor.color = window_color
	for(var/turf/simulated/wall/indestructible/fakeglass/fakeglass in world)
		fakeglass.color = window_color

	// Их не красить
	for(var/obj/structure/window/full/plasmabasic/plasma in world)
		plasma.color = null
	for(var/obj/structure/window/full/plasmareinforced/rplasma in world)
		rplasma.color = null
	for(var/obj/structure/window/full/shuttle/shuttle in world)
		shuttle.color = null
	for(var/obj/structure/window/full/plastitanium/syndie in world)
		syndie.color = null

	// Лучший подарок для лучшего экипажа
	for(var/obj/structure/reagent_dispensers/beerkeg/nuke/beernuke in world)
		beernuke.icon = 'modular_ss220/events/icons/nuclearbomb.dmi'
	for(var/obj/machinery/nuclearbomb/nuke in world)
		if(nuke.type == /obj/machinery/nuclearbomb)
			nuke.icon = 'modular_ss220/events/icons/nuclearbomb.dmi'

	// Новогодние цветочки (И снеговик)
	for(var/obj/item/kirbyplants/plants in world)
		plants.icon = 'modular_ss220/events/icons/xmas.dmi'
		plants.icon_state = "plant-[rand(1,9)]"

	// Шляпа Иану
	for(var/mob/living/simple_animal/pet/dog/corgi/ian/Ian in GLOB.mob_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat)

	// Снеговик в крафт
	for(var/datum/crafting_recipe/snowman/S in GLOB.crafting_recipes)
		S.always_available = TRUE
		break

	//The following spawn is necessary as both the timer and the shuttle systems initialise after the events system does, so we can't add stuff to the shuttle system as it doesn't exist yet and we can't use a timer
	spawn(60 SECONDS)
		var/datum/supply_packs/misc/snow_machine/xmas = SSeconomy.supply_packs["[/datum/supply_packs/misc/snow_machine]"]
		xmas.special = FALSE

// Световые маски на гурлянды, красивое в темноте
/obj/structure/window/full/reinforced/update_overlays()
	. = ..()
	if(CHRISTMAS in SSholiday.holidays)
		underlays += emissive_appearance(edge_overlay_file, "[smoothing_junction]_lightmask")

/obj/structure/window/full/plasmareinforced/update_overlays()
	. = ..()
	if(CHRISTMAS in SSholiday.holidays)
		underlays += emissive_appearance(edge_overlay_file, "[smoothing_junction]_lightmask")

/turf/simulated/wall/indestructible/fakeglass/update_overlays()
	. = ..()
	if(CHRISTMAS in SSholiday.holidays)
		underlays += emissive_appearance(edge_overlay_file, "[smoothing_junction]_lightmask")
