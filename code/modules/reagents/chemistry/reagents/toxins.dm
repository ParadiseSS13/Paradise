/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A Toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_mult = 1.2
	taste_description = "bitterness"

/datum/reagent/toxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/spider_venom
	name = "Spider venom"
	id = "spidertoxin"
	description = "A toxic venom injected by spacefaring arachnids."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "bitterness"

/datum/reagent/spider_venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5, FALSE)
	return ..() | update_flags

/datum/reagent/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "mint"

/datum/reagent/minttoxin/on_mob_life(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_FAT))
		M.gib()
	return ..()

/datum/reagent/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = LIQUID
	color = "#0b8f70" // rgb: 11, 143, 112
	taste_description = "slimes"
	taste_mult = 1.3

/datum/reagent/slimejelly/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		to_chat(M, "<span class='danger'>Your insides are burning!</span>")
		update_flags |= M.adjustToxLoss(rand(2, 6) * REAGENTS_EFFECT_MULTIPLIER, FALSE) // avg 0.4 toxin per cycle, not unreasonable
	else if(prob(40))
		update_flags |= M.adjustBruteLoss(-0.5 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/slimejelly/on_merge(list/mix_data)
	if(data && mix_data)
		if(mix_data["colour"])
			color = mix_data["colour"]

/datum/reagent/slimejelly/reaction_turf(turf/T, volume, color)
	if(volume >= 3 && !isspaceturf(T) && !locate(/obj/effect/decal/cleanable/blood/slime) in T)
		var/obj/effect/decal/cleanable/blood/slime/B = new(T)
		B.basecolor = color
		B.update_icon()


/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	can_synth = FALSE
	taste_description = "shadows"

/datum/reagent/slimetoxin/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/human = M
		if(!isshadowperson(human))
			to_chat(M, "<span class='danger'>Your flesh rapidly mutates!</span>")
			to_chat(M, "<span class='danger'>You are now a Shadow Person, a mutant race of darkness-dwelling humanoids.</span>")
			to_chat(M, "<span class='danger'>Your body reacts violently to light.</span> <span class='notice'>However, it naturally heals in darkness.</span>")
			to_chat(M, "<span class='danger'>Aside from your new traits, you are mentally unchanged and retain your prior obligations.</span>")
			human.set_species(/datum/species/shadow)
	return ..()

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	can_synth = FALSE
	taste_description = "slime"

/datum/reagent/aslimetoxin/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method != REAGENT_TOUCH)
		M.ForceContractDisease(new /datum/disease/transformation/slime(0))


/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	metabolization_rate = 0.2
	penetrates_skin = TRUE
	taste_mult = 0 // elemental mercury is tasteless

/datum/reagent/mercury/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(70))
		M.adjustBrainLoss(1)
	return ..() | update_flags

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	penetrates_skin = TRUE
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "fire"

/datum/reagent/chlorine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#6A6054"
	penetrates_skin = TRUE
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "acid"

/datum/reagent/fluorine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1, FALSE)
	update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	penetrates_skin = TRUE
	taste_description = "the colour blue and regret"

/datum/reagent/radium/on_mob_life(mob/living/M)
	if(M.radiation < 80)
		M.apply_effect(4, IRRADIATE)
	return ..()

/datum/reagent/radium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#04DF27"
	metabolization_rate = 0.3
	taste_mult = 0.9
	taste_description = "slime"

/datum/reagent/mutagen/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(!..())
		return
	if(!M.dna || HAS_TRAIT(M, TRAIT_BADDNA) || HAS_TRAIT(M, TRAIT_GENELESS))
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==REAGENT_TOUCH && prob(33)) || method==REAGENT_INGEST)
		randmutb(M)
		domutcheck(M)
		M.UpdateAppearance()

/datum/reagent/mutagen/on_mob_life(mob/living/M)
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	M.apply_effect(2 * REAGENTS_EFFECT_MULTIPLIER, IRRADIATE)
	if(prob(4))
		randmutb(M)
	return ..()


/datum/reagent/stable_mutagen
	name = "Stable mutagen"
	id = "stable_mutagen"
	description = "Just the regular, boring sort of mutagenic compound.  Works in a completely predictable manner."
	reagent_state = LIQUID
	color = "#7DFF00"
	taste_description = "slime"

