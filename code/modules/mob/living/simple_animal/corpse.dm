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
	name = "Syndicate Operative Corpse"
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
	name = "Syndicate Commando Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	l_ear = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen
	r_pocket = /obj/item/tank/emergency_oxygen
	id = /obj/item/card/id


/obj/effect/mob_spawn/human/clown/corpse
	roundstart = TRUE
	instant = TRUE

/obj/effect/mob_spawn/human/mime/corpse
	roundstart = TRUE
	instant = TRUE

/obj/effect/mob_spawn/human/corpse/pirate
	name = "Pirate"
	mob_name = "Pirate"
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/piratecorpse

/datum/outfit/piratecorpse
	name = "Pirate Corpse"
	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/bandana


/obj/effect/mob_spawn/human/corpse/pirate/ranged
	name = "Pirate Gunner"
	mob_name = "Pirate Gunner"
	outfit = /datum/outfit/piratecorpse/ranged

/datum/outfit/piratecorpse/ranged
	name = "Pirate Gunner Corpse"
	suit = /obj/item/clothing/suit/pirate_black
	head = /obj/item/clothing/head/pirate


/obj/effect/mob_spawn/human/corpse/russian
	name = "Russian"
	mob_name = "Russian"
	hair_style = "bald"
	facial_hair_style = "shaved"
	outfit = /datum/outfit/russiancorpse

/datum/outfit/russiancorpse
	name = "Russian Corpse"
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/bearpelt


/obj/effect/mob_spawn/human/corpse/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Ranged Russian Corpse"
	head = /obj/item/clothing/head/ushanka


/obj/effect/mob_spawn/human/corpse/wizard
	name = "Space Wizard Corpse"
	outfit = /datum/outfit/wizardcorpse

/obj/effect/mob_spawn/human/corpse/clownoff/Initialize()
	mob_name = "[pick(GLOB.wizard_first)], [pick(GLOB.wizard_second)]"
	..()

/datum/outfit/wizardcorpse
	name = "Space Wizard Corpse"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal
	head = /obj/item/clothing/head/wizard
