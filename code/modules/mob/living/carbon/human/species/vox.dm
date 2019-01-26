/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/vox/r_vox.dmi'
	deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	dangerous_existence = TRUE
	language = "Vox-pidgin"
	tail = "voxtail"
	speech_sounds = list('sound/voice/shriek1.ogg')
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/claws	//I dont think it will hurt to give vox claws too.

	blurb = "The Vox are the broken remnants of a once-proud race, now reduced to little more than \
	scavenging vermin who prey on isolated stations, ships or planets to keep their own ancient arkships \
	alive. They are four to five feet tall, reptillian, beaked, tailed and quilled; human crews often \
	refer to them as 'shitbirds' for their violent and offensive nature, as well as their horrible \
	smell.<br/><br/>Most humans will never meet a Vox raider, instead learning of this insular species through \
	dealing with their traders and merchants; those that do rarely enjoy the experience."

	brute_mod = 1.2 //20% more brute damage. Fragile bird bones.

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	breathid = "n2"

	eyes = "vox_eyes_s"

	species_traits = list(NO_SCAN, IS_WHITELISTED, NOTRANSSTING)
	clothing_flags = HAS_SOCKS
	dietflags = DIET_OMNI
	bodyflags = HAS_ICON_SKIN_TONE | HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED | HAS_BODY_MARKINGS | HAS_TAIL_MARKINGS

	blood_color = "#2299FC"
	flesh_color = "#808D11"
	//Default styles for created mobs.
	default_hair = "Short Vox Quills"
	has_gender = FALSE
	default_hair_colour = "#614f19" //R: 97, G: 79, B: 25
	butt_sprite = "vox"

	reagent_tag = PROCESS_ORG
	scream_verb = "shrieks"
	male_scream_sound = 'sound/voice/shriek1.ogg'
	female_scream_sound = 'sound/voice/shriek1.ogg'
	male_cough_sounds = list('sound/voice/shriekcough.ogg')
	female_cough_sounds = list('sound/voice/shriekcough.ogg')
	male_sneeze_sound = 'sound/voice/shrieksneeze.ogg'
	female_sneeze_sound = 'sound/voice/shrieksneeze.ogg'

	icon_skin_tones = list(
		1 = "Default Green",
		2 = "Dark Green",
		3 = "Brown",
		4 = "Grey",
		5 = "Emerald",
		6 = "Azure"
		)

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs/vox,
		"liver" =    /obj/item/organ/internal/liver/vox,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes, //Default darksight of 2.
		"stack" =    /obj/item/organ/internal/stack //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is deeply inhaling oxygen!")

	speciesbox = /obj/item/storage/box/survival_vox

/datum/species/vox/handle_death(mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	if(!H.mind || !H.mind.assigned_role || H.mind.assigned_role != "Clown" && H.mind.assigned_role != "Mime")
		H.unEquip(H.wear_mask)

	H.equip_or_collect(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
	var/tank_pref = H.client && H.client.prefs ? H.client.prefs.speciesprefs : null
	var/obj/item/tank/internal_tank
	if(tank_pref)//Diseasel, here you go
		internal_tank = new /obj/item/tank/nitrogen(H)
	else
		internal_tank = new /obj/item/tank/emergency_oxygen/vox(H)
	if(!H.equip_to_appropriate_slot(internal_tank))
		if(!H.put_in_any_hand_if_possible(internal_tank))
			H.unEquip(H.l_hand)
			H.equip_or_collect(internal_tank, slot_l_hand)
			to_chat(H, "<span class='boldannounce'>Could not find an empty slot for internals! Please report this as a bug</span>")
	H.internal = internal_tank
	to_chat(H, "<span class='notice'>You are now running on nitrogen internals from the [internal_tank]. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>")
	H.update_action_buttons_icon()

/datum/species/vox/on_species_gain(mob/living/carbon/human/H)
	..()
	updatespeciescolor(H)
	H.update_icons()

/datum/species/vox/updatespeciescolor(mob/living/carbon/human/H, owner_sensitive = 1) //Handling species-specific skin-tones for the Vox race.
	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE) //Making sure we don't break Armalis.
		var/new_icobase = 'icons/mob/human_races/vox/r_vox.dmi' //Default Green Vox.
		var/new_deform = 'icons/mob/human_races/vox/r_def_vox.dmi' //Default Green Vox.
		switch(H.s_tone)
			if(6) //Azure Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
				new_deform = 'icons/mob/human_races/vox/r_def_voxazu.dmi'
				H.tail = "voxtail_azu"
			if(5) //Emerald Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
				new_deform = 'icons/mob/human_races/vox/r_def_voxemrl.dmi'
				H.tail = "voxtail_emrl"
			if(4) //Grey Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
				new_deform = 'icons/mob/human_races/vox/r_def_voxgry.dmi'
				H.tail = "voxtail_gry"
			if(3) //Brown Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
				new_deform = 'icons/mob/human_races/vox/r_def_voxbrn.dmi'
				H.tail = "voxtail_brn"
			if(2) //Dark Green Vox.
				new_icobase = 'icons/mob/human_races/vox/r_voxdgrn.dmi'
				new_deform = 'icons/mob/human_races/vox/r_def_voxdgrn.dmi'
				H.tail = "voxtail_dgrn"
			else  //Default Green Vox.
				H.tail = "voxtail" //Ensures they get an appropriately coloured tail depending on the skin-tone.

		H.change_icobase(new_icobase, new_deform, owner_sensitive) //Update the icobase/deform of all our organs, but make sure we don't mess with frankenstein limbs in doing so.
		H.update_dna()

/datum/species/vox/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "oxygen") //Armalis are above such petty things.
		H.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER) //Same as plasma.
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return FALSE //Handling reagent removal on our own.

	return ..()

/datum/species/vox/armalis
	name = "Vox Armalis"
	name_plural = "Vox Armalis"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	unarmed_type = /datum/unarmed_attack/claws/armalis
	blacklisted = TRUE

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

	species_traits = list(NO_SCAN, NO_BLOOD, NO_PAIN, IS_WHITELISTED)
	bodyflags = HAS_TAIL
	dietflags = DIET_OMNI	//should inherit this from vox, this is here just in case

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = PROCESS_ORG

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs/vox,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"eyes" =     /obj/item/organ/internal/eyes, //Default darksight of 2.
		"stack" =    /obj/item/organ/internal/stack //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is huffing oxygen!")

/datum/species/vox/armalis/handle_reagents() //Skip the Vox oxygen reagent toxicity. Armalis are above such things.
	return TRUE
