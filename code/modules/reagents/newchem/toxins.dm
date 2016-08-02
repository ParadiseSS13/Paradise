#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = 1

/datum/reagent/polonium/on_mob_life(mob/living/M)
	M.apply_effect(8, IRRADIATE, negate_armor = 1)
	..()


/datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "Immune-system neurotransmitter. If detected in blood, the subject is likely undergoing an allergic reaction."
	reagent_state = LIQUID
	color = "#E7C4C4"
	metabolization_rate = 0.2
	overdose_threshold = 40

/datum/reagent/histamine/reaction_mob(mob/living/M, method=TOUCH, volume) //dumping histamine on someone is VERY mean.
	if(iscarbon(M))
		if(method == TOUCH)
			M.reagents.add_reagent("histamine",10)
		else
			to_chat(M, "<span class='danger'>You feel a burning sensation in your throat...</span>")
			M.emote("drool")

/datum/reagent/histamine/on_mob_life(mob/living/M)
	if(prob(20))
		M.emote(pick("twitch", "grumble", "sneeze", "cough"))
	if(prob(10))
		to_chat(M, "<span class='notice'>Your eyes itch.</span>")
		M.emote(pick("blink", "sneeze"))
		M.eye_blurry += 3
	if(prob(10))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		M.adjustBruteLoss(1)
		M.emote("grumble")
	if(prob(5))
		to_chat(M, "<span class='danger'>You're getting a rash!</span>")
		M.adjustBruteLoss(2)
	..()

/datum/reagent/histamine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			to_chat(M, "<span class='warning'>You feel mucus running down the back of your throat.</span>")
			M.adjustToxLoss(1)
			M.Jitter(4)
			M.emote(pick("sneeze", "cough"))
		else if(effect <= 4)
			M.stuttering += rand(0,5)
			if(prob(25))
				M.emote(pick("choke","gasp"))
				M.adjustOxyLoss(5)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your chest hurts!</span>")
			M.emote(pick("cough","gasp"))
			M.adjustOxyLoss(3)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] breaks out in hives!</span>")
			M.adjustBruteLoss(6)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] has a horrible coughing fit!</span>")
			M.Jitter(10)
			M.stuttering += rand(0,5)
			M.emote("cough")
			if(prob(40))
				M.emote(pick("choke","gasp"))
				M.adjustOxyLoss(6)
			M.Weaken(8)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your heartbeat is pounding inside your head!</span>")
			M << 'sound/effects/singlebeat.ogg'
			M.emote("collapse")
			M.adjustOxyLoss(8)
			M.adjustToxLoss(3)
			M.Weaken(3)
			M.emote(pick("choke", "gasp"))
			to_chat(M, "<span class='warning'>You feel like you're dying!</span>")

/datum/reagent/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Formaldehyde is a common industrial chemical and is used to preserve corpses and medical samples. It is highly toxic and irritating."
	reagent_state = LIQUID
	color = "#DED6D0"
	penetrates_skin = 1

/datum/reagent/formaldehyde/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	if(prob(10))
		M.reagents.add_reagent("histamine",rand(5,15))
	..()

/datum/chemical_reaction/formaldehyde
	name = "formaldehyde"
	id = "formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	min_temp = 420
	mix_message = "Ugh, it smells like the morgue in here."

/datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "An incredibly potent poison. Origin unknown."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
	overdose_threshold = 40

/datum/reagent/venom/on_mob_life(mob/living/M)
	if(prob(25))
		M.reagents.add_reagent("histamine",rand(5,10))
	if(volume < 20)
		M.adjustToxLoss(1)
		M.adjustBruteLoss(1)
	else if(volume < 40)
		if(prob(8))
			M.fakevomit()
		M.adjustToxLoss(2)
		M.adjustBruteLoss(2)
	..()

