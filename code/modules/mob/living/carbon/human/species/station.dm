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
	bodyflags = FEET_CLAWS | HAS_TAIL | HAS_SKIN_COLOR | TAIL_WAGGING
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

/datum/species/unathi/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/unathi/equip(var/mob/living/carbon/human/H)
	if(H.mind.assigned_role != "Clown")
		H.unEquip(H.shoes)
		H.equip_or_collect(new /obj/item/clothing/shoes/sandal(H), slot_shoes)

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
	bodyflags = FEET_PADDED | HAS_TAIL | HAS_SKIN_COLOR | TAIL_WAGGING
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	flesh_color = "#AFA59E"
	base_color = "#333333"

/datum/species/tajaran/handle_death(var/mob/living/carbon/human/H)
	H.stop_tail_wagging(1)

/datum/species/tajaran/equip(var/mob/living/carbon/human/H)
	if(H.mind.assigned_role != "Clown")
		H.unEquip(H.shoes)
		H.equip_or_collect(new /obj/item/clothing/shoes/sandal(H), slot_shoes)

/datum/species/vulpkanin
	name = "Vulpkanin"
	name_plural = "Vulpakanin"
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
	bodyflags = FEET_PADDED | HAS_TAIL | HAS_SKIN_COLOR | TAIL_WAGGING
	dietflags = DIET_OMNI
	reagent_tag = PROCESS_ORG
	flesh_color = "#966464"
	base_color = "#BE8264"

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
	reagent_tag = PROCESS_ORG

/datum/species/vox
	name = "Vox"
	name_plural = "Vox"
	icobase = 'icons/mob/human_races/r_vox.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	path = /mob/living/carbon/human/vox

	default_language = "Galactic Common"
	language = "Vox-pidgin"
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

	eyes = "vox_eyes_s"

	breath_type = "nitrogen"
	poison_type = "oxygen"

	flags = NO_SCAN | IS_WHITELISTED
	clothing_flags = HAS_SOCKS
	dietflags = DIET_OMNI

	blood_color = "#2299FC"
	flesh_color = "#808D11"

	reagent_tag = PROCESS_ORG

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
	H << "<span class='notice'>You are now running on nitrogen internals from the [H.l_hand] in your hand. Your species finds oxygen toxic, so you must breathe nitrogen only.</span>"
	H.internal = H.l_hand
	if (H.internals)
		H.internals.icon_state = "internal1"

/*
/datum/species/vox/handle_post_spawn(var/mob/living/carbon/human/H)
	H.verbs += /mob/living/carbon/human/proc/leap
	..() */

/datum/species/vox/armalis/handle_post_spawn(var/mob/living/carbon/human/H)
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
		"heart" =    /obj/item/organ/heart,
		"lungs" =    /obj/item/organ/lungs,
		"liver" =    /obj/item/organ/liver,
		"kidneys" =  /obj/item/organ/kidneys,
		"brain" =    /obj/item/organ/brain,
		"eyes" =     /obj/item/organ/eyes,
		"stack" =    /obj/item/organ/stack/vox
		)

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
	dietflags = DIET_HERB
	blood_color = "#FB9800"
	reagent_tag = PROCESS_ORG

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	default_language = "Galactic Common"
	language = "Bubblish"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	path = /mob/living/carbon/human/slime
	unarmed_type = /datum/unarmed_attack/punch

	flags = IS_WHITELISTED | NO_BREATHE | HAS_LIPS | NO_INTORGANS | NO_SCAN
	clothing_flags = HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	dietflags = DIET_CARN
	reagent_tag = PROCESS_ORG
	exotic_blood = "water"
	//ventcrawler = 1 //ventcrawling commented out

	has_organ = list(
		"brain" = /obj/item/organ/brain/slime
		)

