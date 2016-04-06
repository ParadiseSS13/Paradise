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

/datum/reagent/nicotine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/smoke_message = pick("You feel relaxed.", "You feel calmed.", "You feel less stressed.", "You feel more placid.", "You feel more undivided.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[smoke_message]</span>")
	if(prob(50))
		M.AdjustParalysis(-1)
		M.AdjustStunned(-1)
		M.AdjustWeakened(-1)
		M.adjustStaminaLoss(-1*REM)
	..()
	return

/datum/reagent/nicotine/overdose_process(var/mob/living/M as mob)
	M.adjustToxLoss(1*REM)
	M.adjustOxyLoss(1*REM)
	..()
	return

/datum/reagent/crank
	name = "Crank"
	id = "crank"
	description = "Reduces stun times by about 200%. If overdosed or addicted it will deal significant Toxin, Brute and Brain damage."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 50

/datum/reagent/crank/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return
/datum/reagent/crank/overdose_process(var/mob/living/M as mob)
	M.adjustBrainLoss(rand(1,10)*REM)
	M.adjustToxLoss(rand(1,10)*REM)
	M.adjustBruteLoss(rand(1,10)*REM)
	..()
	return

/datum/chemical_reaction/crank
	name = "Crank"
	id = "crank"
	result = "crank"
	required_reagents = list("diphenhydramine" = 1, "ammonia" = 1, "lithium" = 1, "sacid" = 1, "fuel" = 1)
	result_amount = 5
	mix_message = "The mixture violently reacts, leaving behind a few crystalline shards."
	mix_sound = 'sound/goonstation/effects/crystalshatter.ogg'
	min_temp = 390

/datum/chemical_reaction/crank/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)
	explosion(T,0,0,2)
	return

/datum/reagent/krokodil
	name = "Krokodil"
	id = "krokodil"
	description = "A sketchy homemade opiate, often used by disgruntled Cosmonauts."
	reagent_state = LIQUID
	color = "#0264B4"
	overdose_threshold = 20
	addiction_chance = 50


/datum/reagent/krokodil/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

/datum/reagent/krokodil/overdose_process(var/mob/living/M as mob)
	if(prob(10))
		M.adjustBrainLoss(rand(1,5)*REM)
		M.adjustToxLoss(rand(1,5)*REM)
	..()
	return

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

/datum/reagent/methamphetamine/meth2 //for donk pockets
	id = "methamphetamine2"
	addiction_chance = 0

/datum/reagent/methamphetamine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

/datum/reagent/methamphetamine/overdose_process(var/mob/living/M as mob)
	if(prob(20))
		M.emote("laugh")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	..()
	if(prob(50))
		M.adjustToxLoss(10)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	return

/datum/chemical_reaction/methamphetamine
	name = "methamphetamine"
	id = "methamphetamine"
	result = "methamphetamine"
	required_reagents = list("ephedrine" = 1, "iodine" = 1, "phosphorus" = 1, "hydrogen" = 1)
	result_amount = 4
	min_temp = 374

/datum/chemical_reaction/methamphetamine/on_reaction(var/datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>The solution generates a strong vapor!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(!(C.wear_mask && (C.internals != null || C.wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)))
			C.emote("gasp")
			C.losebreath++
			C.reagents.add_reagent("toxin",10)
			C.reagents.add_reagent("neurotoxin2",20)

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
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 20
	addiction_chance = 80
	metabolization_rate = 0.6


/datum/reagent/bath_salts/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	var/high_message = pick("You feel amped up.", "You feel ready.", "You feel like you can push it to the limit.")
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	M.AdjustParalysis(-5)
	M.AdjustStunned(-5)
	M.AdjustWeakened(-5)
	M.adjustStaminaLoss(-10)
	M.adjustBrainLoss(1)
	M.adjustToxLoss(0.1)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /turf/space))
		step(M, pick(cardinal))
		step(M, pick(cardinal))
	..()
	return

/datum/chemical_reaction/bath_salts
	name = "bath_salts"
	id = "bath_salts"
	result = "bath_salts"
	required_reagents = list("????" = 1, "saltpetre" = 1, "msg" = 1, "cleaner" = 1, "enzyme" = 1, "mugwort" = 1, "mercury" = 1)
	result_amount = 6
	min_temp = 374
	mix_message = "Tiny cubic crystals precipitate out of the mixture. Huh."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/reagent/bath_salts/overdose_process(var/mob/living/M as mob)
	M.hallucination += 10
	if(M.canmove && !istype(M.loc, /turf/space))
		for(var/i = 0, i < 8, i++)
			step(M, pick(cardinal))
	if(prob(20))
		M.emote(pick("twitch","drool","moan"))
	if(prob(33))
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	..()
	return

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

/datum/reagent/aranesp/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

/datum/reagent/thc
	name = "Tetrahydrocannabinol"
	id = "thc"
	description = "A mild psychoactive chemical extracted from the cannabis plant."
	reagent_state = LIQUID
	color = "#0FBE0F"


/datum/reagent/thc/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

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

/datum/reagent/fliptonium/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == INGEST || method == TOUCH)
		M.SpinAnimation(speed = 12, loops = -1)
	..()

/datum/reagent/fliptonium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

/datum/reagent/fliptonium/reagent_deleted(var/mob/living/M as mob)
	M.SpinAnimation(speed = 12, loops = -1)

/datum/reagent/fliptonium/overdose_process(var/mob/living/M as mob)
	if(volume > 15)
		if(prob(5))
			switch(pick(1, 2, 3))
				if(1)
					M.emote("laugh")
					M.adjustToxLoss(1)
				if(2)
					to_chat(M, "<span class='danger'>[M] can't seem to control their legs!</span>")
					M.Weaken(8)
					M.adjustToxLoss(1)
				if(3)
					to_chat(M, "<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
					M.drop_l_hand()
					M.drop_r_hand()
					M.adjustToxLoss(1)
	..()
	return

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

/datum/reagent/lube/ultra/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
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
	return

/datum/reagent/lube/ultra/overdose_process(var/mob/living/M as mob)
	if(prob(20))
		M.emote("ping")
	if(prob(33))
		M.visible_message("<span class='danger'>[M]'s hands flip out and flail everywhere!</span>")
		var/obj/item/I = M.get_active_hand()
		if(I)
			M.drop_item()
	..()
	if(prob(50))
		M.adjustFireLoss(10)
	M.adjustBrainLoss(pick(0.5, 0.6, 0.7, 0.8, 0.9, 1))
	return

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


/datum/reagent/surge/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 15)
	var/high_message = pick("You feel calm.", "You feel collected.", "You feel like you need to relax.")
	if(prob(1))
		if(prob(1))
			high_message = "01010100010100100100000101001110010100110100001101000101010011100100010001000101010011100100001101000101."
	if(prob(5))
		to_chat(M, "<span class='notice'>[high_message]</span>")
	..()
	return

/datum/reagent/surge/overdose_process(var/mob/living/M as mob)
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
	..()
	return

/datum/chemical_reaction/surge
	name = "Surge"
	id = "surge"
	result = "surge"
	required_reagents = list("thermite" = 3, "uranium" = 1, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 6
	mix_message = "The mixture congeals into a metallic green gel that crackles with electrical activity."
