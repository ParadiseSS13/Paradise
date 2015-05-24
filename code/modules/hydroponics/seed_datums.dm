// Chili plants/variants.
/datum/seed/chili
	name = "chili"
	seed_name = "chili"
	display_name = "chili plants"
	chems = list("capsaicin" = list(3,5), "plantmatter" = list(1,25))
	mutants = list("icechili")
	kitchen_tag = "chili"

/datum/seed/chili/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,20)
	set_trait(TRAIT_PRODUCT_ICON,"chili")
	set_trait(TRAIT_PRODUCT_COLOUR,"#ED3300")
	set_trait(TRAIT_PLANT_ICON,"bush2")

/datum/seed/chili/ice
	name = "icechili"
	seed_name = "ice pepper"
	display_name = "ice-pepper plants"
	mutants = null
	chems = list("frostoil" = list(3,5), "plantmatter" = list(1,50))
	kitchen_tag = "icechili"

/datum/seed/chili/ice/New()
	..()
	set_trait(TRAIT_MATURATION,4)
	set_trait(TRAIT_PRODUCTION,4)
	set_trait(TRAIT_PRODUCT_COLOUR,"#00EDC6")

// Berry plants/variants.
/datum/seed/berry
	name = "berries"
	seed_name = "berry"
	display_name = "berry bush"
	mutants = list("glowberries","poisonberries")
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "berries"

/datum/seed/berry/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"berry")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FA1616")
	set_trait(TRAIT_PLANT_ICON,"bush")

/datum/seed/berry/glow
	name = "glowberries"
	seed_name = "glowberry"
	display_name = "glowberry bush"
	mutants = null
	chems = list("plantmatter" = list(1,10), "uranium" = list(3,5))

/datum/seed/berry/glow/New()
	..()
	set_trait(TRAIT_SPREAD,1)
	set_trait(TRAIT_BIOLUM,1)
	set_trait(TRAIT_BIOLUM_COLOUR,"#006622")
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_COLOUR,"c9fa16")

/datum/seed/berry/poison
	name = "poisonberries"
	seed_name = "poison berry"
	display_name = "poison berry bush"
	mutants = list("deathberries")
	chems = list("plantmatter" = list(1), "toxin" = list(3,5))
	kitchen_tag = "poisonberries"

/datum/seed/berry/poison/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#6DC961")

/datum/seed/berry/poison/death
	name = "deathberries"
	seed_name = "death berry"
	display_name = "death berry bush"
	mutants = null
	chems = list("plantmatter" = list(1), "toxin" = list(3,3), "lexorin" = list(1,5))

/datum/seed/berry/poison/death/New()
	..()
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,50)
	set_trait(TRAIT_PRODUCT_COLOUR,"#7A5454")

// Nettles/variants.
/datum/seed/nettle
	name = "nettle"
	seed_name = "nettle"
	display_name = "nettles"
	mutants = list("deathnettle")
	chems = list("plantmatter" = list(1,50), "sacid" = list(0,1))
	kitchen_tag = "nettle"

/datum/seed/nettle/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_STINGS,1)
	set_trait(TRAIT_PLANT_ICON,"bush5")
	set_trait(TRAIT_PRODUCT_ICON,"nettles")
	set_trait(TRAIT_PRODUCT_COLOUR,"#728A54")

/datum/seed/nettle/death
	name = "deathnettle"
	seed_name = "death nettle"
	display_name = "death nettles"
	mutants = null
	chems = list("plantmatter" = list(1,50), "facid" = list(0,1))
	kitchen_tag = "deathnettle"

/datum/seed/nettle/death/New()
	..()
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_PRODUCT_COLOUR,"#8C5030")
	set_trait(TRAIT_PLANT_COLOUR,"#634941")

//Tomatoes/variants.
/datum/seed/tomato
	name = "tomato"
	seed_name = "tomato"
	display_name = "tomato plant"
	mutants = list("bluetomato","bloodtomato")
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "tomato"

/datum/seed/tomato/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"tomato")
	set_trait(TRAIT_PRODUCT_COLOUR,"#D10000")
	set_trait(TRAIT_PLANT_ICON,"bush3")

/datum/seed/tomato/blood
	name = "bloodtomato"
	seed_name = "blood tomato"
	display_name = "blood tomato plant"
	mutants = list("killertomato")
	chems = list("protein" = list(1,10), "blood" = list(1,5))
	splat_type = /obj/effect/decal/cleanable/blood/splatter
	kitchen_tag = "bloodtomato"

/datum/seed/tomato/blood/New()
	..()
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_PRODUCT_COLOUR,"#FF0000")

