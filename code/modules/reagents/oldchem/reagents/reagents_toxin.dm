/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A Toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(2)
	..()
	return


/datum/reagent/spider_venom
	name = "Spider venom"
	id = "spidertoxin"
	description = "A toxic venom injected by spacefaring arachnids."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/spider_venom/on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.adjustToxLoss(1.5)
		..()
		return


// Terror Spider, Green, Harmless Pheremone


/datum/reagent/terror_green_toxin
	name = "Green Terror Pheromone"
	id = "terror_green_toxin"
	description = "A nontoxic pheromone used by the green terror spider."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1


// Terror Spider, Black, Deadly Venom

/datum/reagent/terror_black_toxin
	name = "Black Widow venom"
	id = "terror_black_toxin"
	description = "An incredibly toxic venom injected by the Black Widow spider."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

/datum/reagent/terror_black_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if (volume >= 45)
		// bitten 4 or more times, whole body goes into shock/death
		// total damage: 12, human health 150 until crit, = 12.5 ticks, = 25s until death
		M.adjustToxLoss(12)
		M.eye_blurry = max(M.eye_blurry, 9)
		M.Paralyse(5)
	else if (volume >= 30)
		// bitten thrice, die very quickly, severe muscle cramps make movement very difficult. Even calling for help probably won't save you.
		// total damage: 8, human health 150 until crit, = 18.75 ticks, = 37s until death
		M.adjustToxLoss(8) // a bit worse than coiine
		M.confused = max(M.confused, 6)
		M.eye_blurry = max(M.eye_blurry, 6)
	else if (volume >= 15)
		// bitten twice, die more quickly, muscle cramps make movement difficult. Call medics immediately.
		// total damage: 4, human health 150 until crit, = 37.5 ticks, = 75s = 1m15s until death
		M.adjustToxLoss(4)
		M.confused = max(M.confused, 3)
		M.eye_blurry = max(M.eye_blurry, 3)
	else
		// bitten once, die slowly. Easy to survive a single bite - just go to medbay.
		// total damage: 2/tick, human health 150 until crit, = 75 ticks, = 150 seconds = 2.5 minutes to get to medbay.
		M.adjustToxLoss(2) // same damage/tick as tabun cycle 0 to 60
	..()
	return

// Terror Spider, White, Tranq

/datum/reagent/terror_white_tranq
	name = "White Spider tranquilizer"
	id = "terror_white_tranq"
	description = "A venom that incapacitites those who attack the White Death spider."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1

/datum/reagent/terror_white_tranq/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// effects are similar to ketamine, aka the sleepy pen
	if(current_cycle >= 3)
		M.confused = max(M.confused, 5)
	if(current_cycle >= 6)
		M.eye_blurry = max(M.eye_blurry, 5)
	if(current_cycle >= 10)
		M.Paralyse(10)
	..()
	return

// Terror Spider, White, Egg Venom

/datum/reagent/terror_white_toxin
	name = "White Spider venom"
	id = "terror_white_toxin"
	description = "A venom consisting of thousands of tiny spider eggs. When injected under the skin, they feed on living flesh and grow into new spiders."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1
	var/wdstage = 0
	var/wdtreated = 0
	var/awaymission_infection = 0
	var/alternate_ending = 0

