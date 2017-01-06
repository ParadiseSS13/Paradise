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
		M.adjustToxLoss(rand(20,60)*REAGENTS_EFFECT_MULTIPLIER)
	else if(prob(40))
		M.adjustBruteLoss(-5*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	can_synth = 0

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
	can_synth = 0

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
	M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
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
	M.apply_effect(2*REAGENTS_EFFECT_MULTIPLIER, IRRADIATE, negate_armor = 1)
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

/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51

/datum/reagent/carpotoxin/on_mob_life(mob/living/M)
	M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13

/datum/reagent/staminatoxin/on_mob_life(mob/living/M)
	M.adjustStaminaLoss(REAGENTS_EFFECT_MULTIPLIER * data)
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
	M.EyeBlurry(3)
	..()

/datum/reagent/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	drink_icon ="beerglass"
	drink_name = "Beer glass"
	drink_desc = "A freezing pint of beer"

/datum/reagent/beer2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 50)
			M.Sleeping(2)
		if(51 to INFINITY)
			M.Sleeping(2)
			M.adjustToxLoss((current_cycle - 50)*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = 1
	can_synth = 0

/datum/reagent/polonium/on_mob_life(mob/living/M)
	M.apply_effect(8, IRRADIATE, negate_armor = 1)
	..()

/datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "Immune-system neurotransmitter. If detected in blood, the subject is likely undergoing an allergic reaction."
	reagent_state = LIQUID
	color = "#E7C4C4"
	metabolization_rate = 0.2
	overdose_threshold = 40

/datum/reagent/histamine/reaction_mob(mob/living/M, method=TOUCH, volume) //dumping histamine on someone is VERY mean.
	if(iscarbon(M))
		if(method == TOUCH)
			M.reagents.add_reagent("histamine",10)
		else
			to_chat(M, "<span class='danger'>You feel a burning sensation in your throat...</span>")
			M.emote("drool")

/datum/reagent/histamine/on_mob_life(mob/living/M)
	if(prob(20))
		M.emote(pick("twitch", "grumble", "sneeze", "cough"))
	if(prob(10))
		to_chat(M, "<span class='notice'>Your eyes itch.</span>")
		M.emote(pick("blink", "sneeze"))
		M.AdjustEyeBlurry(3)
	if(prob(10))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		M.adjustBruteLoss(1)
		M.emote("grumble")
	if(prob(5))
		to_chat(M, "<span class='danger'>You're getting a rash!</span>")
		M.adjustBruteLoss(2)
	..()

/datum/reagent/histamine/overdose_process(mob/living/M, severity)
	var/effect = ..()
	if(severity == 1)
		if(effect <= 2)
			to_chat(M, "<span class='warning'>You feel mucus running down the back of your throat.</span>")
			M.adjustToxLoss(1)
			M.Jitter(4)
			M.emote(pick("sneeze", "cough"))
		else if(effect <= 4)
			M.stuttering += rand(0,5)
			if(prob(25))
				M.emote(pick("choke","gasp"))
				M.adjustOxyLoss(5)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your chest hurts!</span>")
			M.emote(pick("cough","gasp"))
			M.adjustOxyLoss(3)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] breaks out in hives!</span>")
			M.adjustBruteLoss(6)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] has a horrible coughing fit!</span>")
			M.Jitter(10)
			M.stuttering += rand(0,5)
			M.emote("cough")
			if(prob(40))
				M.emote(pick("choke","gasp"))
				M.adjustOxyLoss(6)
			M.Weaken(8)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your heartbeat is pounding inside your head!</span>")
			M << 'sound/effects/singlebeat.ogg'
			M.emote("collapse")
			M.adjustOxyLoss(8)
			M.adjustToxLoss(3)
			M.Weaken(3)
			M.emote(pick("choke", "gasp"))
			to_chat(M, "<span class='warning'>You feel like you're dying!</span>")

/datum/reagent/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Formaldehyde is a common industrial chemical and is used to preserve corpses and medical samples. It is highly toxic and irritating."
	reagent_state = LIQUID
	color = "#DED6D0"
	penetrates_skin = 1

/datum/reagent/formaldehyde/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(10))
		M.reagents.add_reagent("histamine",rand(5,15))
	..()

/datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "An incredibly potent poison. Origin unknown."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
	overdose_threshold = 40
	can_synth = 0

