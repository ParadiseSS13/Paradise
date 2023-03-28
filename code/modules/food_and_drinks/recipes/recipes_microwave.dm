

// see code/datums/recipe.dm

/datum/recipe/microwave/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/boiledegg

/datum/recipe/microwave/dionaroast
	reagents = list("facid" = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(/obj/item/holder/diona, /obj/item/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/reagent_containers/food/snacks/dionaroast

/datum/recipe/microwave/jellydonut
	reagents = list("berryjuice" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly

/datum/recipe/microwave/jellydonut/slime
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly

/datum/recipe/microwave/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly

/datum/recipe/microwave/donut
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut

/datum/recipe/microwave/donut/sprinkles
	reagents = list("sugar" = 5, "sprinkles" = 2)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/sprinkles

/datum/recipe/microwave/human/burger
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/human_burger

/datum/recipe/microwave/plainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat //do not place this recipe before /datum/recipe/microwave/human_burger
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger

/datum/recipe/microwave/syntiburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger

/datum/recipe/microwave/xenoburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/organ/internal/brain/xeno	)
	result = /obj/item/reagent_containers/food/snacks/xenoburger

/datum/recipe/microwave/brainburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/reagent_containers/food/snacks/brainburger

/datum/recipe/microwave/roburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/robot_parts/head
	)
	result = /obj/item/reagent_containers/food/snacks/roburger

/datum/recipe/microwave/fishburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/carpmeat
	)
	result = /obj/item/reagent_containers/food/snacks/fishburger

/datum/recipe/microwave/tofuburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/tofu
	)
	result = /obj/item/reagent_containers/food/snacks/tofuburger

/datum/recipe/microwave/ghostburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/reagent_containers/food/snacks/ghostburger

/datum/recipe/microwave/clownburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/mask/gas/clown_hat,
	)
	result = /obj/item/reagent_containers/food/snacks/clownburger

/datum/recipe/microwave/mimeburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/reagent_containers/food/snacks/mimeburger

/datum/recipe/microwave/baseballburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/melee/baseball_bat
	)
	result = /obj/item/reagent_containers/food/snacks/baseballburger

/datum/recipe/microwave/cheeseburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheeseburger

/datum/recipe/microwave/hotdog
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/sausage
	)
	result = /obj/item/reagent_containers/food/snacks/hotdog

/datum/recipe/microwave/donkpocket
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket

/datum/recipe/microwave/warmdonkpocket
	items = list(
		/obj/item/reagent_containers/food/snacks/donkpocket
	)
	result = /obj/item/reagent_containers/food/snacks/warmdonkpocket

/datum/recipe/microwave/eggplantparm
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm

/datum/recipe/microwave/soylentviridians
	reagents = list("flour" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/grown/soybeans)
	result = /obj/item/reagent_containers/food/snacks/soylentviridians

/datum/recipe/microwave/soylentgreen
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/human,
		/obj/item/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/reagent_containers/food/snacks/soylentgreen

/datum/recipe/microwave/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/donut/chaos

/datum/recipe/microwave/cheesyfries
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries

/datum/recipe/microwave/cubancarp
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/carpmeat,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/snacks/cubancarp

/datum/recipe/microwave/popcorn
	items = list(/obj/item/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/reagent_containers/food/snacks/popcorn

/datum/recipe/microwave/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap, /obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
				 /obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap)
	result = /obj/item/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/microwave/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita, /obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
				 /obj/item/reagent_containers/food/snacks/grown/mushroom/amanita)
	result = /obj/item/reagent_containers/food/snacks/amanitajelly

/datum/recipe/microwave/amanitajelly/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/amanitajelly/being_cooked = ..()
	being_cooked.reagents.del_reagent("amanitin")
	return being_cooked

//Soup
/datum/recipe/microwave/meatballsoup
	reagents = list("water" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/meatball, /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot)
	result = /obj/item/reagent_containers/food/snacks/soup/meatballsoup

/datum/recipe/microwave/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	result = /obj/item/reagent_containers/food/snacks/soup/slimesoup

/datum/recipe/microwave/bloodsoup
	reagents = list("blood" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/grown/tomato/blood, /obj/item/reagent_containers/food/snacks/grown/tomato/blood)
	result = /obj/item/reagent_containers/food/snacks/soup/bloodsoup

