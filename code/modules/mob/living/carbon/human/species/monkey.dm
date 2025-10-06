/datum/species/monkey
	name = "Monkey"
	name_plural = "Monkeys"
	blurb = "Ook."

	icobase = 'icons/mob/human_races/monkeys/r_monkey.dmi'
	damage_overlays = 'icons/mob/human_races/masks/dam_monkey.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_monkey.dmi'
	blood_mask = 'icons/mob/human_races/masks/blood_monkey.dmi'
	language = null
	default_language = "Chimpanzee"
	inherent_traits = list(TRAIT_NOEXAMINE)
	species_traits = list(NOT_SELECTABLE)
	skinned_type = /obj/item/stack/sheet/animalhide/monkey
	greater_form = /datum/species/human
	no_equip = ITEM_SLOT_BELT | ITEM_SLOT_ID | ITEM_SLOT_LEFT_EAR | ITEM_SLOT_RIGHT_EAR | ITEM_SLOT_EYES | ITEM_SLOT_GLOVES | ITEM_SLOT_SHOES | ITEM_SLOT_OUTER_SUIT | ITEM_SLOT_JUMPSUIT | ITEM_SLOT_LEFT_POCKET | ITEM_SLOT_RIGHT_POCKET | ITEM_SLOT_SUIT_STORE |  ITEM_SLOT_PDA | ITEM_SLOT_NECK
	inherent_factions = list("jungle", "monkey")
	can_craft = FALSE
	is_small = 1
	has_fine_manipulation = 0
	ventcrawler = VENTCRAWLER_NUDE
	dietflags = DIET_OMNI
	show_ssd = 0
	eyes = "blank_eyes"
	death_message = "lets out a faint chimper as it collapses and stops moving..."

	scream_verb = "screeches"
	male_scream_sound = 'sound/goonstation/voice/monkey_scream.ogg'
	female_scream_sound = 'sound/goonstation/voice/monkey_scream.ogg'

	tail = "chimptail"
	bodyflags = HAS_TAIL | HAS_BODYACC_COLOR
	reagent_tag = PROCESS_ORG
	//Has standard darksight of 2.

	unarmed_type = /datum/unarmed_attack/bite

	total_health = 75
	brute_mod = 1.5
	burn_mod = 1.5
	hunger_drain = HUNGER_FACTOR / 2 // twice as slow as normal

/datum/species/monkey/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = ..()
	if(H.radiation > RAD_MOB_GORILLIZE && prob(RAD_MOB_GORILLIZE_PROB))
		H.gorillize()

/datum/species/monkey/handle_npc(mob/living/carbon/human/H)
	if(H.stat != CONSCIOUS)
		return
	if(prob(1))
		H.emote(pick("scratch","jump","roll","tail"))
	if(prob(33) && (H.mobility_flags & MOBILITY_MOVE) && isturf(H.loc) && !H.pulledby) //won't move if being pulled
		var/dir_to_go = pick(GLOB.cardinal)
		var/turf/to_go = get_step(H, dir_to_go)
		if(islava(to_go) || ischasm(to_go))
			return
		step(H, dir_to_go)

/datum/species/monkey/get_random_name()
	return "[lowertext(name)] ([rand(100,999)])"

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H)
	..()
	H.real_name = get_random_name()
	H.name = H.real_name
	H.butcher_results = list(/obj/item/food/meat/monkey = 5)
	H.dna.blood_type = pick(4;"O-", 36;"O+", 3;"A-", 28;"A+", 1;"B-", 20;"B+", 1;"AB-", 5;"AB+")

/datum/species/monkey/handle_dna(mob/living/carbon/human/H, remove)
	..()
	if(!remove)
		H.dna.SetSEState(GLOB.monkeyblock, TRUE)
		singlemutcheck(H, GLOB.monkeyblock, MUTCHK_FORCED)

/datum/species/monkey/tajaran
	name = "Farwa"
	name_plural = "Farwa"

	icobase = 'icons/mob/human_races/monkeys/r_farwa.dmi'

	greater_form = /datum/species/tajaran
	default_language = "Farwa"
	flesh_color = "#AFA59E"
	base_color = "#000000"
	tail = "farwatail"
	has_organ = list(
		"heart" 	= /obj/item/organ/internal/heart/tajaran,
		"lungs" 	= /obj/item/organ/internal/lungs/tajaran,
		"liver" 	= /obj/item/organ/internal/liver/tajaran,
		"kidneys" 	= /obj/item/organ/internal/kidneys/tajaran,
		"brain" 	= /obj/item/organ/internal/brain/tajaran,
		"appendix" 	= /obj/item/organ/internal/appendix,
		"eyes" 		= /obj/item/organ/internal/eyes/tajaran/farwa //Tajara monkey-forms are uniquely colourblind and have excellent darksight, which is why they need a subtype of their greater-form's organ..
		)


