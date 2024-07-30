

// see code/datums/recipe.dm

/datum/recipe/microwave/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/egg
	)
	result = /obj/item/food/boiledegg

/datum/recipe/microwave/dionaroast
	reagents = list("facid" = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(
		/obj/item/holder/diona,
		/obj/item/food/grown/apple
	)
	result = /obj/item/food/dionaroast

/datum/recipe/microwave/jellydonut
	reagents = list("berryjuice" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut/jelly

/datum/recipe/microwave/jellydonut/slime
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut/jelly/slimejelly

/datum/recipe/microwave/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut/jelly/cherryjelly

/datum/recipe/microwave/donut
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut

/datum/recipe/microwave/donut/sprinkles
	reagents = list("sugar" = 5, "sprinkles" = 2)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut/sprinkles

/datum/recipe/microwave/human/burger
	items = list(
		/obj/item/food/meat/human,
		/obj/item/food/grown/lettuce,
		/obj/item/food/bun
	)
	result = /obj/item/food/human/burger

/datum/recipe/microwave/chickenburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat/chicken
	)
	result = /obj/item/food/burger/chicken

/datum/recipe/microwave/plainburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/grown/lettuce,
		/obj/item/food/meat //do not place this recipe before /datum/recipe/microwave/human/burger
	)
	result = /obj/item/food/burger/plain

/datum/recipe/microwave/syntiburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/grown/lettuce,
		/obj/item/food/meat/syntiflesh
	)
	result = /obj/item/food/burger/plain

/datum/recipe/microwave/bigbiteburger
	items = list(
		/obj/item/food/burger/plain,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/burger/bigbite

/datum/recipe/microwave/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/food/burger/bigbite,
		/obj/item/food/dough,
		/obj/item/food/meat,
		/obj/item/food/cheesewedge,
		/obj/item/food/bacon,
		/obj/item/food/tomatoslice
	)
	result = /obj/item/food/burger/superbite

/datum/recipe/microwave/brainburger
	items = list(
		/obj/item/food/bun,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/food/burger/brain

/datum/recipe/microwave/hamborger
	items = list(
		/obj/item/food/bun,
		/obj/item/robot_parts/head
	)
	result = /obj/item/food/burger/hamborger

/datum/recipe/microwave/xenoburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/monstermeat/xenomeat
	)
	result = /obj/item/food/burger/xeno

/datum/recipe/microwave/fishburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/carpmeat
	)
	result = /obj/item/food/fishburger

/datum/recipe/microwave/fishburger/make_food(obj/container)
	var/obj/item/food/fishburger/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/tofuburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/tofu
	)
	result = /obj/item/food/burger/tofu

/datum/recipe/microwave/ghostburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/food/burger/ghost

/datum/recipe/microwave/clownburger
	items = list(
		/obj/item/food/bun,
		/obj/item/clothing/mask/gas/clown_hat
	)
	result = /obj/item/food/burger/clown

/datum/recipe/microwave/mimeburger
	items = list(
		/obj/item/food/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/food/burger/mime

/datum/recipe/microwave/baseballburger
	items = list(
		/obj/item/food/bun,
		/obj/item/melee/baseball_bat
	)
	result = /obj/item/food/burger/baseball

/datum/recipe/microwave/cheeseburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat,
		/obj/item/food/grown/lettuce,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/burger/cheese

/datum/recipe/microwave/appendixburger
	items = list(
		/obj/item/food/bun,
		/obj/item/organ/internal/appendix
	)
	result = /obj/item/food/burger/appendix

/datum/recipe/microwave/appendixburger_bitten
	items = list(
		/obj/item/food/appendix,
		/obj/item/food/bun
	)
	result = /obj/item/food/burger/appendix

/datum/recipe/microwave/bearger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/monstermeat/bearmeat
	)
	result = /obj/item/food/burger/bearger

/datum/recipe/microwave/fivealarmburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/grown/ghost_chili,
		/obj/item/food/grown/ghost_chili,
		/obj/item/food/grown/lettuce
	)
	result = /obj/item/food/burger/fivealarm