/datum/reagent/stable_mutagen/on_new(data)
	..()
	START_PROCESSING(SSprocessing, src)

/datum/reagent/stable_mutagen/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/reagent/stable_mutagen/on_mob_life(mob/living/M)
	if(!ishuman(M) || !M.dna || HAS_TRAIT(M, TRAIT_BADDNA) || HAS_TRAIT(M, TRAIT_GENELESS))
		return
	M.apply_effect(2 * REAGENTS_EFFECT_MULTIPLIER, IRRADIATE)
	if(current_cycle == 10 && islist(data))
		if(istype(data["dna"], /datum/dna))
			var/mob/living/carbon/human/H = M
			var/datum/dna/D = data["dna"]
			if(!D.species.is_small)
				H.change_dna(D, TRUE, TRUE)

	return ..()

/datum/reagent/stable_mutagen/process()
	if(..())
		var/datum/reagent/blood/B = locate() in holder.reagent_list
		if(B && islist(B.data) && !data)
			data = B.data.Copy()

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_mult = 0
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE)
	return ..()

/datum/reagent/uranium/reaction_turf(turf/T, volume)
	if(volume >= 3 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/greenglow(T)


/datum/reagent/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#52685D"
	metabolization_rate = 0.2
	taste_description = "sweetness"

/datum/reagent/lexorin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags


/datum/reagent/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	color = "#00FF32"
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "<span class='userdanger'>ACID</span>"
	var/acidpwr = 10 //the amount of protection removed from the armour

/datum/reagent/acid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/acid/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(ishuman(M) && !isgrey(M))
		var/mob/living/carbon/human/H = M
		if(method == REAGENT_TOUCH)
			if(volume > 25)
				if(H.wear_mask)
					to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid!</span>")
					return

				if(H.head)
					to_chat(H, "<span class='danger'>Your [H.wear_mask] protects you from the acid!</span>")
					return

				if(prob(75))
					H.take_organ_damage(5, 10)
					H.emote("scream")
					var/obj/item/organ/external/affecting = H.get_organ("head")
					if(affecting)
						affecting.disfigure()
				else
					H.take_organ_damage(5, 10)
			else
				H.take_organ_damage(5, 10)
		else
			to_chat(H, "<span class='warning'>The greenish acidic substance stings[volume < 10 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
			if(volume >= 10)
				H.adjustFireLoss(min(max(4, (volume - 10) * 2), 20))
				H.emote("scream")

/datum/reagent/acid/reaction_obj(obj/O, volume)
	if(ismob(O.loc)) //handled in human acid_act()
		return
	volume = round(volume, 0.1)
	O.acid_act(acidpwr, volume)

/datum/reagent/acid/reaction_turf(turf/T, volume)
	if(!istype(T))
		return
	volume = round(volume, 0.1)
	T.acid_act(acidpwr, volume)

/datum/reagent/acid/facid
	name = "Fluorosulfuric Acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive super-acid."
	color = "#5050FF"
	acidpwr = 42

/datum/reagent/acid/facid/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/acid/facid/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(method == REAGENT_TOUCH)
			if(volume > 9)
				if(!H.wear_mask && !H.head)
					var/obj/item/organ/external/affecting = H.get_organ("head")
					if(affecting)
						affecting.disfigure()
					H.adjustFireLoss(min(max(8, (volume - 5) * 3), 75))
					H.emote("scream")
					return
				else
					var/melted_something = FALSE
					if(H.wear_mask && !(H.wear_mask.resistance_flags & ACID_PROOF))
						qdel(H.wear_mask)
						H.update_inv_wear_mask()
						to_chat(H, "<span class='danger'>Your [H.wear_mask] melts away!</span>")
						melted_something = TRUE

					if(H.head && !(H.head.resistance_flags & ACID_PROOF))
						qdel(H.head)
						H.update_inv_head()
						to_chat(H, "<span class='danger'>Your [H.head] melts away!</span>")
						melted_something = TRUE
					if(melted_something)
						return

		if(volume >= 5)
			H.emote("scream")
			H.adjustFireLoss(min(max(8, (volume - 5) * 3), 75))
		to_chat(H, "<span class='warning'>The blueish acidic substance stings[volume < 5 ? " you, but isn't concentrated enough to harm you" : null]!</span>")

/datum/reagent/acetic_acid
	name = "acetic acid"
	id = "acetic_acid"
	description = "A weak acid that is the main component of vinegar and bad hangovers."
	color = "#0080ff"
	reagent_state = LIQUID
	taste_description = "vinegar"

/datum/reagent/acetic_acid/reaction_mob(mob/M, method = REAGENT_TOUCH, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(method == REAGENT_TOUCH)
			if(H.wear_mask || H.head)
				return
			if(volume >= 50 && prob(75))
				var/obj/item/organ/external/affecting = H.get_organ("head")
				if(affecting)
					affecting.disfigure()
				H.adjustBruteLoss(5)
				H.adjustFireLoss(15)
				H.emote("scream")
			else
				H.adjustBruteLoss(min(5, volume * 0.25))
		else
			to_chat(H, "<span class='warning'>The transparent acidic substance stings[volume < 25 ? " you, but isn't concentrated enough to harm you" : null]!</span>")
			if(volume >= 25)
				H.adjustBruteLoss(2)
				H.emote("scream")


/datum/reagent/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51
	taste_description = "fish"

/datum/reagent/carpotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(2*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13
	taste_description = "bitterness"

/datum/reagent/staminatoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(REAGENTS_EFFECT_MULTIPLIER * data, FALSE)
	data = max(data - 1, 3)
	return ..() | update_flags


/datum/reagent/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A natural toxin produced by blob spores that inhibits vision when ingested."
	color = "#9ACD32"
	taste_description = "bitterness"

/datum/reagent/spore/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	M.damageoverlaytemp = 60
	update_flags |= M.EyeBlurry(3)
	return ..() | update_flags

/datum/reagent/beer2	//disguised as normal beer for use by emagged service borgs
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	drink_icon ="beerglass"
	drink_name = "Beer glass"
	drink_desc = "A freezing pint of beer"
	taste_description = "beer"
	taste_description = "piss water"

/datum/reagent/beer2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 50)
			update_flags |= M.Sleeping(2, FALSE)
		if(51 to INFINITY)
			update_flags |= M.Sleeping(2, FALSE)
			update_flags |= M.adjustToxLoss((current_cycle - 50)*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = TRUE
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/polonium/on_mob_life(mob/living/M)
	M.apply_effect(8, IRRADIATE)
	return ..()

/datum/reagent/histamine
	name = "Histamine"
	id = "histamine"
	description = "Immune-system neurotransmitter. If detected in blood, the subject is likely undergoing an allergic reaction."
	reagent_state = LIQUID
	color = "#E7C4C4"
	metabolization_rate = 0.2
	overdose_threshold = 40
	taste_mult = 0

/datum/reagent/histamine/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //dumping histamine on someone is VERY mean.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.reagents.add_reagent("histamine",10)
		else
			to_chat(M, "<span class='danger'>You feel a burning sensation in your throat...</span>")
			M.emote("drool")

/datum/reagent/histamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		M.emote(pick("twitch", "grumble", "sneeze", "cough"))
	if(prob(10))
		to_chat(M, "<span class='notice'>Your eyes itch.</span>")
		M.emote(pick("blink", "sneeze"))
		update_flags |= M.AdjustEyeBlurry(3, FALSE)
	if(prob(10))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		update_flags |= M.adjustBruteLoss(1, FALSE)
		M.emote("grumble")
	if(prob(5))
		to_chat(M, "<span class='danger'>You're getting a rash!</span>")
		update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/histamine/overdose_process(mob/living/M, severity)
	var/list/overdose_info = ..()
	var/effect = overdose_info[REAGENT_OVERDOSE_EFFECT]
	var/update_flags = overdose_info[REAGENT_OVERDOSE_FLAGS]
	if(severity == 1)
		if(effect <= 2)
			to_chat(M, "<span class='warning'>You feel mucus running down the back of your throat.</span>")
			update_flags |= M.adjustToxLoss(1, FALSE)
			M.Jitter(4)
			M.emote(pick("sneeze", "cough"))
		else if(effect <= 4)
			M.AdjustStuttering(rand(0,5))
			if(prob(25))
				M.emote(pick("choke","gasp"))
				update_flags |= M.adjustOxyLoss(5, FALSE)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your chest hurts!</span>")
			M.emote(pick("cough","gasp"))
			update_flags |= M.adjustOxyLoss(3, FALSE)
	else if(severity == 2)
		if(effect <= 2)
			M.visible_message("<span class='warning'>[M] breaks out in hives!</span>")
			update_flags |= M.adjustBruteLoss(6, FALSE)
		else if(effect <= 4)
			M.visible_message("<span class='warning'>[M] has a horrible coughing fit!</span>")
			M.Jitter(10)
			M.AdjustStuttering(rand(0,5))
			M.emote("cough")
			if(prob(40))
				M.emote(pick("choke","gasp"))
				update_flags |= M.adjustOxyLoss(6, FALSE)
			update_flags |= M.Weaken(8, FALSE)
		else if(effect <= 7)
			to_chat(M, "<span class='warning'>Your heartbeat is pounding inside your head!</span>")
			SEND_SOUND(M, sound('sound/effects/singlebeat.ogg'))
			M.emote("collapse")
			update_flags |= M.adjustOxyLoss(8, FALSE)
			update_flags |= M.adjustToxLoss(3, FALSE)
			update_flags |= M.Weaken(3, FALSE)
			M.emote(pick("choke", "gasp"))
			to_chat(M, "<span class='warning'>You feel like you're dying!</span>")
	return list(effect, update_flags)

/datum/reagent/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Formaldehyde is a common industrial chemical and is used to preserve corpses and medical samples. It is highly toxic and irritating."
	reagent_state = LIQUID
	color = "#B44B00"
	penetrates_skin = TRUE
	taste_description = "bitterness"

/datum/reagent/formaldehyde/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(10))
		M.reagents.add_reagent("histamine",rand(5,15))
	return ..() | update_flags

/datum/reagent/acetaldehyde
	name = "Acetaldehyde"
	id = "acetaldehyde"
	description = "Acetaldehyde is a common industrial chemical. It is a severe irritant."
	reagent_state = LIQUID
	color = "#B44B00"
	penetrates_skin = TRUE
	taste_description = "apples"

/datum/reagent/acetaldehyde/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/venom
	name = "Venom"
	id = "venom"
	description = "An incredibly potent poison. Origin unknown."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.2
	overdose_threshold = 40
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/venom/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(25))
		M.reagents.add_reagent("histamine",rand(5,10))
	if(volume < 20)
		update_flags |= M.adjustToxLoss(1, FALSE)
		update_flags |= M.adjustBruteLoss(1, FALSE)
	else if(volume < 40)
		if(prob(8))
			M.fakevomit()
		update_flags |= M.adjustToxLoss(2, FALSE)
		update_flags |= M.adjustBruteLoss(2, FALSE)
	if(volume > 40 && prob(4))
		M.delayed_gib()
		return
	return ..() | update_flags

/datum/reagent/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "A dangerous toxin that attacks the nervous system."
	reagent_state = LIQUID
	color = "#60A584"
	metabolization_rate = 1
	taste_mult = 0

/datum/reagent/neurotoxin2/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
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
			update_flags |= M.Paralyse(10, FALSE)
			M.Drowsy(20)

	M.AdjustJitter(-30)
	if(M.getBrainLoss() <= 80)
		update_flags |= M.adjustBrainLoss(1, FALSE)
	else
		if(prob(10))
			update_flags |= M.adjustBrainLoss(1, FALSE)
	if(prob(10))
		M.emote("drool")
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical with some uses as a building block for other things."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.1
	penetrates_skin = TRUE
	taste_description = "almonds"

/datum/reagent/cyanide/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1.5*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(prob(5))
		M.emote("drool")
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		M.AdjustLoseBreath(1)
		M.emote("gasp")
	if(prob(8))
		to_chat(M, "<span class='danger'>You feel horrendously weak!</span>")
		update_flags |= M.Stun(2, FALSE)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "An abrasive powder beloved by cruel pranksters."
	reagent_state = LIQUID
	color = "#B0B0B0"
	metabolization_rate = 0.3
	penetrates_skin = TRUE
	taste_description = "prickliness"

/datum/reagent/itching_powder/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_STAT
	if(prob(25))
		M.emote(pick("twitch", "laugh", "sneeze", "cry"))
	if(prob(20))
		to_chat(M, "<span class='notice'>Something tickles!</span>")
		M.emote(pick("laugh", "giggle"))
	if(prob(15))
		M.visible_message("<span class='danger'>[M] scratches at an itch.</span>")
		update_flags |= M.adjustBruteLoss(1, FALSE)
		update_flags |= M.Stun(rand(0,1), FALSE)
		M.emote("grumble")
	if(prob(10))
		to_chat(M, "<span class='danger'>So itchy!</span>")
		update_flags |= M.adjustBruteLoss(2, FALSE)
	if(prob(6))
		M.reagents.add_reagent("histamine", rand(1,3))
	if(prob(2))
		to_chat(M, "<span class='danger'>AHHHHHH!</span>")
		update_flags |= M.adjustBruteLoss(5, FALSE)
		update_flags |= M.Weaken(5, FALSE)
		M.AdjustJitter(6)
		M.visible_message("<span class='danger'>[M] falls to the floor, scratching [M.p_them()]self violently!</span>")
		M.emote("scream")
	return ..() | update_flags

/datum/reagent/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "A highly potent cardiac poison - can kill within minutes."
	reagent_state = LIQUID
	color = "#7F10C0"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/initropidril/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		update_flags |= M.adjustToxLoss(rand(5,25), FALSE)
	if(prob(33))
		to_chat(M, "<span class='danger'>You feel horribly weak.</span>")
		update_flags |= M.Stun(2, FALSE)
	if(prob(10))
		to_chat(M, "<span class='danger'>You cannot breathe!</span>")
		update_flags |= M.adjustOxyLoss(10, FALSE)
		M.AdjustLoseBreath(1)
	if(prob(10))
		to_chat(M, "<span class='danger'>Your chest is burning with pain!</span>")
		update_flags |= M.adjustOxyLoss(10, FALSE)
		M.AdjustLoseBreath(1)
		update_flags |= M.Stun(3, FALSE)
		update_flags |= M.Weaken(2, FALSE)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest())
				H.set_heartattack(TRUE) // rip in pepperoni
	return ..() | update_flags

/datum/reagent/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Pancuronium bromide is a powerful skeletal muscle relaxant."
	reagent_state = LIQUID
	color = "#1E4664"
	metabolization_rate = 0.2
	taste_mult = 0

/datum/reagent/pancuronium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			if(prob(10))
				M.emote(pick("drool", "tremble"))
		if(6 to 10)
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				update_flags |= M.Stun(1, FALSE)
			else if(prob(8))
				M.emote(pick("drool", "tremble"))
		if(11 to INFINITY)
			update_flags |= M.Stun(20, FALSE)
			update_flags |= M.Weaken(20, FALSE)
			if(prob(10))
				M.emote(pick("drool", "tremble", "gasp"))
				M.AdjustLoseBreath(1)
			if(prob(9))
				to_chat(M, "<span class='danger'>You can't [pick("move", "feel your legs", "feel your face", "feel anything")]!</span>")
			if(prob(7))
				to_chat(M, "<span class='danger'>You can't breathe!</span>")
				M.AdjustLoseBreath(3)
	return ..() | update_flags

/datum/reagent/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "An rapidly-acting barbituate tranquilizer."
	reagent_state = LIQUID
	color = "#5F8BE1"
	metabolization_rate = 0.7
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/sodium_thiopental/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1)
			M.emote("drool")
			M.Confused(5)
		if(2 to 4)
			M.Drowsy(20)
		if(5)
			M.emote("faint")
			update_flags |= M.Weaken(5, FALSE)
		if(6 to INFINITY)
			update_flags |= M.Paralyse(20, FALSE)
	M.AdjustJitter(-50)
	if(prob(10))
		M.emote("drool")
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/ketamine
	name = "Ketamine"
	id = "ketamine"
	description = "A potent veterinary tranquilizer."
	reagent_state = LIQUID
	color = "#646EA0"
	metabolization_rate = 0.8
	penetrates_skin = TRUE
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/ketamine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			if(prob(25))
				M.emote("yawn")
		if(6 to 9)
			update_flags |= M.AdjustEyeBlurry(5, FALSE)
			if(prob(35))
				M.emote("yawn")
		if(10)
			M.emote("faint")
			update_flags |= M.Weaken(5, FALSE)
		if(11 to INFINITY)
			update_flags |= M.Paralyse(25, FALSE)
	return ..() | update_flags

/datum/reagent/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#6BA688"
	metabolization_rate = 0.1
	taste_mult = 0

/datum/reagent/sulfonal/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
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
				update_flags |= M.Paralyse(5, FALSE)
			M.Drowsy(20)
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "A toxin produced by certain mushrooms. Very deadly."
	reagent_state = LIQUID
	color = "#D9D9D9"
	taste_mult = 0

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
	taste_description = "battery acid"

/datum/reagent/lipolicide/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		switch(rand(1,3))
			if(1)
				to_chat(M, "<span class='warning'>You feel hungry...</span>")
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, "<span class='warning'>Your stomach grumbles painfully!</span>")
	else
		if(prob(60))
			var/fat_to_burn = max(round(M.nutrition / 100, 1), 5)
			M.adjust_nutrition(-fat_to_burn)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/coniine
	name = "Coniine"
	id = "coniine"
	description = "A neurotoxin that rapidly causes respiratory failure."
	reagent_state = LIQUID
	color = "#C2D8CD"
	metabolization_rate = 0.05
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/coniine/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(2, FALSE)
	M.AdjustLoseBreath(5)
	return ..() | update_flags

/datum/reagent/curare
	name = "Curare"
	id = "curare"
	description = "A highly dangerous paralytic poison."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.1
	can_synth = FALSE
	penetrates_skin = TRUE
	taste_mult = 0

/datum/reagent/curare/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustOxyLoss(1, FALSE)
	switch(current_cycle)
		if(1 to 5)
			if(prob(20))
				M.emote(pick("drool", "pale", "gasp"))
		if(6 to 10)
			update_flags |= M.AdjustEyeBlurry(5, FALSE)
			if(prob(8))
				to_chat(M, "<span class='danger'>You feel [pick("weak", "horribly weak", "numb", "like you can barely move", "tingly")].</span>")
				update_flags |= M.Stun(1, FALSE)
			else if(prob(8))
				M.emote(pick("drool", "pale", "gasp"))
		if(11 to INFINITY)
			update_flags |= M.Stun(30, FALSE)
			M.Drowsy(20)
			if(prob(20))
				M.emote(pick("drool", "faint", "pale", "gasp", "collapse"))
			else if(prob(8))
				to_chat(M, "<span class='danger'>You can't [pick("breathe", "move", "feel your legs", "feel your face", "feel anything")]!</span>")
				M.AdjustLoseBreath(1)
	return ..() | update_flags

/datum/reagent/sarin
	name = "Sarin"
	id = "sarin"
	description = "An extremely deadly neurotoxin."
	reagent_state = LIQUID
	color = "#C7C7C7"
	metabolization_rate = 0.1
	penetrates_skin = TRUE
	overdose_threshold = 25
	taste_mult = 0

/datum/reagent/sarin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 15)
			M.AdjustJitter(20)
			if(prob(20))
				M.emote(pick("twitch","twitch_s","quiver"))
		if(16 to 30)
			if(prob(25))
				M.emote(pick("twitch","twitch","drool","quiver","tremble"))
			update_flags |= M.AdjustEyeBlurry(5, FALSE)
			M.Stuttering(5)
			if(prob(10))
				M.Confused(15)
			if(prob(15))
				update_flags |= M.Stun(1, FALSE)
				M.emote("scream")
		if(30 to 60)
			update_flags |= M.AdjustEyeBlurry(5, FALSE)
			M.Stuttering(5)
			if(prob(10))
				update_flags |= M.Stun(1, FALSE)
				M.emote(pick("twitch","twitch","drool","shake","tremble"))
			if(prob(5))
				M.emote("collapse")
			if(prob(5))
				update_flags |= M.Weaken(3, FALSE)
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
			update_flags |= M.adjustToxLoss(1, FALSE)
			update_flags |= M.adjustBrainLoss(1, FALSE)
			update_flags |= M.Weaken(4, FALSE)
	if(prob(8))
		M.fakevomit()
	update_flags |= M.adjustToxLoss(1, FALSE)
	update_flags |= M.adjustBrainLoss(1, FALSE)
	update_flags |= M.adjustFireLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/glyphosate
	name = "Glyphosate"
	id = "glyphosate"
	description = "A broad-spectrum herbicide that is highly effective at killing all plants."
	reagent_state = LIQUID
	color = "#d3cf50"
	var/lethality = 0 //Glyphosate is non-toxic to people
	taste_description = "bitterness"

