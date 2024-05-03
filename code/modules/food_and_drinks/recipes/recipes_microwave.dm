

// see code/datums/recipe.dm

/datum/recipe/microwave/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/egg
	)
	result = /obj/item/food/snacks/boiledegg

/datum/recipe/microwave/dionaroast
	reagents = list("facid" = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(
		/obj/item/holder/diona,
		/obj/item/food/snacks/grown/apple
	)
	result = /obj/item/food/snacks/dionaroast

/datum/recipe/microwave/jellydonut
	reagents = list("berryjuice" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut/jelly

/datum/recipe/microwave/jellydonut/slime
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut/jelly/slimejelly

/datum/recipe/microwave/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut/jelly/cherryjelly

/datum/recipe/microwave/donut
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut

/datum/recipe/microwave/donut/sprinkles
	reagents = list("sugar" = 5, "sprinkles" = 2)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut/sprinkles

/datum/recipe/microwave/human/burger
	items = list(
		/obj/item/food/snacks/meat/human,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/bun
	)
	result = /obj/item/food/snacks/human/burger

/datum/recipe/microwave/plainburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/meat //do not place this recipe before /datum/recipe/microwave/human/burger
	)
	result = /obj/item/food/snacks/burger/plain

/datum/recipe/microwave/syntiburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/meat/syntiflesh
	)
	result = /obj/item/food/snacks/burger/plain

/datum/recipe/microwave/bigbiteburger
	items = list(
		/obj/item/food/snacks/burger/plain,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/burger/bigbite

/datum/recipe/microwave/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/food/snacks/burger/bigbite,
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/bacon,
		/obj/item/food/snacks/tomatoslice
	)
	result = /obj/item/food/snacks/burger/superbite

/datum/recipe/microwave/brainburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/food/snacks/burger/brain

/datum/recipe/microwave/hamborger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/robot_parts/head
	)
	result = /obj/item/food/snacks/burger/hamborger

/datum/recipe/microwave/xenoburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/food/snacks/burger/xeno

/datum/recipe/microwave/fishburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/carpmeat
	)
	result = /obj/item/food/snacks/fishburger

/datum/recipe/microwave/fishburger/make_food(obj/container)
	var/obj/item/food/snacks/fishburger/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/tofuburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/burger/tofu

/datum/recipe/microwave/ghostburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/food/snacks/burger/ghost

/datum/recipe/microwave/clownburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/clothing/mask/gas/clown_hat
	)
	result = /obj/item/food/snacks/burger/clown

/datum/recipe/microwave/mimeburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/food/snacks/burger/mime

/datum/recipe/microwave/baseballburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/melee/baseball_bat
	)
	result = /obj/item/food/snacks/burger/baseball

/datum/recipe/microwave/cheeseburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/burger/cheese

/datum/recipe/microwave/appendixburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/organ/internal/appendix
	)
	result = /obj/item/food/snacks/burger/appendix

/datum/recipe/microwave/appendixburger_bitten
	items = list(
		/obj/item/food/snacks/appendix,
		/obj/item/food/snacks/bun
	)
	result = /obj/item/food/snacks/burger/appendix

/datum/recipe/microwave/bearger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/monstermeat/bearmeat
	)
	result = /obj/item/food/snacks/burger/bearger

/datum/recipe/microwave/fivealarmburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/grown/ghost_chili,
		/obj/item/food/snacks/grown/ghost_chili,
		/obj/item/food/snacks/grown/lettuce
	)
	result = /obj/item/food/snacks/burger/fivealarm

/datum/recipe/microwave/baconburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/bacon,
		/obj/item/food/snacks/bacon,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/burger/bacon

/datum/recipe/microwave/mcrib
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/bbqribs,
		/obj/item/food/snacks/onion_slice
	)
	result = /obj/item/food/snacks/burger/mcrib

/datum/recipe/microwave/mcguffin
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/bacon,
		/obj/item/food/snacks/bacon,
		/obj/item/food/snacks/friedegg
	)
	result = /obj/item/food/snacks/burger/mcguffin

/datum/recipe/microwave/hotdog
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/sausage
	)
	result = /obj/item/food/snacks/hotdog

/datum/recipe/microwave/donkpocket
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meatball
	)
	result = /obj/item/food/snacks/donkpocket

