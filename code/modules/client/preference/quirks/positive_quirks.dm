/datum/quirk/skittish
	name = "Skittish"
	desc = "You can hide yourself in crates by lying down, and WILL jump into a locker or crate if you bump into one while running, \
			as long as you have access."
	cost = 4
	trait_to_apply = TRAIT_SKITTISH

/datum/quirk/freerunner
	name = "Freerunner"
	desc = "You're practiced in vaulting over things."
	cost = 4
	trait_to_apply = TRAIT_FREERUNNER

/datum/quirk/crafty
	name = "Crafty"
	desc = "You can craft things twice as fast."
	cost = 2
	trait_to_apply = TRAIT_CRAFTY

/datum/quirk/alcohol_tolerance/heavy_drinker
	name = "Heavy Drinker"
	desc = "You're used to the effects of alcohol, and get drunk slower than others."
	cost = 1
	alcohol_modifier = 0.7

/datum/quirk/meal_prepper
	name = "Meal Prepper"
	desc = "You thought ahead and pre-packed a meal for the day."
	cost = 1
	item_to_give = /obj/item/storage/box/papersack/prepped_meal

/datum/quirk/glutton
	name = "Glutton"
	desc = "You can eat faster, and don't suffer any ill-effects from being overweight. IPCs cannot take this."
	cost = 2
	trait_to_apply = TRAIT_GLUTTON
	species_flags = QUIRK_MACHINE_INCOMPATIBLE

/obj/item/storage/box/papersack/prepped_meal
	name = "packed meal"
	var/list/entree_options = list(
		/obj/item/food/sandwich,
		/obj/item/food/toastedsandwich,
		/obj/item/food/jellysandwich/cherry,
		/obj/item/food/grilledcheese,
		/obj/item/food/burger/cheese,
		/obj/item/food/blt,
		/obj/item/food/philly_cheesesteak,
		/obj/item/food/sliced/hawaiian_pizza,
		/obj/item/food/sliced/pepperoni_pizza,
		/obj/item/food/meatkebab,
		/obj/item/food/salmonsteak, // If anyone microwaves their leftover fish in the workplace it should be on sight
		/obj/item/food/shrimp_skewer,
		/obj/item/food/omelette
	)
	var/list/snack_options = list(
		/obj/item/food/chips,
		/obj/item/food/sosjerky,
		/obj/item/food/pistachios,
		/obj/item/food/no_raisin,
		/obj/item/food/stroopwafel,
		/obj/item/food/candy/toffee,
		/obj/item/food/candy/chocolate_orange,
		/obj/item/food/sliced/mothmallow,
		/obj/item/food/sliced/apple_cake,
		/obj/item/food/sliced/banarnarbread

	)
	var/list/drink_options = list(
		/obj/item/reagent_containers/drinks/h_chocolate,
		/obj/item/reagent_containers/drinks/tea,
		/obj/item/reagent_containers/drinks/cans/cola,
		/obj/item/reagent_containers/drinks/cans/space_mountain_wind,
		/obj/item/reagent_containers/drinks/cans/dr_gibb,
		/obj/item/reagent_containers/drinks/cans/space_up,
		/obj/item/reagent_containers/drinks/cans/iced_tea,
		/obj/item/reagent_containers/drinks/cans/starkist,
		/obj/item/reagent_containers/drinks/bottle/beer // Don't tell your boss
	)

/obj/item/storage/box/papersack/prepped_meal/populate_contents()
	var/entree = pick(entree_options)
	var/snack = pick(snack_options)
	var/drink = pick(drink_options)
	new entree (src)
	new snack (src)
	new drink (src)

/datum/quirk/upgraded_lungs
	name = "Upgraded Cybernetic Lungs"
	desc  = "Your lungs have been replaced with upgraded cybernetics."
	cost = 3
	species_flags = QUIRK_MACHINE_INCOMPATIBLE
	organ_to_give = /obj/item/organ/internal/lungs/cybernetic/upgraded

/datum/quirk/upgraded_lungs/give_organ(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	if(spawned != owner)
		return
	var/obj/item/organ/internal/lungs/cybernetic/new_lungs = new organ_to_give
	if(isvox(owner))
		new_lungs.configure_species("vox")
	if(isplasmaman(owner))
		new_lungs.configure_species("plasmamen")
	INVOKE_ASYNC(new_lungs, TYPE_PROC_REF(/obj/item/organ/internal, insert), owner, TRUE)

/datum/quirk/culinary_implant
	name = "IPC Culinary Implant"
	desc = "Either you or your creator wanted you to seem more organic, and gave you an artificial mouth and stomach."
	cost = 2
	species_flags = QUIRK_ORGANIC_INCOMPATIBLE
	organ_to_give = /obj/item/organ/internal/cyberimp/chest/ipc_food

/datum/quirk/home_cook
	name = "Home Cook"
	desc = "You have experience in the kitchen, and can examine kitchen machinery to see if the ingredients inside will cook into a proper meal. \
			Chefs can already do this."
	cost = 1
	trait_to_apply = TRAIT_KNOWS_COOKING_RECIPES

/datum/quirk/pet_owner
	name = "Animal Lover"
	desc = "You brought one of your pets to work today! Make sure to name them with your collar."
	cost = 1
	item_to_give = /obj/item/petcollar
	var/list/possible_pets = list(/mob/living/simple_animal/pet/dog/corgi, /mob/living/simple_animal/pet/cat, /mob/living/simple_animal/pet/dog/pug,
							/mob/living/simple_animal/pet/dog/fox, /mob/living/basic/chick, /mob/living/basic/bunny, /mob/living/basic/turkey)

/datum/quirk/pet_owner/apply_quirk_effects()
	mob_to_spawn = pick(possible_pets)
	..()

/datum/quirk/cool
	name = "Cool"
	desc = "You can land every flip. You're so cool."
	cost = 1
	trait_to_apply = TRAIT_COOL

/datum/quirk/breathing_tube
	name = "Breathing Tube"
	desc  = "You have been outfitted with a breathing tube."
	cost = 2
	species_flags = QUIRK_MACHINE_INCOMPATIBLE
	organ_to_give = /obj/item/organ/internal/cyberimp/mouth/breathing_tube