/datum/recipe/microwave/baconburger
	items = list(
		/obj/item/food/bun,
		/obj/item/food/bacon,
		/obj/item/food/bacon,
		/obj/item/food/grown/lettuce,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/burger/bacon

/datum/recipe/microwave/mcrib
	items = list(
		/obj/item/food/bun,
		/obj/item/food/bbqribs,
		/obj/item/food/onion_slice
	)
	result = /obj/item/food/burger/mcrib

/datum/recipe/microwave/mcguffin
	items = list(
		/obj/item/food/bun,
		/obj/item/food/bacon,
		/obj/item/food/bacon,
		/obj/item/food/friedegg
	)
	result = /obj/item/food/burger/mcguffin

/datum/recipe/microwave/hotdog
	items = list(
		/obj/item/food/bun,
		/obj/item/food/sausage
	)
	result = /obj/item/food/hotdog

/datum/recipe/microwave/donkpocket
	items = list(
		/obj/item/food/dough,
		/obj/item/food/meatball
	)
	result = /obj/item/food/donkpocket

/datum/recipe/microwave/warmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/donkpocket
	)
	result = /obj/item/food/warmdonkpocket

/datum/recipe/microwave/reheatwarmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/warmdonkpocket
	)
	result = /obj/item/food/warmdonkpocket

/datum/recipe/microwave/eggplantparm
	items = list(
		/obj/item/food/cheesewedge,
		/obj/item/food/cheesewedge,
		/obj/item/food/grown/eggplant
	)
	result = /obj/item/food/eggplantparm

/datum/recipe/microwave/soylentviridians
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/grown/soybeans
	)
	result = /obj/item/food/soylentviridians

/datum/recipe/microwave/soylentgreen
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/meat/human,
		/obj/item/food/meat/human
	)
	result = /obj/item/food/soylentgreen

/datum/recipe/microwave/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/dough
	)
	result = /obj/item/food/donut/chaos

/datum/recipe/microwave/cheesyfries
	items = list(
		/obj/item/food/fries,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/cheesyfries

/datum/recipe/microwave/cubancarp
	items = list(
		/obj/item/food/dough,
		/obj/item/food/carpmeat,
		/obj/item/food/grown/chili
	)
	result = /obj/item/food/cubancarp

/datum/recipe/microwave/cubancarp/make_food(obj/container)
	var/obj/item/food/cubancarp/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/popcorn
	items = list(
		/obj/item/food/grown/corn
	)
	result = /obj/item/food/popcorn

/datum/recipe/microwave/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/food/grown/mushroom/libertycap,
		/obj/item/food/grown/mushroom/libertycap,
		/obj/item/food/grown/mushroom/libertycap
	)
	result = /obj/item/food/spacylibertyduff

/datum/recipe/microwave/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/food/grown/mushroom/amanita,
		/obj/item/food/grown/mushroom/amanita,
		/obj/item/food/grown/mushroom/amanita
	)
	result = /obj/item/food/amanitajelly

/datum/recipe/microwave/amanitajelly/make_food(obj/container)
	var/obj/item/food/amanitajelly/being_cooked = ..()
	being_cooked.reagents.del_reagent("amanitin")
	return being_cooked

/datum/recipe/microwave/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/meatball,
		/obj/item/food/grown/potato,
		/obj/item/food/grown/carrot
	)
	result = /obj/item/food/soup/meatballsoup

/datum/recipe/microwave/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/potato,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/corn,
		/obj/item/food/grown/eggplant
	)
	result = /obj/item/food/soup/vegetablesoup

/datum/recipe/microwave/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/egg,
		/obj/item/grown/nettle/basic,
		/obj/item/food/grown/potato
	)
	result = /obj/item/food/soup/nettlesoup

/datum/recipe/microwave/wishsoup
	reagents = list("water" = 20)
	result = /obj/item/food/soup/wishsoup