/datum/recipe/microwave/warmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/snacks/donkpocket
	)
	result = /obj/item/food/snacks/warmdonkpocket

/datum/recipe/microwave/reheatwarmdonkpocket
	duplicate = FALSE
	items = list(
		/obj/item/food/snacks/warmdonkpocket
	)
	result = /obj/item/food/snacks/warmdonkpocket

/datum/recipe/microwave/eggplantparm
	items = list(
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/eggplant
	)
	result = /obj/item/food/snacks/eggplantparm

/datum/recipe/microwave/soylentviridians
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/snacks/grown/soybeans
	)
	result = /obj/item/food/snacks/soylentviridians

/datum/recipe/microwave/soylentgreen
	reagents = list("flour" = 10)
	items = list(
		/obj/item/food/snacks/meat/human,
		/obj/item/food/snacks/meat/human
	)
	result = /obj/item/food/snacks/soylentgreen

/datum/recipe/microwave/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/donut/chaos

/datum/recipe/microwave/cheesyfries
	items = list(
		/obj/item/food/snacks/fries,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/cheesyfries

/datum/recipe/microwave/cubancarp
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/carpmeat,
		/obj/item/food/snacks/grown/chili
	)
	result = /obj/item/food/snacks/cubancarp

/datum/recipe/microwave/cubancarp/make_food(obj/container)
	var/obj/item/food/snacks/cubancarp/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/popcorn
	items = list(
		/obj/item/food/snacks/grown/corn
	)
	result = /obj/item/food/snacks/popcorn

/datum/recipe/microwave/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/food/snacks/grown/mushroom/libertycap,
		/obj/item/food/snacks/grown/mushroom/libertycap,
		/obj/item/food/snacks/grown/mushroom/libertycap
	)
	result = /obj/item/food/snacks/spacylibertyduff

/datum/recipe/microwave/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/food/snacks/grown/mushroom/amanita,
		/obj/item/food/snacks/grown/mushroom/amanita,
		/obj/item/food/snacks/grown/mushroom/amanita
	)
	result = /obj/item/food/snacks/amanitajelly

/datum/recipe/microwave/amanitajelly/make_food(obj/container)
	var/obj/item/food/snacks/amanitajelly/being_cooked = ..()
	being_cooked.reagents.del_reagent("amanitin")
	return being_cooked

/datum/recipe/microwave/meatballsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot
	)
	result = /obj/item/food/snacks/soup/meatballsoup

/datum/recipe/microwave/vegetablesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/corn,
		/obj/item/food/snacks/grown/eggplant
	)
	result = /obj/item/food/snacks/soup/vegetablesoup

/datum/recipe/microwave/nettlesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/grown/nettle/basic,
		/obj/item/food/snacks/grown/potato
	)
	result = /obj/item/food/snacks/soup/nettlesoup

/datum/recipe/microwave/wishsoup
	reagents = list("water" = 20)
	result = /obj/item/food/snacks/soup/wishsoup

/datum/recipe/microwave/hotchili
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/soup/hotchili

/datum/recipe/microwave/coldchili
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/grown/icepepper,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/soup/coldchili

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/clothing/head/wizard/fake
	)
	result = /obj/item/food/snacks/burger/spell

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/clothing/head/wizard
	)
	result = /obj/item/food/snacks/burger/spell

/datum/recipe/microwave/enchiladas
	items = list(
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/corn
	)
	result = /obj/item/food/snacks/enchiladas

/datum/recipe/microwave/burrito
	reagents = list("capsaicin" = 5, "rice" = 5)
	items = list(
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/beans,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/sliceable/flatdough
	)
	result = /obj/item/food/snacks/burrito

