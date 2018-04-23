/datum/reagent/medicine
	name = "Medicine"
	id = "medicine"

/datum/reagent/medicine/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(id, (metabolization_rate / M.metabolism_efficiency) * M.digestion_ratio) //medicine reagents stay longer if you have a better metabolism

/datum/reagent/medicine/hydrocodone
	name = "Hydrocodone"
	id = "hydrocodone"
	description = "An extremely effective painkiller; may have long term abuse consequences."
	reagent_state = LIQUID
	color = "#C805DC"
	metabolization_rate = 0.3 // Lasts 1.5 minutes for 15 units
	shock_reduction = 200

/datum/reagent/medicine/hydrocodone/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()

/datum/reagent/medicine/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

	//makes you squeaky clean
/datum/reagent/medicine/sterilizine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/medicine/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/medicine/sterilizine/reaction_turf(turf/T, volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as paralysis."
	reagent_state = LIQUID
	color = "#FA46FA"
	overdose_threshold = 40

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-5)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.SetSleeping(0)
	if(prob(50))
		M.adjustBrainLoss(-1.0)
	..()

/datum/reagent/medicine/synaptizine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			M.adjustToxLoss(1)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] staggers and drools, their eyes bloodshot!</span>")
			M.Dizzy(8)
			M.Weaken(4)
		if(effect <= 15)
			M.adjustToxLoss(1)

/datum/reagent/medicine/mitocholide
	name = "Mitocholide"
	id = "mitocholide"
	description = "A specialized drug that stimulates the mitochondria of cells to encourage healing of internal organs."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/mitocholide/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
		for(var/obj/item/organ/internal/I in H.internal_organs)
			I.receive_damage(-0.4)
	..()

/datum/reagent/medicine/mitocholide/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/Org = O
		Org.rejuvenate()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#0000C8" // rgb: 200, 165, 220
	heart_rate_decrease = 1

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/M)
	if(M.bodytemperature < 265)
		M.adjustCloneLoss(-4)
		M.adjustOxyLoss(-10)
		M.adjustToxLoss(-3)
		M.adjustBruteLoss(-12)
		M.adjustFireLoss(-12)
		M.status_flags &= ~DISFIGURED
	..()

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/M)
	M.setCloneLoss(0) //Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	M.adjustCloneLoss(-1) //What? We just set cloneloss to 0. Why? Simple; this is so external organs properly unmutate.
	M.adjustBruteLoss(-1)
	M.adjustFireLoss(-1)
	M.status_flags &= ~DISFIGURED
	..()

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M, severity)
	M.adjustToxLoss(1)
	M.Dizzy(5)
	M.Jitter(5)

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antibiotic agent extracted from space fungus."
	reagent_state = LIQUID
	color = "#0AB478"
	metabolization_rate = 0.2

/datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "This antibacterial compound is used to treat burn victims."
	reagent_state = LIQUID
	color = "#F0C814"
	metabolization_rate = 3

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/M)
	M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=TOUCH, volume, show_message = 1)
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

/datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "Styptic (aluminium sulfate) powder helps control bleeding and heal physical wounds."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 3

/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=TOUCH, volume, show_message = 1)
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

/datum/reagent/medicine/salglu_solution
	name = "Saline-Glucose Solution"
	id = "salglu_solution"
	description = "This saline and glucose solution can help stabilize critically injured patients and cleanse wounds."
	reagent_state = LIQUID
	color = "#C8A5DC"
	penetrates_skin = TRUE
	metabolization_rate = 0.15
	taste_message = "salt"

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/M)
	if(prob(33))
		M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	if(ishuman(M) && prob(33))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.species.species_traits))//do not restore blood on things with no blood by nature.
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 1
	..()

/datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	description = "A resorbable microfibrillar collagen and protein mixture that can rapidly heal injuries when applied topically."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/medicine/synthflesh/reaction_mob(mob/living/M, method=TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == TOUCH)
			M.adjustBruteLoss(-1.5*volume)
			M.adjustFireLoss(-1.5*volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>")
	..()

/datum/reagent/medicine/synthflesh/reaction_turf(turf/T, volume) //let's make a mess!
	if(volume >= 5 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/medicine/charcoal
	name = "Charcoal"
	id = "charcoal"
	description = "Activated charcoal helps to absorb toxins."
	reagent_state = LIQUID
	color = "#000000"

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/M)
	M.adjustToxLoss(-1.5*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(50))
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
	..()

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	id = "omnizine"
	description = "Omnizine is a highly potent healing medication that can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	overdose_threshold = 30
	addiction_chance = 5

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/M)
	M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(50))
		M.AdjustLoseBreath(-1)
	..()

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M, severity)
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
			M.AdjustConfused(15)
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

/datum/reagent/medicine/calomel
	name = "Calomel"
	id = "calomel"
	description = "This potent purgative rids the body of impurities. It is highly toxic however and close supervision is required."
	reagent_state = LIQUID
	color = "#22AB35"
	metabolization_rate = 0.8

/datum/reagent/medicine/calomel/on_mob_life(mob/living/M)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		M.adjustToxLoss(5*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(6))
		M.fakevomit()
	..()

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning."
	reagent_state = LIQUID
	color = "#B4DCBE"

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/M)
	if(prob(80))
		M.radiation = max(0, M.radiation-1)
	..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Pentetic Acid is an aggressive chelation agent. May cause tissue damage. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/M)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
	M.radiation = max(0, M.radiation-7)
	if(prob(75))
		M.adjustToxLoss(-4*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(33))
		M.adjustBruteLoss(1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	id = "sal_acid"
	description = "This is a is a standard salicylate pain reliever and fever reducer."
	reagent_state = LIQUID
	color = "#B3B3B3"
	metabolization_rate = 0.1
	shock_reduction = 25
	overdose_threshold = 25

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/M)
	if(prob(55))
		M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.2

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/M)
	M.adjustOxyLoss(-6*REAGENTS_EFFECT_MULTIPLIER)
	M.AdjustLoseBreath(-4)
	..()

/datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	addiction_chance = 20

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	M.adjustOxyLoss(-25*REAGENTS_EFFECT_MULTIPLIER)
	if(volume >= 4)
		M.LoseBreath(6)
		M.Silence(6)
	if(prob(33))
		M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Ephedrine is a plant-derived stimulant."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.3
	overdose_threshold = 35
	addiction_chance = 25

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-5)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	M.adjustStaminaLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	M.AdjustLoseBreath(-1, bound_lower = 5)
	if(M.oxyloss > 75)
		M.adjustOxyLoss(-1)
	if(M.health < 0 || M.health > 0 && prob(33))
		M.adjustToxLoss(-1)
		M.adjustBruteLoss(-1)
		M.adjustFireLoss(-1)
	..()

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M, severity)
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

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Anti-allergy medication. May cause drowsiness, do not operate heavy machinery while using this."
	reagent_state = LIQUID
	color = "#5BCBE1"
	addiction_chance = 10

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/M)
	M.AdjustJitter(-20)
	M.reagents.remove_reagent("histamine",3)
	M.reagents.remove_reagent("itching_powder",3)
	if(prob(7))
		M.emote("yawn")
	if(prob(3))
		M.Stun(2)
		M.AdjustDrowsy(1)
		M.visible_message("<span class='notice'>[M] looks a bit dazed.</span>")
	..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	id = "morphine"
	description = "A strong but highly addictive opiate painkiller with sedative side effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 20
	addiction_chance = 50
	shock_reduction = 50

/datum/reagent/medicine/morphine/on_mob_life(mob/living/M)
	M.AdjustJitter(-25)
	switch(current_cycle)
		if(1 to 15)
			if(prob(7))
				M.emote("yawn")
		if(16 to 35)
			M.Drowsy(20)
		if(36 to INFINITY)
			M.Paralyse(15)
			M.Drowsy(20)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.traumatic_shock < 100)
			H.shock_stage = 0
	..()