/datum/recipe/microwave/clownstears
	reagents = list("water" = 10)
	items = list(
		/obj/item/stack/ore/bananium,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/soup/clownstears

/datum/recipe/microwave/vegetablesoup
	reagents = list("water" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot,
				 /obj/item/reagent_containers/food/snacks/grown/corn, /obj/item/reagent_containers/food/snacks/grown/eggplant)
	result = /obj/item/reagent_containers/food/snacks/soup/vegetablesoup

/datum/recipe/microwave/nettlesoup
	reagents = list("water" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/egg, /obj/item/grown/nettle/basic, /obj/item/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/reagent_containers/food/snacks/soup/nettlesoup

/datum/recipe/microwave/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/badrecipe,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mysterysoup

/datum/recipe/microwave/tomatosoup
	reagents = list("water" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/grown/tomato, /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/soup/tomatosoup

/datum/recipe/microwave/rassolnik
	reagents = list("water" = 10, "rice" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/cucumber)
	result = /obj/item/reagent_containers/food/snacks/soup/rassolnik

/datum/recipe/microwave/wishsoup
	reagents = list("water" = 20)
	result= /obj/item/reagent_containers/food/snacks/soup/wishsoup

/datum/recipe/microwave/misosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/misosoup

/datum/recipe/microwave/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom)
	result = /obj/item/reagent_containers/food/snacks/soup/mushroomsoup

/datum/recipe/microwave/beetsoup
	reagents = list("water" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/grown/whitebeet, /obj/item/reagent_containers/food/snacks/grown/cabbage)
	result = /obj/item/reagent_containers/food/snacks/soup/beetsoup

/datum/recipe/microwave/stew
	reagents = list("water" = 10)
	items= list(/obj/item/reagent_containers/food/snacks/grown/tomato, /obj/item/reagent_containers/food/snacks/grown/potato,
				/obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/reagent_containers/food/snacks/grown/eggplant,
				/obj/item/reagent_containers/food/snacks/grown/mushroom, /obj/item/reagent_containers/food/snacks/meat)
	result = /obj/item/reagent_containers/food/snacks/soup/stew

/datum/recipe/microwave/stewedsoymeat
	items = list(/obj/item/reagent_containers/food/snacks/soydope, /obj/item/reagent_containers/food/snacks/soydope,
				 /obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/soup/stewedsoymeat

/datum/recipe/microwave/hotchili
	items = list(/obj/item/reagent_containers/food/snacks/meat, /obj/item/reagent_containers/food/snacks/grown/chili, /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/soup/hotchili

/datum/recipe/microwave/coldchili
	items = list(/obj/item/reagent_containers/food/snacks/meat, /obj/item/reagent_containers/food/snacks/grown/icepepper, /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/soup/coldchili

//Burger
/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/reagent_containers/food/snacks/spellburger

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/reagent_containers/food/snacks/spellburger

/datum/recipe/microwave/bigbiteburger
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeyburger,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/bigbiteburger

//===========
/datum/recipe/microwave/enchiladas
	items = list(/obj/item/reagent_containers/food/snacks/cutlet, /obj/item/reagent_containers/food/snacks/grown/chili, /obj/item/reagent_containers/food/snacks/grown/chili, /obj/item/reagent_containers/food/snacks/grown/corn)
	result = /obj/item/reagent_containers/food/snacks/enchiladas

/datum/recipe/microwave/burrito
	reagents = list("capsaicin" = 5, "rice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/beans,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/burrito

/datum/recipe/microwave/monkeysdelight
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/monkeycube, /obj/item/reagent_containers/food/snacks/grown/banana)
	result = /obj/item/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/microwave/fishandchips
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishandchips

/datum/recipe/microwave/sandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwich

/datum/recipe/microwave/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/microwave/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/microwave/boiledspaghetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledspaghetti

/datum/recipe/microwave/boiledrice
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/reagent_containers/food/snacks/boiledrice

/datum/recipe/microwave/ricepudding
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/reagent_containers/food/snacks/ricepudding

/datum/recipe/microwave/boiledbuckwheat
	reagents = list("water" = 5, "buckwheat" = 10)
	result = /obj/item/reagent_containers/food/snacks/boiledbuckwheat

/datum/recipe/microwave/buckwheat_merchant
	reagents = list("water" = 5, "buckwheat" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/meat
	)
	result = /obj/item/reagent_containers/food/snacks/buckwheat_merchant

/datum/recipe/microwave/pastatomato
	reagents = list("water" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/spaghetti, /obj/item/reagent_containers/food/snacks/grown/tomato,
				 /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/pastatomato

/datum/recipe/microwave/poppypretzel
	items = list(/obj/item/seeds/poppy, /obj/item/reagent_containers/food/snacks/dough)
	result = /obj/item/reagent_containers/food/snacks/poppypretzel

/datum/recipe/microwave/meatballspaggetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/meatballspaghetti

/datum/recipe/microwave/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/spesslaw

/datum/recipe/microwave/macncheese
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/macaroni,
	)
	result = /obj/item/reagent_containers/food/snacks/macncheese

/datum/recipe/microwave/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/superbiteburger

/datum/recipe/microwave/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/reagent_containers/food/snacks/candiedapple

/datum/recipe/microwave/slimeburger
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/jellyburger/slime

/datum/recipe/microwave/jellyburger
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/jellyburger/cherry

/datum/recipe/microwave/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/twobread

/datum/recipe/microwave/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/slime

/datum/recipe/microwave/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/cherry

/datum/recipe/microwave/boiledslimeextract
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledslimecore

/datum/recipe/microwave/mint
	reagents = list("toxin" = 5)
	result = /obj/item/reagent_containers/food/snacks/mint

/datum/recipe/microwave/chocolateegg
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/chocolateegg

/datum/recipe/microwave/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/mushroom
	)
	result = /obj/item/reagent_containers/food/snacks/chawanmushi

/datum/recipe/microwave/herbsalad
	items = list(/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris, /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
				 /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris, /obj/item/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/reagent_containers/food/snacks/herbsalad

/datum/recipe/microwave/herbsalad/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/herbsalad/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/aesirsalad
	items = list(/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus, /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
				 /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus, /obj/item/reagent_containers/food/snacks/grown/apple/gold)
	result = /obj/item/reagent_containers/food/snacks/aesirsalad

/datum/recipe/microwave/validsalad
	items = list(/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris, /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
				 /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris, /obj/item/reagent_containers/food/snacks/grown/potato,
				 /obj/item/reagent_containers/food/snacks/meatball)
	result = /obj/item/reagent_containers/food/snacks/validsalad

/datum/recipe/microwave/vegisalad
	reagents = list("cream" = 5, "sodiumchloride" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/grown/cucumber, /obj/item/reagent_containers/food/snacks/grown/tomato)
	result = /obj/item/reagent_containers/food/snacks/vegisalad

/datum/recipe/microwave/oliviersalad
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/pickles, /obj/item/reagent_containers/food/snacks/boiledegg,
				 /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot,
				 /obj/item/reagent_containers/food/snacks/sausage)
	result = /obj/item/reagent_containers/food/snacks/oliviersalad

/datum/recipe/microwave/weirdoliviersalad
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/pickles, /obj/item/reagent_containers/food/snacks/boiledegg,
				 /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/carrot,
				 /obj/item/reagent_containers/food/snacks/sausage, /obj/item/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/reagent_containers/food/snacks/weirdoliviersalad

/datum/recipe/microwave/validsalad/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/validsalad/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	reagents = list("soysauce" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/friedegg, /obj/item/reagent_containers/food/snacks/grown/cabbage )
	result = /obj/item/reagent_containers/food/snacks/wrap

/datum/recipe/microwave/beans
	reagents = list("ketchup" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/soybeans, /obj/item/reagent_containers/food/snacks/grown/soybeans)
	result = /obj/item/reagent_containers/food/snacks/beans

/datum/recipe/microwave/benedict
	items = list(
		/obj/item/reagent_containers/food/snacks/friedegg,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/benedict

/datum/recipe/microwave/meatbun
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/grown/cabbage
	)
	result = /obj/item/reagent_containers/food/snacks/meatbun

/datum/recipe/microwave/icecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/icecream,
	)
	result = /obj/item/reagent_containers/food/snacks/icecreamsandwich

/datum/recipe/microwave/notasandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
	)
	result = /obj/item/reagent_containers/food/snacks/notasandwich

/datum/recipe/microwave/friedbanana
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/friedbanana

/datum/recipe/microwave/stuffing
	reagents = list("water" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/bread,
	)
	result = /obj/item/reagent_containers/food/snacks/stuffing

/datum/recipe/microwave/boiledspiderleg
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg
	)
	result = /obj/item/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/microwave/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs,
		/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat
	)
	result = /obj/item/reagent_containers/food/snacks/spidereggsham

