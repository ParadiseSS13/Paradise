

// see code/datums/recipe.dm

/datum/recipe/microwave/boiledegg
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledegg

/datum/recipe/microwave/dionaroast
	fruit = list("apple" = 1)
	reagents = list("facid" = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(
		/obj/item/weapon/holder/diona,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/dionaroast

/datum/recipe/microwave/jellydonut
	reagents = list("berryjuice" = 5, "sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/jelly

/datum/recipe/microwave/jellydonut/slime
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/slimejelly

/datum/recipe/microwave/jellydonut/cherry
	reagents = list("cherryjelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/cherryjelly

/datum/recipe/microwave/donut
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/normal

/datum/recipe/microwave/donut/sprinkles
	reagents = list("sugar" = 5, "sprinkles" = 3)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/sprinkles

/datum/recipe/microwave/human/burger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/bun
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/human/burger

/datum/recipe/microwave/plainburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/meat //do not place this recipe before /datum/recipe/microwave/humanburger
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger

/datum/recipe/microwave/syntiburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeyburger

/datum/recipe/microwave/brainburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/brainburger

/datum/recipe/microwave/roburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/robot_parts/head
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/roburger

/datum/recipe/microwave/xenoburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/xenomeat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/xenoburger

/datum/recipe/microwave/fishburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishburger

/datum/recipe/microwave/tofuburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/tofu
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofuburger

/datum/recipe/microwave/ghostburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/ectoplasm //where do you even find this stuff
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/ghostburger

/datum/recipe/microwave/clownburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/clothing/mask/gas/clown_hat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownburger

/datum/recipe/microwave/mimeburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/beret
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/mimeburger

/datum/recipe/microwave/hotdog
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun,
		/obj/item/weapon/reagent_containers/food/snacks/sausage
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotdog

/datum/recipe/microwave/donkpocket
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/weapon/reagent_containers/food/snacks/meatball
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donkpocket

/datum/recipe/microwave/warmdonkpocket
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/donkpocket
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/warmdonkpocket

/datum/recipe/microwave/eggplantparm
	fruit = list("eggplant" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/eggplantparm

/datum/recipe/microwave/soylenviridians
	fruit = list("soybeans" = 1)
	reagents = list("flour" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylenviridians

/datum/recipe/microwave/soylentgreen
	reagents = list("flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
		/obj/item/weapon/reagent_containers/food/snacks/meat/human,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/soylentgreen

/datum/recipe/microwave/chaosdonut
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/donut/chaos

/datum/recipe/microwave/cheesyfries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cheesyfries

/datum/recipe/microwave/cubancarp
	fruit = list("chili" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/cubancarp

/datum/recipe/microwave/popcorn
	fruit = list("corn" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/popcorn

/datum/recipe/microwave/spacylibertyduff
	reagents = list("water" = 5, "vodka" = 5)
	fruit = list("libertycap" = 3)
	result = /obj/item/weapon/reagent_containers/food/snacks/spacylibertyduff

/datum/recipe/microwave/amanitajelly
	reagents = list("water" = 5, "vodka" = 5)
	fruit = list("amanita" = 3)
	result = /obj/item/weapon/reagent_containers/food/snacks/amanitajelly
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/amanitajelly/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("amanitin")
		return being_cooked

/datum/recipe/microwave/meatballsoup
	reagents = list("water" = 10)
	fruit = list("potato" = 1, "carrot" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatball ,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballsoup

/datum/recipe/microwave/vegetablesoup
	reagents = list("water" = 10)
	fruit = list("carrot" = 1, "corn" = 1, "eggplant" = 1, "potato" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/vegetablesoup

/datum/recipe/microwave/nettlesoup
	reagents = list("water" = 10)
	fruit = list("nettle" = 1, "potato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/nettlesoup

/datum/recipe/microwave/wishsoup
	reagents = list("water" = 20)
	result= /obj/item/weapon/reagent_containers/food/snacks/wishsoup

/datum/recipe/microwave/hotchili
	fruit = list("chili" = 1, "tomato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/hotchili

/datum/recipe/microwave/coldchili
	fruit = list("icechili" = 1, "tomato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/coldchili

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeyburger,
		/obj/item/clothing/head/wizard/fake,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spellburger

/datum/recipe/microwave/spellburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeyburger,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spellburger

/datum/recipe/microwave/bigbiteburger
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeyburger,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/bigbiteburger

/datum/recipe/microwave/enchiladas
	fruit = list("chili" = 2, "corn" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/enchiladas

/datum/recipe/microwave/burrito
	reagents = list("capsaicin" = 5, "rice" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/cutlet,
		/obj/item/weapon/reagent_containers/food/snacks/beans,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/burrito

/datum/recipe/microwave/monkeysdelight
	fruit = list("banana" = 1)
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/monkeysdelight

/datum/recipe/microwave/fishandchips
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/fries,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fishandchips

/datum/recipe/microwave/sandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sandwich

/datum/recipe/microwave/toastedsandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/sandwich
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/microwave/tomatosoup
	reagents = list("water" = 10)
	fruit = list("tomato" = 2)
	result = /obj/item/weapon/reagent_containers/food/snacks/tomatosoup

/datum/recipe/microwave/stew
	reagents = list("water" = 10)
	fruit = list("tomato" = 1, "potato" = 1, "carrot" = 1, "eggplant" = 1, "mushroom" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stew

/datum/recipe/microwave/slimetoast
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/slime

/datum/recipe/microwave/jelliedtoast
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jelliedtoast/cherry

/datum/recipe/microwave/milosoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/milosoup

/datum/recipe/microwave/stewedsoymeat
	fruit = list("carrot" = 1, "tomato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
		/obj/item/weapon/reagent_containers/food/snacks/soydope,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stewedsoymeat

/datum/recipe/microwave/boiledspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspagetti

/datum/recipe/microwave/boiledrice
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledrice

/datum/recipe/microwave/ricepudding
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/weapon/reagent_containers/food/snacks/ricepudding

/datum/recipe/microwave/pastatomato
	reagents = list("water" = 5)
	fruit = list("tomato" = 2)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/pastatomato

/datum/recipe/microwave/poppypretzel
	items = list(
		/obj/item/seeds/poppyseed,
		/obj/item/weapon/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/poppypretzel

/datum/recipe/microwave/meatballspagetti
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatballspagetti

/datum/recipe/microwave/spesslaw
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spagetti,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spesslaw

/datum/recipe/microwave/superbiteburger
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	fruit = list("tomato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
		/obj/item/weapon/reagent_containers/food/snacks/boiledegg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/superbiteburger

/datum/recipe/microwave/candiedapple
	reagents = list("water" = 5, "sugar" = 5)
	fruit = list("apple" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/candiedapple

/datum/recipe/microwave/slimeburger
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/slime

/datum/recipe/microwave/jellyburger
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/bun
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellyburger/cherry

/datum/recipe/microwave/twobread
	reagents = list("wine" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/twobread

datum/recipe/microwave/slimesandwich
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/slime

/datum/recipe/microwave/cherrysandwich
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/jellysandwich/cherry

/datum/recipe/microwave/bloodsoup
	reagents = list("blood" = 10)
	fruit = list("bloodtomato" = 2)
	result = /obj/item/weapon/reagent_containers/food/snacks/bloodsoup

/datum/recipe/microwave/slimesoup
	reagents = list("water" = 10, "slimejelly" = 5)
	items = list()
	result = /obj/item/weapon/reagent_containers/food/snacks/slimesoup

/datum/recipe/microwave/clownstears
	reagents = list("water" = 10)
	fruit = list("banana" = 1)
	items = list(
		/obj/item/weapon/ore/bananium,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/clownstears

/datum/recipe/microwave/boiledslimeextract
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledslimecore

/datum/recipe/microwave/mint
	reagents = list("toxin" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/mint

/datum/recipe/microwave/chocolateegg
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chocolateegg

/datum/recipe/microwave/mysterysoup
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/badrecipe,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/mysterysoup

/datum/recipe/microwave/mushroomsoup
	reagents = list("water" = 5, "milk" = 5)
	fruit = list("mushroom" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/mushroomsoup

/datum/recipe/microwave/chawanmushi
	reagents = list("water" = 5, "soysauce" = 5)
	fruit = list("mushroom" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/egg,
		/obj/item/weapon/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/chawanmushi

/datum/recipe/microwave/beetsoup
	reagents = list("water" = 10)
	fruit = list("whitebeet" = 1, "cabbage" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/beetsoup

/datum/recipe/microwave/herbsalad
	fruit = list("ambrosia" = 3, "apple" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/herbsalad
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/herbsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

/datum/recipe/microwave/aesirsalad
	fruit = list("ambrosiadeus" = 3, "goldapple" = 1)
	result = /obj/item/weapon/reagent_containers/food/snacks/aesirsalad

/datum/recipe/microwave/validsalad
	fruit = list("ambrosia" = 3, "potato" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/validsalad
	make_food(var/obj/container as obj)
		var/obj/item/weapon/reagent_containers/food/snacks/validsalad/being_cooked = ..(container)
		being_cooked.reagents.del_reagent("toxin")
		return being_cooked

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	reagents = list("soysauce" = 10)
	fruit = list("cabbage" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/wrap

/datum/recipe/microwave/beans
	reagents = list("ketchup" = 5)
	fruit = list("soybeans" = 2)
	result = /obj/item/weapon/reagent_containers/food/snacks/beans

/datum/recipe/microwave/benedict
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/friedegg,
		/obj/item/weapon/reagent_containers/food/snacks/meatsteak,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/benedict

/datum/recipe/microwave/meatbun
	reagents = list("soysauce" = 5)
	fruit = list("cabbage" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough,
		/obj/item/weapon/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatbun

/datum/recipe/microwave/icecreamsandwich
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/icecream,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/icecreamsandwich

/datum/recipe/microwave/notasandwich
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/weapon/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/notasandwich

/datum/recipe/microwave/friedbanana
	reagents = list("sugar" = 10, "cornoil" = 5)
	fruit = list("banana" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/friedbanana

/datum/recipe/microwave/stuffing
	reagents = list("water" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/sliceable/bread,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/stuffing

/datum/recipe/microwave/tofurkey
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/tofu,
		/obj/item/weapon/reagent_containers/food/snacks/stuffing,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/tofurkey

/datum/recipe/microwave/boiledspiderleg
	reagents = list("water" = 10)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spiderleg,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiledspiderleg

/datum/recipe/microwave/spidereggsham
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/spidermeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/spidereggsham

/datum/recipe/microwave/sashimi
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/spidereggs,
		/obj/item/weapon/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/sashimi

/datum/recipe/microwave/mashedtaters
	fruit = list("potato" = 1)
	reagents = list("gravy" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/mashed_potatoes

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/microwave/taco
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/doughslice,
		/obj/item/weapon/reagent_containers/food/snacks/cutlet,
		/obj/item/weapon/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/taco

/datum/recipe/microwave/meatball
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawmeatball
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/meatball

/datum/recipe/microwave/fries
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/rawsticks
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/fries

/datum/recipe/microwave/mint_2
	reagents = list("sugar" = 5, "frostoil" = 5)
	result = /obj/item/weapon/reagent_containers/food/snacks/mint

/datum/recipe/microwave/boiled_shrimp
	reagents = list("water" = 5)
	items = list(
		/obj/item/weapon/reagent_containers/food/snacks/shrimp
	)
	result = /obj/item/weapon/reagent_containers/food/snacks/boiled_shrimp
