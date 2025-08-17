#define EMOTE_HUMAN_SERPENTIDROAR 			"Рычать"
#define EMOTE_HUMAN_SERPENTIDHISS 			"Шипеть"
#define EMOTE_HUMAN_SERPENTIDWIGGLE 		"Шевелить усиками"
#define EMOTE_HUMAN_SERPENTIDBLINK 			"Моргать щитками"
#define EMOTE_HUMAN_SERPENTIDBLINKBLADES 	"Чистить глаза"
#define EMOTE_HUMAN_SERPENTIDBUZZ 			"Стрекот крыльев"
#define EMOTE_HUMAN_SERPENTIDMANDIBLES		"Стучать мандибулами"
#define EMOTE_HUMAN_SERPENTIDBLADES			"Стучать клинками"

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

/mob/living/carbon/human/proc/emote_serpentidblinks()
	set name = "◦ " + EMOTE_HUMAN_SERPENTIDBLINK + " >"
	set category = "Эмоции"
	emote("serpentidblinks", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidblinksblades()
	set name = "◦ " + EMOTE_HUMAN_SERPENTIDBLINKBLADES + " >"
	set category = "Эмоции"
	emote("serpentidblinksblades", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidbuzzes()
	set name = "< " + EMOTE_HUMAN_SERPENTIDBUZZ + " >"
	set category = "Эмоции"
	emote("serpentidbuzzes", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidmandibles()
	set name = "< " + EMOTE_HUMAN_SERPENTIDMANDIBLES + " >"
	set category = "Эмоции"
	emote("serpentidmandibles", intentional = TRUE)

/mob/living/carbon/human/proc/emote_serpentidblades()
	set name = "< " + EMOTE_HUMAN_SERPENTIDBLADES + " >"
	set category = "Эмоции"
	emote("serpentidblades", intentional = TRUE)

/datum/emote/living/carbon/human/serpentidroar
	name = EMOTE_HUMAN_SERPENTIDROAR

/datum/emote/living/carbon/human/serpentidhiss
	name = EMOTE_HUMAN_SERPENTIDHISS

/datum/emote/living/carbon/human/serpentidwiggles
	name = EMOTE_HUMAN_SERPENTIDWIGGLE

/datum/emote/living/carbon/human/serpentidblinks
	name = EMOTE_HUMAN_SERPENTIDBLINK

/datum/emote/living/carbon/human/serpentidblinksblades
	name = EMOTE_HUMAN_SERPENTIDBLINKBLADES

/datum/emote/living/carbon/human/serpentidbuzzes
	name = EMOTE_HUMAN_SERPENTIDBUZZ

/datum/emote/living/carbon/human/serpentidblinksblades
	name = EMOTE_HUMAN_SERPENTIDMANDIBLES

/datum/emote/living/carbon/human/serpentidblades
	name = EMOTE_HUMAN_SERPENTIDBLADES

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

/datum/emote/living/carbon/human/serpentidblinks
	key = "serpentidblinks"
	key_third_person = "serpentidblinks"
	message = "опускает и поднимает глазные щитки."
	message_param = "опускает и поднимает глазные щитки, смотря на %t."
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = null
	hands_use_check = FALSE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/emote/living/carbon/human/serpentidblinksblades
	key = "serpentidblinksblades"
	key_third_person = "serpentidblinksblades"
	message = "прочищает глаза краями лезвий."
	message_param = "прочищает глаза краями лезвий, смотря на %t."
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = null
	hands_use_check = FALSE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/emote/living/carbon/human/serpentidbuzzes
	key = "serpentidbuzzes"
	key_third_person = "serpentidbuzzes"
	message = "слегка вибрирует спинным панцирем."
	message_param = "слегка вибрирует спинным панцирем в сторону %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'sound/voice/scream_moth.ogg'
	hands_use_check = FALSE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/emote/living/carbon/human/serpentidmandibles
	key = "serpentidmandibles"
	key_third_person = "serpentidmandibles"
	message = "стучит мандибулами"
	message_param = "стучит мандибулами в сторону %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'sound/effects/Kidanclack.ogg'
	hands_use_check = FALSE
	target_behavior = EMOTE_TARGET_BHVR_USE_PARAMS_ANYWAY
	emote_target_type = EMOTE_TARGET_ANY

/datum/emote/living/carbon/human/serpentidblades
	key = "serpentidblades"
	key_third_person = "serpentidblades"
	message = "стучит лезвиями."
	message_param = "стучит лезвиями в сторону %t."
	cooldown = 5 SECONDS
	species_type_whitelist_typecache = list(/datum/species/serpentid)
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE
	age_based = TRUE
	sound = 'sound/weapons/blade_unsheath.ogg'
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

/datum/keybinding/emote/carbon/human/serpentidblinks
	linked_emote = /datum/emote/living/carbon/human/serpentidblinks
	name = EMOTE_HUMAN_SERPENTIDBLINK

/datum/keybinding/emote/carbon/human/serpentidblinksblades
	linked_emote = /datum/emote/living/carbon/human/serpentidblinksblades
	name = EMOTE_HUMAN_SERPENTIDBLINKBLADES

/datum/keybinding/emote/carbon/human/serpentidbuzzes
	linked_emote = /datum/emote/living/carbon/human/serpentidbuzzes
	name = EMOTE_HUMAN_SERPENTIDBUZZ

/datum/keybinding/emote/carbon/human/serpentidmandibles
	linked_emote = /datum/emote/living/carbon/human/serpentidmandibles
	name = EMOTE_HUMAN_SERPENTIDMANDIBLES

/datum/keybinding/emote/carbon/human/serpentidblades
	linked_emote = /datum/emote/living/carbon/human/serpentidblades
	name = EMOTE_HUMAN_SERPENTIDBLADES
