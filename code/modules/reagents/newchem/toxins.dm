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
	penetrates_skin = 1

datum/reagent/polonium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.radiation += 8
	..()
	return


datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "Immune-system neurotransmitter. If detected in blood, the subject is likely undergoing an allergic reaction."
	reagent_state = LIQUID
	color = "#E7C4C4"
	metabolization_rate = 0.2
	overdose_threshold = 30

datum/reagent/histamine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume) //dumping histamine on someone is VERY mean.
	if(iscarbon(M))
		if(method == TOUCH)
			M.reagents.add_reagent("histamine",10)

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
	description = "Formaldehyde is a common industrial chemical and is used to preserve corpses and medical samples. It is highly toxic and irritating."
	reagent_state = LIQUID
	color = "#DED6D0"
	penetrates_skin = 1

datum/reagent/formaldehyde/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	if(prob(10))
		M.reagents.add_reagent("histamine",rand(5,15))
	..()
	return

/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	required_temp = 420
	mix_message = "Ugh, it smells like the morgue in here."

datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "Will deal scaling amounts of Toxin and Brute damage over time. 25% chance to decay into 5-10 histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
	overdose_threshold = 40

datum/reagent/venom/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss((0.1*volume)*REM)
	M.adjustBruteLoss((0.1*volume)*REM)
	if(prob(25))
		M.reagents.add_reagent("histamine",rand(5,10))
	..()
	return

datum/reagent/venom/overdose_process(var/mob/living/M as mob)
	if(volume >= 40)
		if(prob(4))
			M.gib()
	..()
	return

datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "A dangerous toxin that attacks the nervous system."
	reagent_state = LIQUID
	color = "#60A584"
	metabolization_rate = 1

datum/reagent/neurotoxin2/on_mob_life(var/mob/living/M as mob)
	if(current_cycle <= 4)
		M.reagents.add_reagent("neurotoxin2", 1.0)
	if(current_cycle >= 5)
		if(prob(5))
			M.emote("drool")
		if(M.brainloss < 60)
			M.adjustBrainLoss(1*REM)
		M.adjustToxLoss(1*REM)
	if(current_cycle >= 9)
		M.drowsyness = max(M.drowsyness, 10)
	if(current_cycle >= 13)
		M.Paralyse(8)
	switch(current_cycle)
		if(5 to 45)
			M.confused = max(M.confused, 15)
	..()
	return

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	required_temp = 674
	mix_sound = null
	no_message = 1

datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical with some uses as a building block for other things."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = 1

datum/reagent/cyanide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5))
		M.emote("drool")
	M.adjustToxLoss(1.5*REM)
	if(prob(10))
		M << "<span class = 'danger'>You cannot breathe!</span>"
		M.losebreath += 1
	if(prob(8))
		M << "<span class = 'danger'>You feel horrendously weak!</span>"
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
	mix_message = "The mixture gives off a faint scent of almonds."


datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "An abrasive powder beloved by cruel pranksters."
	reagent_state = LIQUID
	color = "#B0B0B0"
	metabolization_rate = 0.3
	penetrates_skin = 1

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
	..()
	return

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "The mixture congeals and dries up, leaving behind an abrasive powder."
	mix_sound = 'sound/effects/blobattack.ogg'

datum/reagent/facid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	M.adjustFireLoss(1)
	..()
	return

datum/reagent/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive super-acid."
	reagent_state = LIQUID
	color = "#4141D2"

