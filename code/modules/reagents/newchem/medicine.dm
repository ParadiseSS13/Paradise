#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

datum/reagent/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "This antibacterial compound is used to treat burn victims."
	reagent_state = LIQUID
	color = "#F0C814"
	metabolization_rate = 3

datum/reagent/silver_sulfadiazine/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(iscarbon(M))
		if(method == TOUCH)
			M.adjustFireLoss(-volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The silver sulfadiazine soothes your burns.</span>")
		if(method == INGEST)
			M.adjustToxLoss(0.5*volume)
			if(show_message)
				to_chat(M, "<span class='warning'>You feel sick...</span>")
	..()
	return

datum/reagent/silver_sulfadiazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(-2*REM)
	..()
	return

datum/reagent/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "Styptic (aluminium sulfate) powder helps control bleeding and heal physical wounds."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 3

datum/reagent/styptic_powder/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume, var/show_message = 1)
	if(iscarbon(M))
		if(method == TOUCH)
			M.adjustBruteLoss(-volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The styptic powder stings like hell as it closes some of your wounds!</span>")
			M.emote("scream")
		if(method == INGEST)
			M.adjustToxLoss(0.5*volume)
			if(show_message)
				to_chat(M, "<span class='warning'>You feel gross!</span>")
	..()
	return

datum/reagent/styptic_powder/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustBruteLoss(-2*REM)
	..()
	return

datum/reagent/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	description = "This saline and glucose solution can help stabilize critically injured patients and cleanse wounds."
	reagent_state = LIQUID
	color = "#C8A5DC"
	penetrates_skin = 1
	metabolization_rate = 0.15

datum/reagent/salglu_solution/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(33))
		M.adjustBruteLoss(-2*REM)
		M.adjustFireLoss(-2*REM)
	..()
	return

datum/reagent/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	description = "A resorbable microfibrillar collagen and protein mixture that can rapidly heal injuries when applied topically."
	reagent_state = LIQUID
	color = "#FFEBEB"

datum/reagent/synthflesh/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume,var/show_message = 1)
	if(!M) M = holder.my_atom
	if(iscarbon(M))
		if(method == TOUCH)
			M.adjustBruteLoss(-1.5*volume)
			M.adjustFireLoss(-1.5*volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>")
	..()
	return

datum/reagent/synthflesh/reaction_turf(var/turf/T, var/volume) //let's make a mess!
	src = null
	if(volume >= 5)
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)
		return

datum/reagent/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Activated charcoal helps to absorb toxins."
	reagent_state = LIQUID
	color = "#000000"

datum/reagent/charcoal/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1.5*REM)
	if(prob(50))
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
	..()
	return

/datum/chemical_reaction/charcoal
	name = "Charcoal"
	id = "charcoal"
	result = "charcoal"
	required_reagents = list("ash" = 1, "sodiumchloride" = 1)
	result_amount = 2
	mix_message = "The mixture yields a fine black powder."
	min_temp = 380
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	result = "silver_sulfadiazine"
	required_reagents = list("ammonia" = 1, "silver" = 1, "sulfur" = 1, "oxygen" = 1, "chlorine" = 1)
	result_amount = 5
	mix_message = "A strong and cloying odor begins to bubble from the mixture."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	result = "salglu_solution"
	required_reagents = list("sodiumchloride" = 1, "water" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	result = "synthflesh"
	required_reagents = list("blood" = 1, "carbon" = 1, "styptic_powder" = 1)
	result_amount = 3
	mix_message = "The mixture knits together into a fibrous, bloody mass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	result = "styptic_powder"
	required_reagents = list("aluminum" = 1, "hydrogen" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 4
	mix_message = "The solution yields an astringent powder."

datum/reagent/omnizine
	name = "Omnizine"
	id = "omnizine"
	description = "Omnizine is a highly potent healing medication that can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	overdose_threshold = 30
	addiction_chance = 5

/datum/reagent/omnizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1*REM)
	M.adjustOxyLoss(-1*REM)
	M.adjustBruteLoss(-2*REM)
	M.adjustFireLoss(-2*REM)
	if(prob(50))
		M.losebreath -= 1
	..()
	return

/datum/reagent/omnizine/overdose_process(var/mob/living/M as mob, severity)
	var/effect = ..()
	if(severity == 1) //lesser
		M.stuttering += 1
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly cluches their gut!</span>")
			M.emote("scream")
			M.Stun(4)
			M.Weaken(4)
		else if(effect <= 3)
			M.visible_message("<span class='warning'>[M] completely spaces out for a moment.</span>")
			M.confused += 15
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] stumbles and staggers.</span>")
			M.Dizzy(5)
			M.Weaken(3)
		else if(effect <= 7)
			M.visible_message("<span class='warning'>[M] shakes uncontrollably.</span>")
			M.Jitter(30)
	else if(severity == 2) // greater
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly cluches their gut!</span>")
			M.emote("scream")
			M.Stun(7)
			M.Weaken(7)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] jerks bolt upright, then collapses!</span>")
			M.Paralyse(5)
			M.Weaken(4)
		else if(effect <= 8)
			M.visible_message("<span class='warning'>[M] stumbles and staggers.</span>")
			M.Dizzy(5)
			M.Weaken(3)

