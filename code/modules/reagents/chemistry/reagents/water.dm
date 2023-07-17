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
	taste_description = "water"
	var/cooling_temperature = 2
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "glass_clear"
	drink_name = "Glass of Water"
	drink_desc = "The father of all refreshments."
	var/water_temperature = 283.15 // As reagents don't have a temperature value, we'll just use 10 celsius.

/datum/reagent/water/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	M.water_act(volume, water_temperature, src, method)

/datum/reagent/water/reaction_turf(turf/T, volume)
	T.water_act(volume, water_temperature, src)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - volume*  50, 0)

/datum/reagent/water/reaction_obj(obj/O, volume)
	O.water_act(volume, water_temperature, src)

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#1BB1AB"
	harmless = TRUE
	taste_description = "cherry"

/datum/reagent/lube/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		T.MakeSlippery(TURF_WET_LUBE)


/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#61C2C2"
	harmless = TRUE
	taste_description = "floor cleaner"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(iseffect(O))
		var/obj/effect/E = O
		if(E.is_cleanable())
			var/obj/effect/decal/cleanable/blood/B = E
			if(!(istype(B) && B.off_floor))
				qdel(E)
	else
		if(O.simulated)
			O.color = initial(O.color)
		O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	T.clean(volume >= 1)

/datum/reagent/space_cleaner/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	M.clean_blood()

/datum/reagent/blood
	data = list("donor" = null,
				"viruses" = null,
				"blood_DNA" = null,
				"blood_type" = null,
				"blood_colour" = "#A10808",
				"resistances" = null,
				"trace_chem" = null,
				"mind" = null,
				"ckey" = null,
				"gender" = null,
				"real_name" = null,
				"cloneable" = null,
				"factions" = null,
				"dna" = null,
				"species" = "Synthetic Humanoid",
				"species_only" = FALSE)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#770000" // rgb: 40, 0, 0
	metabolization_rate = 5 //fast rate so it disappears fast.
	drink_icon = "glass_red"
	drink_name = "Glass of Tomato juice"
	drink_desc = "Are you sure this is tomato juice?"
	taste_description = "<span class='warning'>blood</span>"
	taste_mult = 1.3

/datum/reagent/blood/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if(D.spread_flags & SPECIAL || D.spread_flags & NON_CONTAGIOUS)
				continue

			if(method == REAGENT_TOUCH)
				M.ContractDisease(D)
			else //ingest, patch or inject
				M.ForceContractDisease(D)

	if(method == REAGENT_INGEST && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.mind?.has_antag_datum(/datum/antagonist/vampire))
			C.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, C.nutrition + 10))
	..()

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(!data || !mix_data)
		return

	var/same_species = data["species"] == mix_data["species"]
	var/species_unique = data["species_only"] || mix_data["species_only"]
	var/species_mismatch = species_unique && !same_species
	var/type_mismatch = data["blood_type"] != mix_data["blood_type"]

	if(mix_data["blood_color"])
		color = mix_data["blood_color"]
	data["cloneable"] = 0 // On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned

	if(type_mismatch || species_mismatch)
		data["species"] = "Coagulated blood"
		data["blood_type"] = "<span class='warning'>UNUSABLE!</span>"
		data["species_only"] = species_unique
	else if(!same_species) // Same blood type, species-agnostic, but we're still mixing blood of different species
		data["species"] = "Mixed humanoid blood"

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

/datum/reagent/blood/on_update(atom/A)
	if(data["blood_color"])
		color = data["blood_color"]
	return ..()