/datum/reagent/medicine/oculine
	name = "Oculine"
	id = "oculine"
	description = "Oculine is a saline eye medication with mydriatic and antibiotic effects."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/M)
	if(prob(80))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.receive_damage(-1)
		M.AdjustEyeBlurry(-1)
		M.AdjustEarDamage(-1)
	if(prob(50))
		M.CureNearsighted()
	if(prob(30))
		M.CureBlind()
		M.SetEyeBlind(0)
	if(M.ear_damage <= 25)
		if(prob(30))
			M.SetEarDeaf(0)
	..()

/datum/reagent/medicine/atropine
	name = "Atropine"
	id = "atropine"
	description = "Atropine is a potent cardiac resuscitant but it can causes confusion, dizzyness and hyperthermia."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.2
	overdose_threshold = 25

/datum/reagent/medicine/atropine/on_mob_life(mob/living/M)
	M.AdjustDizzy(1)
	M.Confused(5)
	if(prob(4))
		M.emote("collapse")
	M.AdjustLoseBreath(-5, bound_lower = 5)
	if(M.oxyloss > 65)
		M.adjustOxyLoss(-10*REAGENTS_EFFECT_MULTIPLIER)
	if(M.health < -25)
		M.adjustToxLoss(-1)
		M.adjustBruteLoss(-3*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-3*REAGENTS_EFFECT_MULTIPLIER)
	else if(M.health > -60)
		M.adjustToxLoss(1)
	M.reagents.remove_reagent("sarin", 20)
	..()

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	description = "Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest."
	reagent_state = LIQUID
	color = "#96B1AE"
	metabolization_rate = 0.2
	overdose_threshold = 20

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-5)
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
	M.AdjustLoseBreath(-1, bound_lower = 3)
	if(M.oxyloss > 35)
		M.adjustOxyLoss(-10*REAGENTS_EFFECT_MULTIPLIER)
	if(M.health < -10 && M.health > -65)
		M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M, severity)
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
			M.visible_message("<span class='warning'>[M] staggers and drools, their eyes bloodshot!</span>")
			M.Dizzy(2)
			M.Weaken(3)
		if(effect <= 15)
			M.emote("collapse")

/datum/reagent/medicine/strange_reagent
	name = "Strange Reagent"
	id = "strange_reagent"
	description = "A glowing green fluid highly reminiscent of nuclear waste."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.2

/datum/reagent/medicine/strange_reagent/on_mob_life(mob/living/M)
	if(prob(10))
		M.adjustBruteLoss(2*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/strange_reagent/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(volume < 1)
		// gotta pay to play
		return ..()
	if(isanimal(M))
		if(method == TOUCH)
			var/mob/living/simple_animal/SM = M
			if(SM.stat == DEAD)
				SM.revive()
				SM.loot.Cut() //no abusing strange reagent for unlimited farming of resources
				SM.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")

	if(iscarbon(M))
		if(method == INGEST)
			if(M.stat == DEAD)
				if(M.getBruteLoss()+M.getFireLoss()+M.getCloneLoss() >= 150)
					M.visible_message("<span class='warning'>[M]'s body starts convulsing!</span>")
					M.gib()
					return
				var/mob/dead/observer/ghost = M.get_ghost()
				if(ghost)
					to_chat(ghost, "<span class='ghostalert'>You are attempting to be revived with Strange Reagent. Return to your body if you want to be revived!</span> (Verbs -> Ghost -> Re-enter corpse)")
					window_flash(ghost.client)
					ghost << sound('sound/effects/genetics.ogg')
					M.visible_message("<span class='notice'>[M] doesn't appear to respond, perhaps try again later?</span>")
				if(!M.suiciding && !ghost && !(NOCLONE in M.mutations))
					var/time_dead = world.time - M.timeofdeath
					M.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")
					M.adjustCloneLoss(50)
					M.setOxyLoss(0)
					M.adjustBruteLoss(rand(0,15))
					M.adjustToxLoss(rand(0,15))
					M.adjustFireLoss(rand(0,15))
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/necrosis_prob = 40 * min((20 MINUTES), max((time_dead - (1 MINUTES)), 0)) / ((20 MINUTES) - (1 MINUTES))
						for(var/obj/item/organ/O in (H.bodyparts | H.internal_organs))
							// Per non-vital body part:
							// 0% chance of necrosis within 1 minute of death
							// 40% chance of necrosis after 20 minutes of death
							if(!O.vital && prob(necrosis_prob))
								// side effects may include: Organ failure
								O.necrotize(FALSE)
								if(O.status & ORGAN_DEAD)
									O.germ_level = INFECTION_LEVEL_THREE
						H.update_body()

					M.update_revive()
					M.stat = UNCONSCIOUS
					add_attack_logs(M, M, "Revived with strange reagent") //Yes, the logs say you revived yourself.
	..()

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	id = "mannitol"
	description = "Mannitol is a sugar alcohol that can help alleviate cranial swelling."
	color = "#D1D1F1"

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/M)
	M.adjustBrainLoss(-3)
	..()

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	id = "mutadone"
	description = "Mutadone is an experimental bromide that can cure genetic abnomalities."
	color = "#5096C8"

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/human/M)
	if(M.mind && M.mind.assigned_role == "Cluwne") // HUNKE
		..()
		return
	M.SetJitter(0)
	var/needs_update = M.mutations.len > 0 || M.disabilities > 0

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

