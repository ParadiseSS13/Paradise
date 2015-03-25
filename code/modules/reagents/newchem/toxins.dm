#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

datum/reagent/polonium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.radiation += 8
	..()
	return


datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "A dose-dependent toxin, ranges from annoying to incredibly lethal."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
	overdose_threshold = 30

datum/reagent/histamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	switch(pick(1, 2, 3, 4))
		if(1)
			M << "<span class='danger'>You can barely see!</span>"
			M.eye_blurry = 3
		if(2)
			M.emote("cough")
		if(3)
			M.emote("sneeze")
		if(4)
			if(prob(75))
				M << "You scratch at an itch."
				M.adjustBruteLoss(2*REM)
	..()
	return
datum/reagent/histamine/overdose_process(var/mob/living/M as mob)
	M.adjustOxyLoss(pick(1,3)*REM)
	M.adjustBruteLoss(pick(1,3)*REM)
	M.adjustToxLoss(pick(1,3)*REM)
	..()
	return

datum/reagent/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Deals a moderate amount of Toxin damage over time. 10% chance to decay into 10-15 histamine."
	reagent_state = LIQUID
	color = "#CF3600"

datum/reagent/formaldehyde/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	if(prob(10))
		M.reagents.add_reagent("histamine",pick(5,15))
		M.reagents.remove_reagent("formaldehyde",1)
	..()
	return

/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "Formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	required_temp = 420

datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "Will deal scaling amounts of Toxin and Brute damage over time. 25% chance to decay into 5-10 histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
datum/reagent/venom/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss((0.1*volume)*REM)
	M.adjustBruteLoss((0.1*volume)*REM)
	if(prob(25))
		M.reagents.add_reagent("histamine",pick(5,10))
		M.reagents.remove_reagent("venom",1)
	..()
	return

datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "Deals toxin and brain damage up to 60 before it slows down, causing confusion and a knockout after 17 elapsed cycles."
	reagent_state = LIQUID
	color = "#CF3600"
	var/cycle_count = 0
	metabolization_rate = 1

datum/reagent/neurotoxin2/on_mob_life(var/mob/living/M as mob)
	cycle_count++
	if(M.brainloss < 60)
		M.adjustBrainLoss(1*REM)
	M.adjustToxLoss(1*REM)
	if(cycle_count == 17)
		M.sleeping += 10 // buffed so it works
	..()
	return

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	required_temp = 674

datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "Deals toxin damage, alongside some oxygen loss. 8% chance of stun and some extra toxin damage."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

datum/reagent/cyanide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1.5*REM)
	if(prob(10))
		M.losebreath += 1
	if(prob(8))
		M << "You feel horrendously weak!"
		M.Stun(2)
		M.adjustToxLoss(2*REM)
	..()
	return

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = "cyanide"
	result = "cyanide"
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	result_amount = 3
	required_temp = 380

/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "????"
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2

datum/reagent/questionmark/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return

datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "Lots of annoying random effects, chances to do some brute damage from scratching. 6% chance to decay into 1-3 units of histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.3

/datum/reagent/itching_powder/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.reagents.add_reagent("itching_powder", volume)
		return

datum/reagent/itching_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(rand(5,50)))
		M << "You scratch at your head."
		M.adjustBruteLoss(0.2*REM)
	if(prob(rand(5,50)))
		M << "You scratch at your leg."
		M.adjustBruteLoss(0.2*REM)
	if(prob(rand(5,50)))
		M << "You scratch at your arm."
		M.adjustBruteLoss(0.2*REM)
	if(prob(6))
		M.reagents.add_reagent("histamine",rand(1,3))
		M.reagents.remove_reagent("itching_powder",1)
	..()
	return

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "charcoal" = 1)
	result_amount = 3

datum/reagent/facid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(2*REM)
	M.take_organ_damage(0, 1*REM)
	..()
	return

datum/reagent/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	description = ""
	reagent_state = LIQUID
	color = "#CF3600"

datum/reagent/facid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return //wooo more runtime fixin
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.wear_mask)
				if(!H.wear_mask.unacidable)
					qdel (H.wear_mask)
					H.update_inv_wear_mask()
					H << "\red Your mask melts away but protects you from the acid!"
				else
					H << "\red Your mask protects you from the acid!"
				return

			if(H.head)
				if(prob(15) && !H.head.unacidable)
					qdel(H.head)
					H.update_inv_head()
					H << "\red Your helmet melts away but protects you from the acid"
				else
					H << "\red Your helmet protects you from the acid!"
				return

			if(!H.unacidable)
				var/datum/organ/external/affecting = H.get_organ("head")
				if(affecting.take_damage(15, 0))
					H.UpdateDamageIcon()
				H.emote("scream")
		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M

			if(MK.wear_mask)
				if(!MK.wear_mask.unacidable)
					qdel (MK.wear_mask)
					MK.update_inv_wear_mask()
					MK << "\red Your mask melts away but protects you from the acid!"
				else
					MK << "\red Your mask protects you from the acid!"
				return

			if(!MK.unacidable)
				MK.take_organ_damage(min(15, volume * 4)) // same deal as sulphuric acid
	else
		if(!M.unacidable)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/datum/organ/external/affecting = H.get_organ("head")
				if(affecting.take_damage(15, 0))
					H.UpdateDamageIcon()
				H.emote("scream")
				H.status_flags |= DISFIGURED
			else
				M.take_organ_damage(min(15, volume * 4))

datum/reagent/facid/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/organ/head))
		new/obj/item/weapon/skeleton/head(O.loc)
		for(var/mob/M in viewers(5, O))
			M << "\red \the [O] melts."
		qdel(O)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				M << "\red \the [O] melts."
			qdel(O)
/datum/chemical_reaction/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	result = "facid"
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	result_amount = 4
	required_temp = 380

datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "33% chance to hit with a random amount of toxin damage, 5-10% chances to cause stunning, suffocation, or immediate heart failure."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.4

datum/reagent/initropidril/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(rand(5,10)))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M.Stun(3)
				M.Weaken(3)
			if(2)
				M.losebreath += 10
				M.adjustOxyLoss(rand(5,25))
			if(3)
				var/mob/living/carbon/human/H = M
				if(!H.heart_attack)
					H.visible_message("<span class = 'userdanger'>[H] clutches at their chest as if their heart stopped!</span>")
					H.heart_attack = 1 // rip in pepperoni
				else
					H.losebreath += 10
					H.adjustOxyLoss(rand(5,25))
	..()
	return

datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Knocks you out after 30 seconds, 7% chance to cause some oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2

datum/reagent/pancuronium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 10)
		M.Weaken(3)
	if(prob(7))
		M.losebreath += rand(3,5)
	..()
	return

datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "Puts you to sleep after 30 seconds, along with some major stamina loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.7

datum/reagent/sodium_thiopental/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 10)
		M.sleeping += 3
	M.adjustStaminaLoss(10)
	..()
	return

datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3

datum/reagent/sulfonal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 22)
		M.sleeping += 3
	M.adjustToxLoss(1)
	..()
	return

datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "On the last second that it's in you, it hits you with a stack of toxin damage based on how long it's been in you. The more you use, the longer it takes before anything happens, but the harder it hits when it does."
	reagent_state = LIQUID
	color = "#CF3600"

datum/reagent/amanitin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	..()
	return

datum/reagent/amanitin/reagent_deleted(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(current_cycle*rand(2,4))
	..()
	return

datum/reagent/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "Deals some toxin damage unless they keep eating food. Will reduce nutrition values."
	reagent_state = LIQUID
	color = "#CF3600"

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = "lipolicide"
	result = "lipolicide"
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)
	result_amount = 3

datum/reagent/lipolicide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!holder.has_reagent("nutriment"))
		M.adjustToxLoss(1)
	M.nutrition -= 10 * REAGENTS_METABOLISM
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()
	return

datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "Does moderate toxin damage and oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.05

datum/reagent/coniine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.losebreath += 5
	M.adjustToxLoss(2)
	..()
	return

datum/reagent/curare
	name = "Curare"
	id = "curare"
	description = "Does some oxygen and toxin damage, weakens you after 33 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1

datum/reagent/curare/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle >= 11)
		M.Weaken(3)
	M.adjustToxLoss(1)
	M.adjustOxyLoss(1)
	..()
	return

datum/reagent/sarin
	name = "Sarin"
	id = "sarin"
	description = "An extremely deadly neurotoxin."
	reagent_state = LIQUID
	color = "#C7C7C7"
	metabolization_rate = 0.1

/datum/chemical_reaction/sarin
	name = "sarin"
	id = "sarin"
	result = "sarin"
	required_reagents = list("chlorine" = 1, "fluorine" = 1, "hydrogen" = 1, "oxygen" = 1, "phosphorus" = 1, "fuel" = 1, "acetone" = 1, "atrazine" = 1)
	result_amount = 3
	mix_message = "The mixture yields a colorless, odorless liquid."
	required_temp = 373

datum/reagent/sarin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	M.adjustToxLoss(1)
	if(prob(20))
		M.emote(pick("twitch","drool", "quiver"))
	if(prob(10))
		M.emote("scream")
		M.drop_l_hand()
		M.drop_r_hand()
	if(prob(5))
		M.confused = max(M.confused, 3)
	if(prob(15))
		M.fakevomit()
	if(prob(2))
		M.visible_message("<span class='danger'>[M] starts having a seizure!</span>", "<span class='danger'>You have a seizure!</span>")
		M.Paralyse(5)
		M.jitteriness = 1000
	if(current_cycle >= 5)
		M.jitteriness += 10
	if(current_cycle >= 20)
		if(prob(5))
			M.emote("collapse")
	switch(current_cycle)
		if(0 to 60)
			M.adjustBrainLoss(1)
		if(61 to INFINITY)
			M.adjustBrainLoss(2)
			M.Paralyse(5)
			M.losebreath += 5
	..()
	return

datum/reagent/atrazine
	name = "Atrazine"
	id = "atrazine"
	description = "A herbicidal compound used for destroying unwanted plants."
	reagent_state = LIQUID
	color = "#17002D"

datum/reagent/atrazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(2)
	..()
	return

			// Clear off wallrot fungi
datum/reagent/atrazine/reaction_turf(var/turf/T, var/volume)
	if(istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/W = T
		if(W.rotting)
			W.rotting = 0
			for(var/obj/effect/E in W) if(E.name == "Wallrot") del E

			for(var/mob/O in viewers(W, null))
				O.show_message(text("\blue The fungi are completely dissolved by the solution!"), 1)

datum/reagent/atrazine/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/structure/alien/weeds/))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		del(O)
	else if(istype(O,/obj/effect/plantsegment))
		if(prob(50)) del(O) //Kills kudzu too.
	// Damage that is done to growing plants is separately at code/game/machinery/hydroponics at obj/item/hydroponics

datum/reagent/atrazine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.dna)
				if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
					H.adjustToxLoss(50)
					..()
					return
		if(ismonkey(M))
			var/mob/living/carbon/monkey/MO = M
			if(MO.dna)
				if(MO.dna.mutantrace == "plant") //plantmen monkeys (diona) take EVEN MORE damage
					MO.adjustToxLoss(100)
					..()
					return

/datum/chemical_reaction/atrazine
	name = "atrazine"
	id = "atrazine"
	result = "atrazine"
	required_reagents = list("chlorine" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_message = "The mixture gives off a harsh odor"