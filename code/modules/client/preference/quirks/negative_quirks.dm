/datum/quirk/alcohol_tolerance
	var/alcohol_modifier = 1

/datum/quirk/alcohol_tolerance/apply_quirk_effects(mob/living/quirky)
	..()
	owner.physiology.alcohol_mod *= alcohol_modifier

/datum/quirk/alcohol_tolerance/remove_quirk_effects()
	..()
	owner.physiology.alcohol_mod /= alcohol_modifier

/datum/quirk/alcohol_tolerance/lightweight
	name = "Lightweight"
	desc = "You can't handle liquor very well, and get drunker quicker."
	cost = -1
	alcohol_modifier = 1.3

/datum/quirk/foreigner
	name = "Foreigner"
	desc = "You just recently joined the greater galactic community, and don't understand the common tongue yet. You cannot sign up for a command or security position."
	cost = -2
	item_to_give = /obj/item/taperecorder
	blacklisted = TRUE
	trait_to_apply = TRAIT_FOREIGNER

/datum/quirk/foreigner/apply_quirk_effects(mob/living/quirky)
	..()
	owner.remove_language("Galactic Common")
	owner.set_default_language(quirky.languages[1]) // set_default_language needs to be passed a direct reference to the user's language list

/datum/quirk/foreigner/remove_quirk_effects()
	owner.add_language("Galactic Common")
	..()

/datum/quirk/deaf
	name = "Deafness"
	desc = "You are incurably deaf, and cannot take a command or security position."
	cost = -4
	trait_to_apply = TRAIT_DEAF
	blacklisted = TRUE

/datum/quirk/blind
	name = "Blind"
	desc = "You are incurably blind, and cannot take a command or security position."
	cost = -4
	trait_to_apply = TRAIT_BLIND
	blacklisted = TRUE
	item_to_give = /obj/item/clothing/glasses/sunglasses/blindfold
	item_slot = ITEM_SLOT_EYES

/datum/quirk/mute
	name = "Mute"
	desc = "You are incurably mute, and cannot take a command or security position."
	cost = -3
	blacklisted = TRUE
	trait_to_apply = TRAIT_MUTE

/datum/quirk/blind/apply_quirk_effects()
	..()
	owner.update_sight() // Gotta make sure to manually update sight, apparently.

/datum/quirk/blind/remove_quirk_effects()
	..()
	owner.update_sight()

/datum/quirk/frail
	name = "Frail"
	desc = "You get major injuries much easier than most people."
	cost = -3
	trait_to_apply = TRAIT_FRAIL

#define ASTHMA_ATTACK_THRESHOLD 50

/datum/quirk/asthma
	name = "Asthma"
	desc = "You have trouble catching your breath, and can have violent coughing fits when exerting yourself. IPCs cannot take this."
	cost = -3
	species_flags = QUIRK_MACHINE_INCOMPATIBLE
	trait_to_apply = TRAIT_ASTHMATIC
	processes = TRUE
	item_to_give = /obj/item/reagent_containers/pill/salbutamol // If an inhaler ever gets made put it here

/datum/quirk/asthma/process()
	if(!..())
		return
	var/ease_of_breathing = owner.getOxyLoss() + owner.getStaminaLoss() / 2
	if(ease_of_breathing < ASTHMA_ATTACK_THRESHOLD)
		return
	owner.emote("cough")
	if(prob(ease_of_breathing / 4))
		trigger_asthma_symptom(ease_of_breathing)

/* Causes an asthmatic flareup, which gets worse depending on how much oxygen and stamina damage the owner already has.
*  If a bad attack isn't treated, it can easily feed into itself and kill the user.
*/
/datum/quirk/asthma/proc/trigger_asthma_symptom(current_severity)
	owner.visible_message("<span class='notice'>[owner] violently coughs!</span>", "<span class='warning'>Your asthma flares up!</span>")
	switch(current_severity)
		if(50 to 75)
			owner.adjustOxyLoss(3)
		if(76 to 100)
			owner.adjustOxyLoss(5)
		if(101 to 150) // By now you're doubled over coughing
			owner.adjustOxyLoss(2)
			owner.AdjustLoseBreath(4 SECONDS)
			owner.KnockDown(4 SECONDS)
		if(151 to INFINITY)
			owner.adjustOxyLoss(10)

#undef ASTHMA_ATTACK_THRESHOLD

/datum/quirk/no_apc_charging
	name = "High Internal Resistance"
	desc = "The station's outlets operate at a higher voltage than your chassis can handle, so you can only safely charge from recharging stations. Only IPCs can take this."
	cost = -2
	species_flags = QUIRK_ORGANIC_INCOMPATIBLE
	trait_to_apply = TRAIT_NO_APC_CHARGING
	organ_slot_to_remove = "r_arm_device" // This feels like such a dumb way to do this but I can't think of a smarter solution

/datum/quirk/pacifism
	name = "Pacifist"
	desc = "You can't bring yourself to hurt others, and cannot take a command or security position."
	cost = -3
	trait_to_apply = TRAIT_PACIFISM
