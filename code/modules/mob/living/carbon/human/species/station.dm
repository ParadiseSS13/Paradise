/datum/species/human
	name = "Human"
	name_plural = "Humans"
	icobase = 'icons/mob/human_races/r_human.dmi'
	deform = 'icons/mob/human_races/r_def_human.dmi'
	primitive_form = "Monkey"
	path = /mob/living/carbon/human/human
	language = "Sol Common"
	flags = HAS_LIPS | CAN_BE_FAT
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_TONE
	dietflags = DIET_OMNI
	unarmed_type = /datum/unarmed_attack/punch
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	reagent_tag = PROCESS_ORG

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
	darksight = 3

	blurb = "A heavily reptillian species, Unathi (or 'Sinta as they call themselves) hail from the \
	Uuosa-Eso system, which roughly translates to 'burning mother'.<br/><br/>Coming from a harsh, radioactive \
	desert planet, they mostly hold ideals of honesty, virtue, martial combat and bravery above all \
	else, frequently even their own lives. They prefer warmer temperatures than most species and \
	their native tongue is a heavy hissing laungage called Sinta'Unathi."

	flags = HAS_LIPS
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = FEET_CLAWS | HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING
	dietflags = DIET_CARN

	cold_level_1 = 280 //Default 260 - Lower is better
	cold_level_2 = 220 //Default 200
	cold_level_3 = 140 //Default 120

	heat_level_1 = 380 //Default 360 - Higher is better
	heat_level_2 = 420 //Default 400
	heat_level_3 = 480 //Default 460
	heat_level_3_breathe = 1100 //Default 1000

	flesh_color = "#34AF10"
	reagent_tag = PROCESS_ORG
	base_color = "#066000"
	//Default styles for created mobs.
	default_hair = "Unathi Horns"
	butt_sprite = "unathi"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/unathi,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken,
								 /mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

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
	darksight = 8

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
	heat_level_3_breathe = 900

	primitive_form = "Farwa"

	flags = HAS_LIPS | CAN_BE_FAT
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = FEET_PADDED | HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING | HAS_FUR
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	flesh_color = "#AFA59E"
	base_color = "#333333"
	//Default styles for created mobs.
	default_headacc = "Tajaran Ears"
	butt_sprite = "tajaran"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/tajaran,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
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
	darksight = 8

	blurb = "Vulpkanin are a species of sharp-witted canine-pideds residing on the planet Altam just barely within the \
	dual-star Vazzend system. Their politically de-centralized society and independent natures have led them to become a species and \
	culture both feared and respected for their scientific breakthroughs. Discovery, loyalty, and utilitarianism dominates their lifestyles \
	to the degree it can cause conflict with more rigorous and strict authorities. They speak a guttural language known as 'Canilunzt' \
    which has a heavy emphasis on utilizing tail positioning and ear twitches to communicate intent."

	flags = HAS_LIPS
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = FEET_PADDED | HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING | HAS_FUR
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	flesh_color = "#966464"
	base_color = "#B43214"
	butt_sprite = "vulp"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/vulpkanin,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
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
	unarmed_type = /datum/unarmed_attack/punch

	blurb = "An amphibious species, Skrell come from the star system known as Qerr'Vallis, which translates to 'Star of \
	the royals' or 'Light of the Crown'.<br/><br/>Skrell are a highly advanced and logical race who live under the rule \
	of the Qerr'Katish, a caste within their society which keeps the empire of the Skrell running smoothly. Skrell are \
	herbivores on the whole and tend to be co-operative with the other species of the galaxy, although they rarely reveal \
	the secrets of their empire to their allies."

	flags = HAS_LIPS
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR
	dietflags = DIET_HERB
	flesh_color = "#8CD7A3"
	blood_color = "#1D2CBF"
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
		"eyes" =     /obj/item/organ/internal/eyes,
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

	warning_low_pressure = 50
	hazard_low_pressure = 0

	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	atmos_requirements = list(
		"min_oxy" = 0,
		"max_oxy" = 1,
		"min_nitro" = 16,
		"max_nitro" = 0,
		"min_tox" = 0,
		"max_tox" = 0.005,
		"min_co2" = 0,
	 	"max_co2" = 10,
	 	"sa_para" = 1,
		"sa_sleep" = 5
		)

	eyes = "vox_eyes_s"

	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = NO_SCAN | IS_WHITELISTED
	clothing_flags = HAS_SOCKS
	dietflags = DIET_OMNI
	bodyflags = HAS_ICON_SKIN_TONE | HAS_TAIL | TAIL_WAGGING | TAIL_OVERLAPPED

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
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/vox,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
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

