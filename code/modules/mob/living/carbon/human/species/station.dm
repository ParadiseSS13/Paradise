/datum/species/human
	name = "Human"
	name_plural = "Humans"
	icobase = 'icons/mob/human_races/r_human.dmi'
	deform = 'icons/mob/human_races/r_def_human.dmi'
	primitive_form = "Monkey"
	path = /mob/living/carbon/human/human
	language = "Sol Common"
	species_traits = list(LIPS, CAN_BE_FAT)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	dietflags = DIET_OMNI
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	reagent_tag = PROCESS_ORG
	//Has standard darksight of 2.

/datum/species/unathi
	name = "Unathi"
	name_plural = "Unathi"
	icobase = 'icons/mob/human_races/r_lizard.dmi'
	deform = 'icons/mob/human_races/r_def_lizard.dmi'
	path = /mob/living/carbon/human/unathi
	default_language = "Galactic Common"
	language = "Sinta'unathi"
	tail = "sogtail"
	unarmed_type = /datum/unarmed_attack/claws
	primitive_form = "Stok"

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_BODY_MARKINGS | HAS_HEAD_MARKINGS | HAS_SKIN_COLOR | HAS_ALT_HEADS | TAIL_WAGGING
	dietflags = DIET_CARN

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 480 //Default 460

	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_headacc = "Simple"
	default_headacc_colour = "#404040"
	butt_sprite = "unathi"
	brute_mod = 1.05

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/unathi //3 darksight.
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

	var/datum/action/innate/tail_lash/lash = new()


/datum/species/unathi/handle_post_spawn(var/mob/living/carbon/human/H)
	lash.Grant(H)
	..()

/datum/action/innate/tail_lash
	name = "Tail lash"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "tail"

/datum/action/innate/tail_lash/Activate()
	var/mob/living/carbon/human/user = owner
	if(!user.restrained() || !user.buckled)
		to_chat(user, "<span class='warning'>You need freedom of movement to tail lash!</span>")
		return
	if(user.getStaminaLoss() >= 50)
		to_chat(user, "<span class='warning'>Rest before tail lashing again!</span>")
		return
	for(var/mob/living/carbon/human/C in orange(1))
		var/obj/item/organ/external/E = C.get_organ(pick("l_leg", "r_leg", "l_foot", "r_foot", "groin"))
		if(E)
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message("<span class='danger'>[src] smacks [C] in [E] with their tail! </span>", "<span class='danger'>You hit [C] in [E] with your tail!</span>")
			user.adjustStaminaLoss(15)
			C.apply_damage(5, BRUTE, E)
			user.spin(20, 1)
			playsound(user.loc, 'sound/weapons/slash.ogg', 50, 0)