/datum/seed/tomato/killer
	name = "killertomato"
	seed_name = "killer tomato"
	display_name = "killer tomato plant"
	mutants = null
	can_self_harvest = 1
	has_mob_product = /mob/living/simple_animal/tomato

/datum/seed/tomato/killer/New()
	..()
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_PRODUCT_COLOUR,"#A86747")

/datum/seed/tomato/blue
	name = "bluetomato"
	seed_name = "blue tomato"
	display_name = "blue tomato plant"
	mutants = list("bluespacetomato")
	chems = list("plantmatter" = list(1,20), "lube" = list(1,5))

/datum/seed/tomato/blue/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#4D86E8")
	set_trait(TRAIT_PLANT_COLOUR,"#070AAD")

/datum/seed/tomato/blue/teleport
	name = "bluespacetomato"
	seed_name = "bluespace tomato"
	display_name = "bluespace tomato plant"
	mutants = null
	chems = list("plantmatter" = list(1,20), "singulo" = list(10,5))

/datum/seed/tomato/blue/teleport/New()
	..()
	set_trait(TRAIT_TELEPORTING,1)
	set_trait(TRAIT_PRODUCT_COLOUR,"#00E5FF")
	set_trait(TRAIT_BIOLUM,1)
	set_trait(TRAIT_BIOLUM_COLOUR,"#4DA4A8")

//Eggplants/varieties.
/datum/seed/eggplant
	name = "eggplant"
	seed_name = "eggplant"
	display_name = "eggplants"
	mutants = list("realeggplant")
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "eggplant"

/datum/seed/eggplant/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,20)
	set_trait(TRAIT_PRODUCT_ICON,"eggplant")
	set_trait(TRAIT_PRODUCT_COLOUR,"#892694")
	set_trait(TRAIT_PLANT_ICON,"bush4")

//Apples/varieties.
/datum/seed/apple
	name = "apple"
	seed_name = "apple"
	display_name = "apple tree"
	mutants = list("poisonapple","goldapple")
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "apple"

/datum/seed/apple/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,5)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"apple")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FF540A")
	set_trait(TRAIT_PLANT_ICON,"tree2")

/datum/seed/apple/poison
	name = "poisonapple"
	mutants = null
	chems = list("cyanide" = list(1,5))

/datum/seed/apple/gold
	name = "goldapple"
	seed_name = "golden apple"
	display_name = "gold apple tree"
	mutants = null
	chems = list("plantmatter" = list(1,10), "gold" = list(1,5))
	kitchen_tag = "goldapple"

/datum/seed/apple/gold/New()
	..()
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_PRODUCTION,10)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFDD00")
	set_trait(TRAIT_PLANT_COLOUR,"#D6B44D")

//Ambrosia/varieties.
/datum/seed/ambrosia
	name = "ambrosia"
	seed_name = "ambrosia vulgaris"
	display_name = "ambrosia vulgaris"
	mutants = list("ambrosiadeus")
	chems = list("plantmatter" = list(1), "thc" = list(1,8), "silver_sulfadiazine" = list(1,8,1), "styptic_powder" = list(1,10,1), "toxin" = list(1,10))
	kitchen_tag = "ambrosia"

/datum/seed/ambrosia/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"ambrosia")
	set_trait(TRAIT_PRODUCT_COLOUR,"#9FAD55")
	set_trait(TRAIT_PLANT_ICON,"ambrosia")

/datum/seed/ambrosia/deus
	name = "ambrosiadeus"
	seed_name = "ambrosia deus"
	display_name = "ambrosia deus"
	mutants = null
	chems = list("plantmatter" = list(1), "styptic_powder" = list(1,8), "synaptizine" = list(1,8,1), "methamphetamine" = list(1,10,1), "thc" = list(1,10))
	kitchen_tag = "ambrosiadeus"

//Tobacco/varieties
/datum/seed/tobacco
	name = "tobacco"
	seed_name = "tobacco"
	display_name = "tobacco"
	mutants = list("stobacco")
	chems = list("plantmatter" = list(1,40), "nicotine" = list(1,40))
	kitchen_tag = "tobacco"

/datum/seed/tobacco/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"leaf")
	set_trait(TRAIT_PRODUCT_COLOUR,"#9FAD55")
	set_trait(TRAIT_PLANT_ICON,"bush7")

/datum/seed/tobacco/space
	name = "stobacco"
	seed_name = "space tobacco"
	display_name = "space tobacco"
	mutants = null
	chems = list("plantmatter" = list(1,40), "nicotine" = list(1,20), "epinephrine" = list(1,30))
	kitchen_tag = "stobacco"

/datum/seed/tobacco/space/New()
	..()
	set_trait(TRAIT_YIELD, 4)
	set_trait(TRAIT_POTENCY, 5)
	set_trait(TRAIT_PRODUCT_COLOUR,"#A3F0AD")
	set_trait(TRAIT_PLANT_COLOUR,"#2A9C61")

