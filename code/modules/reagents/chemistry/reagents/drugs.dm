/*
* increases the probability of bad effects from stimulantive chems based on the duration of exposure (in volume)
* at 10 volume the mod is 1
* at 20 volume the mod is 2, and so on
*/
#define DRAWBACK_CHANCE_MODIFIER(duration) 0.1 * duration

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if((M.mobility_flags & MOBILITY_MOVE) && !M.restrained())
			step(M, pick(GLOB.cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	return ..()

/datum/reagent/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	description = "A highly potent hallucinogenic substance. Far out, maaaan."
	reagent_state = LIQUID
	color = "#0000D8"
	taste_description = "a magical journey"

/datum/reagent/lsd/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	M.AdjustHallucinate(10 SECONDS)
	return ..() | update_flags

/datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#9087A2"
	metabolization_rate = 0.2
	addiction_chance = 15
	addiction_threshold = 10
	heart_rate_decrease = 1
	taste_description = "a synthetic high"

/datum/reagent/space_drugs/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	if(isturf(M.loc) && !isspaceturf(M.loc))
		if((M.mobility_flags & MOBILITY_MOVE) && !M.restrained())
			step(M, pick(GLOB.cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	return ..() | update_flags

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	taste_description = "visions"

/datum/reagent/psilocybin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(60 SECONDS)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(2 SECONDS)
			M.Dizzy(10 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(2 SECONDS)
			M.Jitter(20 SECONDS)
			M.Dizzy(20 SECONDS)
			M.Druggy(70 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(2 SECONDS)
			M.Jitter(40 SECONDS)
			M.Dizzy(40 SECONDS)
			M.Druggy(80 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 35
	addiction_chance = 15
	addiction_threshold = 10
	minor_addiction = TRUE
	heart_rate_increase = 1
	taste_description = "calm"

/datum/reagent/nicotine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/smoke_message = pick("You feel relaxed.", "You feel calmed.", "You feel less stressed.", "You feel more placid.", "You feel more undivided.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	return ..() | update_flags

/datum/reagent/nicotine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks nervous!</span>")
			M.AdjustConfused(30 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			M.Jitter(20 SECONDS)
			M.emote("twitch_s")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += rand(15,30)
			update_flags |= M.adjustToxLoss(3, FALSE)
		else if(effect <= 7)
			update_flags |= M.adjustToxLoss(4, FALSE)
			M.emote("twitch")
			M.Jitter(20 SECONDS)
	else if(severity == 2)
		if(effect <= 2)
			M.emote("gasp")
			to_chat(M, "<span class='warning'>You can't breathe!</span>")
			update_flags |= M.adjustOxyLoss(15, FALSE)
			update_flags |= M.adjustToxLoss(3, FALSE)
			M.Stun(2 SECONDS, FALSE)
		else if(effect <= 4)
			to_chat(M, "<span class='warning'>You feel terrible!</span>")
			M.emote("drool")
			M.Jitter(20 SECONDS)
			update_flags |= M.adjustToxLoss(5, FALSE)
			M.Weaken(2 SECONDS)
			M.AdjustConfused(66 SECONDS)
		else if(effect <= 7)
			M.emote("collapse")
			to_chat(M, "<span class='warning'>Your heart is pounding!</span>")
			SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
			M.Paralyse(10 SECONDS)
			M.Jitter(60 SECONDS)
			update_flags |= M.adjustToxLoss(6, FALSE)
			update_flags |= M.adjustOxyLoss(20, FALSE)
	return list(effect, update_flags)

// basic antistun chem, removes stuns and stamina, mild downsides
/datum/reagent/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times and improves stamina regeneration. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	heart_rate_increase = TRUE
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	addiction_decay_rate = 0.2 // half the metabolism rate
	taste_description = "bitterness"

/datum/reagent/crank/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]
	M.AdjustParalysis(-4 SECONDS)
	M.AdjustStunned(-4 SECONDS)
	M.AdjustWeakened(-4 SECONDS)
	M.AdjustKnockDown(-4 SECONDS)
	update_flags |= M.adjustStaminaLoss(-40, FALSE)
	if(prob(15))
		M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
	if(prob(8))
		M.emote(pick("laugh", "giggle"))
	if(prob(5 * DRAWBACK_CHANCE_MODIFIER(recent_consumption)))
		to_chat(M, "<span class='notice'>You feel warm.</span>") // fever, gets worse with volume
		M.bodytemperature += 30 * recent_consumption
		M.Confused(1 SECONDS * recent_consumption) //let us see how this feels

	if(prob(4))
		to_chat(M, "<span class='notice'>You feel kinda awful!</span>")
		M.LoseBreath(5 SECONDS)
		M.AdjustJitter(60 SECONDS)
	return ..() | update_flags

/datum/reagent/crank/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks confused!</span>")
			M.AdjustConfused(40 SECONDS)
			M.Jitter(40 SECONDS)
			M.emote("scream")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += 150
			update_flags |= M.adjustBrainLoss(5, FALSE)
			update_flags |= M.adjustToxLoss(5, FALSE)
			M.Stun(1 SECONDS)
		else if(effect <= 7)
			M.Jitter(60 SECONDS)
			M.emote("grumble")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] is sweating like a pig!</span>")
			M.bodytemperature += 200
			update_flags |= M.adjustToxLoss(20, FALSE)
			M.Stun(2 SECONDS)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] starts twitching the hell out!</span>")
			M.Jitter(200 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(20, FALSE)
			M.Weaken(6 SECONDS)
			M.AdjustConfused(50 SECONDS)
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message("<span class='warning'>[M] nervously scratches at [M.p_their()] skin!</span>")
			M.Jitter(20 SECONDS)
			update_flags |= M.adjustBruteLoss(5, FALSE)
			M.emote("twitch_s")
	return list(effect, update_flags)

// a makeshift stimulant, very fast metabolism rate, not very good
/datum/reagent/pump_up
	name = "Pump Up"
	id = "pump_up"
	description = "An awful smelling mixture which acts as a makeshift stimulant"
	reagent_state = SOLID
	color = COLOR_HALF_TRANSPARENT_BLACK
	taste_description = "poorly mixed coffee"
	metabolization_rate = 1
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5

/datum/reagent/pump_up/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-21) // one cycle to get out of stam crit ~2 second
	M.AdjustParalysis(-2 SECONDS)
	M.AdjustStunned(-2 SECONDS)
	M.AdjustWeakened(-2 SECONDS)
	M.AdjustKnockDown(-2 SECONDS)
	return ..() | update_flags

/datum/reagent/pump_up/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	switch(severity)
		if(1)
			if(prob(20))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.vomit(lost_nutrition = 0, blood = TRUE, stun = FALSE)
				M.KnockDown(1 SECONDS)
			else
				update_flags |= M.adjustStaminaLoss(10, FALSE)
		if(2)
			M.Drowsy(10 SECONDS)
			M.drop_r_hand()
			M.drop_l_hand()
			to_chat(M, "<span class='warning'>You can barely keep your eyes open!</span>")
	return list(effect, update_flags)

/datum/reagent/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
	reagent_state = LIQUID
	color = "#0264B4"
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 10
	taste_description = "very poor life choices"
	allowed_overdose_process = TRUE


/datum/reagent/krokodil/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-80 SECONDS)
	if(prob(25))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	if(prob(15))
		M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
	if(prob(10))
		to_chat(M, "<span class='notice'>You feel pretty chill.</span>")
		M.bodytemperature--
		M.emote("smile")
	if(prob(5))
		to_chat(M, "<span class='notice'>You feel too chill!</span>")
		M.emote(pick("yawn", "drool"))
		M.Stun(2 SECONDS, FALSE)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustBrainLoss(1, FALSE)
		M.bodytemperature -= 20
	if(prob(2))
		to_chat(M, "<span class='warning'>Your skin feels all rough and dry.</span>")
		update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/krokodil/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks dazed!</span>")
			M.Stun(6 SECONDS)
			M.emote("drool")
		else if(effect <= 4)
			M.emote("shiver")
			M.bodytemperature -= 40
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your skin is cracking and bleeding!</span>")
			update_flags |= M.adjustBruteLoss(5, FALSE)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.emote("cry")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M]</b> sways and falls over!</span>")
			update_flags |= M.adjustToxLoss(3, FALSE)
			update_flags |= M.adjustBrainLoss(3, FALSE)
			M.Weaken(16 SECONDS)
			M.emote("faint")
		else if(effect <= 4)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.visible_message("<span class='warning'>[M]'s skin is rotting away!</span>")
				update_flags |= H.adjustBruteLoss(25, FALSE)
				H.emote("scream")
				H.become_husk("krokodil_overdose")
				H.emote("faint")
		else if(effect <= 7)
			M.emote("shiver")
			M.bodytemperature -= 70
	return list(effect, update_flags)

// makes you faster, increases the duration of stuns, removes a LOT of stamina, makes you skinny, and does brain damage
/datum/reagent/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Increases stun times, speeds the user up, and allows the user to quickly recover stamina while dealing a large amount of brain damage and making the user waste away. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	metabolization_rate = 0.6
	addiction_decay_rate = 0.1 // very low, to prevent people from abusing the massive speed boost for too long. forces them to take long downtimes to not die from brain damage.
	heart_rate_increase = 1
	taste_description = "speed"
	allowed_overdose_process = TRUE //Requested by balance.
	/// modifier to the stun time of the mob taking the drug
	var/tenacity = 1.5

/datum/reagent/methamphetamine/on_mob_add(mob/living/L)
	ADD_TRAIT(L, TRAIT_GOTTAGOFAST, id)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stun_mod *= tenacity // takes 1.5 times longer to get up as they are off their head

/datum/reagent/methamphetamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]
	if(prob(5))
		M.emote(pick("twitch_s","blink_r","shiver"))
	M.AdjustJitter(10 SECONDS, bound_upper = 100 SECONDS)
	update_flags |= M.adjustStaminaLoss(-30, FALSE)
	M.SetSleeping(0)
	M.SetDrowsy(0)
	if(prob(10 * DRAWBACK_CHANCE_MODIFIER(recent_consumption)))
		update_flags |= M.adjustBrainLoss(10, FALSE)
		M.adjust_nutrition(-25)
	return ..() | update_flags

/datum/reagent/methamphetamine/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_GOTTAGOFAST, id)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.stun_mod /= tenacity
	..()

/datum/reagent/methamphetamine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control [M.p_their()] legs!</span>")
			M.AdjustConfused(40 SECONDS)
			M.Weaken(8 SECONDS)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M]'s hands flip out and flail everywhere!</span>")
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 7)
			M.emote("laugh")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M]'s hands flip out and flail everywhere!</span>")
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] falls to the floor and flails uncontrollably!</span>")
			M.Jitter(20 SECONDS)
			M.Weaken(20 SECONDS)
		else if(effect <= 7)
			M.emote("laugh")
	return list(effect, update_flags)

// makes you next to immune to stuns and stamina, but will demolish all of your organs, and has a tiny chance of permanently reducing your strength
/datum/reagent/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	reagent_state = SOLID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_chance = 15
	addiction_threshold = 5
	metabolization_rate = 0.6
	addiction_decay_rate = 0.2
	taste_description = "WAAAAGH"
	var/bonus_damage = 2

/datum/reagent/bath_salts/on_mob_add(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.melee_bonus += bonus_damage // rage mode

/datum/reagent/bath_salts/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		for(var/obj/item/organ/internal/I in H.internal_organs)
			I.receive_damage(0.8, TRUE) //double the rate of mitocholide
	M.SetParalysis(0)
	M.SetStunned(0)
	M.SetWeakened(0)
	M.SetKnockDown(0)
	M.Druggy(30 SECONDS)
	update_flags |= M.setStaminaLoss(0, FALSE)
	var/check = rand(0, 100)
	if(check < 30)
		M.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))
	if(check < 8)
		M.visible_message("<span class='warning'>[M] scratches at something under [M.p_their()] skin!</span>")
		update_flags |= M.adjustBruteLoss(5, FALSE)
	else if(check < 16)
		M.AdjustHallucinate(30 SECONDS)
	else if(check < 24)
		to_chat(M, "<span class='userdanger'>They're coming for you!</span>")
	else if(check < 28)
		to_chat(M, "<span class='userdanger'>THEY'RE GONNA GET YOU!</span>")
	return ..() | update_flags

/datum/reagent/bath_salts/on_mob_delete(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.melee_bonus -= bonus_damage // ragen't mode

/datum/reagent/bath_salts/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		to_chat(M, "<span class = 'danger'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>")
		SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
		M.EyeBlind(2 SECONDS)
		M.adjustToxLoss(5)
	else
		to_chat(M, "<span class='notice'>You feel a bit more salty than usual.</span>")

/datum/reagent/bath_salts/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M] flails around like a lunatic!</span>")
			M.AdjustConfused(50 SECONDS)
			M.Jitter(20 SECONDS)
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			M.emote("twitch_s")
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.Stun(6 SECONDS)
			M.EyeBlurry(14 SECONDS)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("faint")
			M.reagents.add_reagent("jagged_crystals", 5)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.Stun(6 SECONDS)
			M.EyeBlurry(14 SECONDS)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M] convulses violently and falls to the floor!</span>")
			M.Jitter(100 SECONDS)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			M.Weaken(16 SECONDS)
			M.emote("gasp")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message("<span class='danger'>[M] tears at [M.p_their()] own skin!</span>")
			update_flags |= M.adjustBruteLoss(5, FALSE)
			M.reagents.add_reagent("jagged_crystals", 5)
			M.emote("twitch")
	return list(effect, update_flags)

/datum/reagent/jenkem
	name = "Jenkem"
	id = "jenkem"
	description = "Jenkem is a prison drug made from fermenting feces in a solution of urine. Extremely disgusting."
	reagent_state = LIQUID
	color = "#644600"
	addiction_chance = 5
	addiction_threshold = 5
	taste_description = "the inside of a toilet... or worse"

/datum/reagent/jenkem/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Dizzy(10 SECONDS)
	if(prob(10))
		M.emote(pick("twitch_s","drool","moan"))
		update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

//makes you resistant to stuns and stamina damage, heals a small amount of stamina damage, causes a large amount of toxin damage, on removal forces you to throw up blood.
/datum/reagent/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "An illegal performance enhancing drug. Side effects might include chest pain, seizures, swelling, headache, fever... ... ..."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "bitterness"
	addiction_chance = 5
	addiction_threshold = 5
	addiction_decay_rate = 0.2
	/// how much do we edit the stun and stamina mods? lower is more resistance
	var/tenacity = 0.5

/datum/reagent/aranesp/on_mob_add(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stun_mod *= tenacity
		H.physiology.stamina_mod *= tenacity

/datum/reagent/aranesp/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]

	// So. Before this let you take 5 shots before going down. Nice and all, but you needed to combine this with another antistun drug to be benefical, which means you need 2 downsides. It was not pratical, or used
	// you can take 7 disabler shots (30 base * 0.5 stam mod = 15 stam damage each, 7 shots to 105 which is stamina crit. but you can heal 6 in 3 cycles) before going down.
	// Strong combined with another drug, but frankly I could do meth crank hydro for a better mix. Will be interesting with batons?
	update_flags |= M.adjustStaminaLoss(-2, FALSE)
	if(prob(10 * DRAWBACK_CHANCE_MODIFIER(recent_consumption)))
		update_flags |= M.adjustToxLoss(4, FALSE) //This does toxin damage. This kills any chem mixes, which could be considered a good thing, but it is a drug that MUST be combined with other drugs. I want to turn this down, but someone will just iv drip a certian bar drink
	if(prob(5))
		M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_s"))
	if(prob(8))
		var/high_message = pick("really buff", "on top of the world","like you're made of steel", "energized", "invigorated", "full of energy")
		to_chat(M, "<span class='notice'>You feel [high_message]!</span>")
	return ..() | update_flags

