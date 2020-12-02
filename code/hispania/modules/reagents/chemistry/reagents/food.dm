/////////////////Food reagents////////////////
/datum/reagent/consumable/butter
	name = "butter"
	id = "butter"
	description = "Delicious milk fat."
	reagent_state = LIQUID
	color = "#fff98f" // rgb: 255, 249, 143
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_description = "butter"

/datum/reagent/consumable/mayonnaise
	name = "mayonnaise"
	id = "mayonnaise"
	description = "Tasty and beauty mayonnaise!"
	reagent_state = LIQUID
	color = "#FFFEF4" // rgb: 255, 254, 244
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_description = "mayonnaise"

/datum/reagent/consumable/guacamole
	name = "guacamole"
	id = "guacamole"
	description = "greenish pasta with a good fruit flavor"
	reagent_state = LIQUID
	color = "#32CD32"
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_description = "avocado"

/datum/reagent/consumable/discount_sauce
	name = "discount sauce"
	id = "discount_sauce"
	description = "Nice and tasty sauce mixed with multiple kinds of stuff!"
	reagent_state = LIQUID
	color = "#f4fffab3" // rgb: 255, 254, 244
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_description = "sweet iron"

/datum/reagent/consumable/discount_sauce/on_mob_life(mob/living/M)
	if(prob(25))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(20))
		M.reagents.add_reagent("porktonium", 5)
	if(prob(30))
		M.reagents.add_reagent("omnizine", 5)
	return ..()