//Tea/varieties
/datum/seed/teaaspera
	name = "teaaspera"
	seed_name = "tea aspera"
	display_name = "tea aspera"
	mutants = list("teaastra")
	chems = list("teapowder" = list(1,20), "charcoal" = list(1,30))

/datum/seed/teaaspera/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"leaf2")
	set_trait(TRAIT_PRODUCT_COLOUR,"#9FAD55")
	set_trait(TRAIT_PLANT_ICON,"tree6")

/datum/seed/teaastra
	name = "teaastra"
	seed_name = "tea astra"
	display_name = "tea astra"
	chems = list("teapowder" = list(1,20), "haloperidol" = list(1,30))

/datum/seed/teaastra/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"leaf2")
	set_trait(TRAIT_PRODUCT_COLOUR,"#A3F0AD")
	set_trait(TRAIT_PLANT_COLOUR,"#2A9C61")
	set_trait(TRAIT_PLANT_ICON,"tree6")

//Coffee/varieties
/datum/seed/coffeea
	name = "coffeea"
	seed_name = "coffee arabica"
	display_name = "coffee arabica"
	mutants = list("coffeer")
	chems = list("coffeepowder" = list(1,20), "synaptizine" = list(1,40))
	kitchen_tag = "coffeea"

/datum/seed/coffeea/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"coffee")
	set_trait(TRAIT_PRODUCT_COLOUR,"#ED0000")
	set_trait(TRAIT_PLANT_ICON,"bush8")

/datum/seed/coffeer
	name = "coffeer"
	seed_name = "coffee robusta"
	display_name = "coffee robusta"
	chems = list("coffeepowder" = list(1,20), "synaptizine" = list(1,20), "methamphetamine" = list(1,40))
	kitchen_tag = "coffeer"

/datum/seed/coffeer/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"coffee")
	set_trait(TRAIT_PRODUCT_COLOUR,"#A22043")
	set_trait(TRAIT_PLANT_ICON,"bush8")

//Mushrooms/varieties.
/datum/seed/mushroom
	name = "mushrooms"
	seed_name = "chanterelle"
	seed_noun = "spores"
	display_name = "chanterelle mushrooms"
	mutants = list("reishi","amanita","plumphelmet")
	chems = list("plantmatter" = list(1,25), "fungus" = list(1,10))
	splat_type = /obj/effect/plant
	kitchen_tag = "mushroom"

/datum/seed/mushroom/New()
	..()
	set_trait(TRAIT_MATURATION,7)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,5)
	set_trait(TRAIT_POTENCY,1)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom4")
	set_trait(TRAIT_PRODUCT_COLOUR,"#DBDA72")
	set_trait(TRAIT_PLANT_COLOUR,"#D9C94E")
	set_trait(TRAIT_PLANT_ICON,"mushroom")

/datum/seed/mushroom/mold
	name = "mold"
	seed_name = "brown mold"
	display_name = "brown mold"
	mutants = null

/datum/seed/mushroom/mold/New()
	..()
	set_trait(TRAIT_SPREAD,1)
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_YIELD,-1)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom5")
	set_trait(TRAIT_PRODUCT_COLOUR,"#7A5F20")
	set_trait(TRAIT_PLANT_COLOUR,"#7A5F20")
	set_trait(TRAIT_PLANT_ICON,"mushroom9")

/datum/seed/mushroom/plump
	name = "plumphelmet"
	seed_name = "plump helmet"
	display_name = "plump helmet mushrooms"
	mutants = list("walkingmushroom","towercap")
	chems = list("plantmatter" = list(2,10))
	kitchen_tag = "plumphelmet"

/datum/seed/mushroom/plump/New()
	..()
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,0)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom10")
	set_trait(TRAIT_PRODUCT_COLOUR,"#B57BB0")
	set_trait(TRAIT_PLANT_COLOUR,"#9E4F9D")
	set_trait(TRAIT_PLANT_ICON,"mushroom2")

/datum/seed/mushroom/plump/walking
	name = "walkingmushroom"
	seed_name = "walking mushroom"
	display_name = "walking mushrooms"
	mutants = null
	can_self_harvest = 1
	has_mob_product = /mob/living/simple_animal/hostile/mushroom

/datum/seed/mushroom/plump/walking/New()
	..()
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_YIELD,1)
	set_trait(TRAIT_PRODUCT_COLOUR,"#FAC0F2")
	set_trait(TRAIT_PLANT_COLOUR,"#C4B1C2")