/datum/reagent/terror_white_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// I want there to be a (difficult, little-known) treatment for this, but nothing fits!
	//	spaceacillin doesn't work because its an antibiotic not an antiparasite
	//	charcoal doesn't work because its a toxin scrubber not an antiparasite
	//	calomel doesn't work because its a purgative not an antiparasite
	//	...
	// What would make most sense, I suppose, is surgery... but... surgery is easy...
	if (wdtreated)
		if (prob(30))
			to_chat(M,"<span class='notice'> You feel better, as your black flesh begins to heal.</span>")
			M.reagents.remove_reagent("terror_white_toxin", 100)
	else
		if (holder.has_reagent("terror_white_antitoxin",1))
			if (wdstage < 150)
				wdtreated = 1
				to_chat(M,"<span class='notice'> The antivenom burns in your veins!</span>")
				M.adjustToxLoss(40)
		else
			wdstage += 1 // since charcoal, calomel, and dialysis can't purge us... only option left is our unique antidote
	if (volume < 30)
		volume += 10 // this is more than dialysis (-3) calomel (-5) and charcoal -1) combined could pump out in a tick.
	else if (volume < 50)
		volume += 1
	else if (volume < 100)
		volume += 0.1
	M.reagents.remove_reagent("terror_black_toxin", 30)
	if(M.health < -25)
		to_chat(M,"<span class='notice'> You feel a strange, blissful senstation.</span>")
		M.adjustBruteLoss(-5)
		M.adjustFireLoss(-5)
		M.adjustToxLoss(-5)
		// the spider eggs secrete stimulants/etc to keep their host alive until they hatch
	if (wdstage == 1) // immediately
		to_chat(M,"<span class='danger'> Your spider bite wound hurts horribly! </span>")
		if(istype(get_area(M), /area/awaycontent) || istype(get_area(M), /area/awaymission/))
			awaymission_infection = 1
	if (wdstage == 15) // 30 seconds... enough time for the nerve agent to kick in, the pain to be blocked, and healing to begin
		to_chat(M,"<span class='notice'> The pain has faded, and stopped bleeding, though the skin around it has turned black.</span>")
		M.adjustBruteLoss(-10)
		M.adjustToxLoss(-10)
	if (wdstage == 60) // 2 minutes... the point where the venom uses and accellerates the healing process, to feed the eggs
		to_chat(M,"<span class='notice'> Your bite wound has completely sealed up, though the skin is still black. You feel significantly better.</span>")
		M.adjustBruteLoss(-20)
		M.adjustToxLoss(-20)
	if (wdstage == 120) // 4 minutes... where the eggs are developing, and the wound is turning into a hatching site, but invisibly
		to_chat(M,"<span class='notice'> The black flesh around your old spider bite wound has started to peel off.</span>")
	if (wdstage == 150) // 5 minutes... where the victim realizes something is wrong - this is not a normal wound
		to_chat(M,"<span class='danger'> The black flesh around your spider bite wound has cracked, and started to split open!</span>")
	if (wdstage == 165) // 5m 30s
		to_chat(M,"<span class='danger'> The black flesh splits open completely, revealing a cluster of small black oval shapes inside you, shapes that seem to be moving!</span>")
	if (wdstage == 180) // 6m
		if (awaymission_infection && !istype(get_area(M), /area/awaycontent) && !istype(get_area(M), /area/awaymission/))
			// we started in the awaymission, we ended on the station.
			// To prevent someone bringing an infection back, we're going to trigger an alternate, equally-bad result here.
			// Actually, let's make it slightly worse... just to discourage people from bringing back infections.
			alternate_ending = 1
		to_chat(M,"<span class='danger'> The shapes extend tendrils out of your wound... no... those are legs! SPIDER LEGS! You have spiderlings growing inside you! You scratch at the wound, but it just aggrivates them - they swarm out of the wound, biting you all over!</span>")
		M.visible_message("<span class='danger'>[M] flails around on the floor as spiderlings erupt from their skin and swarm all over them! </span>")
		M.Stun(20)
		M.Weaken(20)
		// yes, this is a hella long stun - that's intentional. Gotta give the spiderlings time to escape.
		var/obj/effect/spider/terror_spiderling/S1 = new(get_turf(M))
		S1.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/red
		S1.name = "red spiderling"
		var/obj/effect/spider/terror_spiderling/S2 = new(get_turf(M))
		S2.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/gray
		S2.name = "gray spiderling"
		var/obj/effect/spider/terror_spiderling/S3 = new(get_turf(M))
		S3.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/green
		S3.name = "green spiderling"
		wdtreated = 1 // to ensure it is removed from their system.
		M.adjustBruteLoss(20)
		M.adjustToxLoss(80)
		if (alternate_ending)
			// This is the alternate ending of the infestation, triggered above by someone bringing back an infection from a gateway mission to the main station.
			// In this ending, we still spawn spiderlings - but we make sure they're stillborn, and don't grow up.
			// In addition, we give you an extra 60 toxin... enough to crit most people.
			S1.stillborn = 1
			S2.stillborn = 1
			S3.stillborn = 1
			M.adjustToxLoss(30)
	if (wdstage == 190) // 6m 30s
		to_chat(M,"<span class='danger'>The spiderlings are gone. Your wound, though, looks worse than ever. Remnants of tiny spider eggs, and dead spiders, inside your flesh. Disgusting.</span>")
		M.reagents.remove_reagent("terror_white_toxin", 100)
	..()
	return

