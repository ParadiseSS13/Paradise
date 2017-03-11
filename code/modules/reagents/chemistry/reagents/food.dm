/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/consumable
	name = "Consumable"
	id = "consumable"
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/diet_flags = DIET_OMNI | DIET_HERB | DIET_CARN

/datum/reagent/consumable/on_mob_life(mob/living/M)
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				H.nutrition += nutriment_factor	// For hunger and fatness
	..()

/datum/reagent/consumable/nutriment		// Pure nutriment, universally digestable and thus slightly less effective
	name = "Nutriment"
	id = "nutriment"
	description = "A questionable mixture of various pure nutrients commonly found in processed foods."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/M)
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				if(prob(50))
					M.adjustBruteLoss(-1)
				if(H.species.exotic_blood)
					H.vessel.add_reagent(H.species.exotic_blood, 0.4)
				else
					if(!(H.species.flags & NO_BLOOD))
						H.vessel.add_reagent("blood", 0.4)
	..()

/datum/reagent/consumable/nutriment/protein			// Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Protein"
	id = "protein"
	description = "Various essential proteins and fats commonly found in animal flesh and blood."
	diet_flags = DIET_CARN | DIET_OMNI

/datum/reagent/consumable/nutriment/plantmatter		// Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Plant-matter"
	id = "plantmatter"
	description = "Vitamin-rich fibers and natural sugars commonly found in fresh produce."
	diet_flags = DIET_HERB | DIET_OMNI

/datum/reagent/consumable/vitamin
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/consumable/vitamin/on_mob_life(mob/living/M)
	if(prob(50))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	if(M.satiety < 600)
		M.satiety += 30
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.exotic_blood)
			H.vessel.add_reagent(H.species.exotic_blood, 0.5)
		else
			if(!(H.species.flags & NO_BLOOD))
				H.vessel.add_reagent("blood", 0.5)
	..()

/datum/reagent/consumable/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	nutriment_factor = 5 * REAGENTS_METABOLISM
	overdose_threshold = 200 // Hyperglycaemic shock

/datum/reagent/consumable/sugar/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-5)
	if(current_cycle >= 90)
		M.AdjustJitter(2)
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	if(prob(4))
		M.reagents.add_reagent("epinephrine", 1.2)
	..()

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='danger'>You pass out from hyperglycemic shock!</span>")
	M.emote("collapse")
	..()

/datum/reagent/consumable/sugar/overdose_process(mob/living/M, severity)
	M.Paralyse(3 * severity)
	M.Weaken(4 * severity)
	if(prob(8))
		M.adjustToxLoss(severity)

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
		if(25 to 35)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature += 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(20,25)
	..()

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "This shit goes in pepperspray."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if(victim.wear_mask.flags_cover & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if(victim.wear_mask.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if(victim.head.flags_cover & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.head
				if(victim.head.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if( !safe_thing )
					safe_thing = victim.glasses
			if( eyes_covered && mouth_covered )
				to_chat(victim, "<span class='danger'>Your [safe_thing] protects you from the pepperspray!</span>")
				return
			else if( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, "<span class='danger'>Your [safe_thing] protect you from most of the pepperspray!</span>")
				if(prob(5))
					victim.emote("scream")
				victim.EyeBlurry(3)
				victim.EyeBlind(1)
				victim.Confused(3)
				victim.damageoverlaytemp = 60
				victim.Weaken(3)
				victim.drop_item()
				return
			else if( eyes_covered ) // Eye cover is better than mouth cover
				to_chat(victim, "<span class='danger'>Your [safe_thing] protects your eyes from the pepperspray!</span>")
				victim.EyeBlurry(3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				to_chat(victim, "<span class='danger'>You're sprayed directly in the eyes with pepperspray!</span>")
				victim.EyeBlurry(5)
				victim.EyeBlind(2)
				victim.Confused(6)
				victim.damageoverlaytemp = 75
				victim.Weaken(5)
				victim.drop_item()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = LIQUID
	color = "#8BA6E9" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
		if(25 to 35)
			M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(20,25)
	..()

/datum/reagent/consumable/frostoil/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))

/datum/reagent/consumable/sodiumchloride
	name = "Salt"
	id = "sodiumchloride"
	description = "Sodium chloride, common table salt."
	reagent_state = SOLID
	color = "#B1B0B0"
	overdose_threshold = 100

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/M, severity)
	if(prob(70))
		M.adjustBrainLoss(1)
	..()

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID

/datum/reagent/consumable/cocoa
	name = "Cocoa Powder"
	id = "cocoa"
	description = "A fatty, bitter paste made from cocoa beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	id = "vanilla"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"

/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#FF00FF" // rgb: 255, 0, 255

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Security Officer", "Security Pod Pilot", "Detective", "Warden", "Head of Security", "Brig Physician", "Internal Affairs Agent", "Magistrate"))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/consumable/cornoil/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume >= 3)
		T.MakeSlippery()
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/enzyme
	name = "Denatured Enzyme"
	id = "enzyme"
	description = "Heated beyond usefulness, this enzyme is now worthless."
	reagent_state = LIQUID
	color = "#282314" // rgb: 54, 94, 48

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/M)
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()

/datum/reagent/consumable/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/consumable/flour/reaction_turf(turf/T, volume)
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/consumable/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	id = "bluecherryjelly"
	description = "Blue and tastier kind of cherry jelly."
	reagent_state = LIQUID
	color = "#00F0FF"

/datum/reagent/consumable/egg
	name = "Egg"
	id = "egg"
	description = "A runny and viscous mixture of clear and yellow fluids."
	reagent_state = LIQUID
	color = "#F0C814"

/datum/reagent/consumable/egg/on_mob_life(mob/living/M)
	if(prob(8))
		M.emote("fart")
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	..()

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	id = "corn_starch"
	description = "The powdered starch of maize, derived from the kernel's endosperm. Used as a thickener for gravies and puddings."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	id = "corn_syrup"
	description = "A sweet syrup derived from corn starch that has had its starches converted into maltose and other sugars."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 1.2)
	..()