/datum/seed/mushroom/hallucinogenic
	name = "reishi"
	seed_name = "reishi"
	display_name = "reishi"
	mutants = list("libertycap","glowshroom")
	chems = list("plantmatter" = list(1,50), "psilocybin" = list(3,5))

/datum/seed/mushroom/hallucinogenic/New()
	..()
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,15)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom11")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFB70F")
	set_trait(TRAIT_PLANT_COLOUR,"#F58A18")
	set_trait(TRAIT_PLANT_ICON,"mushroom6")

/datum/seed/mushroom/hallucinogenic/strong
	name = "libertycap"
	seed_name = "liberty cap"
	display_name = "liberty cap mushrooms"
	mutants = null
	chems = list("plantmatter" = list(1), "morphine" = list(3,3), "space_drugs" = list(1,25))
	kitchen_tag = "libertycap"

/datum/seed/mushroom/hallucinogenic/strong/New()
	..()
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_POTENCY,15)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom8")
	set_trait(TRAIT_PRODUCT_COLOUR,"#F2E550")
	set_trait(TRAIT_PLANT_COLOUR,"#D1CA82")
	set_trait(TRAIT_PLANT_ICON,"mushroom3")

/datum/seed/mushroom/poison
	name = "amanita"
	seed_name = "fly amanita"
	display_name = "fly amanita mushrooms"
	mutants = list("destroyingangel","plastic")
	chems = list("plantmatter" = list(1), "amanitin" = list(3,3), "psilocybin" = list(1,25))
	kitchen_tag = "amanita"

/datum/seed/mushroom/poison/New()
	..()
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FF4545")
	set_trait(TRAIT_PLANT_COLOUR,"#E0DDBA")
	set_trait(TRAIT_PLANT_ICON,"mushroom4")

/datum/seed/mushroom/poison/death
	name = "destroyingangel"
	seed_name = "destroying angel"
	display_name = "destroying angel mushrooms"
	mutants = null
	chems = list("plantmatter" = list(1,50), "amanitin" = list(13,3), "psilocybin" = list(1,25))

/datum/seed/mushroom/poison/death/New()
	..()
	set_trait(TRAIT_MATURATION,12)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,35)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom3")
	set_trait(TRAIT_PRODUCT_COLOUR,"#EDE8EA")
	set_trait(TRAIT_PLANT_COLOUR,"#E6D8DD")
	set_trait(TRAIT_PLANT_ICON,"mushroom5")

/datum/seed/mushroom/towercap
	name = "towercap"
	seed_name = "tower cap"
	display_name = "tower caps"
	chems = list("woodpulp" = list(10,1))
	mutants = null

/datum/seed/mushroom/towercap/New()
	..()
	set_trait(TRAIT_MATURATION,15)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom7")
	set_trait(TRAIT_PRODUCT_COLOUR,"#79A36D")
	set_trait(TRAIT_PLANT_COLOUR,"#857F41")
	set_trait(TRAIT_PLANT_ICON,"mushroom8")

/datum/seed/mushroom/glowshroom
	name = "glowshroom"
	seed_name = "glowshroom"
	display_name = "glowshrooms"
	mutants = null
	chems = list("radium" = list(1,20))

/datum/seed/mushroom/glowshroom/New()
	..()
	set_trait(TRAIT_SPREAD,1)
	set_trait(TRAIT_MATURATION,15)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,30)
	set_trait(TRAIT_BIOLUM,1)
	set_trait(TRAIT_BIOLUM_COLOUR,"#006622")
	set_trait(TRAIT_PRODUCT_ICON,"mushroom2")
	set_trait(TRAIT_PRODUCT_COLOUR,"#DDFAB6")
	set_trait(TRAIT_PLANT_COLOUR,"#EFFF8A")
	set_trait(TRAIT_PLANT_ICON,"mushroom7")

/datum/seed/mushroom/plastic
	name = "plastic"
	seed_name = "plastellium"
	display_name = "plastellium"
	mutants = null
	chems = list("plasticide" = list(1,10))

/datum/seed/mushroom/plastic/New()
	..()
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,20)
	set_trait(TRAIT_PRODUCT_ICON,"mushroom6")
	set_trait(TRAIT_PRODUCT_COLOUR,"#E6E6E6")
	set_trait(TRAIT_PLANT_COLOUR,"#E6E6E6")
	set_trait(TRAIT_PLANT_ICON,"mushroom10")

//Flowers/varieties
/datum/seed/flower
	name = "harebells"
	seed_name = "harebell"
	display_name = "harebells"
	chems = list("plantmatter" = list(1,20))

/datum/seed/flower/New()
	..()
	set_trait(TRAIT_MATURATION,7)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_PRODUCT_ICON,"flower5")
	set_trait(TRAIT_PRODUCT_COLOUR,"#C492D6")
	set_trait(TRAIT_PLANT_COLOUR,"#6B8C5E")
	set_trait(TRAIT_PLANT_ICON,"flower")