datum/reagent/calomel
	name = "Calomel"
	id = "calomel"
	description = "This potent purgative rids the body of impurities. It is highly toxic however and close supervision is required."
	reagent_state = LIQUID
	color = "#22AB35"
	metabolization_rate = 0.8

datum/reagent/calomel/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		M.adjustToxLoss(5*REM)
	if(prob(6))
		M.fakevomit()
	..()
	return

/datum/chemical_reaction/calomel
	name = "Calomel"
	id = "calomel"
	result = "calomel"
	required_reagents = list("mercury" = 1, "chlorine" = 1)
	result_amount = 2
	min_temp = 374
	mix_message = "Stinging vapors rise from the solution."

datum/reagent/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning."
	reagent_state = LIQUID
	color = "#B4DCBE"

datum/reagent/potass_iodide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(80))
		M.radiation = max(0, M.radiation-1)
	..()
	return

/datum/chemical_reaction/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	result = "potass_iodide"
	required_reagents = list("potassium" = 1, "iodine" = 1)
	result_amount = 2
	mix_message = "The solution settles calmly and emits gentle fumes."

datum/reagent/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Pentetic Acid is an aggressive chelation agent. May cause tissue damage. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/pen_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
	M.radiation = max(0, M.radiation-7)
	if(prob(75))
		M.adjustToxLoss(-4*REM)
	if(prob(33))
		M.adjustBruteLoss(1*REM)
		M.adjustFireLoss(1*REM)
	..()
	return

/datum/chemical_reaction/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	result = "pen_acid"
	required_reagents = list("fuel" = 1, "chlorine" = 1, "ammonia" = 1, "formaldehyde" = 1, "sodium" = 1, "cyanide" = 1)
	result_amount = 6
	mix_message = "The substance becomes very still, emitting a curious haze."

datum/reagent/sal_acid
	name = "Salicylic Acid"
	id = "sal_acid"
	description = "This is a is a standard salicylate pain reliever and fever reducer."
	reagent_state = LIQUID
	color = "#B3B3B3"
	metabolization_rate = 0.1
	shock_reduction = 25
	overdose_threshold = 25

datum/reagent/sal_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(55))
		M.adjustBruteLoss(-2*REM)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()
	return

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	result = "sal_acid"
	required_reagents = list("sodium" = 1, "phenol" = 1, "carbon" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "The mixture crystallizes."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

datum/reagent/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.2

datum/reagent/salbutamol/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-6*REM)
	M.losebreath = max(0, M.losebreath-4)
	..()
	return

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	result = "salbutamol"
	required_reagents = list("sal_acid" = 1, "lithium" = 1, "aluminum" = 1, "bromine" = 1, "ammonia" = 1)
	result_amount = 5
	mix_message = "The solution bubbles freely, creating a head of bluish foam."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

datum/reagent/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	addiction_chance = 20

datum/reagent/perfluorodecalin/on_mob_life(var/mob/living/carbon/human/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-25*REM)
	if(volume >= 4)
		M.losebreath = max(M.losebreath, 6)
		M.silent = max(M.silent, 6)
	if(prob(33))
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	..()
	return

/datum/chemical_reaction/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	result = "perfluorodecalin"
	required_reagents = list("hydrogen" = 1, "fluorine" = 1, "oil" = 1)
	result_amount = 3
	min_temp = 370
	mix_message = "The mixture rapidly turns into a dense pink liquid."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Ephedrine is a plant-derived stimulant."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.3
	overdose_threshold = 35
	addiction_chance = 25