/datum/species/grey
	name = "Grey"
	name_plural = "Greys"
	icobase = 'icons/mob/human_races/r_grey.dmi'
	deform = 'icons/mob/human_races/r_def_grey.dmi'
	default_language = "Galactic Common"
	//language = "Grey" // Perhaps if they ever get a hivemind
	unarmed_type = /datum/unarmed_attack/punch
	darksight = 5 // BOOSTED from 2
	eyes = "grey_eyes_s"

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
	C.mutations.Add(GREY)
	C.update_mutations()
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

	flags = NO_BREATHE | REQUIRE_LIGHT | IS_PLANT | RAD_ABSORB | NO_BLOOD | NO_PAIN
	clothing_flags = HAS_SOCKS
	dietflags = 0		//Diona regenerate nutrition in light, no diet necessary

	body_temperature = T0C + 15		//make the plant people have a bit lower body temperature, why not
	blood_color = "#004400"
	flesh_color = "#907E4A"

	reagent_tag = PROCESS_ORG

	has_organ = list(
		"nutrient channel" =   /obj/item/organ/diona/nutrients,
		"neural strata" =      /obj/item/organ/diona/strata,
		"response node" =      /obj/item/organ/diona/node,
		"gas bladder" =        /obj/item/organ/diona/bladder,
		"polyp segment" =      /obj/item/organ/diona/polyp,
		"anchoring ligament" = /obj/item/organ/diona/ligament
		)

	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/diona/chest),
		"groin" =  list("path" = /obj/item/organ/external/diona/groin),
		"head" =   list("path" = /obj/item/organ/external/diona/head),
		"l_arm" =  list("path" = /obj/item/organ/external/diona/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/diona/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/diona/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/diona/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/diona/hand),
		"r_hand" = list("path" = /obj/item/organ/external/diona/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/diona/foot),
		"r_foot" = list("path" = /obj/item/organ/external/diona/foot/right)
		)

/datum/species/diona/can_understand(var/mob/other)
	var/mob/living/simple_animal/diona/D = other
	if(istype(D))
		return 1
	return 0

/datum/species/diona/handle_post_spawn(var/mob/living/carbon/human/H)
	H.gender = NEUTER

	return ..()

/*        //overpowered and dumb as hell; they get cloning back, though.
/datum/species/diona/handle_death(var/mob/living/carbon/human/H)

	var/mob/living/simple_animal/diona/S = new(get_turf(H))

	if(H.mind)
		H.mind.transfer_to(S)
	else
		S.key = H.key

	for(var/mob/living/simple_animal/diona/D in H.contents)
		if(D.client)
			D.loc = H.loc
		else
			qdel(D)

	H.visible_message("<span class='danger">[H] splits apart with a wet slithering noise!"</span>) */

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

	eyes = "blank_eyes"
	brute_mod = 2.5 // 100% * 2.5 * 0.6 (robolimbs) ~= 150%
	burn_mod = 2.5  // So they take 50% extra damage from brute/burn overall.
	death_message = "gives one shrill beep before falling limp, their monitor flashing blue before completely shutting off..."

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500		//gives them about 25 seconds in space before taking damage
	heat_level_2 = 540
	heat_level_3 = 600
	heat_level_3_breathe = 600

	passive_temp_gain = 10 //this should cause IPCs to stabilize at ~80 C in a 20 C environment.

	flags = IS_WHITELISTED | NO_BREATHE | NO_SCAN | NO_BLOOD | NO_PAIN | NO_DNA_RAD | NO_POISON
	clothing_flags = HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR
	dietflags = 0		//IPCs can't eat, so no diet
	blood_color = "#1F181F"
	flesh_color = "#AAAAAA"
	virus_immune = 1
	can_revive_by_healing = 1
	reagent_tag = PROCESS_SYN

	has_organ = list(
		"brain" = /obj/item/organ/mmi_holder/posibrain,
		"cell" = /obj/item/organ/cell,
		"optics" = /obj/item/organ/optical_sensor
		)

	vision_organ = "optics"
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

/datum/species/machine/handle_death(var/mob/living/carbon/human/H)
	H.h_style = ""
	spawn(100)
		if(H) H.update_hair()

/datum/species/machine/handle_post_spawn(var/mob/living/carbon/human/H)
	..()
	H.verbs += /mob/living/carbon/human/proc/change_monitor
