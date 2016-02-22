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


// ROBOT ALCOHOL PAST THIS POINT
// WOOO!


/datum/reagent/ethanol/synthanol
	name = "Synthanol"
	id = "synthanol"
	description = "A runny liquid with conductive capacities. Its effects on synthetics are similar to those of alcohol on organics."
	reagent_state = LIQUID
	color = "#1BB1FF"
	process_flags = SYNTHETIC
	metabolization_rate = 0.4
	vomit_start = INFINITY		//
	blur_start = INFINITY		//
	pass_out = INFINITY			//INFINITY, so that IPCs don't puke and stuff
	var/collapse_start = 200	//amount absorbed after wich mob starts collapsing
	var/braindamage_start = 300 //amount absorbed after which mob starts taking small amount of brain damage


/datum/chemical_reaction/synthanol
	name = "Synthanol"
	id = "synthanol"
	result = "synthanol"
	required_reagents = list("lube" = 1, "plasma" = 1, "fuel" = 1)
	result_amount = 3
	mix_message = "The chemicals mix to create shiny, blue substance."

/datum/reagent/ethanol/synthanol/on_mob_life(var/mob/living/M as mob, var/alien)
	if(!src.data) data = 1
	src.data++

	var/d = data

	// make all the synthanol children work together
	for(var/datum/reagent/ethanol/synthanol/A in holder.reagent_list)
		if(isnum(A.data)) d += A.data

	if(d >= collapse_start && prob(10))
		M.emote("collapse")
		var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
		s.set_up(3, 1, M)
		s.start()
	if(d >= braindamage_start && prob(33))
		M.adjustBrainLoss(1)
	..()

/datum/reagent/ethanol/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	description = "An oily substance that an IPC could technically consider a 'drink'."
	reagent_state = LIQUID
	color = "#363636"

/datum/chemical_reaction/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	result = "robottears"
	required_reagents = list("synthanol" = 1, "oil" = 1, "sodawater" = 1)
	result_amount = 3
	mix_message = "The ingredients combine into a stiff, dark goo."

/datum/reagent/ethanol/synthanol/trinary
	name = "Trinary"
	id = "trinary"
	description = "A fruit drink meant only for synthetics, however that works."
	reagent_state = LIQUID
	color = "#adb21f"

/datum/chemical_reaction/synthanol/trinary
	name = "Trinary"
	id = "trinary"
	result = "trinary"
	required_reagents = list("synthanol" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 3
	mix_message = "The ingredients mix into a colorful substance."

/datum/reagent/ethanol/synthanol/servo
	name = "Servo"
	id = "servo"
	description = "A drink containing some organic ingredients, but meant only for synthetics."
	reagent_state = LIQUID
	color = "#5b3210"

/datum/chemical_reaction/synthanol/servo
	name = "Servo"
	id = "servo"
	result = "servo"
	required_reagents = list("synthanol" = 2, "cream" = 1, "hot_coco" = 1)
	result_amount = 4
	mix_message = "The ingredients mix into a dark brown substance."

// ROBOT ALCOHOL ENDS