/datum/seed/flower/poppy
	name = "poppies"
	seed_name = "poppy"
	display_name = "poppies"
	chems = list("plantmatter" = list(1,20), "styptic_powder" = list(1,10))
	kitchen_tag = "poppy"

/datum/seed/flower/poppy/New()
	..()
	set_trait(TRAIT_POTENCY,20)
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_PRODUCT_ICON,"flower3")
	set_trait(TRAIT_PRODUCT_COLOUR,"#B33715")
	set_trait(TRAIT_PLANT_ICON,"flower3")

/datum/seed/flower/sunflower
	name = "sunflowers"
	seed_name = "sunflower"
	display_name = "sunflowers"

/datum/seed/flower/sunflower/New()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCT_ICON,"flower2")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFF700")
	set_trait(TRAIT_PLANT_ICON,"flower2")

//Grapes/varieties
/datum/seed/grapes
	name = "grapes"
	seed_name = "grape"
	display_name = "grapevines"
	mutants = list("greengrapes")
	chems = list("plantmatter" = list(1,10), "sugar" = list(1,5))

/datum/seed/grapes/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"grapes")
	set_trait(TRAIT_PRODUCT_COLOUR,"#BB6AC4")
	set_trait(TRAIT_PLANT_COLOUR,"#378F2E")
	set_trait(TRAIT_PLANT_ICON,"vine")

/datum/seed/grapes/green
	name = "greengrapes"
	seed_name = "green grape"
	display_name = "green grapevines"
	mutants = null
	chems = list("plantmatter" = list(1,10), "silver_sulfadiazine" = list(3,5))

/datum/seed/grapes/green/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"42ed2f")

//Everything else
/datum/seed/peanuts
	name = "peanut"
	seed_name = "peanut"
	display_name = "peanut vines"
	chems = list("plantmatter" = list(1,10))

/datum/seed/peanuts/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"potato")
	set_trait(TRAIT_PRODUCT_COLOUR,"#C4AE7A")
	set_trait(TRAIT_PLANT_ICON,"bush2")

/datum/seed/cabbage
	name = "cabbage"
	seed_name = "cabbage"
	display_name = "cabbages"
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "cabbage"

/datum/seed/cabbage/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"cabbage")
	set_trait(TRAIT_PRODUCT_COLOUR,"#84BD82")
	set_trait(TRAIT_PLANT_COLOUR,"#6D9C6B")
	set_trait(TRAIT_PLANT_ICON,"vine2")

/datum/seed/banana
	name = "banana"
	seed_name = "banana"
	display_name = "banana tree"
	chems = list("banana" = list(10,10))
	trash_type = /obj/item/weapon/bananapeel
	kitchen_tag = "banana"

/datum/seed/banana/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_PRODUCT_ICON,"bananas")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFEC1F")
	set_trait(TRAIT_PLANT_COLOUR,"#69AD50")
	set_trait(TRAIT_PLANT_ICON,"tree4")

/datum/seed/corn
	name = "corn"
	seed_name = "corn"
	display_name = "ears of corn"
	chems = list("plantmatter" = list(1,10), "corn_starch" = list(3,5))
	kitchen_tag = "corn"
	trash_type = /obj/item/weapon/corncob

/datum/seed/corn/New()
	..()
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,20)
	set_trait(TRAIT_PRODUCT_ICON,"corn")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFF23B")
	set_trait(TRAIT_PLANT_COLOUR,"#87C969")
	set_trait(TRAIT_PLANT_ICON,"corn")

/datum/seed/potato
	name = "potato"
	seed_name = "potato"
	display_name = "potatoes"
	chems = list("plantmatter" = list(1,10))
	kitchen_tag = "potato"

/datum/seed/potato/New()
	..()
	set_trait(TRAIT_PRODUCES_POWER,1)
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"potato")
	set_trait(TRAIT_PRODUCT_COLOUR,"#D4CAB4")
	set_trait(TRAIT_PLANT_ICON,"bush2")

/datum/seed/soybean
	name = "soybean"
	seed_name = "soybean"
	display_name = "soybeans"
	chems = list("plantmatter" = list(1,20), "soybeanoil" = list(1,20))
	kitchen_tag = "soybeans"

/datum/seed/soybean/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,4)
	set_trait(TRAIT_PRODUCTION,4)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"bean")
	set_trait(TRAIT_PRODUCT_COLOUR,"#EBE7C0")
	set_trait(TRAIT_PLANT_ICON,"stalk")

/datum/seed/wheat
	name = "wheat"
	seed_name = "wheat"
	display_name = "wheat stalks"
	chems = list("plantmatter" = list(1,25))
	kitchen_tag = "wheat"