/datum/reagent/venom/on_mob_life(mob/living/M)
	if(prob(25))
		M.reagents.add_reagent("histamine",rand(5,10))
	if(volume < 20)
		M.adjustToxLoss(1)
		M.adjustBruteLoss(1)
	else if(volume < 40)
		if(prob(8))
			M.fakevomit()
		M.adjustToxLoss(2)
		M.adjustBruteLoss(2)
	..()

/datum/reagent/venom/overdose_process(mob/living/M)
	if(volume >= 40)
		if(prob(4))
			M.visible_message("<span class='danger'><B>[M]</B> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
			M.Weaken(15)
			M.AdjustJitter(1000)
			spawn(rand(20, 100))
				M.gib()

/datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "A dangerous toxin that attacks the nervous system."
	reagent_state = LIQUID
	color = "#60A584"
	metabolization_rate = 1

/datum/reagent/neurotoxin2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 4)
			current_cycle++
			return
		if(5 to 8)
			M.AdjustDizzy(1)
			M.Confused(10)
		if(9 to 12)
			M.Drowsy(10)
			M.AdjustDizzy(1)
			M.Confused(20)
		if(13)
			M.emote("faint")
		if(14 to INFINITY)
			M.Paralyse(10)
			M.Drowsy(20)

	M.AdjustJitter(-30)
	if(M.getBrainLoss() <= 80)
		M.adjustBrainLoss(1)
	else
		if(prob(10))
			M.adjustBrainLoss(1)
	if(prob(10))
		M.emote("drool")
	M.adjustToxLoss(1)
	..()

/datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical with some uses as a building block for other things."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = 1

/datum/reagent/cyanide/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5*REAGENTS_EFFECT_MULTIPLIER)
	if(prob(5))
		M.emote("drool")
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.AdjustLoseBreath(1)
		M.emote("gasp")
	if(prob(8))
		to_chat(M, "<span class='danger'>You feel horrendously weak!</span>")
		M.Stun(2)
		M.adjustToxLoss(2)
	..()

/datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "An abrasive powder beloved by cruel pranksters."
	reagent_state = LIQUID
	color = "#B0B0B0"
	metabolization_rate = 0.3
	penetrates_skin = 1

/datum/reagent/itching_powder/on_mob_life(mob/living/M)
	if(prob(25))
		M.emote(pick("twitch", "laugh", "sneeze", "cry"))
	if(prob(20))
		to_chat(M, "<span class='notice'>Something tickles!</span>")
		M.emote(pick("laugh", "giggle"))
	if(prob(15))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		M.adjustBruteLoss(1)
		M.Stun(rand(0,1))
		M.emote("grumble")
	if(prob(10))
		to_chat(M, "<span class='danger'>So itchy!</span>")
		M.adjustBruteLoss(2)
	if(prob(6))
		M.reagents.add_reagent("histamine", rand(1,3))
	if(prob(2))
		to_chat(M, "<span class='danger'>AHHHHHH!</span>")
		M.adjustBruteLoss(5)
		M.Weaken(5)
		M.AdjustJitter(6)
		M.visible_message("<span class='danger'>[M] falls to the floor, scratching themselves violently!</span>")
		M.emote("scream")
	..()

/datum/reagent/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive super-acid."
	reagent_state = LIQUID
	color = "#4141D2"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/facid/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	M.adjustFireLoss(1)
	..()

/datum/reagent/facid/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH || method == INGEST)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(volume < 5)
				to_chat(M, "<span class='danger'>The blueish acidic substance stings you, but isn't concentrated enough to harm you!</span>")

			if(volume >=5 && volume <=10)
				if(!H.unacidable)
					M.take_organ_damage(0,max(volume-5,2)*4)
					M.emote("scream")


			if(volume > 10)

				if(method == TOUCH)
					if(H.wear_mask)
						if(!H.wear_mask.unacidable)
							qdel(H.wear_mask)
							H.update_inv_wear_mask()
							to_chat(H, "<span class='warning'>Your mask melts away but protects you from the acid!</span>")
						else
							to_chat(H, "<span class='warning'>Your mask protects you from the acid!</span>")
						return

					if(H.head)
						if(!H.head.unacidable)
							qdel(H.head)
							H.update_inv_head()
							to_chat(H, "<span class='warning'>Your helmet melts away but protects you from the acid</span>")
						else
							to_chat(H, "<span class='warning'>Your helmet protects you from the acid!</span>")
						return

				if(!H.unacidable)
					var/obj/item/organ/external/affecting = H.get_organ("head")
					affecting.take_damage(0, 75)
					H.UpdateDamageIcon()
					H.emote("scream")
					H.status_flags |= DISFIGURED