/datum/reagent/blood/reaction_turf(turf/simulated/T, volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(volume < 3)
		return
	if(!data["donor"] || ishuman(data["donor"]))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[data["blood_DNA"]] = data["blood_type"]

	else if(isalien(data["donor"]))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_description = "antibodies"

/datum/reagent/vaccine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(islist(data) && (method == REAGENT_INGEST))
		for(var/thing in M.viruses)
			var/datum/disease/D = thing
			if(D.GetDiseaseID() in data)
				D.cure()
		M.resistances |= data

/datum/reagent/vaccine/on_merge(list/incoming_data)
	if(islist(incoming_data))
		data |= incoming_data.Copy()

/datum/reagent/fishwater
	name = "Fish Water"
	id = "fishwater"
	description = "Smelly water from a fish tank. Gross!"
	reagent_state = LIQUID
	color = "#757547"
	taste_description = "puke"

/datum/reagent/fishwater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		to_chat(M, "Oh god, why did you drink that?")

/datum/reagent/fishwater/on_mob_life(mob/living/M)
	if(prob(30))		// Nasty, you drank this stuff? 30% chance of the fakevomit (non-stunning version)
		if(prob(50))	// 50/50 chance of green vomit vs normal vomit
			M.fakevomit(1)
		else
			M.fakevomit(0)
	return ..()

/datum/reagent/fishwater/toiletwater
	name = "Toilet Water"
	id = "toiletwater"
	description = "Filthy water scoured from a nasty toilet bowl. Absolutely disgusting."
	reagent_state = LIQUID
	color = "#757547"
	taste_description = "the inside of a toilet... or worse"

/datum/reagent/fishwater/toiletwater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //For shennanigans
	return

/datum/reagent/holywater
	name = "Water"
	id = "holywater"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	process_flags = ORGANIC | SYNTHETIC
	drink_icon = "glass_clear"
	drink_name = "Glass of Water"
	drink_desc = "The father of all refreshments."
	taste_description = "water"

/datum/reagent/holywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-10 SECONDS)
	if(current_cycle >= 30)		// 12 units, 60 seconds @ metabolism 0.4 units & tick rate 2.0 sec
		M.AdjustStuttering(8 SECONDS, bound_lower = 0, bound_upper = 40 SECONDS)
		M.Dizzy(10 SECONDS)
		if(iscultist(M))
			for(var/datum/action/innate/cult/blood_magic/BM in M.actions)
				for(var/datum/action/innate/cult/blood_spell/BS in BM.spells)
					to_chat(M, "<span class='cultlarge'>Your blood rites falter as holy water scours your body!</span>")
					qdel(BS)
			if(prob(5))
				M.AdjustCultSlur(10 SECONDS)//5 seems like a good number...
				M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
		if(isvampirethrall(M))
			if(prob(10))
				M.say(pick("*gasp", "*cough", "*sneeze"))
			if(prob(5)) //Same as cult, for the real big tell
				M.visible_message("<span class='warning'>A fog lifts from [M]'s eyes for a moment, but soon returns.</span>")

	if(current_cycle >= 75 && prob(33))	// 30 units, 150 seconds
		M.AdjustConfused(6 SECONDS)
		if(isvampirethrall(M))
			M.mind.remove_antag_datum(/datum/antagonist/mindslave/thrall)
			holder.remove_reagent(id, volume)
			M.visible_message("<span class='biggerdanger'>[M] recoils, their skin flushes with colour, regaining their sense of control!</span>")
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			return
		if(iscultist(M))
			SSticker.mode.remove_cultist(M.mind, TRUE, TRUE)
			holder.remove_reagent(id, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			return
	var/datum/antagonist/vampire/vamp = M.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(ishuman(M) && vamp && !vamp.get_ability(/datum/vampire_passive/full) && prob(80))
		var/mob/living/carbon/V = M
		if(vamp.bloodusable)
			M.Stuttering(2 SECONDS)
			M.Jitter(60 SECONDS)
			update_flags |= M.adjustStaminaLoss(5, FALSE)
			if(prob(20))
				M.emote("scream")
			vamp.adjust_nullification(20, 4)
			vamp.bloodusable = max(vamp.bloodusable - 3,0)
			if(vamp.bloodusable)
				V.vomit(0, TRUE, FALSE)
				V.adjustBruteLoss(3)
			else
				holder.remove_reagent(id, volume)
				V.vomit(0, FALSE, FALSE)
				return
		else
			if(!vamp.bloodtotal)
				return ..() | update_flags
			switch(current_cycle)
				if(1 to 4)
					to_chat(M, "<span class = 'warning'>Something sizzles in your veins!</span>")
					vamp.adjust_nullification(20, 4)
				if(5 to 12)
					to_chat(M, "<span class = 'danger'>You feel an intense burning inside of you!</span>")
					update_flags |= M.adjustFireLoss(1, FALSE)
					M.Stuttering(2 SECONDS)
					M.Jitter(40 SECONDS)
					if(prob(20))
						M.emote("scream")
					vamp.adjust_nullification(20, 4)
				if(13 to INFINITY)
					M.visible_message("<span class='danger'>[M] suddenly bursts into flames!</span>",
									"<span class='danger'>You suddenly ignite in a holy fire!</span>")
					M.fire_stacks = min(5, M.fire_stacks + 3)
					M.IgniteMob()
					update_flags |= M.adjustFireLoss(3, FALSE)
					M.Stuttering(2 SECONDS)
					M.Jitter(60 SECONDS)
					if(prob(40))
						M.emote("scream")
					vamp.adjust_nullification(20, 4)
	return ..() | update_flags


/datum/reagent/holywater/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	// Vampires have their powers weakened by holy water applied to the skin.
	var/datum/antagonist/vampire/V = M.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(ishuman(M) && V && !V.get_ability(/datum/vampire_passive/full))
		var/mob/living/carbon/human/H = M
		if(method == REAGENT_TOUCH)
			if(H.wear_mask)
				to_chat(H, "<span class='warning'>Your mask protects you from the holy water!</span>")
				return
			else if(H.head)
				to_chat(H, "<span class='warning'>Your helmet protects you from the holy water!</span>")
				return
			else
				to_chat(M, "<span class='warning'>Something holy interferes with your powers!</span>")
				V.adjust_nullification(5, 2)


/datum/reagent/holywater/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existence."
	process_flags = ORGANIC | SYNTHETIC //ethereal means everything processes it.
	metabolization_rate = 1
	taste_description = "sulfur"

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(iscultist(M))
		M.AdjustDrowsy(-10 SECONDS)
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-4 SECONDS)
		M.AdjustWeakened(-4 SECONDS)
		M.AdjustKnockDown(-4 SECONDS)
		update_flags |= M.adjustStaminaLoss(-25, FALSE)
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
		update_flags |= M.adjustOxyLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	else
		update_flags |= M.adjustBrainLoss(3, FALSE)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustFireLoss(2, FALSE)
		update_flags |= M.adjustOxyLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(2, FALSE)
		M.AdjustCultSlur(20 SECONDS) //CUASE WHY THE HELL NOT
	return ..() | update_flags