/datum/recipe/microwave/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(
		/obj/item/food/snacks/monkeycube,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/monkeysdelight

/datum/recipe/microwave/fishandchips
	items = list(
		/obj/item/food/snacks/fries,
		/obj/item/food/snacks/carpmeat,
	)
	result = /obj/item/food/snacks/fishandchips

/datum/recipe/microwave/fishandchips/make_food(obj/container)
	var/obj/item/food/snacks/fishandchips/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	return being_cooked

/datum/recipe/microwave/sandwich
	items = list(
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/sandwich

/datum/recipe/microwave/tomatosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/soup/tomatosoup

/datum/recipe/microwave/stew
	reagents = list("water" = 10)
	items= list(
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/eggplant,
		/obj/item/food/snacks/grown/mushroom,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/soup/stew

/datum/recipe/microwave/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
	)
	result = /obj/item/food/snacks/jelliedtoast/slime

/datum/recipe/microwave/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/jelliedtoast/cherry

/datum/recipe/microwave/misosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/soydope,
		/obj/item/food/snacks/soydope,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/soup/misosoup

/datum/recipe/microwave/stewedsoymeat
	items = list(
		/obj/item/food/snacks/soydope,
		/obj/item/food/snacks/soydope,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/stewedsoymeat

/datum/recipe/microwave/boiledspaghetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/spaghetti
	)
	result = /obj/item/food/snacks/boiledspaghetti

/datum/recipe/microwave/boiledrice
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/food/snacks/boiledrice

/datum/recipe/microwave/ricepudding
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/food/snacks/ricepudding

/datum/recipe/microwave/pastatomato
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/spaghetti,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato
	)
	result = /obj/item/food/snacks/pastatomato

/datum/recipe/microwave/poppypretzel
	items = list(
		/obj/item/seeds/poppy,
		/obj/item/food/snacks/dough
	)
	result = /obj/item/food/snacks/poppypretzel

/datum/recipe/microwave/meatballspaggetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/spaghetti,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball,
	)
	result = /obj/item/food/snacks/meatballspaghetti

/datum/recipe/microwave/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/spaghetti,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball,
	)
	result = /obj/item/food/snacks/spesslaw

/datum/recipe/microwave/macncheese
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/macaroni,
	)
	result = /obj/item/food/snacks/macncheese

/datum/recipe/microwave/crazyburger
	reagents = list("cornoil" = 15)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/grown/chili,
		/obj/item/toy/crayon/green,
		/obj/item/flashlight/flare
	)
	result = /obj/item/food/snacks/burger/crazy

/datum/recipe/microwave/blt
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/tomatoslice,
		/obj/item/food/snacks/bacon
	)
	result = /obj/item/food/snacks/blt

/datum/recipe/microwave/peanut_butter_jelly/cherry
	reagents = list("cherryjelly" = 5, "peanutbutter" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/peanut_butter_jelly/cherry

/datum/recipe/microwave/peanut_butter_jelly/slime
	reagents = list("slimejelly" = 5, "peanutbutter" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/peanut_butter_jelly/slime

/datum/recipe/microwave/peanut_butter_banana
	reagents = list("peanutbutter" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/peanut_butter_banana

/datum/recipe/microwave/philly_cheesesteak
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/grown/onion
	)
	result = /obj/item/food/snacks/philly_cheesesteak

/datum/recipe/microwave/ppattyred
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/red

/datum/recipe/microwave/ppattyorange
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/orange

/datum/recipe/microwave/ppattyyellow
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/yellow

/datum/recipe/microwave/ppattygreen
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/green

/datum/recipe/microwave/ppattyblue
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/blue

/datum/recipe/microwave/ppattypurple
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/purple

/datum/recipe/microwave/ppattywhite
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/food/snacks/meat
	)
	result = /obj/item/food/snacks/burger/ppatty/white

/datum/recipe/microwave/ppattyrainbow
	items = list(
		/obj/item/food/snacks/burger/ppatty/red,
		/obj/item/food/snacks/burger/ppatty/orange,
		/obj/item/food/snacks/burger/ppatty/yellow,
		/obj/item/food/snacks/burger/ppatty/green,
		/obj/item/food/snacks/burger/ppatty/blue,
		/obj/item/food/snacks/burger/ppatty/purple,
		/obj/item/food/snacks/burger/ppatty/white
	)
	result = /obj/item/food/snacks/burger/ppatty/rainbow

/datum/recipe/microwave/elecburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/plasma
	)
	result = /obj/item/food/snacks/burger/elec

/datum/recipe/microwave/ratburger
	items = list(
		/obj/item/food/snacks/bun,
		/obj/item/holder/mouse
	)
	result = /obj/item/food/snacks/burger/rat

/datum/recipe/microwave/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(/obj/item/food/snacks/grown/apple)
	result = /obj/item/food/snacks/candiedapple

/datum/recipe/microwave/slimeburger
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/snacks/bun
	)
	result = /obj/item/food/snacks/burger/jelly/slime

