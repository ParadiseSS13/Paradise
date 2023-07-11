/datum/reagent/medicine
	name = "Medicine"
	id = "medicine"
	taste_description = "bitterness"
	harmless = TRUE

/datum/reagent/medicine/on_mob_life(mob/living/M)
	current_cycle++
	var/total_depletion_rate = metabolization_rate / M.metabolism_efficiency // Cache it

	handle_addiction(M, total_depletion_rate)
	sate_addiction(M)
	holder.remove_reagent(id, total_depletion_rate) //medicine reagents stay longer if you have a better metabolism
	return STATUS_UPDATE_NONE

/datum/reagent/medicine/hydrocodone
	name = "Hydrocodone"
	id = "hydrocodone"
	description = "An extremely effective painkiller; may have long term abuse consequences."
	reagent_state = LIQUID
	color = "#C805DC"
	metabolization_rate = 0.3 // Lasts 1.5 minutes for 15 units
	shock_reduction = 200
	taste_description = "numbness"

/datum/reagent/medicine/hydrocodone/on_mob_life(mob/living/M) //Needed so the hud updates when injested / removed from system
	var/update_flags = STATUS_UPDATE_HEALTH
	return ..() | update_flags

/datum/reagent/medicine/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "antiseptic"

	//makes you squeaky clean
/datum/reagent/medicine/sterilizine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		M.germ_level -= min(volume*20, M.germ_level)

/datum/reagent/medicine/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/medicine/sterilizine/reaction_turf(turf/T, volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/medicine/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat neuroleptic shock. Can be used to help remove disabling symptoms such as confusion."
	reagent_state = LIQUID
	color = "#FA46FA"
	overdose_threshold = 40
	harmless = FALSE
	taste_description = "stimulant"

/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	M.AdjustConfused(-10 SECONDS)
	M.AdjustDizzy(-10 SECONDS)
	M.SetSleeping(0)
	if(prob(50))
		update_flags |= M.adjustBrainLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/synaptizine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 3)
			M.emote(pick("groan","moan"))
		if(effect <= 8)
			update_flags |= M.adjustToxLoss(1, FALSE)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly and violently vomits!</span>")
			M.fakevomit(no_text = 1)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] staggers and drools, [M.p_their()] eyes bloodshot!</span>")
			M.Dizzy(16 SECONDS)
			M.Weaken(8 SECONDS)
		if(effect <= 15)
			update_flags |= M.adjustToxLoss(1, FALSE)
	return list(effect, update_flags)

/datum/reagent/medicine/mitocholide
	name = "Mitocholide"
	id = "mitocholide"
	description = "A specialized drug that stimulates the mitochondria of cells to encourage healing of internal organs."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "nurturing"

/datum/reagent/medicine/mitocholide/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		//Mitocholide is hard enough to get, it's probably fair to make this all internal organs
		for(var/obj/item/organ/internal/I in H.internal_organs)
			I.heal_internal_damage(0.4)
	return ..()

/datum/reagent/medicine/mitocholide/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/organ))
		var/obj/item/organ/Org = O
		if(!Org.is_robotic())
			Org.rejuvenate()

/datum/reagent/medicine/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A plasma mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 265K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#0000C8" // rgb: 200, 165, 220
	heart_rate_decrease = 1
	taste_description = "a safe refuge"

