///Hispania drinks
/datum/reagent/consumable/drink/hispania
	icon = 'icons/hispania/obj/drinks.dmi'

/datum/reagent/consumable/drink/hispania/rainbowjuice
	name = "Rainbow Juice"
	id = "rainbowjuice"
	description = "A colorful mixture of fruit juices."
	color = "#FF8EC8"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "rainbowjuice"
	drink_name = "Rainbow Juice"
	drink_desc = "A colorful mixture of fruit juices."
	taste_description = "gayness"

/datum/reagent/consumable/drink/hispania/unclegits_specialmilk
	name= "Uncle Git's Special Milk"
	id = "unclegits_specialmilk"
	description = "It is sticky and has a strong chlorine smell."
	color = "#FFFEC6"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "unclegits_specialmilk"
	drink_name = "Uncle Git's Special Milk"
	drink_desc = "It is sticky and has a strong chlorine smell."
	taste_description = "someone else's child"

/datum/reagent/consumable/drink/hispania/agave
	name = "Agave Juice"
	id = "agave"
	description = "Principal reagent to make tequila."
	color = "#C9B25D"
	drink_icon = "agave_juice"
	drink_name = "Glass of Agave Juice"
	drink_desc = "Principal reagent to make tequila, are you sure about this?"
	taste_description = "Bland"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/anonna
	name = "Anonna Juice"
	id = "anonnajuice"
	description = "Magic juice with lovely taste"
	color = "#C1AA8D"
	drink_icon = "anonna_juice"
	drink_name = "Glass of Anonna Juice"
	drink_desc = "Magic juice with lovely taste."
	taste_description = "Sugary"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/kiwi
	name = "Kiwi Juice"
	id = "kiwijuice"
	description = "For some reasons kinda tastes like feathers"
	color = "#C5CA4C"
	drink_icon = "kiwi_juice"
	drink_name = "Glass of Kiwi Juice"
	drink_desc = "For some reasons kinda tastes like feathers."
	taste_description = "Sour Sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/mango
	name = "Mango Juice"
	id = "mangojuice"
	description = "Sweat and pulpy"
	color = "#FF9903"
	drink_icon = "mango_juice"
	drink_name = "Glass of Mango Juice"
	drink_desc = "For some reasons kinda tastes like feathers."
	taste_description = "pulpy"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/mate
	name = "Mate"
	id = "matejuice"
	description = "Hipster stuff"
	color = "#948870"
	drink_icon = "glass_mate"
	drink_name = "Glass of Mate"
	drink_desc = "Hipster stuff"
	taste_description = "hipster"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/nispero
	name = "Nispero Juice"
	id = "nisperojuice"
	description = "Weird stuff no idea what is this"
	color = "#9B723C"
	drink_icon = "nispero_juice"
	drink_name = "Glass of Nispero Juice"
	drink_desc = "Weird stuff no idea what is this"
	taste_description = "sour sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/peach
	name = "Peach Juice"
	id = "peachjuice"
	description = "Coloured, juicy fruit"
	color = "#FFB5B6"
	drink_icon = "peach_juice"
	drink_name = "Glass of Peach Juice"
	drink_desc = "Coloured, juicy fruit"
	taste_description = "deliciously sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/castor
	name = "Castor Oil"
	id = "castor_oil"
	description = "smells like beans"
	color = "#9D8F62"
	drink_icon = "castor_oil"
	drink_name = "Glass of Castor Oil"
	drink_desc = "smells like beans"
	taste_description = "beans"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/castor/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/hispania/strawberry
	name = "Strawberry Juice"
	id = "strawberryjuice"
	description = "Acidic and sweet"
	color = "#FF292E"
	drink_icon = "straw_juice"
	drink_name = "Glass of Strawberry Juice"
	drink_desc = "Acidic and sweet"
	taste_description = "sweet citric"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/coconutwater
	name = "Coconut Water"
	id = "coconutwater"
	description = "Diaphanous water with coconut bits floating"
	color = "#FF292E"
	drink_icon = "coconut_water"
	drink_name = "Glass of Coconut Water"
	drink_desc = "Diaphanous water with coconut bits floating"
	taste_description = "sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/hispania/peach_milshake
	name = "Peach Milshake"
	id = "peach_milshake"
	description = "Pink and very light, essential on the first date"
	color = "#FF7391"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "peach_milshake"
	drink_name = "Peach Milshake"
	drink_desc = "Pink and very light, essential on the first date"
	taste_description = "dainty"