/datum/species/vox/equip(var/mob/living/carbon/human/H)
	if(H.mind.assigned_role != "Clown" && H.mind.assigned_role != "Mime")
		H.unEquip(H.wear_mask)
	H.unEquip(H.l_hand)

	H.equip_or_collect(new /obj/item/clothing/mask/breath/vox(H), slot_wear_mask)
	var/tank_pref = H.client.prefs.speciesprefs
	if(tank_pref)//Diseasel, here you go
		H.equip_or_collect(new /obj/item/weapon/tank/nitrogen(H), slot_l_hand)
	else
		H.equip_or_collect(new /obj/item/weapon/tank/emergency_oxygen/vox(H), slot_l_hand)
	to_chat(H, "<span class='notice'>You are now running on nitrogen internals from the [H.l_hand] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>")
	H.internal = H.l_hand
	H.update_internals_hud_icon(1)

/datum/species/vox/handle_post_spawn(var/mob/living/carbon/human/H)
	updatespeciescolor(H)
	H.update_icons()
	//H.verbs += /mob/living/carbon/human/proc/leap
	..()

/datum/species/vox/updatespeciescolor(var/mob/living/carbon/human/H) //Handling species-specific skin-tones for the Vox race.
	if(H.species.name == "Vox") //Making sure we don't break Armalis.
		switch(H.s_tone)
			if(6) //Azure Vox.
				icobase = 'icons/mob/human_races/vox/r_voxazu.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxazu.dmi'
				tail = "voxtail_azu"
			if(5) //Emerald Vox.
				icobase = 'icons/mob/human_races/vox/r_voxemrl.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxemrl.dmi'
				tail = "voxtail_emrl"
			if(4) //Grey Vox.
				icobase = 'icons/mob/human_races/vox/r_voxgry.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxgry.dmi'
				tail = "voxtail_gry"
			if(3) //Brown Vox.
				icobase = 'icons/mob/human_races/vox/r_voxbrn.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxbrn.dmi'
				tail = "voxtail_brn"
			if(2) //Dark Green Vox.
				icobase = 'icons/mob/human_races/vox/r_voxdgrn.dmi'
				deform = 'icons/mob/human_races/vox/r_def_voxdgrn.dmi'
				tail = "voxtail_dgrn"
			else  //Default Green Vox.
				icobase = 'icons/mob/human_races/vox/r_vox.dmi'
				deform = 'icons/mob/human_races/vox/r_def_vox.dmi'
				tail = "voxtail" //Ensures they get an appropriately coloured tail depending on the skin-tone.

		H.update_dna()

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
	heat_level_3_breathe = 4000

	brute_mod = 0.2
	burn_mod = 0.2

	eyes = "blank_eyes"
	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = NO_SCAN | NO_BLOOD | HAS_TAIL | NO_PAIN | IS_WHITELISTED
	dietflags = DIET_OMNI	//should inherit this from vox, this is here just in case

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = PROCESS_ORG

	tail = "armalis_tail"
	icon_template = 'icons/mob/human_races/r_armalis.dmi'

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"eyes" =     /obj/item/organ/internal/eyes,
		"stack" =    /obj/item/organ/internal/stack/vox //Not the same as the cortical stack implant Vox Raiders spawn with. The cortical stack implant is used
		)												//for determining the success of the heist game-mode's 'leave nobody behind' objective, while this is just an organ.

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!",
		"is huffing oxygen!")

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

	flags = IS_WHITELISTED
	clothing_flags = HAS_SOCKS
	bodyflags = FEET_CLAWS
	eyes = "kidan_eyes"
	dietflags = DIET_HERB
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG
	butt_sprite = "kidan"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/kidan,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/diona)

	suicide_messages = list(
		"is attempting to bite their antenna off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	default_language = "Galactic Common"
	language = "Bubblish"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	path = /mob/living/carbon/human/slime
	unarmed_type = /datum/unarmed_attack/punch
	remains_type = /obj/effect/decal/remains/slime

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	cold_env_multiplier = 3

	flags = IS_WHITELISTED | NO_BREATHE | HAS_LIPS | NO_INTORGANS | NO_SCAN
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	dietflags = DIET_CARN
	reagent_tag = PROCESS_ORG
	exotic_blood = "water"
	//ventcrawler = 1 //ventcrawling commented out
	butt_sprite = "slime"

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/slime
		)

	suicide_messages = list(
		"is melting into a puddle!",
		"is ripping out their own core!",
		"is turning a dull, brown color and melting into a puddle!")

	var/list/mob/living/carbon/human/recolor_list = list()

	species_abilities = list(
		/mob/living/carbon/human/verb/toggle_recolor_verb,
		/mob/living/carbon/human/proc/regrow_limbs
		)

