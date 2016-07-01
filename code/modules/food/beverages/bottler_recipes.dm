
/datum/bottler_recipe
	var/name = ""
	var/description = ""
	var/obj/item/obj_1_item = null
	var/obj_1_kitchen_tag = ""
	var/obj/item/obj_2_item = null
	var/obj_2_kitchen_tag = ""
	var/obj/item/obj_3_item = null
	var/obj_3_kitchen_tag = ""
	var/datum/reagent/result = null

/datum/bottler_recipe/Paradise_Punch
	name = "Paradise Punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	obj_1_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_1_kitchen_tag = "grapes"
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "banana"
	obj_3_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_3_kitchen_tag = "cherries"
	result = "paradise_punch"

/datum/bottler_recipe/Applepocalypse
	name = "Apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	obj_1_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_1_kitchen_tag = "apple"
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "apple"
	obj_3_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_3_kitchen_tag = "apple"
	result = "apple-pocalypse"

/datum/bottler_recipe/Berry_Banned
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	obj_1_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_1_kitchen_tag = "berries"
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "berries"
	obj_3_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_3_kitchen_tag = "berries"
	result = "berry_banned"

/datum/bottler_recipe/Berry_Banned2
	name = "Berry Banned"
	description = "Reason for ban: Excessive Flavor."
	obj_1_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_1_kitchen_tag = "poisonberries"
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "poisonberries"
	obj_3_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_3_kitchen_tag = "poisonberries"
	result = "berry_banned2"

/datum/bottler_recipe/Blackeye_Brew
	name = "Blackeye Brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	obj_1_item = /obj/item/weapon/reagent_containers/food/drinks/cans/cola
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "sugarcane"
	obj_3_item = /obj/item/weapon/reagent_containers/food/snacks/icecream
	result = "blackeye_brew"

/datum/bottler_recipe/Grape_Granade
	name = "Grape Granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	obj_1_item = /obj/item/weapon/reagent_containers/food/drinks/cans/grape_juice
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "grapes"
	obj_3_item = /obj/item/device/flash
	result = "grape_granade"

/datum/bottler_recipe/Meteor_Malt
	name = "Meteor Malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	obj_1_item = /obj/item/weapon/ore
	obj_2_item = /obj/item/weapon/reagent_containers/food/snacks/grown
	obj_2_kitchen_tag = "wheat"
	obj_3_item = /obj/item/weapon/ore
	result = "meteor_malt"
