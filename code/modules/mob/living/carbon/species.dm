/*
	Datum-based species. Should make for much cleaner and easier to maintain mutantrace code.
*/

/datum/species
	var/name                     // Species name.
	var/path 					// Species path
	var/icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	var/deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.
	var/eyes = "eyes_s"                                  // Icon for eyes.

	var/primitive                // Lesser form, if any (ie. monkey for humans)
	var/tail                     // Name of tail image in species effects icon file.
	var/language                 // Default racial language, if any.
	var/unarmed                  //For empty hand harm-intent attack
	var/unarmed_type = /datum/unarmed_attack
	var/mutantrace               // Safeguard due to old code.

	var/breath_type = "oxygen"   // Non-oxygen gas breathed, if any.
	var/poison_type = "plasma"   // Poisonous air.
	var/exhale_type = "carbon_dioxide"      // Exhaled gas type.

	var/cold_level_1 = 260  // Cold damage level 1 below this point.
	var/cold_level_2 = 200  // Cold damage level 2 below this point.
	var/cold_level_3 = 120  // Cold damage level 3 below this point.

	var/heat_level_1 = 360  // Heat damage level 1 above this point.
	var/heat_level_2 = 400  // Heat damage level 2 above this point.
	var/heat_level_3 = 1000 // Heat damage level 2 above this point.

	var/body_temperature = 310.15	//non-IS_SYNTHETIC species will try to stabilize at this temperature. (also affects temperature processing)
	var/synth_temp_gain = 0			//IS_SYNTHETIC species will gain this much temperature every second
	var/reagent_tag                 //Used for metabolizing reagents.

	var/darksight = 2
	var/hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	var/warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	var/warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	var/hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.

	var/brute_mod = null    // Physical damage reduction/malus.
	var/burn_mod = null     // Burn damage reduction/malus.

	// For grays
	var/max_hurt_damage = 5 // Max melee damage dealt + 5 if hulk
	var/list/default_mutations = list()
	var/list/default_blocks = list() // Don't touch.
	var/list/default_block_names = list() // Use this instead, using the names from setupgame.dm

	var/flags = 0       // Various specific features.
	var/bloodflags=0
	var/bodyflags=0

	var/list/abilities = list()	// For species-derived or admin-given powers

	var/blood_color = "#A10808" //Red.
	var/flesh_color = "#FFC896" //Pink.
	var/base_color      //Used when setting species.

	//Used in icon caching.
	var/race_key = 0
	var/icon/icon_template


/datum/species/New()
	unarmed = new unarmed_type()


/datum/species/proc/create_organs(var/mob/living/carbon/human/H) //Handles creation of mob organs.
	//This is a basic humanoid limb setup.
	H.organs = list()
	H.organs_by_name["chest"] = new/datum/organ/external/chest()
	H.organs_by_name["groin"] = new/datum/organ/external/groin(H.organs_by_name["chest"])
	H.organs_by_name["head"] = new/datum/organ/external/head(H.organs_by_name["chest"])
	H.organs_by_name["l_arm"] = new/datum/organ/external/l_arm(H.organs_by_name["chest"])
	H.organs_by_name["r_arm"] = new/datum/organ/external/r_arm(H.organs_by_name["chest"])
	H.organs_by_name["r_leg"] = new/datum/organ/external/r_leg(H.organs_by_name["groin"])
	H.organs_by_name["l_leg"] = new/datum/organ/external/l_leg(H.organs_by_name["groin"])
	H.organs_by_name["l_hand"] = new/datum/organ/external/l_hand(H.organs_by_name["l_arm"])
	H.organs_by_name["r_hand"] = new/datum/organ/external/r_hand(H.organs_by_name["r_arm"])
	H.organs_by_name["l_foot"] = new/datum/organ/external/l_foot(H.organs_by_name["l_leg"])
	H.organs_by_name["r_foot"] = new/datum/organ/external/r_foot(H.organs_by_name["r_leg"])

	if (name!="Slime People")
		H.internal_organs = list()
		H.internal_organs_by_name["heart"] = new/datum/organ/internal/heart(H)
		H.internal_organs_by_name["lungs"] = new/datum/organ/internal/lungs(H)
		H.internal_organs_by_name["liver"] = new/datum/organ/internal/liver(H)
		H.internal_organs_by_name["kidney"] = new/datum/organ/internal/kidney(H)
		H.internal_organs_by_name["brain"] = new/datum/organ/internal/brain(H)
		H.internal_organs_by_name["eyes"] = new/datum/organ/internal/eyes(H)

	for(var/name in H.organs_by_name)
		H.organs += H.organs_by_name[name]

	for(var/datum/organ/external/O in H.organs)
		O.owner = H

	if(flags & IS_SYNTHETIC)
		for(var/datum/organ/external/E in H.organs)
			if(E.status & ORGAN_CUT_AWAY || E.status & ORGAN_DESTROYED) continue
			E.status |= ORGAN_ROBOT
		for(var/datum/organ/internal/I in H.internal_organs)
			I.mechanize()


	return

