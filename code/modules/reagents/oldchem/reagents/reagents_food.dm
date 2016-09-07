/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
/datum/reagent/nutriment		// Pure nutriment, universally digestable and thus slightly less effective
	name = "Nutriment"
	id = "nutriment"
	description = "A questionable mixture of various pure nutrients commonly found in processed foods."
	reagent_state = SOLID
	nutriment_factor = 12 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	var/diet_flags = DIET_OMNI | DIET_HERB | DIET_CARN

/datum/reagent/nutriment/on_mob_life(mob/living/M)
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				H.nutrition += nutriment_factor	// For hunger and fatness
				if(prob(50))
					M.adjustBruteLoss(-1)
				if(H.species.exotic_blood)
					H.vessel.add_reagent(H.species.exotic_blood, 0.4)
				else
					if(!(H.species.flags & NO_BLOOD))
						H.vessel.add_reagent("blood", 0.4)
	..()

/datum/reagent/nutriment/protein			// Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Protein"
	id = "protein"
	description = "Various essential proteins and fats commonly found in animal flesh and blood."
	nutriment_factor = 15 * REAGENTS_METABOLISM
	diet_flags = DIET_CARN | DIET_OMNI

/datum/reagent/nutriment/plantmatter		// Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Plant-matter"
	id = "plantmatter"
	description = "Vitamin-rich fibers and natural sugars commonly found in fresh produce."
	nutriment_factor = 15 * REAGENTS_METABOLISM
	diet_flags = DIET_HERB | DIET_OMNI


/datum/reagent/vitamin
	name = "Vitamin"
	id = "vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/vitamin/on_mob_life(mob/living/M) //everyone needs vitamins, so this works on everyone, regardless of diet or if they're a vampire.
	M.nutrition += nutriment_factor
	if(prob(50))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.exotic_blood)
			H.vessel.add_reagent(H.species.exotic_blood, 0.5)
		else
			if(!(H.species.flags & NO_BLOOD))
				H.vessel.add_reagent("blood", 0.5)
	..()

/datum/reagent/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0

/datum/reagent/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8


/datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/capsaicin/on_mob_life(mob/living/M)
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

/datum/reagent/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = LIQUID
	color = "#8BA6E9" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/frostoil/on_mob_life(mob/living/M)
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

/datum/reagent/frostoil/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))


/datum/reagent/sodiumchloride
	name = "Salt"
	id = "sodiumchloride"
	description = "Sodium chloride, common table salt."
	reagent_state = SOLID
	color = "#B1B0B0"
	overdose_threshold = 100

/datum/reagent/sodiumchloride/overdose_process(mob/living/M, severity)
	if(prob(70))
		M.adjustBrainLoss(1)
	..()

/datum/reagent/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID

/datum/reagent/cocoa
	name = "Cocoa Powder"
	id = "cocoa"
	description = "A fatty, bitter paste made from cocoa beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/cocoa/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()

/datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And cocoa beans."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16

/datum/reagent/hot_coco/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += nutriment_factor
	..()

/datum/reagent/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FF00FF" // rgb: 255, 0, 255

/datum/reagent/sprinkles/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if(ishuman(M) && M.job in list("Security Officer", "Security Pod Pilot", "Detective", "Warden", "Head of Security", "Brig Physician", "Internal Affairs Agent", "Magistrate"))
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()


/datum/reagent/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/cornoil/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()

/datum/reagent/cornoil/reaction_turf(turf/simulated/T, volume)
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


/datum/reagent/enzyme
	name = "Denatured Enzyme"
	id = "enzyme"
	description = "Heated beyond usefulness, this enzyme is now worthless."
	reagent_state = LIQUID
	color = "#282314" // rgb: 54, 94, 48


/datum/reagent/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/dry_ramen/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()


/datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/hot_ramen/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()


/datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/hell_ramen/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()


/datum/reagent/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()

/datum/reagent/flour/reaction_turf(turf/T, volume)
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)


/datum/reagent/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/rice/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()


/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(mob/living/M)
	M.nutrition += nutriment_factor
	..()

/datum/reagent/toxin/coffeepowder
	name = "Coffee Grounds"
	id = "coffeepowder"
	description = "Finely ground Coffee beans, used to make coffee."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13

/datum/reagent/toxin/teapowder
	name = "Ground Tea Leaves"
	id = "teapowder"
	description = "Finely shredded Tea leaves, used for making tea."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0

//Reagents used for plant fertilizers.
/datum/reagent/toxin/fertilizer
	name = "fertilizer"
	id = "fertilizer"
	description = "A chemical mix good for growing plants with."
	reagent_state = LIQUID
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/toxin/fertilizer/eznutrient
	name = "EZ Nutrient"
	id = "eznutrient"

/datum/reagent/toxin/fertilizer/left4zed
	name = "Left-4-Zed"
	id = "left4zed"

/datum/reagent/toxin/fertilizer/robustharvest
	name = "Robust Harvest"
	id = "robustharvest"


/datum/reagent/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	overdose_threshold = 200 // Hyperglycaemic shock

/datum/reagent/sugar/on_mob_life(mob/living/M)
	M.drowsyness = max(0, M.drowsyness-5)
	if(current_cycle >= 90)
		M.jitteriness += 2
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	if(prob(4))
		M.reagents.add_reagent("epinephrine", 1.2)
	..()

/datum/reagent/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='danger'>You pass out from hyperglycemic shock!</span>")
	M.emote("collapse")
	..()

/datum/reagent/sugar/overdose_process(mob/living/M, severity)
	M.Paralyse(3 * severity)
	M.Weaken(4 * severity)
	if(prob(8))
		M.adjustToxLoss(severity)