/datum/recipe/microwave/hotchili
	items = list(
		/obj/item/food/meat,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/soup/hotchili

/datum/recipe/microwave/coldchili
	items = list(
		/obj/item/food/meat,
		/obj/item/food/grown/icepepper,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/soup/coldchili

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/food/bun,
		/obj/item/clothing/head/wizard
	)
	result = /obj/item/food/burger/spell

/datum/recipe/microwave/enchiladas
	items = list(
		/obj/item/food/cutlet,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/corn
	)
	result = /obj/item/food/enchiladas

/datum/recipe/microwave/burrito
	reagents = list("capsaicin" = 5, "rice" = 5)
	items = list(
		/obj/item/food/cutlet,
		/obj/item/food/beans,
		/obj/item/food/cheesewedge,
		/obj/item/food/sliceable/flatdough
	)
	result = /obj/item/food/burrito

/datum/recipe/microwave/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(
		/obj/item/food/monkeycube,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/monkeysdelight

/datum/recipe/microwave/fishandchips
	items = list(
		/obj/item/food/fries,
		/obj/item/food/carpmeat,
	)
	result = /obj/item/food/fishandchips

/datum/recipe/microwave/fishandchips/make_food(obj/container)
	var/obj/item/food/fishandchips/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/sandwich
	items = list(
		/obj/item/food/meatsteak,
		/obj/item/food/breadslice,
		/obj/item/food/breadslice,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/sandwich

/datum/recipe/microwave/tomatosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/soup/tomatosoup

/datum/recipe/microwave/stew
	reagents = list("water" = 10)
	items= list(
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/potato,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/eggplant,
		/obj/item/food/grown/mushroom,
		/obj/item/food/meat
	)
	result = /obj/item/food/soup/stew

/datum/recipe/microwave/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/breadslice,
	)
	result = /obj/item/food/jelliedtoast/slime

/datum/recipe/microwave/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/breadslice
	)
	result = /obj/item/food/jelliedtoast/cherry

/datum/recipe/microwave/misosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/soydope,
		/obj/item/food/soydope,
		/obj/item/food/tofu,
		/obj/item/food/tofu
	)
	result = /obj/item/food/soup/misosoup

/datum/recipe/microwave/stewedsoymeat
	items = list(
		/obj/item/food/soydope,
		/obj/item/food/soydope,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/stewedsoymeat

/datum/recipe/microwave/boiledspaghetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/spaghetti
	)
	result = /obj/item/food/boiledspaghetti

/datum/recipe/microwave/boiledrice
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/food/boiledrice

/datum/recipe/microwave/ricepudding
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/food/ricepudding

/datum/recipe/microwave/pastatomato
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/spaghetti,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato
	)
	result = /obj/item/food/pastatomato

/datum/recipe/microwave/poppypretzel
	items = list(
		/obj/item/seeds/poppy,
		/obj/item/food/dough
	)
	result = /obj/item/food/poppypretzel

/datum/recipe/microwave/meatballspaggetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/spaghetti,
		/obj/item/food/meatball,
		/obj/item/food/meatball,
	)
	result = /obj/item/food/meatballspaghetti

/datum/recipe/microwave/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/spaghetti,
		/obj/item/food/meatball,
		/obj/item/food/meatball,
		/obj/item/food/meatball,
		/obj/item/food/meatball,
	)
	result = /obj/item/food/spesslaw

/datum/recipe/microwave/macncheese
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/food/cheesewedge,
		/obj/item/food/macaroni,
	)
	result = /obj/item/food/macncheese

/datum/recipe/microwave/crazyburger
	reagents = list("cornoil" = 15)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat,
		/obj/item/food/meat,
		/obj/item/food/cheesewedge,
		/obj/item/food/cheesewedge,
		/obj/item/food/grown/lettuce,
		/obj/item/food/grown/chili,
		/obj/item/toy/crayon/green,
		/obj/item/flashlight/flare
	)
	result = /obj/item/food/burger/crazy

/datum/recipe/microwave/blt
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice,
		/obj/item/food/grown/lettuce,
		/obj/item/food/tomatoslice,
		/obj/item/food/bacon
	)
	result = /obj/item/food/blt

