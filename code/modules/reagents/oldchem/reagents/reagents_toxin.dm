/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A Toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/toxin/on_mob_life(mob/living/M)
	M.adjustToxLoss(2)
	..()

/datum/reagent/spider_venom
	name = "Spider venom"
	id = "spidertoxin"
	description = "A toxic venom injected by spacefaring arachnids."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/spider_venom/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5)
	..()

/datum/reagent/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic, do not eat."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/plasticide/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5)
	..()


/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0

/datum/reagent/minttoxin/on_mob_life(mob/living/M)
	if(FAT in M.mutations)
		M.gib()
	..()

/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40

/datum/reagent/slimejelly/on_mob_life(mob/living/M)
	if(prob(10))
		to_chat(M, "<span class='danger'>Your insides are burning!</span>")
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(40))
		M.adjustBruteLoss(-5*REM)
	..()

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/slimetoxin/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(human.species.name != "Shadow")
			to_chat(M, "<span class='danger'>Your flesh rapidly mutates!</span>")
			to_chat(M, "<span class='danger'>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</span>")
			to_chat(M, "<span class='danger'>Your body reacts violently to light. \green However, it naturally heals in darkness.</span>")
			to_chat(M, "<span class='danger'>Aside from your new traits, you are mentally unchanged and retain your prior obligations.</span>")
			human.set_species("Shadow")
	..()

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/aslimetoxin/reaction_mob(mob/living/M, method=TOUCH, volume)
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

/datum/reagent/mercury/on_mob_life(mob/living/M)
	if(prob(70))
		M.adjustBrainLoss(1)
	..()

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	penetrates_skin = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/chlorine/on_mob_life(mob/living/M)
	M.adjustFireLoss(1)
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#6A6054"
	penetrates_skin = 1
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/fluorine/on_mob_life(mob/living/M)
	M.adjustFireLoss(1)
	M.adjustToxLoss(1*REM)
	..()

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	metabolization_rate = 0.4
	penetrates_skin = 1

/datum/reagent/radium/on_mob_life(mob/living/M)
	if(M.radiation < 80)
		M.apply_effect(4, IRRADIATE, negate_armor = 1)
	..()

/datum/reagent/radium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#04DF27"
	metabolization_rate = 0.3

/datum/reagent/mutagen/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==TOUCH && prob(33)) || method==INGEST)
		randmutb(M)
		domutcheck(M, null)
		M.UpdateAppearance()

/datum/reagent/mutagen/on_mob_life(mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	M.apply_effect(2*REM, IRRADIATE, negate_armor = 1)
	if(prob(4))
		randmutb(M)
	..()


/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

/datum/reagent/uranium/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE, negate_armor = 1)
	..()

/datum/reagent/uranium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !istype(T, /turf/space))
		new /obj/effect/decal/cleanable/greenglow(T)


/datum/reagent/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#52685D"
	metabolization_rate = 0.2

/datum/reagent/lexorin/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	..()


/datum/reagent/sacid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	color = "#00D72B"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/sacid/on_mob_life(mob/living/M)
	M.adjustFireLoss(1)
	..()

/datum/reagent/sacid/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(volume > 25)

				if(H.wear_mask)
					to_chat(H, "<span class='danger'>Your mask protects you from the acid!</span>")
					return

				if(H.head)
					to_chat(H, "<span class='danger'>Your helmet protects you from the acid!</span>")
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

/datum/reagent/sacid/reaction_obj(obj/O, volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(40))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			O.visible_message("<span class='warning'>[O] melts.</span>")
			qdel(O)


/datum/reagent/hellwater
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
	process_flags = ORGANIC | SYNTHETIC		//Admin-bus has no brakes! KILL THEM ALL.
	metabolization_rate = 1

/datum/reagent/hellwater/on_mob_life(mob/living/M)
	M.fire_stacks = min(5, M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1)
	M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	..()


/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51

/datum/reagent/carpotoxin/on_mob_life(mob/living/M)
	M.adjustToxLoss(2*REM)
	..()

/datum/reagent/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13

/datum/reagent/staminatoxin/on_mob_life(mob/living/M)
	M.adjustStaminaLoss(REM * data)
	data = max(data - 1, 3)
	..()


/datum/reagent/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A natural toxin produced by blob spores that inhibits vision when ingested."
	color = "#9ACD32"

/datum/reagent/spores/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	M.damageoverlaytemp = 60
	M.eye_blurry = max(M.eye_blurry, 3)
	..()

/datum/reagent/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/beer2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 50)
			M.AdjustSleeping(1)
		if(51 to INFINITY)
			M.AdjustSleeping(1)
			M.adjustToxLoss((current_cycle - 50)*REM)
	..()

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "This shit goes in pepperspray."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

/datum/reagent/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if( victim.wear_mask.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if( victim.wear_mask.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if( victim.head.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.head
				if( victim.head.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if( !safe_thing )
					safe_thing = victim.glasses
			if( eyes_covered && mouth_covered )
				to_chat(victim, "<span class='danger'>Your [safe_thing] protects you from the pepperspray!</span>")
				return
			else if( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, "<span class='danger'>Your [safe_thing] protect you from most of the pepperspray!</span>")
				if(prob(5))
					victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.eye_blind = max(M.eye_blind, 1)
				victim.confused = max(M.confused, 3)
				victim.damageoverlaytemp = 60
				victim.Weaken(3)
				victim.drop_item()
				return
			else if( eyes_covered ) // Eye cover is better than mouth cover
				to_chat(victim, "<span class='danger'>Your [safe_thing] protects your eyes from the pepperspray!</span>")
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				to_chat(victim, "<span class='danger'>You're sprayed directly in the eyes with pepperspray!</span>")
				victim.eye_blurry = max(M.eye_blurry, 5)
				victim.eye_blind = max(M.eye_blind, 2)
				victim.confused = max(M.confused, 6)
				victim.damageoverlaytemp = 75
				victim.Weaken(5)
				victim.drop_item()

/datum/reagent/condensedcapsaicin/on_mob_life(mob/living/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()