/datum/reagent/facid/reaction_obj(obj/O, volume)
	if((istype(O, /obj/item) || istype(O, /obj/effect/glowshroom)))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			O.visible_message("<span class='warning'>[O] melts.</span>")
			qdel(O)

/datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "A highly potent cardiac poison - can kill within minutes."
	reagent_state = LIQUID
	color = "#7F10C0"
	can_synth = 0

/datum/reagent/initropidril/on_mob_life(mob/living/M)
	if(prob(33))
		M.adjustToxLoss(rand(5,25))
	if(prob(33))
		to_chat(M, "<span class='danger'>You feel horribly weak.</span>")
		M.Stun(2)
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.adjustOxyLoss(10)
		M.AdjustLoseBreath(1)
	if(prob(10))
		to_chat(M, "<span class='danger'>Your chest is burning with pain!</span>")
		M.adjustOxyLoss(10)
		M.AdjustLoseBreath(1)
		M.Stun(3)
		M.Weaken(2)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.heart_attack)
				H.heart_attack = 1 // rip in pepperoni
	..()

/datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Pancuronium bromide is a powerful skeletal muscle relaxant."
	reagent_state = LIQUID
	color = "#1E4664"
	metabolization_rate = 0.2

/datum/reagent/pancuronium/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			if(prob(10))
				M.emote(pick("drool", "tremble"))
		if(6 to 10)
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				M.Stun(1)
			else if(prob(8))
				M.emote(pick("drool", "tremble"))
		if(11 to INFINITY)
			M.Stun(20)
			M.Weaken(20)
			if(prob(10))
				M.emote(pick("drool", "tremble", "gasp"))
				M.AdjustLoseBreath(1)
			if(prob(9))
				to_chat(M, "<span class='danger'>You can't [pick("move", "feel your legs", "feel your face", "feel anything")]!</span>")
			if(prob(7))
				to_chat(M, "<span class='danger'>You can't breathe!</span>")
				M.AdjustLoseBreath(3)
	..()

/datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "An rapidly-acting barbituate tranquilizer."
	reagent_state = LIQUID
	color = "#5F8BE1"
	metabolization_rate = 0.7
	can_synth = 0

/datum/reagent/sodium_thiopental/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1)
			M.emote("drool")
			M.Confused(5)
		if(2 to 4)
			M.Drowsy(20)
		if(5)
			M.emote("faint")
			M.Weaken(5)
		if(6 to INFINITY)
			M.Paralyse(20)
	M.AdjustJitter(-50)
	if(prob(10))
		M.emote("drool")
		M.adjustBrainLoss(1)
	..()

/datum/reagent/ketamine
	name = "Ketamine"
	id = "ketamine"
	description = "A potent veterinary tranquilizer."
	reagent_state = LIQUID
	color = "#646EA0"
	metabolization_rate = 0.8
	penetrates_skin = 1
	can_synth = 0

/datum/reagent/ketamine/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			if(prob(25))
				M.emote("yawn")
		if(6 to 9)
			M.AdjustEyeBlurry(5)
			if(prob(35))
				M.emote("yawn")
		if(10)
			M.emote("faint")
			M.Weaken(5)
		if(11 to INFINITY)
			M.Paralyse(25)
	..()

/datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#6BA688"
	metabolization_rate = 0.1

/datum/reagent/sulfonal/on_mob_life(mob/living/M)
	M.AdjustJitter(-30)
	switch(current_cycle)
		if(1 to 10)
			if(prob(7))
				M.emote("yawn")
		if(11 to 20)
			M.Drowsy(20)
		if(21)
			M.emote("faint")
		if(22 to INFINITY)
			if(prob(20))
				M.emote("faint")
				M.Paralyse(5)
			M.Drowsy(20)
	M.adjustToxLoss(1)
	..()

/datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "A toxin produced by certain mushrooms. Very deadly."
	reagent_state = LIQUID
	color = "#D9D9D9"

/datum/reagent/amanitin/on_mob_delete(mob/living/M)
	M.adjustToxLoss(current_cycle*rand(2,4))
	..()