/datum/recipe/microwave/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sashimi

/datum/recipe/microwave/mashedtaters
	reagents = list("gravy" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/potato)
	result = /obj/item/reagent_containers/food/snacks/mashed_potatoes

/datum/recipe/microwave/shawarma
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/shawarma

/datum/recipe/microwave/doner_cheese
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/doner_cheese

/datum/recipe/microwave/doner_mushroom
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/doner_mushroom

/datum/recipe/microwave/doner_vegan
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/doner_vegan

/datum/recipe/microwave/kidan_ragu
	reagents = list("water" = 10, "sodiumchloride" = 1)
	items = list(
		/obj/item/organ/external/head/kidan,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/snacks/kidanragu

/datum/recipe/microwave/tomato_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/condiment/tomatosauce

/datum/recipe/microwave/diablo_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 2, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/condiment/diablosauce

/datum/recipe/microwave/cheese_sauce
	reagents = list("milk" = 15, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/condiment/cheesesauce

/datum/recipe/microwave/mushroom_sauce
	reagents = list("milk" = 15, "cream" = 5, "sodiumchloride" = 1,)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/onion,
		/obj/item/reagent_containers/food/snacks/grown/mushroom
	)
	result = /obj/item/reagent_containers/food/condiment/mushroomsauce

/datum/recipe/microwave/garlic_sauce
	reagents = list("water" = 15, "sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/cucumber
	)
	result = /obj/item/reagent_containers/food/condiment/garlicsauce

/datum/recipe/microwave/custard
	reagents = list("sugar" = 10, "milk" = 10, "cream" = 5, "vanilla" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/condiment/custard

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/microwave/taco
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/taco

/datum/recipe/microwave/mint_2
	reagents = list("sugar" = 5, "frostoil" = 5)
	result = /obj/item/reagent_containers/food/snacks/mint

/datum/recipe/microwave/boiled_shrimp
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp
	)
	result = /obj/item/reagent_containers/food/snacks/boiled_shrimp

//////////////////////////////////////////
//onyx bay food
//////////////////////////////////////////

/datum/recipe/microwave/pelmeni
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pelmeni
	)
	result = /obj/item/reagent_containers/food/snacks/boiledpelmeni

