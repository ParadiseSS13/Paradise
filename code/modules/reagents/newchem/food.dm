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

datum/reagent/honey/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/honeycomb(T)
		return

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

datum/reagent/chocolate/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/reagentchocolatebar(T)
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

/datum/reagent/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	color = "#FFFF00"

datum/reagent/cheese/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge(T)
		return

/datum/chemical_reaction/cheese
	name = "cheese"
	id = "cheese"
	result = "cheese"
	required_reagents = list("vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The mixture curdles up."

/datum/reagent/fake_cheese
	name = "Cheese substitute"
	id = "fake_cheese"
	description = "A cheese-like substance derived loosely from actual cheese."
	reagent_state = LIQUID
	color = "#B2B139"

/datum/reagent/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	description = "Hell, I don't even know if this IS cheese. Whatever it is, it ain't normal. If you want to, pour it out to make it solid."
	reagent_state = SOLID
	color = "#50FF00"

datum/reagent/weird_cheese/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/weirdcheesewedge(T)
		return

/datum/chemical_reaction/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	result = "weird_cheese"
	required_reagents = list("green_vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The disgusting mixture sloughs together horribly, emitting a foul stench."

datum/reagent/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	color = "#684435"

datum/reagent/beans/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(8))
		M.emote("fart")
	..()
	return

/datum/reagent/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	color = "#9C5013"

datum/reagent/bread/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/item/weapon/reagent_containers/food/snacks/breadslice(T)
		return

/datum/reagent/vomit
	name = "Vomit"
	id = "vomit"
	description = "Looks like someone lost their lunch. And then collected it. Yuck."
	reagent_state = LIQUID
	color = "#FFFF00"

datum/reagent/vomit/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/effect/decal/cleanable/vomit(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)
		return

/datum/reagent/greenvomit
	name = "Green vomit"
	id = "green_vomit"
	description = "Whoa, that can't be natural. That's horrible."
	reagent_state = LIQUID
	color = "#78FF74"

datum/reagent/greenvomit/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 5)
		new /obj/effect/decal/cleanable/vomit/green(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)
		return


/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = "ectoplasm"
	description = "A bizarre gelatinous substance supposedly derived from ghosts."
	reagent_state = LIQUID
	color = "#8EAE7B"

datum/reagent/ectoplasm/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		var/spooky_eat = pick("Ugh, why did you eat that? Your mouth feels haunted. Haunted with bad flavors.", "Ugh, why did you eat that? It has the texture of ham aspic.  From the 1950s.  Left out in the sun.", "Ugh, why did you eat that? It tastes like a ghost fart.", "Ugh, why did you eat that? It tastes like flavor died.")
		M << "<span class = 'warning'>[spooky_eat]</span>"

/datum/reagent/ectoplasm/on_mob_life(var/mob/living/M as mob)
	var/spooky_message = pick("You notice something moving out of the corner of your eye, but nothing is there...", "Your eyes twitch, you feel like something you can't see is here...", "You've got the heebie-jeebies.", "You feel uneasy.", "You shudder as if cold...", "You feel something gliding across your back...")
	if(prob(5))
		M << "<span class='warning'>[spooky_message]</span>"
	..()
	return

datum/reagent/ectoplasm/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 10)
		new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(T)
		return

/datum/reagent/soybeanoil
	name = "Space-soybean oil "
	id = "soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans."
	reagent_state = LIQUID
	color = "#B1B0B0"

/datum/reagent/soybeanoil/on_mob_life(var/mob/living/M as mob)
	if(prob(5))
		M.reagents.add_reagent("porktonium",5)
	..()
	return

/datum/reagent/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans, with additional hydrogen atoms added to convert it into a saturated form."
	reagent_state = LIQUID
	color = "#B1B0B0"

/datum/reagent/hydrogenated_soybeanoil/on_mob_life(var/mob/living/M as mob)
	if(prob(8))
		M.reagents.add_reagent("porktonium",5)
	..()
	return

/datum/chemical_reaction/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	result = "hydrogenated_soybeanoil"
	required_reagents = list("soybeanoil" = 1, "hydrogen" = 1)
	result_amount = 2
	required_temp = 520
	mix_message = "The mixture emits a burnt, oily smell."

/datum/reagent/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	description = "A paste comprised of highly-processed organic material. Uncomfortably similar to deviled ham spread."
	reagent_state = LIQUID
	color = "#EBD7D7"

/datum/chemical_reaction/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	result = "meatslurry"
	required_reagents = list("corn_starch" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The mixture congeals into a bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/reagent/mashedpotatoes
	name = "Mashed potatoes"
	id = "mashedpotatoes"
	description = "A starchy food paste made from boiled potatoes."
	reagent_state = SOLID
	color = "#D6D9C1"

/datum/reagent/gravy
	name = "Gravy"
	id = "gravy"
	description = "A savory sauce made from a simple meat-dripping roux and milk."
	reagent_state = LIQUID
	color = "#B4641B"

/datum/chemical_reaction/gravy
	name = "Gravy"
	id = "gravy"
	result = "gravy"
	required_reagents = list("porktonium" = 1, "corn_starch" = 1, "milk" = 1)
	result_amount = 3
	required_temp = 374
	mix_message = "The substance thickens and takes on a meaty odor."

/datum/reagent/beff
	name = "Beff"
	id = "beff"
	description = "An advanced blend of mechanically-recovered meat and textured synthesized protein product notable for its unusual crystalline grain when sliced."
	reagent_state = SOLID
	color = "#AC7E67"

/datum/reagent/beff/on_mob_life(var/mob/living/M as mob)
	if(prob(5))
		M.reagents.add_reagent("porktonium",5)
	if(prob(5))
		M.reagents.add_reagent(pick("blood", "corn_syrup", "synthflesh", "hydrogenated_soybeanoil"), 0.8)
	if(prob(5))
		M.emote("groan")
	if(prob(2))
		M << "<span class='warning'>You feel sick.</span>"
	..()
	return

/datum/chemical_reaction/beff
	name = "Beff"
	id = "beff"
	result = "beff"
	required_reagents = list("hydrogenated_soybeanoil" = 2, "meatslurry" = 1, "plasma" = 1)
	result_amount = 4
	mix_message = "The mixture solidifies, taking a crystalline appearance."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/reagent/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	description = "An Italian-American variety of salami usually made from beef and pork"
	reagent_state = SOLID
	color = "#AC7E67"

datum/reagent/pepperoni/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				H << "<span class='warning'>The pepperoni bounces off your mask!</span>"
				return

			if(H.head)
				H << "<span class='warning'>Your mask protects you from the errant pepperoni!</span>"
				return

			if(prob(50))
				M.adjustBruteLoss(1)
				playsound(M, 'sound/effects/woodhit.ogg', 50, 1, -1)
				M << "<span class='warning'>A slice of pepperoni slaps you!</span>"
			else
				M.emote("burp")
				M << "<span class='warning'>My goodness, that was tasty!</span>"


/datum/chemical_reaction/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	result = "pepperoni"
	required_reagents = list("beff" = 1, "saltpetre" = 1, "synthflesh" = 1)
	result_amount = 2
	mix_message = "The beff and the synthflesh combine to form a smoky red log."
	mix_sound = 'sound/effects/blobattack.ogg'