/datum/species/proc/handle_post_spawn(var/mob/living/carbon/human/H) //Handles anything not already covered by basic species assignment.
	return

// Used for species-specific names (Vox, etc)
/datum/species/proc/makeName(var/gender,var/mob/living/carbon/human/H=null)
	if(gender==FEMALE)	return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
	else				return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))

/datum/species/proc/handle_death(var/mob/living/carbon/human/H) //Handles any species-specific death events (such as dionaea nymph spawns).
	return


/datum/species/proc/say_filter(mob/M, message, datum/language/speaking)
	return message

/datum/species/proc/equip(var/mob/living/carbon/human/H)

/datum/species/human
	name = "Human"
	icobase = 'icons/mob/human_races/r_human.dmi'
	deform = 'icons/mob/human_races/r_def_human.dmi'
	primitive = /mob/living/carbon/monkey
	path = /mob/living/carbon/human/human
	flags = HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT
	bodyflags = HAS_SKIN_TONE
	unarmed_type = /datum/unarmed_attack/punch

/datum/species/unathi
	name = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	path = /mob/living/carbon/human/unathi
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	primitive = /mob/living/carbon/monkey/unathi
	darksight = 3

	flags = HAS_LIPS | HAS_UNDERWEAR
	bodyflags = FEET_CLAWS | HAS_TAIL | HAS_SKIN_COLOR

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 130 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000

	flesh_color = "#34AF10"

	reagent_tag = IS_UNATHI
	base_color = "#066000"

/datum/species/tajaran
	name = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	path = /mob/living/carbon/human/tajaran
	language = "Siik'tajr"
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws
	darksight = 8

	cold_level_1 = 200
	cold_level_2 = 140
	cold_level_3 = 80

	heat_level_1 = 330
	heat_level_2 = 380
	heat_level_3 = 800

	primitive = /mob/living/carbon/monkey/tajara

	flags = HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT
	bodyflags = FEET_PADDED | HAS_TAIL | HAS_SKIN_COLOR

	flesh_color = "#AFA59E"
	base_color = "#333333"

/datum/species/skrell
	name = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	path = /mob/living/carbon/human/skrell
	language = "Skrellian"
	primitive = /mob/living/carbon/monkey/skrell
	unarmed_type = /datum/unarmed_attack/punch

	flags = HAS_LIPS | HAS_UNDERWEAR
	bloodflags = BLOOD_GREEN
	bodyflags = HAS_SKIN_COLOR

	flesh_color = "#8CD7A3"

	reagent_tag = IS_SKRELL

/datum/species/vox
	name = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	path = /mob/living/carbon/human/vox
	language = "Vox-pidgin"
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = NO_SCAN | IS_WHITELISTED | NO_BLOOD

	flesh_color = "#808D11"

	reagent_tag = IS_VOX

	makeName(var/gender,var/mob/living/carbon/human/H=null)
		var/sounds = rand(2,8)
		var/i = 0
		var/newname = ""

		while(i<=sounds)
			i++
			newname += pick(vox_name_syllables)
		return capitalize(newname)

/datum/species/vox/handle_post_spawn(var/mob/living/carbon/human/H)

	H.verbs += /mob/living/carbon/human/proc/leap
	..()

/datum/species/vox/armalis/handle_post_spawn(var/mob/living/carbon/human/H)

	H.verbs += /mob/living/carbon/human/proc/gut
	..()

/datum/species/vox/armalis
	name = "Vox Armalis"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	language = "Vox-pidgin"
	path = /mob/living/carbon/human/voxarmalis
	unarmed_type = /datum/unarmed_attack/claws/armalis

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = "blank_eyes"
	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = NO_SCAN | NO_BLOOD | HAS_TAIL | NO_PAIN | IS_WHITELISTED

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = IS_VOX

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

/datum/species/vox/create_organs(var/mob/living/carbon/human/H)

	..() //create organs first.

	//Now apply cortical stack.
	var/datum/organ/external/affected = H.get_organ("head")

	//To avoid duplicates.
	for(var/obj/item/weapon/implant/cortical/imp in H.contents)
		affected.implants -= imp
		del(imp)

	var/obj/item/weapon/implant/cortical/I = new(H)
	I.imp_in = H
	I.implanted = 1
	affected.implants += I
	I.part = affected

	if(ticker.mode && ( istype( ticker.mode,/datum/game_mode/vox/heist ) ) )
		var/datum/game_mode/vox/heist/M = ticker.mode
		M.cortical_stacks += I
		M.raiders[H.mind] = I



