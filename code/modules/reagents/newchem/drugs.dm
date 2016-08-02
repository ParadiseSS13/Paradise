#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "Slightly reduces stun times. If overdosed it will deal toxin and oxygen damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 35
	addiction_chance = 70
	heart_rate_increase = 1

/datum/reagent/nicotine/on_mob_life(mob/living/M)
	var/smoke_message = pick("You feel relaxed.", "You feel calmed.", "You feel less stressed.", "You feel more placid.", "You feel more undivided.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
		M.adjustStaminaLoss(-1*REM)
	..()

/datum/reagent/nicotine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks nervous!</span>")
			M.confused += 15
			M.adjustToxLoss(2)
			M.Jitter(10)
			M.emote("twitch_s")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += rand(15,30)
			M.adjustToxLoss(3)
		else if(effect <= 7)
			M.adjustToxLoss(4)
			M.emote("twitch")
			M.Jitter(10)
	else if(severity == 2)
		if(effect <= 2)
			M.emote("gasp")
			to_chat(M, "<span class='warning'>You can't breathe!</span>")
			M.adjustOxyLoss(15)
			M.adjustToxLoss(3)
			M.Stun(1)
		else if(effect <= 4)
			to_chat(M, "<span class='warning'>You feel terrible!</span>")
			M.emote("drool")
			M.Jitter(10)
			M.adjustToxLoss(5)
			M.Weaken(1)
			M.confused += 33
		else if(effect <= 7)
			M.emote("collapse")
			to_chat(M, "<span class='warning'>Your heart is pounding!</span>")
			M << 'sound/effects/singlebeat.ogg'
			M.Paralyse(5)
			M.Jitter(30)
			M.adjustToxLoss(6)
			M.adjustOxyLoss(20)

/datum/reagent/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 50

/datum/reagent/crank/on_mob_life(mob/living/M)
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
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
		M.adjustToxLoss(1)
		M.jitteriness += 30
		M.emote(pick("groan", "moan"))
	..()

/datum/reagent/crank/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks confused!</span>")
			M.confused += 20
			M.Jitter(20)
			M.emote("scream")
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] is all sweaty!</span>")
			M.bodytemperature += rand(5,30)
			M.adjustBrainLoss(1)
			M.adjustToxLoss(1)
			M.Stun(2)
		else if(effect <= 7)
			M.Jitter(30)
			M.emote("grumble")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] is sweating like a pig!</span>")
			M.bodytemperature += rand(20,100)
			M.adjustToxLoss(5)
			M.Stun(3)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] starts tweaking the hell out!</span>")
			M.Jitter(100)
			M.adjustToxLoss(2)
			M.adjustBrainLoss(8)
			M.Weaken(3)
			M.confused += 25
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message("<span class='warning'>[M] nervously scratches at their skin!</span>")
			M.Jitter(10)
			M.adjustBruteLoss(5)
			M.emote("twitch_s")

/datum/chemical_reaction/crank
	name = "Crank"
	id = "crank"
	result = "crank"
	required_reagents = list("diphenhydramine" = 1, "ammonia" = 1, "lithium" = 1, "sacid" = 1, "fuel" = 1)
	result_amount = 5
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	mix_sound = 'sound/goonstation/effects/crystalshatter.ogg'
	min_temp = 390

/datum/chemical_reaction/crank/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)
	explosion(T,0,0,2)

/datum/reagent/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
	reagent_state = LIQUID
	color = "#0264B4"
	overdose_threshold = 20
	addiction_chance = 50


/datum/reagent/krokodil/on_mob_life(mob/living/M)
	M.jitteriness -= 40
	if(prob(25))
		M.adjustBrainLoss(1)
	if(prob(15))
		M.emote(pick("smile", "grin", "yawn", "laugh", "drool"))
	if(prob(10))
		to_chat(M, "<span class='notice'>You feel pretty chill.</span>")
		M.bodytemperature--
		M.emote("smile")
	if(prob(5))
		to_chat(M, "<span class='notice'>You feel too chill!</span>")
		M.emote(pick("yawn", "drool"))
		M.Stun(1)
		M.adjustToxLoss(1)
		M.adjustBrainLoss(1)
		M.bodytemperature -= 20
	if(prob(2))
		to_chat(M, "<span class='warning'>Your skin feels all rough and dry.</span>")
		M.adjustBruteLoss(2)
	..()

