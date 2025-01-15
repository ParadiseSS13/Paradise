/datum/species/vulpkanin/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_wag
	H.verbs |= /mob/living/carbon/human/proc/emote_swag
	H.verbs |= /mob/living/carbon/human/proc/emote_howl
	H.verbs |= /mob/living/carbon/human/proc/emote_growl
	H.verbs |= /mob/living/carbon/human/proc/emote_bark
	H.verbs |= /mob/living/carbon/human/proc/emote_wbark

/datum/species/vulpkanin/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_wag
	H.verbs -= /mob/living/carbon/human/proc/emote_swag
	H.verbs -= /mob/living/carbon/human/proc/emote_howl
	H.verbs -= /mob/living/carbon/human/proc/emote_growl
	H.verbs -= /mob/living/carbon/human/proc/emote_bark
	H.verbs -= /mob/living/carbon/human/proc/emote_wbark

/datum/species/diona/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_creak

/datum/species/diona/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_creak

/datum/species/drask/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_hum

/datum/species/drask/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_hum

/datum/species/kidan/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_click
	H.verbs |= /mob/living/carbon/human/proc/emote_clack
	H.verbs |= /mob/living/carbon/human/proc/emote_waves_k
	H.verbs |= /mob/living/carbon/human/proc/emote_wiggles

/datum/species/kidan/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_click
	H.verbs -= /mob/living/carbon/human/proc/emote_clack
	H.verbs -= /mob/living/carbon/human/proc/emote_waves_k
	H.verbs -= /mob/living/carbon/human/proc/emote_wiggles

/datum/species/machine/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_ping
	H.verbs |= /mob/living/carbon/human/proc/emote_beep
	H.verbs |= /mob/living/carbon/human/proc/emote_buzz
	H.verbs |= /mob/living/carbon/human/proc/emote_buzz2
	H.verbs |= /mob/living/carbon/human/proc/emote_yes
	H.verbs |= /mob/living/carbon/human/proc/emote_no

/datum/species/machine/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_ping
	H.verbs -= /mob/living/carbon/human/proc/emote_beep
	H.verbs -= /mob/living/carbon/human/proc/emote_buzz
	H.verbs -= /mob/living/carbon/human/proc/emote_buzz2
	H.verbs -= /mob/living/carbon/human/proc/emote_yes
	H.verbs -= /mob/living/carbon/human/proc/emote_no

/datum/species/moth/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_flap
	H.verbs |= /mob/living/carbon/human/proc/emote_aflap
	H.verbs |= /mob/living/carbon/human/proc/emote_flutter

/datum/species/moth/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_flap
	H.verbs -= /mob/living/carbon/human/proc/emote_aflap
	H.verbs -= /mob/living/carbon/human/proc/emote_flutter

/datum/species/skrell/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_warble
	H.verbs |= /mob/living/carbon/human/proc/emote_croak
	H.verbs |= /mob/living/carbon/human/proc/emote_croak_anger

/datum/species/skrell/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_warble
	H.verbs -= /mob/living/carbon/human/proc/emote_croak
	H.verbs -= /mob/living/carbon/human/proc/emote_croak_anger

/datum/species/slime/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_squish
	H.verbs |= /mob/living/carbon/human/proc/emote_bubble
	H.verbs |= /mob/living/carbon/human/proc/emote_pop

/datum/species/slime/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_squish
	H.verbs -= /mob/living/carbon/human/proc/emote_bubble
	H.verbs -= /mob/living/carbon/human/proc/emote_pop

/datum/species/tajaran/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_wag
	H.verbs |= /mob/living/carbon/human/proc/emote_swag
	H.verbs |= /mob/living/carbon/human/proc/emote_purr
	H.verbs |= /mob/living/carbon/human/proc/emote_purrl
	H.verbs |= /mob/living/carbon/human/proc/emote_hiss
	H.verbs |= /mob/living/carbon/human/proc/emote_meow
	H.verbs |= /mob/living/carbon/human/proc/emote_mrow

/datum/species/tajaran/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_wag
	H.verbs -= /mob/living/carbon/human/proc/emote_swag
	H.verbs -= /mob/living/carbon/human/proc/emote_purr
	H.verbs -= /mob/living/carbon/human/proc/emote_purrl
	H.verbs -= /mob/living/carbon/human/proc/emote_hiss
	H.verbs -= /mob/living/carbon/human/proc/emote_meow
	H.verbs -= /mob/living/carbon/human/proc/emote_mrow

/datum/species/unathi/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_wag
	H.verbs |= /mob/living/carbon/human/proc/emote_swag
	H.verbs |= /mob/living/carbon/human/proc/emote_hiss
	H.verbs |= /mob/living/carbon/human/proc/emote_roar
	H.verbs |= /mob/living/carbon/human/proc/emote_threat
	H.verbs |= /mob/living/carbon/human/proc/emote_whip
	H.verbs |= /mob/living/carbon/human/proc/emote_whips
	H.verbs |= /mob/living/carbon/human/proc/emote_rumble

/datum/species/unathi/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_wag
	H.verbs -= /mob/living/carbon/human/proc/emote_swag
	H.verbs -= /mob/living/carbon/human/proc/emote_hiss
	H.verbs -= /mob/living/carbon/human/proc/emote_roar
	H.verbs -= /mob/living/carbon/human/proc/emote_threat
	H.verbs -= /mob/living/carbon/human/proc/emote_whip
	H.verbs -= /mob/living/carbon/human/proc/emote_whips
	H.verbs -= /mob/living/carbon/human/proc/emote_rumble

/datum/species/vox/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_wag
	H.verbs |= /mob/living/carbon/human/proc/emote_swag
	H.verbs |= /mob/living/carbon/human/proc/emote_quill

/datum/species/vox/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_wag
	H.verbs -= /mob/living/carbon/human/proc/emote_swag
	H.verbs -= /mob/living/carbon/human/proc/emote_quill

/datum/species/skeleton/on_species_gain(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/emote_rattle

/datum/species/skeleton/on_species_loss(mob/living/carbon/human/H)
	..()
	H.verbs -= /mob/living/carbon/human/proc/emote_rattle
