/****************************************************
				BLOOD SYSTEM
****************************************************/
//Blood levels
var/const/BLOOD_VOLUME_SAFE = 501
var/const/BLOOD_VOLUME_OKAY = 336
var/const/BLOOD_VOLUME_BAD = 224
var/const/BLOOD_VOLUME_SURVIVE = 122

/mob/living/carbon/human/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.
/mob/living/carbon/human/var/var/pale = 0			//Should affect how mob sprite is drawn, but currently doesn't.

//Initializes blood vessels
/mob/living/carbon/human/proc/make_blood()

	if(vessel)
		return

	vessel = new/datum/reagents(600)
	vessel.my_atom = src

	if(species && species.flags & NO_BLOOD) //We want the var for safety but we can do without the actual blood.
		return
	if(species.bloodflags &BLOOD_SLIME)
		vessel.add_reagent("water",560)
	else
		vessel.add_reagent("blood",560)
	spawn(1)
		fixblood()

//Resets blood data
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.data = list(	"donor"=src,"viruses"=null,"blood_DNA"=dna.unique_enzymes,"blood_type"=dna.b_type,	\
							"resistances"=null,"trace_chem"=null, "virus2" = null, "antibodies" = null)

// Takes care blood loss and regeneration
/mob/living/carbon/human/proc/handle_blood()
	var/blood_volume
	if(species && species.flags & NO_BLOOD)
		return
	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.
		if(species.bloodflags &BLOOD_SLIME)
			blood_volume = round(vessel.get_reagent_amount("water"))
			if(blood_volume < 560 && blood_volume)
				var/datum/reagent/water/W = locate() in vessel.reagent_list //Grab some blood
				if(W) // Make sure there's some blood at all
					W.volume += 0.1 // regenerate blood VERY slowly
					if (reagents.has_reagent("nutriment"))	//Getting food speeds it up
						W.volume += 0.4
						reagents.remove_reagent("nutriment", 0.1)
		else
			blood_volume = round(vessel.get_reagent_amount("blood"))
			//Blood regeneration if there is some space
			if(blood_volume < 560 && blood_volume)
				var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
				if(B) // Make sure there's some blood at all
					if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
						for(var/datum/reagent/blood/D in vessel.reagent_list)
							if(D.data["donor"] == src)
								B = D
								break

					B.volume += 0.1 // regenerate blood VERY slowly
					if (reagents.has_reagent("nutriment"))	//Getting food speeds it up
						B.volume += 0.4
						reagents.remove_reagent("nutriment", 0.1)
					if (reagents.has_reagent("iron"))	//Hematogen candy anyone?
						B.volume += 0.8
						reagents.remove_reagent("iron", 0.1)

		// Damaged heart virtually reduces the blood volume, as the blood isn't
		// being pumped properly anymore.
		var/datum/organ/internal/heart/heart = internal_organs_by_name["heart"]
		
		if(heart)
			if(heart.damage > 1 && heart.damage < heart.min_bruised_damage)
				blood_volume *= 0.8
			else if(heart.damage >= heart.min_bruised_damage && heart.damage < heart.min_broken_damage)
				blood_volume *= 0.6
			else if(heart.damage >= heart.min_broken_damage && heart.damage < INFINITY)
				blood_volume *= 0.3

		//Effects of bloodloss
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to 10000)
				if(pale)
					pale = 0
					update_body()
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(!pale)
					pale = 1
					update_body()
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel [word]"
				if(prob(1))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel [word]"
				if(oxyloss < 20)
					oxyloss += 3
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(!pale)
					pale = 1
					update_body()
				eye_blurry += 6
				if(oxyloss < 50)
					oxyloss += 10
				oxyloss += 1
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel very [word]"
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(!pale)
					pale = 1
					update_body()
				if(oxyloss > 20)
					eye_blurry += 6
				oxyloss += 12
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woosey","faint")
					src << "\red You feel extremely [word]"
			if(0 to BLOOD_VOLUME_SURVIVE)
				// There currently is a strange bug here. If the mob is not below -100 health
				// when death() is called, apparently they will be just fine, and this way it'll
				// spam deathgasp. Adjusting toxloss ensures the mob will stay dead.
				toxloss += 300 // just to be safe!
				death()

		// Without enough blood you slowly go hungry.
		if(blood_volume < BLOOD_VOLUME_SAFE)
			if(nutrition >= 300)
				nutrition -= 10
			else if(nutrition >= 200)
				nutrition -= 3

		//Bleeding out
		var/blood_max = 0
		for(var/datum/organ/external/temp in organs)
			if(!(temp.status & ORGAN_BLEEDING) || temp.status & ORGAN_ROBOT)
				continue
			for(var/datum/wound/W in temp.wounds) if(W.bleeding())
				blood_max += W.damage / 4
			if (temp.open)
				blood_max += 2  //Yer stomach is cut open
		drip(blood_max)

