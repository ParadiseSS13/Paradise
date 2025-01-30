#define EMOTE_HUMAN_SERPENTIDROAR 			"Рычать"
#define EMOTE_HUMAN_SERPENTIDHISS 			"Шипеть"
#define EMOTE_HUMAN_SERPENTIDWIGGLE 		"Шевелить усиками"

/mob/living/carbon/human/proc/emote_serpentidroar()
	set name = "< " + EMOTE_HUMAN_SERPENTIDROAR + " >"
	set category = "Эмоции"
	emote("serpentidroar", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidhiss()
	set name = "< " + EMOTE_HUMAN_SERPENTIDHISS + " >"
	set category = "Эмоции"
	emote("serpentidhiss", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidwiggles()
	set name = "< " + EMOTE_HUMAN_SERPENTIDWIGGLE + " >"
	set category = "Эмоции"
	emote("serpentidwiggles", intentional = TRUE)

/datum/emote/living/carbon/human/serpentidroar
	name = EMOTE_HUMAN_SERPENTIDROAR

/datum/emote/living/carbon/human/serpentidhiss
	name = EMOTE_HUMAN_SERPENTIDHISS

/datum/emote/living/carbon/human/serpentidwiggles
	name = EMOTE_HUMAN_SERPENTIDWIGGLE

/datum/emote/living/carbon/human/serpentidroar
	key = "serpentidroar"
	key_third_person = "serpentidroar"
	message = "утробно рычит."
	message_mime = "бесшумно рычит."
	message_param = "утробно рычит на %t."
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	volume = 50
	muzzled_noises = list("раздражённый")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE
	sound = "modular_ss220/species/serpentids/sounds/serpentid_roar.ogg"
	age_based = TRUE

/datum/emote/living/carbon/human/serpentidhiss
	key = "serpentidhiss"
	key_third_person = "serpentidhisses"
	message = "шипит."
	message_param = "шипит на %t."
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH
	age_based = TRUE
	muzzled_noises = list("слабо")
	sound = "modular_ss220/species/serpentids/sounds/serpentid_hiss.ogg"
	muzzled_noises = list("weak hissing")

/datum/emote/living/carbon/human/serpentidwiggles
	key = "serpentidwiggles"
	key_third_person = "serpentidwiggles"
	message = "шевелит усиками."
	message_param = "шевелит усиками в сторону %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'modular_ss220/species/serpentids/sounds/serpentid_tendrils.ogg'
	hands_use_check = FALSE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/keybinding/emote/carbon/human/serpentidroar
	linked_emote = /datum/emote/living/carbon/human/serpentidroar
	name = EMOTE_HUMAN_SERPENTIDROAR

/datum/keybinding/emote/carbon/human/serpentidhiss
	linked_emote = /datum/emote/living/carbon/human/serpentidhiss
	name = EMOTE_HUMAN_SERPENTIDHISS

/datum/keybinding/emote/carbon/human/serpentidwiggles
	linked_emote = /datum/emote/living/carbon/human/serpentidwiggles
	name = EMOTE_HUMAN_SERPENTIDWIGGLE
