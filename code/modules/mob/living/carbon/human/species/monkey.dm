/datum/species/monkey
	name = "Monkey"
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

	tail = "chimptail"
	bodyflags = FEET_PADDED | HAS_TAIL

	//unarmed_types = list(/datum/unarmed_attack/bite, /datum/unarmed_attack/claws)
	//inherent_verbs = list(/mob/living/proc/ventcrawl)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/monkey

	total_health = 75
	brute_mod = 1.5
	burn_mod = 1.5

	flags = IS_RESTRICTED

/datum/species/monkey/handle_npc(var/mob/living/carbon/human/H)
	if(H.stat != CONSCIOUS)
		return
	if(prob(33) && H.canmove && isturf(H.loc) && !H.pulledby) //won't move if being pulled
		step(H, pick(cardinal))
	if(prob(1))
		H.emote(pick("scratch","jump","roll","tail"))

datum/species/monkey/get_random_name(var/gender)
	return

/datum/species/monkey/handle_post_spawn(var/mob/living/carbon/human/H)
	H.real_name = "[lowertext(name)] ([rand(100,999)])"
	H.name = H.real_name
	..()

/datum/species/monkey/handle_dna(var/mob/living/carbon/human/H)
	H.dna.SetSEState(MONKEYBLOCK,1)

/datum/species/monkey/tajaran
	name = "Farwa"

	icobase = 'icons/mob/human_races/monkeys/r_farwa.dmi'
	deform = 'icons/mob/human_races/monkeys/r_farwa.dmi'

	greater_form = "Tajaran"
	default_language = "Farwa"
	flesh_color = "#AFA59E"
	base_color = "#333333"
	tail = "farwatail"


/datum/species/monkey/vulpkanin
	name = "Wolpin"

	icobase = 'icons/mob/human_races/monkeys/r_wolpin.dmi'
	deform = 'icons/mob/human_races/monkeys/r_wolpin.dmi'

	greater_form = "Vulpkanin"
	default_language = "Wolpin"
	flesh_color = "#966464"
	base_color = "#BE8264"
	tail = "wolpintail"


/datum/species/monkey/skrell
	name = "Neara"

	icobase = 'icons/mob/human_races/monkeys/r_neara.dmi'
	deform = 'icons/mob/human_races/monkeys/r_neara.dmi'

	greater_form = "Skrell"
	default_language = "Neara"
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	reagent_tag = IS_SKRELL
	tail = null

	bodyflags = FEET_PADDED


/datum/species/monkey/unathi
	name = "Stok"

	icobase = 'icons/mob/human_races/monkeys/r_stok.dmi'
	deform = 'icons/mob/human_races/monkeys/r_stok.dmi'

	tail = "stoktail"
	greater_form = "Unathi"
	default_language = "Stok"
	flesh_color = "#34AF10"
	base_color = "#066000"
	reagent_tag = IS_UNATHI

	bodyflags = FEET_CLAWS | HAS_TAIL