// Terror Spider, White, Anti Toxin

/datum/reagent/terror_white_antitoxin
	name = "White Spider Antitoxin"
	id = "terror_white_antitoxin"
	description = "A strange serum that destroys spider eggs."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 0.1


// Terror Spider, Queen

/datum/reagent/terror_queen_toxin
	name = "Terror Queen venom"
	id = "terror_queen_toxin"
	description = "A royally potent venom."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	metabolization_rate = 2

/datum/reagent/terror_queen_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	// make them hallucinate a lot, like a changeling sting
	if (M.hallucination < 400)
		M.hallucination += 50
	return




// End Spiders.


/datum/reagent/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic, do not eat."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/plasticide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1.5)
	..()
	return


/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/minttoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if (FAT in M.mutations)
		M.gib()
	..()
	return


/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/slimejelly/on_mob_life(var/mob/living/M as mob)
	if(prob(10))
		to_chat(M, "\red Your insides are burning!")
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(40))
		M.adjustBruteLoss(-5*REM)
	..()
	return

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/slimetoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(human.species.name != "Shadow")
			to_chat(M, "\red Your flesh rapidly mutates!")
			to_chat(M, "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>")
			to_chat(M, "\red Your body reacts violently to light. \green However, it naturally heals in darkness.")
			to_chat(M, "Aside from your new traits, you are mentally unchanged and retain your prior obligations.")
			human.set_species("Shadow")
	..()
	return

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/aslimetoxin/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(method != TOUCH)
		M.ForceContractDisease(new /datum/disease/transformation/slime(0))


/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	metabolization_rate = 0.2
	penetrates_skin = 1

/datum/reagent/mercury/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(70))
		M.adjustBrainLoss(1)
	..()
	return


/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	penetrates_skin = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/chlorine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	..()
	return

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#6A6054"
	penetrates_skin = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/fluorine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	M.adjustToxLoss(1*REM)
	..()
	return


/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	metabolization_rate = 0.4
	penetrates_skin = 1

/datum/reagent/radium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.radiation < 80)
		M.apply_effect(4, IRRADIATE, negate_armor = 1)
	..()

/datum/reagent/radium/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			new /obj/effect/decal/cleanable/greenglow(T)
			return


/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#04DF27"
	metabolization_rate = 0.3

/datum/reagent/mutagen/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(!..())	return
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	src = null
	if((method==TOUCH && prob(33)) || method==INGEST)
		randmutb(M)
		domutcheck(M, null)
		M.UpdateAppearance()
	return

/datum/reagent/mutagen/on_mob_life(var/mob/living/M as mob)
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M) M = holder.my_atom
	M.apply_effect(2*REM, IRRADIATE, negate_armor = 1)
	if(prob(4))
		randmutb(M)
	..()
	return


/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

/datum/reagent/uranium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.apply_effect(2, IRRADIATE, negate_armor = 1)
	..()
	return

/datum/reagent/uranium/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			new /obj/effect/decal/cleanable/greenglow(T)


/datum/reagent/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#52685D"
	metabolization_rate = 0.2

