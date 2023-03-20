/mob/living/carbon/human/lesser
	var/master_commander = null //переменная хранящая владельца "животного"
	var/sentience_type = SENTIENCE_ORGANIC
	//holder_type = /obj/item/holder/monkey	//Задыхается сидя на голове или в сумке, временно отключен

/mob/living/carbon/human/lesser/Initialize(mapload, species)
	icon = null
	. = ..(mapload, species)

/mob/living/carbon/human/lesser/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)
	tts_seed = "Sniper"

/mob/living/carbon/human/lesser/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)
	tts_seed = "Gyro"
	//holder_type = /obj/item/holder/farwa

/mob/living/carbon/human/lesser/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)
	tts_seed = "Bloodseeker"
	//holder_type = /obj/item/holder/farwa

/mob/living/carbon/human/lesser/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)
	tts_seed = "Bounty"
	//holder_type = /obj/item/holder/neara

/mob/living/carbon/human/lesser/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)
	tts_seed = "Witchdoctor"
	//holder_type = /obj/item/holder/stok

/mob/living/carbon/human/lesser/slip(description, stun, weaken, tilesSlipped, walkSafely, slipAny, grav_ignore = FALSE, slipVerb = "поскользнулись")
	. = ..()
	if(prob(50) && (has_gravity(src) || grav_ignore))
		unEquip(shoes, 1)