/datum/reagent/venom/overdose_process(mob/living/M)
	if(volume >= 40)
		if(prob(4))
			M.visible_message("<span class='danger'><B>[M]</B> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
			M.Weaken(15)
			M.jitteriness += 1000
			spawn(rand(20, 100))
				M.gib()

/datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "A dangerous toxin that attacks the nervous system."
	reagent_state = LIQUID
	color = "#60A584"
	metabolization_rate = 1

/datum/reagent/neurotoxin2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 4)
			current_cycle++
			return
		if(5 to 8)
			M.dizziness += 1
			M.confused = max(M.confused, 10)
		if(9 to 12)
			M.drowsyness  = max(M.drowsyness, 10)
			M.dizziness += 1
			M.confused = max(M.confused, 20)
		if(13)
			M.emote("faint")
		if(14 to INFINITY)
			M.Paralyse(10)
			M.drowsyness  = max(M.drowsyness, 20)

	M.jitteriness = max(0, M.jitteriness-30)
	if(M.getBrainLoss() <= 80)
		M.adjustBrainLoss(1)
	else
		if(prob(10))
			M.adjustBrainLoss(1)
	if(prob(10))
		M.emote("drool")
	M.adjustToxLoss(1)
	..()

/datum/chemical_reaction/neurotoxin2
	name = "neurotoxin2"
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	min_temp = 674
	mix_sound = null
	no_message = 1

/datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical with some uses as a building block for other things."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = 1

/datum/reagent/cyanide/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5*REM)
	if(prob(5))
		M.emote("drool")
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.losebreath += 1
		M.emote("gasp")
	if(prob(8))
		to_chat(M, "<span class='danger'>You feel horrendously weak!</span>")
		M.Stun(2)
		M.adjustToxLoss(2)
	..()

/datum/chemical_reaction/cyanide
	name = "Cyanide"
	id = "cyanide"
	result = "cyanide"
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	result_amount = 3
	min_temp = 380
	mix_message = "The mixture gives off a faint scent of almonds."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cyanide/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("cyanide", 7)

/datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "An abrasive powder beloved by cruel pranksters."
	reagent_state = LIQUID
	color = "#B0B0B0"
	metabolization_rate = 0.3
	penetrates_skin = 1

/datum/reagent/itching_powder/on_mob_life(mob/living/M)
	if(prob(25))
		M.emote(pick("twitch", "laugh", "sneeze", "cry"))
	if(prob(20))
		to_chat(M, "<span class='notice'>Something tickles!</span>")
		M.emote(pick("laugh", "giggle"))
	if(prob(15))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		M.adjustBruteLoss(1)
		M.Stun(rand(0,1))
		M.emote("grumble")
	if(prob(10))
		to_chat(M, "<span class='danger'>So itchy!</span>")
		M.adjustBruteLoss(2)
	if(prob(6))
		M.reagents.add_reagent("histamine", rand(1,3))
	if(prob(2))
		to_chat(M, "<span class='danger'>AHHHHHH!</span>")
		M.adjustBruteLoss(5)
		M.Weaken(5)
		M.jitteriness += 6
		M.visible_message("<span class='danger'>[M] falls to the floor, scratching themselves violently!</span>")
		M.emote("scream")
	..()

/datum/chemical_reaction/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "The mixture congeals and dries up, leaving behind an abrasive powder."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/reagent/facid/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM)
	M.adjustFireLoss(1)
	..()

/datum/reagent/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive super-acid."
	reagent_state = LIQUID
	color = "#4141D2"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/facid/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH || method == INGEST)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(volume < 5)
				to_chat(M, "<span class='danger'>The blueish acidic substance stings you, but isn't concentrated enough to harm you!</span>")

			if(volume >=5 && volume <=10)
				if(!H.unacidable)
					M.take_organ_damage(0,max(volume-5,2)*4)
					M.emote("scream")


			if(volume > 10)

				if(method == TOUCH)
					if(H.wear_mask)
						if(!H.wear_mask.unacidable)
							qdel(H.wear_mask)
							H.update_inv_wear_mask()
							to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
						else
							to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
						return

					if(H.head)
						if(!H.head.unacidable)
							qdel(H.head)
							H.update_inv_head()
							to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
						else
							to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
						return

				if(!H.unacidable)
					var/obj/item/organ/external/affecting = H.get_organ("head")
					affecting.take_damage(0, 75)
					H.UpdateDamageIcon()
					H.emote("scream")
					H.status_flags |= DISFIGURED