/datum/recipe/microwave/fruitcup
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/watermelon
	)
	result = /obj/item/reagent_containers/food/snacks/fruitcup

/datum/recipe/microwave/junglesalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/watermelon
	)
	result = /obj/item/reagent_containers/food/snacks/junglesalad

/datum/recipe/microwave/delightsalad
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
	)
	result = /obj/item/reagent_containers/food/snacks/delightsalad

/datum/recipe/microwave/chowmein
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledspaghetti,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/carrot
	)
	result = /obj/item/reagent_containers/food/snacks/chowmein

/datum/recipe/microwave/beefnoodles
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledspaghetti,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage
	)
	result = /obj/item/reagent_containers/food/snacks/beefnoodles

/datum/recipe/microwave/tortilla
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/corn
	)
	result = /obj/item/reagent_containers/food/snacks/tortilla

/datum/recipe/microwave/nachos
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla
	)
	result = /obj/item/reagent_containers/food/snacks/nachos

/datum/recipe/microwave/cheesenachos
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/cheesenachos

/datum/recipe/microwave/cubannachos
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/snacks/cubannachos

/datum/recipe/microwave/carneburrito
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet
	)
	result = /obj/item/reagent_containers/food/snacks/carneburrito

/datum/recipe/microwave/cheeseburrito
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/cheeseburrito

/datum/recipe/microwave/plasmaburrito
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/snacks/plasmaburrito

/datum/recipe/microwave/risotto
	reagents = list("wine" = 5, "rice" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/risotto

/datum/recipe/microwave/bruschetta
	reagents = list("sodiumchloride" = 2, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/garlic
	)
	result = /obj/item/reagent_containers/food/snacks/bruschetta

/datum/recipe/microwave/quiche
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/quiche