/datum/reagent/consumable/vhfcs
	name = "Very-high-fructose corn syrup"
	id = "vhfcs"
	description = "An incredibly sweet syrup, created from corn syrup treated with enzymes to convert its sugars into fructose."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/consumable/vhfcs/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 2.4)
	..()

/datum/reagent/consumable/honey
	name = "Honey"
	id = "honey"
	description = "A sweet substance produced by bees through partial digestion. Bee barf."
	reagent_state = LIQUID
	color = "#d3a308"
	nutriment_factor = 15 * REAGENTS_METABOLISM

/datum/reagent/consumable/honey/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 3)
	if(prob(20))
		M.adjustBruteLoss(-3)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/consumable/chocolate
	name = "Chocolate"
	id = "chocolate"
	description = "Chocolate is a delightful product derived from the seeds of the theobroma cacao tree."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM		//same as pure cocoa powder, because it makes no sense that chocolate won't fill you up and make you fat
	color = "#2E2418"
	drink_icon = "chocolateglass"
	drink_name = "Glass of chocolate"
	drink_desc = "Tasty"

/datum/reagent/consumable/chocolate/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 0.8)
	..()

/datum/reagent/consumable/chocolate/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/choc_pile(T)

/datum/reagent/consumable/mugwort
	name = "Mugwort"
	id = "mugwort"
	description = "A rather bitter herb once thought to hold magical protective properties."
	reagent_state = LIQUID
	color = "#21170E"

/datum/reagent/consumable/mugwort/on_mob_life(mob/living/M)
	if(ishuman(M) && M.mind)
		if(M.mind.special_role == SPECIAL_ROLE_WIZARD)
			M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
			M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
			M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
			M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/consumable/porktonium
	name = "Porktonium"
	id = "porktonium"
	description = "A highly-radioactive pork byproduct first discovered in hotdogs."
	reagent_state = LIQUID
	color = "#AB5D5D"
	metabolization_rate = 0.2
	overdose_threshold = 133

/datum/reagent/consumable/porktonium/overdose_process(mob/living/M, severity)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("radium", 15)
		M.reagents.add_reagent("cyanide", 10)

/datum/reagent/consumable/chicken_soup
	name = "Chicken soup"
	id = "chicken_soup"
	description = "An old household remedy for mild illnesses."
	reagent_state = LIQUID
	color = "#B4B400"
	metabolization_rate = 0.2
	nutriment_factor = 2