datum/reagent/facid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return //wooo more runtime fixin
	if(method == TOUCH || method == INGEST)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(volume < 5)
				M << "<span class = 'danger'>The blueish acidic substance stings you, but isn't concentrated enough to harm you!</span>"

			if(volume >=5 && volume <=10)
				if(!H.unacidable)
					M.take_organ_damage(max(volume-5,2)*4,0)
					M.emote("scream")


			if(volume > 10)

				if(method == TOUCH)
					if(H.wear_mask)
						if(!H.wear_mask.unacidable)
							qdel (H.wear_mask)
							H.update_inv_wear_mask()
							H << "\red Your mask melts away but protects you from the acid!"
						else
							H << "\red Your mask protects you from the acid!"
						return

					if(H.head)
						if(!H.head.unacidable)
							qdel(H.head)
							H.update_inv_head()
							H << "\red Your helmet melts away but protects you from the acid"
						else
							H << "\red Your helmet protects you from the acid!"
						return

				if(!H.unacidable)
					var/obj/item/organ/external/affecting = H.get_organ("head")
					affecting.take_damage(75, 0)
					H.UpdateDamageIcon()
					H.emote("scream")
					H.status_flags |= DISFIGURED

datum/reagent/facid/reaction_obj(var/obj/O, var/volume)
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
	mix_message = "The mixture deepens to a dark blue, and slowly begins to corrode its container."

datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "A highly potent cardiac poison - can kill within minutes."
	reagent_state = LIQUID
	color = "#7F10C0"
	metabolization_rate = 0.4

datum/reagent/initropidril/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(rand(5,10)))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M << "<span class = 'danger'>You feel horrendously weak!</span>"
				M.Stun(2)
				M.losebreath += 1
			if(2)
				M << "<span class = 'danger'>You cannot breathe!</span>"
				M.losebreath += 5
				M.adjustOxyLoss(10)
			if(3)
				var/mob/living/carbon/human/H = M
				if(!H.heart_attack)
					H.heart_attack = 1 // rip in pepperoni
	..()
	return

datum/reagent/concentrated_initro
	name = "Concentrated Initropidril"
	id = "concentrated_initro"
	description = "A guaranteed heart-stopper!"
	reagent_state = LIQUID
	color = "#AB1CCF"
	metabolization_rate = 0.4

datum/reagent/concentrated_initro/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(volume >=5)
		var/mob/living/carbon/human/H = M
		if(!H.heart_attack)
			H.heart_attack = 1 // rip in pepperoni

datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Pancuronium bromide is a powerful skeletal muscle relaxant."
	reagent_state = LIQUID
	color = "#1E4664"
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
	description = "An rapidly-acting barbituate tranquilizer."
	reagent_state = LIQUID
	color = "#5F8BE1"
	metabolization_rate = 0.7

datum/reagent/sodium_thiopental/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle == 1)
		M.emote("drool")
	if(current_cycle >= 2)
		M.drowsyness = max(M.drowsyness, 20)
	if(current_cycle >= 5)
		M.Paralyse(4)
	..()
	return

datum/reagent/ketamine
	name = "Ketamine"
	id = "ketamine"
	description = "A potent veterinary tranquilizer."
	reagent_state = LIQUID
	color = "#646EA0"
	metabolization_rate = 0.8
	penetrates_skin = 1

datum/reagent/ketamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(current_cycle <= 10)
		if(prob(20))
			M.emote("yawn")
	if(current_cycle == 6)
		M.eye_blurry = max(M.eye_blurry, 5)
	if(current_cycle >= 10)
		M.Paralyse(10)
	..()
	return

datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#6BA688"
	metabolization_rate = 0.1

/datum/chemical_reaction/sulfonal
	name = "sulfonal"
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "The mixture gives off quite a stench."

datum/reagent/sulfonal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1)
	if(current_cycle >= 11)
		M.drowsyness = max(M.drowsyness, 20)
	switch(current_cycle)
		if(0 to 10)
			if(prob(5))
				M.emote("yawn")
		if(22)
			M.emote("faint")
		if(23 to INFINITY)
			if(prob(20))
				M.emote("faint")
	..()
	return

datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "A toxin produced by certain mushrooms. Very deadly."
	reagent_state = LIQUID
	color = "#D9D9D9"

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
	description = "A compound found in many seedy dollar stores in the form of a weight-loss tonic."
	reagent_state = SOLID
	color = "#D1DED1"

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
	description = "A neurotoxin that rapidly causes respiratory failure."
	reagent_state = LIQUID
	color = "#C2D8CD"
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
	description = "A highly dangerous paralytic poison."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.1
	penetrates_skin = 1

