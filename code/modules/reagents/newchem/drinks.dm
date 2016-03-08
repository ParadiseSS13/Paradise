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
	process_flags = ORGANIC | SYNTHETIC
	metabolization_rate = 0.4
	vomit_start = INFINITY		//
	blur_start = INFINITY		//
	pass_out = INFINITY			//INFINITY, so that IPCs don't puke and stuff
	var/spark_start = 50	//amount absorbed after which mob starts sparking
	var/collapse_start = 150	//amount absorbed after wich mob starts sparking and collapsing (DOUBLE THE SPARKS, DOUBLE THE FUN)
	var/braindamage_start = 250 //amount absorbed after which mob starts taking a small amount of brain damage


/datum/chemical_reaction/synthanol
	name = "Synthanol"
	id = "synthanol"
	result = "synthanol"
	required_reagents = list("lube" = 1, "plasma" = 1, "fuel" = 1)
	result_amount = 3
	mix_message = "The chemicals mix to create shiny, blue substance."

/datum/reagent/ethanol/synthanol/on_mob_life(var/mob/living/M as mob, var/alien)

	var/d = data
	if(M.get_species() == "Machine")
		if(d >= spark_start && prob(25))
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(3, 1, M)
			s.start()
		if(d >= collapse_start && prob(10))
			M.emote("collapse")
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(3, 1, M)
			s.start()
		if(d >= braindamage_start && prob(33))
			M.adjustBrainLoss(1)
		..()
	else
		if(prob(8))
			M.fakevomit()


datum/reagent/ethanol/synthanol/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(M.get_species()=="Machine")
		return
	if(method == INGEST)
		M << pick("<span class = 'danger'>That was awful!</span>", "<span class = 'danger'>Yuck!</span>")

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

/datum/reagent/ethanol/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	description = "A potent mix of alcohol and synthanol. Will only work on synthetics."
	reagent_state = LIQUID
	color = "#e7ae04"

/datum/chemical_reaction/synthanol/uplink
	name = "Uplink"
	id = "uplink"
	result = "uplink"
	required_reagents = list("rum" = 1, "vodka" = 1, "tequilla" = 1, "whiskey" = 1, "synthanol" = 1)
	result_amount = 5

/datum/reagent/ethanol/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	description = "The classic drink adjusted for a robot's tastes."
	reagent_state = LIQUID
	color = "#7204e7"

/datum/chemical_reaction/synthanol/synthnsoda
	name = "Synth 'n Soda"
	id = "synthnsoda"
	result = "synthnsoda"
	required_reagents = list("synthanol" = 1, "cola" = 1)
	result_amount = 2

/datum/reagent/ethanol/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	description = "Someone mixed wine and alcohol for robots. Hope you're proud of yourself."
	reagent_state = LIQUID
	color = "#d004e7"

/datum/chemical_reaction/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	result = "synthignon"
	required_reagents = list("synthanol" = 1, "wine" = 1)
	result_amount = 2
// ROBOT ALCOHOL ENDS
