/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "A gross and unidentifiable substance."
	reagent_state = LIQUID
	color = "#63DE63"
	metabolization_rate = 0.4

/datum/reagent/questionmark/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		M.Stun(2)
		M.Weaken(2)
		to_chat(M, "<span class='danger'>Ugh! Eating that was a terrible idea!</span>")
		M.ForceContractDisease(new /datum/disease/food_poisoning(0))

/datum/reagent/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	color = "#F0C814"

/datum/reagent/egg/on_mob_life(mob/living/M)
	if(prob(8))
		M.emote("fart")
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	..()

/datum/reagent/triple_citrus
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
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/triple_citrus/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		M.adjustToxLoss(-rand(1,2))

/datum/reagent/corn_starch
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
	min_temp = 374
	mix_message = "The mixture forms a viscous, clear fluid!"

/datum/reagent/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "A sweet syrup derived from corn starch that has had its starches converted into maltose and other sugars."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/corn_syrup/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 1.2)
	..()

/datum/chemical_reaction/vhfcs
	name = "vhfcs"
	id = "vhfcs"
	result = "vhfcs"
	required_reagents = list("corn_syrup" = 1)
	required_catalysts = list("enzyme" = 1)
	result_amount = 1
	mix_message = "The mixture emits a sickly-sweet smell."

/datum/reagent/vhfcs
	name = "Very-high-fructose corn syrup"
	id = "vhfcs"
	description = "An incredibly sweet syrup, created from corn syrup treated with enzymes to convert its sugars into fructose."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/vhfcs/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 2.4)
	..()

/datum/chemical_reaction/cola
	name = "cola"
	id = "cola"
	result = "cola"
	required_reagents = list("carbon" = 1, "oxygen" = 1, "water" = 1, "sugar" = 1)
	result_amount = 4
	mix_message = "The mixture begins to fizz."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/honey
	name = "Honey"
	id = "honey"
	description = "A sweet substance produced by bees through partial digestion. Bee barf."
	reagent_state = LIQUID
	color = "#d3a308"

/datum/reagent/honey/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 0.4)
	if(prob(20))
		M.heal_organ_damage(3,1)
	..()

/datum/reagent/chocolate
	name = "Chocolate"
	id = "chocolate"
	description = "Chocolate is a delightful product derived from the seeds of the theobroma cacao tree."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM		//same as pure cocoa powder, because it makes no sense that chocolate won't fill you up and make you fat
	color = "#2E2418"

/datum/reagent/chocolate/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	M.reagents.add_reagent("sugar", 0.8)
	..()

/datum/reagent/chocolate/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/choc_pile(T)

/datum/reagent/mugwort
	name = "Mugwort"
	id = "mugwort"
	description = "A rather bitter herb once thought to hold magical protective properties."
	reagent_state = LIQUID
	color = "#21170E"

/datum/reagent/mugwort/on_mob_life(mob/living/M)
	if(ishuman(M) && M.mind)
		if(M.mind.special_role == SPECIAL_ROLE_WIZARD)
			M.adjustToxLoss(-1*REM)
			M.adjustOxyLoss(-1*REM)
			M.adjustBruteLoss(-1*REM)
			M.adjustFireLoss(-1*REM)
	..()

/datum/reagent/porktonium
	name = "Porktonium"
	id = "porktonium"
	description = "A highly-radioactive pork byproduct first discovered in hotdogs."
	reagent_state = LIQUID
	color = "#AB5D5D"
	metabolization_rate = 0.2
	overdose_threshold = 133

/datum/reagent/porktonium/overdose_process(mob/living/M, severity)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("radium", 15)
		M.reagents.add_reagent("cyanide", 10)

/datum/reagent/fungus
	name = "Space fungus"
	id = "fungus"
	description = "Scrapings of some unknown fungus found growing on the station walls."
	reagent_state = LIQUID
	color = "#C87D28"

/datum/reagent/fungus/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		var/ranchance = rand(1,10)
		if(ranchance == 1)
			to_chat(M, "<span class='warning'>You feel very sick.</span>")
			M.reagents.add_reagent("toxin", rand(1,5))
		else if(ranchance <= 5)
			to_chat(M, "<span class='warning'>That tasted absolutely FOUL.</span>")
			M.ForceContractDisease(new /datum/disease/food_poisoning(0))
		else
			to_chat(M, "<span class='warning'>Yuck!</span>")

/datum/reagent/chicken_soup
	name = "Chicken soup"
	id = "chicken_soup"
	description = "An old household remedy for mild illnesses."
	reagent_state = LIQUID
	color = "#B4B400"
	metabolization_rate = 0.2

/datum/reagent/chicken_soup/on_mob_life(mob/living/M)
	M.nutrition += 2
	..()

/datum/reagent/msg
	name = "Monosodium glutamate"
	id = "msg"
	description = "Monosodium Glutamate is a sodium salt known chiefly for its use as a controversial flavor enhancer."
	reagent_state = LIQUID
	color = "#F5F5F5"
	metabolization_rate = 0.2

/datum/reagent/msg/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		to_chat(M, "<span class='notice'>That tasted amazing!</span>")


/datum/reagent/msg/on_mob_life(mob/living/M)
	if(prob(5))
		if(prob(10))
			M.adjustToxLoss(rand(2.4))
		if(prob(7))
			to_chat(M, "<span class='warning'>A horrible migraine overpowers you.</span>")
			M.Stun(rand(2,5))
	..()

/datum/reagent/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	color = "#FFFF00"
	metabolization_rate = 0 //heheheh


/datum/reagent/cheese/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	..()

/datum/reagent/cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge(T)

/datum/chemical_reaction/cheese
	name = "cheese"
	id = "cheese"
	result = "cheese"
	required_reagents = list("vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The mixture curdles up."

/datum/chemical_reaction/cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='notice'>A faint cheesy smell drifts through the air...</span>")

/datum/reagent/fake_cheese
	name = "Cheese substitute"
	id = "fake_cheese"
	description = "A cheese-like substance derived loosely from actual cheese."
	reagent_state = LIQUID
	color = "#B2B139"
	overdose_threshold = 50

/datum/reagent/fake_cheese/overdose_process(mob/living/M, severity)
	if(prob(8))
		to_chat(M, "<span class='warning'>You feel something squirming in your stomach. Your thoughts turn to cheese and you begin to sweat.</span>")
		M.adjustToxLoss(rand(1,2))

/datum/reagent/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	description = "Hell, I don't even know if this IS cheese. Whatever it is, it ain't normal. If you want to, pour it out to make it solid."
	reagent_state = SOLID
	color = "#50FF00"
	metabolization_rate = 0 //heheheh
	addiction_chance = 5

/datum/reagent/weird_cheese/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	..()

/datum/reagent/weird_cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/weirdcheesewedge(T)

/datum/chemical_reaction/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	result = "weird_cheese"
	required_reagents = list("green_vomit" = 1, "milk" = 1)
	result_amount = 1
	mix_message = "The disgusting mixture sloughs together horribly, emitting a foul stench."
	mix_sound = 'sound/goonstation/misc/gurggle.ogg'

/datum/chemical_reaction/weird_cheese/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>A horrible smell assaults your nose! What in space is it?</span>")

/datum/reagent/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	color = "#684435"

/datum/reagent/beans/on_mob_life(mob/living/M)
	if(prob(10))
		M.emote("fart")
	..()

/datum/reagent/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	color = "#9C5013"

/datum/reagent/bread/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/breadslice(T)

/datum/reagent/vomit
	name = "Vomit"
	id = "vomit"
	description = "Looks like someone lost their lunch. And then collected it. Yuck."
	reagent_state = LIQUID
	color = "#FFFF00"

/datum/reagent/vomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/vomit(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/greenvomit
	name = "Green vomit"
	id = "green_vomit"
	description = "Whoa, that can't be natural. That's horrible."
	reagent_state = LIQUID
	color = "#78FF74"

/datum/reagent/greenvomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/vomit/green(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)


/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = "ectoplasm"
	description = "A bizarre gelatinous substance supposedly derived from ghosts."
	reagent_state = LIQUID
	color = "#8EAE7B"
	process_flags = ORGANIC | SYNTHETIC		//Because apparently ghosts in the shell

/datum/reagent/ectoplasm/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		var/spooky_eat = pick("Ugh, why did you eat that? Your mouth feels haunted. Haunted with bad flavors.", "Ugh, why did you eat that? It has the texture of ham aspic.  From the 1950s.  Left out in the sun.", "Ugh, why did you eat that? It tastes like a ghost fart.", "Ugh, why did you eat that? It tastes like flavor died.")
		to_chat(M, "<span class='warning'>[spooky_eat]</span>")

/datum/reagent/ectoplasm/on_mob_life(mob/living/M)
	var/spooky_message = pick("You notice something moving out of the corner of your eye, but nothing is there...", "Your eyes twitch, you feel like something you can't see is here...", "You've got the heebie-jeebies.", "You feel uneasy.", "You shudder as if cold...", "You feel something gliding across your back...")
	if(prob(8))
		to_chat(M, "<span class='warning'>[spooky_message]</span>")
	..()

/datum/reagent/ectoplasm/reaction_turf(turf/T, volume)
	if(volume >= 10 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(T)

/datum/reagent/soybeanoil
	name = "Space-soybean oil"
	id = "soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans."
	reagent_state = LIQUID
	color = "#B1B0B0"

/datum/reagent/soybeanoil/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	..()

/datum/reagent/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans, with additional hydrogen atoms added to convert it into a saturated form."
	reagent_state = LIQUID
	color = "#B1B0B0"
	metabolization_rate = 0.2
	overdose_threshold = 75

/datum/reagent/hydrogenated_soybeanoil/on_mob_life(mob/living/M)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	if(volume >= 75)
		metabolization_rate = 0.4
	else
		metabolization_rate = 0.2
	..()

/datum/reagent/hydrogenated_soybeanoil/overdose_process(mob/living/M, severity)
	if(prob(33))
		to_chat(M, "<span class='warning'>You feel horribly weak.</span>")
	if(prob(10))
		to_chat(M, "<span class='warning'>You cannot breathe!</span>")
		M.adjustOxyLoss(5)
	if(prob(5))
		to_chat(M, "<span class='warning'>You feel a sharp pain in your chest!</span>")
		M.adjustOxyLoss(25)
		M.Stun(5)
		M.Paralyse(10)

/datum/chemical_reaction/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	result = "hydrogenated_soybeanoil"
	required_reagents = list("soybeanoil" = 1, "hydrogen" = 1)
	result_amount = 2
	min_temp = 520
	mix_message = "The mixture emits a burnt, oily smell."

/datum/reagent/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	description = "A paste comprised of highly-processed organic material. Uncomfortably similar to deviled ham spread."
	reagent_state = LIQUID
	color = "#EBD7D7"

/datum/reagent/meatslurry/on_mob_life(mob/living/M)
	if(prob(4))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	..()

/datum/reagent/meatslurry/reaction_turf(turf/T, volume)
	if(volume >= 5 && prob(10) && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

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
	min_temp = 374
	mix_message = "The substance thickens and takes on a meaty odor."

/datum/reagent/beff
	name = "Beff"
	id = "beff"
	description = "An advanced blend of mechanically-recovered meat and textured synthesized protein product notable for its unusual crystalline grain when sliced."
	reagent_state = SOLID
	color = "#AC7E67"

/datum/reagent/beff/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent(pick("blood", "corn_syrup", "synthflesh", "hydrogenated_soybeanoil", "porktonium", "toxic_slurry"), 0.8)
	else if(prob(6))
		to_chat(M, "<span class='warning'>[pick("You feel ill.","Your stomach churns.","You feel queasy.","You feel sick.")]</span>")
		M.emote(pick("groan","moan"))
	..()

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

/datum/reagent/pepperoni/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				to_chat(H, "<span class='warning'>The pepperoni bounces off your mask!</span>")
				return

			if(H.head)
				to_chat(H, "<span class='warning'>Your mask protects you from the errant pepperoni!</span>")
				return

			if(prob(50))
				M.adjustBruteLoss(1)
				playsound(M, 'sound/effects/woodhit.ogg', 50, 1)
				to_chat(M, "<span class='warning'>A slice of pepperoni slaps you!</span>")
			else
				M.emote("burp")
				to_chat(M, "<span class='warning'>My goodness, that was tasty!</span>")


/datum/chemical_reaction/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	result = "pepperoni"
	required_reagents = list("beff" = 1, "saltpetre" = 1, "synthflesh" = 1)
	result_amount = 2
	mix_message = "The beff and the synthflesh combine to form a smoky red log."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/reagent/cholesterol
	name = "cholesterol"
	id = "cholesterol"
	description = "Pure cholesterol. Probably not very good for you."
	reagent_state = LIQUID
	color = "#FFFAC8"

/datum/reagent/cholesterol/on_mob_life(mob/living/M)
	if(volume >= 25 && prob(volume*0.15))
		to_chat(M, "<span class='warning'>Your chest feels [pick("weird","uncomfortable","nasty","gross","odd","unusual","warm")]!</span>")
		M.adjustToxLoss(rand(1,2))
	else if(volume >= 45 && prob(volume*0.08))
		to_chat(M, "<span class='warning'>Your chest [pick("hurts","stings","aches","burns")]!</span>")
		M.adjustToxLoss(rand(2,4))
		M.Stun(1)
	else if(volume >= 150 && prob(volume*0.01))
		to_chat(M, "<span class='warning'>Your chest is burning with pain!</span>")
		M.Stun(1)
		M.Weaken(1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.heart_attack)
				H.heart_attack = 1
	..()