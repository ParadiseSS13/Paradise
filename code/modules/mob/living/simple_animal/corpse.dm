//List of different corpse types
/obj/effect/mob_spawn/human/corpse/syndicatesoldier
	name = "Syndicate Operative"
	mob_name = "Syndicate Operative"
	hair_style = "bald"
	facial_hair_style = "shaved"
	id_job = "Operative"
	id_access_list = list(ACCESS_SYNDICATE)
	outfit = /datum/outfit/syndicatesoldiercorpse

/datum/outfit/syndicatesoldiercorpse
	name = "Corpse of a Syndicate Operative"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id


/obj/effect/mob_spawn/human/corpse/syndicatecommando
	name = "Syndicate Commando"
	mob_name = "Syndicate Commando"
	hair_style = "bald"
	facial_hair_style = "shaved"
	id_job = "Operative"
	id_access_list = list(ACCESS_SYNDICATE)
	outfit = /datum/outfit/syndicatecommandocorpse

/datum/outfit/syndicatecommandocorpse
	name = "Corpse of a Syndicate Commando"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/mod/control/pre_equipped/traitor
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id

/obj/effect/mob_spawn/human/corpse/syndicatequartermaster
	name = "Syndicate Quartermaster"
	mob_name = "Syndicate Quartermaster"
	hair_style = "bald"
	facial_hair_style = "shaved"
	id_job = "Operative"
	id_access_list = list(ACCESS_SYNDICATE)
	outfit = /datum/outfit/syndicatequartermastercorpse

/datum/outfit/syndicatequartermastercorpse
	name = "Corpse of a Syndicate Quartermaster"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id

/obj/effect/mob_spawn/human/corpse/clown/corpse
	roundstart = TRUE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/mime/corpse
	roundstart = TRUE
	instant = TRUE

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
	outfit = /datum/outfit/piratecorpse

/datum/outfit/piratecorpse/ranged
	name = "Corpse of a Pirate Gunner"


/obj/effect/mob_spawn/human/corpse/russian
	name = "Russian"
	mob_name = "Russian"
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/russiancorpse

/datum/outfit/russiancorpse
	name = "Corpse of a Russian"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/bearpelt


/obj/effect/mob_spawn/human/corpse/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Corpse of a Ranged Russian"
	head = /obj/item/clothing/head/ushanka


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