/datum/reagent/consumable/cheese
	name = "Cheese"
	id = "cheese"
	description = "Some cheese. Pour it out to make it solid."
	reagent_state = SOLID
	color = "#FFFF00"

/datum/reagent/consumable/cheese/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	..()

/datum/reagent/consumable/cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/cheesewedge(T)

/datum/reagent/consumable/fake_cheese
	name = "Cheese substitute"
	id = "fake_cheese"
	description = "A cheese-like substance derived loosely from actual cheese."
	reagent_state = LIQUID
	color = "#B2B139"
	overdose_threshold = 50

/datum/reagent/consumable/fake_cheese/overdose_process(mob/living/M, severity)
	if(prob(8))
		to_chat(M, "<span class='warning'>You feel something squirming in your stomach. Your thoughts turn to cheese and you begin to sweat.</span>")
		M.adjustToxLoss(rand(1,2))

/datum/reagent/consumable/weird_cheese
	name = "Weird cheese"
	id = "weird_cheese"
	description = "Hell, I don't even know if this IS cheese. Whatever it is, it ain't normal. If you want to, pour it out to make it solid."
	reagent_state = SOLID
	color = "#50FF00"
	addiction_chance = 5

/datum/reagent/consumable/weird_cheese/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	..()

/datum/reagent/consumable/weird_cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/weirdcheesewedge(T)

/datum/reagent/consumable/beans
	name = "Refried beans"
	id = "beans"
	description = "A dish made of mashed beans cooked with lard."
	reagent_state = LIQUID
	color = "#684435"

/datum/reagent/consumable/beans/on_mob_life(mob/living/M)
	if(prob(10))
		M.emote("fart")
	..()

/datum/reagent/consumable/bread
	name = "Bread"
	id = "bread"
	description = "Bread! Yep, bread."
	reagent_state = SOLID
	color = "#9C5013"

/datum/reagent/consumable/soybeanoil
	name = "Space-soybean oil"
	id = "soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans."
	reagent_state = LIQUID
	color = "#B1B0B0"

/datum/reagent/consumable/soybeanoil/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	..()

/datum/reagent/consumable/hydrogenated_soybeanoil
	name = "Partially hydrogenated space-soybean oil"
	id = "hydrogenated_soybeanoil"
	description = "An oil derived from extra-terrestrial soybeans, with additional hydrogen atoms added to convert it into a saturated form."
	reagent_state = LIQUID
	color = "#B1B0B0"
	metabolization_rate = 0.2
	overdose_threshold = 75

/datum/reagent/consumable/hydrogenated_soybeanoil/on_mob_life(mob/living/M)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	if(volume >= 75)
		metabolization_rate = 0.4
	else
		metabolization_rate = 0.2
	..()

/datum/reagent/consumable/hydrogenated_soybeanoil/overdose_process(mob/living/M, severity)
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

/datum/reagent/consumable/meatslurry
	name = "Meat Slurry"
	id = "meatslurry"
	description = "A paste comprised of highly-processed organic material. Uncomfortably similar to deviled ham spread."
	reagent_state = LIQUID
	color = "#EBD7D7"

/datum/reagent/consumable/meatslurry/on_mob_life(mob/living/M)
	if(prob(4))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	..()

/datum/reagent/consumable/meatslurry/reaction_turf(turf/T, volume)
	if(volume >= 5 && prob(10) && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/consumable/mashedpotatoes
	name = "Mashed potatoes"
	id = "mashedpotatoes"
	description = "A starchy food paste made from boiled potatoes."
	reagent_state = SOLID
	color = "#D6D9C1"

/datum/reagent/consumable/gravy
	name = "Gravy"
	id = "gravy"
	description = "A savory sauce made from a simple meat-dripping roux and milk."
	reagent_state = LIQUID
	color = "#B4641B"

/datum/reagent/consumable/beff
	name = "Beff"
	id = "beff"
	description = "An advanced blend of mechanically-recovered meat and textured synthesized protein product notable for its unusual crystalline grain when sliced."
	reagent_state = SOLID
	color = "#AC7E67"

/datum/reagent/consumable/beff/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent(pick("blood", "corn_syrup", "synthflesh", "hydrogenated_soybeanoil", "porktonium", "toxic_slurry"), 0.8)
	else if(prob(6))
		to_chat(M, "<span class='warning'>[pick("You feel ill.","Your stomach churns.","You feel queasy.","You feel sick.")]</span>")
		M.emote(pick("groan","moan"))
	..()

/datum/reagent/consumable/pepperoni
	name = "Pepperoni"
	id = "pepperoni"
	description = "An Italian-American variety of salami usually made from beef and pork"
	reagent_state = SOLID
	color = "#AC7E67"

/datum/reagent/consumable/pepperoni/reaction_mob(mob/living/M, method=TOUCH, volume)
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


///Food Related, but non-nutritious

/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "A gross and unidentifiable substance."
	reagent_state = LIQUID
	color = "#63DE63"

/datum/reagent/questionmark/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		M.Stun(2)
		M.Weaken(2)
		to_chat(M, "<span class='danger'>Ugh! Eating that was a terrible idea!</span>")
		M.ForceContractDisease(new /datum/disease/food_poisoning(0))

/datum/reagent/msg
	name = "Monosodium glutamate"
	id = "msg"
	description = "Monosodium Glutamate is a sodium salt known chiefly for its use as a controversial flavor enhancer."
	reagent_state = LIQUID
	color = "#F5F5F5"
	metabolization_rate = 0.2

/datum/reagent/msg/on_mob_life(mob/living/M)
	if(prob(5))
		if(prob(10))
			M.adjustToxLoss(rand(2.4))
		if(prob(7))
			to_chat(M, "<span class='warning'>A horrible migraine overpowers you.</span>")
			M.Stun(rand(2,5))
	..()

/datum/reagent/msg/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		to_chat(M, "<span class='notice'>That tasted amazing!</span>")

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

/datum/reagent/ectoplasm
	name = "Ectoplasm"
	id = "ectoplasm"
	description = "A bizarre gelatinous substance supposedly derived from ghosts."
	reagent_state = LIQUID
	color = "#8EAE7B"
	process_flags = ORGANIC | SYNTHETIC		//Because apparently ghosts in the shell

/datum/reagent/ectoplasm/on_mob_life(mob/living/M)
	var/spooky_message = pick("You notice something moving out of the corner of your eye, but nothing is there...", "Your eyes twitch, you feel like something you can't see is here...", "You've got the heebie-jeebies.", "You feel uneasy.", "You shudder as if cold...", "You feel something gliding across your back...")
	if(prob(8))
		to_chat(M, "<span class='warning'>[spooky_message]</span>")
	..()

/datum/reagent/ectoplasm/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		var/spooky_eat = pick("Ugh, why did you eat that? Your mouth feels haunted. Haunted with bad flavors.", "Ugh, why did you eat that? It has the texture of ham aspic.  From the 1950s.  Left out in the sun.", "Ugh, why did you eat that? It tastes like a ghost fart.", "Ugh, why did you eat that? It tastes like flavor died.")
		to_chat(M, "<span class='warning'>[spooky_eat]</span>")

/datum/reagent/ectoplasm/reaction_turf(turf/T, volume)
	if(volume >= 10 && !istype(T, /turf/space))
		new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(T)

///Vomit///

/datum/reagent/consumable/bread/reaction_turf(turf/T, volume)
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
		
////Lavaland Flora Reagents////

/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	id = "entpoly"
	description = "An ichor, derived from a certain mushroom, makes for a bad time."
	color = "#1d043d"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/M)
	if(current_cycle >= 10)
		M.Paralyse(2)
	if(prob(20))
		M.LoseBreath(4)
		M.adjustBrainLoss(2 * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustStaminaLoss(10 * REAGENTS_EFFECT_MULTIPLIER)
		M.EyeBlurry(5)
	..()

/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	id = "tinlux"
	description = "A stimulating ichor which causes luminescent fungi to grow on the skin. "
	color = "#b5a213"
	var/light_activated = 0

/datum/reagent/consumable/tinlux/on_mob_life(mob/living/M)
	if(!light_activated)
		M.set_light(2)
		light_activated = 1
	..()	

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/M)
	M.set_light(0)

/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	id = "vitfro"
	description = "A bubbly paste that heals wounds of the skin."
	color = "#d3a308"
	nutriment_factor = 3 * REAGENTS_METABOLISM

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/M)
	if(prob(80))
		M.adjustBruteLoss(-1 * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-1 * REAGENTS_EFFECT_MULTIPLIER)
	..()