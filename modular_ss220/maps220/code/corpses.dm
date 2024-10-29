/* For Black Market Packers gateway */
/obj/effect/mob_spawn/human/corpse/tacticool
	mob_type = /mob/living/carbon/human
	name = "Tacticool corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	mob_name = "Unknown"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/packercorpse

/datum/outfit/packercorpse
	name = "Packer Corpse"
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	l_ear = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/black

/obj/effect/mob_spawn/human/corpse/tacticool/Initialize(mapload)
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader
	name = "Syndi trader corpse"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "tactifool"
	random = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/syndicatetrader

/datum/outfit/syndicatetrader
	uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	gloves = /obj/item/clothing/gloves/color/black/forensics
	belt = /obj/item/gun/projectile/automatic/pistol
	mask = /obj/item/clothing/mask/balaclava
	suit = /obj/item/clothing/suit/armor/vest/combat

/obj/effect/mob_spawn/human/corpse/syndicatesoldier/trader/Initialize(mapload)
	brute_damage = rand(150, 500)
	burn_damage = rand(100, 300)
	return ..()