/datum/reagent/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "A compound found in many seedy dollar stores in the form of a weight-loss tonic."
	reagent_state = SOLID
	color = "#D1DED1"
	metabolization_rate = 0.2

/datum/reagent/lipolicide/on_mob_life(mob/living/M)
	if(!M.nutrition)
		switch(rand(1,3))
			if(1)
				to_chat(M, "<span class='warning'>You feel hungry...</span>")
			if(2)
				M.adjustToxLoss(1)
				to_chat(M, "<span class='warning'>Your stomach grumbles painfully!</span>")
	else
		if(prob(60))
			var/fat_to_burn = max(round(M.nutrition/100,1), 5)
			M.nutrition = max(0, M.nutrition-fat_to_burn)
			M.overeatduration = 0
	..()

/datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "A neurotoxin that rapidly causes respiratory failure."
	reagent_state = LIQUID
	color = "#C2D8CD"
	metabolization_rate = 0.05
	can_synth = 0

/datum/reagent/coniine/on_mob_life(mob/living/M)
	M.adjustToxLoss(2)
	M.AdjustLoseBreath(5)
	..()

/datum/reagent/curare
	name = "Curare"
	id = "curare"
	description = "A highly dangerous paralytic poison."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.1
	penetrates_skin = 1

/datum/reagent/curare/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	M.adjustOxyLoss(1)
	switch(current_cycle)
		if(1 to 5)
			if(prob(20))
				M.emote(pick("drool", "pale", "gasp"))
		if(6 to 10)
			M.AdjustEyeBlurry(5)
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				M.Stun(1)
			else if(prob(8))
				M.emote(pick("drool","pale", "gasp"))
		if(11 to INFINITY)
			M.Stun(30)
			M.Drowsy(20)
			if(prob(20))
				M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
			else if(prob(8))
				to_chat(M, "<span class='danger'>You can't [pick("breathe", "move", "feel your legs", "feel your face", "feel anything")]!</span>")
				M.AdjustLoseBreath(1)
	..()

/datum/reagent/sarin
	name = "Sarin"
	id = "sarin"
	description = "An extremely deadly neurotoxin."
	reagent_state = LIQUID
	color = "#C7C7C7"
	metabolization_rate = 0.1
	penetrates_skin = 1
	overdose_threshold = 25

/datum/reagent/sarin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.AdjustJitter(20)
			if(prob(20))
				M.emote(pick("twitch","twitch_s","quiver"))
		if(16 to 30)
			if(prob(25))
				M.emote(pick("twitch","twitch","drool","quiver","tremble"))
			M.AdjustEyeBlurry(5)
			M.Stuttering(5)
			if(prob(10))
				M.Confused(15)
			if(prob(15))
				M.Stun(1)
				M.emote("scream")
		if(30 to 60)
			M.AdjustEyeBlurry(5)
			M.Stuttering(5)
			if(prob(10))
				M.Stun(1)
				M.emote(pick("twitch","twitch","drool","shake","tremble"))
			if(prob(5))
				M.emote("collapse")
			if(prob(5))
				M.Weaken(3)
				M.visible_message("<span class='warning'>[M] has a seizure!</span>")
				M.SetJitter(1000)
			if(prob(5))
				to_chat(M, "<span class='warning'>You can't breathe!</span>")
				M.emote(pick("gasp", "choke", "cough"))
				M.AdjustLoseBreath(1)
		if(61 to INFINITY)
			if(prob(15))
				M.emote(pick("gasp", "choke", "cough","twitch", "shake", "tremble","quiver","drool", "twitch","collapse"))
			M.LoseBreath(5)
			M.adjustToxLoss(1)
			M.adjustBrainLoss(1)
			M.Weaken(4)
	if(prob(8))
		M.fakevomit()
	M.adjustToxLoss(1)
	M.adjustBrainLoss(1)
	M.adjustFireLoss(1)
	..()

/datum/reagent/atrazine
	name = "Atrazine"
	id = "atrazine"
	description = "A herbicidal compound used for destroying unwanted plants."
	reagent_state = LIQUID
	color = "#17002D"

/datum/reagent/atrazine/on_mob_life(mob/living/M)
	M.adjustToxLoss(2)
	..()

/datum/reagent/atrazine/reaction_turf(turf/simulated/wall/W, volume) // Clear off wallrot fungi
	if(istype(W) && W.rotting)
		for(var/obj/effect/overlay/wall_rot/WR in W)
			qdel(WR)
		W.rotting = 0
		W.visible_message("<span class='warning'>The fungi are completely dissolved by the solution!</span>")