/datum/reagent/medicine/antihol
	name = "Antihol"
	id = "antihol"
	description = "A medicine which quickly eliminates alcohol in the body."
	color = "#009CA8"

/datum/reagent/medicine/antihol/on_mob_life(mob/living/M)
	M.SetSlur(0)
	M.AdjustDrunk(-4)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 8, 0, 1)
	if(M.toxloss <= 25)
		M.adjustToxLoss(-2.0)
	..()

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "Increases run speed and eliminates stuns, can heal minor damage. If overdosed it will deal toxin damage and stun."
	color = "#C8A5DC"
	can_synth = FALSE

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/M)
	if(volume > 5)
		M.adjustOxyLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustToxLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustBruteLoss(-10*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-10*REAGENTS_EFFECT_MULTIPLIER)
		M.setStaminaLoss(0)
		M.SetSlowed(0)
		M.AdjustDizzy(-10)
		M.AdjustDrowsy(-10)
		M.SetConfused(0)
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

/datum/reagent/medicine/stimulants/on_mob_delete(mob/living/M)
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
	..()

/datum/reagent/medicine/stimulative_agent
	name = "Stimulative Agent"
	id = "stimulative_agent"
	description = "An illegal compound that dramatically enhances the body's performance and healing capabilities."
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	can_synth = FALSE

/datum/reagent/medicine/stimulative_agent/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	if(M.health < 50 && M.health > 0)
		M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER)
	M.AdjustParalysis(-3)
	M.AdjustStunned(-3)
	M.AdjustWeakened(-3)
	M.adjustStaminaLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/stimulative_agent/on_mob_delete(mob/living/M)
	M.status_flags &= ~GOTTAGOFAST
	..()

/datum/reagent/medicine/stimulative_agent/overdose_process(mob/living/M, severity)
	if(prob(33))
		M.adjustStaminaLoss(2.5*REAGENTS_EFFECT_MULTIPLIER)
		M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
		M.AdjustLoseBreath(1)

/datum/reagent/medicine/insulin
	name = "Insulin"
	id = "insulin"
	description = "A hormone generated by the pancreas responsible for metabolizing carbohydrates and fat in the bloodstream."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/medicine/insulin/on_mob_life(mob/living/M)
	M.reagents.remove_reagent("sugar", 5)
	..()

/datum/reagent/medicine/simethicone
	name = "Simethicone"
	id = "simethicone"
	description = "This strange liquid seems to have no bubbles on the surface."
	color = "#14AA46"

/datum/reagent/medicine/teporone
	name = "Teporone"
	id = "teporone"
	description = "This experimental plasma-based compound seems to regulate body temperature."
	reagent_state = LIQUID
	color = "#D782E6"
	addiction_chance = 20
	overdose_threshold = 50