/datum/species/kidan
	name = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	deform = 'icons/mob/human_races/r_def_kidan.dmi'
	path = /mob/living/carbon/human/kidan
	language = "Chittin"
	unarmed_type = /datum/unarmed_attack/claws

	flags = IS_WHITELISTED | HAS_CHITTIN
	bloodflags = BLOOD_GREEN
	bodyflags = FEET_CLAWS



/datum/species/slime
	name = "Slime People"
	language = "Bubblish"
	path = /mob/living/carbon/human/slime
	primitive = /mob/living/carbon/slime
	unarmed_type = /datum/unarmed_attack/punch

	flags = IS_WHITELISTED | NO_BREATHE | HAS_LIPS | NO_INTORGANS | NO_SCAN
	bloodflags = BLOOD_SLIME
	bodyflags = FEET_NOSLIP
	abilities = list(/mob/living/carbon/human/slime/proc/slimepeople_ventcrawl)

/datum/species/slime/handle_post_spawn(var/mob/living/carbon/human/H)
	H.dna = new /datum/dna(null)
	H.dna.species=H.species.name
	H.dna.mutantrace = "slime"
	H.update_mutantrace()

	return ..()

/datum/species/grey // /vg/
	name = "Grey"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	language = "Grey"
	unarmed_type = /datum/unarmed_attack/punch
	darksight = 5 // BOOSTED from 2
	eyes = "grey_eyes_s"

	primitive = /mob/living/carbon/monkey // TODO

	flags = IS_WHITELISTED | HAS_LIPS | HAS_UNDERWEAR | CAN_BE_FAT

	// Both must be set or it's only a 45% chance of manifesting.
	default_mutations=list(M_REMOTE_TALK)
	default_block_names=list("REMOTETALK")


/datum/species/diona
	name = "Diona"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	path = /mob/living/carbon/human/diona
	language = "Rootspeak"
	unarmed_type = /datum/unarmed_attack/diona
	primitive = /mob/living/carbon/monkey/diona

	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 300
	heat_level_2 = 350
	heat_level_3 = 700

	flags = NO_BREATHE | REQUIRE_LIGHT | NO_SCAN | IS_PLANT | RAD_ABSORB | NO_BLOOD | IS_SLOW | NO_PAIN

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not

	blood_color = "#004400"
	flesh_color = "#907E4A"

	reagent_tag = IS_DIONA

/datum/species/diona/handle_post_spawn(var/mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/diona/handle_death(var/mob/living/carbon/human/H)

	var/mob/living/carbon/monkey/diona/S = new(get_turf(H))

	if(H.mind)
		H.mind.transfer_to(S)
	else
		S.key = H.key

	for(var/mob/living/carbon/monkey/diona/D in H.contents)
		if(D.client)
			D.loc = H.loc
		else
			del(D)

	H.visible_message("\red[H] splits apart with a wet slithering noise!")

/datum/species/machine
	name = "Machine"
	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	path = /mob/living/carbon/human/machine
	language = "Trinary"
	unarmed_type = /datum/unarmed_attack/punch

	eyes = "blank_eyes"
	brute_mod = 1.5
	burn_mod = 1.5

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500		//gives them about 25 seconds in space before taking damage
	heat_level_2 = 1000
	heat_level_3 = 2000

	synth_temp_gain = 10 //this should cause IPCs to stabilize at ~80 C in a 20 C environment.

	flags = IS_WHITELISTED | NO_BREATHE | NO_SCAN | NO_BLOOD | NO_PAIN | IS_SYNTHETIC | NO_INTORGANS

	flesh_color = "#AAAAAA"

//Species unarmed attacks

/datum/unarmed_attack
	var/attack_verb = list("attack")	// Empty hand hurt intent verb.
	var/damage = 0						// Extra empty hand attack damage.
	var/attack_sound = "punch"
	var/miss_sound = 'sound/weapons/punchmiss.ogg'
	var/sharp = 0
	var/edge = 0

/datum/unarmed_attack/punch
	attack_verb = list("punch")

/datum/unarmed_attack/diona
	attack_verb = list("lash", "bludgeon")
	damage = 5

/datum/unarmed_attack/claws
	attack_verb = list("scratch", "claw")
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	damage = 5
	sharp = 1
	edge = 1

/datum/unarmed_attack/claws/armalis
	attack_verb = list("slash", "claw")
	damage = 10	//they're huge! they should do a little more damage, i'd even go for 15-20 maybe...
