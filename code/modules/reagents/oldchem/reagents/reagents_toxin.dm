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
		M << "\red Your insides are burning!"
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(40))
		M.heal_organ_damage(5*REM,0)
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
			M << "\red Your flesh rapidly mutates!"
			M << "<b>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</b>"
			M << "\red Your body reacts violently to light. \green However, it naturally heals in darkness."
			M << "Aside from your new traits, you are mentally unchanged and retain your prior obligations."
			human.set_species("Shadow")
	..()
	return

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/aslimetoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(istype(M, /mob/living/carbon) && M.stat != DEAD)
		M << "\red Your flesh rapidly mutates!"
		if(M.notransform)	return
		M.notransform = 1
		M.canmove = 0
		M.icon = null
		M.overlays.Cut()
		M.invisibility = 101
		for(var/obj/item/W in M)
			if(istype(W, /obj/item/weapon/implant))	//TODO: Carn. give implants a dropped() or something
				qdel(W)
				continue
			W.layer = initial(W.layer)
			W.loc = M.loc
			W.dropped(M)
		var/mob/living/carbon/slime/new_mob = new /mob/living/carbon/slime(M.loc)
		new_mob.a_intent = I_HARM
		new_mob.universal_speak = 1
		if(M.mind)
			M.mind.transfer_to(new_mob)
		else
			new_mob.key = M.key
		qdel(M)
	..()
	return


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
		M.apply_effect(4,IRRADIATE,0)
	// radium may increase your chances to cure a disease
	if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
		var/mob/living/carbon/C = M
		if(C.virus2.len)
			for (var/ID in C.virus2)
				var/datum/disease2/disease/V = C.virus2[ID]
				if(prob(5))
					if(prob(50))
						M.apply_effect(50,IRRADIATE,0) // curing it that way may kill you instead
						M.adjustToxLoss(100)
					C.antibodies |= V.antigen
	..()
	return

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
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		M.UpdateAppearance()
	return

/datum/reagent/mutagen/on_mob_life(var/mob/living/M as mob)
	if(!M.dna) return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if(!M) M = holder.my_atom
	M.apply_effect(2*REM,IRRADIATE,0)
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
	M.apply_effect(2,IRRADIATE,0)
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
					H << "\red Your mask protects you from the acid!"
					return

				if(H.head)
					H << "\red Your helmet protects you from the acid!"
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
				M << "<span class = 'danger'>The greenish acidic substance stings you, but isn't concentrated enough to harm you!</span>"

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
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(40))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				M << "\red \the [O] melts."
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
/*
/datum/reagent/nanomachines
	name = "Nanomachines"
	id = "nanomachines"
	description = "Microscopic construction robots."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/nanomachines/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/robotic_transformation(0),1)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/xeno_transformation(0),1)
*/

/datum/reagent/spore
	name = "Blob Spores"
	id = "spore"
	description = "Spores of some blob creature thingy."
	reagent_state = LIQUID
	color = "#CE760A" // rgb: 206, 118, 10
	var/client/blob_client = null
	var/blob_point_rate = 3

/datum/reagent/spore/on_mob_life(var/mob/living/M)
	if(!M) M = holder.my_atom
	if (holder.has_reagent("atrazine",45))
		holder.del_reagent("spore")
	if (prob(1))
		M << "\red Your mouth tastes funny."
	if (prob(1) && prob(25))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(directory[ckey(C.key)])
				blob_client = directory[ckey(C.key)]
				C.gib()
				if(blob_client)
					var/obj/effect/blob/core/core = new(get_turf(C), 200, blob_client, blob_point_rate)
					if(core.overmind && core.overmind.mind)
						core.overmind.mind.name = C.name

	return

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
				victim << "\red Your [safe_thing] protects you from the pepperspray!"
				return
			else if ( mouth_covered )	// Reduced effects if partially protected
				victim << "\red Your [safe_thing] protect you from most of the pepperspray!"
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
				victim << "\red Your [safe_thing] protects your eyes from the pepperspray!"
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				victim << "\red You're sprayed directly in the eyes with pepperspray!"
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