/*
// Frankly, this is just for chemicals that are sortof 'watery', which really didn't seem to fit under any other file
// Current chems: Water, Space Lube, Space Cleaner, Blood, Fish Water, Holy water
//
//
*/



/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	var/cooling_temperature = 2
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, volume)
// Put out fire
	if(method == TOUCH)
		M.adjust_fire_stacks(-(volume / 10))
		M.ExtinguishMob()

/datum/reagent/water/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume >= 3)
		T.MakeSlippery()

	for(var/mob/living/carbon/slime/M in T)
		M.apply_water()

	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000,lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/water/reaction_obj(obj/O, volume)
	if(istype(O))
		O.extinguish()

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	// Dehydrated carp
	if(istype(O, /obj/item/toy/carpplushie/dehy_carp))
		var/obj/item/toy/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp


/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#1BB1AB"

/datum/reagent/lube/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		T.MakeSlippery(TURF_WET_LUBE)


/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#61C2C2"

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(O && !istype(O, /atom/movable/lighting_overlay))
		O.color = initial(O.color)
	if(istype(O, /obj/effect/decal/cleanable))
		qdel(O)
	else if(O)
		O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	if(volume >= 1)
		if(T)
			T.color = initial(T.color)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5,10))
		if(istype(T, /turf/simulated))
			var/turf/simulated/S = T
			S.dirt = 0

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.lip_style)
				H.lip_style = null
				H.update_body()
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0,0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0,0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0,0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0,0)
		M.clean_blood()
		..()


/datum/reagent/blood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"="#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#C80000" // rgb: 200, 0, 0

/datum/reagent/blood/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(data && data["viruses"])
		for(var/datum/disease/D in data["viruses"])

			if(D.spread_flags & SPECIAL || D.spread_flags & NON_CONTAGIOUS)
				continue

			if(method == TOUCH)
				M.ContractDisease(D)
			else //ingest, patch or inject
				M.ForceContractDisease(D)

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve

		if(mix_data["blood_colour"])
			color = mix_data["blood_colour"]
	return 1

/datum/reagent/blood/on_update(atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/reaction_turf(turf/simulated/T, volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(volume < 3)
		return
	if(!data["donor"] || istype(data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

		for(var/datum/disease/D in data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

	else if(istype(data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

		for(var/datum/disease/D in data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64

/datum/reagent/vaccine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(islist(data) && (method == INGEST))
		for(var/datum/disease/D in M.viruses)
			if(D.GetDiseaseID() in data)
				D.cure()
		M.resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		data |= data.Copy()

/datum/reagent/fishwater
	name = "Fish Water"
	id = "fishwater"
	description = "Smelly water from a fish tank. Gross!"
	reagent_state = LIQUID
	color = "#757547"

/datum/reagent/fishwater/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		to_chat(M, "Oh god, why did you drink that?")

/datum/reagent/fishwater/on_mob_life(mob/living/M)
	if(prob(30))		// Nasty, you drank this stuff? 30% chance of the fakevomit (non-stunning version)
		if(prob(50))	// 50/50 chance of green vomit vs normal vomit
			M.fakevomit(1)
		else
			M.fakevomit(0)
	..()

/datum/reagent/fishwater/toiletwater
	name = "Toilet Water"
	id = "toiletwater"
	description = "Filthy water scoured from a nasty toilet bowl. Absolutely disgusting."
	reagent_state = LIQUID
	color = "#757547"

/datum/reagent/fishwater/toiletwater/reaction_mob(mob/living/M, method=TOUCH, volume) //For shennanigans
	return

/datum/reagent/holywater
	name = "Water"
	id = "holywater"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/holywater/on_mob_life(mob/living/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(current_cycle >= 30)		// 12 units, 60 seconds @ metabolism 0.4 units & tick rate 2.0 sec
		M.stuttering = min(M.stuttering+4, 20)
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(current_cycle >= 75 && prob(33))	// 30 units, 150 seconds
		M.confused += 3
		if(isvampirethrall(M))
			ticker.mode.remove_vampire_mind(M.mind)
			holder.remove_reagent(id, volume)
			M.jitteriness = 0
			M.stuttering = 0
			M.confused = 0
			return
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(id, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.jitteriness = 0
			M.stuttering = 0
			M.confused = 0
			return
	if(ishuman(M) && M.mind && M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full) && prob(80))
		switch(current_cycle)
			if(1 to 4)
				to_chat(M, "<span class = 'warning'>Something sizzles in your veins!</span>")
				M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
			if(5 to 12)
				to_chat(M, "<span class = 'danger'>You feel an intense burning inside of you!</span>")
				M.adjustFireLoss(1)
				M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
			if(13 to INFINITY)
				to_chat(M, "<span class = 'danger'>You suddenly ignite in a holy fire!</span>")
				for(var/mob/O in viewers(M, null))
					O.show_message(text("<span class = 'danger'>[] suddenly bursts into flames!<span>", M), 1)
				M.fire_stacks = min(5,M.fire_stacks + 3)
				M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
				M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard?
				M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
	..()


/datum/reagent/holywater/reaction_mob(mob/living/M, method=TOUCH, volume)
	// Vampires have their powers weakened by holy water applied to the skin.
	if(ishuman(M) && M.mind && M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full))
		var/mob/living/carbon/human/H=M
		if(method == TOUCH)
			if(H.wear_mask)
				to_chat(H, "<span class='warning'>Your mask protects you from the holy water!</span>")
				return
			else if(H.head)
				to_chat(H, "<span class='warning'>Your helmet protects you from the holy water!</span>")
				return
			else
				to_chat(M, "<span class='warning'>Something holy interferes with your powers!</span>")
				M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)


/datum/reagent/holywater/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()


/datum/reagent/liquidgibs
	name = "Liquid gibs"
	id = "liquidgibs"
	color = "#FF9966"
	description = "You don't even want to think about what's in here."
	reagent_state = LIQUID

/datum/reagent/liquidgibs/reaction_turf(turf/T, volume) //yes i took it from synthflesh...
	if(volume >= 5 && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/lye
	name = "Lye"
	id = "lye"
	description = "Also known as sodium hydroxide."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow

/datum/reagent/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	description = "Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"

/datum/reagent/drying_agent/reaction_turf(turf/simulated/T, volume)
	if(istype(T) && T.wet)
		T.MakeDry(TURF_WET_WATER)

/datum/reagent/drying_agent/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/clothing/shoes/galoshes))
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)