/datum/reagent/ephedrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness = max(0, M.drowsyness-5)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REM)
	if(M.losebreath > 5)
		M.losebreath = max(5, M.losebreath-1)
	if(M.oxyloss > 75)
		M.adjustOxyLoss(-1)
	if(M.health < 0 || M.health > 0 && prob(33))
		M.adjustToxLoss(-1)
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()
	return

/datum/reagent/ephedrine/overdose_process(var/mob/living/M as mob, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.emote("collapse")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M.name] staggers and drools, their eyes bloodshot!</span>")
			M.Dizzy(2)
			M.Weaken(3)
		if(effect <= 15)
			M.emote("collapse")

/datum/chemical_reaction/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	result = "ephedrine"
	required_reagents = list("sugar" = 1, "oil" = 1, "hydrogen" = 1, "diethylamine" = 1)
	result_amount = 4
	mix_message = "The solution fizzes and gives off toxic fumes."

datum/reagent/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Anti-allergy medication. May cause drowsiness, do not operate heavy machinery while using this."
	reagent_state = LIQUID
	color = "#5BCBE1"
	addiction_chance = 10

datum/reagent/diphenhydramine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.jitteriness = max(0, M.jitteriness-20)
	M.reagents.remove_reagent("histamine",3)
	M.reagents.remove_reagent("itching_powder",3)
	if(prob(7))
		M.emote("yawn")
	if(prob(3))
		M.Stun(2)
		M.drowsyness += 1
		M.visible_message("<span class='notice'>[M] looks a bit dazed.</span>")
	..()
	return

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	result = "diphenhydramine"
	required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
	result_amount = 4
	mix_message = "The mixture fizzes gently."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

datum/reagent/morphine
	name = "Morphine"
	id = "morphine"
	description = "A strong but highly addictive opiate painkiller with sedative side effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 20
	addiction_chance = 50
	shock_reduction = 50

datum/reagent/morphine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.jitteriness = max(0, M.jitteriness-25)
	switch(current_cycle)
		if(1 to 15)
			if(prob(7))
				M.emote("yawn")
		if(16 to 35)
			M.drowsyness = max(M.drowsyness, 20)
		if(36 to INFINITY)
			M.Paralyse(15)
			M.drowsyness = max(M.drowsyness, 20)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()
	return

datum/reagent/oculine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(80))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.damage = max(E.damage-1, 0)
		M.eye_blurry = max(M.eye_blurry-1 , 0)
		M.ear_damage = max(M.ear_damage-1, 0)
	if(prob(50))
		M.disabilities &= ~NEARSIGHTED
	if(prob(30))
		M.sdisabilities &= ~BLIND
		M.eye_blind = 0
	if(M.ear_damage <= 25)
		if(prob(30))
			M.ear_deaf = 0
	..()
	return

/datum/chemical_reaction/oculine
	name = "Oculine"
	id = "oculine"
	result = "oculine"
	required_reagents = list("atropine" = 1, "spaceacillin" = 1, "salglu_solution" = 1)
	result_amount = 3
	mix_message = "The mixture settles, becoming a milky white."

datum/reagent/oculine
	name = "Oculine"
	id = "oculine"
	description = "Oculine is a saline eye medication with mydriatic and antibiotic effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.4
	var/cycle_amount = 0

datum/reagent/atropine
	name = "Atropine"
	id = "atropine"
	description = "Atropine is a potent cardiac resuscitant but it can causes confusion, dizzyness and hyperthermia."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.2
	overdose_threshold = 25

datum/reagent/atropine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.dizziness += 1
	M.confused = max(M.confused, 5)
	if(prob(4))
		M.emote("collapse")
	if(M.losebreath > 5)
		M.losebreath = max(5, M.losebreath-5)
	if(M.oxyloss > 65)
		M.adjustOxyLoss(-10*REM)
	if(M.health < -25)
		M.adjustToxLoss(-1)
		M.adjustBruteLoss(-3*REM)
		M.adjustFireLoss(-3*REM)
	else if(M.health > -60)
		M.adjustToxLoss(1)
	M.reagents.remove_reagent("sarin", 20)
	..()
	return

/datum/chemical_reaction/atropine
	name = "Atropine"
	id = "atropine"
	result = "atropine"
	required_reagents = list("ethanol" = 1, "acetone" = 1, "diethylamine" = 1, "phenol" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "A horrid smell like something died drifts from the mixture."

datum/reagent/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	description = "Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest."
	reagent_state = LIQUID
	color = "#96B1AE"
	metabolization_rate = 0.2
	overdose_threshold = 20

datum/reagent/epinephrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness = max(0, M.drowsyness-5)
	if(prob(20))
		M.AdjustParalysis(-1)
	if(prob(20))
		M.AdjustStunned(-1)
	if(prob(20))
		M.AdjustWeakened(-1)
	if(prob(5))
		M.SetSleeping(0)
	if(prob(5))
		M.adjustBrainLoss(-1)
	holder.remove_reagent("histamine", 15)
	if(M.losebreath > 3)
		M.losebreath--
	if(M.oxyloss > 35)
		M.adjustOxyLoss(-10*REM)
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-1*REM)
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	..()
	return

