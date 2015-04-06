/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "A gross and unidentifiable substance."
	reagent_state = LIQUID
	color = "#63DE63"
	metabolization_rate = 0.4

datum/reagent/questionmark/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		M.Weaken(2)
		M << "<span class = 'danger'>Ugh! Eating that was a terrible idea!</span>"

datum/reagent/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	color = "#F0C814"

datum/reagent/egg/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5))
		M.emote("fart")
	..()
	return

datum/reagent/triple_citrus
	name = "Triple Citrus"
	id = "triple_citrus"
	description = "A refreshing mixed drink of orange, lemon and lime juice."
	reagent_state = LIQUID
	color = "#23A046"

/datum/chemical_reaction/triple_citrus
	name = "triple_citrus"
	id = "triple_citrus"
	result = "triple_citrus"
	required_reagents = list("lemonjuice" = 1, "limejuice" = 1, "orangejuice" = 1)
	result_amount = 3
	mix_message = "The citrus juices begin to blend together."

datum/reagent/triple_citrus/reaction_mob(var/mob/living/carbon/M as mob, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living/carbon))
		return
	if(method == INGEST)
		M.adjustToxLoss(-rand(1,2))

datum/reagent/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "The powdered starch of maize, derived from the kernel's endosperm. Used as a thickener for gravies and puddings."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/chemical_reaction/corn_syrup
	name = "corn_syrup"
	id = "corn_syrup"
	result = "corn_syrup"
	required_reagents = list("corn_starch" = 1, "sacid" = 1)
	result_amount = 2
	required_temp = 374
	mix_message = "The mixture forms a viscous, clear fluid!"

datum/reagent/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "A sweet syrup derived from corn starch that has had its starches converted into maltose and other sugars."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/corn_syrup/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 1.2)
	..()
	return

/datum/chemical_reaction/vhfcs
	name = "vhfcs"
	id = "vhfcs"
	result = "vhfcs"
	required_reagents = list("corn_syrup" = 1)
	required_catalysts = list("enzyme" = 1)
	result_amount = 1
	mix_message = "The mixture emits a sickly-sweet smell."

datum/reagent/vhfcs
	name = "Very-high-fructose corn syrup"
	id = "vhfcs"
	description = "An incredibly sweet syrup, created from corn syrup treated with enzymes to convert its sugars into fructose."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/vhfcs/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 2.4)
	..()
	return

/datum/chemical_reaction/cola
	name = "cola"
	id = "cola"
	result = "cola"
	required_reagents = list("carbon" = 1, "oxygen" = 1, "water" = 1, "sugar" = 1)
	result_amount = 4
	mix_message = "The mixture begins to fizz."

/datum/reagent/honey
	name = "Honey"
	id = "honey"
	description = "A sweet substance produced by bees through partial digestion. Bee barf."
	reagent_state = LIQUID
	color = "#CFCF1F"

datum/reagent/honey/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 0.8)
	..()
	return
/*        //Commenting this out until smoke is rewritten, otherwise, this spam so much honeycomb it's not funny
datum/reagent/honey/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/honeycomb(T)
		return */

/datum/reagent/chocolate
	name = "Chocolate"
	id = "chocolate"
	description = "Chocolate is a delightful product derived from the seeds of the theobroma cacao tree."
	reagent_state = LIQUID
	color = "#2E2418"

datum/reagent/chocolate/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.add_reagent("sugar", 0.8)
	..()
	return

/datum/reagent/mugwort
	name = "Mugwort"
	id = "mugwort"
	description = "A rather bitter herb once thought to hold magical protective properties."
	reagent_state = LIQUID
	color = "#21170E"

datum/reagent/mugwort/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(istype(M, /mob/living/carbon/human) && M.mind)
		if(M.mind.special_role == "Wizard")
			M.adjustToxLoss(-1*REM)
			M.adjustOxyLoss(-1*REM)
			M.adjustBruteLoss(-1*REM)
			M.adjustFireLoss(-1*REM)
	..()
	return

/datum/reagent/porktonium
	name = "Porktonium"
	id = "porktonium"
	description = "A highly-radioactive pork byproduct first discovered in hotdogs."
	reagent_state = LIQUID
	color = "#AB5D5D"
	metabolization_rate = 0.2
	overdose_threshold = 125

datum/reagent/porktonium/overdose_process(var/mob/living/M as mob)
	if(volume > 125)
		if(prob(8))
			M.reagents.add_reagent("cyanide", 10)
			M.reagents.add_reagent("radium", 15)
	..()
	return

/datum/reagent/fungus
	name = "Space fungus"
	id = "fungus"
	description = "Scrapings of some unknown fungus found growing on the station walls."
	reagent_state = LIQUID
	color = "#C87D28"

datum/reagent/fungus/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		M << "<span class = 'danger'>Yuck!</span>"

/datum/reagent/chicken_soup
	name = "Chicken soup"
	id = "chicken_soup"
	description = "An old household remedy for mild illnesses."
	reagent_state = LIQUID
	color = "#B4B400"

/datum/reagent/chicken_soup/on_mob_life(var/mob/living/M as mob)
	M.nutrition += 2
	..()
	return

/datum/reagent/msg
	name = "Monosodium glutamate"
	id = "msg"
	description = "Monosodium Glutamate is a sodium salt known chiefly for its use as a controversial flavor enhancer."
	reagent_state = LIQUID
	color = "#F5F5F5"

datum/reagent/msg/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		M << "<span class = 'notice'>That tasted amazing!</span>"


/datum/reagent/msg/on_mob_life(var/mob/living/M as mob)
	if(prob(1))
		M.Stun(rand(4,10))
		M << "<span class='warning'>A horrible migraine overpowers you.</span>"
	..()
	return