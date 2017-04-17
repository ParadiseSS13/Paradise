//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox. I wonder what it says?"
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	icon_resting = "fox_rest"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls","barks")
	emote_see = list("shakes its head", "shivers")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat = 3)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "kicks"
	gold_core_spawnable = CHEM_MOB_SPAWN_FRIENDLY

	var/turns_since_scan = 0
	var/mob/living/movement_target

/mob/living/simple_animal/pet/fox/New()
	if(!vore_organs.len)
		var/datum/belly/B = new /datum/belly(src)
		B.immutable = 1
		B.name = "Stomach"
		B.inside_flavor = "Slick foxguts. Cute on the outside, slimy on the inside!"
		vore_organs[B.name] = B
		vore_selected = B.name

		B.emote_lists[DM_HOLD] = list(
			"The foxguts knead and churn around you harmlessly.",
			"With a loud glorp, some air shifts inside the belly.",
			"A thick drop of warm bellyslime drips onto you from above.",
			"The fox turns suddenly, causing you to shift a little.",
			"During a moment of relative silence, you can hear the fox breathing.",
			"The slimey stomach walls squeeze you lightly, then relax.")

		B.emote_lists[DM_DIGEST] = list(
			"The guts knead at you, trying to work you into thick soup.",
			"You're ground on by the slimey walls, treated like a mouse.",
			"The acrid air is hard to breathe, and stings at your lungs.",
			"You can feel the acids coating you, ground in by the slick walls.",
			"The fox's stomach churns hungrily over your form, trying to take you.",
			"With a loud glorp, the stomach spills more acids onto you.")

	. = ..()

//Captain fox
/mob/living/simple_animal/pet/fox/Renault
	name = "Renault"
	desc = "Renault, the Captain's trustworthy fox. I wonder what it says?"
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID

/mob/living/simple_animal/pet/fox/Renault/New()
	if(!vore_organs.len)
		var/datum/belly/B = new /datum/belly(src)
		B.immutable = 1
		B.name = "Stomach"
		B.inside_flavor = "Slick foxguts. They seem somehow more regal than perhaps other foxes!"
		vore_organs[B.name] = B
		vore_selected = B.name

		B.emote_lists[DM_HOLD] = list(
			"Renault's stomach walls squeeze around you more tightly for a moment, before relaxing, as if testing you a bit.",
			"There's a sudden squeezing as Renault presses a forepaw against his gut over you, squeezng you against the slick walls.",
			"The 'head fox' has a stomach that seems to think you belong to it. It might be hard to argue, as it kneads at your form.",
			"If being in the captain's fox is a promotion, it might not feel like one. The belly just coats you with more thick foxslime.",
			"It doesn't seem like Renault wants to let you out. The stomach and owner possessively squeeze around you.",
			"Renault's stomach walls squeeze closer, as he belches quietly, before swallowing more air. Does he do that on purpose?")

		B.emote_lists[DM_DIGEST] = list(
			"Renault's stomach walls grind hungrily inwards, kneading acids against your form, and treating you like any other food.",
			"The captain's fox impatiently kneads and works acids against you, trying to claim your body for fuel.",
			"The walls knead in firmly, squeezing and tossing you around briefly in disorienting aggression.",
			"Renault belches, letting the remaining air grow more acrid. It burns your lungs with each breath.",
			"A thick glob of acids drip down from above, adding to the pool of caustic fluids in Renault's belly.",
			"There's a loud gurgle as the stomach declares the intent to make you a part of Renault.")

	..()

/mob/living/simple_animal/pet/fox/Renault/handle_automated_action()
	. = ..()

	if(!incapacitated())
		for(var/mob/living/L in range(1, src))
			if(Adjacent(L) && L == movement_target)
				perform_the_nom(src, L, src, "Stomach")
				movement_target = null

/mob/living/simple_animal/pet/fox/Renault/handle_automated_movement()
	. = ..()

	if(!incapacitated())
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if(movement_target && !isturf(movement_target.loc))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(movement_target.loc in oview(src, 3)))
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/snack in oview(src, 3))
					if(isturf(snack.loc) && !snack.stat)
						if(snack.get_species() == "Vulpkanin") //is this caninebalism
							movement_target = snack
							break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src, movement_target, 0, 3)


//Syndi fox
/mob/living/simple_animal/pet/fox/Syndifox
	name = "Syndifox"
	desc = "Syndifox, the Syndicate's most respected mascot. I wonder what it says?"
	icon_state = "Syndifox"
	icon_living = "Syndifox"
	icon_dead = "Syndifox_dead"
	icon_resting = "Syndifox_rest"
	flags = NO_BREATHE
	faction = list("syndicate")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0