/datum/reagent/glyphosate/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(lethality, FALSE)
	return ..() | update_flags

/datum/reagent/glyphosate/reaction_turf(turf/simulated/wall/W, volume) // Clear off wallrot fungi
	if(istype(W) && W.rotting)
		for(var/obj/effect/overlay/wall_rot/WR in W)
			qdel(WR)
		W.rotting = 0
		W.visible_message("<span class='warning'>The fungi are completely dissolved by the solution!</span>")

/datum/reagent/glyphosate/reaction_obj(obj/O, volume)
	if(istype(O,/obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.take_damage(rand(15, 35), BRUTE, 0) // Kills alien weeds pretty fast
	else if(istype(O, /obj/structure/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O, /obj/structure/spacevine))
		var/obj/structure/spacevine/SV = O
		SV.on_chem_effect(src)

/datum/reagent/glyphosate/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(isliving(M))
		if(M.mob_biotypes & MOB_PLANT)
			var/damage = min(round(0.4 * volume, 0.1), 10)
			M.adjustToxLoss(damage)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.wear_mask) // If not wearing a mask
				C.adjustToxLoss(lethality)
		if(istype(M, /mob/living/simple_animal/diona)) //nymphs take EVEN MORE damage
			var/mob/living/simple_animal/diona/D = M
			D.adjustHealth(100)
	..()

/datum/reagent/glyphosate/atrazine
	name = "Atrazine"
	id = "atrazine"
	description = "A herbicidal compound used for destroying unwanted plants."
	reagent_state = LIQUID
	color = "#773E73" //RGB: 47 24 45
	lethality = 2 //Atrazine, however, is definitely toxic


/datum/reagent/pestkiller // To-Do; make this more realistic.
	name = "Pest Killer"
	id = "pestkiller"
	description = "A harmful toxic mixture to kill pests. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75
	taste_description = "bitterness"

/datum/reagent/pestkiller/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/pestkiller/reaction_obj(obj/O, volume)
	if(istype(O, /obj/effect/decal/ants))
		O.visible_message("<span class='warning'>The ants die.</span>")
		qdel(O)

/datum/reagent/pestkiller/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(isliving(M))
		if(M.mob_biotypes & MOB_BUG)
			var/damage = min(round(0.4 * volume, 0.1), 10)
			M.adjustToxLoss(damage)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.wear_mask) // If not wearing a mask
				C.adjustToxLoss(2)
			if(iskidan(C)) //RIP
				C.adjustToxLoss(18)

