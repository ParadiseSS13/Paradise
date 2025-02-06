/datum/cooking/recipe/appendixburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/appendix
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/appendix),
	)

/datum/cooking/recipe/appendixburger_bitten
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/appendix
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/appendix),
		PCWJ_ADD_ITEM(/obj/item/food/bun),
	)

/datum/cooking/recipe/baconburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bacon
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/baseballburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/baseball
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/melee/baseball_bat),
	)

/datum/cooking/recipe/bearger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bearger
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/bearmeat),
	)

/datum/cooking/recipe/bigbiteburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/bigbite
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/burger/plain),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
	)

/datum/cooking/recipe/brainburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/brain
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/organ/internal/brain),
	)

/datum/cooking/recipe/cheeseburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/cheese
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/chickenburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/chicken
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/chicken),
	)

/datum/cooking/recipe/clownburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/clown
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/gas/clown_hat),
	)

/datum/cooking/recipe/crazyburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/crazy
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
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/elec
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
		PCWJ_ADD_ITEM(/obj/item/stack/sheet/mineral/plasma),
	)

/datum/cooking/recipe/fishburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/fishburger
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/carpmeat),
	)

/datum/cooking/recipe/fivealarmburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/fivealarm
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/ghost_chili),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/ghostburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ghost
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/ectoplasm),
	)

/datum/cooking/recipe/hamborger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/hamborger
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/robot_parts/head),
	)

/datum/cooking/recipe/hotdog
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/hotdog
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/sausage),
	)

/datum/cooking/recipe/jellyburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/mcguffin
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mcguffin
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
	)

/datum/cooking/recipe/mcrib
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mcrib
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/bbqribs),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/onion_slice),
	)

/datum/cooking/recipe/mimeburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/mime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/head/beret),
	)

/datum/cooking/recipe/plainburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/plain
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/ppattyblue
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/blue
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("berryjuice", 5),
	)

/datum/cooking/recipe/ppattygreen
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/green
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("limejuice", 5),
	)

/datum/cooking/recipe/ppattyorange
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/orange
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("orangejuice", 5),
	)

/datum/cooking/recipe/ppattypurple
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/purple
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("grapejuice", 5),
	)

/datum/cooking/recipe/ppattyrainbow
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/rainbow
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
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/red
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/ppattywhite
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/white
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("sugar", 5),
	)

/datum/cooking/recipe/ppattyyellow
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/ppatty/yellow
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_REAGENT("lemonjuice", 5),
	)

/datum/cooking/recipe/ratburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/rat
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/holder/mouse),
	)

/datum/cooking/recipe/slimeburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("slimejelly", 5),
	)

/datum/cooking/recipe/spellburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/spell
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/clothing/head/wizard),
	)

/datum/cooking/recipe/superbiteburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/superbite
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

/datum/cooking/recipe/syntiburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/plain
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/meat/patty),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
	)

/datum/cooking/recipe/tofuburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/tofu
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/tofu),
	)

/datum/cooking/recipe/xenoburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/xeno
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/food/monstermeat/xenomeat),
	)

/datum/cooking/recipe/baseballburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/baseball
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_ITEM(/obj/item/melee/baseball_bat),
	)

/datum/cooking/recipe/cherrysandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/jellyburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/notasandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/notasandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/fakemoustache),
	)

/datum/cooking/recipe/sandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/sandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
	)

/datum/cooking/recipe/slimeburger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burger/jelly/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_REAGENT("slimejelly", 5),
	)

/datum/cooking/recipe/slimesandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jellysandwich/slime
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("slimejelly", 5),
	)

/datum/cooking/recipe/twobread
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/twobread
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("wine", 5),
	)

/datum/cooking/recipe/wrap
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/wrap
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/friedegg),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/cabbage),
		PCWJ_ADD_REAGENT("soysauce", 10),
	)

/datum/cooking/recipe/sandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/sandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/meatsteak),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/philly_cheesesteak
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/philly_cheesesteak
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/onion),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/pbj_cherry
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_jelly/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/peanut_butter_banana
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/peanut_butter_banana
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("peanutbutter", 5),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/banana),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/notasandwich
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/notasandwich
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/clothing/mask/fakemoustache),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)

/datum/cooking/recipe/jelliedtoast
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/jelliedtoast/cherry
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_REAGENT("cherryjelly", 5),
	)

/datum/cooking/recipe/human_burger
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/human/burger
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/bun),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_ITEM(/obj/item/food/meat/human),
	)
	appear_in_default_catalog = FALSE

/datum/cooking/recipe/burrito
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/burrito
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/tortilla),
		PCWJ_ADD_ITEM(/obj/item/food/cutlet),
		PCWJ_ADD_ITEM(/obj/item/food/beans),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/cheesewedge),
		PCWJ_ADD_REAGENT("capsaicin", 5),
		PCWJ_ADD_REAGENT("rice", 5),
	)

/datum/cooking/recipe/blt
	cooking_container = /obj/item/reagent_containers/cooking/board
	product_type = /obj/item/food/blt
	steps = list(
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
		PCWJ_ADD_ITEM(/obj/item/food/bacon),
		PCWJ_ADD_PRODUCE(/obj/item/food/grown/lettuce),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/tomato),
		PCWJ_ADD_ITEM(/obj/item/food/sliced/bread),
	)
