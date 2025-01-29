/datum/quirk/negative
	quirk_type = QUIRK_NEGATIVE

/datum/quirk/negative/lightweight
	name = "Lightweight"
	desc = "You can't handle liquor very well, and get drunker quicker."
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
	desc = "You just recently joined the greater galactic community, and don't understand the common tongue yet. You cannot sign up for a command or security position."
	cost = -2
	item_to_give = /obj/item/taperecorder
	blacklisted = TRUE

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
	item_to_give = /obj/item/clothing/glasses/sunglasses/blindfold
	item_slot = ITEM_SLOT_EYES

/datum/quirk/negative/mute
	name = "Mute"
	desc = "You are incurably mute, and cannot take a command or security position."
	cost = -3
	blacklisted = TRUE
	trait_to_apply = TRAIT_MUTE

/datum/quirk/negative/blind/apply_quirk_effects()
	..()
	owner.update_sight() // Gotta make sure to manually update sight, apparently.

/datum/quirk/negative/frail
	name = "Frail"
	desc = "You get major injuries much easier than most people."
	cost = -3
	trait_to_apply = TRAIT_FRAIL

#define ASTHMA_ATTACK_THRESHOLD 50

/datum/quirk/negative/asthma
	name = "Asthma"
	desc = "You have trouble catching your breath, and can have violent coughing fits when exerting yourself."
	cost = -3
	organic_only = TRUE
	trait_to_apply = TRAIT_ASTHMATIC
	processes = TRUE
	item_to_give = /obj/item/reagent_containers/pill/salbutamol // If an inhaler ever gets made put it here

/datum/quirk/negative/asthma/process()
	if(owner.stat == DEAD)
		return
	var/ease_of_breathing = owner.getOxyLoss() + owner.getStaminaLoss() / 2
	if(ease_of_breathing < ASTHMA_ATTACK_THRESHOLD)
		return
	owner.emote("cough")
	if(prob(ease_of_breathing / 5))
		trigger_asthma_symptom(ease_of_breathing)

/* Causes an asthmatic flareup, which gets worse depending on how much oxygen and stamina damage the owner already has.
*  If a bad attack isn't treated, it can easily feed into itself and kill the user.
*/
/datum/quirk/negative/asthma/proc/trigger_asthma_symptom(current_severity)
	owner.visible_message("<span class='notice'>[owner] violently coughs!</span>", "<span class='warning'>Your asthma flares up!</span>")
	switch(current_severity)
		if(50 to 75)
			owner.adjustOxyLoss(2)
		if(76 to 100)
			owner.adjustOxyLoss(4)
		if(101 to 150) // By now you're doubled over coughing
			owner.AdjustLoseBreath(4 SECONDS)
			owner.KnockDown(4 SECONDS)
		if(151 to INFINITY)
			owner.adjustOxyLoss(10)

#undef ASTHMA_ATTACK_THRESHOLD
