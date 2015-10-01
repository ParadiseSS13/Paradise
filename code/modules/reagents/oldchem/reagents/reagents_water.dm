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

/datum/reagent/water/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return

// Put out fire
	if(method == TOUCH)
		M.adjust_fire_stacks(-(volume / 10))
		if(M.fire_stacks <= 0)
			M.ExtinguishMob()
		return

/datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)
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

	for(var/mob/living/carbon/slime/M in T)
		M.apply_water()

	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	return

/datum/reagent/water/reaction_obj(var/obj/O, var/volume)
	src = null
	var/turf/T = get_turf(O)
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	// Dehydrated carp
	if(istype(O,/obj/item/toy/carpplushie/dehy_carp))
		var/obj/item/toy/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp
	return


/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#1BB1AB"

/datum/reagent/lube/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 1)
		if(T.wet >= 2) return
		T.wet = 2
		spawn(800)
			if (!istype(T)) return
			T.wet = 0
			if(T.wet_overlay)
				T.overlays -= T.wet_overlay
				T.wet_overlay = null
			return


/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#61C2C2"

/datum/reagent/space_cleaner/reaction_obj(var/obj/O, var/volume)
	if(O && !istype(O, /atom/movable/lighting_overlay))
		O.color = initial(O.color)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(var/turf/T, var/volume)
	if(volume >= 1)
		if(T)
			T.color = initial(T.color)
		T.overlays.Cut()
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in src)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5,10))
		if(istype(T,/turf/simulated))
			var/turf/simulated/S = T
			S.dirt = 0

/datum/reagent/space_cleaner/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(istype(M,/mob/living/carbon/human))
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
		return


/datum/reagent/blood
	data = new/list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","resistances"=null,"trace_chem"=null, "antibodies" = null)
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#C80000" // rgb: 200, 0, 0

/datum/reagent/blood/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/blood/self = src
	src = null
	if(self.data && self.data["virus2"] && istype(M, /mob/living/carbon))//infecting...
		var/list/vlist = self.data["virus2"]
		if (vlist.len)
			for (var/ID in vlist)
				var/datum/disease2/disease/V = vlist[ID]

				if(method == TOUCH)
					infect_virus2(M,V.getcopy())
				else
					infect_virus2(M,V.getcopy(),1) //injected, force infection!
	if(self.data && self.data["antibodies"] && istype(M, /mob/living/carbon))//... and curing
		var/mob/living/carbon/C = M
		C.antibodies |= self.data["antibodies"]

/datum/reagent/blood/on_merge(var/data)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()

/datum/reagent/blood/on_update(var/atom/A)
	if(data["blood_colour"])
		color = data["blood_colour"]
	return ..()



/datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
	if(!istype(T)) return
	var/datum/reagent/blood/self = src
	src = null
	if(!(volume >= 3)) return
	//var/datum/disease/D = self.data["virus"]
	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

		if(self.data["virus2"])
			blood_prop.virus2 = virus_copylist(self.data["virus2"])

	else if(istype(self.data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
	return


/datum/reagent/fishwater
	name = "Fish Water"
	id = "fishwater"
	description = "Smelly water from a fish tank. Gross!"
	reagent_state = LIQUID
	color = "#757547"

/datum/reagent/fishwater/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST)
		M << "Oh god, why did you drink that?"

/datum/reagent/fishwater/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(30))		// Nasty, you drank this stuff? 30% chance of the fakevomit (non-stunning version)
		if(prob(50))	// 50/50 chance of green vomit vs normal vomit
			M.fakevomit(1)
		else
			M.fakevomit(0)
		..()
	return


/datum/reagent/holywater
	name = "Water"
	id = "holywater"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/holywater/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= 30)		// 12 units, 60 seconds @ metabolism 0.4 units & tick rate 2.0 sec
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 4
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(data >= 75 && prob(33))	// 30 units, 150 seconds
		if (!M.confused) M.confused = 1
		M.confused += 3
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(src.id, src.volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.jitteriness = 0
			M.stuttering = 0
			M.confused = 0
			return
	if(ishuman(M) && M.mind)				.
		if(((M.mind in ticker.mode.vampires) || M.mind.vampire) && (!(VAMP_FULL in M.mind.vampire.powers)) && prob(80))
			switch(data)
				if(1 to 4)
					M << "<span class = 'warning'>Something sizzles in your veins!</span>"
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(5 to 12)
					M << "<span class = 'danger'>You feel an intense burning inside of you!</span>"
					M.adjustFireLoss(1)
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
				if(13 to INFINITY)
					M << "<span class = 'danger'>You suddenly ignite in a holy fire!</span>"
					for(var/mob/O in viewers(M, null))
						O.show_message(text("<span class = 'danger'>[] suddenly bursts into flames!<span>", M), 1)
					M.fire_stacks = min(5,M.fire_stacks + 3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard?
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
	..()
	return


/datum/reagent/holywater/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	// Vampires have their powers weakened by holy water applied to the skin.
	if(ishuman(M))
		if((M.mind in ticker.mode.vampires) && !(VAMP_FULL in M.mind.vampire.powers))
			var/mob/living/carbon/human/H=M
			if(method == TOUCH)
				if(H.wear_mask)
					H << "\red Your mask protects you from the holy water!"
					return
				else if(H.head)
					H << "\red Your helmet protects you from the holy water!"
					return
				else
					M << "<span class='warning'>Something holy interferes with your powers!</span>"
					M.mind.vampire.nullified = max(5, M.mind.vampire.nullified + 2)
	return


/datum/reagent/holywater/reaction_turf(var/turf/simulated/T, var/volume)
	..()
	if(!istype(T)) return
	if(volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/*
/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	reagent_state = LIQUID
	color = "#C81040" // rgb: 200, 16, 64

/datum/reagent/vaccine/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/vaccine/self = src
	src = null
	if(self.data&&method == INGEST)
		for(var/datum/disease/D in M.viruses)
			if(istype(D, /datum/disease/advance))
				var/datum/disease/advance/A = D
				if(A.GetDiseaseID() == self.data)
					D.cure()
			else
				if(D.type == self.data)
					D.cure()

		M.resistances += self.data
	return
*/