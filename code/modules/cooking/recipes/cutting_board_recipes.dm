/datum/cooking/recipe/appendixburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/appendix
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/appendix),
	)

/datum/cooking/recipe/appendixburger_bitten
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/appendix
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/appendix),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/baconburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bacon
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/baseballburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/baseball
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/melee/baseball_bat),
	)

/datum/cooking/recipe/bearger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bearger
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/bearmeat),
	)

/datum/cooking/recipe/bigbiteburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bigbite
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/burger/plain),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
	)

/datum/cooking/recipe/brainburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/brain
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/brain),
	)

/datum/cooking/recipe/cheeseburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/cheese
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/chickenburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/chicken
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/chicken),
	)

/datum/cooking/recipe/clownburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/clown
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/gas/clown_hat),
	)

/datum/cooking/recipe/crazyburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/crazy
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/toy/crayon/green),
		PCWJ_ADD_ITEM(/obj/item/flashlight/flare),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/chili),
		PCWJ_ADD_REAGENT("cornoil", 15),
	)

/datum/cooking/recipe/elecburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/elec
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
		PCWJ_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
	)

/datum/cooking/recipe/fishburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/fishburger
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
	)

/datum/cooking/recipe/fivealarmburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/fivealarm
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/ghostburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ghost
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/ectoplasm),
	)

/datum/cooking/recipe/hamborger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/hamborger
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/robot_parts/head),
	)

/datum/cooking/recipe/hotdog
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/hotdog
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
	)

/datum/cooking/recipe/jellyburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/cherry
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/mcguffin
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mcguffin
	catalog_category = COOKBOOK_CATEGORY_BREAKFASTS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
	)

/datum/cooking/recipe/mcrib
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mcrib
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bbqribs),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
	)

/datum/cooking/recipe/mimeburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mime
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/head/beret),
	)

/datum/cooking/recipe/plainburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/plain
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/ppattyblue
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/blue
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("berryjuice", 5),
	)

/datum/cooking/recipe/ppattygreen
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/green
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("limejuice", 5),
	)

/datum/cooking/recipe/ppattyorange
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/orange
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("orangejuice", 5),
	)

/datum/cooking/recipe/ppattypurple
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/purple
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("grapejuice", 5),
	)

/datum/cooking/recipe/ppattyrainbow
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/rainbow
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/red),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/orange),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/yellow),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/green),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/blue),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/purple),
		PCWJ_ADD_ITEM(/obj/item/food/burger/ppatty/white),
	)

/datum/cooking/recipe/ppattyred
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/red
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/ppattywhite
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/white
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("sugar", 5),
	)

/datum/cooking/recipe/ppattyyellow
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/yellow
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
	)

/datum/cooking/recipe/ratburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/rat
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/holder/mouse),
	)

/datum/cooking/recipe/slimeburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/slime
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("slimejelly", 5),
	)

/datum/cooking/recipe/spellburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/spell
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/head/wizard),
	)

/datum/cooking/recipe/superbiteburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/superbite
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/burger/bigbite),
		PCWJ_ADD_ITEM(/obj/item/food/dough),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/tomato),
		PCWJ_ADD_REAGENT("sodiumchloride", 5),
		PCWJ_ADD_REAGENT("blackpepper", 5),
	)

/datum/cooking/recipe/tofuburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/tofu
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
	)

/datum/cooking/recipe/xenoburger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/xeno
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
	)

/datum/cooking/recipe/cherrysandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/cherry
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/slimesandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/slime
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/twobread
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/twobread
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("wine", 5),
	)

/datum/cooking/recipe/wrap
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/wrap
	catalog_category = COOKBOOK_CATEGORY_VEGE
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("soysauce", 10),
	)

/datum/cooking/recipe/sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/sandwich
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/glass_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/glass_sandwich
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/shard, exact = TRUE),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/plasma_glass_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/glass_sandwich/plasma
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/shard/plasma),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/plastitanium_glass_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/glass_sandwich/plasma/plastitanium
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/shard/plastitanium),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/// A step that allows either direct adding of a supermatter sliver
/// (if you have somehow manage to hold one), or
/// from tongs if those are used and contain a sliver in them.
/datum/cooking/recipe_step/add_item/supermatter_sliver

/datum/cooking/recipe_step/add_item/supermatter_sliver/check_conditions_met(obj/added_item, datum/cooking/recipe_tracker/tracker)
	var/obj/item/retractor/supermatter/tongs = added_item
	if(istype(tongs) && tongs.sliver)
		return PCWJ_CHECK_VALID

	var/obj/item/nuke_core/supermatter_sliver/sliver = added_item
	if(istype(sliver))
		return PCWJ_CHECK_VALID

	return PCWJ_CHECK_INVALID

/datum/cooking/recipe_step/add_item/supermatter_sliver/follow_step(obj/used_item, datum/cooking/recipe_tracker/tracker, mob/user)
	var/obj/item/retractor/supermatter/tongs = used_item
	if(istype(tongs) && tongs.sliver)
		. = ..(tongs.sliver, tracker, user)
		// TODO: refactor the tongs so they actually check if(sliver) in `update_icon()` instead of manually setting the icons everywhere.
		tongs.sliver = null
		tongs.update_appearance(UPDATE_ICON_STATE)
	else
		. = ..()

/datum/cooking/recipe/supermatter_sandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/supermatter_sandwich
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		new /datum/cooking/recipe_step/add_item/supermatter_sliver(),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/philly_cheesesteak
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/philly_cheesesteak
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/pbj_cherry
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_jelly/cherry
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/slime
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_ADD_REAGENT("slimejelly", 5),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/peanut_butter_banana
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_banana
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/notasandwich
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/notasandwich
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/fakemoustache),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/jelliedtoast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jelliedtoast/cherry
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/jellied_slime_toast
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jelliedtoast/slime
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
	)

/datum/cooking/recipe/human_burger
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/human/burger
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/burrito
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burrito
	catalog_category = COOKBOOK_CATEGORY_MEAT
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/beans),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("capsaicin", 5),
		PCWJ_ADD_REAGENT("rice", 5),
	)

/datum/cooking/recipe/blt
	container_type = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/blt
	catalog_category = COOKBOOK_CATEGORY_BURGS
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/tomato),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)