/datum/reagent/krokodil/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] looks dazed!</span>")
			M.Stun(3)
			M.emote("drool")
		else if(effect <= 4)
			M.emote("shiver")
			M.bodytemperature -= 40
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your skin is cracking and bleeding!</span>")
			M.adjustBruteLoss(5)
			M.adjustToxLoss(2)
			M.adjustBrainLoss(1)
			M.emote("cry")
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M]</b> sways and falls over!</span>")
			M.adjustToxLoss(3)
			M.adjustBrainLoss(3)
			M.Weaken(8)
			M.emote("faint")
		else if(effect <= 4)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.visible_message("<span class='warning'>[M]'s skin is rotting away!</span>")
				H.adjustBruteLoss(25)
				H.emote("scream")
				H.ChangeToHusk()
				H.emote("faint")
		else if(effect <= 7)
			M.emote("shiver")
			M.bodytemperature -= 70

/datum/chemical_reaction/krokodil
	name = "Krokodil"
	id = "krokodil"
	result = "krokodil"
	required_reagents = list("diphenhydramine" = 1, "morphine" = 1, "cleaner" = 1, "potassium" = 1, "phosphorus" = 1, "fuel" = 1)
	result_amount = 6
	mix_message = "The mixture dries into a pale blue powder."
	min_temp = 380
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

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

/datum/reagent/methamphetamine/on_mob_life(mob/living/M)
	if(prob(5))
		M.emote(pick("twitch_s","blink_r","shiver"))
	if(current_cycle >= 25)
		M.jitteriness += 5
	M.drowsyness = max(0, M.drowsyness-10)
	M.AdjustParalysis(-2.5)
	M.AdjustStunned(-2.5)
	M.AdjustWeakened(-2.5)
	M.adjustStaminaLoss(-2)
	M.SetSleeping(0)
	M.status_flags |= GOTTAGOREALLYFAST
	if(prob(50))
		M.adjustBrainLoss(1.0)
	..()

/datum/reagent/methamphetamine/reagent_deleted(mob/living/M)
	M.status_flags &= ~GOTTAGOREALLYFAST
	..()

/datum/reagent/methamphetamine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control their legs!</span>")
			M.confused += 20
			M.Weaken(4)
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
			M.Weaken(10)
		else if(effect <= 7)
			M.emote("laugh")