/datum/reagent/consumable/drink/hispania/mango_punch
	name= "Mango Punch"
	id = "mango_punch"
	description = "Is it mango season yet?"
	color = "#F2C341"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "mango_punch"
	drink_name = "Mango Punch"
	drink_desc = "Is it mango season yet?"
	taste_description = "delicious!"

/datum/reagent/consumable/drink/hispania/green_juice
	name= "Green Juice"
	id = "green_juice"
	description = "A drinkable salad?"
	color = "#2D572C"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "green_juice"
	drink_name = "Glass of Green Juice"
	drink_desc = "A drinkable salad?"
	taste_description = "grassy"

/datum/reagent/consumable/drink/hispania/mambo_smothie
	name= "Mambo Smothie"
	id = "mambo_smothie"
	description = "Do you want to stay fit, mate?"
	color = "#A4C639"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "mambo_smothie"
	drink_name = "Mambo Smothie"
	drink_desc = "Do you want to stay fit, mate?"
	taste_description = "grass"

/datum/reagent/consumable/drink/hispania/anonna_blueberries
	name = "Anonna and Blueberries"
	id = "anonna_blueberries"
	description = "Sweeeeet"
	color = "#CE3B00"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "anonna_blueberries"
	drink_name = "Cóctel of Anonna and Blueberries"
	drink_desc = "Tropical cóctel."
	taste_description = "sweet fruits"

/datum/reagent/consumable/drink/hispania/anonna_cream
	name = "Anonna Cream"
	id = "anonna_cream"
	description = "A tropical looking cream"
	color = "#FFD484"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "anonna_cream"
	drink_name = "Glass of Anonna Cream"
	drink_desc = "A really good tropical cream."
	taste_description = "creamy edgy fruit"

/datum/reagent/consumable/drink/hispania/cold/nisperorefinedjuice
	name = "Refined Nispero Juice"
	description = "A cold citric juice of Nispero."
	id = "nisperorefinedjuice"
	color = "#F09D16"
	drink_icon = "nisperorefinedjuice"
	drink_name = "Glass of Refined Nispero Juice"
	drink_desc = "A really good tropical cream."
	taste_description = "cold citric nispero"

/datum/reagent/consumable/drink/hispania/cold/cactus_healtus
	name = "Super-Healthy Prickly Pear Juice"
	id = "cactus_healtus"
	description = "A smoothie mixed with a little of sugar, lemon juice and a prickly pear."
	color = "#87CA53"
	drink_icon = "cactus_healtus"
	drink_name = "Smoothie of Prickly Pear"
	drink_desc = "A bright green cold smoothie. People say its good for the overweight."
	taste_description = "fresh cold water with a little of citric"

/datum/reagent/consumable/drink/hispania/cold/cactus_healtus/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/nutrition_value = -rand(3,4)
	update_flags |= M.adjust_nutrition(nutrition_value)
	return ..() | update_flags

/datum/reagent/consumable/drink/hispania/cactusjuice
	name = "Prickly Pear Cactus Juice"
	id = "cactusjuice"
	description = "The lower tier of the avocado."
	color = "#5BB615"
	drink_icon = "cactus_juice"
	drink_name = "Glass of Prickly Pear Cactus Juice"
	drink_desc = "Wait what, cactus?"
	taste_description = "bland water"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM
