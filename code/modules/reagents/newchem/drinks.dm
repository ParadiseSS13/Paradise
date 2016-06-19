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
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/ginsonic/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness = max(0, M.drowsyness-5)
	if(prob(25))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	if(prob(8))
		M.reagents.add_reagent("methamphetamine",1.2)
		var/sonic_message = pick("Gotta go fast!", "Time to speed, keed!", "I feel a need for speed!", "Let's juice.", "Juice time.", "Way Past Cool!")
		if(prob(50))
			M.say("[sonic_message]")
		else
			to_chat(M, "<span class='notice'>[sonic_message ]</span>")
	..()
	return

/datum/reagent/ethanol/applejack
	name = "Applejack"
	id = "applejack"
	description = "A highly concentrated alcoholic beverage made by repeatedly freezing cider and removing the ice."
	color = "#997A00"
	alcohol_perc = 0.4

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
	alcohol_perc = 0.4

/datum/chemical_reaction/jackrose
	name = "jackrose"
	id = "jackrose"
	result = "jackrose"
	required_reagents = list("applejack" = 4, "lemonjuice" = 1)
	result_amount = 5
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'


/datum/reagent/ethanol/dragons_breath //inaccessible to players, but here for admin shennanigans
	name = "Dragon's Breath"
	id = "dragonsbreath"
	description = "Possessing this stuff probably breaks the Geneva convention."
	reagent_state = LIQUID
	color = "#DC0000"
	alcohol_perc = 1

/datum/reagent/ethanol/dragons_breath/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == INGEST && prob(20))
		if(M.on_fire)
			M.adjust_fire_stacks(3)

/datum/reagent/ethanol/dragons_breath/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.reagents.has_reagent("milk"))
		to_chat(M, "<span class='notice'>The milk stops the burning. Ahhh.</span>")
		M.reagents.del_reagent("milk")
		M.reagents.del_reagent("dragonsbreath")
		return
	if(prob(8))
		to_chat(M, "<span class='userdanger'>Oh god! Oh GODD!!</span>")
	if(prob(50))
		to_chat(M, "<span class='danger'>Your throat burns terribly!</span>")
		M.emote(pick("scream","cry","choke","gasp"))
		M.Stun(1)
	if(prob(8))
		to_chat(M, "<span class='danger'>Why!? WHY!?</span>")
	if(prob(8))
		to_chat(M, "<span class='danger'>ARGHHHH!</span>")
	if(prob(2 * volume))
		to_chat(M, "<span class='userdanger'>OH GOD OH GOD PLEASE NO!!</b></span>")
		if(M.on_fire)
			M.adjust_fire_stacks(5)
		if(prob(50))
			to_chat(M, "<span class='userdanger'>IT BURNS!!!!</span>")
			M.visible_message("<span class='danger'>[M] is consumed in flames!</span>")
			M.dust()
			return
	..()

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
	alcohol_perc = 0.5

/datum/chemical_reaction/synthanol
	name = "Synthanol"
	id = "synthanol"
	result = "synthanol"
	required_reagents = list("lube" = 1, "plasma" = 1, "fuel" = 1)
	result_amount = 3
	mix_message = "The chemicals mix to create shiny, blue substance."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/ethanol/synthanol/on_mob_life(var/mob/living/M as mob, var/alien)
	if(!M.isSynthetic())
		holder.remove_reagent(id, 3.6) //gets removed from organics very fast
		if(prob(25))
			holder.remove_reagent(id, 15)
			M.fakevomit()
	..()

datum/reagent/ethanol/synthanol/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(M.isSynthetic())
		return
	if(method == INGEST)
		to_chat(M, pick("<span class = 'danger'>That was awful!</span>", "<span class = 'danger'>Yuck!</span>"))

/datum/reagent/ethanol/synthanol/robottears
	name = "Robot Tears"
	id = "robottears"
	description = "An oily substance that an IPC could technically consider a 'drink'."
	reagent_state = LIQUID
	color = "#363636"
	alcohol_perc = 0.25

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
	alcohol_perc = 0.2

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
	alcohol_perc = 0.25

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
	alcohol_perc = 0.15

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
	alcohol_perc = 0.25

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
	alcohol_perc = 0.25

/datum/chemical_reaction/synthanol/synthignon
	name = "Synthignon"
	id = "synthignon"
	result = "synthignon"
	required_reagents = list("synthanol" = 1, "wine" = 1)
	result_amount = 2

// ROBOT ALCOHOL ENDS