/datum/recipe/microwave/peanut_butter_jelly/cherry
	reagents = list("cherryjelly" = 5, "peanutbutter" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/peanut_butter_jelly/cherry

/datum/recipe/microwave/peanut_butter_jelly/slime
	reagents = list("slimejelly" = 5, "peanutbutter" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/peanut_butter_jelly/slime

/datum/recipe/microwave/peanut_butter_banana
	reagents = list("peanutbutter" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/peanut_butter_banana

/datum/recipe/microwave/philly_cheesesteak
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice,
		/obj/item/food/cutlet,
		/obj/item/food/cheesewedge,
		/obj/item/food/grown/onion
	)
	result = /obj/item/food/philly_cheesesteak

/datum/recipe/microwave/ppattyred
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/red

/datum/recipe/microwave/ppattyorange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/orange

/datum/recipe/microwave/ppattyyellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/yellow

/datum/recipe/microwave/ppattygreen
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/green

/datum/recipe/microwave/ppattyblue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/blue

/datum/recipe/microwave/ppattypurple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/purple

/datum/recipe/microwave/ppattywhite
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/bun,
		/obj/item/food/meat
	)
	result = /obj/item/food/burger/ppatty/white

/datum/recipe/microwave/ppattyrainbow
	items = list(
		/obj/item/food/burger/ppatty/red,
		/obj/item/food/burger/ppatty/orange,
		/obj/item/food/burger/ppatty/yellow,
		/obj/item/food/burger/ppatty/green,
		/obj/item/food/burger/ppatty/blue,
		/obj/item/food/burger/ppatty/purple,
		/obj/item/food/burger/ppatty/white
	)
	result = /obj/item/food/burger/ppatty/rainbow

/datum/recipe/microwave/elecburger
	items = list(
		/obj/item/food/bun,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/plasma
	)
	result = /obj/item/food/burger/elec

/datum/recipe/microwave/ratburger
	items = list(
		/obj/item/food/bun,
		/obj/item/holder/mouse
	)
	result = /obj/item/food/burger/rat

/datum/recipe/microwave/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(/obj/item/food/grown/apple)
	result = /obj/item/food/candiedapple

/datum/recipe/microwave/slimeburger
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/bun
	)
	result = /obj/item/food/burger/jelly/slime

/datum/recipe/microwave/jellyburger
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/bun
	)
	result = /obj/item/food/burger/jelly/cherry

/datum/recipe/microwave/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/twobread

/datum/recipe/microwave/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/jellysandwich/slime

/datum/recipe/microwave/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/jellysandwich/cherry

/datum/recipe/microwave/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/food/grown/tomato/blood,
		/obj/item/food/grown/tomato/blood
	)
	result = /obj/item/food/soup/bloodsoup

/datum/recipe/microwave/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	result = /obj/item/food/soup/slimesoup

/datum/recipe/microwave/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/stack/ore/bananium,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/soup/clownstears

/datum/recipe/microwave/clownchili
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/cutlet,
		/obj/item/food/cutlet,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/tomato,
		/obj/item/clothing/shoes/clown_shoes
	)
	result = /obj/item/food/soup/clownchili

/datum/recipe/microwave/eyesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/tomato,
		/obj/item/organ/internal/eyes
	)
	result = /obj/item/food/soup/eyesoup

/datum/recipe/microwave/sweetpotatosoup
	reagents = list("water" = 10, "milk" = 10)
	items = list(
		/obj/item/food/grown/potato/sweet,
		/obj/item/food/grown/potato/sweet
	)
	result = /obj/item/food/soup/sweetpotatosoup

/datum/recipe/microwave/redbeetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/redbeet,
		/obj/item/food/grown/redbeet,
		/obj/item/food/grown/cabbage
	)
	result = /obj/item/food/soup/redbeetsoup

/datum/recipe/microwave/frenchonionsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/onion,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/soup/frenchonionsoup

/datum/recipe/microwave/zurek
	reagents = list("water" = 10, "flour" = 10)
	items = list(
		/obj/item/food/boiledegg,
		/obj/item/food/sausage,
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/onion
	)
	result = /obj/item/food/soup/zurek

/datum/recipe/microwave/cullenskink
	reagents = list("water" = 10, "milk" = 10, "blackpepper" = 4)
	items = list(
		/obj/item/food/salmonmeat,
		/obj/item/food/grown/onion,
		/obj/item/food/grown/potato
	)
	result = /obj/item/food/soup/cullenskink

/datum/recipe/microwave/chicken_noodle_soup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/meat,
		/obj/item/food/grown/carrot,
		/obj/item/food/boiledspaghetti
	)
	result = /obj/item/food/soup/chicken_noodle_soup

/datum/recipe/microwave/cornchowder
	reagents = list("water" = 10, "cream" = 5)
	items = list(
		/obj/item/food/grown/corn,
		/obj/item/food/grown/potato,
		/obj/item/food/grown/carrot,
		/obj/item/food/bacon
	)
	result = /obj/item/food/soup/cornchowder

/datum/recipe/microwave/meatball_noodles
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/cutlet,
		/obj/item/food/cutlet,
		/obj/item/food/grown/onion,
		/obj/item/food/grown/peanuts,
		/obj/item/food/meatball,
		/obj/item/food/meatball,
		/obj/item/food/spaghetti
	)
	result = /obj/item/food/soup/meatball_noodles

