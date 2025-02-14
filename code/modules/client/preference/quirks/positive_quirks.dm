/datum/quirk/skittish
	name = "Skittish"
	desc = "You can hide yourself in crates by lying down, and WILL jump into a locker or crate if you bump into one while running, as long as you have access."
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

/datum/quirk/heavy_drinker
	name = "Heavy Drinker"
	desc = "You're used to the effects of alcohol, and get drunk slower than others."
	cost = 1
	var/alcohol_modifier = 0.7

/datum/quirk/heavy_drinker/apply_quirk_effects(mob/living/quirky)
	if(!ishuman(quirky))
		return
	var/mob/living/carbon/human/user = quirky
	user.physiology.alcohol_mod *= alcohol_modifier
	. = ..()

/datum/quirk/meal_prepper
	name = "Meal Prepper"
	desc = "You thought ahead and pre-packed a meal for the day."
	cost = 1
	item_to_give = /obj/item/storage/box/papersack/prepped_meal

/datum/quirk/glutton // TODO test
	name = "Glutton"
	desc = "You can eat faster, and don't suffer any ill-effects from being overweight. IPCs cannot take this."
	cost = 2
	trait_to_apply = TRAIT_GLUTTON
	organic_only = TRUE

/obj/item/storage/box/papersack/prepped_meal
	name = "packed meal"

/obj/item/storage/box/papersack/prepped_meal/populate_contents() //Just go with this for ease right now, but maybe make a more interesting lunch spawner later
	new /obj/item/food/customizable/sandwich(src)
	new /obj/item/food/chips(src)
	new /obj/item/reagent_containers/drinks/cans/cola(src)

/datum/quirk/upgraded_lungs
	name = "Upgraded Cybernetic Lungs"
	desc  = "Your lungs have been replaced with upgraded cybernetics."
	cost = 2
	organic_only = TRUE
	organ_to_give = /obj/item/organ/internal/lungs/cybernetic/upgraded