/datum/chemical_reaction/methamphetamine
	name = "methamphetamine"
	id = "methamphetamine"
	result = "methamphetamine"
	required_reagents = list("ephedrine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1)
	result_amount = 4
	min_temp = 374

/datum/chemical_reaction/methamphetamine/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.emote("gasp")
			C.losebreath++
			C.reagents.add_reagent("toxin", 10)
			C.reagents.add_reagent("neurotoxin2", 20)

/datum/chemical_reaction/saltpetre
	name = "saltpetre"
	id = "saltpetre"
	result = "saltpetre"
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/bath_salts
	name = "Bath Salts"
	id = "bath_salts"
	description = "Sometimes packaged as a refreshing bathwater additive, these crystals are definitely not for human consumption."
	reagent_state = SOLID
	color = "#FAFAFA"
	overdose_threshold = 20
	addiction_chance = 80
	metabolization_rate = 0.6

/datum/reagent/bath_salts/on_mob_life(mob/living/M)
	var/check = rand(0,100)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		if(check < 8 && head_organ.h_style != "Very Long Beard")
			head_organ.h_style = "Very Long Hair"
			head_organ.f_style = "Very Long Beard"
			H.update_hair()
			H.update_fhair()
			H.visible_message("<span class='warning'>[H] has a wild look in their eyes!</span>")
	if(check < 60)
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
	if(check < 30)
		M.emote(pick("twitch", "twitch_s", "scream", "drool", "grumble", "mumble"))
	M.druggy = max(M.druggy, 15)
	if(check < 20)
		M.confused += 10
	if(check < 8)
		M.reagents.add_reagent(pick("methamphetamine", "crank", "neurotoxin"), rand(1,5))
		M.visible_message("<span class='warning'>[M] scratches at something under their skin!</span>")
		M.adjustBruteLoss(5)
	else if(check < 16)
		M.hallucination += 30
	else if(check < 24)
		to_chat(M, "<span class='userdanger'>They're coming for you!</span>")
	else if(check < 28)
		to_chat(M, "<span class='userdanger'>THEY'RE GONNA GET YOU!</span>")
	..()

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
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M] flails around like a lunatic!</span>")
			M.confused += 25
			M.Jitter(10)
			M.emote("scream")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			M.emote("twitch_s")
			M.adjustToxLoss(2)
			M.adjustBrainLoss(1)
			M.Stun(3)
			M.eye_blurry = max(M.eye_blurry, 7)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("faint")
			M.reagents.add_reagent("jagged_crystals", 5)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='danger'>[M]'s eyes dilate!</span>")
			M.adjustToxLoss(2)
			M.adjustBrainLoss(1)
			M.Stun(3)
			M.eye_blurry = max(M.eye_blurry, 7)
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 4)
			M.visible_message("<span class='danger'>[M] convulses violently and falls to the floor!</span>")
			M.Jitter(50)
			M.adjustToxLoss(2)
			M.adjustBrainLoss(1)
			M.Weaken(8)
			M.emote("gasp")
			M.reagents.add_reagent("jagged_crystals", 5)
		else if(effect <= 7)
			M.emote("scream")
			M.visible_message("<span class='danger'>[M] tears at their own skin!</span>")
			M.adjustBruteLoss(5)
			M.reagents.add_reagent("jagged_crystals", 5)
			M.emote("twitch")

/datum/chemical_reaction/bath_salts
	name = "bath_salts"
	id = "bath_salts"
	result = "bath_salts"
	required_reagents = list("????" = 1, "saltpetre" = 1, "msg" = 1, "cleaner" = 1, "enzyme" = 1, "mugwort" = 1, "mercury" = 1)
	result_amount = 6
	min_temp = 374
	mix_message = "Tiny cubic crystals precipitate out of the mixture. Huh."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/jenkem
	name = "Jenkem"
	id = "jenkem"
	result = "jenkem"
	required_reagents = list("toiletwater" = 1, "ammonia" = 1, "water" = 1)
	result_amount = 3
	mix_message = "The mixture ferments into a filthy morass."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/jenkem/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("jenkem", 25)

/datum/reagent/jenkem
	name = "Jenkem"
	id = "jenkem"
	description = "Jenkem is a prison drug made from fermenting feces in a solution of urine. Extremely disgusting."
	reagent_state = LIQUID
	color = "#644600"
	addiction_chance = 30

/datum/reagent/jenkem/on_mob_life(mob/living/M)
	M.Dizzy(5)
	if(prob(10))
		M.emote(pick("twitch_s","drool","moan"))
		M.adjustToxLoss(1)
	..()

/datum/chemical_reaction/aranesp
	name = "Aranesp"
	id = "aranesp"
	result = "aranesp"
	required_reagents = list("epinephrine" = 1, "atropine" = 1, "insulin" = 1)
	result_amount = 3

