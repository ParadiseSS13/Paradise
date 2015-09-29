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
				M << "<span class='notice'>The silver sulfadiazine soothes your burns.</span>"
		if(method == INGEST)
			M.adjustToxLoss(0.5*volume)
			if(show_message)
				M << "<span class='warning'>You feel sick...</span>"
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
				M << "<span class='notice'>The styptic powder stings like hell as it closes some of your wounds!</span>"
			M.emote("scream")
		if(method == INGEST)
			M.adjustToxLoss(0.5*volume)
			if(show_message)
				M << "<span class='warning'>You feel gross!</span>"
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
				M << "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>"
	..()
	return

datum/reagent/synthflesh/reaction_turf(var/turf/T, var/volume) //let's make a mess!
	src = null
	if(volume >= 5)
		new /obj/effect/decal/cleanable/blood/gibs(T)
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

/datum/chemical_reaction/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	result = "silver_sulfadiazine"
	required_reagents = list("ammonia" = 1, "silver" = 1, "sulfur" = 1, "oxygen" = 1, "chlorine" = 1)
	result_amount = 5
	mix_message = "A strong and cloying odor begins to bubble from the mixture."

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

datum/reagent/omnizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1*REM)
	M.adjustOxyLoss(-1*REM)
	M.adjustBruteLoss(-2*REM)
	M.adjustFireLoss(-2*REM)
	if(prob(50))
		M.losebreath -= 1
	..()
	return

datum/reagent/omnizine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(3*REM)
	M.adjustOxyLoss(3*REM)
	M.adjustBruteLoss(3*REM)
	M.adjustFireLoss(3*REM)
	..()
	return

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
	if(prob(10))
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
	if(M.radiation > 0)
		if(prob(80))
			M.radiation--
	if(M.radiation < 0)
		M.radiation = 0
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
	if(M.radiation > 0)
		M.radiation -= 7
	if(prob(75))
		M.adjustToxLoss(-4*REM)
	if(prob(33))
		M.adjustBruteLoss(1*REM)
		M.adjustFireLoss(1*REM)
	if(M.radiation < 0)
		M.radiation = 0
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
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
	shock_reduction = 40
	overdose_threshold = 25

datum/reagent/sal_acid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(55))
		M.adjustBruteLoss(-2*REM)
	..()
	return

datum/reagent/sal_acid/overdose_process(var/mob/living/M as mob)
	if(volume > 25)
		if(prob(8))
			M.adjustToxLoss(rand(1,2))
	..()
	return

/datum/chemical_reaction/sal_acid
	name = "Salicyclic Acid"
	id = "sal_acid"
	result = "sal_acid"
	required_reagents = list("sodium" = 1, "phenol" = 1, "carbon" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "The mixture crystallizes."

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
	if(M.losebreath >= 4)
		M.losebreath -= 4
	..()
	return

/datum/chemical_reaction/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	result = "salbutamol"
	required_reagents = list("sal_acid" = 1, "lithium" = 1, "aluminum" = 1, "bromine" = 1, "ammonia" = 1)
	result_amount = 5
	mix_message = "The solution bubbles freely, creating a head of bluish foam."

datum/reagent/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2

datum/reagent/perfluorodecalin/on_mob_life(var/mob/living/carbon/human/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-25*REM)
	M.silent = max(M.silent, 5)
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

datum/reagent/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Ephedrine is a plant-derived stimulant."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.3
	overdose_threshold = 45
	addiction_threshold = 30

datum/reagent/ephedrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REM)
	..()
	return

datum/reagent/ephedrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return

datum/reagent/ephedrine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(2*REM)
		M.losebreath += 2
	..()
	return
datum/reagent/ephedrine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(3*REM)
		M.losebreath += 3
	..()
	return
datum/reagent/ephedrine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(4*REM)
		M.losebreath += 4
	..()
	return
datum/reagent/ephedrine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		M.adjustToxLoss(5*REM)
		M.losebreath += 5
	..()
	return

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
datum/reagent/diphenhydramine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness += 1
	M.jitteriness -= 1
	M.reagents.remove_reagent("histamine",3)
	M.reagents.remove_reagent("itching_powder",3)
	..()
	return

/datum/chemical_reaction/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	result = "diphenhydramine"
	required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
	result_amount = 4
	mix_message = "The mixture fizzes gently."

datum/reagent/morphine
	name = "Morphine"
	id = "morphine"
	description = "A strong but highly addictive opiate painkiller with sedative side effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	addiction_threshold = 25
	shock_reduction = 60

datum/reagent/morphine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= IGNORESLOWDOWN
	switch(current_cycle)
		if(0 to 15)
			if(prob(5))
				M.emote("yawn")
		if(16 to 35)
			M.drowsyness = max(M.drowsyness, 10)
		if(36 to INFINITY)
			M.Paralyse(10)
			M.drowsyness = max(M.drowsyness, 15)
	..()
	return

datum/reagent/morphine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(1)
		M.Jitter(1)
	..()
	return

datum/reagent/morphine/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.Dizzy(2)
		M.Jitter(2)
	..()
	return
datum/reagent/morphine/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(1*REM)
		M.Dizzy(3)
		M.Jitter(3)
	..()
	return
datum/reagent/morphine/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(2*REM)
		M.Dizzy(4)
		M.Jitter(4)
	..()
	return
datum/reagent/morphine/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
		M.adjustToxLoss(3*REM)
		M.Dizzy(5)
		M.Jitter(5)
	..()
	return

datum/reagent/oculine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.eye_blurry = max(M.eye_blurry-5 , 0)
	M.eye_blind = max(M.eye_blind-5 , 0)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]
		if(istype(E))
			if(E.damage > 0)
				E.damage -= 1
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
	overdose_threshold = 35

