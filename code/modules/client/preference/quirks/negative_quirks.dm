/datum/quirk/negative
	quirk_type = QUIRK_NEGATIVE

/datum/quirk/negative/lightweight
	name = "Lightweight"
	desc = "You can't handle liquor very well, and get drunk much easier."
	cost = -1
	var/alcohol_modifier = 1.3

/datum/quirk/negative/lightweight/apply_quirk_effects(mob/living/quirky)
	if(!ishuman(quirky))
		return
	var/mob/living/carbon/human/user = quirky
	user.physiology.alcohol_mod *= alcohol_modifier
	. = ..()


/datum/quirk/negative/foreigner
	name = "Foreigner"
	desc = "You just recently joined the greater galactic community, and don't understand the common tongue yet."
	cost = -1
	item_to_give = /obj/item/taperecorder
	spawn_text = "You feel out of place."

/datum/quirk/negative/foreigner/apply_quirk_effects(mob/living/quirky)
	quirky.remove_language("Galactic Common")
	quirky.set_default_language(quirky.languages[1]) // set_default_language needs to be passed a direct reference to the user's language list
	. = ..()

/datum/quirk/negative/deaf
	name = "Deafness"
	desc = "You are incurably deaf, and cannot take a command or security position."
	cost = -4
	trait_to_apply = TRAIT_DEAF
	blacklisted = TRUE

/datum/quirk/negative/blind
	name = "Blind"
	desc = "You are incurably blind, and cannot take a command or security position."
	cost = -4
	trait_to_apply = TRAIT_BLIND
	blacklisted = TRUE

/datum/quirk/negative/blind/apply_quirk_effects(mob/living/quirky)
	..()
	quirky.update_sight() // Gotta make sure to manually update sight, apparently.

/datum/quirk/negative/frail
	name = "Frail"
	desc = "You get major injuries much easier."
	cost = -3
	trait_to_apply = TRAIT_FRAIL

/datum/quirk/negative/asthma
	name = "Asthma"
	desc = "You have trouble breathing sometimes."
	cost = -4
	organic_only = TRUE
	trait_to_apply = TRAIT_ASTHMATIC
	processes = TRUE
	item_to_give = /obj/item/reagent_containers/pill/salbutamol

/datum/quirk/negative/asthma/process()
