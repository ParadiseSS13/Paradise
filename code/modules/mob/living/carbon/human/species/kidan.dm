/datum/species/kidan
	name = "Kidan"
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	deform = 'icons/mob/human_races/r_def_kidan.dmi'
	language = "Chittin"
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8
	tox_mod = 1.7

	species_traits = list(IS_WHITELISTED)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS
	fingers_count = 6
	eyes = "kidan_eyes_s"
	flesh_color = "#ba7814"
	blood_species = "Kidan"
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/kidan,
		"lungs" =    /obj/item/organ/internal/lungs/kidan,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys/kidan,
		"brain" =    /obj/item/organ/internal/brain/kidan,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/kidan, //Default darksight of 2.
		"lantern" =  /obj/item/organ/internal/lantern
		)

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/kidan),
		"groin" =  list("path" = /obj/item/organ/external/groin/kidan),
		"head" =   list("path" = /obj/item/organ/external/head/kidan),
		"l_arm" =  list("path" = /obj/item/organ/external/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/hand),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/foot),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right)
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"пытается откусить себе усики!",
		"вонзает когти в свои глазницы!",
		"сворачивает себе шею!",
		"разбивает себе панцирь",
		"протыкает себя челюстями!",
		"задерживает дыхание!")

	speech_sounds = list('sound/voice/kidan/speak1.ogg', 'sound/voice/kidan/speak2.ogg', 'sound/voice/kidan/speak3.ogg' )
	speech_chance = 35
	scream_verb = "визжит"
	female_giggle_sound = list('sound/voice/kidan/giggles1.ogg', 'sound/voice/kidan/giggles2.ogg')
	male_giggle_sound = list('sound/voice/kidan/giggles1.ogg', 'sound/voice/kidan/giggles2.ogg')
	male_scream_sound = list('sound/voice/kidan/scream1.ogg', 'sound/voice/kidan/scream2.ogg', 'sound/voice/kidan/scream3.ogg')
	female_scream_sound = list('sound/voice/kidan/scream1.ogg', 'sound/voice/kidan/scream2.ogg', 'sound/voice/kidan/scream3.ogg')
	female_laugh_sound = list('sound/voice/kidan/laugh1.ogg', 'sound/voice/kidan/laugh2.ogg', 'sound/voice/kidan/laugh3.ogg', 'sound/voice/kidan/laugh4.ogg')
	male_laugh_sound = list('sound/voice/kidan/laugh1.ogg', 'sound/voice/kidan/laugh2.ogg', 'sound/voice/kidan/laugh3.ogg', 'sound/voice/kidan/laugh4.ogg')
	death_sounds = list('sound/voice/kidan/deathgasp1.ogg', 'sound/voice/kidan/deathgasp2.ogg')
	male_dying_gasp_sounds = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	female_dying_gasp_sounds = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	male_cough_sounds = list('sound/voice/kidan/cough1.ogg')
	female_cough_sounds = list('sound/voice/kidan/cough1.ogg')
	male_sneeze_sound = list('sound/voice/kidan/sneeze1.ogg', 'sound/voice/kidan/sneeze2.ogg', 'sound/voice/kidan/sneeze3.ogg', 'sound/voice/kidan/sneeze4.ogg')
	female_sneeze_sound = list('sound/voice/kidan/sneeze1.ogg', 'sound/voice/kidan/sneeze2.ogg', 'sound/voice/kidan/sneeze3.ogg', 'sound/voice/kidan/sneeze4.ogg')
	female_cry_sound = list('sound/voice/kidan/cry1.ogg', 'sound/voice/kidan/cry2.ogg')
	male_cry_sound = list('sound/voice/kidan/cry1.ogg', 'sound/voice/kidan/cry2.ogg')
	female_grumble_sound = list('sound/voice/kidan/grumble1.ogg', 'sound/voice/kidan/grumble2.ogg', 'sound/voice/kidan/grumble3.ogg')
	male_grumble_sound = list('sound/voice/kidan/grumble1.ogg', 'sound/voice/kidan/grumble2.ogg', 'sound/voice/kidan/grumble3.ogg')
	male_moan_sound = list('sound/voice/kidan/moan1.ogg')
	female_moan_sound = list('sound/voice/kidan/moan1.ogg')
	female_sigh_sound = list('sound/voice/kidan/sigh1.ogg', 'sound/voice/kidan/sigh2.ogg')
	male_sigh_sound = list('sound/voice/kidan/sigh1.ogg', 'sound/voice/kidan/sigh2.ogg')
	female_choke_sound = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')
	male_choke_sound = list('sound/voice/kidan/dying_gasp1.ogg', 'sound/voice/kidan/dying_gasp2.ogg', 'sound/voice/kidan/dying_gasp3.ogg')

	disliked_food = FRIED | DAIRY
	liked_food = SUGAR | ALCOHOL | GROSS | FRUIT

/datum/species/kidan/get_species_runechat_color(mob/living/carbon/human/H)
	var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
	return E.eye_colour

/datum/species/kidan/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_click
	H.verbs |= /mob/living/carbon/human/proc/emote_clack
	H.verbs |= /mob/living/carbon/human/proc/emote_wiggle
	H.verbs |= /mob/living/carbon/human/proc/emote_waves_antennae
	H.verbs -= /mob/living/carbon/human/verb/emote_pale
	H.verbs -= /mob/living/carbon/human/verb/emote_blink
	H.verbs -= /mob/living/carbon/human/verb/emote_blink_r
	H.verbs -= /mob/living/carbon/human/verb/emote_blush
	H.verbs -= /mob/living/carbon/human/verb/emote_wink
	H.verbs -= /mob/living/carbon/human/verb/emote_smile
	H.verbs -= /mob/living/carbon/human/verb/emote_snuffle
	H.verbs -= /mob/living/carbon/human/verb/emote_grin
	H.verbs -= /mob/living/carbon/human/verb/emote_eyebrow
	H.verbs -= /mob/living/carbon/human/verb/emote_frown
	H.verbs -= /mob/living/carbon/human/verb/emote_sniff
	H.verbs -= /mob/living/carbon/human/verb/emote_glare

/datum/species/kidan/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_click
	H.verbs -= /mob/living/carbon/human/proc/emote_clack
	H.verbs -= /mob/living/carbon/human/proc/emote_wiggle
	H.verbs -= /mob/living/carbon/human/proc/emote_waves_antennae
	H.verbs |= /mob/living/carbon/human/verb/emote_pale
	H.verbs |= /mob/living/carbon/human/verb/emote_blink
	H.verbs |= /mob/living/carbon/human/verb/emote_blink_r
	H.verbs |= /mob/living/carbon/human/verb/emote_blush
	H.verbs |= /mob/living/carbon/human/verb/emote_wink
	H.verbs |= /mob/living/carbon/human/verb/emote_smile
	H.verbs |= /mob/living/carbon/human/verb/emote_snuffle
	H.verbs |= /mob/living/carbon/human/verb/emote_grin
	H.verbs |= /mob/living/carbon/human/verb/emote_eyebrow
	H.verbs |= /mob/living/carbon/human/verb/emote_frown
	H.verbs |= /mob/living/carbon/human/verb/emote_sniff
	H.verbs |= /mob/living/carbon/human/verb/emote_glare