/datum/reagent/medicine/cryoxadone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE

	var/external_temp
	if(istype(M.loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = M.loc
		external_temp = C.air_contents.temperature
	else
		var/turf/T = get_turf(M)
		external_temp = T.temperature

	if(external_temp < TCRYO)
		update_flags |= M.adjustCloneLoss(-4, FALSE)
		update_flags |= M.adjustOxyLoss(-10, FALSE)
		update_flags |= M.adjustToxLoss(-3, FALSE)
		update_flags |= M.adjustBruteLoss(-12, FALSE)
		update_flags |= M.adjustFireLoss(-12, FALSE)

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/head/head = H.get_organ("head")
			if(head)
				head.status &= ~ORGAN_DISFIGURED

	return ..() | update_flags

/datum/reagent/medicine/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, Rezadone can effectively treat genetic damage as well as restoring minor wounds. Overdose will cause intense nausea and minor toxin damage."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "reformation"

/datum/reagent/medicine/rezadone/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.setCloneLoss(0, FALSE) // Rezadone is almost never used in favor of cryoxadone. Hopefully this will change that.
	update_flags |= M.adjustBruteLoss(-1, FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head = H.get_organ("head")
		if(head)
			head.status &= ~ORGAN_DISFIGURED
	return ..() | update_flags

/datum/reagent/medicine/rezadone/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	M.Dizzy(10 SECONDS)
	M.Jitter(10 SECONDS)
	return list(0, update_flags)

/datum/reagent/medicine/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antibiotic agent extracted from space fungus."
	reagent_state = LIQUID
	color = "#0AB478"
	metabolization_rate = 0.2
	taste_description = "antibiotics"

/datum/reagent/medicine/spaceacillin/on_mob_life(mob/living/M)
	var/list/organs_list = list()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		organs_list += C.internal_organs

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		organs_list += H.bodyparts

	for(var/X in organs_list)
		var/obj/item/organ/O = X
		if(O.germ_level < INFECTION_LEVEL_ONE)
			O.germ_level = 0	//cure instantly
		else if(O.germ_level < INFECTION_LEVEL_TWO)
			O.germ_level = max(M.germ_level - 25, 0)	//at germ_level == 500, this should cure the infection in 34 seconds
		else
			O.germ_level = max(M.germ_level - 10, 0)	// at germ_level == 1000, this will cure the infection in 1 minutes, 14 seconds

	organs_list.Cut()
	M.germ_level = max(M.germ_level - 20, 0) // Reduces the mobs germ level, too
	return ..()

/datum/reagent/medicine/silver_sulfadiazine
	name = "Silver Sulfadiazine"
	id = "silver_sulfadiazine"
	description = "This antibacterial compound is used to treat burn victims."
	reagent_state = LIQUID
	color = "#F0DC00"
	metabolization_rate = 3
	harmless = FALSE	//toxic if ingested, and I am NOT going to account for the difference
	taste_description = "burn cream"

/datum/reagent/medicine/silver_sulfadiazine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/silver_sulfadiazine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustFireLoss(-volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The silver sulfadiazine soothes your burns.</span>")
		if(method == REAGENT_INGEST)
			M.adjustToxLoss(0.5*volume)
			if(show_message)
				to_chat(M, "<span class='warning'>You feel sick...</span>")
	..()

/datum/reagent/medicine/styptic_powder
	name = "Styptic Powder"
	id = "styptic_powder"
	description = "Styptic (aluminum sulfate) powder helps control bleeding and heal physical wounds."
	reagent_state = LIQUID
	color = "#FF9696"
	metabolization_rate = 3
	harmless = FALSE
	taste_description = "wound cream"

/datum/reagent/medicine/styptic_powder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/styptic_powder/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustBruteLoss(-volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The styptic powder stings like hell as it closes some of your wounds!</span>")
				M.emote("scream")
		if(method == REAGENT_INGEST)
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
	taste_description = "salt"

/datum/reagent/medicine/salglu_solution/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(ishuman(M) && prob(33))
		var/mob/living/carbon/human/H = M
		if(!(NO_BLOOD in H.dna.species.species_traits))//do not restore blood on things with no blood by nature.
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 1
	return ..() | update_flags

/datum/reagent/medicine/synthflesh
	name = "Synthflesh"
	id = "synthflesh"
	description = "A resorbable microfibrillar collagen and protein mixture that can rapidly heal injuries when applied topically."
	reagent_state = LIQUID
	color = "#FFEBEB"
	penetrates_skin = TRUE
	taste_description = "blood"

/datum/reagent/medicine/synthflesh/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume, show_message = 1)
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustBruteLoss(-1.5 * volume)
			M.adjustFireLoss(-1.5 * volume)
			if(show_message)
				to_chat(M, "<span class='notice'>The synthetic flesh integrates itself into your wounds, healing you.</span>")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(HAS_TRAIT_FROM(H, TRAIT_HUSK, BURN) && H.getFireLoss() <= UNHUSK_DAMAGE_THRESHOLD && (H.reagents.get_reagent_amount("synthflesh") + volume >= SYNTHFLESH_UNHUSK_AMOUNT))
				H.cure_husk(BURN)
				// Could be a skeleton or a golem or sth, avoid phrases like "burnt flesh" and "burnt skin"
				H.visible_message("<span class='nicegreen'>The squishy liquid coats [H]'s burns. [H] looks a lot healthier!</span>")
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
	taste_description = "dust"

/datum/reagent/medicine/charcoal/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(50))
		for(var/datum/reagent/R in M.reagents.reagent_list)
			if(R != src)
				M.reagents.remove_reagent(R.id,1)
	return ..() | update_flags

/datum/reagent/medicine/omnizine
	name = "Omnizine"
	id = "omnizine"
	description = "Omnizine is a highly potent healing medication that can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	overdose_threshold = 30
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 5
	harmless = FALSE
	taste_description = "health"

/datum/reagent/medicine/omnizine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(50))
		M.AdjustLoseBreath(-2 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/omnizine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1) //lesser
		M.AdjustStuttering(2 SECONDS)
		if(effect <= 1)
			M.visible_message("<span class='warning'>[M] suddenly clutches [M.p_their()] gut!</span>")
			M.emote("scream")
			M.Weaken(8 SECONDS)
		else if(effect <= 3)
			M.visible_message("<span class='warning'>[M] completely spaces out for a moment.</span>")
			M.AdjustConfused(30 SECONDS)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] stumbles and staggers.</span>")
			M.Dizzy(10 SECONDS)
			M.Weaken(6 SECONDS)
		else if(effect <= 7)
			M.visible_message("<span class='warning'>[M] shakes uncontrollably.</span>")
			M.Jitter(60 SECONDS)
	else if(severity == 2) // greater
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] suddenly clutches [M.p_their()] gut!</span>")
			M.emote("scream")
			M.Weaken(14 SECONDS)
		else if(effect <= 5)
			M.visible_message("<span class='warning'>[M] jerks bolt upright, then collapses!</span>")
			M.Paralyse(10 SECONDS)
			M.Weaken(8 SECONDS)
		else if(effect <= 8)
			M.visible_message("<span class='warning'>[M] stumbles and staggers.</span>")
			M.Dizzy(10 SECONDS)
			M.Weaken(6 SECONDS)
	return list(effect, update_flags)