datum/reagent/atropine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.health > -60)
		M.adjustToxLoss(1*REM)
	if(M.health < -25)
		M.adjustBruteLoss(-3*REM)
		M.adjustFireLoss(-3*REM)
	if(M.oxyloss > 65)
		M.adjustOxyLoss(-10*REM)
	if(M.losebreath > 5)
		M.losebreath = 5
	if(M.confused > 60)
		M.confused += 5
	M.reagents.remove_reagent("tabun",10)
	..()
	return

datum/reagent/atropine/overdose_process(var/mob/living/M as mob)
	if(prob(50))
		M.adjustToxLoss(2*REM)
		M.Dizzy(1)
		M.Jitter(1)
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
	overdose_threshold = 30

datum/reagent/epinephrine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-1*REM)
		M.adjustBruteLoss(-1*REM)
		M.adjustFireLoss(-1*REM)
	if(M.oxyloss > 35)
		M.adjustOxyLoss(-10*REM)
	if(M.losebreath >= 3)
		M.losebreath = 3
	..()
	return

datum/reagent/epinephrine/overdose_process(var/mob/living/M as mob)
	if(prob(33))
		M.adjustStaminaLoss(5*REM)
		M.adjustToxLoss(2*REM)
		M.losebreath++
	..()
	return

/datum/chemical_reaction/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	result = "epinephrine"
	required_reagents = list("phenol" = 1, "acetone" = 1, "diethylamine" = 1, "oxygen" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 6
	mix_message = "Tiny white crystals precipitate out of the solution."

datum/reagent/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	description = "A glowing green fluid highly reminiscent of nuclear waste."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.2

datum/reagent/strange_reagent/reaction_mob(var/mob/living/M as mob, var/method=TOUCH, var/volume)
	if(istype(M, /mob/living/simple_animal))
		if(method == TOUCH)
			if(M.stat == DEAD)
				M.health = M.maxHealth
				M.update_revive()
				M.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")
	if(istype(M, /mob/living/carbon))
		if(method == INGEST)
			if(M.stat == DEAD)
				if(M.getBruteLoss()+M.getFireLoss() >= 150)
					M.visible_message("<span class='warning'>[M]'s body starts convulsing!</span>")
					M.gib()
					return
				var/mob/dead/observer/ghost = M.get_ghost()
				if(ghost)
					ghost << "<span class='ghostalert'>Your are attempting to be revived with Strange Reagent. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)"
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

proc/chemical_mob_spawn(var/datum/reagents/holder, var/amount_to_spawn, var/reaction_name, var/mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		var/blocked =  blocked_mobs //global variable for blocked mobs

		var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)
		var/message = "A [reaction_name] reaction has occured in (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[my_area.name]</A>)"
		var/mob/M = get(A, /mob)
		if(M)
			message += " - carried by: [key_name_admin(M)]"
		else
			message += " - last fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/i = 1, i <= amount_to_spawn, i++)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.faction |= mob_faction
			C.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))

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
	var/needs_update = 1 //M.mutations.len > 0

	for(var/block=1;block<=DNA_SE_LENGTH;block++)
		M.dna.SetSEState(block,0)
		genemutcheck(M,block,null,MUTCHK_FORCED)
		M.update_mutations()

	M.dna.struc_enzymes = M.dna.struc_enzymes_original

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
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
	M.dizziness = 0
	M.drowsyness = 0
	M.slurring = 0
	M.confused = 0
	M.reagents.remove_reagent("ethanol", 8)
	if(M.health < 25)
		M.adjustToxLoss(-2.0)
	..()

/datum/chemical_reaction/antihol
	name = "antihol"
	id = "antihol"
	result = "antihol"
	required_reagents = list("ethanol" = 1, "charcoal" = 1)
	result_amount = 2
	mix_message = "A minty and refreshing smell drifts from the effervescent mixture."

/datum/reagent/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "Increases run speed and eliminates stuns, can heal minor damage. If overdosed it will deal toxin damage and stun."
	color = "#C8A5DC"
	metabolization_rate = 0.4

datum/reagent/stimulants/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-5*REM)
	M.adjustToxLoss(-5*REM)
	M.adjustBruteLoss(-10*REM)
	M.adjustFireLoss(-10*REM)
	M.setStaminaLoss(0)
	var/status = CANSTUN | CANWEAKEN | CANPARALYSE
	M.status_flags &= ~status
	..()

datum/reagent/stimulants/reagent_deleted(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
	M.adjustBruteLoss(12)
	M.adjustToxLoss(24)
	M.Stun(4)
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

/datum/reagent/medicine/stimulative_agent/overdose_process(mob/living/M)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REM)
		M.adjustToxLoss(1*REM)
		M.losebreath++
	..()
	return

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
	M.reagents.remove_reagent("stimulants", 5)
	M.reagents.remove_reagent("bath_salts", 5)
	M.reagents.remove_reagent("lsd", 5)
	M.druggy -= 5
	M.hallucination -= 5
	M.jitteriness -= 5
	if(prob(40))
		M.drowsyness = max(M.drowsyness, 2)
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
	switch(current_cycle)
		if(0 to 15)
			if(prob(5))
				M.emote("yawn")
		if(16 to 35)
			M.drowsyness = max(M.drowsyness, 10)
		if(36 to INFINITY)
			M.Paralyse(10)
			M.drowsyness = max(M.drowsyness, 15)
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

//Degreaser: Anti-toxin / Lube Remover
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
		if(T.wet >= 2)			//Clears lube! Fight back against the slipping, and WIN!
			T.wet = 0
			if(T.wet_overlay)
				T.overlays -= T.wet_overlay
				T.wet_overlay = null
			return

/datum/reagent/degreaser/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(-1.5*REM)
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