/datum/reagent/hellwater
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
	process_flags = ORGANIC | SYNTHETIC		//Admin-bus has no brakes! KILL THEM ALL.
	metabolization_rate = 1
	can_synth = FALSE
	taste_description = "burning"

/datum/reagent/hellwater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.fire_stacks = min(5, M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustFireLoss(1, FALSE)		//Hence the other damages... ain't I a bastard?
	update_flags |= M.adjustBrainLoss(5, FALSE)
	return ..() | update_flags

/datum/reagent/liquidgibs
	name = "Liquid gibs"
	id = "liquidgibs"
	color = "#FF9966"
	description = "You don't even want to think about what's in here."
	reagent_state = LIQUID
	taste_description = "meat"

/datum/reagent/liquidgibs/reaction_turf(turf/T, volume) //yes i took it from synthflesh...
	if(volume >= 5 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/lye
	name = "Lye"
	id = "lye"
	description = "Also known as sodium hydroxide."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow
	taste_description = "<span class='userdanger'>ACID</span>"//don't drink lye, kids

/datum/reagent/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	description = "Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "dry mouth"

/datum/reagent/drying_agent/reaction_turf(turf/simulated/T, volume)
	if(istype(T) && T.wet)
		T.MakeDry(TURF_WET_WATER)

/datum/reagent/drying_agent/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/clothing/shoes/galoshes))
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)