/datum/reagent/medicine/calomel
	name = "Calomel"
	id = "calomel"
	description = "This potent purgative rids the body of impurities. It is highly toxic however and close supervision is required."
	reagent_state = LIQUID
	color = "#22AB35"
	metabolization_rate = 0.8
	harmless = FALSE
	taste_description = "a painful cleansing"

/datum/reagent/medicine/calomel/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,5)
	if(M.health > 20)
		update_flags |= M.adjustToxLoss(5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(6))
		M.fakevomit()
	return ..() | update_flags

/datum/reagent/medicine/potass_iodide
	name = "Potassium Iodide"
	id = "potass_iodide"
	description = "Potassium Iodide is a medicinal drug used to counter the effects of radiation poisoning."
	reagent_state = LIQUID
	color = "#B4DCBE"
	taste_description = "cleansing"

/datum/reagent/medicine/potass_iodide/on_mob_life(mob/living/M)
	M.radiation = max(0, M.radiation - 25)
	return ..()

/datum/reagent/medicine/pen_acid
	name = "Pentetic Acid"
	id = "pen_acid"
	description = "Pentetic Acid is an aggressive chelation agent. May cause tissue damage. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	harmless = FALSE
	taste_description = "a purge"

/datum/reagent/medicine/pen_acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,4)
	M.radiation = max(0, M.radiation-70)
	if(prob(75))
		update_flags |= M.adjustToxLoss(-4*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(33))
		update_flags |= M.adjustBruteLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/sal_acid
	name = "Salicylic Acid"
	id = "sal_acid"
	description = "This is a is a standard salicylate pain reliever and fever reducer."
	reagent_state = LIQUID
	color = "#B54848"
	metabolization_rate = 0.1
	shock_reduction = 25
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "relief"

