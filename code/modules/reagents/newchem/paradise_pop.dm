
/*
	Paradise Pop reagents
	Created through the bottler machine via bottler_recipes, not through standard reactions
	Eventually will have special effects (minor mostly) tied to their reagents, but for now are purely for flavor

	Make sure to yell at me to finish giving them effects later
	-FalseIncarnate
*/


//Paradise Punch: No effect, aside from maybe messages about how tasty it is or something
/datum/reagent/paradise_punch
	name = "Paradise Punch"
	id = "paradise_punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	reagent_state = LIQUID
	color = "#cc0044"

//Apple-pocalypse: Low chance to cause a goonchem vortex that pulls things within a very small radius (2 tiles?) towards the drinker
/datum/reagent/apple_pocalypse
	name = "Apple-pocalypse"
	id = "apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	reagent_state = LIQUID
	color = "#44FF44"

//Berry Banned: This one is tasty and safe to drink, might have a low chance of healing a random damage type?
/datum/reagent/berry_banned
	name = "Berry Banned"
	id = "berry_banned"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"

//Berry Banned 2: This one is tasty and toxic. Deals toxin damage and MAYBE plays the "BWOINK!" sound if it kills someone?
/datum/reagent/berry_banned2
	name = "Berry Banned"
	id = "berry_banned2"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"

//Blackeye Brew: Chance to make the drinker say greytider-themed things like "I thought clown was valid!"
/datum/reagent/blackeye_brew
	name = "Blackeye Brew"
	id = "blackeye_brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	reagent_state = LIQUID
	color = "#4d2600"

//Grape Granade: causes the drinker to sometimes burp, has a low chance to cause a goonchem vortex that pushes things within a very small radius (1-2 tiles) away from the drinker
/datum/reagent/grape_granade
	name = "Grape Granade"
	id = "grape_granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	reagent_state = LIQUID
	color = "#9933ff"

//Meteor Malt: Sometimes causes screen shakes for the drinker like a meteor impact, low chance to add 1-5 units of a random mineral reagent to the drinker's blood (iron, copper, silver, gold, uranium, carbon, etc)
/datum/reagent/meteor_malt
	name = "Meteor Malt"
	id = "meteor_malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	reagent_state = LIQUID
	color = "#cc9900"