/datum/species/unathi/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/tajaran
	name = "Tajaran"
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	deform = 'icons/mob/human_races/r_def_tajaran.dmi'
	path = /mob/living/carbon/human/tajaran
	default_language = "Galactic Common"
	language = "Siik'tajr"
	tail = "tajtail"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "The Tajaran race is a species of feline-like bipeds hailing from the planet of Ahdomai in the \
	S'randarr system. They have been brought up into the space age by the Humans and Skrell, and have been \
	influenced heavily by their long history of Slavemaster rule. They have a structured, clan-influenced way \
	of family and politics. They prefer colder environments, and speak a variety of languages, mostly Siik'Maas, \
	using unique inflections their mouths form."

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	primitive_form = "Farwa"

	species_traits = list(LIPS, CAN_BE_FAT)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG
	flesh_color = "#AFA59E"
	base_color = "#424242"
	butt_sprite = "tajaran"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/tajaran,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/tajaran /*Most Tajara see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
															 unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/chick, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot,
								 /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/tajaran/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/vulpkanin
	name = "Vulpkanin"
	name_plural = "Vulpkanin"
	icobase = 'icons/mob/human_races/r_vulpkanin.dmi'
	deform = 'icons/mob/human_races/r_vulpkanin.dmi'
	path = /mob/living/carbon/human/vulpkanin
	default_language = "Galactic Common"
	language = "Canilunzt"
	primitive_form = "Wolpin"
	tail = "vulptail"
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Vulpkanin are a species of sharp-witted canine-pideds residing on the planet Altam just barely within the \
	dual-star Vazzend system. Their politically de-centralized society and independent natures have led them to become a species and \
	culture both feared and respected for their scientific breakthroughs. Discovery, loyalty, and utilitarianism dominates their lifestyles \
	to the degree it can cause conflict with more rigorous and strict authorities. They speak a guttural language known as 'Canilunzt' \
    which has a heavy emphasis on utilizing tail positioning and ear twitches to communicate intent."

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR
	dietflags = DIET_OMNI
	hunger_drain = 0.11
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG
	flesh_color = "#966464"
	base_color = "#CF4D2F"
	butt_sprite = "vulp"

	scream_verb = "yelps"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/vulpkanin,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/vulpkanin /*Most Vulpkanin see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
															   unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/vulpkanin/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/skrell
	name = "Skrell"
	name_plural = "Skrell"
	icobase = 'icons/mob/human_races/r_skrell.dmi'
	deform = 'icons/mob/human_races/r_def_skrell.dmi'
	path = /mob/living/carbon/human/skrell
	default_language = "Galactic Common"
	language = "Skrellian"
	primitive_form = "Neara"

	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_BODY_MARKINGS
	dietflags = DIET_HERB
	taste_sensitivity = TASTE_SENSITIVITY_DULL
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
	base_color = "#38b661" //RGB: 56, 182, 97.
	default_hair_colour = "#38b661"
	eyes = "skrell_eyes_s"
	//Default styles for created mobs.
	default_hair = "Skrell Male Tentacles"
	reagent_tag = PROCESS_ORG
	butt_sprite = "skrell"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/skrell,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes, //Default darksight of 2.
		"headpocket" = /obj/item/organ/internal/headpocket
		)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their thumbs into their eye sockets!",
		"is twisting their own neck!",
		"makes like a fish and suffocates!",
		"is strangling themselves with their own tendrils!")

/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/vox/r_vox.dmi'
	deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
	path = /mob/living/carbon/human/vox

	default_language = "Galactic Common"
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
		"stack" =    /obj/item/organ/internal/stack/vox //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is deeply inhaling oxygen!")

/datum/species/vox/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/vox/makeName(var/gender,var/mob/living/carbon/human/H=null)
	var/sounds = rand(2,8)
	var/i = 0
	var/newname = ""

	while(i<=sounds)
		i++
		newname += pick(vox_name_syllables)
	return capitalize(newname)

/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	if(!H.mind || !H.mind.assigned_role || H.mind.assigned_role != "Clown" && H.mind.assigned_role != "Mime")
		H.unEquip(H.wear_mask)
	H.unEquip(H.l_hand)

	H.equip_or_collect(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
	var/tank_pref = H.client && H.client.prefs ? H.client.prefs.speciesprefs : null
	if(tank_pref)//Diseasel, here you go
		H.equip_or_collect(new /obj/item/tank/nitrogen(H), slot_l_hand)
	else
		H.equip_or_collect(new /obj/item/tank/emergency_oxygen/vox(H), slot_l_hand)
	to_chat(H, "<span class='notice'>You are now running on nitrogen internals from the [H.l_hand] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>")
	H.internal = H.l_hand
	H.update_action_buttons_icon()

/datum/species/vox/handle_post_spawn(var/mob/living/carbon/human/H)
	updatespeciescolor(H)
	H.update_icons()
	//H.verbs += /mob/living/carbon/human/proc/leap
	..()

/datum/species/vox/updatespeciescolor(var/mob/living/carbon/human/H, var/owner_sensitive = 1) //Handling species-specific skin-tones for the Vox race.
	if(H.species.bodyflags & HAS_ICON_SKIN_TONE) //Making sure we don't break Armalis.
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

/datum/species/vox/handle_reagents(var/mob/living/carbon/human/H, var/datum/reagent/R)
	if(R.id == "oxygen") //Armalis are above such petty things.
		H.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER) //Same as plasma.
		H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
		return 0 //Handling reagent removal on our own.

	return ..()

/datum/species/vox/armalis/handle_post_spawn(var/mob/living/carbon/human/H)
	H.verbs += /mob/living/carbon/human/proc/leap
	H.verbs += /mob/living/carbon/human/proc/gut
	..()

/datum/species/vox/armalis
	name = "Vox Armalis"
	name_plural = "Vox Armalis"
	icobase = 'icons/mob/human_races/r_armalis.dmi'
	deform = 'icons/mob/human_races/r_armalis.dmi'
	path = /mob/living/carbon/human/voxarmalis
	unarmed_type = /datum/unarmed_attack/claws/armalis

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
		"stack" =    /obj/item/organ/internal/stack/vox //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is huffing oxygen!")

/datum/species/vox/armalis/handle_reagents() //Skip the Vox oxygen reagent toxicity. Armalis are above such things.
	return 1

/datum/species/kidan
	name = "Kidan"
	name_plural = "Kidan"
	icobase = 'icons/mob/human_races/r_kidan.dmi'
	deform = 'icons/mob/human_races/r_def_kidan.dmi'
	path = /mob/living/carbon/human/kidan
	default_language = "Galactic Common"
	language = "Chittin"
	unarmed_type = /datum/unarmed_attack/claws

	brute_mod = 0.8

	species_traits = list(IS_WHITELISTED)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HEAD_MARKINGS | HAS_BODY_MARKINGS
	eyes = "kidan_eyes_s"
	dietflags = DIET_HERB
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	//Default styles for created mobs.
	default_headacc = "Normal Antennae"
	butt_sprite = "kidan"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes, //Default darksight of 2.
		"lantern" =  /obj/item/organ/internal/lantern
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"is attempting to bite their antenna off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is cracking their exoskeleton!",
		"is stabbing themselves with their mandibles!",
		"is holding their breath!")

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	default_language = "Galactic Common"
	language = "Bubblish"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	path = /mob/living/carbon/human/slime
	remains_type = /obj/effect/decal/remains/slime

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	coldmod = 3

	oxy_mod = 0
	brain_mod = 2.5

	male_cough_sounds = list('sound/effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/slime_squish.ogg')

	species_traits = list(LIPS, IS_WHITELISTED, NO_BREATHE, NO_INTORGANS, NO_SCAN)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	dietflags = DIET_CARN
	reagent_tag = PROCESS_ORG

	blood_color = "#0064C8"
	exotic_blood = "water"
	blood_damage_type = TOX

	butt_sprite = "slime"
	//Has default darksight of 2.

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/slime
		)

	suicide_messages = list(
		"is melting into a puddle!",
		"is ripping out their own core!",
		"is turning a dull, brown color and melting into a puddle!")

	var/list/mob/living/carbon/human/recolor_list = list()

	var/datum/action/innate/regrow/grow = new()

	species_abilities = list(
		/mob/living/carbon/human/verb/toggle_recolor_verb,
		/mob/living/carbon/human/proc/regrow_limbs
		)

/datum/species/slime/handle_post_spawn(var/mob/living/carbon/human/H)
	grow.Grant(H)
	..()

/datum/action/innate/regrow
	name = "Regrow limbs"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/regrow/Activate()
	var/mob/living/carbon/human/user = owner
	user.regrow_limbs()


/datum/species/slime/handle_life(var/mob/living/carbon/human/H)
//This is allegedly for code "style". Like a plaid sweater?
#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.
	// Slowly shifting to the color of the reagents
	if((H in recolor_list) && H.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = H.blood_volume
		var/r_color = mix_color_from_reagents(H.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, H.skin_colour, (blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)/((blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)+(H.reagents.total_volume)))
		H.skin_colour = new_body_color
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in H.bodyparts_by_name)
				var/obj/item/organ/external/E = H.bodyparts_by_name[organname]
				if(istype(E) && E.dna.species == "Slime People")
					E.sync_colour_to_human(H)
			H.update_hair(0)
			H.update_body()
	..()

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

/mob/living/carbon/human/proc/toggle_recolor(var/silent = 0)
	var/datum/species/slime/S = all_species[get_species()]
	if(!istype(S))
		if(!silent)
			to_chat(src, "You're not a slime person!")
		return

	if(src in S.recolor_list)
		S.recolor_list -= src
		if(!silent)
			to_chat(src, "You adjust your internal chemistry to filter out pigments from things you consume.")
	else
		S.recolor_list += src
		if(!silent)
			to_chat(src, "You adjust your internal chemistry to permit pigments in chemicals you consume to tint you.")

/mob/living/carbon/human/verb/toggle_recolor_verb()
	set category = "IC"
	set name = "Toggle Reagent Recoloring"
	set desc = "While active, you'll slowly adjust your body's color to that of the reagents inside of you, moderated by how much blood you have."

	toggle_recolor()


/mob/living/carbon/human/proc/regrow_limbs()
	set category = "IC"
	set name = "Regrow Limbs"
	set desc = "Regrow one of your missing limbs at the cost of a large amount of hunger"

#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_REGROWTHDELAY 450 // 45 seconds

	if(stat || paralysis || stunned)
		to_chat(src, "<span class='warning'>You cannot regenerate missing limbs in your current state.</span>")
		return

	if(nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(src, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
		return

	var/list/missing_limbs = list()
	for(var/l in bodyparts_by_name)
		var/obj/item/organ/external/E = bodyparts_by_name[l]
		if(!istype(E))
			var/list/limblist = species.has_limbs[l]
			var/obj/item/organ/external/limb = limblist["path"]
			var/parent_organ = initial(limb.parent_organ)
			var/obj/item/organ/external/parentLimb = bodyparts_by_name[parent_organ]
			if(!istype(parentLimb))
				continue
			missing_limbs[initial(limb.name)] = l

	if(!missing_limbs.len)
		to_chat(src, "<span class='warning'>You're not missing any limbs!</span>")
		return

	var/limb_select = input(src, "Choose a limb to regrow", "Limb Regrowth") as null|anything in missing_limbs
	var/chosen_limb = missing_limbs[limb_select]

	visible_message("<span class='notice'>[src] begins to hold still and concentrate on their missing [limb_select]...</span>", "<span class='notice'>You begin to focus on regrowing your missing [limb_select]... (This will take [round(SLIMEPERSON_REGROWTHDELAY/10)] seconds, and you must hold still.)</span>")
	if(do_after(src, SLIMEPERSON_REGROWTHDELAY, needhand=0, target = src))
		if(stat || paralysis || stunned)
			to_chat(src, "<span class='warning'>You cannot regenerate missing limbs in your current state.</span>")
			return

		if(nutrition < SLIMEPERSON_MINHUNGER)
			to_chat(src, "<span class='warning'>You're too hungry to regenerate a limb!</span>")
			return

		var/obj/item/organ/external/O = bodyparts_by_name[chosen_limb]

		var/stored_brute = 0
		var/stored_burn = 0
		if(istype(O))
			to_chat(src, "<span class='warning'>You distribute the damaged tissue around your body, out of the way of your new pseudopod!</span>")
			var/obj/item/organ/external/doomedStump = O
			stored_brute = doomedStump.brute_dam
			stored_burn = doomedStump.burn_dam
			qdel(O)

		var/limb_list = species.has_limbs[chosen_limb]
		var/obj/item/organ/external/limb_path = limb_list["path"]
		// Parent check
		var/obj/item/organ/external/potential_parent = bodyparts_by_name[initial(limb_path.parent_organ)]
		if(!istype(potential_parent))
			to_chat(src, "<span class='danger'>You've lost the organ that you've been growing your new part on!</span>")
			return // No rayman for you
		// Grah this line will leave a "not used" warning, in spite of the fact that the new() proc WILL do the thing.
		// Bothersome.
		var/obj/item/organ/external/new_limb = new limb_path(src)
		new_limb.open = 0 // This is just so that the compiler won't think that new_limb is unused, because the compiler is horribly stupid.
		adjustBruteLoss(stored_brute)
		adjustFireLoss(stored_burn)
		update_body()
		updatehealth()
		UpdateDamageIcon()
		nutrition -= SLIMEPERSON_HUNGERCOST
		visible_message("<span class='notice'>[src] finishes regrowing their missing [new_limb]!</span>", "<span class='notice'>You finish regrowing your [limb_select]</span>")
	else
		to_chat(src, "<span class='warning'>You need to hold still in order to regrow a limb!</span>")
	return

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY

/datum/species/slime/handle_pre_change(var/mob/living/carbon/human/H)
	..()
	if(H in recolor_list)
		H.toggle_recolor(silent = 1)

/datum/species/grey
	name = "Grey"
	name_plural = "Greys"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	default_language = "Galactic Common"
	language = "Psionic Communication"
	eyes = "grey_eyes_s"
	butt_sprite = "grey"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/grey,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain/grey,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/grey //5 darksight.
		)

	brute_mod = 1.25 //greys are fragile

	default_genes = list(REMOTE_TALK)


	species_traits = list(LIPS, IS_WHITELISTED, CAN_BE_FAT)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags =  HAS_BODY_MARKINGS
	dietflags = DIET_HERB
	reagent_tag = PROCESS_ORG
	blood_color = "#A200FF"

/datum/species/grey/handle_dna(var/mob/living/carbon/C, var/remove)
	if(!remove)
		C.dna.SetSEState(REMOTETALKBLOCK,1,1)
		genemutcheck(C,REMOTETALKBLOCK,null,MUTCHK_FORCED)
	else
		C.dna.SetSEState(REMOTETALKBLOCK,0,1)
		genemutcheck(C,REMOTETALKBLOCK,null,MUTCHK_FORCED)
	..()

/datum/species/grey/water_act(var/mob/living/carbon/C, volume, temperature, source)
	..()
	C.take_organ_damage(5,min(volume,20))
	C.emote("scream")

/datum/species/grey/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	var/speech_pref = H.client.prefs.speciesprefs
	if(speech_pref)
		H.mind.speech_span = "wingdings"

/datum/species/grey/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	if(R.id == "sacid")
		H.reagents.del_reagent(R.id)
		return 0
	return ..()

/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	path = /mob/living/carbon/human/diona
	default_language = "Galactic Common"
	language = "Rootspeak"
	speech_sounds = list('sound/voice/dionatalk1.ogg') //Credit https://www.youtube.com/watch?v=ufnvlRjsOTI [0:13 - 0:16]
	speech_chance = 20
	unarmed_type = /datum/unarmed_attack/diona
	//primitive_form = "Nymph"
	slowdown = 5
	remains_type = /obj/effect/decal/cleanable/ash


	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange space-dwelling collective \
	species hailing from Epsilon Ursae Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; \
	there is no effective upper limit to the number that can fuse in gestalt, and reports exist	of the Epsilon Ursae \
	Minoris primary being ringed with a cloud of singing space-station-sized entities.<br/><br/>The Dionaea coexist peacefully with \
	all known species, especially the Skrell. Their communal mind makes them slow to react, and they have difficulty understanding \
	even the simplest concepts of other minds. Their alien physiology allows them survive happily off a diet of nothing but light, \
	water and other radiation."

	species_traits = list(NO_BREATHE, RADIMMUNE, IS_PLANT, NO_BLOOD, NO_PAIN)
	clothing_flags = HAS_SOCKS
	default_hair_colour = "#000000"
	dietflags = 0		//Diona regenerate nutrition in light and water, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	oxy_mod = 0

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		"nutrient channel" =   /obj/item/organ/internal/liver/diona,
		"neural strata" =      /obj/item/organ/internal/heart/diona,
		"receptor node" =      /obj/item/organ/internal/eyes/diona, //Default darksight of 2.
		"gas bladder" =        /obj/item/organ/internal/brain/diona,
		"polyp segment" =      /obj/item/organ/internal/kidneys/diona,
		"anchoring ligament" = /obj/item/organ/internal/appendix/diona
		)

	vision_organ = /obj/item/organ/internal/eyes/diona
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/diona),
		"groin" =  list("path" = /obj/item/organ/external/groin/diona),
		"head" =   list("path" = /obj/item/organ/external/head/diona),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/diona),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/diona),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/diona),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/diona),
		"l_hand" = list("path" = /obj/item/organ/external/hand/diona),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/diona),
		"l_foot" = list("path" = /obj/item/organ/external/foot/diona),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/diona)
		)

	suicide_messages = list(
		"is losing branches!",
		"pulls out a secret stash of herbicide and takes a hearty swig!",
		"is pulling themselves apart!")

/datum/species/diona/can_understand(var/mob/other)
	if(istype(other, /mob/living/simple_animal/diona))
		return 1
	return 0

/datum/species/diona/handle_post_spawn(var/mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/datum/species/diona/handle_life(var/mob/living/carbon/human/H)
	H.radiation = Clamp(H.radiation, 0, 100) //We have to clamp this first, then decrease it, or there's a few edge cases of massive heals if we clamp and decrease at the same time.
	var/rads = H.radiation / 25
	H.radiation = max(H.radiation-rads, 0)
	H.nutrition = min(H.nutrition+rads, NUTRITION_LEVEL_WELL_FED+10)
	H.adjustBruteLoss(-(rads))
	H.adjustToxLoss(-(rads))

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(T.get_lumcount() * 10, 5)  //hardcapped so it's not abused by having a ton of flashlights
	H.nutrition = min(H.nutrition+light_amount, NUTRITION_LEVEL_WELL_FED+10)

	if(light_amount > 0)
		H.clear_alert("nolight")
	else
		H.throw_alert("nolight", /obj/screen/alert/nolight)

	if((light_amount >= 5) && !H.suiciding) //if there's enough light, heal

		H.adjustBruteLoss(-(light_amount/2))
		H.adjustFireLoss(-(light_amount/4))
	if(H.nutrition < NUTRITION_LEVEL_STARVING+50)
		H.take_overall_damage(10,0)
	..()

/datum/species/machine
	name = "Machine"
	name_plural = "Machines"

	blurb = "Positronic intelligence really took off in the 26th century, and it is not uncommon to see independant, free-willed \
	robots on many human stations, particularly in fringe systems where standards are slightly lax and public opinion less relevant \
	to corporate operations. IPCs (Integrated Positronic Chassis) are a loose category of self-willed robots with a humanoid form, \
	generally self-owned after being 'born' into servitude; they are reliable and dedicated workers, albeit more than slightly \
	inhuman in outlook and perspective."

	icobase = 'icons/mob/human_races/r_machine.dmi'
	deform = 'icons/mob/human_races/r_machine.dmi'
	path = /mob/living/carbon/human/machine
	default_language = "Galactic Common"
	language = "Trinary"
	remains_type = /obj/effect/decal/remains/robot

	eyes = "blank_eyes"
	brute_mod = 2.5 // 100% * 2.5 * 0.6 (robolimbs) ~= 150%
	burn_mod = 2.5  // So they take 50% extra damage from brute/burn overall.
	tox_mod = 0
	clone_mod = 0
	oxy_mod = 0
	death_message = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off..."

	species_traits = list(IS_WHITELISTED, NO_BREATHE, NO_SCAN, NO_BLOOD, NO_PAIN, NO_DNA, RADIMMUNE, VIRUSIMMUNE, NOTRANSSTING)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_HEAD_MARKINGS | HAS_HEAD_ACCESSORY | ALL_RPARTS
	dietflags = 0		//IPCs can't eat, so no diet
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE
	blood_color = "#1F181F"
	flesh_color = "#AAAAAA"
	//Default styles for created mobs.
	default_hair = "Blue IPC Screen"
	can_revive_by_healing = 1
	has_gender = FALSE
	reagent_tag = PROCESS_SYN
	male_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	female_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	male_cough_sounds = list('sound/effects/mob_effects/m_machine_cougha.ogg','sound/effects/mob_effects/m_machine_coughb.ogg', 'sound/effects/mob_effects/m_machine_coughc.ogg')
	female_cough_sounds = list('sound/effects/mob_effects/f_machine_cougha.ogg','sound/effects/mob_effects/f_machine_coughb.ogg')
	male_sneeze_sound = 'sound/effects/mob_effects/machine_sneeze.ogg'
	female_sneeze_sound = 'sound/effects/mob_effects/f_machine_sneeze.ogg'
	butt_sprite = "machine"

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/mmi_holder/posibrain,
		"cell" = /obj/item/organ/internal/cell,
		"optics" = /obj/item/organ/internal/eyes/optical_sensor, //Default darksight of 2.
		"charger" = /obj/item/organ/internal/cyberimp/arm/power_cord
		)

	vision_organ = /obj/item/organ/internal/eyes/optical_sensor
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/ipc),
		"groin" =  list("path" = /obj/item/organ/external/groin/ipc),
		"head" =   list("path" = /obj/item/organ/external/head/ipc),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/ipc),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/ipc),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/ipc),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/ipc),
		"l_hand" = list("path" = /obj/item/organ/external/hand/ipc),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/ipc),
		"l_foot" = list("path" = /obj/item/organ/external/foot/ipc),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/ipc)
		)

	suicide_messages = list(
		"is powering down!",
		"is smashing their own monitor!",
		"is twisting their own neck!",
		"is downloading extra RAM!",
		"is frying their own circuits!",
		"is blocking their ventilation port!")

	species_abilities = list(
		/mob/living/carbon/human/proc/change_monitor
		)

/datum/species/machine/handle_death(var/mob/living/carbon/human/H)
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(!head_organ)
		return
	head_organ.h_style = "Bald"
	head_organ.f_style = "Shaved"
	spawn(100)
		if(H)
			H.update_hair()
			H.update_fhair()

/datum/species/drask
	name = "Drask"
	name_plural = "Drask"
	icobase = 'icons/mob/human_races/r_drask.dmi'
	deform = 'icons/mob/human_races/r_drask.dmi'
	path = /mob/living/carbon/human/drask
	default_language = "Galactic Common"
	language = "Orluum"
	eyes = "drask_eyes_s"

	speech_sounds = list('sound/voice/DraskTalk.ogg')
	speech_chance = 20
	male_scream_sound = 'sound/voice/DraskTalk2.ogg'
	female_scream_sound = 'sound/voice/DraskTalk2.ogg'
	male_cough_sounds = 'sound/voice/DraskCough.ogg'
	female_cough_sounds = 'sound/voice/DraskCough.ogg'
	male_sneeze_sound = 'sound/voice/DraskSneeze.ogg'
	female_sneeze_sound = 'sound/voice/DraskSneeze.ogg'

	burn_mod = 2
	//exotic_blood = "cryoxadone"
	body_temperature = 273

	blurb = "Hailing from Hoorlm, planet outside what is usually considered a habitable \
	orbit, the Drask evolved to live in extreme cold. Their strange bodies seem \
	to operate better the colder their surroundings are, and can regenerate rapidly \
	when breathing supercooled gas. <br/><br/> On their homeworld, the Drask live long lives \
	in their labyrinthine settlements, carved out beneath Hoorlm's icy surface, where the air \
	is of breathable density."

	suicide_messages = list(
		"is self-warming with friction!",
		"is jamming fingers through their big eyes!",
		"is sucking in warm air!",
		"is holding their breath!")

	species_traits = list(LIPS, IS_WHITELISTED)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	dietflags = DIET_OMNI

	cold_level_1 = -1 //Default 260 - Lower is better
	cold_level_2 = -1 //Default 200
	cold_level_3 = -1 //Default 120
	coldmod = -1

	heat_level_1 = 300 //Default 360 - Higher is better
	heat_level_2 = 340 //Default 400
	heat_level_3 = 400 //Default 460
	heatmod = 2

	flesh_color = "#a3d4eb"
	reagent_tag = PROCESS_ORG
	base_color = "#a3d4eb"
	blood_color = "#a3d4eb"
	butt_sprite = "drask"

	has_organ = list(
		"heart" =      				/obj/item/organ/internal/heart/drask,
		"lungs" =     				/obj/item/organ/internal/lungs/drask,
		"metabolic strainer" =      /obj/item/organ/internal/liver/drask,
		"eyes" =     				/obj/item/organ/internal/eyes/drask, //5 darksight.
		"brain" =  					/obj/item/organ/internal/brain/drask
		)