datum/reagent/curare/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5))
		M.emote(pick("gasp","drool", "pale"))
	if(current_cycle >= 11)
		M.Weaken(15)
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
	penetrates_skin = 1

/datum/chemical_reaction/sarin
	name = "sarin"
	id = "sarin"
	result = "sarin"
	required_reagents = list("chlorine" = 1, "fluorine" = 1, "hydrogen" = 1, "oxygen" = 1, "phosphorus" = 1, "fuel" = 1, "acetone" = 1, "atrazine" = 1)
	result_amount = 3
	mix_message = "The mixture yields a colorless, odorless liquid."
	required_temp = 374

datum/reagent/sarin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
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
			M.adjustToxLoss(1)
		if(61 to INFINITY)
			M.adjustBrainLoss(2)
			M.adjustToxLoss(2)
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
				if(istype(MO,/mob/living/carbon/monkey/diona)) //plantmen monkeys (diona) take EVEN MORE damage
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

datum/reagent/capulettium
	name = "Capulettium"
	id = "capulettium"
	description = "A rare drug that causes the user to appear dead for some time."
	reagent_state = LIQUID
	color = "#60A584"

/datum/chemical_reaction/capulettium
	name = "capulettium"
	id = "capulettium"
	result = "capulettium"
	required_reagents = list("neurotoxin2" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 1
	mix_message = "The smell of death wafts up from the solution."

datum/reagent/capulettium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.eye_blurry = max(M.eye_blurry, 2)
	if(current_cycle == 12)
		M.emote("deathgasp")
		M.Paralyse(10)
	..()
	return

datum/reagent/capulettium_plus
	name = "Capulettium Plus"
	id = "capulettium_plus"
	description = "A rare and expensive drug that causes the user to appear dead for some time while they retain consciousness and vision."
	reagent_state = LIQUID
	color = "#60A584"

/datum/chemical_reaction/capulettium_plus
	name = "capulettium_plus"
	id = "capulettium_plus"
	result = "capulettium_plus"
	required_reagents = list("capulettium" = 1, "ephedrine" = 1, "methamphetamine" = 1)
	result_amount = 3
	mix_message = "The solution begins to slosh about violently by itself."

datum/reagent/capulettium_plus/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.silent += REM + 1
	..()
	return

datum/reagent/toxic_slurry
	name = "Toxic Slurry"
	id = "toxic_slurry"
	description = "A filthy, carcinogenic sludge produced by the Slurrypod plant."
	reagent_state = LIQUID
	color = "#00C81E"

datum/reagent/toxic_slurry/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(10))
		M.adjustToxLoss(rand(2,4))
	if(prob(7))
		switch(pick(1,2))
			if(1)
				M.fakevomit(1)
			if(2)
				M.Stun(rand(4,10))
				M << "<span class='warning'>A horrible migraine overpowers you.</span>"
	..()
	return

datum/reagent/glowing_slurry
	name = "Glowing Slurry"
	id = "glowing_slurry"
	description = "This is probably not good for you."
	reagent_state = LIQUID
	color = "#00FD00"

datum/reagent/glowing_slurry/reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //same as mutagen
	if(!..())	return
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	src = null
	if((method==TOUCH && prob(33)) || method==INGEST)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		M.UpdateAppearance()
	return

datum/reagent/glowing_slurry/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.apply_effect(2*REM,IRRADIATE,0)
	if(prob(15))
		randmutb(M)
	if(prob(5))
		randmutg(M)
	domutcheck(M, null)
	M.UpdateAppearance()
	..()
	return

datum/reagent/ants
	name = "Ants"
	id = "ants"
	description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
	reagent_state = SOLID
	color = "#993333"

datum/reagent/ants/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume) //NOT THE ANTS
	if(iscarbon(M))
		if(method == TOUCH || method==INGEST)
			M.adjustBruteLoss(4)
			M.emote("scream")
			M << "<span class='warning'>OH SHIT ANTS!!!!</span>"


datum/reagent/ants/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustBruteLoss(2)
	..()
	return