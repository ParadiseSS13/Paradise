//List of different corpse types
// MARK: Syndicate
/obj/effect/mob_spawn/human/corpse/syndicate
	name = "Syndicate Operative"
	id_job = "err#unkwn"
	id_access_list = list(ACCESS_SYNDICATE)
	outfit = /datum/outfit/syndicatecorpse
	del_types = list()
	var/name_changed
	var/name_to_add
	var/num_to_add

/obj/effect/mob_spawn/human/corpse/syndicate/Initialize(mapload)
	if(!name_changed)
		name_to_add = pick("Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu")
		num_to_add = rand(1, 1337)
		mob_name = "[syndicate_name()] [name_to_add] #[num_to_add]"
		name_changed = TRUE
	brute_damage = rand(0, 200)
	var/hcolor = pick("#000000", "#8B4513", "#FFD700")
	var/ecolor = pick("#000000", "#8B4513", "#1E90FF")
	hair_color = hcolor
	facial_hair_color = hcolor
	eyes_color = ecolor
	skin_tone = pick(-50, -30, -10, 0, 0, 0, 10)
	return ..()

/datum/outfit/syndicatecorpse
	name = "Corpse of a Syndicate Operative"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/jacket/bomber/syndicate
	glasses = /obj/item/clothing/glasses/night/syndicate_fake
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset/syndicate_fake
	mask = /obj/item/clothing/mask/gas/syndicate
	head = /obj/item/clothing/head/helmet/swat/syndicate
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/utility/syndi_researcher
	box = /obj/item/storage/box/survival_syndie/traitor/loot
	l_pocket = /obj/item/tank/internals/emergency_oxygen/engi/syndi
	id = /obj/item/card/id/syndicate_fake
	pda = /obj/item/pda/syndicate_fake
	internals_slot = ITEM_SLOT_LEFT_POCKET
	var/modsuit
	var/armory_loot

/datum/outfit/syndicatecorpse/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(modsuit && prob(5))
		box = null
		head = null
		suit = null
		l_pocket = null
		back = modsuit
		suit_store = /obj/item/tank/internals/oxygen/red
		internals_slot = ITEM_SLOT_SUIT_STORE
	if(armory_loot)
		backpack_contents |= /obj/item/storage/box/syndie_kit/loot/elite
	else if(prob(50))
		backpack_contents |= /obj/item/storage/box/syndie_kit/loot

/datum/outfit/syndicatecorpse/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H?.w_uniform)
		var/obj/item/clothing/under/U = H.w_uniform
		var/obj/item/clothing/accessory/holster/W = new /obj/item/clothing/accessory/holster(U)
		U.accessories += W
		W.on_attached(U)

// MARK: Syndicate mod
/obj/effect/mob_spawn/human/corpse/syndicate/modsuit
	name = "Syndicate Commando"
	outfit = /datum/outfit/syndicatecorpse/modsuit

/obj/effect/mob_spawn/human/corpse/syndicate/modsuit/Initialize(mapload)
	if(!name_changed)
		name_to_add = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces", "Rose", "Peony", "Lily", "Daisy", "Zinnia", "Ivy", "Iris", "Petunia", "Violet", "Lilac", "Orchid")
		if(prob(95))
			num_to_add = pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
		mob_name = num_to_add ? "[syndicate_name()] [name_to_add] [num_to_add]" : "[syndicate_name()] [name_to_add]"
		name_changed = TRUE
	return ..()

/datum/outfit/syndicatecorpse/modsuit
	name = "Corpse of a Syndicate Commando"
	modsuit = /obj/item/mod/control/pre_equipped/traitor

// MARK: Syndicate elite mod
/obj/effect/mob_spawn/human/corpse/syndicate/modsuit/elite
	name = "Syndicate Overseer"
	outfit = /datum/outfit/syndicatecorpse/modsuit/elite

/obj/effect/mob_spawn/human/corpse/syndicate/modsuit/elite/Initialize(mapload)
	if(!name_changed)
		name_to_add = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord", "Berzerk", "Reaper", "Beast", "Hellwalker", "Slayer", "Oathbreaker", "Supreme Commander", "Overseer", "Butcher", "Executioner", "Judge", "Head of Shitcurity", "Unchained Predator", "Outlander", "DM1-5", "Scourge of Hell", "Doom")
		mob_name = "[syndicate_name()] [name_to_add]"
		name_changed = TRUE
	return ..()