/datum/seed/wheat/New()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"wheat")
	set_trait(TRAIT_PRODUCT_COLOUR,"#DBD37D")
	set_trait(TRAIT_PLANT_COLOUR,"#BFAF82")
	set_trait(TRAIT_PLANT_ICON,"stalk2")

/datum/seed/rice
	name = "rice"
	seed_name = "rice"
	display_name = "rice stalks"
	chems = list("plantmatter" = list(1,25))
	kitchen_tag = "rice"

/datum/seed/rice/New()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,5)
	set_trait(TRAIT_PRODUCT_ICON,"rice")
	set_trait(TRAIT_PRODUCT_COLOUR,"#D5E6D1")
	set_trait(TRAIT_PLANT_COLOUR,"#8ED17D")
	set_trait(TRAIT_PLANT_ICON,"stalk2")

/datum/seed/carrots
	name = "carrot"
	seed_name = "carrot"
	display_name = "carrots"
	chems = list("plantmatter" = list(1,20), "oculine" = list(3,5))
	kitchen_tag = "carrot"

/datum/seed/carrots/New()
	..()
	set_trait(TRAIT_MATURATION,10)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,5)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"carrot")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFDB4A")
	set_trait(TRAIT_PLANT_ICON,"carrot")

/datum/seed/weeds
	name = "weeds"
	seed_name = "weed"
	display_name = "weeds"

/datum/seed/weeds/New()
	..()
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,-1)
	set_trait(TRAIT_POTENCY,-1)
	set_trait(TRAIT_IMMUTABLE,-1)
	set_trait(TRAIT_PRODUCT_ICON,"flower4")
	set_trait(TRAIT_PRODUCT_COLOUR,"#FCEB2B")
	set_trait(TRAIT_PLANT_COLOUR,"#59945A")
	set_trait(TRAIT_PLANT_ICON,"bush6")

/datum/seed/whitebeets
	name = "whitebeet"
	seed_name = "white-beet"
	display_name = "white-beets"
	chems = list("plantmatter" = list(0,20), "sugar" = list(1,5))
	kitchen_tag = "whitebeet"

/datum/seed/whitebeets/New()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,6)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"carrot2")
	set_trait(TRAIT_PRODUCT_COLOUR,"#EEF5B0")
	set_trait(TRAIT_PLANT_COLOUR,"#4D8F53")
	set_trait(TRAIT_PLANT_ICON,"carrot2")

/datum/seed/sugarcane
	name = "sugarcane"
	seed_name = "sugarcane"
	display_name = "sugarcanes"
	chems = list("sugar" = list(4,5))

/datum/seed/sugarcane/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"stalk")
	set_trait(TRAIT_PRODUCT_COLOUR,"#B4D6BD")
	set_trait(TRAIT_PLANT_COLOUR,"#6BBD68")
	set_trait(TRAIT_PLANT_ICON,"stalk3")

/datum/seed/watermelon
	name = "watermelon"
	seed_name = "watermelon"
	display_name = "watermelon vine"
	chems = list("plantmatter" = list(1,6))
	kitchen_tag = "watermelon"

/datum/seed/watermelon/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,1)
	set_trait(TRAIT_PRODUCT_ICON,"vine")
	set_trait(TRAIT_PRODUCT_COLOUR,"#326B30")
	set_trait(TRAIT_PLANT_COLOUR,"#257522")
	set_trait(TRAIT_PLANT_ICON,"vine2")

/datum/seed/pumpkin
	name = "pumpkin"
	seed_name = "pumpkin"
	display_name = "pumpkin vine"
	chems = list("plantmatter" = list(1,6))
	kitchen_tag = "pumpkin"

/datum/seed/pumpkin/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"vine")
	set_trait(TRAIT_PRODUCT_COLOUR,"#B4D4B9")
	set_trait(TRAIT_PLANT_COLOUR,"#BAE8C1")
	set_trait(TRAIT_PLANT_ICON,"vine2")

/datum/seed/citrus
	name = "lime"
	seed_name = "lime"
	display_name = "lime trees"
	chems = list("plantmatter" = list(1,20))
	kitchen_tag = "lime"

