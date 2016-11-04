
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

/datum/reagent/apple_pocalypse/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 0, 2, 1)
		to_chat(M, "<span class='notice'>You briefly feel super-massive, like a black hole. Probably just your imagination...</span>")
	..()

//Berry Banned: This one is tasty and safe to drink, might have a low chance of healing a random damage type?
/datum/reagent/berry_banned
	name = "Berry Banned"
	id = "berry_banned"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"

/datum/reagent/berry_banned/on_mob_life(mob/living/M)
	if(prob(10))
		var/heal_type = rand(0, 5)		//still prefer the string version
		switch(heal_type)
			if(0)
				M.adjustBruteLoss(-0.5*REM)
			if(1)
				M.adjustFireLoss(-0.5*REM)
			if(2)
				M.adjustToxLoss(-0.5*REM)
			if(3)
				M.adjustOxyLoss(-0.5*REM)
			if(4)
				M.adjustCloneLoss(-0.5*REM)
			if(5)
				M.adjustBrainLoss(-1*REM)
		to_chat(M, "<span class='notice'>You feel slightly rejuvinated!</span>")
	..()

//Berry Banned 2: This one is tasty and toxic. Deals toxin damage and MAYBE plays the "BWOINK!" sound if it kills someone?
/datum/reagent/berry_banned2
	name = "Berry Banned"
	id = "berry_banned2"
	description = "Reason for ban: Excessive Flavor."
	reagent_state = LIQUID
	color = "#FF44FF"

/datum/reagent/berry_banned2/on_mob_life(mob/living/M)
	if(prob(50))
		M.adjustToxLoss(2*REM)		//double strength of poison berry juice alone, because it's concentrated (this is equal to the damage of normal toxin, less often)
	if(prob(10))
		to_chat(M, "<span class='notice'>You feel slightly rejuvinated!</span>")		//meta this!
	..()

/datum/reagent/berry_banned2/on_mob_death(mob/living/M)
	M << sound('sound/effects/adminhelp.ogg',0,1,0,25)
	to_chat(M, "<span class='adminhelp'>PM from-<b>Administrator</b>: BWOINK!</span>")
	..()

//Blackeye Brew: Chance to make the drinker say greytider-themed things like "I thought clown was valid!"
/datum/reagent/blackeye_brew
	name = "Blackeye Brew"
	id = "blackeye_brew"
	description = "Creamy, smooth flavor, just like the bald heads of the masses. Supposedly aged for 30 years."
	reagent_state = LIQUID
	color = "#4d2600"

/datum/reagent/blackeye_brew/on_mob_life(mob/living/M)
	if(prob(25))
		var/list/tider_talk = list("CLOWN IS VALID, RIGHT?",
									"SHITMINS! SHITMINS! SHITMINS!",
									"FURRIES ARE OPPRESSED!",
									"I OWN THIS SERVER NOW, I JUST BOUGHT IT.",
									"SECRET TECHNIQUE: TOOLBOX TO THE FACE!",
									"SECRET TECHNIQUE: PLASMA CANISTER FIRE!",
									"SECRET TECHNIQUE: TABLE AND DISPOSAL!",
									"[pick("MY BROTHER", " MY DOG", "MY BEST FRIEND", "THE BORER", "GEORGE MELONS", "SHITMINS")] DID IT!",
									"WHAT DO YOU MEAN [pick("Barrack Obama", "John Cena", "Hughe Jass", "Hitler", "xX360noscopeXx")] ISN'T AN ACCEPTABLE NAME?",
									"WHAT THE FUCK DID YOU JUST FUCKING SAY ABOUT ME, YOU LITTLE BITCH? I'LL HAVE YOU KNOW I GRADUATED TOP OF MY CLASS IN...")
		M.say(pick(tider_talk))
	..()

//Grape Granade: causes the drinker to sometimes burp, has a low chance to cause a goonchem vortex that pushes things within a very small radius (1-2 tiles) away from the drinker
/datum/reagent/grape_granade
	name = "Grape Granade"
	id = "grape_granade"
	description = "Exploding with grape flavor and a favorite among ERT members system-wide."
	reagent_state = LIQUID
	color = "#9933ff"

/datum/reagent/grape_granade/on_mob_life(mob/living/M)
	if(prob(1))
		var/turf/simulated/T = get_turf(M)
		goonchem_vortex(T, 1, 1, 2)
		M.emote("burp")
		to_chat(M, "<span class='notice'>You feel ready to burst! Oh wait, just a burp...</span>")
	else if(prob(25))
		M.emote("burp")
	..()

//Meteor Malt: Sometimes causes screen shakes for the drinker like a meteor impact, low chance to add 1-5 units of a random mineral reagent to the drinker's blood (iron, copper, silver, gold, uranium, carbon, etc)
/datum/reagent/meteor_malt
	name = "Meteor Malt"
	id = "meteor_malt"
	description = "Soft drinks have been detected on collision course with your tastebuds."
	reagent_state = LIQUID
	color = "#cc9900"

/datum/reagent/meteor_malt/on_mob_life(mob/living/M)
	if(prob(25))
		M << sound('sound/effects/meteorimpact.ogg',0,1,0,25)
		shake_camera(M, 3, 1)
	if(prob(5))
		var/amount = rand(1, 5)
		var/mineral = pick("copper", "iron", "gold", "carbon", "silver", "aluminum", "silicon", "sodiumchloride", "plasma")
		M.reagents.add_reagent(mineral, amount)
	..()