/datum/reagent/atrazine/reaction_obj(obj/O, volume)
	if(istype(O,/obj/structure/alien/weeds/))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O, /obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plant))
		if(prob(50))
			qdel(O) //Kills kudzu too.
	// Damage that is done to growing plants is separately at code/game/machinery/hydroponics at obj/item/hydroponics

/datum/reagent/atrazine/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 2 toxic damage per application
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
				H.adjustToxLoss(50)
				..()
	else if(istype(M, /mob/living/simple_animal/diona)) //plantmen monkeys (diona) take EVEN MORE damage
		var/mob/living/simple_animal/diona/D = M
		D.adjustHealth(100)
		..()

/datum/reagent/capulettium
	name = "Capulettium"
	id = "capulettium"
	description = "A rare drug that causes the user to appear dead for some time."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1

/datum/reagent/capulettium/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 5)
			M.AdjustEyeBlurry(10)
		if(6 to 10)
			M.Drowsy(10)
		if(11)
			M.Paralyse(10)
			M.visible_message("<B>[M]</B> seizes up and falls limp, their eyes dead and lifeless...") //so you can't trigger deathgasp emote on people. Edge case, but necessary.
		if(12 to 60)
			M.Paralyse(10)
		if(61 to INFINITY)
			M.AdjustEyeBlurry(10)
	..()

/datum/reagent/capulettium_plus
	name = "Capulettium Plus"
	id = "capulettium_plus"
	description = "A rare and expensive drug that causes the user to appear dead for some time while they retain consciousness and vision."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1

/datum/reagent/capulettium_plus/on_mob_life(mob/living/M)
	M.Silence(2)
	..()

/datum/reagent/toxic_slurry
	name = "Toxic Slurry"
	id = "toxic_slurry"
	description = "A filthy, carcinogenic sludge produced by the Slurrypod plant."
	reagent_state = LIQUID
	color = "#00C81E"

/datum/reagent/toxic_slurry/on_mob_life(mob/living/M)
	if(prob(10))
		M.adjustToxLoss(rand(2.4))
	if(prob(7))
		to_chat(M, "<span class='danger'>A horrible migraine overpowers you.</span>")
		M.Stun(rand(2,5))
	if(prob(7))
		M.fakevomit(1)
	..()

/datum/reagent/glowing_slurry
	name = "Glowing Slurry"
	id = "glowing_slurry"
	description = "This is probably not good for you."
	reagent_state = LIQUID
	color = "#00FD00"

/datum/reagent/glowing_slurry/reaction_mob(mob/living/M, method=TOUCH, volume) //same as mutagen
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==TOUCH && prob(50)) || method==INGEST)
		randmutb(M)
		domutcheck(M, null)
		M.UpdateAppearance()

/datum/reagent/glowing_slurry/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE, 0, negate_armor = 1)
	if(!M.dna)
		return
	if(prob(15))
		randmutb(M)
	if(prob(3))
		randmutg(M)
	domutcheck(M, null)
	M.UpdateAppearance()
	..()

/datum/reagent/ants
	name = "Ants"
	id = "ants"
	description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
	reagent_state = SOLID
	color = "#993333"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/ants/on_mob_life(mob/living/M)
	M.adjustBruteLoss(2)
	..()

/datum/reagent/ants/reaction_mob(mob/living/M, method=TOUCH, volume) //NOT THE ANTS
	if(iscarbon(M))
		if(method == TOUCH || method==INGEST)
			to_chat(M, "<span class='warning'>OH SHIT ANTS!!!!</span>")
			M.emote("scream")
			M.adjustBruteLoss(4)

/datum/reagent/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Teslium"
	id = "teslium"
	description = "An unstable, electrically-charged metallic slurry. Increases the conductance of living things."
	reagent_state = LIQUID
	color = "#20324D" //RGB: 32, 50, 77
	metabolization_rate = 0.2
	var/shock_timer = 0
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/teslium/on_mob_life(mob/living/M)
	shock_timer++
	if(shock_timer >= rand(5,30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		M.electrocute_act(rand(5,20), "Teslium in their body", 1, 1) //Override because it's caused from INSIDE of you
		playsound(M, "sparks", 50, 1)
	..()