/datum/reagent/capulettium
	name = "Capulettium"
	id = "capulettium"
	description = "A rare drug that causes the user to appear dead for some time."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1
	taste_description = "sweetness"

/datum/reagent/capulettium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(1 to 5)
			update_flags |= M.AdjustEyeBlurry(10, FALSE)
		if(6 to 10)
			M.Drowsy(10)
		if(11)
			fakedeath(M)
		if(61 to 69)
			update_flags |= M.AdjustEyeBlurry(10, FALSE)
		if(70 to INFINITY)
			update_flags |= M.AdjustEyeBlurry(10, FALSE)
			if(HAS_TRAIT(M, TRAIT_FAKEDEATH))
				fakerevive(M)
	return ..() | update_flags

/datum/reagent/capulettium/on_mob_delete(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_FAKEDEATH))
		fakerevive(M)
	..()

/datum/reagent/capulettium_plus
	name = "Capulettium Plus"
	id = "capulettium_plus"
	description = "A rare and expensive drug that will silence the user and let him appear dead as long as it's in the body. Rest to play dead, stand up to wake up."
	reagent_state = LIQUID
	color = "#60A584"
	heart_rate_stop = 1
	taste_description = "sweetness"

/datum/reagent/capulettium_plus/on_mob_life(mob/living/M)
	M.Silence(2)
	if((HAS_TRAIT(M, TRAIT_FAKEDEATH)) && !M.resting)
		fakerevive(M)
	else if(!HAS_TRAIT(M, TRAIT_FAKEDEATH) && M.resting)
		fakedeath(M)
	return ..()