/datum/recipe/microwave/seedsoup
	reagents = list("water" = 10, "vinegar" = 10)
	items = list(
		/obj/item/seeds/sunflower,
		/obj/item/seeds/poppy/lily,
		/obj/item/seeds/ambrosia
	)
	result = /obj/item/food/soup/seedsoup

/datum/recipe/microwave/beanstew
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/beans,
		/obj/item/food/grown/cabbage,
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/onion,
		/obj/item/food/grown/chili,
		/obj/item/food/grown/corn
	)
	result = /obj/item/food/soup/beanstew

/datum/recipe/microwave/oatstew
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/oat,
		/obj/item/food/grown/potato/sweet,
		/obj/item/food/grown/parsnip,
		/obj/item/food/grown/carrot
	)
	result = /obj/item/food/soup/oatstew

/datum/recipe/microwave/hong_kong_borscht
	reagents = list("water" = 10, "soysauce" = 5)
	items = list(
		/obj/item/food/grown/tomato,
		/obj/item/food/grown/cabbage,
		/obj/item/food/grown/onion,
		/obj/item/food/grown/carrot,
		/obj/item/food/cutlet
	)
	result = /obj/item/food/soup/hong_kong_borscht

/datum/recipe/microwave/hong_kong_macaroni
	reagents = list("water" = 10, "cream" = 10)
	items = list(
		/obj/item/food/boiledspaghetti,
		/obj/item/food/cutlet,
		/obj/item/food/bacon
	)
	result = /obj/item/food/soup/hong_kong_macaroni

/datum/recipe/microwave/boiledslimeextract
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/food/boiledslimecore

/datum/recipe/microwave/mint
	reagents = list("toxin" = 5)
	result = /obj/item/food/mint

/datum/recipe/microwave/chocolateegg
	items = list(
		/obj/item/food/egg,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/chocolateegg

/datum/recipe/microwave/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/badrecipe,
		/obj/item/food/tofu,
		/obj/item/food/egg,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/soup/mysterysoup

/datum/recipe/microwave/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/food/grown/mushroom
	)
	result = /obj/item/food/soup/mushroomsoup

/datum/recipe/microwave/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/food/egg,
		/obj/item/food/egg,
		/obj/item/food/grown/mushroom
	)
	result = /obj/item/food/chawanmushi

/datum/recipe/microwave/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/grown/whitebeet,
		/obj/item/food/grown/cabbage
	)
	result = /obj/item/food/soup/beetsoup

/datum/recipe/microwave/salad
	items = list(
		/obj/item/food/grown/lettuce,
		/obj/item/food/grown/lettuce
	)
	result = /obj/item/food/salad
/datum/recipe/microwave/antipasto_salad
	items = list(
		/obj/item/food/grown/lettuce,
		/obj/item/food/grown/lettuce,
		/obj/item/food/grown/olive,
		/obj/item/food/grown/tomato,
		/obj/item/food/cutlet,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/salad/antipasto

/datum/recipe/microwave/caesar_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/grown/lettuce,
		/obj/item/food/onion_slice/red,
		/obj/item/food/cheesewedge,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/salad/caesar

/datum/recipe/microwave/citrusdelight
	items = list(
		/obj/item/food/grown/citrus/lime,
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/grown/citrus/lemon
	)
	result = /obj/item/food/salad/citrusdelight

/datum/recipe/microwave/fruitsalad
	items = list(
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/grapes,
		/obj/item/food/watermelonslice
	)
	result = /obj/item/food/salad/fruit

/datum/recipe/microwave/greek_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/grown/olive,
		/obj/item/food/grown/tomato,
		/obj/item/food/onion_slice/red,
		/obj/item/food/onion_slice/red,
		/obj/item/food/cheesewedge,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/salad/greek

/datum/recipe/microwave/junglesalad
	items = list(
		/obj/item/food/grown/apple,
		/obj/item/food/grown/grapes,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/food/watermelonslice,
		/obj/item/food/watermelonslice
	)
	result = /obj/item/food/salad/jungle

/datum/recipe/microwave/kale_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/grown/carrot,
		/obj/item/food/grown/lettuce,
		/obj/item/food/onion_slice/red,
		/obj/item/food/onion_slice/red
	)
	result = /obj/item/food/salad/kale

/datum/recipe/microwave/potato_salad
	reagents = list("mayonnaise" = 5)
	items = list(
		/obj/item/food/grown/potato,
		/obj/item/food/grown/potato,
		/obj/item/food/boiledegg
	)
	result = /obj/item/food/salad/potato