/datum/reagent/facid/reaction_obj(obj/O, volume)
	if((istype(O, /obj/item) || istype(O, /obj/effect/glowshroom)))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			O.visible_message("<span class='warning'>[O] melts.</span>")
			qdel(O)

/datum/chemical_reaction/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	result = "facid"
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	result_amount = 4
	min_temp = 380
	mix_message = "The mixture deepens to a dark blue, and slowly begins to corrode its container."

/datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "A highly potent cardiac poison - can kill within minutes."
	reagent_state = LIQUID
	color = "#7F10C0"
	metabolization_rate = 0.4

/datum/reagent/initropidril/on_mob_life(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(33))
		to_chat(M, "<span class='danger'>You feel horribly weak.</span>")
		M.Stun(2)
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.adjustOxyLoss(10)
		M.losebreath++
	if(prob(10))
		to_chat(M, "<span class='danger'>Your chest is burning with pain!</span>")
		M.adjustOxyLoss(10)
		M.losebreath++
		M.Stun(3)
		M.Weaken(2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.heart_attack)
				H.heart_attack = 1 // rip in pepperoni
	..()

/datum/chemical_reaction/initropidril
	name = "Initropidril"
	id = "initropidril"
	result = "initropidril"
	required_reagents = list("crank" = 1, "histamine" = 1, "krokodil" = 1, "bath_salts" = 1, "atropine" = 1, "nicotine" = 1, "morphine" = 1)
	result_amount = 4
	mix_message = "A sweet and sugary scent drifts from the unpleasant milky substance."


/datum/reagent/concentrated_initro
	name = "Concentrated Initropidril"
	id = "concentrated_initro"
	description = "A guaranteed heart-stopper!"
	reagent_state = LIQUID
	color = "#AB1CCF"
	metabolization_rate = 0.4

/datum/reagent/concentrated_initro/on_mob_life(mob/living/M)
	if(volume >=5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.heart_attack)
				H.heart_attack = 1 // rip in pepperoni

/datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Pancuronium bromide is a powerful skeletal muscle relaxant."
	reagent_state = LIQUID
	color = "#1E4664"
	metabolization_rate = 0.2

/datum/reagent/pancuronium/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			if(prob(10))
				M.emote(pick("drool", "tremble"))
		if(6 to 10)
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				M.Stun(1)
			else if(prob(8))
				M.emote(pick("drool", "tremble"))
		if(11 to INFINITY)
			M.Stun(20)
			M.Weaken(20)
			if(prob(10))
				M.emote(pick("drool", "tremble", "gasp"))
				M.losebreath++
			if(prob(9))
				to_chat(M, "<span class='danger'>You can't [pick("move", "feel your legs", "feel your face", "feel anything")]!</span>")
			if(prob(7))
				to_chat(M, "<span class='danger'>You can't breathe!</span>")
				M.losebreath += 3
	..()

/datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "An rapidly-acting barbituate tranquilizer."
	reagent_state = LIQUID
	color = "#5F8BE1"
	metabolization_rate = 0.7

/datum/reagent/sodium_thiopental/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1)
			M.emote("drool")
			M.confused = max(M.confused, 5)
		if(2 to 4)
			M.drowsyness = max(M.drowsyness, 20)
		if(5)
			M.emote("faint")
			M.Weaken(5)
		if(6 to INFINITY)
			M.Paralyse(20)
	M.jitteriness = max(0, M.jitteriness-50)
	if(prob(10))
		M.emote("drool")
		M.adjustBrainLoss(1)
	..()

/datum/reagent/ketamine
	name = "Ketamine"
	id = "ketamine"
	description = "A potent veterinary tranquilizer."
	reagent_state = LIQUID
	color = "#646EA0"
	metabolization_rate = 0.8
	penetrates_skin = 1