/datum/species/slime/handle_life(var/mob/living/carbon/human/H)
//This is allegedly for code "style". Like a plaid sweater?
#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.
	// Slowly shifting to the color of the reagents
	if((H in recolor_list) && H.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = H.vessel.total_volume
		var/r_color = mix_color_from_reagents(H.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, rgb(H.r_skin, H.g_skin, H.b_skin), (blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)/((blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)+(H.reagents.total_volume)))
		var/list/new_color_list = ReadRGB(new_body_color)
		H.r_skin = new_color_list[1]
		H.g_skin = new_color_list[2]
		H.b_skin = new_color_list[3]
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in H.organs_by_name)
				var/obj/item/organ/external/E = H.organs_by_name[organname]
				if(istype(E) && E.dna.species == "Slime People")
					E.sync_colour_to_human(H)
			H.update_hair(0)
			H.update_body()
	return ..()

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
	for(var/l in organs_by_name)
		var/obj/item/organ/external/E = organs_by_name[l]
		if(!istype(E) || istype(E, /obj/item/organ/external/stump))
			var/list/limblist = species.has_limbs[l]
			var/obj/item/organ/external/limb = limblist["path"]
			var/parent_organ = initial(limb.parent_organ)
			var/obj/item/organ/external/parentLimb = organs_by_name[parent_organ]
			if(!istype(parentLimb) || parentLimb.is_stump())
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

		var/obj/item/organ/external/O = organs_by_name[chosen_limb]

		var/stored_brute = 0
		var/stored_burn = 0
		if(istype(O))
			if(!O.is_stump())
				to_chat(src, "<span class='warning'>Your limb has already been replaced in some way!</span>")
				return
			else
				to_chat(src, "<span class='warning'>You distribute the damaged tissue around your body, out of the way of your new pseudopod!</span>")
				var/obj/item/organ/external/doomedStump = O
				stored_brute = doomedStump.brute_dam
				stored_burn = doomedStump.burn_dam
				qdel(O)

		var/limb_list = species.has_limbs[chosen_limb]
		var/obj/item/organ/external/limb_path = limb_list["path"]
		// Parent check
		var/obj/item/organ/external/potential_parent = organs_by_name[initial(limb_path.parent_organ)]
		if(!istype(potential_parent) || potential_parent.is_stump())
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
	unarmed_type = /datum/unarmed_attack/punch
	darksight = 5 // BOOSTED from 2
	eyes = "grey_eyes_s"
	butt_sprite = "grey"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart,
		"lungs" =    /obj/item/organ/internal/lungs,
		"liver" =    /obj/item/organ/internal/liver/grey,
		"kidneys" =  /obj/item/organ/internal/kidneys,
		"brain" =    /obj/item/organ/internal/brain/grey,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes,
		)

	brute_mod = 1.25 //greys are fragile

	default_genes = list(REMOTE_TALK)


	flags = IS_WHITELISTED | HAS_LIPS | CAN_BE_FAT
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	dietflags = DIET_HERB
	reagent_tag = PROCESS_ORG
	blood_color = "#A200FF"

/datum/species/grey/handle_dna(var/mob/living/carbon/C, var/remove)
	if(!remove)
		C.dna.SetSEState(REMOTETALKBLOCK,1,1)
		C.mutations |= REMOTE_TALK
		genemutcheck(C,REMOTETALKBLOCK,null,MUTCHK_FORCED)
	else
		C.dna.SetSEState(REMOTETALKBLOCK,0,1)
		C.mutations -= REMOTE_TALK
		genemutcheck(C,REMOTETALKBLOCK,null,MUTCHK_FORCED)
	..()