/datum/recipe/microwave/melonfruitbowl
	items = list(
		/obj/item/food/grown/watermelon,
		/obj/item/food/grown/apple,
		/obj/item/food/grown/ambrosia,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/citrus/orange,
		/obj/item/food/grown/citrus/lemon
	)
	result = /obj/item/food/salad/melonfruitbowl


/datum/recipe/microwave/herbsalad
	items = list(
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/apple
	)
	result = /obj/item/food/salad/herb

/datum/recipe/microwave/herbsalad/make_food(obj/container)
	var/obj/item/food/salad/herb/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/aesirsalad
	items = list(
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/apple/gold
	)
	result = /obj/item/food/salad/aesir

/datum/recipe/microwave/validsalad
	items = list(
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/food/grown/potato,
		/obj/item/food/meatball
	)
	result = /obj/item/food/salad/valid

/datum/recipe/microwave/validsalad/make_food(obj/container)
	var/obj/item/food/salad/valid/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/food/friedegg,
		/obj/item/food/grown/cabbage
	)
	result = /obj/item/food/wrap

/datum/recipe/microwave/beans
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/food/grown/soybeans,
		/obj/item/food/grown/soybeans
	)
	result = /obj/item/food/beans

/datum/recipe/microwave/benedict
	items = list(
		/obj/item/food/friedegg,
		/obj/item/food/meatsteak,
		/obj/item/food/breadslice
	)
	result = /obj/item/food/benedict

/datum/recipe/microwave/meatbun
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/meatball,
		/obj/item/food/grown/cabbage
	)
	result = /obj/item/food/meatbun

/datum/recipe/microwave/icecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/food/frozen/icecream
	)
	result = /obj/item/food/frozen/icecreamsandwich

/datum/recipe/microwave/berryicecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/food/grown/cherries,
		/obj/item/food/grown/cherries,
		/obj/item/food/wafflecone
	)
	result = /obj/item/food/frozen/berryicecreamsandwich