/datum/recipe/microwave/jellyburger
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/snacks/bun
	)
	result = /obj/item/food/snacks/burger/jelly/cherry

/datum/recipe/microwave/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/twobread

/datum/recipe/microwave/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/jellysandwich/slime

/datum/recipe/microwave/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/jellysandwich/cherry

/datum/recipe/microwave/bloodsoup
	reagents = list("blood" = 10)
	items = list(
		/obj/item/food/snacks/grown/tomato/blood,
		/obj/item/food/snacks/grown/tomato/blood
	)
	result = /obj/item/food/snacks/soup/bloodsoup

/datum/recipe/microwave/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	result = /obj/item/food/snacks/soup/slimesoup

/datum/recipe/microwave/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/stack/ore/bananium,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/soup/clownstears

/datum/recipe/microwave/clownchili
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/clothing/shoes/clown_shoes
	)
	result = /obj/item/food/snacks/soup/clownchili

/datum/recipe/microwave/eyesoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/organ/internal/eyes
	)
	result = /obj/item/food/snacks/soup/eyesoup

/datum/recipe/microwave/sweetpotatosoup
	reagents = list("water" = 10, "milk" = 10)
	items = list(
		/obj/item/food/snacks/grown/potato/sweet,
		/obj/item/food/snacks/grown/potato/sweet
	)
	result = /obj/item/food/snacks/soup/sweetpotatosoup

/datum/recipe/microwave/redbeetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/redbeet,
		/obj/item/food/snacks/grown/redbeet,
		/obj/item/food/snacks/grown/cabbage
	)
	result = /obj/item/food/snacks/soup/redbeetsoup

/datum/recipe/microwave/frenchonionsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/soup/frenchonionsoup

/datum/recipe/microwave/zurek
	reagents = list("water" = 10, "flour" = 10)
	items = list(
		/obj/item/food/snacks/boiledegg,
		/obj/item/food/snacks/sausage,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/onion
	)
	result = /obj/item/food/snacks/soup/zurek

/datum/recipe/microwave/cullenskink
	reagents = list("water" = 10, "milk" = 10, "blackpepper" = 4)
	items = list(
		/obj/item/food/snacks/salmonmeat,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/potato
	)
	result = /obj/item/food/snacks/soup/cullenskink

/datum/recipe/microwave/chicken_noodle_soup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/meat,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/boiledspaghetti
	)
	result = /obj/item/food/snacks/soup/chicken_noodle_soup

/datum/recipe/microwave/cornchowder
	reagents = list("water" = 10, "cream" = 5)
	items = list(
		/obj/item/food/snacks/grown/corn,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/bacon
	)
	result = /obj/item/food/snacks/soup/cornchowder

/datum/recipe/microwave/meatball_noodles
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/peanuts,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/spaghetti
	)
	result = /obj/item/food/snacks/soup/meatball_noodles

/datum/recipe/microwave/seedsoup
	reagents = list("water" = 10, "vinegar" = 10)
	items = list(
		/obj/item/seeds/sunflower,
		/obj/item/seeds/poppy/lily,
		/obj/item/seeds/ambrosia
	)
	result = /obj/item/food/snacks/soup/seedsoup

/datum/recipe/microwave/beanstew
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/beans,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/chili,
		/obj/item/food/snacks/grown/corn
	)
	result = /obj/item/food/snacks/soup/beanstew

/datum/recipe/microwave/oatstew
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/oat,
		/obj/item/food/snacks/grown/potato/sweet,
		/obj/item/food/snacks/grown/parsnip,
		/obj/item/food/snacks/grown/carrot
	)
	result = /obj/item/food/snacks/soup/oatstew

/datum/recipe/microwave/hong_kong_borscht
	reagents = list("water" = 10, "soysauce" = 5)
	items = list(
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/grown/cabbage,
		/obj/item/food/snacks/grown/onion,
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/cutlet
	)
	result = /obj/item/food/snacks/soup/hong_kong_borscht

/datum/recipe/microwave/hong_kong_macaroni
	reagents = list("water" = 10, "cream" = 10)
	items = list(
		/obj/item/food/snacks/boiledspaghetti,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/bacon
	)
	result = /obj/item/food/snacks/soup/hong_kong_macaroni

/datum/recipe/microwave/boiledslimeextract
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/food/snacks/boiledslimecore

/datum/recipe/microwave/mint
	reagents = list("toxin" = 5)
	result = /obj/item/food/snacks/mint