/datum/reagent/ketamine/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			if(prob(25))
				M.emote("yawn")
		if(6 to 9)
			M.eye_blurry += 5
			if(prob(35))
				M.emote("yawn")
		if(10)
			M.emote("faint")
			M.Weaken(5)
		if(11 to INFINITY)
			M.Paralyse(25)
	..()

/datum/reagent/sulfonal
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
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/sulfonal/on_mob_life(mob/living/M)
	M.jitteriness = max(0, M.jitteriness-30)
	switch(current_cycle)
		if(1 to 10)
			if(prob(7))
				M.emote("yawn")
		if(11 to 20)
			M.drowsyness  = max(M.drowsyness, 20)
		if(21)
			M.emote("faint")
		if(22 to INFINITY)
			if(prob(20))
				M.emote("faint")
				M.Paralyse(5)
			M.drowsyness  = max(M.drowsyness, 20)
	M.adjustToxLoss(1)
	..()

/datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "A toxin produced by certain mushrooms. Very deadly."
	reagent_state = LIQUID
	color = "#D9D9D9"

/datum/reagent/amanitin/reagent_deleted(mob/living/M)
	M.adjustToxLoss(current_cycle*rand(2,4))
	..()

/datum/reagent/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "A compound found in many seedy dollar stores in the form of a weight-loss tonic."
	reagent_state = SOLID
	color = "#D1DED1"
	metabolization_rate = 0.2

/datum/chemical_reaction/lipolicide
	name = "lipolicide"
	id = "lipolicide"
	result = "lipolicide"
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)
	result_amount = 3

/datum/reagent/lipolicide/on_mob_life(mob/living/M)
	if(!M.nutrition)
		switch(rand(1,3))
			if(1)
				to_chat(M, "<span class='warning'>You feel hungry...</span>")
			if(2)
				M.adjustToxLoss(1)
				to_chat(M, "<span class='warning'>Your stomach grumbles painfully!</span>")
	else
		if(prob(60))
			var/fat_to_burn = max(round(M.nutrition/100,1), 5)
			M.nutrition = max(0, M.nutrition-fat_to_burn)
			M.overeatduration = 0
	..()

/datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "A neurotoxin that rapidly causes respiratory failure."
	reagent_state = LIQUID
	color = "#C2D8CD"
	metabolization_rate = 0.05

/datum/reagent/coniine/on_mob_life(mob/living/M)
	M.adjustToxLoss(2)
	M.losebreath += 5
	..()

/datum/reagent/curare
	name = "Curare"
	id = "curare"
	description = "A highly dangerous paralytic poison."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.1
	penetrates_skin = 1

/datum/reagent/curare/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	M.adjustOxyLoss(1)
	switch(current_cycle)
		if(1 to 5)
			if(prob(20))
				M.emote(pick("drool", "pale", "gasp"))
		if(6 to 10)
			M.eye_blurry += 5
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				M.Stun(1)
			else if(prob(8))
				M.emote(pick("drool","pale", "gasp"))
		if(11 to INFINITY)
			M.Stun(30)
			M.drowsyness  = max(M.drowsyness, 20)
			if(prob(20))
				M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
			else if(prob(8))
				to_chat(M, "<span class='danger'>You can't [pick("breathe", "move", "feel your legs", "feel your face", "feel anything")]!</span>")
				M.losebreath++
	..()

/datum/reagent/sarin
	name = "Sarin"
	id = "sarin"
	description = "An extremely deadly neurotoxin."
	reagent_state = LIQUID
	color = "#C7C7C7"
	metabolization_rate = 0.1
	penetrates_skin = 1
	overdose_threshold = 25

/datum/chemical_reaction/sarin
	name = "sarin"
	id = "sarin"
	result = "sarin"
	required_reagents = list("chlorine" = 1, "fuel" = 1, "oxygen" = 1, "phosphorus" = 1, "fluorine" = 1, "hydrogen" = 1, "acetone" = 1, "atrazine" = 1)
	result_amount = 3
	mix_message = "The mixture yields a colorless, odorless liquid."
	min_temp = 374
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sarin/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 2))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("sarin", 4)