/datum/recipe/microwave/sundae
	reagents = list("cream" = 5)
	items = list(
		/obj/item/food/wafflecone,
		/obj/item/food/grown/cherries,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/frozen/sundae

/datum/recipe/microwave/bananatopsicle
	reagents = list("sugar" = 5, "banana" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/tofu
	)
	result = /obj/item/food/frozen/popsicle/bananatop

/datum/recipe/microwave/berrytopsicle
	reagents = list("sugar" = 5, "berryjuice" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/tofu
	)
	result = /obj/item/food/frozen/popsicle/berrytop

/datum/recipe/microwave/pineappletopsicle
	reagents = list("sugar" = 5, "pineapplejuice" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/tofu
	)
	result = /obj/item/food/frozen/popsicle/pineappletop

/datum/recipe/microwave/licoricecreamsicle
	reagents = list("sugar" = 2, "blumpkinjuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/frozen/popsicle/licoricecream

/datum/recipe/microwave/orangecreamsicle
	reagents = list("sugar" = 2, "orangejuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/frozen/popsicle/orangecream

/datum/recipe/microwave/berrycreamsicle
	reagents = list("sugar" = 2, "berryjuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/frozen/popsicle/berrycream

/datum/recipe/microwave/frozenpineapplepop
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/pineappleslice,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/frozen/popsicle/frozenpineapple

/datum/recipe/microwave/jumboicecream
	reagents = list("sugar" = 2, "ice" = 2, "vanilla" = 3, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/frozen/popsicle

/datum/recipe/microwave/seasalticecream
	reagents = list("sugar" = 5, "sodiumchloride" = 3, "cream" = 5)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/frozen/popsicle/sea_salt

/datum/recipe/microwave/cornuto
	reagents = list("ice" = 2, "sugar" = 4, "cream" = 4)
	items = list(
		/obj/item/food/sliceable/flatdough,
		/obj/item/food/chocolatebar
	)
	result = /obj/item/food/frozen/cornuto

/datum/recipe/microwave/honkdae
	reagents = list("cream" = 5, "ice" = 5)
	items = list(
		/obj/item/food/wafflecone,
		/obj/item/food/grown/cherries,
		/obj/item/food/grown/banana,
		/obj/item/food/grown/banana,
		/obj/item/clothing/mask/gas/clown_hat
	)
	result = /obj/item/food/frozen/honkdae

/datum/recipe/microwave/peanutbuttermochi
	reagents = list("cream" = 5, "rice" = 5, "sugar" = 5, "peanutbutter" = 2)
	items = list(
		/obj/item/food/wafflecone
	)
	result = /obj/item/food/frozen/peanutbuttermochi

/datum/recipe/microwave/spacefreezy
	reagents = list("bluecherryjelly" = 5,"spacemountainwind" = 15)
	items = list(
		/obj/item/food/frozen/icecream
	)
	result = /obj/item/food/frozen/spacefreezy

/datum/recipe/microwave/snowcone/apple
	reagents = list("ice" = 15, "applejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/apple

/datum/recipe/microwave/snowcone/berry
	reagents = list("ice" = 15, "berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/berry

/datum/recipe/microwave/snowcone/bluecherry
	reagents = list("ice" = 15, "bluecherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/bluecherry
/datum/recipe/microwave/snowcone/cherry
	reagents = list("ice" = 15, "cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/cherry

/datum/recipe/microwave/snowcone/flavorless
	reagents = list("ice" = 15)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone

/datum/recipe/microwave/snowcone/fruitsalad
	reagents = list("ice" = 15, "banana" = 5, "orangejuice" = 5, "watermelonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/fruitsalad

/datum/recipe/microwave/snowcone/grape
	reagents = list("ice" = 15, "grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/grape

/datum/recipe/microwave/snowcone/honey
	reagents = list("ice" = 15, "honey" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/honey

/datum/recipe/microwave/snowcone/lemon
	reagents = list("ice" = 15, "lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/lemon

/datum/recipe/microwave/snowcone/lime
	reagents = list("ice" = 15, "limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/lime

/datum/recipe/microwave/snowcone/mime
	reagents = list("ice" = 15, "nothing" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/mime

/datum/recipe/microwave/snowcone/orange
	reagents = list("ice" = 15, "orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/orange

/datum/recipe/microwave/snowcone/pineapple
	reagents = list("ice" = 15, "pineapplejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/pineapple

/datum/recipe/microwave/snowcone/rainbow
	reagents = list("ice" = 15, "colorful_reagent" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/rainbow

/datum/recipe/microwave/snowcone/cola
	reagents = list("ice" = 15, "cola" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/cola

/datum/recipe/microwave/snowcone/spacemountainwind
	reagents = list("ice" = 15, "spacemountainwind" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/frozen/snowcone/spacemountain

/datum/recipe/microwave/antpopsicle
	reagents = list("sugar" = 5, "water" = 5, "ants" = 10)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/frozen/popsicle/ant

/datum/recipe/microwave/notasandwich
	items = list(
		/obj/item/food/breadslice,
		/obj/item/food/breadslice,
		/obj/item/clothing/mask/fakemoustache
	)
	result = /obj/item/food/notasandwich

/datum/recipe/microwave/friedbanana
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/food/dough,
		/obj/item/food/grown/banana
	)
	result = /obj/item/food/friedbanana

/datum/recipe/microwave/stuffing
	reagents = list("water" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/sliceable/bread
	)
	result = /obj/item/food/stuffing

/datum/recipe/microwave/boiledspiderleg
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/monstermeat/spiderleg
	)
	result = /obj/item/food/boiledspiderleg

/datum/recipe/microwave/boiledspiderleg/make_food(obj/container)
	var/obj/item/food/boiledspiderleg/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/food/monstermeat/spidereggs,
		/obj/item/food/monstermeat/spidermeat
	)
	result = /obj/item/food/spidereggsham

/datum/recipe/microwave/spidereggsham/make_food(obj/container)
	var/obj/item/food/spidereggsham/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/food/monstermeat/spidereggs,
		/obj/item/food/carpmeat
	)
	result = /obj/item/food/sashimi

/datum/recipe/microwave/sashimi/make_food(obj/container)
	var/obj/item/food/sashimi/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/mashedtaters
	reagents = list("gravy" = 5)
	items = list(
		/obj/item/food/grown/potato
	)
	result = /obj/item/food/mashed_potatoes

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/microwave/taco
	items = list(
		/obj/item/food/doughslice,
		/obj/item/food/cutlet,
		/obj/item/food/cheesewedge
	)
	result = /obj/item/food/taco

/datum/recipe/microwave/mint_2
	reagents = list("sugar" = 5, "frostoil" = 5)
	result = /obj/item/food/mint

/datum/recipe/microwave/boiled_shrimp
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/shrimp
	)
	result = /obj/item/food/boiled_shrimp

