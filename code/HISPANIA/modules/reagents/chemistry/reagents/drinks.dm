///Hispania drinks


/datum/reagent/consumable/drink/rainbowjuice
	name = "Rainbow Juice"
	id = "rainbowjuice"
	description = "A colorful mixture of fruit juices."
	color = "#FF8EC8"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "rainbowjuice"
	drink_name = "Rainbow Juice"
	drink_desc = "A colorful mixture of fruit juices."
	taste_description = "gayness"

/datum/reagent/consumable/drink/unclegits_specialmilk
	name= "Uncle Git's Special Milk"
	id = "unclegits_specialmilk"
	description = "It is sticky and has a strong chlorine smell."
	color = "#FFFEC6"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "unclegits_specialmilk"
	drink_name = "Uncle Git's Special Milk"
	drink_desc = "It is sticky and has a strong chlorine smell."
	taste_description = "someone else's child"

/datum/reagent/consumable/drink/agave
	name = "Agave Juice"
	id = "agave"
	description = "Principal reagent to make tequila."
	color = "#C9B25D"
	drink_icon = "agave_juice"
	drink_name = "Glass of Agave Juice"
	drink_desc = "Principal reagent to make tequila, are you sure about this?"
	taste_description = "Bland"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/anonna
	name = "Anonna Juice"
	id = "anonna"
	description = "Magic juice with lovely taste"
	color = "#C1AA8D"
	drink_icon = "anonna_juice"
	drink_name = "Glass of Anonna Juice"
	drink_desc = "Magic juice with lovely taste."
	taste_description = "Sugary"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/kiwi
	name = "Kiwi Juice"
	id = "kiwi"
	description = "For some reasons kinda tastes like feathers"
	color = "#C5CA4C"
	drink_icon = "kiwi_juice"
	drink_name = "Glass of Kiwi Juice"
	drink_desc = "For some reasons kinda tastes like feathers."
	taste_description = "Sour Sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/mango
	name = "Mango Juice"
	id = "mango"
	description = "Sweat and pulpy"
	color = "#FF9903"
	drink_icon = "mango_juice"
	drink_name = "Glass of Mango Juice"
	drink_desc = "For some reasons kinda tastes like feathers."
	taste_description = "pulpy"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/mate
	name = "Mate"
	id = "mate"
	description = "Hipster stuff"
	color = "#948870"
	drink_icon = "glass_mate"
	drink_name = "Glass of Mate"
	drink_desc = "Hipster stuff"
	taste_description = "hipster"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/nispero
	name = "Nispero Juice"
	id = "nispero"
	description = "Weird stuff no idea what is this"
	color = "#9B723C"
	drink_icon = "nispero_juice"
	drink_name = "Glass of Nispero Juice"
	drink_desc = "Weird stuff no idea what is this"
	taste_description = "sour sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/peach
	name = "Peach Juice"
	id = "peach"
	description = "Coloured, juicy fruit"
	color = "#FFB5B6"
	drink_icon = "peach_juice"
	drink_name = "Glass of Peach Juice"
	drink_desc = "Coloured, juicy fruit"
	taste_description = "deliciously sweet"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/castor
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

/datum/reagent/consumable/drink/strawberry
	name = "Strawberry Juice"
	id = "strawberry"
	description = "Acidic and sweet"
	color = "#FF292E"
	drink_icon = "straw_juice"
	drink_name = "Glass of Strawberry Juice"
	drink_desc = "Acidic and sweet"
	taste_description = "sweet citric"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/drink/peach_milshake
	name = "Peach Milshake"
	id = "peach_milshake"
	description = "Pink and very light, essential on the first date"
	color = "#FF7391"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "peach_milshake"
	drink_name = "Peach Milshake"
	drink_desc = "Pink and very light, essential on the first date"
	taste_description = "dainty"

/datum/reagent/consumable/drink/mango_punch
	name= "Mango Punch"
	id = "mango_punch"
	description = "Is it mango season yet?"
	color = "#F2C341"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "mango_punch"
	drink_name = "Mango Punch"
	drink_desc = "Is it mango season yet?"
	taste_description = "delicious!"

/datum/reagent/consumable/drink/green_juice
	name= "Green Juice"
	id = "green_juice"
	description = "A drinkable salad?"
	color = "#2D572C"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	drink_icon = "green_juice"
	drink_name = "Glass of Green Juice"
	drink_desc = "A drinkable salad?"
	taste_description = "grassy"

/datum/reagent/consumable/drink/mambo_smothie
	name= "Mambo Smothie"
	id = "mambo_smothie"
	description = "Do you want to stay fit, mate?"
	color = "#A4C639"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "mambo_smothie"
	drink_name = "Mambo Smothie"
	drink_desc = "Do you want to stay fit, mate?"
	taste_description = "grassy"