/datum/species/monkey/vulpkanin
	name = "Wolpin"
	name_plural = "Wolpin"

	icobase = 'icons/mob/human_races/monkeys/r_wolpin.dmi'

	greater_form = /datum/species/vulpkanin
	default_language = "Wolpin"
	flesh_color = "#966464"
	base_color = "#000000"
	tail = "wolpintail"
	has_organ = list(
		"heart" 	= /obj/item/organ/internal/heart/vulpkanin,
		"lungs" 	= /obj/item/organ/internal/lungs/vulpkanin,
		"liver" 	= /obj/item/organ/internal/liver/vulpkanin,
		"kidneys" 	= /obj/item/organ/internal/kidneys/vulpkanin,
		"brain" 	= /obj/item/organ/internal/brain/vulpkanin,
		"appendix" 	= /obj/item/organ/internal/appendix,
		"eyes" 		= /obj/item/organ/internal/eyes/vulpkanin/wolpin //Vulpkanin monkey-forms are uniquely colourblind and have excellent darksight, which is why they need a subtype of their greater-form's organ..
		)


/datum/species/monkey/skrell
	name = "Neara"
	name_plural = "Neara"

	icobase = 'icons/mob/human_races/monkeys/r_neara.dmi'

	greater_form = /datum/species/skrell
	default_language = "Neara"
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	tail = null

	inherent_traits = list(TRAIT_NOEXAMINE, TRAIT_NOFAT, TRAIT_WATERBREATH)

	has_organ = list(
		"heart" 	= /obj/item/organ/internal/heart/skrell,
		"lungs" 	= /obj/item/organ/internal/lungs/skrell,
		"liver" 	= /obj/item/organ/internal/liver/skrell,
		"kidneys" 	= /obj/item/organ/internal/kidneys/skrell,
		"brain" 	= /obj/item/organ/internal/brain/skrell,
		"appendix" 	= /obj/item/organ/internal/appendix,
		"eyes" 		= /obj/item/organ/internal/eyes/skrell //Tajara monkey-forms are uniquely colourblind and have excellent darksight, which is why they need a subtype of their greater-form's organ..
		)

/datum/species/monkey/unathi
	name = "Stok"
	name_plural = "Stok"

	icobase = 'icons/mob/human_races/monkeys/r_stok.dmi'

	tail = "stoktail"
	greater_form = /datum/species/unathi
	default_language = "Stok"
	flesh_color = "#34AF10"
	base_color = "#000000"


	has_organ = list(
		"heart" 	= /obj/item/organ/internal/heart/unathi,
		"lungs" 	= /obj/item/organ/internal/lungs/unathi,
		"liver" 	= /obj/item/organ/internal/liver/unathi,
		"kidneys" 	= /obj/item/organ/internal/kidneys/unathi,
		"brain" 	= /obj/item/organ/internal/brain/unathi,
		"appendix" 	= /obj/item/organ/internal/appendix,
		"eyes" 		= /obj/item/organ/internal/eyes/unathi
		)

/datum/species/monkey/nian_worme
	name = "nian worme"
	name_plural = "nian worme"
	icobase = 'icons/mob/human_races/monkeys/r_worme.dmi'
	tail = ""
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_BUG
	bodyflags = BALD | SHAVED
	greater_form = /datum/species/moth
	default_language = "Tkachi"
	butt_sprite = "nian"
	dietflags = DIET_HERB
	tox_mod = 3 // Die. Terrible creatures. Die.

	has_organ = list(
		"heart" 	= /obj/item/organ/internal/heart/nian,
		"lungs" 	= /obj/item/organ/internal/lungs/nian,
		"liver" 	= /obj/item/organ/internal/liver/nian,
		"kidneys" 	= /obj/item/organ/internal/kidneys/nian,
		"brain" 	= /obj/item/organ/internal/brain/nian,
		"eyes" 		= /obj/item/organ/internal/eyes/nian
	)

/datum/species/monkey/nian_worme/spec_attacked_by(obj/item/I, mob/living/user, obj/item/organ/external/affecting, intent, mob/living/carbon/human/H)
	if(istype(I, /obj/item/melee/flyswatter) && I.force)
		apply_damage(I.force * FLYSWATTER_DAMAGE_MULTIPLIER, I.damtype, affecting, FALSE, H) // making flyswatters do 15x damage to moff
