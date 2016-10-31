/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/serotrotium/on_mob_life(mob/living/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()


/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			step(M, pick(cardinal))
	if(prob(5)) M.emote(pick("twitch","drool","moan"))
	..()


/datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM

/datum/reagent/hippies_delight/on_mob_life(mob/living/M)
	M.Druggy(50)
	switch(current_cycle)
		if(1 to 5)
			if(!M.stuttering) M.stuttering = 1
			M.Dizzy(10)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if(!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.Druggy(45)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			if(!M.stuttering) M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.Druggy(60)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	description = "A highly potent hallucinogenic substance. Far out, maaaan."
	reagent_state = LIQUID
	color = "#0000D8"

/datum/reagent/lsd/on_mob_life(mob/living/M)
	M.Druggy(15)
	M.AdjustHallucinate(10)
	..()

/datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#9087A2"
	metabolization_rate = 0.2
	addiction_chance = 65
	heart_rate_decrease = 1

/datum/reagent/space_drugs/on_mob_life(mob/living/M)
	M.Druggy(15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			step(M, pick(cardinal))
	if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
	..()

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231

/datum/reagent/psilocybin/on_mob_life(mob/living/M)
	M.Druggy(30)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(1)
			M.Dizzy(5)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(1)
			M.Jitter(10)
			M.Dizzy(10)
			M.Druggy(35)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(1)
			M.Jitter(20)
			M.Dizzy(20)
			M.Druggy(40)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	..()