/datum/recipe/microwave/chocolateegg
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/chocolatebar
	)
	result = /obj/item/food/snacks/chocolateegg

/datum/recipe/microwave/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/badrecipe,
		/obj/item/food/snacks/tofu,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/soup/mysterysoup

/datum/recipe/microwave/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/food/snacks/grown/mushroom
	)
	result = /obj/item/food/snacks/soup/mushroomsoup

/datum/recipe/microwave/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/egg,
		/obj/item/food/snacks/grown/mushroom
	)
	result = /obj/item/food/snacks/chawanmushi

/datum/recipe/microwave/beetsoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/grown/whitebeet,
		/obj/item/food/snacks/grown/cabbage
	)
	result = /obj/item/food/snacks/soup/beetsoup

/datum/recipe/microwave/salad
	items = list(
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/grown/lettuce
	)
	result = /obj/item/food/snacks/salad
/datum/recipe/microwave/antipasto_salad
	items = list(
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/grown/olive,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/salad/antipasto

/datum/recipe/microwave/caesar_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/onion_slice/red,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/salad/caesar

/datum/recipe/microwave/citrusdelight
	items = list(
		/obj/item/food/snacks/grown/citrus/lime,
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/food/snacks/salad/citrusdelight

/datum/recipe/microwave/fruitsalad
	items = list(
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/grapes,
		/obj/item/food/snacks/watermelonslice
	)
	result = /obj/item/food/snacks/salad/fruit

/datum/recipe/microwave/greek_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/snacks/grown/olive,
		/obj/item/food/snacks/grown/tomato,
		/obj/item/food/snacks/onion_slice/red,
		/obj/item/food/snacks/onion_slice/red,
		/obj/item/food/snacks/cheesewedge,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/salad/greek

/datum/recipe/microwave/junglesalad
	items = list(
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/grapes,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/watermelonslice,
		/obj/item/food/snacks/watermelonslice
	)
	result = /obj/item/food/snacks/salad/jungle

/datum/recipe/microwave/kale_salad
	reagents = list("oliveoil" = 5)
	items = list(
		/obj/item/food/snacks/grown/carrot,
		/obj/item/food/snacks/grown/lettuce,
		/obj/item/food/snacks/onion_slice/red,
		/obj/item/food/snacks/onion_slice/red
	)
	result = /obj/item/food/snacks/salad/kale

/datum/recipe/microwave/potato_salad
	reagents = list("mayonnaise" = 5)
	items = list(
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/boiledegg
	)
	result = /obj/item/food/snacks/salad/potato

/datum/recipe/microwave/melonfruitbowl
	items = list(
		/obj/item/food/snacks/grown/watermelon,
		/obj/item/food/snacks/grown/apple,
		/obj/item/food/snacks/grown/ambrosia,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/citrus/orange,
		/obj/item/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/food/snacks/salad/melonfruitbowl


/datum/recipe/microwave/herbsalad
	items = list(
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/apple
	)
	result = /obj/item/food/snacks/salad/herb

/datum/recipe/microwave/herbsalad/make_food(obj/container)
	var/obj/item/food/snacks/salad/herb/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/aesirsalad
	items = list(
		/obj/item/food/snacks/grown/ambrosia/deus,
		/obj/item/food/snacks/grown/ambrosia/deus,
		/obj/item/food/snacks/grown/ambrosia/deus,
		/obj/item/food/snacks/grown/apple/gold
	)
	result = /obj/item/food/snacks/salad/aesir

/datum/recipe/microwave/validsalad
	items = list(
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/food/snacks/grown/potato,
		/obj/item/food/snacks/meatball
	)
	result = /obj/item/food/snacks/salad/valid

/datum/recipe/microwave/validsalad/make_food(obj/container)
	var/obj/item/food/snacks/salad/valid/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/food/snacks/friedegg,
		/obj/item/food/snacks/grown/cabbage
	)
	result = /obj/item/food/snacks/wrap

/datum/recipe/microwave/beans
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/food/snacks/grown/soybeans,
		/obj/item/food/snacks/grown/soybeans
	)
	result = /obj/item/food/snacks/beans

/datum/recipe/microwave/benedict
	items = list(
		/obj/item/food/snacks/friedegg,
		/obj/item/food/snacks/meatsteak,
		/obj/item/food/snacks/breadslice
	)
	result = /obj/item/food/snacks/benedict

/datum/recipe/microwave/meatbun
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/meatball,
		/obj/item/food/snacks/grown/cabbage
	)
	result = /obj/item/food/snacks/meatbun