/datum/reagent/sarin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.jitteriness += 20
			if(prob(20))
				M.emote(pick("twitch","twitch_s","quiver"))
		if(16 to 30)
			if(prob(25))
				M.emote(pick("twitch","twitch","drool","quiver","tremble"))
			M.eye_blurry += 5
			M.stuttering = max(M.stuttering, 5)
			if(prob(10))
				M.confused = max(M.confused, 15)
			if(prob(15))
				M.Stun(1)
				M.emote("scream")
		if(30 to 60)
			M.eye_blurry += 5
			M.stuttering = max(M.stuttering, 5)
			if(prob(10))
				M.Stun(1)
				M.emote(pick("twitch","twitch","drool","shake","tremble"))
			if(prob(5))
				M.emote("collapse")
			if(prob(5))
				M.Weaken(3)
				M.visible_message("<span class='warning'>[M] has a seizure!</span>")
				M.jitteriness = 1000
			if(prob(5))
				to_chat(M, "<span class='warning'>You can't breathe!</span>")
				M.emote(pick("gasp", "choke", "cough"))
				M.losebreath++
		if(61 to INFINITY)
			if(prob(15))
				M.emote(pick("gasp", "choke", "cough","twitch", "shake", "tremble","quiver","drool", "twitch","collapse"))
			M.losebreath = max(5, M.losebreath + 5)
			M.adjustToxLoss(1)
			M.adjustBrainLoss(1)
			M.Weaken(4)
	if(prob(8))
		M.fakevomit()
	M.adjustToxLoss(1)
	M.adjustBrainLoss(1)
	M.adjustFireLoss(1)
	..()

/datum/reagent/atrazine
	name = "Atrazine"
	id = "atrazine"
	description = "A herbicidal compound used for destroying unwanted plants."
	reagent_state = LIQUID
	color = "#17002D"

/datum/reagent/atrazine/on_mob_life(mob/living/M)
	M.adjustToxLoss(2)
	..()

			// Clear off wallrot fungi
/datum/reagent/atrazine/reaction_turf(turf/simulated/wall/W, volume)
	if(istype(W) && W.rotting)
		W.rotting = 0
		for(var/obj/effect/overlay/O in W)
			if(O.name == "Wallrot") // This is so awful
				qdel(O)

		W.visible_message("<span class='warning'>The fungi are completely dissolved by the solution!</span>")

/datum/reagent/atrazine/reaction_obj(obj/O, volume)
	if(istype(O,/obj/structure/alien/weeds/))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O, /obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plant))
		if(prob(50))
			qdel(O) //Kills kudzu too.
	// Damage that is done to growing plants is separately at code/game/machinery/hydroponics at obj/item/hydroponics

/datum/reagent/atrazine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 2 toxic damage per application
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
				H.adjustToxLoss(50)
				..()
	else if(istype(M, /mob/living/simple_animal/diona)) //plantmen monkeys (diona) take EVEN MORE damage
		var/mob/living/simple_animal/diona/D = M
		D.adjustHealth(100)
		..()