/datum/reagent/medicine/sal_acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(55))
		update_flags |= M.adjustBruteLoss(-2 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(M.bodytemperature > 310.15)
		M.bodytemperature = max(310.15, M.bodytemperature - 10)
	return ..() | update_flags

/datum/reagent/medicine/menthol
	name = "Menthol"
	id = "menthol"
	description = "Menthol relieves burns and aches while providing a cooling sensation."
	reagent_state = LIQUID
	color = "#F0F9CA"
	metabolization_rate = 0.1
	taste_description = "soothing"

/datum/reagent/medicine/menthol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(55))
		update_flags |= M.adjustFireLoss(-2 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(M.bodytemperature > 280)
		M.bodytemperature = max(280, M.bodytemperature - 10)
	return ..() | update_flags

/datum/reagent/medicine/salbutamol
	name = "Salbutamol"
	id = "salbutamol"
	description = "Salbutamol is a common bronchodilation medication for asthmatics. It may help with other breathing problems as well."
	reagent_state = LIQUID
	color = "#00FFFF"
	metabolization_rate = 0.2
	taste_description = "safety"

/datum/reagent/medicine/salbutamol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustOxyLoss(-6*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	M.AdjustLoseBreath(-8 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/perfluorodecalin
	name = "Perfluorodecalin"
	id = "perfluorodecalin"
	description = "This experimental perfluoronated solvent has applications in liquid breathing and tissue oxygenation. Use with caution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.2
	overdose_threshold = 4
	allowed_overdose_process = TRUE
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "oxygenation"

/datum/reagent/medicine/perfluorodecalin/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE

	update_flags |= M.adjustOxyLoss(-25*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(33))
		update_flags |= M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)

	return ..() | update_flags

/datum/reagent/medicine/perfluorodecalin/overdose_process(mob/living/M)
	M.LoseBreath(12 SECONDS)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/medicine/ephedrine
	name = "Ephedrine"
	id = "ephedrine"
	description = "Ephedrine is a plant-derived stimulant."
	reagent_state = LIQUID
	color = "#C8A5DC"
	metabolization_rate = 0.3
	overdose_threshold = 35
	addiction_chance = 1
	addiction_chance = 10
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "stimulation"

//super weak antistun chem, barely any downside
/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	M.AdjustParalysis(-2 SECONDS)
	M.AdjustStunned(-2 SECONDS)
	M.AdjustWeakened(-2 SECONDS)
	M.AdjustKnockDown(-2 SECONDS)
	update_flags |= M.adjustStaminaLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	M.AdjustLoseBreath(-2 SECONDS, bound_lower = 10 SECONDS)
	if(M.getOxyLoss() > 75)
		update_flags |= M.adjustOxyLoss(-1, FALSE)
	if(M.health < 0 || M.health > 0 && prob(33))
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/ephedrine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
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
			M.visible_message("<span class='warning'>[M.name] staggers and drools, [M.p_their()] eyes bloodshot!</span>")
			M.Dizzy(4 SECONDS)
			M.Weaken(6 SECONDS)
		if(effect <= 15)
			M.emote("collapse")
	return list(effect, update_flags)

/datum/reagent/medicine/diphenhydramine
	name = "Diphenhydramine"
	id = "diphenhydramine"
	description = "Anti-allergy medication. May cause drowsiness, do not operate heavy machinery while using this."
	reagent_state = LIQUID
	color = "#5BCBE1"
	addiction_chance = 1
	addiction_threshold = 10
	harmless = FALSE
	taste_description = "antihistamine"

/datum/reagent/medicine/diphenhydramine/on_mob_life(mob/living/M)
	M.AdjustJitter(-40 SECONDS)
	M.reagents.remove_reagent("histamine",3)
	M.reagents.remove_reagent("itching_powder",3)
	if(prob(7))
		M.emote("yawn")
	if(prob(3))

		M.AdjustDrowsy(2 SECONDS)
		M.visible_message("<span class='notice'>[M] looks a bit dazed.</span>")
	return ..()

/datum/reagent/medicine/morphine
	name = "Morphine"
	id = "morphine"
	description = "A strong but highly addictive opiate painkiller with sedative side effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 15
	metabolization_rate = 0.25 //Lasts for 120 seconds
	shock_reduction = 50
	harmless = FALSE
	taste_description = "a delightful numbing"
	allowed_overdose_process = TRUE

/datum/reagent/medicine/morphine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-50 SECONDS)
	switch(current_cycle)
		if(1 to 15)
			if(prob(7))
				M.emote("yawn")
		if(16 to 35)
			M.Drowsy(40 SECONDS)
		if(36 to INFINITY)
			M.Paralyse(30 SECONDS)
			M.Drowsy(40 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/oculine
	name = "Oculine"
	id = "oculine"
	description = "Oculine is a saline eye medication with mydriatic and antibiotic effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "clarity"

/datum/reagent/medicine/oculine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(80))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/organ/internal/eyes/E = C.get_int_organ(/obj/item/organ/internal/eyes)
			if(istype(E))
				E.heal_internal_damage(1)
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(istype(ears))
				ears.heal_internal_damage(1)
				if(ears.damage < 25 && prob(30))
					C.SetDeaf(0)
		M.AdjustEyeBlurry(-2 SECONDS)
	if(prob(50))
		update_flags |= M.cure_nearsighted(EYE_DAMAGE, FALSE)
	if(prob(30))
		update_flags |= M.cure_blind(EYE_DAMAGE, FALSE)
		M.SetEyeBlind(0)
	return ..() | update_flags

/datum/reagent/medicine/atropine
	name = "Atropine"
	id = "atropine"
	description = "Atropine is a potent cardiac resuscitant but it can causes confusion, dizzyness and hyperthermia."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.2
	overdose_threshold = 25
	harmless = FALSE
	taste_description = "a moment of respite"

/datum/reagent/medicine/atropine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDizzy(2 SECONDS)
	M.Confused(10 SECONDS)
	if(prob(4))
		M.emote("collapse")
	M.AdjustLoseBreath(-10 SECONDS, bound_lower = 10 SECONDS)
	if(M.getOxyLoss() > 65)
		update_flags |= M.adjustOxyLoss(-10*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(M.health < -25)
		update_flags |= M.adjustToxLoss(-1, FALSE)
		update_flags |= M.adjustBruteLoss(-3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	else if(M.health > -60)
		update_flags |= M.adjustToxLoss(1, FALSE)
	M.reagents.remove_reagent("sarin", 20)
	return ..() | update_flags

/datum/reagent/medicine/epinephrine
	name = "Epinephrine"
	id = "epinephrine"
	description = "Epinephrine is a potent neurotransmitter, used in medical emergencies to halt anaphylactic shock and prevent cardiac arrest."
	reagent_state = LIQUID
	color = "#96B1AE"
	metabolization_rate = 0.2
	overdose_threshold = 20
	harmless = FALSE
	taste_description = "borrowed time"

/datum/reagent/medicine/epinephrine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(prob(5))
		M.SetSleeping(0)
	if(prob(5))
		update_flags |= M.adjustBrainLoss(-1, FALSE)
	holder.remove_reagent("histamine", 15)
	M.AdjustLoseBreath(-2 SECONDS, bound_lower = 6 SECONDS)
	if(M.getOxyLoss() > 35)
		update_flags |= M.adjustOxyLoss(-10*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(M.health < -10 && M.health > -65)
		update_flags |= M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/epinephrine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
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
			M.visible_message("<span class='warning'>[M] staggers and drools, [M.p_their()] eyes bloodshot!</span>")
			M.Dizzy(4 SECONDS)
			M.Weaken(6 SECONDS)
		if(effect <= 15)
			M.emote("collapse")
	return list(effect, update_flags)

/datum/reagent/medicine/lazarus_reagent
	name = "Lazarus Reagent"
	id = "lazarus_reagent"
	description = "A bioluminescent green fluid that seems to move on its own."
	reagent_state = LIQUID
	color = "#A0E85E"
	metabolization_rate = 0.2
	taste_description = "life"
	harmless = FALSE
	var/revive_type = SENTIENCE_ORGANIC //So you can't revive boss monsters or robots with it

/datum/reagent/medicine/lazarus_reagent/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		update_flags |= M.adjustBruteLoss(2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/lazarus_reagent/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(volume < 1)
		// gotta pay to play
		return ..()
	if(isanimal(M) && method == REAGENT_TOUCH)
		var/mob/living/simple_animal/SM = M
		if(SM.sentience_type != revive_type) // No reviving Ash Drakes for you
			return
		if(SM.stat == DEAD)
			SM.revive()
			SM.loot.Cut() //no abusing Lazarus Reagent for farming unlimited resources
			SM.visible_message("<span class='warning'>[SM] seems to rise from the dead!</span>")

	if(iscarbon(M))
		if(method == REAGENT_INGEST || (method == REAGENT_TOUCH && prob(25)))
			if(M.stat == DEAD)
				if(M.getBruteLoss() + M.getFireLoss() + M.getCloneLoss() >= 150)
					if(ischangeling(M))
						return
					M.delayed_gib()
					return
				if(!M.ghost_can_reenter())
					M.visible_message("<span class='warning'>[M] twitches slightly, but is otherwise unresponsive!</span>")
					return

				if(!M.suiciding && !HAS_TRAIT(M, TRAIT_HUSK) && !HAS_TRAIT(M, TRAIT_BADDNA))
					var/time_dead = world.time - M.timeofdeath
					M.visible_message("<span class='warning'>[M] seems to rise from the dead!</span>")
					M.adjustCloneLoss(50)
					M.setOxyLoss(0)
					M.adjustBruteLoss(rand(0, 15))
					M.adjustToxLoss(rand(0, 15))
					M.adjustFireLoss(rand(0, 15))
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						H.decaylevel = 0
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

					M.grab_ghost()
					M.update_revive()
					add_attack_logs(M, M, "Revived with lazarus reagent") //Yes, the logs say you revived yourself.
					SSblackbox.record_feedback("tally", "players_revived", 1, "lazarus_reagent")
	..()

/datum/reagent/medicine/sanguine_reagent
	name = "Sanguine Reagent"
	id = "sanguine_reagent"
	description = "A deeply crimson almost-gel that can mimic blood, regardless of type."
	color = "#770101"
	taste_description = "coppery fuel"
	harmless = FALSE
	overdose_threshold = 15

/datum/reagent/medicine/sanguine_reagent/on_mob_life(mob/living/M)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M

	if(NO_BLOOD in H.dna.species.species_traits)
		return ..()

	if(H.blood_volume < BLOOD_VOLUME_NORMAL)
		switch(current_cycle)
			if(1)
				H.blood_volume += 1
			if(2 to 25)
				H.blood_volume += 3
			else
				H.blood_volume += 5

	return ..()

/datum/reagent/medicine/sanguine_reagent/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(volume < 20)
		if(prob(10))
			to_chat(H, "<span class='warning>You cough up some congealed blood.</span>")
			H.vomit(blood = TRUE, stun = FALSE) //mostly visual
		else if(prob(10))
			var/overdose_message = pick("Your vision is tinted red for a moment.", "You can hear your heart beating.")
			to_chat(H, "<span class='warning'>[overdose_message]</span>")
	else
		if(prob(10))
			to_chat(H, "<span class='danger'>You choke on congealed blood!</span>")
			H.AdjustLoseBreath(2 SECONDS)
			H.vomit(blood = TRUE, stun = FALSE)
		else if(prob(10))
			var/overdose_message = pick("You're seeing red!", "Your heartbeat thunders in your ears!", "Your veins writhe under your skin!")
			to_chat(H, "<span class='danger'>[overdose_message]</span>")
			H.adjustBruteLoss(6)
			if(H.client?.prefs.colourblind_mode == COLOURBLIND_MODE_NONE)
				H.client.color = "red"
				addtimer(VARSET_CALLBACK(H.client, color, ""), 6 SECONDS)
	return list(0, update_flags)

/datum/reagent/medicine/osseous_reagent
	name = "Osseous Reagent"
	id = "osseous_reagent"
	description = "A solution of pinkish gel with white shards floating in it, which is supposedly able to be processed into bone gel."
	color = "#c9abab"
	taste_description = "chunky marrow"
	harmless = FALSE
	overdose_threshold = 30 //so a single shotgun dart can't cause the tumor effect

/datum/reagent/medicine/osseous_reagent/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/osseous_reagent/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)

	if(ishuman(M) && prob(5))
		var/mob/living/carbon/human/H = M
		if(!H.get_int_organ(/obj/item/organ/internal/bone_tumor))
			new/obj/item/organ/internal/bone_tumor(H)

	return ..()

/datum/reagent/medicine/mannitol
	name = "Mannitol"
	id = "mannitol"
	description = "Mannitol is a sugar alcohol that can help alleviate cranial swelling."
	color = "#D1D1F1"
	taste_description = "sweetness"

/datum/reagent/medicine/mannitol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBrainLoss(-3, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/mutadone
	name = "Mutadone"
	id = "mutadone"
	description = "Mutadone is an experimental bromide that can cure genetic abnomalities."
	color = "#5096C8"
	taste_description = "cleanliness"

/datum/reagent/medicine/mutadone/on_mob_life(mob/living/carbon/human/M)
	if(M.mind && M.mind.assigned_role == "Cluwne") // HUNKE
		..()
		return
	M.SetJitter(0)
	var/needs_update = length(M.active_mutations)

	if(needs_update)
		for(var/block = 1; block<=DNA_SE_LENGTH; block++)
			if(!(block in M.dna.default_blocks))
				M.dna.SetSEState(block, FALSE, TRUE)
				singlemutcheck(M, block, MUTCHK_FORCED)
		M.dna.UpdateSE()

		M.dna.struc_enzymes = M.dna.struc_enzymes_original

		// Might need to update appearance for hulk etc.
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.update_mutations()
	return ..()

/datum/reagent/medicine/antihol
	name = "Antihol"
	id = "antihol"
	description = "A medicine which quickly eliminates alcohol in the body."
	color = "#009CA8"
	taste_description = "sobriety"

/datum/reagent/medicine/antihol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSlur(0)
	M.AdjustDrunk(-8 SECONDS)
	M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 8)
	if(M.getToxLoss() <= 25)
		update_flags |= M.adjustToxLoss(-2.0, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/stimulants
	name = "Stimulants"
	id = "stimulants"
	description = "An illegal compound that dramatically enhances the body's performance and healing capabilities."
	color = "#C8A5DC"
	harmless = FALSE
	can_synth = FALSE
	taste_description = "<span class='userdanger'>an unstoppable force</span>"

/datum/reagent/medicine/stimulants/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume > 5)
		update_flags |= M.adjustOxyLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustBruteLoss(-10*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-10*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.setStaminaLoss(0, FALSE)
		M.SetSlowed(0)
		M.AdjustDizzy(-20 SECONDS)
		M.AdjustDrowsy(-20 SECONDS)
		M.SetConfused(0)
		M.SetSleeping(0)
		var/status = CANSTUN | CANWEAKEN | CANPARALYSE
		M.status_flags &= ~status
	else
		M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
		update_flags |= M.adjustToxLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(1, FALSE)
		if(prob(10))
			M.Stun(6 SECONDS)

	return ..() | update_flags

/datum/reagent/medicine/stimulants/on_mob_delete(mob/living/M)
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE
	..()

//the highest end antistun chem, removes stun and stamina rapidly.
/datum/reagent/medicine/stimulative_agent
	name = "Stimulative Agent"
	id = "stimulative_agent"
	description = "Increases run speed and eliminates stuns, can heal minor damage. If overdosed it will deal toxin damage and be less effective for healing stamina."
	color = "#C8A5DC"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 60
	harmless = FALSE
	can_synth = FALSE

/datum/reagent/medicine/stimulative_agent/on_mob_add(mob/living/L)
	ADD_TRAIT(L, TRAIT_GOTTAGOFAST, id)

/datum/reagent/medicine/stimulative_agent/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustParalysis(-6 SECONDS)
	M.AdjustStunned(-6 SECONDS)
	M.AdjustWeakened(-6 SECONDS)
	M.AdjustKnockDown(-6 SECONDS)
	update_flags |= M.adjustStaminaLoss(-40 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/stimulative_agent/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_GOTTAGOFAST, id)
	..()

/datum/reagent/medicine/stimulative_agent/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustStaminaLoss(2.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		M.AdjustLoseBreath(2 SECONDS)
	return list(0, update_flags)

/datum/reagent/medicine/stimulative_agent/changeling
	id = "stimulative_cling"

/datum/reagent/medicine/stimulative_agent/changeling/on_mob_add(mob/living/L)
	return

/datum/reagent/medicine/stimulative_agent/changeling/on_mob_delete(mob/living/L)
	return

/datum/reagent/medicine/insulin
	name = "Insulin"
	id = "insulin"
	description = "A hormone generated by the pancreas responsible for metabolizing carbohydrates and fat in the bloodstream."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "tiredness"

/datum/reagent/medicine/insulin/on_mob_life(mob/living/M)
	M.reagents.remove_reagent("sugar", 5)
	return ..()

/datum/reagent/heparin
	name = "Heparin"
	id = "heparin"
	description = "An anticoagulant used in heart surgeries, and in the treatment of heart attacks and blood clots."
	reagent_state = LIQUID
	color = "#eee6da"
	overdose_threshold = 20
	taste_description = "bitterness"

/datum/reagent/heparin/on_mob_life(mob/living/M)
	M.reagents.remove_reagent("cholesterol", 2)
	return ..()

/datum/reagent/heparin/overdose_process(mob/living/carbon/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.vomit(0, TRUE, FALSE)
			M.blood_volume = max(M.blood_volume - rand(5, 10), 0)
		else if(effect <= 4)
			M.vomit(0, TRUE, FALSE)
			M.blood_volume = max(M.blood_volume - rand(1, 2), 0)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] is bleeding from [M.p_their()] very pores!</span>")
			M.bleed(rand(10, 20))
		else if(effect <= 4)
			M.vomit(0, TRUE, FALSE)
			M.blood_volume = max(M.blood_volume - rand(5, 10), 0)
		else if(effect <= 8)
			M.vomit(0, TRUE, FALSE)
			M.blood_volume = max(M.blood_volume - rand(1, 2), 0)
	return list(effect, update_flags)


/datum/reagent/medicine/teporone
	name = "Teporone"
	id = "teporone"
	description = "This experimental plasma-based compound seems to regulate body temperature."
	reagent_state = LIQUID
	color = "#D782E6"
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 10
	overdose_threshold = 50
	taste_description = "warmth and stability"

/datum/reagent/medicine/teporone/on_mob_life(mob/living/M)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/medicine/haloperidol
	name = "Haloperidol"
	id = "haloperidol"
	description = "Haloperidol is a powerful antipsychotic and sedative. Will help control psychiatric problems, but may cause brain damage."
	reagent_state = LIQUID
	color = "#FFDCFF"
	taste_description = "stability"
	harmless = FALSE
	var/list/drug_list = list("crank", "methamphetamine", "space_drugs", "synaptizine", "psilocybin", "ephedrine", "epinephrine", "stimulants", "stimulative_agent", "bath_salts", "lsd", "thc")

/datum/reagent/medicine/haloperidol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	for(var/I in M.reagents.reagent_list)
		var/datum/reagent/R = I
		if(drug_list.Find(R.id))
			M.reagents.remove_reagent(R.id, 5)
	M.AdjustDruggy(-10 SECONDS)
	M.AdjustHallucinate(-5 SECONDS)
	M.AdjustJitter(-10 SECONDS)
	if(prob(40))
		M.EyeBlurry(10 SECONDS)
	if(prob(75))
		M.Confused(6 SECONDS)
	if(prob(10))
		M.emote("drool")
	if(prob(20))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/ether
	name = "Ether"
	id = "ether"
	description = "A strong anesthetic and sedative."
	reagent_state = LIQUID
	color = "#96DEDE"
	metabolization_rate = 0.1
	harmless = FALSE
	taste_description = "sleepiness"

/datum/reagent/medicine/ether/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-50 SECONDS)
	switch(current_cycle)
		if(1 to 30)
			if(prob(7))
				M.emote("yawn")
		if(31 to 40)
			M.Drowsy(40 SECONDS)
		if(41 to INFINITY)
			M.Paralyse(30 SECONDS)
			M.Drowsy(40 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/syndicate_nanites //Used exclusively by Syndicate medical cyborgs
	name = "Restorative Nanites"
	id = "syndicate_nanites"
	description = "Miniature medical robots that swiftly restore bodily damage. May begin to attack their host's cells in high amounts."
	reagent_state = SOLID
	color = "#555555"
	can_synth = FALSE
	taste_description = "bodily perfection"

/datum/reagent/medicine/syndicate_nanites/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE) //A ton of healing - this is a 50 telecrystal investment.
	update_flags |= M.adjustFireLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustOxyLoss(-15*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustToxLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustBrainLoss(-15*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustCloneLoss(-3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/omnizine_diluted
	name = "Diluted Omnizine"
	id = "weak_omnizine"
	description = "Slowly heals all damage types. A far weaker substitute than actual omnizine."
	reagent_state = LIQUID
	color = "#DCDCDC"
	overdose_threshold = 30
	metabolization_rate = 0.1
	harmless = FALSE
	taste_description = "faint hope"

/datum/reagent/medicine/omnizine_diluted/godblood
	name = "Godblood"
	id = "godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150

/datum/reagent/medicine/omnizine_diluted/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustOxyLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustBruteLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(-0.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/omnizine_diluted/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustOxyLoss(1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustBruteLoss(1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return list(0, update_flags)

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
	taste_description = "overclocking"

/datum/reagent/medicine/degreaser/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(50))
		M.AdjustConfused(-10 SECONDS)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			if(R.id == "ultralube" || R.id == "lube")
				//Flushes lube and ultra-lube even faster than other chems
				M.reagents.remove_reagent(R.id, 5)
			else
				M.reagents.remove_reagent(R.id,1)
	return ..() | update_flags

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
	taste_description = "heavy metals"

/datum/reagent/medicine/liquid_solder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBrainLoss(-3, FALSE)
	return ..() | update_flags



//Trek-Chems. DO NOT USE THES OUTSIDE OF BOTANY OR FOR VERY SPECIFIC PURPOSES. NEVER GIVE A RECIPE UNDER ANY CIRCUMSTANCES//
/datum/reagent/medicine/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Restores bruising. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "knitting wounds"

/datum/reagent/medicine/bicaridine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/bicaridine/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(4*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Restores fire damage. Overdose causes it instead."
	reagent_state = LIQUID
	color = "#C8A5DC"
	overdose_threshold = 30
	harmless = FALSE
	taste_description = "soothed burns"

/datum/reagent/medicine/kelotane/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/kelotane/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(4*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags


/datum/reagent/medicine/earthsblood //Created by ambrosia gaia plants
	name = "Earthsblood"
	id = "earthsblood"
	description = "Ichor from an extremely powerful plant. Great for restoring wounds, but it's a little heavy on the brain."
	color = "#FFAF00"
	overdose_threshold = 25
	addiction_threshold = 50
	addiction_chance = 5
	harmless = FALSE
	taste_description = "a gift from nature"

/datum/reagent/medicine/earthsblood/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle <= 25) //10u has to be processed before u get into THE FUN ZONE
		update_flags |= M.adjustBruteLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustOxyLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustCloneLoss(-0.1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustBrainLoss(1 * REAGENTS_EFFECT_MULTIPLIER, FALSE) //This does, after all, come from ambrosia, and the most powerful ambrosia in existence, at that!
	else
		update_flags |= M.adjustBruteLoss(-5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustOxyLoss(-3 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(-3 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustCloneLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		M.AdjustJitter(6 SECONDS, 0, 60 SECONDS)
		update_flags |= M.adjustBrainLoss(2 * REAGENTS_EFFECT_MULTIPLIER, FALSE) //See above
	M.AdjustDruggy(10 SECONDS, 0, 15 SECONDS)
	return ..() | update_flags

/datum/reagent/medicine/earthsblood/on_mob_add(mob/living/M)
	..()
	ADD_TRAIT(M, TRAIT_PACIFISM, type)

/datum/reagent/medicine/earthsblood/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_PACIFISM, type)
	..()

/datum/reagent/medicine/earthsblood/overdose_process(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustHallucinate(5 SECONDS, 0, 60 SECONDS)
	if(current_cycle > 25)
		update_flags |= M.adjustToxLoss(4 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		if(current_cycle > 100) //podpeople get out reeeeeeeeeeeeeeeeeeeee
			update_flags |= M.adjustToxLoss(6 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return list(0, update_flags)

/datum/reagent/medicine/corazone
	name = "Corazone"
	id = "corazone"
	description = "A medication used to treat pain, fever, and inflammation, along with heart attacks."
	color = "#F5F5F5"
	taste_description = "a brief respite"

// This reagent's effects are handled in heart attack handling code

/datum/reagent/medicine/nanocalcium
	name = "Nano-Calcium"
	id = "nanocalcium"
	description = "Highly advanced nanites equipped with an unknown payload designed to repair a body. Nanomachines son."
	color = "#9b3401"
	metabolization_rate = 0.5
	can_synth = FALSE
	harmless = FALSE
	taste_description = "2 minutes of suffering"
	var/list/stimulant_list = list("methamphetamine", "crank", "bath_salts", "stimulative_agent", "stimulants")

/datum/reagent/medicine/nanocalcium/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/has_stimulant = FALSE
	for(var/I in M.reagents.reagent_list)
		var/datum/reagent/R = I
		if(stimulant_list.Find(R.id))
			has_stimulant = TRUE
	switch(current_cycle)
		if(1 to 19)
			M.AdjustJitter(8 SECONDS)
			if(prob(10))
				to_chat(M, "<span class='warning'>Your skin feels hot and your veins are on fire!</span>")
				update_flags |= M.adjustFireLoss(1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
			for(var/datum/reagent/R in M.reagents.reagent_list)
				if(stimulant_list.Find(R.id))
					M.reagents.remove_reagent(R.id, 0.5) //We will be generous (for nukies really) and purge out the chemicals during this phase, so they don't fucking die during the next phase. Of course, if they try to use adrenals in the next phase, well...
		if(20 to 43)
			//If they have stimulants or stimulant drugs then just apply toxin damage instead.
			if(has_stimulant == TRUE)
				update_flags |= M.adjustToxLoss(10, FALSE)
			else //apply debilitating effects
				if(prob(75))
					M.AdjustConfused(4 SECONDS)
				else
					M.AdjustKnockDown(10 SECONDS) //You can still crawl around a bit for now, but soon suffering kicks in.
		if(44)
			to_chat(M, "<span class='warning'>Your body goes rigid, you cannot move at all!</span>")
			M.AdjustWeakened(15 SECONDS)
		if(45 to INFINITY) // Start fixing bones | If they have stimulants or stimulant drugs in their system then the nanites won't work.
			if(has_stimulant == TRUE)
				return ..()
			else
				for(var/obj/item/organ/external/E in M.bodyparts)
					if(E.status & (ORGAN_INT_BLEEDING | ORGAN_BROKEN | ORGAN_SPLINTED | ORGAN_BURNT)) //I can't just check for !E.status
						to_chat(M, "<span class='notice'>You feel a burning sensation in your [E.name] as it straightens involuntarily!</span>")
						E.rejuvenate() //Repair it completely.
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					for(var/obj/item/organ/internal/I in M.internal_organs) // 60 healing to all internal organs.
						I.heal_internal_damage(4)
					if(H.blood_volume < BLOOD_VOLUME_NORMAL * 0.7)// If below 70% blood, regenerate 150 units total
						H.blood_volume += 10
					for(var/datum/disease/critical/heart_failure/HF in H.viruses)
						HF.cure() //Won't fix a stopped heart, but it will sure fix a critical one. Shock is not fixed as healing will fix it
					for(var/obj/item/organ/O as anything in (H.internal_organs + H.bodyparts))
						O.germ_level = 0
				if(M.health < 40)
					update_flags |= M.adjustOxyLoss(-5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
					update_flags |= M.adjustToxLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
					update_flags |= M.adjustBruteLoss(-3 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
					update_flags |= M.adjustFireLoss(-3 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
				else
					if(prob(25))
						to_chat(M, "<span class='warning'>Your skin feels like it is ripping apart and your veins are on fire!</span>") //It is experimental and does cause scars, after all.
						update_flags |= M.adjustBruteLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
						update_flags |= M.adjustFireLoss(1.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/lavaland_extract
	name = "Lavaland Extract"
	id = "lavaland_extract"
	description = "An extract of lavaland atmospheric and mineral elements. Heals the user in small doses, but is extremely toxic otherwise."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 3 //To prevent people stacking massive amounts of a very strong healing reagent
	harmless = FALSE
	can_synth = FALSE

/datum/reagent/medicine/lavaland_extract/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(-5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/medicine/lavaland_extract/overdose_process(mob/living/M) // This WILL be brutal
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustConfused(10 SECONDS)
	update_flags |= M.adjustBruteLoss(3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustFireLoss(3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	update_flags |= M.adjustToxLoss(3*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags
