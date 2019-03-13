/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/serotrotium/on_mob_life(mob/living/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	return ..()


/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			step(M, pick(cardinal))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	return ..()

/datum/reagent/lsd
	name = "Lysergic acid diethylamide"
	id = "lsd"
	description = "A highly potent hallucinogenic substance. Far out, maaaan."
	reagent_state = LIQUID
	color = "#0000D8"
	taste_message = "a magical journey"

/datum/reagent/lsd/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(15, FALSE)
	M.AdjustHallucinate(10)
	return ..() | update_flags

/datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#9087A2"
	metabolization_rate = 0.2
	addiction_chance = 65
	heart_rate_decrease = 1
	taste_message = "a synthetic high"

/datum/reagent/space_drugs/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(15, FALSE)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove && !M.restrained())
			step(M, pick(cardinal))
	if(prob(7))
		M.emote(pick("twitch","drool","moan","giggle"))
	return ..() | update_flags

/datum/reagent/psilocybin
	name = "Psilocybin"
	id = "psilocybin"
	description = "A strong psycotropic derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	taste_message = "visions"

/datum/reagent/psilocybin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(30, FALSE)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(1)
			M.Dizzy(5)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(1)
			M.Jitter(10)
			M.Dizzy(10)
			update_flags |= M.Druggy(35, FALSE)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(1)
			M.Jitter(20)
			M.Dizzy(20)
			update_flags |= M.Druggy(40, FALSE)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 35
	addiction_chance = 70
	heart_rate_increase = 1
	taste_message = "calm"

/datum/reagent/nicotine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/smoke_message = pick("You feel relaxed.", "You feel calmed.", "You feel less stressed.", "You feel more placid.", "You feel more undivided.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	if(prob(50))
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-1, FALSE)
		update_flags |= M.AdjustWeakened(-1, FALSE)
		update_flags |= M.adjustStaminaLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/nicotine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks nervous!</span>")
			M.AdjustConfused(15)
			update_flags |= M.adjustToxLoss(2, FALSE)
			M.Jitter(10)
			M.emote("twitch_s")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += rand(15,30)
			update_flags |= M.adjustToxLoss(3, FALSE)
		else if(effect <= 7)
			update_flags |= M.adjustToxLoss(4, FALSE)
			M.emote("twitch")
			M.Jitter(10)
	else if(severity == 2)
		if(effect <= 2)
			M.emote("gasp")
			to_chat(M, "<span class='warning'>You can't breathe!</span>")
			update_flags |= M.adjustOxyLoss(15, FALSE)
			update_flags |= M.adjustToxLoss(3, FALSE)
			update_flags |= M.Stun(1, FALSE)
		else if(effect <= 4)
			to_chat(M, "<span class='warning'>You feel terrible!</span>")
			M.emote("drool")
			M.Jitter(10)
			update_flags |= M.adjustToxLoss(5, FALSE)
			update_flags |= M.Weaken(1, FALSE)
			M.AdjustConfused(33)
		else if(effect <= 7)
			M.emote("collapse")
			to_chat(M, "<span class='warning'>Your heart is pounding!</span>")
			M << 'sound/effects/singlebeat.ogg'
			update_flags |= M.Paralyse(5, FALSE)
			M.Jitter(30)
			update_flags |= M.adjustToxLoss(6, FALSE)
			update_flags |= M.adjustOxyLoss(20, FALSE)
	return list(effect, update_flags)

/datum/reagent/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 50

/datum/reagent/crank/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.AdjustParalysis(-2, FALSE)
	update_flags |= M.AdjustStunned(-2, FALSE)
	update_flags |= M.AdjustWeakened(-2, FALSE)
	if(prob(15))
		M.emote(pick("twitch", "twitch_s", "grumble", "laugh"))
	if(prob(8))
		to_chat(M, "<span class='notice'>You feel great!</span>")
		M.reagents.add_reagent("methamphetamine", rand(1,2))
		M.emote(pick("laugh", "giggle"))
	if(prob(6))
		to_chat(M, "<span class='notice'>You feel warm.</span>")
		M.bodytemperature += rand(1,10)
	if(prob(4))
		to_chat(M, "<span class='notice'>You feel kinda awful!</span>")
		update_flags |= M.adjustToxLoss(1, FALSE)
		M.AdjustJitter(30)
		M.emote(pick("groan", "moan"))
	return ..() | update_flags

/datum/reagent/crank/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks confused!</span>")
			M.AdjustConfused(20)
			M.Jitter(20)
			M.emote("scream")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += rand(5,30)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.adjustToxLoss(1, FALSE)
			update_flags |= M.Stun(2, FALSE)
		else if(effect <= 7)
			M.Jitter(30)
			M.emote("grumble")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] is sweating like a pig!</span>")
			M.bodytemperature += rand(20,100)
			update_flags |= M.adjustToxLoss(5, FALSE)
			update_flags |= M.Stun(3, FALSE)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] starts tweaking the hell out!</span>")
			M.Jitter(100)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(8, FALSE)
			update_flags |= M.Weaken(3, FALSE)
			M.AdjustConfused(25)
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message("<span class='warning'>[M] nervously scratches at [M.p_their()] skin!</span>")
			M.Jitter(10)
			update_flags |= M.adjustBruteLoss(5, FALSE)
			M.emote("twitch_s")
	return list(effect, update_flags)

/datum/reagent/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
	reagent_state = LIQUID
	color = "#0264B4"
	overdose_threshold = 20
	addiction_chance = 50
	taste_message = "very poor life choices"


/datum/reagent/krokodil/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(-40)
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
		update_flags |= M.Stun(1, FALSE)
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
			update_flags |= M.Stun(3, FALSE)
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
			update_flags |= M.Weaken(8, FALSE)
			M.emote("faint")
		else if(effect <= 4)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.visible_message("<span class='warning'>[M]'s skin is rotting away!</span>")
				update_flags |= H.adjustBruteLoss(25, FALSE)
				H.emote("scream")
				H.ChangeToHusk()
				H.emote("faint")
		else if(effect <= 7)
			M.emote("shiver")
			M.bodytemperature -= 70
	return list(effect, update_flags)

/datum/reagent/methamphetamine
	name = "Methamphetamine"
	id = "methamphetamine"
	description = "Reduces stun times by about 300%, speeds the user up, and allows the user to quickly recover stamina while dealing a small amount of Brain damage. If overdosed the subject will move randomly, laugh randomly, drop items and suffer from Toxin and Brain damage. If addicted the subject will constantly jitter and drool, before becoming dizzy and losing motor control and eventually suffer heavy toxin damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 60
	metabolization_rate = 0.6
	heart_rate_increase = 1
	taste_message = "speed"

/datum/reagent/methamphetamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		M.emote(pick("twitch_s","blink_r","shiver"))
	if(current_cycle >= 25)
		M.AdjustJitter(5)
	M.AdjustDrowsy(-10)
	update_flags |= M.AdjustParalysis(-2.5, FALSE)
	update_flags |= M.AdjustStunned(-2.5, FALSE)
	update_flags |= M.AdjustWeakened(-2.5, FALSE)
	update_flags |= M.adjustStaminaLoss(-2, FALSE)
	update_flags |= M.SetSleeping(0, FALSE)
	M.status_flags |= GOTTAGOFAST_METH
	if(prob(50))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/methamphetamine/on_mob_delete(mob/living/M)
	M.status_flags &= ~GOTTAGOFAST_METH
	..()

/datum/reagent/methamphetamine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control [M.p_their()] legs!</span>")
			M.AdjustConfused(20)
			update_flags |= M.Weaken(4, FALSE)
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
			M.Jitter(10)
			update_flags |= M.Weaken(10, FALSE)
		else if(effect <= 7)
			M.emote("laugh")
	return list(effect, update_flags)

/datum/reagent/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	reagent_state = SOLID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_chance = 80
	metabolization_rate = 0.6
	taste_message = "WAAAAGH"