/datum/seed/citrus/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,15)
	set_trait(TRAIT_PRODUCT_ICON,"treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR,"#3AF026")
	set_trait(TRAIT_PLANT_ICON,"tree")

/datum/seed/citrus/lemon
	name = "lemon"
	seed_name = "lemon"
	display_name = "lemon trees"
	chems = list("plantmatter" = list(1,20))
	kitchen_tag = "lemon"

/datum/seed/citrus/lemon/New()
	..()
	set_trait(TRAIT_PRODUCES_POWER,1)
	set_trait(TRAIT_PRODUCT_COLOUR,"#F0E226")

/datum/seed/citrus/orange
	name = "orange"
	seed_name = "orange"
	display_name = "orange trees"
	kitchen_tag = "orange"
	chems = list("plantmatter" = list(1,20))

/datum/seed/citrus/orange/New()
	..()
	set_trait(TRAIT_PRODUCT_COLOUR,"#FFC20A")

/datum/seed/grass
	name = "grass"
	seed_name = "grass"
	display_name = "grass"
	chems = list("plantmatter" = list(1,20))
	kitchen_tag = "grass"

/datum/seed/grass/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,2)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,5)
	set_trait(TRAIT_PRODUCT_ICON,"grass")
	set_trait(TRAIT_PRODUCT_COLOUR,"#09FF00")
	set_trait(TRAIT_PLANT_COLOUR,"#07D900")
	set_trait(TRAIT_PLANT_ICON,"grass")

/datum/seed/cocoa
	name = "cocoa"
	seed_name = "cacao"
	display_name = "cacao tree"
	chems = list("plantmatter" = list(1,10), "coco" = list(4,5))

/datum/seed/cocoa/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR,"#CCA935")
	set_trait(TRAIT_PLANT_ICON,"tree2")

/datum/seed/cherries
	name = "cherry"
	seed_name = "cherry"
	seed_noun = "pits"
	display_name = "cherry tree"
	chems = list("plantmatter" = list(1,15), "sugar" = list(1,15))
	kitchen_tag = "cherries"

/datum/seed/cherries/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"cherry")
	set_trait(TRAIT_PRODUCT_COLOUR,"#A80000")
	set_trait(TRAIT_PLANT_ICON,"tree2")
	set_trait(TRAIT_PLANT_COLOUR,"#2F7D2D")

/datum/seed/kudzu
	name = "kudzu"
	seed_name = "kudzu"
	display_name = "kudzu vines"
	chems = list("plantmatter" = list(1,50), "charcoal" = list(1,25))

/datum/seed/kudzu/New()
	..()
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_SPREAD,2)
	set_trait(TRAIT_PRODUCT_ICON,"treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR,"#96D278")
	set_trait(TRAIT_PLANT_COLOUR,"#6F7A63")
	set_trait(TRAIT_PLANT_ICON,"vine2")

/datum/seed/diona
	name = "diona"
	seed_name = "diona"
	seed_noun = "nodes"
	display_name = "replicant pods"
	can_self_harvest = 1
	has_mob_product = /mob/living/carbon/monkey/diona

/datum/seed/diona/New()
	..()
	set_trait(TRAIT_IMMUTABLE,1)
	set_trait(TRAIT_ENDURANCE,8)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,10)
	set_trait(TRAIT_YIELD,1)
	set_trait(TRAIT_POTENCY,30)
	set_trait(TRAIT_PRODUCT_ICON,"diona")
	set_trait(TRAIT_PRODUCT_COLOUR,"#799957")
	set_trait(TRAIT_PLANT_COLOUR,"#66804B")
	set_trait(TRAIT_PLANT_ICON,"alien4")

/datum/seed/clown
	name = "clown"
	seed_name = "clown"
	seed_noun = "pods"
	display_name = "laughing clowns"
	can_self_harvest = 1
	has_mob_product = /mob/living/simple_animal/hostile/retaliate/clown

/datum/seed/clown/New()
	..()
	set_trait(TRAIT_ENDURANCE,8)
	set_trait(TRAIT_MATURATION,1)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,10)
	set_trait(TRAIT_POTENCY,30)
	set_trait(TRAIT_PRODUCT_ICON,"diona")
	set_trait(TRAIT_PRODUCT_COLOUR,"#799957")
	set_trait(TRAIT_PLANT_COLOUR,"#66804B")
	set_trait(TRAIT_PLANT_ICON,"alien4")

/datum/seed/shand
	name = "shand"
	seed_name = "S'randar's hand"
	display_name = "S'randar's hand leaves"
	chems = list("styptic_powder" = list(0,10))
	kitchen_tag = "shand"

/datum/seed/shand/New()
	..()
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"alien3")
	set_trait(TRAIT_PRODUCT_COLOUR,"#378C61")
	set_trait(TRAIT_PLANT_COLOUR,"#378C61")
	set_trait(TRAIT_PLANT_ICON,"tree5")

/datum/seed/mtear
	name = "mtear"
	seed_name = "Messa's tear"
	display_name = "Messa's tear leaves"
	chems = list("honey" = list(1,10), "silver_sulfadiazine" = list(3,5))
	kitchen_tag = "mtear"