/datum/reagent/aranesp/on_mob_delete(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.stun_mod /= tenacity
		H.physiology.stamina_mod /= tenacity
		H.vomit(blood = TRUE, stun = FALSE) // just a visual, very gritty. don't do drugs kids
		H.LoseBreath(10 SECONDS) // procs 5 times, mostly a visual thing. damage could stack to cause a slowdown.
		H.Confused(10 SECONDS)

/datum/reagent/thc
	name = "Tetrahydrocannabinol"
	id = "thc"
	description = "A mild psychoactive chemical extracted from the cannabis plant."
	reagent_state = LIQUID
	color = "#0FBE0F"
	taste_description = "man like, totally the best like, thing ever dude"

/datum/reagent/thc/on_mob_life(mob/living/M)
	M.AdjustStuttering(rand(0, 6 SECONDS))
	if(prob(5))
		M.emote(pick("laugh","giggle","smile"))
	if(prob(5))
		to_chat(M, "[pick("You feel hungry.","Your stomach rumbles.","You feel cold.","You feel warm.")]")
	if(prob(4))
		M.Confused(20 SECONDS)
	if(volume >= 50 && prob(25))
		if(prob(10))
			M.Drowsy(20 SECONDS)
	return ..()

/datum/reagent/cbd
	name = "Cannabidiol"
	id = "cbd"
	description = "A non-psychoactive phytocannabinoid extracted from the cannabis plant."
	reagent_state = LIQUID
	color = "#00e100"
	taste_description = "relaxation"

/datum/reagent/cbd/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		M.emote(pick("hsigh", "yawn"))
	if(prob(5))
		to_chat(M, "<span class='notice'>[pick("You feel peaceful.", "You breathe softly.", "You feel chill.", "You vibe.")]</span>")
	if(prob(10))
		M.AdjustConfused(-10 SECONDS)
		M.SetWeakened(0, FALSE)
	if(volume >= 70 && prob(25))
		if(M.reagents.get_reagent_amount("thc") <= 20)
			M.Drowsy(20 SECONDS)
	if(prob(25))
		update_flags |= M.adjustBruteLoss(-2, FALSE)
		update_flags |= M.adjustFireLoss(-2, FALSE)
	return ..() | update_flags


/datum/reagent/fliptonium
	name = "Fliptonium"
	id = "fliptonium"
	description = "Do some flips!"
	reagent_state = LIQUID
	color = "#A42964"
	metabolization_rate = 0.2
	overdose_threshold = 15
	process_flags = ORGANIC | SYNTHETIC		//Flipping for everyone!
	addiction_chance = 1
	addiction_chance_additional = 20
	addiction_threshold = 10
	taste_description = "flips"

/datum/reagent/fliptonium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle == 5)
		M.SpinAnimation(speed = 11, loops = -1, parallel = FALSE)
	if(current_cycle == 10)
		M.SpinAnimation(speed = 10, loops = -1, parallel = FALSE)
	if(current_cycle == 15)
		M.SpinAnimation(speed = 9, loops = -1, parallel = FALSE)
	if(current_cycle == 20)
		M.SpinAnimation(speed = 8, loops = -1, parallel = FALSE)
	if(current_cycle == 25)
		M.SpinAnimation(speed = 7, loops = -1, parallel = FALSE)
	if(current_cycle == 30)
		M.SpinAnimation(speed = 6, loops = -1, parallel = FALSE)
	if(current_cycle == 40)
		M.SpinAnimation(speed = 5, loops = -1, parallel = FALSE)
	if(current_cycle == 50)
		M.SpinAnimation(speed = 4, loops = -1, parallel = FALSE)

	return ..() | update_flags

/datum/reagent/fliptonium/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST || method == REAGENT_TOUCH)
		M.SpinAnimation(speed = 12, loops = -1, parallel = FALSE)
	..()

/datum/reagent/fliptonium/on_mob_delete(mob/living/M)
	M.SpinAnimation(speed = 12, loops = -1, parallel = FALSE)

/datum/reagent/fliptonium/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control [M.p_their()] legs!</span>")
			M.AdjustConfused(66 SECONDS)
			M.Weaken(4 SECONDS)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M]'s hands flip out and flail everywhere!</span>")
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 7)
			M.emote("laugh")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M]'s hands flip out and flail everywhere!</span>")
			M.drop_l_hand()
			M.drop_r_hand()
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] falls to the floor and flails uncontrollably!</span>")
			M.Jitter(10 SECONDS)
			M.Weaken(10 SECONDS)
		else if(effect <= 7)
			M.emote("laugh")
	return list(effect, update_flags)

/datum/reagent/rotatium //Rotatium. Fucks up your rotation and is hilarious
	name = "Rotatium"
	id = "rotatium"
	description = "A constantly swirling, oddly colourful fluid. Causes the consumer's sense of direction and hand-eye coordination to become wild."
	reagent_state = LIQUID
	color = "#AC88CA" //RGB: 172, 136, 202
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	taste_description = "spinning"

