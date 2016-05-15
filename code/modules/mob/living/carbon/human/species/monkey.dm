/datum/species/monkey
	name = "Monkey"
	name_plural = "Monkeys"
	blurb = "Ook."

	icobase = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	deform = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	damage_overlays = 'icons/mob/human_races/masks/dam_monkey.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_monkey.dmi'
	blood_mask = 'icons/mob/human_races/masks/blood_monkey.dmi'
	path = /mob/living/carbon/human/monkey
	language = null
	default_language = "Chimpanzee"
	greater_form = "Human"
	is_small = 1
	has_fine_manipulation = 0
	ventcrawler = 1
	show_ssd = 0
	eyes = "blank_eyes"
	death_message = "lets out a faint chimper as it collapses and stops moving..."

	scream_verb = "screeches"
	male_scream_sound = 'sound/goonstation/voice/monkey_scream.ogg'
	female_scream_sound = 'sound/goonstation/voice/monkey_scream.ogg'

	tail = "chimptail"
	bodyflags = FEET_PADDED | HAS_TAIL
	reagent_tag = PROCESS_ORG

	//unarmed_types = list(/datum/unarmed_attack/bite, /datum/unarmed_attack/claws)
	//inherent_verbs = list(/mob/living/proc/ventcrawl)

	total_health = 75
	brute_mod = 1.5
	burn_mod = 1.5

/datum/species/monkey/handle_npc(var/mob/living/carbon/human/H)
	if(H.stat != CONSCIOUS)
		return
	if(prob(33) && H.canmove && isturf(H.loc) && !H.pulledby) //won't move if being pulled
		step(H, pick(cardinal))
	if(prob(1))
		H.emote(pick("scratch","jump","roll","tail"))

/datum/species/monkey/get_random_name()
	return "[lowertext(name)] ([rand(100,999)])"

/datum/species/monkey/handle_post_spawn(var/mob/living/carbon/human/H)
	H.real_name = "[lowertext(name)] ([rand(100,999)])"
	H.name = H.real_name
	H.butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/monkey = 5)

	..()

/datum/species/monkey/handle_dna(var/mob/living/carbon/human/H)
	H.dna.SetSEState(MONKEYBLOCK,1)
	genemutcheck(H, MONKEYBLOCK)

/datum/species/monkey/handle_can_equip(obj/item/I, slot, disable_warning = 0, mob/living/carbon/human/user)
	switch(slot)
		if(slot_l_hand)
			if(user.l_hand)
				return 2
			return 1
		if(slot_r_hand)
			if(user.r_hand)
				return 2
			return 1
		if(slot_wear_mask)
			if(user.wear_mask)
				return 2
			if(!(I.slot_flags & SLOT_MASK))
				return 2
			return 1
		if(slot_back)
			if(user.back)
				return 2
			if(!(I.slot_flags & SLOT_BACK))
				return 2
			return 1
		if(slot_handcuffed)
			if(user.handcuffed)
				return 2
			if(!istype(I, /obj/item/weapon/restraints/handcuffs))
				return 2
			return 1
		if(slot_in_backpack)
			if(user.back && istype(user.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = user.back
				if(B.contents.len < B.storage_slots && I.w_class <= B.max_w_class)
					return 1
			return 2
	return 2

/datum/species/monkey/tajaran
	name = "Farwa"
	name_plural = "Farwa"

	icobase = 'icons/mob/human_races/monkeys/r_farwa.dmi'
	deform = 'icons/mob/human_races/monkeys/r_farwa.dmi'

	greater_form = "Tajaran"
	default_language = "Farwa"
	flesh_color = "#AFA59E"
	base_color = "#000000"
	tail = "farwatail"
	reagent_tag = PROCESS_ORG


/datum/species/monkey/vulpkanin
	name = "Wolpin"
	name_plural = "Wolpin"

	icobase = 'icons/mob/human_races/monkeys/r_wolpin.dmi'
	deform = 'icons/mob/human_races/monkeys/r_wolpin.dmi'

	greater_form = "Vulpkanin"
	default_language = "Wolpin"
	flesh_color = "#966464"
	base_color = "#000000"
	tail = "wolpintail"
	reagent_tag = PROCESS_ORG


/datum/species/monkey/skrell
	name = "Neara"
	name_plural = "Neara"

	icobase = 'icons/mob/human_races/monkeys/r_neara.dmi'
	deform = 'icons/mob/human_races/monkeys/r_neara.dmi'

	greater_form = "Skrell"
	default_language = "Neara"
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	reagent_tag = PROCESS_ORG
	tail = null

	bodyflags = FEET_PADDED


/datum/species/monkey/unathi
	name = "Stok"
	name_plural = "Stok"

	icobase = 'icons/mob/human_races/monkeys/r_stok.dmi'
	deform = 'icons/mob/human_races/monkeys/r_stok.dmi'

	tail = "stoktail"
	greater_form = "Unathi"
	default_language = "Stok"
	flesh_color = "#34AF10"
	base_color = "#000000"
	reagent_tag = PROCESS_ORG

	bodyflags = FEET_CLAWS | HAS_TAIL
