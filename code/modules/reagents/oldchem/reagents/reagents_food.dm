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

/datum/reagent/nutriment/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.dietflags)	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				H.nutrition += nutriment_factor	// For hunger and fatness
				if(prob(50)) M.heal_organ_damage(1,0)
		if(istype(M,/mob/living/simple_animal))		//Any nutrients can heal simple animals
			if(prob(50)) M.heal_organ_damage(1,0)
	..()
	return


/datum/reagent/protein			// Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Protein"
	id = "protein"
	description = "Various essential proteins and fats commonly found in animal flesh and blood."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/protein/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.dietflags && !(H.species.dietflags & DIET_HERB))	//Make sure the species has it's dietflag set, and that it is not a herbivore
				H.nutrition += nutriment_factor	// For hunger and fatness
				if(prob(50)) M.heal_organ_damage(1,0)
		if(istype(M,/mob/living/simple_animal))		//Any nutrients can heal simple animals
			if(prob(50)) M.heal_organ_damage(1,0)
	..()
	return


/datum/reagent/plantmatter		// Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Plant-matter"
	id = "plantmatter"
	description = "Vitamin-rich fibers and natural sugars commonly found in fresh produce."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/plantmatter/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!(M.mind in ticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species && H.species.dietflags && !(H.species.dietflags & DIET_CARN))	//Make sure the species has it's dietflag set, and that it is not a carnivore
				H.nutrition += nutriment_factor	// For hunger and fatness
				if(prob(50)) M.heal_organ_damage(1,0)
		if(istype(M,/mob/living/simple_animal))		//Any nutrients can heal simple animals
			if(prob(50)) M.heal_organ_damage(1,0)
	..()
	return


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

/datum/reagent/capsaicin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(15,20)
	holder.remove_reagent(src.id, FOOD_METABOLISM)
	data++
	..()
	return


/datum/reagent/sodiumchloride
	name = "Salt"
	id = "sodiumchloride"
	description = "Sodium chloride, common table salt."
	reagent_state = SOLID
	color = "#B1B0B0"

/datum/reagent/sodiumchloride/overdose_process(var/mob/living/M as mob)
	if(volume > 100)
		if(prob(70))
			M.adjustBrainLoss(1)
		if(prob(8))
			M.adjustToxLoss(rand(1,2))
	..()
	return


/datum/reagent/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)

/datum/reagent/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/coco/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16

/datum/reagent/hot_coco/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += nutriment_factor
	..()
	return


/datum/reagent/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231

/datum/reagent/psilocybin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 30)
	if(!data) data = 1
	switch(data)
		if(1 to 5)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(5)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(10)
			M.Dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	data++
	..()
	return


/datum/reagent/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FF00FF" // rgb: 255, 0, 255

/datum/reagent/sprinkles/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		M.nutrition += nutriment_factor
		..()
		return
	..()


/datum/reagent/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/cornoil/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 3)
		if(T.wet >= 1) return
		T.wet = 1
		if(T.wet_overlay)
			T.overlays -= T.wet_overlay
			T.wet_overlay = null
		T.wet_overlay = image('icons/effects/water.dmi',T,"wet_floor")
		T.overlays += T.wet_overlay

		spawn(800)
			if (!istype(T)) return
			if(T.wet >= 2) return
			T.wet = 0
			if(T.wet_overlay)
				T.overlays -= T.wet_overlay
				T.wet_overlay = null
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
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

/datum/reagent/dry_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return


/datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/hot_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return


/datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

/datum/reagent/hell_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()
	return


/datum/reagent/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/flour/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

/datum/reagent/flour/reaction_turf(var/turf/T, var/volume)
	src = null
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)


/datum/reagent/rice
	name = "Rice"
	id = "rice"
	description = "Enjoy the great taste of nothing."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

/datum/reagent/rice/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return


/datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/cherryjelly/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return


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
//			toxpwr = 0.2 //It's not THAT poisonous.
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

/datum/reagent/sugar/on_mob_life(var/mob/living/M as mob)
	if(prob(4))
		M.reagents.add_reagent("epinephrine", 1.2)
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
	if(current_cycle >= 90)
		M.jitteriness += 10
	..()
	return

/datum/reagent/sugar/overdose_process(var/mob/living/M as mob)
	if(volume > 200)
		M << "<span class = 'danger'>You pass out from hyperglycemic shock!</span>"
		M.Paralyse(1)
		if(prob(8))
			M.adjustToxLoss(rand(1,2))
	..()
	return