/datum/seed/mtear/New()
	..()
	set_trait(TRAIT_MATURATION,3)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)
	set_trait(TRAIT_PRODUCT_ICON,"alien4")
	set_trait(TRAIT_PRODUCT_COLOUR,"#4CC5C7")
	set_trait(TRAIT_PLANT_COLOUR,"#4CC789")
	set_trait(TRAIT_PLANT_ICON,"bush7")

/datum/seed/telriis
	name = "telriis"
	seed_name = "telriis"
	display_name = "telriis grass"
	chems = list("wine" = list(1,5), "toxin" = list(1,5), "plantmatter" = list(1,6))

/datum/seed/telriis/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"telriis")
	set_trait(TRAIT_ENDURANCE,50)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,5)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,5)

/datum/seed/thaadra
	name = "thaadra"
	seed_name = "thaa'dra"
	display_name = "thaa'dra lichen"
	chems = list("frostoil" = list(1,5),"plantmatter" = list(1,5))

/datum/seed/thaadra/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"thaadra")
	set_trait(TRAIT_ENDURANCE,10)
	set_trait(TRAIT_MATURATION,5)
	set_trait(TRAIT_PRODUCTION,9)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,5)

/datum/seed/jurlmah
	name = "jurlmah"
	seed_name = "jurl'mah"
	display_name = "jurl'mah reeds"
	chems = list("serotrotium" = list(1,5),"plantmatter" = list(1,5))

/datum/seed/jurlmah/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"jurlmah")
	set_trait(TRAIT_ENDURANCE,12)
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,9)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,10)

/datum/seed/amauri
	name = "amauri"
	seed_name = "amauri"
	display_name = "amauri plant"
	chems = list("condensedcapsaicin" = list(1,5),"plantmatter" = list(1,5))

/datum/seed/amauri/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"amauri")
	set_trait(TRAIT_ENDURANCE,10)
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,9)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,10)

/datum/seed/gelthi
	name = "gelthi"
	seed_name = "gelthi"
	display_name = "gelthi plant"
	chems = list("morphine" = list(1,5),"capsaicin" = list(1,5),"plantmatter" = list(1,5))

/datum/seed/gelthi/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"gelthi")
	set_trait(TRAIT_ENDURANCE,15)
	set_trait(TRAIT_MATURATION,6)
	set_trait(TRAIT_PRODUCTION,6)
	set_trait(TRAIT_YIELD,2)
	set_trait(TRAIT_POTENCY,1)

/datum/seed/vale
	name = "vale"
	seed_name = "vale"
	display_name = "vale bush"
	chems = list("sal_acid" = list(1,5),"salbutamol" = list(1,2),"plantmatter"= list(1,5))

/datum/seed/vale/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"vale")
	set_trait(TRAIT_ENDURANCE,15)
	set_trait(TRAIT_MATURATION,8)
	set_trait(TRAIT_PRODUCTION,10)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,3)

/datum/seed/surik
	name = "surik"
	seed_name = "surik"
	display_name = "surik vine"
	chems = list("haloperidol" = list(1,3),"synaptizine" = list(1,2),"plantmatter" = list(1,5))

/datum/seed/surik/New()
	..()
	set_trait(TRAIT_PLANT_ICON,"surik")
	set_trait(TRAIT_ENDURANCE,18)
	set_trait(TRAIT_MATURATION,7)
	set_trait(TRAIT_PRODUCTION,7)
	set_trait(TRAIT_YIELD,3)
	set_trait(TRAIT_POTENCY,3)

/datum/seed/test
	name = "test"
	seed_name = "test"
	display_name = "test trees"
	chems = list("omnizine" = list(1,20))
	consume_gasses = list("oxygen" = 5)

/datum/seed/test/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_JUICY,1)
	set_trait(TRAIT_MATURATION,1)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,15)
	set_trait(TRAIT_PRODUCT_ICON,"treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR,"#BB6AC4")
	set_trait(TRAIT_PLANT_ICON,"tree")
	set_trait(TRAIT_EXPLOSIVE, 1)

/datum/seed/test2
	name = "test2"
	seed_name = "test2"
	display_name = "test2 trees"
	exude_gasses = list("toxins" = 5)

/datum/seed/test2/New()
	..()
	set_trait(TRAIT_HARVEST_REPEAT,1)
	set_trait(TRAIT_MATURATION,1)
	set_trait(TRAIT_PRODUCTION,1)
	set_trait(TRAIT_YIELD,4)
	set_trait(TRAIT_POTENCY,15)
	set_trait(TRAIT_PRODUCT_ICON,"treefruit")
	set_trait(TRAIT_PRODUCT_COLOUR,"#BB6AC4")
	set_trait(TRAIT_PLANT_ICON,"tree")