/datum/reagent/lexorin/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1)
	..()
	return


/datum/reagent/sacid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	color = "#00D72B"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/sacid/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	..()
	return

/datum/reagent/sacid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(volume > 25)
				if(H.wear_mask)
					to_chat(H, "\red Your mask protects you from the acid!")
					return
				if(H.head)
					to_chat(H, "\red Your helmet protects you from the acid!")
					return
				if(!M.unacidable)
					if(prob(75))
						var/obj/item/organ/external/affecting = H.get_organ("head")
						if(affecting)
							affecting.take_damage(5, 10)
							H.UpdateDamageIcon()
							H.emote("scream")
					else
						M.take_organ_damage(5,10)
			else
				M.take_organ_damage(5,10)
	if(method == INGEST)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(volume < 10)
				to_chat(M, "<span class='danger'>The greenish acidic substance stings you, but isn't concentrated enough to harm you!</span>")
			if(volume >=10 && volume <=25)
				if(!H.unacidable)
					M.take_organ_damage(0,min(max(volume-10,2)*2,20))
					M.emote("scream")
			if(volume > 25)
				if(!M.unacidable)
					if(prob(75))
						var/obj/item/organ/external/affecting = H.get_organ("head")
						if(affecting)
							affecting.take_damage(0, 20)
							H.UpdateDamageIcon()
							H.emote("scream")
					else
						M.take_organ_damage(0,20)

/datum/reagent/sacid/reaction_obj(var/obj/O, var/volume)
	if((istype(O, /obj/item) || istype(O, /obj/effect/glowshroom)) && prob(40))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				to_chat(M, "\red \the [O] melts.")
			qdel(O)


/datum/reagent/hellwater
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
	process_flags = ORGANIC | SYNTHETIC		//Admin-bus has no brakes! KILL THEM ALL.

/datum/reagent/hellwater/on_mob_life(var/mob/living/M as mob)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1)
	M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)


/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51

/datum/reagent/carpotoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(2*REM)
	..()
	return


/datum/reagent/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13

/datum/reagent/staminatoxin/on_mob_life(var/mob/living/M)
	M.adjustStaminaLoss(REM * data)
	data = max(data - 1, 3)
	..()


/datum/reagent/spores
	name = "Spore Toxin"
	id = "spores"
	description = "A toxic spore cloud which blocks vision when ingested."
	color = "#9ACD32"

/datum/reagent/spores/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1)
	M.damageoverlaytemp = 60
	M.eye_blurry = max(M.eye_blurry, 3)
	..()
	return


/datum/reagent/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/beer2/on_mob_life(var/mob/living/M as mob)
	if(!data)
		data = 1
	switch(data)
		if(1 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss((data - 50)*REM)
	data++
	..()
	return


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "This shit goes in pepperspray."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if ( victim.wear_mask.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if ( victim.head.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.head
				if ( victim.head.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if ( !safe_thing )
					safe_thing = victim.glasses
			if ( eyes_covered && mouth_covered )
				to_chat(victim, "\red Your [safe_thing] protects you from the pepperspray!")
				return
			else if ( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, "\red Your [safe_thing] protect you from most of the pepperspray!")
				if(prob(5))
					victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.eye_blind = max(M.eye_blind, 1)
				victim.confused = max(M.confused, 3)
				victim.damageoverlaytemp = 60
				victim.Weaken(3)
				victim.drop_item()
				return
			else if ( eyes_covered ) // Eye cover is better than mouth cover
				to_chat(victim, "\red Your [safe_thing] protects your eyes from the pepperspray!")
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				to_chat(victim, "\red You're sprayed directly in the eyes with pepperspray!")
				victim.eye_blurry = max(M.eye_blurry, 5)
				victim.eye_blind = max(M.eye_blind, 2)
				victim.confused = max(M.confused, 6)
				victim.damageoverlaytemp = 75
				victim.Weaken(5)
				victim.drop_item()

/datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()
	return