/datum/chemical_reaction/atrazine
	name = "atrazine"
	id = "atrazine"
	result = "atrazine"
	required_reagents = list("chlorine" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_message = "The mixture gives off a harsh odor"

/datum/reagent/capulettium
	name = "Capulettium"
	id = "capulettium"
	description = "A rare drug that causes the user to appear dead for some time."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1

/datum/chemical_reaction/capulettium
	name = "capulettium"
	id = "capulettium"
	result = "capulettium"
	required_reagents = list("neurotoxin2" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 1
	mix_message = "The smell of death wafts up from the solution."

/datum/reagent/capulettium/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			M.eye_blurry += 10
		if(6 to 10)
			M.drowsyness  = max(M.drowsyness, 10)
		if(11)
			M.Paralyse(10)
			M.visible_message("<B>[M]</B> seizes up and falls limp, their eyes dead and lifeless...") //so you can't trigger deathgasp emote on people. Edge case, but necessary.
		if(12 to 60)
			M.Paralyse(10)
		if(61 to INFINITY)
			M.eye_blurry += 10
	..()

/datum/reagent/capulettium_plus
	name = "Capulettium Plus"
	id = "capulettium_plus"
	description = "A rare and expensive drug that causes the user to appear dead for some time while they retain consciousness and vision."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1

/datum/chemical_reaction/capulettium_plus
	name = "capulettium_plus"
	id = "capulettium_plus"
	result = "capulettium_plus"
	required_reagents = list("capulettium" = 1, "ephedrine" = 1, "methamphetamine" = 1)
	result_amount = 3
	mix_message = "The solution begins to slosh about violently by itself."

/datum/reagent/capulettium_plus/on_mob_life(mob/living/M)
	M.silent = max(M.silent, 2)
	..()

/datum/reagent/toxic_slurry
	name = "Toxic Slurry"
	id = "toxic_slurry"
	description = "A filthy, carcinogenic sludge produced by the Slurrypod plant."
	reagent_state = LIQUID
	color = "#00C81E"

/datum/reagent/toxic_slurry/on_mob_life(mob/living/M)
	if(prob(10))
		M.adjustToxLoss(rand(2.4))
	if(prob(7))
		to_chat(M, "<span class='danger'>A horrible migraine overpowers you.</span>")
		M.Stun(rand(2,5))
	if(prob(7))
		M.fakevomit(1)
	..()

/datum/reagent/glowing_slurry
	name = "Glowing Slurry"
	id = "glowing_slurry"
	description = "This is probably not good for you."
	reagent_state = LIQUID
	color = "#00FD00"

/datum/reagent/glowing_slurry/reaction_mob(mob/living/M, method=TOUCH, volume) //same as mutagen
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==TOUCH && prob(50)) || method==INGEST)
		randmutb(M)
		domutcheck(M, null)
		M.UpdateAppearance()

/datum/reagent/glowing_slurry/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE, 0, negate_armor = 1)
	if(!M.dna)
		return
	if(prob(15))
		randmutb(M)
	if(prob(3))
		randmutg(M)
	domutcheck(M, null)
	M.UpdateAppearance()
	..()

/datum/reagent/ants
	name = "Ants"
	id = "ants"
	description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
	reagent_state = SOLID
	color = "#993333"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/ants/reaction_mob(mob/living/M, method=TOUCH, volume) //NOT THE ANTS
	if(iscarbon(M))
		if(method == TOUCH || method==INGEST)
			to_chat(M, "<span class='warning'>OH SHIT ANTS!!!!</span>")
			M.emote("scream")
			M.adjustBruteLoss(4)


/datum/reagent/ants/on_mob_life(mob/living/M)
	M.adjustBruteLoss(2)
	..()

/datum/reagent/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Teslium"
	id = "teslium"
	description = "An unstable, electrically-charged metallic slurry. Increases the conductance of living things."
	reagent_state = LIQUID
	color = "#20324D" //RGB: 32, 50, 77
	metabolization_rate = 0.2
	var/shock_timer = 0
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/teslium/on_mob_life(mob/living/M)
	shock_timer++
	if(shock_timer >= rand(5,30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		M.electrocute_act(rand(5,20), "Teslium in their body", 1, 1) //Override because it's caused from INSIDE of you
		playsound(M, "sparks", 50, 1)
	..()

/datum/chemical_reaction/teslium
	name = "Teslium"
	id = "teslium"
	result = "teslium"
	required_reagents = list("plasma" = 1, "silver" = 1, "blackpowder" = 1)
	result_amount = 3
	mix_message = "<span class='danger'>A jet of sparks flies from the mixture as it merges into a flickering slurry.</span>"
	min_temp = 400
	mix_sound = null

/datum/chemical_reaction/teslium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(6, 1, location)
	s.start()