/datum/quirk/positive
	quirk_type = QUIRK_POSITIVE

/datum/quirk/positive/skittish
	name = "Skittish"
	desc = "You've learned how to hide yourself well, and can quickly scurry into closed closets by Ctrl+Shift+Clicking them, as long as you have access."
	cost = 4
	trait_to_apply = TRAIT_SKITTISH

/datum/quirk/positive/freerunner
	name = "Freefrunner"
	desc = "You can vault over tables faster than others."
	cost = 4
	trait_to_apply = TRAIT_FREERUNNER

/datum/quirk/positive/crafty
	name = "Crafty"
	desc = "You can craft things faster than normal."
	cost = 2
	trait_to_apply = TRAIT_CRAFTY

/datum/quirk/positive/heavy_drinker
	name = "Heavy Drinker"
	desc = "You're used to the effects of alcohol, and get drunk slower than others."
	cost = 1
	var/alcohol_modifier = 0.8

/datum/quirk/positive/heavy_drinker/apply_quirk_effects(mob/living/quirky)
	if(!ishuman(quirky))
		return
	var/mob/living/carbon/human/user = quirky
	user.physiology.alcohol_mod *= alcohol_modifier
	. = ..()

/datum/quirk/positive/light_step
	name = "Light Step"
	desc = "Your footsteps are quieter, and stepping on sharp objects hurts less."
	cost = 3
	trait_to_apply = TRAIT_LIGHT_STEP

/datum/quirk/positive/meal_prepper
	name = "Meal Prepper"
	desc = "You thought ahead and pre-packed a meal for the day."
	cost = 1
	items_to_give = list(/obj/item/storage/box/papersack/prepped_meal)

/obj/item/storage/box/papersack/prepped_meal
	name = "packed meal"

/obj/item/storage/box/papersack/prepped_meal/populate_contents() //Just go with this for ease right now, but maybe make a more interesting lunch spawner later
	new /obj/item/food/customizable/sandwich(src)
	new /obj/item/food/chips(src)
	new /obj/item/reagent_containers/drinks/cans/cola(src)