/datum/reagent/capulettium_plus/on_mob_delete(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_FAKEDEATH))
		fakerevive(M)
	..()

/datum/reagent/toxic_slurry
	name = "Toxic Slurry"
	id = "toxic_slurry"
	description = "A filthy, carcinogenic sludge produced by the Slurrypod plant."
	reagent_state = LIQUID
	color = "#00C81E"
	taste_description = "slime"

/datum/reagent/toxic_slurry/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(10))
		update_flags |= M.adjustToxLoss(rand(2.4), FALSE)
	if(prob(7))
		to_chat(M, "<span class='danger'>A horrible migraine overpowers you.</span>")
		update_flags |= M.Stun(rand(2,5), FALSE)
	if(prob(7))
		M.fakevomit(1)
	return ..() | update_flags

/datum/reagent/glowing_slurry
	name = "Glowing Slurry"
	id = "glowing_slurry"
	description = "This is probably not good for you."
	reagent_state = LIQUID
	color = "#00FD00"
	taste_description = "slime"

/datum/reagent/glowing_slurry/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //same as mutagen
	if(!..())
		return
	if(!M.dna)
		return //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==REAGENT_TOUCH && prob(50)) || method==REAGENT_INGEST)
		randmutb(M)
		domutcheck(M)
		M.UpdateAppearance()