/datum/reagent/rotatium/on_mob_life(mob/living/carbon/M)
	if(M.hud_used)
		if(current_cycle >= 20 && current_cycle % 20 == 0)
			var/atom/movable/plane_master_controller/pm_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
			var/rotation = min(round(current_cycle / 20), 89) // By this point the player is probably puking and quitting anyway
			for(var/key in pm_controller.controlled_planes)
				animate(pm_controller.controlled_planes[key], transform = matrix(rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING, loop = -1)
				animate(transform = matrix(-rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING)
	return ..()

/datum/reagent/rotatium/on_mob_delete(mob/living/M)
	if(M?.hud_used)
		var/atom/movable/plane_master_controller/pm_controller = M.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		for(var/key in pm_controller.controlled_planes)
			animate(pm_controller.controlled_planes[key], transform = matrix(), time = 5, easing = QUAD_EASING)
	..()

//////////////////////////////
//		Synth-Drugs			//
//////////////////////////////

//Ultra-Lube: Meth
/datum/reagent/lube/ultra
	name = "Ultra-Lube"
	id = "ultralube"
	description = "Ultra-Lube is an enhanced lubricant which induces effect similar to Methamphetamine in synthetic users by drastically reducing internal friction and increasing cooling capabilities."
	reagent_state = LIQUID
	color = "#1BB1FF"
	process_flags = SYNTHETIC
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	metabolization_rate = 0.6
	addiction_decay_rate = 0.1 //very low to force them to take time off of meth
	taste_description = "wiper fluid"
	var/tenacity = 1.5 // higher is worse

/datum/reagent/lube/ultra/on_mob_add(mob/living/L)
	ADD_TRAIT(L, TRAIT_GOTTAGOFAST, id)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.physiology.stun_mod *= tenacity

/datum/reagent/lube/ultra/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]
	M.AdjustJitter(10 SECONDS)
	update_flags |= M.adjustStaminaLoss(-40, FALSE)
	M.SetSleeping(0)
	M.SetDrowsy(0)
	if(prob(12 * DRAWBACK_CHANCE_MODIFIER(recent_consumption))) // slightly higher prob than meth due to the no nutrition thing
		update_flags |= M.adjustBrainLoss(10, FALSE)

	var/high_message = pick("You feel your servos whir!", "You feel like you need to go faster.", "You feel like you were just overclocked!")
	if(prob(10))
		high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	return ..() | update_flags


/datum/reagent/lube/ultra/on_mob_delete(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_GOTTAGOFAST, id)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.physiology.stun_mod /= tenacity
	..()

/datum/reagent/lube/ultra/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(prob(20))
		M.emote("ping")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	update_flags |= M.adjustFireLoss(5, FALSE)
	update_flags |= M.adjustBrainLoss(3, FALSE)
	return list(effect, update_flags)

//Surge: crank
/datum/reagent/surge
	name = "Surge"
	id = "surge"
	description = "A sketchy superconducting gel that overloads processors, causing an effect reportedly similar to opiates in synthetic units."
	reagent_state = LIQUID
	color = "#6DD16D"

	process_flags = SYNTHETIC
	overdose_threshold = 20
	addiction_chance = 10
	addiction_threshold = 5
	addiction_decay_rate = 0.2
	taste_description = "silicon"


/datum/reagent/surge/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/recent_consumption = holder.addiction_threshold_accumulated[type]
	M.Druggy(30 SECONDS)
	M.AdjustParalysis(-4 SECONDS)
	M.AdjustStunned(-4 SECONDS)
	M.AdjustWeakened(-4 SECONDS)
	M.AdjustKnockDown(-4 SECONDS)
	update_flags |= M.adjustStaminaLoss(-40, FALSE)
	if(prob(5))
		var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
		if(prob(10))
			high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
		to_chat(M, "<span class='notice'>[high_message]</span>")
	if(prob(5 * DRAWBACK_CHANCE_MODIFIER(recent_consumption)))
		to_chat(M, "<span class='notice'>Your circuits overheat!</span>") // synth fever
		M.bodytemperature += 30 * recent_consumption
		M.Confused(2 SECONDS * recent_consumption)

	return ..() | update_flags

/datum/reagent/surge/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	//Hit them with the same effects as an electrode!
	M.Weaken(10 SECONDS)
	M.Jitter(40 SECONDS)
	M.Stuttering(10 SECONDS)
	if(prob(10))
		to_chat(M, "<span class='danger'>You experience a violent electrical discharge!</span>")
		playsound(get_turf(M), 'sound/effects/eleczap.ogg', 75, 1)
		//Lightning effect for electrical discharge visualization
		var/icon/I=new('icons/obj/zap.dmi',"lightningend")
		I.Turn(-135)
		var/obj/effect/overlay/beam/B = new(get_turf(M))
		B.pixel_x = rand(-20, 0)
		B.pixel_y = rand(-20, 0)
		B.icon = I
		update_flags |= M.adjustFireLoss(rand(1,5)*REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustBruteLoss(rand(1,5)*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return list(0, update_flags)

#undef DRAWBACK_CHANCE_MODIFIER
