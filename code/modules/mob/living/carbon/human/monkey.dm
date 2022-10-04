/mob/living/carbon/human/lesser
	var/master_commander = null //переменная хранящая владельца "животного"
	fire_dmi = 'icons/mob/species/monkey/OnFire.dmi'
	genetic_mutable = 'icons/mob/species/monkey/genetics.dmi'
	var/sentience_type = SENTIENCE_ORGANIC

/mob/living/carbon/human/lesser/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)

/mob/living/carbon/human/lesser/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)

/mob/living/carbon/human/lesser/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)

/mob/living/carbon/human/lesser/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)

/mob/living/carbon/human/lesser/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)

/mob/living/carbon/human/lesser/slip(description, stun, weaken, tilesSlipped, walkSafely, slipAny, slipVerb = "поскользнулись")
	. = ..()
	if(prob(50))
		unEquip(shoes, 1)
