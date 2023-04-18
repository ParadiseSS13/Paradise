
/datum/bottler_recipe
	var/name = ""
	var/description = ""
	var/list/ingredients[3]
	var/datum/reagent/result = null


/* Example of how a bottler_recipe should look:
/datum/bottler_recipe/example
	name = "Example"
	description = "This is an example."
	ingredients = list(thing_1, thing_2, thing_3)
	result = "water"

The ingredients list must have 3 non-null entries.
Failing to ensure the list has EXACTLY 3 entries (unless the system is updated in the future to use a different number) will result in runtimes.
There is no excuse to do this wrong now that there is an example for you. --FalseIncarnate
*/


/datum/bottler_recipe/Paradise_Punch
	name = "Paradise Punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/grapes,
					/obj/item/reagent_containers/food/snacks/grown/banana,
					/obj/item/reagent_containers/food/snacks/grown/cherries)
	result = "paradise_punch"

/datum/bottler_recipe/Applepocalypse
	name = "Apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/apple,
					/obj/item/reagent_containers/food/snacks/grown/apple,
					/obj/item/reagent_containers/food/snacks/grown/apple)
	result = "apple-pocalypse"

/datum/bottler_recipe/Berry_Banned2 // Berry_Banned2 must be first in recipes list, before Berry_Banned, since we are using poison berries specifically
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries/poison,
					/obj/item/reagent_containers/food/snacks/grown/berries/poison,
					/obj/item/reagent_containers/food/snacks/grown/berries/poison)
	result = "berry_banned2"

/datum/bottler_recipe/Berry_Banned
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/berries,
					/obj/item/reagent_containers/food/snacks/grown/berries,
					/obj/item/reagent_containers/food/snacks/grown/berries)
	result = "berry_banned"

/datum/bottler_recipe/Blackeye_Brew
	name = "Blackeye Brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	ingredients = list(/obj/item/reagent_containers/food/drinks/cans/cola,
					/obj/item/reagent_containers/food/snacks/grown/sugarcane,
					/obj/item/reagent_containers/food/snacks/icecream)
	result = "blackeye_brew"

/datum/bottler_recipe/Grape_Granade
	name = "Grape Granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	ingredients = list(/obj/item/reagent_containers/food/drinks/cans/grape_juice,
					/obj/item/reagent_containers/food/snacks/grown/grapes,
					/obj/item/flash)
	result = "grape_granade"

/datum/bottler_recipe/Meteor_Malt
	name = "Meteor Malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	ingredients = list(/obj/item/stack/ore,
					/obj/item/reagent_containers/food/snacks/grown/wheat,
					/obj/item/stack/ore)
	result = "meteor_malt"

/datum/bottler_recipe/moonlight_skuma
	name = "Moon'drin"
	description = "Double distilled Moon'lin. Soft mint taste which is loved by all tajarans."
	ingredients = list(/obj/item/reagent_containers/food/snacks/grown/moonlight,
					/obj/item/reagent_containers/food/snacks/grown/moonlight,
					/obj/item/reagent_containers/food/snacks/grown/moonlight)
	result = "moonlight_skuma"