/datum/reagent/medicine/teporone/on_mob_life(mob/living/M)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	description = "Haloperidol is a powerful antipsychotic and sedative. Will help control psychiatric problems, but may cause brain damage."
	reagent_state = LIQUID
	color = "#FFDCFF"

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/M)
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
	M.AdjustDruggy(-5)
	M.AdjustHallucinate(-5)
	M.AdjustJitter(-5)
	if(prob(50))
		M.Drowsy(3)
	if(prob(10))
		M.emote("drool")
	if(prob(20))
		M.adjustBrainLoss(1)
	..()

/datum/reagent/medicine/ether
	name = "Ether"
	id = "ether"
	description = "A strong anesthetic and sedative."
	reagent_state = LIQUID
	color = "#96DEDE"
	metabolization_rate = 0.1

/datum/reagent/medicine/ether/on_mob_life(mob/living/M)
	M.AdjustJitter(-25)
	switch(current_cycle)
		if(1 to 30)
			if(prob(7))
				M.emote("yawn")
		if(31 to 40)
			M.Drowsy(20)
		if(41 to INFINITY)
			M.Paralyse(15)
			M.Drowsy(20)
	..()

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	id = "syndicate_nanites"
	description = "Miniature medical robots that swiftly restore bodily damage. May begin to attack their host's cells in high amounts."
	reagent_state = SOLID
	color = "#555555"
	can_synth = FALSE

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-5*REAGENTS_EFFECT_MULTIPLIER) //A ton of healing - this is a 50 telecrystal investment.
	M.adjustFireLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustOxyLoss(-15*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustToxLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBrainLoss(-15*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustCloneLoss(-3*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/omnizine_diluted
	name = "Diluted Omnizine"
	id = "weak_omnizine"
	description = "Slowly heals all damage types. A far weaker substitute than actual omnizine."
	reagent_state = LIQUID
	color = "#DCDCDC"
	overdose_threshold = 30
	metabolization_rate = 0.1

/datum/reagent/medicine/omnizine_diluted/on_mob_life(mob/living/M)
	M.adjustToxLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustOxyLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/omnizine_diluted/overdose_process(mob/living/M, severity)
	M.adjustToxLoss(1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustOxyLoss(1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBruteLoss(1.5*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(1.5*REAGENTS_EFFECT_MULTIPLIER)

//virus-specific symptom reagents

/datum/reagent/medicine/synaphydramine
	name = "Diphen-Synaptizine"
	id = "synaphydramine"
	description = "Reduces drowsiness and hallucinations while also purging histamine from the body."
	color = "#EC536D" // rgb: 236, 83, 109

/datum/reagent/medicine/synaphydramine/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-5)
	if(holder.has_reagent("lsd"))
		holder.remove_reagent("lsd", 5)
	if(holder.has_reagent("histamine"))
		holder.remove_reagent("histamine", 5)
	M.AdjustHallucinate(-10)
	if(prob(30))
		M.adjustToxLoss(1)
	..()

//////////////////////////////
//		Synth-Meds			//
//////////////////////////////

//Degreaser: Mild Purgative / Lube Remover
/datum/reagent/medicine/degreaser
	name = "Degreaser"
	id = "degreaser"
	description = "An industrial degreaser which can be used to clean residual build-up from machinery and surfaces."
	reagent_state = LIQUID
	color = "#CC7A00"
	process_flags = SYNTHETIC

/datum/reagent/medicine/degreaser/on_mob_life(mob/living/M)
	if(prob(50))		//Same effects as coffee, to help purge ill effects like paralysis
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
		M.AdjustConfused(-5)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			if(R.id == "ultralube" || R.id == "lube")
				//Flushes lube and ultra-lube even faster than other chems
				M.reagents.remove_reagent(R.id, 5)
			else
				M.reagents.remove_reagent(R.id,1)
	..()

/datum/reagent/medicine/degreaser/reaction_turf(turf/simulated/T, volume)
	if(volume >= 1 && istype(T))
		if(T.wet)
			T.MakeDry(TURF_WET_LUBE)

//Liquid Solder: Mannitol
/datum/reagent/medicine/liquid_solder
	name = "Liquid Solder"
	id = "liquid_solder"
	description = "A solution formulated to clean and repair damaged connections in posibrains while in use."
	reagent_state = LIQUID
	color = "#D7B395"
	process_flags = SYNTHETIC

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/M)
	M.adjustBrainLoss(-3)
	..()



//Trek-Chems. DO NOT USE THES OUTSIDE OF BOTANY OR FOR VERY SPECIFIC PURPOSES. NEVER GIVE A RECIPE UNDER ANY CIRCUMSTANCES//
/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Restores bruising. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M)
	M.adjustBruteLoss(4*REAGENTS_EFFECT_MULTIPLIER)

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Restores fire damage. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/M)
	M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M)
	M.adjustFireLoss(4*REAGENTS_EFFECT_MULTIPLIER)


/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	id = "earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain."
	color = "#FFAF00"
	overdose_threshold = 25

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/M)
	M.adjustBruteLoss(-3 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(-3 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustOxyLoss(-15 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustToxLoss(-3 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustBrainLoss(2 * REAGENTS_EFFECT_MULTIPLIER) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	M.adjustCloneLoss(-1 * REAGENTS_EFFECT_MULTIPLIER)
	M.adjustStaminaLoss(-30 * REAGENTS_EFFECT_MULTIPLIER)
	M.SetJitter(min(max(0, M.jitteriness + 3), 30))
	M.SetDruggy(min(max(0, M.druggy + 10), 15)) //See above
	..()

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	M.SetHallucinate(min(max(0, M.hallucination + 10), 50))
	M.adjustToxLoss(5 * REAGENTS_EFFECT_MULTIPLIER)

/datum/reagent/medicine/corazone
	name = "Corazone"
	id = "corazone"
	description = "A medication used to treat pain, fever, and inflammation, along with heart attacks."
	color = "#F5F5F5"

// This reagent's effects are handled in heart attack handling code

/datum/reagent/medicine/nanocalcium
	name = "Nano-Calcium"
	id = "nanocalcium"
	description = "Highly advanced nanites equipped with calcium payloads designed to repair bones. Nanomachines son."
	color = "#9b3401"
	metabolization_rate = 0.5
	can_synth = FALSE

/datum/reagent/medicine/nanocalcium/on_mob_life(mob/living/carbon/human/M)
	switch(current_cycle)
		if(1 to 19)
			M.AdjustJitter(4)
			if(prob(10))
				to_chat(M, "<span class='warning'>Your skin feels hot and your veins are on fire!</span>")
		if(20 to 43)
			//If they have stimulants or stimulant drugs then just apply toxin damage instead.
			if(M.reagents.has_reagent("methamphetamine") || M.reagents.has_reagent("crank") || M.reagents.has_reagent("bath_salts") || M.reagents.has_reagent("stimulative_agent") || M.reagents.has_reagent("stimulants"))
				M.adjustToxLoss(10)
			else //apply debilitating effects
				if(prob(75))
					M.AdjustConfused(5)
				else
					M.AdjustWeakened(5)
		if(44)
			to_chat(M, "<span class='warning'>Your body goes rigid, you cannot move at all!</span>")
			M.AdjustWeakened(15)
		if(45 to INFINITY) // Start fixing bones | If they have stimulants or stimulant drugs in their system then the nanites won't work.
			if(M.reagents.has_reagent("methamphetamine") || M.reagents.has_reagent("crank") || M.reagents.has_reagent("bath_salts") || M.reagents.has_reagent("stimulative_agent") || M.reagents.has_reagent("stimulants"))
				return ..()
			else
				for(var/obj/item/organ/external/E in M.bodyparts)
					if(E.is_broken())
						if(prob(50)) // Each tick has a 50% chance of repearing a bone.
							to_chat(M, "<span class='notice'>You feel a burning sensation in your [E.name] as it straightens involuntarily!</span>")
							E.rejuvenate() //Repair it completely.
							break
	..()