/datum/reagent/glowing_slurry/on_mob_life(mob/living/M)
	M.apply_effect(2, IRRADIATE)
	if(!M.dna)
		return
	var/did_mutation = FALSE
	if(prob(15))
		randmutb(M)
		did_mutation = TRUE
	if(prob(3))
		randmutg(M)
		did_mutation = TRUE
	if(did_mutation)
		domutcheck(M)
		M.UpdateAppearance()
	return ..()

/datum/reagent/ants
	name = "Ants"
	id = "ants"
	description = "A sample of a lost breed of Space Ants (formicidae bastardium tyrannus), they are well-known for ravaging the living shit out of pretty much anything."
	reagent_state = SOLID
	color = "#993333"
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "<span class='warning'>ANTS OH GOD</span>"

/datum/reagent/ants/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/ants/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) //NOT THE ANTS
	if(iscarbon(M))
		if(method == REAGENT_TOUCH || method==REAGENT_INGEST)
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
	taste_description = "electricity"

/datum/reagent/teslium/on_mob_life(mob/living/M)
	shock_timer++
	if(shock_timer >= rand(5,30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		M.electrocute_act(rand(5, 20), "Teslium in their body", 1, SHOCK_NOGLOVES) //Override because it's caused from INSIDE of you
		playsound(M, "sparks", 50, 1)
	return ..()

/datum/reagent/teslium/on_mob_add(mob/living/M)
	..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.dna.species.siemens_coeff *= 2

/datum/reagent/teslium/on_mob_delete(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.dna.species.siemens_coeff *= 0.5
	..()

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	id = "gluttonytoxin"
	description = "An advanced corruptive toxin produced by something terrible."
	reagent_state = LIQUID
	color = "#5EFF3B" //RGB: 94, 255, 59
	can_synth = FALSE
	taste_description = "decay"

/datum/reagent/gluttonytoxin/reaction_mob(mob/living/L, method=REAGENT_TOUCH, reac_volume)
	L.ForceContractDisease(new /datum/disease/transformation/morph())