/datum/reagent/bath_salts/on_mob_life(mob/living/M)
	var/check = rand(0,100)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		if(check < 8 && head_organ.h_style != "Very Long Beard")
			head_organ.h_style = "Very Long Hair"
			head_organ.f_style = "Very Long Beard"
			H.update_hair()
			H.update_fhair()
			H.visible_message("<span class='warning'>[H] has a wild look in [H.p_their()] eyes!</span>")
	if(check < 60)
		update_flags |= M.SetParalysis(0, FALSE)
		update_flags |= M.SetStunned(0, FALSE)
		update_flags |= M.SetWeakened(0, FALSE)
	if(check < 30)
		M.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))
	update_flags |= M.Druggy(15, FALSE)
	if(check < 20)
		M.AdjustConfused(10)
	if(check < 8)
		M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
		M.visible_message("<span class='warning'>[M] scratches at something under [M.p_their()] skin!</span>")
		update_flags |= M.adjustBruteLoss(5, FALSE)
	else if(check < 16)
		M.AdjustHallucinate(30)
	else if(check < 24)
		to_chat(M, "<span class='userdanger'>They're coming for you!</span>")
	else if(check < 28)
		to_chat(M, "<span class='userdanger'>THEY'RE GONNA GET YOU!</span>")
	return ..() | update_flags

/datum/reagent/bath_salts/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST)
		to_chat(M, "<span class = 'danger'><font face='[pick("Curlz MT", "Comic Sans MS")]' size='[rand(4,6)]'>You feel FUCKED UP!!!!!!</font></span>")
		M << 'sound/effects/singlebeat.ogg'
		M.emote("faint")
		M.apply_effect(5, IRRADIATE, negate_armor = 1)
		M.adjustToxLoss(5)
		M.adjustBrainLoss(10)
	else
		to_chat(M, "<span class='notice'>You feel a bit more salty than usual.</span>")

/datum/reagent/bath_salts/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M] flails around like a lunatic!</span>")
			M.AdjustConfused(25)
			M.Jitter(10)
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			M.emote("twitch_s")
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.Stun(3, FALSE)
			update_flags |= M.EyeBlurry(7, FALSE)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("faint")
			M.reagents.add_reagent("jagged_crystals", 5)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.Stun(3, FALSE)
			update_flags |= M.EyeBlurry(7, FALSE)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M] convulses violently and falls to the floor!</span>")
			M.Jitter(50)
			update_flags |= M.adjustToxLoss(2, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.Weaken(8, FALSE)
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
	addiction_chance = 30
	taste_message = "puke... or worse"

/datum/reagent/jenkem/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Dizzy(5)
	if(prob(10))
		M.emote(pick("twitch_s","drool","moan"))
		update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "An illegal performance enhancing drug. Side effects might include chest pain, seizures, swelling, headache, fever... ... ..."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/aranesp/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-40, FALSE)
	if(prob(90))
		update_flags |= M.adjustToxLoss(1, FALSE)
	if(prob(5))
		M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_s"))
	var/high_message = pick("really buff", "on top of the world","like you're made of steel", "energized", "invigorated", "full of energy")
	if(prob(8))
		to_chat(M, "<span class='notice'>[high_message]!</span>")
	if(prob(5))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		update_flags |= M.adjustOxyLoss(15, FALSE)
		update_flags |= M.Stun(1, FALSE)
		M.AdjustLoseBreath(1, FALSE)
	return ..() | update_flags

/datum/reagent/thc
	name = "Tetrahydrocannabinol"
	id = "thc"
	description = "A mild psychoactive chemical extracted from the cannabis plant."
	reagent_state = LIQUID
	color = "#0FBE0F"

/datum/reagent/thc/on_mob_life(mob/living/M)
	M.stuttering += rand(0,2)
	if(prob(5))
		M.emote(pick("laugh","giggle","smile"))
	if(prob(5))
		to_chat(M, "[pick("You feel hungry.","Your stomach rumbles.","You feel cold.","You feel warm.")]")
	if(prob(4))
		M.Confused(10)
	if(volume >= 50 && prob(25))
		if(prob(10))
			M.Drowsy(10)
	return ..()

