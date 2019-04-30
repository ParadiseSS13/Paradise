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
	drink_icon = "glass_clear"
	drink_name = "Glass of Water"
	drink_desc = "The father of all refreshments."
	taste_message = null

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		// Put out fire
		M.adjust_fire_stacks(-(volume * 0.2))

	if(isgrey(M)) // You gosh darn snowflakes
		var/mob/living/carbon/human/G = M
		if(method == TOUCH)
			if(volume > 25)
				if(G.wear_mask)
					to_chat(G, "<span class='danger'>Your [G.wear_mask] protects you from the acid!</span>")
					return

				if(G.head)
					to_chat(G, "<span class='danger'>Your [G.wear_mask] protects you from the acid!</span>")
					return

				if(prob(75))
					G.take_organ_damage(5, 10)
					G.emote("scream")
					var/obj/item/organ/external/affecting = G.get_organ("head")
					if(affecting)
						affecting.disfigure()
				else
					G.take_organ_damage(5, 10)
			else
				G.take_organ_damage(5, 10)
		else
			to_chat(G, "<span class='warning'>The water stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
			if(volume >= 10)
				G.adjustFireLoss(min(max(4, (volume - 10) * 2), 20))
				G.emote("scream")

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
	O.extinguish()

	if(istype(O, /obj/item/reagent_containers/food/snacks/monkeycube))
		var/obj/item/reagent_containers/food/snacks/monkeycube/cube = O
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
	taste_message = "cherry"

/datum/reagent/lube/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		T.MakeSlippery(TURF_WET_LUBE)


/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#61C2C2"
	taste_message = "floor cleaner"

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(is_cleanable(O))
		var/obj/effect/decal/cleanable/blood/B = O
		if(!(istype(B) && B.off_floor))
			qdel(O)
	else
		if(!istype(O, /atom/movable/lighting_overlay))
			O.color = initial(O.color)
		O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	if(volume >= 1)
		var/floor_only = TRUE
		for(var/obj/effect/decal/cleanable/C in src)
			var/obj/effect/decal/cleanable/blood/B = C
			if(istype(B) && B.off_floor)
				floor_only = FALSE
			else
				qdel(C)
		T.color = initial(T.color)
		if(floor_only)
			T.clean_blood()

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
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"="#A10808","resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null, "dna" = null)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#770000" // rgb: 40, 0, 0
	metabolization_rate = 5 //fast rate so it disappears fast.
	drink_icon = "glass_red"
	drink_name = "Glass of Tomato juice"
	drink_desc = "Are you sure this is tomato juice?"
	taste_message = "<span class='warning'>blood</span>"

/datum/reagent/blood/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(data && data["viruses"])
		for(var/thing in data["viruses"])
			var/datum/disease/D = thing

			if(D.spread_flags & SPECIAL || D.spread_flags & NON_CONTAGIOUS)
				continue

			if(method == TOUCH)
				M.ContractDisease(D)
			else //ingest, patch or inject
				M.ForceContractDisease(D)

	if(method == INGEST && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.get_blood_id() == "blood")
			if((!data || !(data["blood_type"] in get_safe_blood(C.dna.b_type))))
				C.reagents.add_reagent("toxin", volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(volume, 0.1), BLOOD_VOLUME_NORMAL)

/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned, etc
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

		if(mix_data["blood_color"])
			color = mix_data["blood_color"]
	return 1

/datum/reagent/blood/on_update(atom/A)
	if(data["blood_color"])
		color = data["blood_color"]
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

	else if(istype(data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_message = "antibodies"

/datum/reagent/vaccine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(islist(data) && (method == INGEST))
		for(var/thing in M.viruses)
			var/datum/disease/D = thing
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
	taste_message = "puke"

/datum/reagent/fishwater/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
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
	taste_message = "puke"

/datum/reagent/fishwater/toiletwater/reaction_mob(mob/living/M, method=TOUCH, volume) //For shennanigans
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
	taste_message = null

/datum/reagent/holywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-5)
	if(current_cycle >= 30)		// 12 units, 60 seconds @ metabolism 0.4 units & tick rate 2.0 sec
		M.AdjustStuttering(4, bound_lower = 0, bound_upper = 20)
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.AdjustCultSlur(5)//5 seems like a good number...
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(current_cycle >= 75 && prob(33))	// 30 units, 150 seconds
		M.AdjustConfused(3)
		if(isvampirethrall(M))
			ticker.mode.remove_vampire_mind(M.mind)
			holder.remove_reagent(id, volume)
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			return
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(id, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.SetJitter(0)
			M.SetStuttering(0)
			M.SetConfused(0)
			return
	if(ishuman(M) && M.mind && M.mind.vampire && !M.mind.vampire.get_ability(/datum/vampire_passive/full) && prob(80))
		var/mob/living/carbon/V = M
		if(M.mind.vampire.bloodusable)
			M.Stuttering(1)
			M.Jitter(30)
			update_flags |= M.adjustStaminaLoss(5, FALSE)
			if(prob(20))
				M.emote("scream")
			M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
			M.mind.vampire.bloodusable = max(M.mind.vampire.bloodusable - 3,0)
			if(M.mind.vampire.bloodusable)
				V.vomit(0,1)
			else
				holder.remove_reagent(id, volume)
				V.vomit(0,0)
				return
		else
			switch(current_cycle)
				if(1 to 4)
					to_chat(M, "<span class = 'warning'>Something sizzles in your veins!</span>")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(5 to 12)
					to_chat(M, "<span class = 'danger'>You feel an intense burning inside of you!</span>")
					update_flags |= M.adjustFireLoss(1, FALSE)
					M.Stuttering(1)
					M.Jitter(20)
					if(prob(20))
						M.emote("scream")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(13 to INFINITY)
					to_chat(M, "<span class = 'danger'>You suddenly ignite in a holy fire!</span>")
					for(var/mob/O in viewers(M, null))
						O.show_message(text("<span class = 'danger'>[] suddenly bursts into flames!</span>", M), 1)
					M.fire_stacks = min(5,M.fire_stacks + 3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					update_flags |= M.adjustFireLoss(3, FALSE)		//Hence the other damages... ain't I a bastard?
					M.Stuttering(1)
					M.Jitter(30)
					if(prob(40))
						M.emote("scream")
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
	return ..() | update_flags


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

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existance."
	process_flags = ORGANIC | SYNTHETIC //ethereal means everything processes it.
	metabolization_rate = 1
	taste_message = "sulfur"

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(iscultist(M))
		M.AdjustDrowsy(-5)
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-2, FALSE)
		update_flags |= M.AdjustWeakened(-2, FALSE)
		update_flags |= M.adjustToxLoss(-2, FALSE)
		update_flags |= M.adjustFireLoss(-2, FALSE)
		update_flags |= M.adjustOxyLoss(-2, FALSE)
		update_flags |= M.adjustBruteLoss(-2, FALSE)
	else
		update_flags |= M.adjustBrainLoss(3, FALSE)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustFireLoss(2, FALSE)
		update_flags |= M.adjustOxyLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(2, FALSE)
		M.AdjustCultSlur(10)//CUASE WHY THE HELL NOT
	return ..() | update_flags

/datum/reagent/hellwater
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
	process_flags = ORGANIC | SYNTHETIC		//Admin-bus has no brakes! KILL THEM ALL.
	metabolization_rate = 1
	can_synth = FALSE
	taste_message = "admin abuse"

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
	taste_message = "meat"

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
	taste_message = "<span class='userdanger'>ACID</span>"//don't drink lye, kids

/datum/reagent/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	description = "Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_message = "dry mouth"

/datum/reagent/drying_agent/reaction_turf(turf/simulated/T, volume)
	if(istype(T) && T.wet)
		T.MakeDry(TURF_WET_WATER)

/datum/reagent/drying_agent/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/clothing/shoes/galoshes))
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)