/datum/reagent/epinephrine/overdose_process(var/mob/living/M as mob, severity)
	var/effect = ..()
	if (severity == 1)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.emote("collapse")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] staggers and drools, their eyes bloodshot!</span>")
			M.Dizzy(2)
			M.Weaken(3)
		if(effect <= 15)
			M.emote("collapse")

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	result = "epinephrine"
	required_reagents = list("phenol" = 1, "acetone" = 1, "diethylamine" = 1, "oxygen" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 6
	mix_message = "Tiny white crystals precipitate out of the solution."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

datum/reagent/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	description = "A glowing green fluid highly reminiscent of nuclear waste."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.2

datum/reagent/strange_reagent/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(isanimal(M))
		if(method == TOUCH)
			var/mob/living/simple_animal/SM = M
			if(SM.stat == DEAD)
				SM.revive()
				SM.loot.Cut() //no abusing strange reagent for unlimited farming of resources
				SM.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")

	if(istype(M, /mob/living/carbon))
		if(method == INGEST)
			if(M.stat == DEAD)
				if(M.getBruteLoss()+M.getFireLoss() >= 150)
					M.visible_message("<span class='warning'>[M]'s body starts convulsing!</span>")
					M.gib()
					return
				var/mob/dead/observer/ghost = M.get_ghost()
				if(ghost)
					to_chat(ghost, "<span class='ghostalert'>Your are attempting to be revived with Strange Reagent. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
					ghost << sound('sound/effects/genetics.ogg')
					M.visible_message("<span class='notice'>[M] doesn't appear to respond, perhaps try again later?</span>")
				if(!M.suiciding && !ghost && !(NOCLONE in M.mutations))
					M.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")
					M.setOxyLoss(0)
					M.adjustBruteLoss(rand(0,15))
					M.adjustToxLoss(rand(0,15))
					M.adjustFireLoss(rand(0,15))
					M.update_revive()
					M.stat = UNCONSCIOUS
					add_logs(M, M, "revived", object="strange reagent")
	..()
	return

datum/reagent/strange_reagent/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(10))
		M.adjustBruteLoss(2*REM)
		M.adjustToxLoss(2*REM)
	..()
	return

/datum/chemical_reaction/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	result = "strange_reagent"
	required_reagents = list("omnizine" = 1, "holywater" = 1, "mutagen" = 1)
	result_amount = 3
	mix_message = "The substance begins moving on its own somehow."

datum/reagent/life
	name = "Life"
	id = "life"
	description = "Can create a life form, however it is not guaranteed to be friendly. May want to have Security on hot standby."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2

/datum/chemical_reaction/life
	name = "Life"
	id = "life"
	result = null
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "blood" = 1)
	result_amount = 3
	min_temp = 374

/datum/chemical_reaction/life/on_reaction(var/datum/reagents/holder, var/created_volume)
	chemical_mob_spawn(holder, 1, "Life")

/datum/reagent/mannitol/on_mob_life(mob/living/M as mob)
	M.adjustBrainLoss(-3)
	..()
	return

