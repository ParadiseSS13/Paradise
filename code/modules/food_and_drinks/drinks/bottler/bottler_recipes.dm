
/datum/bottler_recipe
	var/name = ""
	var/description = ""
	var/list/ingredients[3]
	var/list/tags[3]
	var/datum/reagent/result = null


/* Example of how a bottler_recipe should look:
/datum/bottler_recipe/example
	name = "Example"
	description = "This is an example."
	ingredients = list(thing_1, thing_2, thing_3)
	tags = list(null, "tag_2", null)
	result = "water"

The ingredients list must have 3 non-null entries.
The tags list must have 3 entries, using null where a tag is unused.
Failing to ensure both lists have EXACTLY 3 entries (unless the system is updated in the future to use a different number) will result in runtimes.
There is no excuse to do this wrong now that there is an example for you. --FalseIncarnate
*/


/datum/bottler_recipe/Paradise_Punch
	name = "Paradise Punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	ingredients = list(/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown)
	tags = list("grapes", "banana", "cherries")
	result = "paradise_punch"

/datum/bottler_recipe/Applepocalypse
	name = "Apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	ingredients = list(/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown)
	tags = list("apple", "apple", "apple")
	result = "apple-pocalypse"

/datum/bottler_recipe/Berry_Banned
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown)
	tags = list("berries", "berries", "berries")
	result = "berry_banned"

/datum/bottler_recipe/Berry_Banned2
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	ingredients = list(/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/grown)
	tags = list("poisonberries", "poisonberries", "poisonberries")
	result = "berry_banned2"

/datum/bottler_recipe/Blackeye_Brew
	name = "Blackeye Brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	ingredients = list(/obj/item/weapon/reagent_containers/food/drinks/cans/cola,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/reagent_containers/food/snacks/icecream)
	tags = list(null, "sugarcane", null)
	result = "blackeye_brew"

/datum/bottler_recipe/Grape_Granade
	name = "Grape Granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	ingredients = list(/obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/device/flash)
	tags = list(null, "grapes", null)
	result = "grape_granade"

/datum/bottler_recipe/Meteor_Malt
	name = "Meteor Malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	ingredients = list(/obj/item/weapon/ore,
					/obj/item/weapon/reagent_containers/food/snacks/grown,
					/obj/item/weapon/ore)
	tags = list(null, "wheat", null)
	result = "meteor_malt"