/datum/recipe/microwave/icecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/food/snacks/frozen/icecream
	)
	result = /obj/item/food/snacks/frozen/icecreamsandwich

/datum/recipe/microwave/berryicecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/food/snacks/grown/cherries,
		/obj/item/food/snacks/grown/cherries,
		/obj/item/food/snacks/wafflecone
	)
	result = /obj/item/food/snacks/frozen/berryicecreamsandwich

/datum/recipe/microwave/sundae
	reagents = list("cream" = 5)
	items = list(
		/obj/item/food/snacks/wafflecone,
		/obj/item/food/snacks/grown/cherries,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/frozen/sundae

/datum/recipe/microwave/bananatopsicle
	reagents = list("sugar" = 5, "banana" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/frozen/popsicle/bananatop

/datum/recipe/microwave/berrytopsicle
	reagents = list("sugar" = 5, "berryjuice" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/frozen/popsicle/berrytop

/datum/recipe/microwave/pineappletopsicle
	reagents = list("sugar" = 5, "pineapplejuice" = 5)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/snacks/tofu
	)
	result = /obj/item/food/snacks/frozen/popsicle/pineappletop

/datum/recipe/microwave/licoricecreamsicle
	reagents = list("sugar" = 2, "blumpkinjuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/snacks/frozen/popsicle/licoricecream

/datum/recipe/microwave/orangecreamsicle
	reagents = list("sugar" = 2, "orangejuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/snacks/frozen/popsicle/orangecream

/datum/recipe/microwave/berrycreamsicle
	reagents = list("sugar" = 2, "berryjuice" = 4, "ice" = 2, "vanilla" = 2, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/snacks/frozen/popsicle/berrycream

/datum/recipe/microwave/frozenpineapplepop
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/snacks/pineappleslice,
		/obj/item/food/snacks/chocolatebar
	)
	result = /obj/item/food/snacks/frozen/popsicle/frozenpineapple

/datum/recipe/microwave/jumboicecream
	reagents = list("sugar" = 2, "ice" = 2, "vanilla" = 3, "cream" = 2)
	items = list(
		/obj/item/popsicle_stick,
		/obj/item/food/snacks/chocolatebar
	)
	result = /obj/item/food/snacks/frozen/popsicle

/datum/recipe/microwave/seasalticecream
	reagents = list("sugar" = 5, "sodiumchloride" = 3, "cream" = 5)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/snacks/frozen/popsicle/sea_salt

/datum/recipe/microwave/cornuto
	reagents = list("ice" = 2, "sugar" = 4, "cream" = 4)
	items = list(
		/obj/item/food/snacks/sliceable/flatdough,
		/obj/item/food/snacks/chocolatebar
	)
	result = /obj/item/food/snacks/frozen/cornuto

/datum/recipe/microwave/honkdae
	reagents = list("cream" = 5, "ice" = 5)
	items = list(
		/obj/item/food/snacks/wafflecone,
		/obj/item/food/snacks/grown/cherries,
		/obj/item/food/snacks/grown/banana,
		/obj/item/food/snacks/grown/banana,
		/obj/item/clothing/mask/gas/clown_hat
	)
	result = /obj/item/food/snacks/frozen/honkdae

/datum/recipe/microwave/peanutbuttermochi
	reagents = list("cream" = 5, "rice" = 5, "sugar" = 5, "peanutbutter" = 2)
	items = list(
		/obj/item/food/snacks/wafflecone
	)
	result = /obj/item/food/snacks/frozen/peanutbuttermochi

/datum/recipe/microwave/spacefreezy
	reagents = list("bluecherryjelly" = 5,"spacemountainwind" = 15)
	items = list(
		/obj/item/food/snacks/frozen/icecream
	)
	result = /obj/item/food/snacks/frozen/spacefreezy

/datum/recipe/microwave/snowcone/apple
	reagents = list("ice" = 15, "applejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/apple

/datum/recipe/microwave/snowcone/berry
	reagents = list("ice" = 15, "berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/berry

/datum/recipe/microwave/snowcone/bluecherry
	reagents = list("ice" = 15, "bluecherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/bluecherry
/datum/recipe/microwave/snowcone/cherry
	reagents = list("ice" = 15, "cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/cherry

/datum/recipe/microwave/snowcone/flavorless
	reagents = list("ice" = 15)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone

/datum/recipe/microwave/snowcone/fruitsalad
	reagents = list("ice" = 15, "orangejuice" = 5, "limejuice" = 5, "lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/fruitsalad

/datum/recipe/microwave/snowcone/grape
	reagents = list("ice" = 15, "grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/grape

/datum/recipe/microwave/snowcone/honey
	reagents = list("ice" = 15, "honey" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/honey

/datum/recipe/microwave/snowcone/lemon
	reagents = list("ice" = 15, "lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/lemon

/datum/recipe/microwave/snowcone/lime
	reagents = list("ice" = 15, "limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/lime

/datum/recipe/microwave/snowcone/mime
	reagents = list("ice" = 15, "nothing" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/mime

/datum/recipe/microwave/snowcone/orange
	reagents = list("ice" = 15, "orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/orange

/datum/recipe/microwave/snowcone/pineapple
	reagents = list("ice" = 15, "pineapplejuice" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/pineapple

/datum/recipe/microwave/snowcone/rainbow
	reagents = list("ice" = 15, "colorful_reagent" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/rainbow

/datum/recipe/microwave/snowcone/cola
	reagents = list("ice" = 15, "cola" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/cola

/datum/recipe/microwave/snowcone/spacemountainwind
	reagents = list("ice" = 15, "spacemountainwind" = 5)
	items = list(
		/obj/item/reagent_containers/drinks/sillycup
	)
	result = /obj/item/food/snacks/frozen/snowcone/spacemountain

/datum/recipe/microwave/antpopsicle
	reagents = list("sugar" = 5, "water" = 5, "ants" = 10)
	items = list(
		/obj/item/popsicle_stick
	)
	result = /obj/item/food/snacks/frozen/popsicle/ant

/datum/recipe/microwave/notasandwich
	items = list(
		/obj/item/food/snacks/breadslice,
		/obj/item/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache
	)
	result = /obj/item/food/snacks/notasandwich

/datum/recipe/microwave/friedbanana
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/food/snacks/dough,
		/obj/item/food/snacks/grown/banana
	)
	result = /obj/item/food/snacks/friedbanana

/datum/recipe/microwave/stuffing
	reagents = list("water" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/food/snacks/sliceable/bread
	)
	result = /obj/item/food/snacks/stuffing

/datum/recipe/microwave/boiledspiderleg
	reagents = list("water" = 10)
	items = list(
		/obj/item/food/snacks/monstermeat/spiderleg
	)
	result = /obj/item/food/snacks/boiledspiderleg

/datum/recipe/microwave/boiledspiderleg/make_food(obj/container)
	var/obj/item/food/snacks/boiledspiderleg/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/food/snacks/monstermeat/spidereggs,
		/obj/item/food/snacks/monstermeat/spidermeat
	)
	result = /obj/item/food/snacks/spidereggsham

/datum/recipe/microwave/spidereggsham/make_food(obj/container)
	var/obj/item/food/snacks/spidereggsham/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/food/snacks/monstermeat/spidereggs,
		/obj/item/food/snacks/carpmeat
	)
	result = /obj/item/food/snacks/sashimi

/datum/recipe/microwave/sashimi/make_food(obj/container)
	var/obj/item/food/snacks/sashimi/being_cooked = ..()
	being_cooked.reagents.del_reagent("carpotoxin")
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/mashedtaters
	reagents = list("gravy" = 5)
	items = list(
		/obj/item/food/snacks/grown/potato
	)
	result = /obj/item/food/snacks/mashed_potatoes

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/microwave/taco
	items = list(
		/obj/item/food/snacks/doughslice,
		/obj/item/food/snacks/cutlet,
		/obj/item/food/snacks/cheesewedge
	)
	result = /obj/item/food/snacks/taco

/datum/recipe/microwave/mint_2
	reagents = list("sugar" = 5, "frostoil" = 5)
	result = /obj/item/food/snacks/mint

/datum/recipe/microwave/boiled_shrimp
	reagents = list("water" = 5)
	items = list(
		/obj/item/food/snacks/shrimp
	)
	result = /obj/item/food/snacks/boiled_shrimp
