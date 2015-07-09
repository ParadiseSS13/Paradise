/datum/reagent/ginsonic
	name = "Gin and sonic"
	id = "ginsonic"
	description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
	reagent_state = LIQUID
	color = "#1111CF"

/datum/chemical_reaction/ginsonic
	name = "ginsonic"
	id = "ginsonic"
	result = "ginsonic"
	required_reagents = list("gintonic" = 1, "methamphetamine" = 1)
	result_amount = 2
	mix_message = "The drink turns electric blue and starts quivering violently."

/datum/reagent/ginsonic/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(10))
		M.reagents.add_reagent("methamphetamine",1.2)
	M.reagents.add_reagent("ethanol",1.4)
	if(prob(8))
		M.say(pick("Gotta go fast!", "Let's juice.", "I feel a need for speed!", "Way Past Cool!"))
	if(prob(8))
		switch(pick(1, 2, 3))
			if(1)
				M << "<span class='notice'>Time to speed, keed!</span>"
			if(2)
				M << "<span class='notice'>Let's juice.</span>"
			if(3)
				M << "<span class='notice'>Way Past Cool!</span>"
	..()
	return

/datum/reagent/ethanol/applejack
	name = "Applejack"
	id = "applejack"
	description = "A highly concentrated alcoholic beverage made by repeatedly freezing cider and removing the ice."
	color = "#997A00"
	slur_start = 30
	brawl_start = 40
	confused_start = 100

/datum/chemical_reaction/applejack
	name = "applejack"
	id = "applejack"
	result = "applejack"
	required_reagents = list("cider" = 2)
	max_temp = 270
	result_amount = 1
	mix_message = "The drink darkens as the water freezes, leaving the concentrated cider behind."
	mix_sound = null

/datum/reagent/ethanol/jackrose
	name = "Jack Rose"
	id = "jackrose"
	description = "A classic cocktail that had fallen out of fashion, but never out of taste,"
	color = "#664300"

/datum/chemical_reaction/jackrose
	name = "jackrose"
	id = "jackrose"
	result = "jackrose"
	required_reagents = list("applejack" = 4, "lemonjuice" = 1)
	result_amount = 5