/datum/outfit/syndicatecorpse/modsuit/elite
	name = "Corpse of a Syndicate Overseer"
	modsuit = /obj/item/mod/control/pre_equipped/traitor_elite
	armory_loot = TRUE

// MARK: Syndicate depot QM
/obj/effect/mob_spawn/human/corpse/syndicate/modsuit/elite/depot
	name = "Syndicate Quartermaster"
	outfit = /datum/outfit/syndicatecorpse/modsuit/elite/depot

/datum/outfit/syndicatecorpse/modsuit/elite/depot
	name = "Corpse of a Syndicate Quartermaster"
	armory_loot = FALSE

/obj/effect/mob_spawn/human/corpse/clown/corpse
	roundstart = TRUE

/obj/effect/mob_spawn/human/corpse/mime/corpse
	roundstart = TRUE

/obj/effect/mob_spawn/human/corpse/pirate
	name = "Pirate"
	mob_name = "Pirate"
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/piratecorpse

/datum/outfit/piratecorpse
	name = "Corpse of a Pirate"
	uniform = /obj/item/clothing/under/costume/pirate
	suit = /obj/item/clothing/suit/space/eva
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/helmet/space/eva
	back = /obj/item/tank/jetpack/carbondioxide

/obj/effect/mob_spawn/human/corpse/pirate/ranged
	name = "Pirate Gunner"
	mob_name = "Pirate Gunner"

/datum/outfit/piratecorpse/ranged
	name = "Corpse of a Pirate Gunner"

/obj/effect/mob_spawn/human/corpse/drakehound
	name = "Drakehound"
	mob_name = "Drakehound"
	mob_species = /datum/species/unathi
	outfit = /datum/outfit/drakehound

/datum/outfit/drakehound
	name = "Drakehound"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots

/obj/effect/mob_spawn/human/corpse/soviet
	name = "Soviet"
	mob_name = "Soviet"
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/sovietcorpse

/datum/outfit/sovietcorpse
	name = "Corpse of a Soviet"
	uniform = /obj/item/clothing/under/new_soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/sovietsidecap


/obj/effect/mob_spawn/human/corpse/soviet/ranged
	outfit = /datum/outfit/sovietcorpse/ranged

/datum/outfit/sovietcorpse/ranged
	name = "Corpse of a Ranged Soviet"
	suit = /obj/item/clothing/suit/sovietcoat

/obj/effect/mob_spawn/human/corpse/soviet_nian
	name = "Soviet Nian"
	mob_name = "Soviet Nian"
	mob_species = /datum/species/moth
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/soviet_nian

/datum/outfit/soviet_nian
	name = "Soviet Nian"
	uniform = /obj/item/clothing/under/new_soviet
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/ushanka
	r_pocket = /obj/item/reagent_containers/drinks/drinkingglass/shotglass
	l_pocket = /obj/item/reagent_containers/drinks/bottle/vodka

/obj/effect/mob_spawn/human/corpse/wizard
	name = "Corpse of a Space Wizard"
	outfit = /datum/outfit/wizardcorpse

/obj/effect/mob_spawn/human/corpse/wizard/officer/Initialize(mapload)
	mob_name = "[pick(GLOB.wizard_first)], [pick(GLOB.wizard_second)]"
	. = ..()

/datum/outfit/wizardcorpse
	name = "Corpse of a Space Wizard"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/wizard

/obj/effect/mob_spawn/human/corpse/seed_vault_diona
	name = "Corpse of a Diona"
	mob_species = /datum/species/diona
	outfit = /datum/outfit/seed_vault_diona

/datum/outfit/seed_vault_diona
	name = "Unknown Diona"
	uniform = /obj/item/clothing/under/rank/civilian/hydroponics
	belt = /obj/item/storage/bag/plants
	mask = /obj/item/clothing/mask/breath
	r_pocket = /obj/item/paper/crumpled/ruins/lavaland/seed_vault/discovery
	l_pocket = /obj/item/tank/internals/emergency_oxygen/engi/empty

