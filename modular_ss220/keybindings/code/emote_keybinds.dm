/datum/keybinding/emote/New()
	name = initial(linked_emote.name)

/datum/keybinding/emote/carbon/human/hem
	linked_emote = /datum/emote/living/carbon/human/hem
	name = EMOTE_HUMAN_HEM

/datum/keybinding/emote/carbon/human/scratch
	linked_emote = /datum/emote/living/carbon/human/scratch
	name = EMOTE_HUMAN_SCRATCH

/datum/keybinding/emote/carbon/human/whistle
	linked_emote = /datum/emote/living/carbon/human/whistle
	name = EMOTE_HUMAN_WHISTLE

/datum/keybinding/emote/carbon/human/snuffle
	linked_emote = /datum/emote/living/carbon/human/snuffle
	name = EMOTE_HUMAN_SNUFFLE

/datum/keybinding/emote/carbon/human/roar
	linked_emote = /datum/emote/living/carbon/human/roar
	name = EMOTE_HUMAN_ROAR

/datum/keybinding/emote/carbon/human/rumble
	linked_emote = /datum/emote/living/carbon/human/rumble
	name = EMOTE_HUMAN_RUMBLE

/datum/keybinding/emote/carbon/human/threat
	linked_emote = /datum/emote/living/carbon/human/threat
	name = EMOTE_HUMAN_THREAT

/datum/keybinding/emote/carbon/human/purr
	linked_emote = /datum/emote/living/carbon/human/purr
	name = EMOTE_HUMAN_PURR

/datum/keybinding/emote/carbon/human/purrl
	linked_emote = /datum/emote/living/carbon/human/purrl
	name = EMOTE_HUMAN_PURRL

/datum/keybinding/emote/carbon/human/waves
	linked_emote = /datum/emote/living/carbon/human/waves_k
	name = EMOTE_HUMAN_WAVES_K

/datum/keybinding/emote/carbon/human/wiggles
	linked_emote = /datum/emote/living/carbon/human/wiggles
	name = EMOTE_HUMAN_WIGGLES

/datum/keybinding/emote/carbon/human/whips
	linked_emote = /datum/emote/living/carbon/human/whip/whips
	name = EMOTE_HUMAN_WHIPS

/datum/keybinding/emote/carbon/human/whip
	linked_emote = /datum/emote/living/carbon/human/whip
	name = EMOTE_HUMAN_WHIP

/datum/keybinding/emote/carbon/human/croak
	linked_emote = /datum/emote/living/carbon/human/croak
	name = EMOTE_HUMAN_CROAK

/datum/keybinding/emote/carbon/human/croak/anger
	linked_emote = /datum/emote/living/carbon/human/croak/anger
	name = EMOTE_HUMAN_CROAK_ANGER

/datum/keybinding/emote/exercise
	linked_emote = /datum/emote/exercise
	name = EMOTE_EXERCISE

/datum/keybinding/emote/exercise/squat
	linked_emote = /datum/emote/exercise/squat
	name = EMOTE_SQUAT

/datum/keybinding/emote/exercise/pushup
	linked_emote = /datum/emote/exercise/pushup
	name = EMOTE_PUSHUP

/datum/keybinding/emote/carbon/human/bark
	linked_emote = /datum/emote/living/carbon/human/bark
	name = EMOTE_HUMAN_BARK

/datum/keybinding/emote/carbon/human/wbark
	linked_emote = /datum/emote/living/carbon/human/wbark
	name = EMOTE_HUMAN_WBARK

/datum/keybinding/emote/carbon/human/drask_talk/New()
	..()
	name += " (драск)"

/datum/keybinding/emote/carbon/human/hiss/New()
	..()
	name += " (унатх)"

/datum/keybinding/emote/carbon/human/hiss/tajaran/New()
	..()
	name = replacetext(name, regex(@"\(.*\)"), "(таяр)")

/datum/keybinding/emote/carbon/human/monkey/New()
	..()
	name += " (мартышка)"

/datum/keybinding/emote/simple_animal/diona_chirp/New()
	..()
	name += " (нимфа)"

/datum/keybinding/emote/simple_animal/gorilla_ooga/New()
	..()
	name += " (горилла)"

/datum/keybinding/emote/simple_animal/pet/dog/New()
	..()
	name += " (пёс)"

/datum/keybinding/emote/simple_animal/mouse/New()
	..()
	name += " (мышь)"

/datum/keybinding/emote/simple_animal/pet/cat/New()
	..()
	name += " (кот)"

/datum/keybinding/custom
	default_emote_text = "Введите текст вашей эмоции"

/datum/keybinding/custom/one
	name = "Своя эмоция 1"

/datum/keybinding/custom/two
	name = "Своя эмоция 2"

/datum/keybinding/custom/three
	name = "Своя эмоция 3"

/datum/keybinding/custom/four
	name = "Своя эмоция 4"

/datum/keybinding/custom/five
	name = "Своя эмоция 5"

/datum/keybinding/custom/six
	name = "Своя эмоция 6"

/datum/keybinding/custom/seven
	name = "Своя эмоция 7"

/datum/keybinding/custom/eight
	name = "Своя эмоция 8"

/datum/keybinding/custom/nine
	name = "Своя эмоция 9"

/datum/keybinding/custom/ten
	name = "Своя эмоция 10"