//Makes a blood drop, leaking certain amount of blood from the mob
/mob/living/carbon/human/proc/drip(var/amt as num)

	if(species && species.flags & NO_BLOOD) //TODO: Make drips come from the reagents instead.
		return

	if(!amt)
		return

	var/amm = 0.1 * amt
	var/turf/T = get_turf(src)
	var/list/obj/effect/decal/cleanable/blood/drip/nums = list()

	var/list/iconL = list("1","2","3","4","5")

	if(src.species.bloodflags &BLOOD_SLIME)
		vessel.remove_reagent("water",amm)
		vessel.reaction(T, TOUCH, amm)
		return

	if(src.species.bloodflags &BLOOD_GREEN)
		var/list/obj/effect/decal/cleanable/blood/drip/green/nums2 = list()
		iconL = list("g1","g2","g3","g4","g5")

		vessel.remove_reagent("blood",amm)

		for(var/obj/effect/decal/cleanable/blood/drip/green/G in T)
			nums2 += G
			iconL.Remove(G.icon_state)

		if (nums2.len < 5)
			var/obj/effect/decal/cleanable/blood/drip/green/this = new(T)
			this.icon_state = pick(iconL)
			this.blood_DNA = list()
			this.blood_DNA[dna.unique_enzymes] = dna.b_type
			for (var/ID in virus2)
				var/datum/disease2/disease/V = virus2[ID]
				this.virus2[ID] = V.getcopy()
		else
			for(var/obj/effect/decal/cleanable/blood/drip/green/G in nums)
				del G
			T.add_blood(src)
		return

	else
		vessel.remove_reagent("blood",amm)

		for(var/obj/effect/decal/cleanable/blood/drip/G in T)
			nums += G
			iconL.Remove(G.icon_state)

		if (nums.len < 5)
			var/obj/effect/decal/cleanable/blood/drip/this = new(T)
			this.icon_state = pick(iconL)
			this.blood_DNA = list()
			this.blood_DNA[dna.unique_enzymes] = dna.b_type
			for (var/ID in virus2)
				var/datum/disease2/disease/V = virus2[ID]
				this.virus2[ID] = V.getcopy()
		else
			for(var/obj/effect/decal/cleanable/blood/drip/G in nums)
				del G
			T.add_blood(src)
		return

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to the container, preserving all data in it.
/mob/living/carbon/proc/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/B = get_blood(container.reagents)
	if(!B)	B = new /datum/reagent/blood
	B.holder = container
	B.volume += amount



	//set reagent data
	B.data["donor"] = src
	if (!B.data["virus2"])
		B.data["virus2"] = list()
	B.data["virus2"] |= virus_copylist(src.virus2)
	B.data["antibodies"] = src.antibodies
	B.data["blood_DNA"] = copytext(src.dna.unique_enzymes,1,0)
	B.data["blood_type"] = copytext(src.dna.b_type,1,0)
	var/list/temp_chem = list()
	for(var/datum/reagent/R in src.reagents.reagent_list)
		temp_chem += R.id
		temp_chem[R.id] = R.volume
	B.data["trace_chem"] = list2params(temp_chem)
	return B

//For humans, blood does not appear from blue, it comes from vessels.
/mob/living/carbon/human/take_blood(obj/item/weapon/reagent_containers/container, var/amount)
	if(src.species.bloodflags &BLOOD_SLIME)
		if(vessel.get_reagent_amount("water") < amount)
			return null
		var/datum/reagent/W = new /datum/reagent/water
		W.holder = container
		W.volume += amount
		var/list/temp_chem = list()
		for(var/datum/reagent/R in src.reagents.reagent_list)
			temp_chem += R.id
			temp_chem[R.id] = R.volume
		W.data["trace_chem"] = list2params(temp_chem)
		vessel.remove_reagent("water",amount) // Removes blood if human
		return W
	if(species && species.flags & NO_BLOOD)
		return null
	else
		if(vessel.get_reagent_amount("blood") < amount)
			return null
		. = ..()
		vessel.remove_reagent("blood",amount) // Removes blood if human

//Transfers blood from container ot vessels
/mob/living/carbon/proc/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)
	var/datum/reagent/blood/injected = get_blood(container.reagents)
	if (!injected)
		return
	var/list/sniffles = virus_copylist(injected.data["virus2"])
	for(var/ID in sniffles)
		var/datum/disease2/disease/sniffle = sniffles[ID]
		infect_virus2(src,sniffle,1)
	if (injected.data["antibodies"] && prob(5))
		antibodies |= injected.data["antibodies"]
	var/list/chems = list()
	chems = params2list(injected.data["trace_chem"])
	for(var/C in chems)
		src.reagents.add_reagent(C, (text2num(chems[C]) / 560) * amount)//adds trace chemicals to owner's blood
	reagents.update_total()

	container.reagents.remove_reagent("blood", amount)

//Transfers blood from container ot vessels, respecting blood types compatability.
/mob/living/carbon/human/inject_blood(obj/item/weapon/reagent_containers/container, var/amount)

	var/datum/reagent/blood/injected = get_blood(container.reagents)

	if(species && species.flags & NO_BLOOD)
		reagents.add_reagent("blood", amount, injected.data)
		reagents.update_total()
		return

	var/datum/reagent/blood/our = get_blood(vessel)

	if (!injected || !our)
		return
	if(blood_incompatible(injected.data["blood_type"],our.data["blood_type"]) )
		reagents.add_reagent("toxin",amount * 0.5)
		reagents.update_total()
	else
		vessel.add_reagent("blood", amount, injected.data)
		vessel.update_total()
	..()

//Gets human's own blood.
/mob/living/carbon/proc/get_blood(datum/reagents/container)
	var/datum/reagent/blood/res = locate() in container.reagent_list //Grab some blood
	if(res) // Make sure there's some blood at all
		if(res.data["donor"] != src) //If it's not theirs, then we look for theirs
			for(var/datum/reagent/blood/D in container.reagent_list)
				if(D.data["donor"] == src)
					return D
	return res

proc/blood_incompatible(donor,receiver)
	if(!donor || !receiver) return 0
	var
		donor_antigen = copytext(donor,1,lentext(donor))
		receiver_antigen = copytext(receiver,1,lentext(receiver))
		donor_rh = (findtext(donor,"+")>0)
		receiver_rh = (findtext(receiver,"+")>0)
	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0