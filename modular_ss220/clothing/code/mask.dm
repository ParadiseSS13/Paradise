/obj/item/clothing/mask
	var/modifies_speech = FALSE

/obj/item/clothing/mask/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	return

/obj/item/clothing/mask/equipped(mob/M, slot)
	. = ..()

	if((slot & SLOT_HUD_WEAR_MASK) && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/fakemoustache/chef
	name = "абсолютно настоящие усы шефа"
	desc = "Осторожно: усы накладные."
	modifies_speech = TRUE

/obj/item/clothing/mask/fakemoustache/chef/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		var/static/regex/words = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "g")
		message = replacetext(message, words, GLOBAL_PROC_REF(italian_words_replace))

		if(prob(5))
			message += pick(" Равиоли, равиоли, подскажи мне формуоли!"," Мамма-мия!"," Мамма-мия! Какая острая фрикаделька!", " Ла ла ла ла ла фуникули+ фуникуля+!", " Вордс Реплаке!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/proc/italian_words_replace(word)
	var/static/list/italian_words
	if(!italian_words)
		italian_words = strings("italian_replacement.json", "italian")

	var/match = italian_words[lowertext(word)]
	if(!match)
		return word

	if(islist(match))
		match = pick(match)

	if(word == uppertext(word))
		return uppertext(match)

	if(word == capitalize(word))
		return capitalize(match)

	return match

/datum/outfit/job/chef
	mask = /obj/item/clothing/mask/fakemoustache/chef

/obj/item/clothing/mask/breath/red_gas
	name = "ПРС-1"
	desc = "Стильная дыхательная маска в виде противогаза, не скрывает лицо."
	icon = 'modular_ss220/clothing/icons/object/masks.dmi'
	icon_state = "red_gas"
	icon_override = 'modular_ss220/clothing/icons/mob/mask.dmi'

/obj/item/clothing/mask/breath/breathscarf
	name = "шарф с системой дыхания"
	desc = "Стильный и инновационный шарф, который служит дыхательной маской в экстремальных ситуациях."
	icon = 'modular_ss220/clothing/icons/object/masks.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mask.dmi'
	icon_state = "breathscarf"

/obj/item/clothing/mask/rooster
	w_class = WEIGHT_CLASS_SMALL
	flags = BLOCKHAIR
	flags_inv = HIDEEARS | HIDEEYES | HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	modifies_speech = TRUE
	species_restricted = list("Human", "Nian", "Skrell", "Slime People", "Diona", "Skeleton", "Shadow")

/obj/item/clothing/mask/rooster
	name = "маска петуха"
	desc = "Прямо из Острой дороги космо-Майами. Со встроенными фразами."
	icon = 'modular_ss220/clothing/icons/object/masks.dmi'
	icon_override = 'modular_ss220/clothing/icons/mob/mask.dmi'
	icon_state = "rooster_mask"

/obj/item/clothing/mask/rooster/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(!length(message))
		return
	if(prob(3))
		message += pick(
			". Тебе нравится причинять людям боль?",
			". Вы вернулись, да?",
			". Что, бля, за неуважение?",
			)
	speech_args[SPEECH_MESSAGE] = trim(message)

/* EI mask */
/obj/item/clothing/mask/breath/ei_mask
	name = "дыхательная маска от EI"
	desc = "Качество и надежность, а самое главное - безопасность."
	icon = 'modular_ss220/clothing/icons/object/masks.dmi'
	icon_state = "ei_mask"
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/species/vulpkanin/mask.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/mask.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/species/unathi/mask.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/mask.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/mask.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/mask.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/mask.dmi',
	)