/datum/reagent/aranesp
	name = "Aranesp"
	id = "aranesp"
	description = "An illegal performance enhancing drug. Side effects might include chest pain, seizures, swelling, headache, fever... ... ..."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/aranesp/on_mob_life(mob/living/M)
	M.adjustStaminaLoss(-40)
	if(prob(90))
		M.adjustToxLoss(1)
	if(prob(5))
		M.emote(pick("twitch", "shake", "tremble","quiver", "twitch_s"))
	var/high_message = pick("really buff", "on top of the world","like you're made of steel", "energized", "invigorated", "full of energy")
	if(prob(8))
		to_chat(M, "<span class='notice'>[high_message]!</span>")
	if(prob(5))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.adjustOxyLoss(15)
		M.Stun(1)
		M.losebreath++
	..()

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
		M.confused = max(M.confused, 10)
	if(volume >= 50 && prob(25))
		if(prob(10))
			M.drowsyness = max(M.drowsyness, 10)
	..()

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

/datum/chemical_reaction/fliptonium
	name = "fliptonium"
	id = "fliptonium"
	result = "fliptonium"
	required_reagents = list("ephedrine" = 1, "liquid_dark_matter" = 1, "chocolate" = 1, "ginsonic" = 1)
	result_amount = 4
	mix_message = "The mixture swirls around excitedly!"

/datum/reagent/fliptonium/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == INGEST || method == TOUCH)
		M.SpinAnimation(speed = 12, loops = -1)
	..()

/datum/reagent/fliptonium/on_mob_life(mob/living/M)
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

	M.drowsyness = max(0, M.drowsyness-6)
	M.AdjustParalysis(-1.5)
	M.AdjustStunned(-1.5)
	M.AdjustWeakened(-1.5)
	M.adjustStaminaLoss(-1.5)
	M.SetSleeping(0)
	..()

/datum/reagent/fliptonium/reagent_deleted(mob/living/M)
	M.SpinAnimation(speed = 12, loops = -1)

/datum/reagent/fliptonium/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] can't seem to control their legs!</span>")
			M.confused += 33
			M.Weaken(2)
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
			M.Weaken(5)
		else if(effect <= 7)
			M.emote("laugh")

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

/datum/chemical_reaction/lube/ultra
	name = "Ultra-Lube"
	id = "ultralube"
	result = "ultralube"
	required_reagents = list("lube" = 2, "formaldehyde" = 1, "cryostylane" = 1)
	result_amount = 2
	mix_message = "The mixture darkens and appears to partially vaporize into a chilling aerosol."

/datum/reagent/lube/ultra/on_mob_life(mob/living/M)
	var/high_message = pick("You feel your servos whir!", "You feel like you need to go faster.", "You feel like you were just overclocked!")
	if(prob(1))
		if(prob(1))
			high_message = "0100011101001111010101000101010001000001010001110100111101000110010000010101001101010100!"
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
	M.adjustStaminaLoss(-2)
	M.status_flags |= GOTTAGOREALLYFAST
	M.Jitter(3)
	M.adjustBrainLoss(0.5)
	if(prob(5))
		M.emote(pick("twitch", "shiver"))
	..()

/datum/reagent/lube/ultra/reagent_deleted(mob/living/M)
	M.status_flags &= ~GOTTAGOREALLYFAST
	..()

/datum/reagent/lube/ultra/overdose_process(mob/living/M, severity)
	if(prob(20))
		M.emote("ping")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	if(prob(50))
		M.adjustFireLoss(10)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	..()

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


/datum/reagent/surge/on_mob_life(mob/living/M)
	M.druggy = max(M.druggy, 15)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(1))
		if(prob(1))
			high_message = "01010100010100100100000101001110010100110100001101000101010011100100010001000101010011100100001101000101."
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	..()

/datum/reagent/surge/overdose_process(mob/living/M, severity)
	//Hit them with the same effects as an electrode!
	M.Stun(5)
	M.Weaken(5)
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
		M.adjustFireLoss(rand(1,5)*REM)
		M.adjustBruteLoss(rand(1,5)*REM)

/datum/chemical_reaction/surge
	name = "Surge"
	id = "surge"
	result = "surge"
	required_reagents = list("thermite" = 3, "uranium" = 1, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 6
	mix_message = "The mixture congeals into a metallic green gel that crackles with electrical activity."