/datum/reagent/fliptonium
	name = "Fliptonium"
	id = "fliptonium"
	description = "Do some flips!"
	reagent_state = LIQUID
	color = "#A42964"
	metabolization_rate = 0.2
	overdose_threshold = 15
	process_flags = ORGANIC | SYNTHETIC		//Flipping for everyone!
	addiction_chance = 10
	taste_message = "flips"

/datum/reagent/fliptonium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle == 5)
		M.SpinAnimation(speed = 11, loops = -1)
	if(current_cycle == 10)
		M.SpinAnimation(speed = 10, loops = -1)
	if(current_cycle == 15)
		M.SpinAnimation(speed = 9, loops = -1)
	if(current_cycle == 20)
		M.SpinAnimation(speed = 8, loops = -1)
	if(current_cycle == 25)
		M.SpinAnimation(speed = 7, loops = -1)
	if(current_cycle == 30)
		M.SpinAnimation(speed = 6, loops = -1)
	if(current_cycle == 40)
		M.SpinAnimation(speed = 5, loops = -1)
	if(current_cycle == 50)
		M.SpinAnimation(speed = 4, loops = -1)

	M.AdjustDrowsy(-6)
	update_flags |= M.AdjustParalysis(-1.5, FALSE)
	update_flags |= M.AdjustStunned(-1.5, FALSE)
	update_flags |= M.AdjustWeakened(-1.5, FALSE)
	update_flags |= M.adjustStaminaLoss(-1.5, FALSE)
	update_flags |= M.SetSleeping(0, FALSE)
	return ..() | update_flags

/datum/reagent/fliptonium/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST || method == TOUCH)
		M.SpinAnimation(speed = 12, loops = -1)
	..()

/datum/reagent/fliptonium/on_mob_delete(mob/living/M)
	M.SpinAnimation(speed = 12, loops = -1)

/datum/reagent/fliptonium/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control [M.p_their()] legs!</span>")
			M.AdjustConfused(33)
			update_flags |= M.Weaken(2, FALSE)
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
			M.Jitter(5)
			update_flags |= M.Weaken(5, FALSE)
		else if(effect <= 7)
			M.emote("laugh")
	return list(effect, update_flags)

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
	addiction_chance = 60
	metabolization_rate = 0.6
	taste_message = "wiper fluid"

/datum/reagent/lube/ultra/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	var/high_message = pick("You feel your servos whir!", "You feel like you need to go faster.", "You feel like you were just overclocked!")
	if(prob(1))
		if(prob(1))
			high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	update_flags |= M.AdjustParalysis(-2, FALSE)
	update_flags |= M.AdjustStunned(-2, FALSE)
	update_flags |= M.AdjustWeakened(-2, FALSE)
	update_flags |= M.adjustStaminaLoss(-2, FALSE)
	M.status_flags |= GOTTAGOFAST_METH
	M.Jitter(3)
	update_flags |= M.adjustBrainLoss(0.5, FALSE)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	return ..() | update_flags

/datum/reagent/lube/ultra/on_mob_delete(mob/living/M)
	M.status_flags &= ~GOTTAGOFAST_METH
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
	if(prob(50))
		update_flags |= M.adjustFireLoss(10, FALSE)
	update_flags |= M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1), FALSE)
	return list(effect, update_flags)

//Surge: Krokodil
/datum/reagent/surge
	name = "Surge"
	id = "surge"
	description = "A sketchy superconducting gel that overloads processors, causing an effect reportedly similar to opiates in synthetic units."
	reagent_state = LIQUID
	color = "#6DD16D"

	process_flags = SYNTHETIC
	overdose_threshold = 20
	addiction_chance = 50
	taste_message = "silicone"


/datum/reagent/surge/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(15)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(1))
		if(prob(1))
			high_message = "01010100010100100100000101001110010100110100001101000101010011100100010001000101010011100100001101000101."
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	return ..() | update_flags

/datum/reagent/surge/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	//Hit them with the same effects as an electrode!
	update_flags |= M.Stun(5, FALSE)
	update_flags |= M.Weaken(5, FALSE)
	M.Jitter(20)
	M.apply_effect(STUTTER, 5)
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