/datum/species/diona
	name = "Diona"
	name_plural = "Dionaea"
	icobase = 'icons/mob/human_races/r_diona.dmi'
	deform = 'icons/mob/human_races/r_def_plant.dmi'
	path = /mob/living/carbon/human/diona
	default_language = "Galactic Common"
	language = "Rootspeak"
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
	heat_level_3_breathe = 700

	blurb = "Commonly referred to (erroneously) as 'plant people', the Dionaea are a strange space-dwelling collective \
	species hailing from Epsilon Ursae Minoris. Each 'diona' is a cluster of numerous cat-sized organisms called nymphs; \
	there is no effective upper limit to the number that can fuse in gestalt, and reports exist	of the Epsilon Ursae \
	Minoris primary being ringed with a cloud of singing space-station-sized entities.<br/><br/>The Dionaea coexist peacefully with \
	all known species, especially the Skrell. Their communal mind makes them slow to react, and they have difficulty understanding \
	even the simplest concepts of other minds. Their alien physiology allows them survive happily off a diet of nothing but light, \
	water and other radiation."

	flags = NO_BREATHE | RADIMMUNE | IS_PLANT | NO_BLOOD | NO_PAIN
	clothing_flags = HAS_SOCKS
	dietflags = 0		//Diona regenerate nutrition in light, no diet necessary

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	blood_color = "#004400"
	flesh_color = "#907E4A"
	butt_sprite = "diona"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		"nutrient channel" =   /obj/item/organ/internal/liver/diona,
		"neural strata" =      /obj/item/organ/internal/heart/diona,
		"receptor node" =      /obj/item/organ/internal/diona_receptor,
		"gas bladder" =        /obj/item/organ/internal/brain/diona,
		"polyp segment" =      /obj/item/organ/internal/kidneys/diona,
		"anchoring ligament" = /obj/item/organ/internal/appendix/diona
		)

	vision_organ = /obj/item/organ/internal/diona_receptor
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
	var/rads = H.radiation/25
	H.radiation = Clamp(H.radiation - rads, 0, 100)
	H.nutrition += rads
	H.adjustBruteLoss(-(rads))
	H.adjustOxyLoss(-(rads))
	H.adjustToxLoss(-(rads))

	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(T.get_lumcount()*10, 5)  //hardcapped so it's not abused by having a ton of flashlights
	H.nutrition += light_amount
	H.traumatic_shock -= light_amount

	if(H.nutrition > 450)
		H.nutrition = 450

	if((light_amount >= 5) && !H.suiciding) //if there's enough light, heal
		H.adjustBruteLoss(-(light_amount/2))
		H.adjustFireLoss(-(light_amount/4))
		H.adjustOxyLoss(-(light_amount))

	if(H.nutrition < 200)
		H.take_overall_damage(10,0)
		H.traumatic_shock++

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
	unarmed_type = /datum/unarmed_attack/punch
	remains_type = /obj/effect/decal/remains/robot

	eyes = "blank_eyes"
	brute_mod = 2.5 // 100% * 2.5 * 0.6 (robolimbs) ~= 150%
	burn_mod = 2.5  // So they take 50% extra damage from brute/burn overall.
	death_message = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off..."

	flags = IS_WHITELISTED | NO_BREATHE | NO_SCAN | NO_BLOOD | NO_PAIN | NO_DNA | NO_POISON | RADIMMUNE | ALL_RPARTS
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | HAS_MARKINGS | HAS_HEAD_ACCESSORY
	dietflags = 0		//IPCs can't eat, so no diet
	blood_color = "#1F181F"
	flesh_color = "#AAAAAA"
	//Default styles for created mobs.
	default_hair = "Blue IPC Screen"
	virus_immune = 1
	can_revive_by_healing = 1
	reagent_tag = PROCESS_SYN
	male_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	female_scream_sound = 'sound/goonstation/voice/robot_scream.ogg'
	butt_sprite = "machine"

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/mmi_holder/posibrain,
		"cell" = /obj/item/organ/internal/cell,
		"optics" = /obj/item/organ/internal/optical_sensor
		)

	vision_organ = /obj/item/organ/internal/optical_sensor
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
	head_organ.h_style = "Bald"
	head_organ.f_style = "Shaved"
	spawn(100)
		if(H)
			H.update_hair()
			H.update_fhair()