/datum/chemical_reaction/mannitol
	name = "Mannitol"
	id = "mannitol"
	result = "mannitol"
	required_reagents = list("sugar" = 1, "hydrogen" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles slowly, making a slightly sweet odor."

/datum/reagent/mannitol
	name = "Mannitol"
	id = "mannitol"
	description = "Mannitol is a sugar alcohol that can help alleviate cranial swelling."
	color = "#D1D1F1"

/datum/reagent/mutadone/on_mob_life(var/mob/living/carbon/human/M as mob)
	M.jitteriness = 0
	var/needs_update = M.mutations.len > 0 || M.disabilities > 0 || M.sdisabilities > 0

	if(needs_update)
		for(var/block=1;block<=DNA_SE_LENGTH;block++)
			M.dna.SetSEState(block,0, 1)
			genemutcheck(M,block,null,MUTCHK_FORCED)
		M.dna.UpdateSE()

		M.dna.struc_enzymes = M.dna.struc_enzymes_original

		// Might need to update appearance for hulk etc.
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.update_mutations()
	..()
	return

/datum/chemical_reaction/mutadone
	name = "Mutadone"
	id = "mutadone"
	result = "mutadone"
	required_reagents = list("mutagen" = 1, "acetone" = 1, "bromine" = 1)
	result_amount = 3
	mix_message = "A foul astringent liquid emerges from the reaction."


/datum/reagent/mutadone
	name = "Mutadone"
	id = "mutadone"
	description = "Mutadone is an experimental bromide that can cure genetic abnomalities."
	color = "#5096C8"

datum/reagent/antihol
	name = "Antihol"
	id = "antihol"
	description = "A medicine which quickly eliminates alcohol in the body."
	color = "#009CA8"

datum/reagent/antihol/on_mob_life(var/mob/living/M as mob)
	M.slurring = 0
	M.AdjustDrunk(-4)
	M.reagents.remove_all_type(/datum/reagent/ethanol, 8, 0, 1)
	if(M.toxloss <= 25)
		M.adjustToxLoss(-2.0)
	..()

/datum/chemical_reaction/antihol
	name = "antihol"
	id = "antihol"
	result = "antihol"
	required_reagents = list("ethanol" = 1, "charcoal" = 1)
	result_amount = 2
	mix_message = "A minty and refreshing smell drifts from the effervescent mixture."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "Increases run speed and eliminates stuns, can heal minor damage. If overdosed it will deal toxin damage and stun."
	color = "#C8A5DC"
	metabolization_rate = 0.4

datum/reagent/stimulants/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(volume > 5)
		M.adjustOxyLoss(-5*REM)
		M.adjustToxLoss(-5*REM)
		M.adjustBruteLoss(-10*REM)
		M.adjustFireLoss(-10*REM)
		M.setStaminaLoss(0)
		M.slowed = 0
		M.dizziness = max(0,M.dizziness-10)
		M.drowsyness = max(0,M.drowsyness-10)
		M.confused = 0
		M.SetSleeping(0)
		var/status = CANSTUN | CANWEAKEN | CANPARALYSE
		M.status_flags &= ~status
	else
		M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
		M.adjustToxLoss(2)
		M.adjustBruteLoss(1)
		if(prob(10))
			M.Stun(3)
	..()

datum/reagent/stimulants/reagent_deleted(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
	..()
	return

/datum/reagent/medicine/stimulative_agent
	name = "Stimulative Agent"
	id = "stimulative_agent"
	description = "An illegal compound that dramatically enhances the body's performance and healing capabilities."
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60

/datum/reagent/medicine/stimulative_agent/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	if(M.health < 50 && M.health > 0)
		M.adjustOxyLoss(-1*REM)
		M.adjustToxLoss(-1*REM)
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	M.adjustStaminaLoss(-5*REM)
	..()

/datum/reagent/medicine/stimulative_agent/overdose_process(mob/living/M, severity)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++

datum/reagent/insulin
	name = "Insulin"
	id = "insulin"
	description = "A hormone generated by the pancreas responsible for metabolizing carbohydrates and fat in the bloodstream."
	reagent_state = LIQUID
	color = "#C8A5DC"

datum/reagent/insulin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.remove_reagent("sugar", 5)
	..()
	return


/datum/reagent/simethicone
	name = "Simethicone"
	id = "simethicone"
	description = "This strange liquid seems to have no bubbles on the surface."
	color = "#14AA46"

/datum/chemical_reaction/Simethicone
	name = "Simethicone"
	id = "simethicone"
	result = "simethicone"
	required_reagents = list("hydrogen" = 1, "chlorine" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 4


datum/reagent/teporone
	name = "Teporone"
	id = "teporone"
	description = "This experimental plasma-based compound seems to regulate body temperature."
	reagent_state = LIQUID
	color = "#D782E6"
	addiction_chance = 20
	overdose_threshold = 50

datum/reagent/teporone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.bodytemperature > 310)
		M.bodytemperature -= 10
	if(M.bodytemperature < 310)
		M.bodytemperature += 10
	..()
	return

/datum/chemical_reaction/teporone
	name = "Teporone"
	id = "teporone"
	result = "teporone"
	required_reagents = list("acetone" = 1, "silicon" = 1, "plasma" = 1)
	result_amount = 2
	mix_message = "The mixture turns an odd lavender color."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

datum/reagent/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	description = "Haloperidol is a powerful antipsychotic and sedative. Will help control psychiatric problems, but may cause brain damage."
	reagent_state = LIQUID
	color = "#FFDCFF"

datum/reagent/haloperidol/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.remove_reagent("crank", 5)
	M.reagents.remove_reagent("methamphetamine", 5)
	M.reagents.remove_reagent("space_drugs", 5)
	M.reagents.remove_reagent("psilocybin", 5)
	M.reagents.remove_reagent("ephedrine", 5)
	M.reagents.remove_reagent("epinephrine", 5)
	M.reagents.remove_reagent("stimulants", 3)
	M.reagents.remove_reagent("bath_salts", 5)
	M.reagents.remove_reagent("lsd", 5)
	M.reagents.remove_reagent("thc", 5)
	M.druggy -= 5
	M.hallucination -= 5
	M.jitteriness -= 5
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	if(prob(20))
		M.adjustBrainLoss(1)
	..()
	return

/datum/chemical_reaction/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	result = "haloperidol"
	required_reagents = list("chlorine" = 1, "fluorine" = 1, "aluminum" = 1, "potass_iodide" = 1, "oil" = 1)
	result_amount = 4
	mix_message = "The chemicals mix into an odd pink slush."


/datum/reagent/ether
	name = "Ether"
	id = "ether"
	description = "A strong anesthetic and sedative."
	reagent_state = LIQUID
	color = "#96DEDE"

/datum/reagent/ether/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.jitteriness = max(M.jitteriness-25,0)
	switch(current_cycle)
		if(1 to 15)
			if(prob(7))
				M.emote("yawn")
		if(16 to 35)
			M.drowsyness = max(M.drowsyness, 20)
		if(36 to INFINITY)
			M.Paralyse(15)
			M.drowsyness = max(M.drowsyness, 20)
	..()
	return

/datum/chemical_reaction/ether
	name = "Ether"
	id = "ether"
	result = "ether"
	required_reagents = list("sacid" = 1, "ethanol" = 1, "oxygen" = 1)
	result_amount = 1
	mix_message = "The mixture yields a pungent odor, which makes you tired."

//////////////////////////////
//		Synth-Meds			//
//////////////////////////////

//Degreaser: Mild Purgative / Lube Remover
/datum/reagent/degreaser
	name = "Degreaser"
	id = "degreaser"
	description = "An industrial degreaser which can be used to clean residual build-up from machinery and surfaces."
	reagent_state = LIQUID
	color = "#CC7A00"
	process_flags = SYNTHETIC

/datum/chemical_reaction/degreaser
	name = "Degreaser"
	id = "degreaser"
	result = "degreaser"
	required_reagents = list("oil" = 1, "sterilizine" = 1)
	result_amount = 2

/datum/reagent/degreaser/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 1)
		if(istype(T) && T.wet)
			T.MakeDry(TURF_WET_LUBE)

/datum/reagent/degreaser/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(50))		//Same effects as coffee, to help purge ill effects like paralysis
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
		M.confused = max(0, M.confused-5)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			if(R.id == "ultralube" || R.id == "lube")
				//Flushes lube and ultra-lube even faster than other chems
				M.reagents.remove_reagent(R.id, 5)
			else
				M.reagents.remove_reagent(R.id,1)
	..()
	return

//Liquid Solder: Mannitol
/datum/reagent/liquid_solder
	name = "Liquid Solder"
	id = "liquid_solder"
	description = "A solution formulated to clean and repair damaged connections in posibrains while in use."
	reagent_state = LIQUID
	color = "#D7B395"
	process_flags = SYNTHETIC

/datum/reagent/liquid_solder/on_mob_life(mob/living/M as mob)
	M.adjustBrainLoss(-3)
	..()
	return

/datum/chemical_reaction/liquid_solder
	name = "Liquid Solder"
	id = "liquid_solder"
	result = "liquid_solder"
	required_reagents = list("ethanol" = 1, "copper" = 1, "silver" = 1)
	result_amount = 3
	min_temp = 370
	mix_message = "The solution gently swirls with a metallic sheen."


datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	id = "syndicate_nanites"
	description = "Miniature medical robots that swiftly restore bodily damage. May begin to attack their host's cells in high amounts."
	reagent_state = SOLID
	color = "#555555"

datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-5*REM) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REM)
	M.adjustOxyLoss(-15*REM)
	M.adjustToxLoss(-5*REM)
	M.adjustBrainLoss(-15*REM)
	M.adjustCloneLoss(-3*REM)
	..()
	return
