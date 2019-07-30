/*
	Paradise Pop reagents
	Created through the bottler machine via bottler_recipes, not through standard reactions
	Eventually will have special effects (minor mostly) tied to their reagents, but for now are purely for flavor

	Make sure to yell at me to finish giving them effects later
	-FalseIncarnate
*/


//Paradise Punch: No effect, aside from maybe messages about how tasty it is or something
/datum/reagent/consumable/drink/paradise_punch
	name = "Paradise Punch"
	id = "paradise_punch"
	description = "Tastes just how you'd think Paradise would if you could bottle it."
	reagent_state = LIQUID
	color = "#cc0044"
	taste_description = "paradise"

//Apple-pocalypse: Low chance to cause a goonchem vortex that pulls things within a very small radius (2 tiles?) towards the drinker
/datum/reagent/consumable/drink/apple_pocalypse
	name = "Apple-pocalypse"
	id = "apple-pocalypse"
	description = "If doomsday came in fruit form, it'd probably be apples."
	reagent_state = LIQUID
	color = "#44FF44"
	taste_description = "doomsday"

/datum/reagent/consumable/drink/apple_pocalypse/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 1, 0)
		to_chat(M, "<span class='notice'>You briefly feel super-massive, like a black hole. Probably just your imagination...</span>")
	return ..()

//Berry Banned: This one is tasty and safe to drink, might have a low chance of healing a random damage type?
/datum/reagent/consumable/drink/berry_banned
	name = "Berry Banned"
	id = "berry_banned"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"
	taste_description = "a permaban"

/datum/reagent/consumable/drink/berry_banned/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		var/heal_type = rand(0, 5)		//still prefer the string version
		switch(heal_type)
			if(0)
				update_flags |= M.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			if(1)
				update_flags |= M.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			if(2)
				update_flags |= M.adjustToxLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			if(3)
				update_flags |= M.adjustOxyLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			if(4)
				update_flags |= M.adjustCloneLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			if(5)
				update_flags |= M.adjustBrainLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		to_chat(M, "<span class='notice'>You feel slightly rejuvinated!</span>")
	return ..() | update_flags

//Berry Banned 2: This one is tasty and toxic. Deals toxin damage and MAYBE plays the "BWOINK!" sound if it kills someone?
/datum/reagent/consumable/drink/berry_banned2
	name = "Berry Banned"
	id = "berry_banned2"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"
	taste_description = "a permaban"

/datum/reagent/consumable/drink/berry_banned2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(50))
		update_flags |= M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER, FALSE)		//double strength of poison berry juice alone, because it's concentrated (this is equal to the damage of normal toxin, less often)
	if(prob(10))
		to_chat(M, "<span class='notice'>You feel slightly rejuvinated!</span>")		//meta this!
	return ..() | update_flags

/datum/reagent/consumable/drink/berry_banned2/on_mob_death(mob/living/M)
	M << sound('sound/effects/adminhelp.ogg',0,1,0,25)
	to_chat(M, "<span class='adminhelp'>PM from-<b>Administrator</b>: BWOINK!</span>")
	..()

//Blackeye Brew: Chance to make the drinker say greytider-themed things like "I thought clown was valid!"
/datum/reagent/consumable/drink/blackeye_brew
	name = "Blackeye Brew"
	id = "blackeye_brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	reagent_state = LIQUID
	color = "#4d2600"
	taste_description = "greytide"

/datum/reagent/consumable/drink/blackeye_brew/on_mob_life(mob/living/M)
	if(prob(25))
		var/list/tider_talk = list("I OWN THIS STATION NOW, I JUST BOUGHT IT.",
									"SECRET TECHNIQUE: TOOLBOX TO THE FACE!",
									"SECRET TECHNIQUE: PLASMA CANISTER FIRE!",
									"SECRET TECHNIQUE: TABLE AND DISPOSAL!",
									"[pick("MY BROTHER", " MY DOG", "MY BEST FRIEND", "THE BORER", "GEORGE MELONS", "BADMINS")] DID IT!",
									";s WHATS SPACE LAW?!",
									"I BOUGHT THESE GLOVES, NOT STEAL THEM",
									"THIS DOOR WAS SHOCKED WHEN I GOT HERE",
									"ANIMALS ARE NOT CREW")
		M.say(pick(tider_talk))
	return ..()

//Grape Granade: causes the drinker to sometimes burp, has a low chance to cause a goonchem vortex that pushes things within a very small radius (1-2 tiles) away from the drinker
/datum/reagent/consumable/drink/grape_granade
	name = "Grape Granade"
	id = "grape_granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	reagent_state = LIQUID
	color = "#9933ff"
	taste_description = "old people"

/datum/reagent/consumable/drink/grape_granade/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 0, 0)
		M.emote("burp")
		to_chat(M, "<span class='notice'>You feel ready to burst! Oh wait, just a burp...</span>")
	else if(prob(25))
		M.emote("burp")
	return ..()

//Meteor Malt: Sometimes causes screen shakes for the drinker like a meteor impact, low chance to add 1-5 units of a random mineral reagent to the drinker's blood (iron, copper, silver, gold, uranium, carbon, etc)
/datum/reagent/consumable/drink/meteor_malt
	name = "Meteor Malt"
	id = "meteor_malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	reagent_state = LIQUID
	color = "#cc9900"
	taste_description = "flying space rocks"

/datum/reagent/consumable/drink/meteor_malt/on_mob_life(mob/living/M)
	if(prob(25))
		M << sound('sound/effects/meteorimpact.ogg',0,1,0,25)
		shake_camera(M, 3, 1)
	if(prob(5))
		var/amount = rand(1, 5)
		var/mineral = pick("copper", "iron", "gold", "carbon", "silver", "aluminum", "silicon", "sodiumchloride", "plasma")
		M.reagents.add_reagent(mineral, amount)
	return ..()
