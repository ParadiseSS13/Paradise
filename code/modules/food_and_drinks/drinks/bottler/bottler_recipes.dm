
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


/datum/bottler_recipe/paradise_punch
	name = "Paradise Punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	ingredients = list(/obj/item/food/grown/grapes,
					/obj/item/food/grown/banana,
					/obj/item/food/grown/cherries)
	result = "paradise_punch"

/datum/bottler_recipe/applepocalypse
	name = "Apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	ingredients = list(/obj/item/food/grown/apple,
					/obj/item/food/grown/apple,
					/obj/item/food/grown/apple)
	result = "apple-pocalypse"

/datum/bottler_recipe/berry_banned
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/food/grown/berries,
					/obj/item/food/grown/berries,
					/obj/item/food/grown/berries)
	result = "berry_banned"

/datum/bottler_recipe/berry_banned2
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/food/grown/berries/poison,
					/obj/item/food/grown/berries/poison,
					/obj/item/food/grown/berries/poison)
	result = "berry_banned2"

/datum/bottler_recipe/blackeye_brew
	name = "Blackeye Brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	ingredients = list(/obj/item/reagent_containers/drinks/cans/cola,
					/obj/item/food/grown/sugarcane,
					/obj/item/food/frozen/icecream)
	result = "blackeye_brew"

/datum/bottler_recipe/grape_granade
	name = "Grape Granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	ingredients = list(/obj/item/reagent_containers/drinks/cans/grape_juice,
					/obj/item/food/grown/grapes,
					/obj/item/flash)
	result = "grape_granade"

/datum/bottler_recipe/meteor_malt
	name = "Meteor Malt"
	description = "Soft drinks have been detected on collision course with your taste buds."
	ingredients = list(/obj/item/stack/ore,
					/obj/item/food/grown/wheat,
					/obj/item/stack/ore)
	result = "meteor_malt"
