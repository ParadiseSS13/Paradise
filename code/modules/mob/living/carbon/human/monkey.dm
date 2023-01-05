/mob/living/carbon/human/lesser
	var/master_commander = null //переменная хранящая владельца "животного"
	fire_dmi = 'icons/mob/species/monkey/OnFire.dmi'
	genetic_mutable = 'icons/mob/species/monkey/genetics.dmi'
	var/sentience_type = SENTIENCE_ORGANIC

/mob/living/carbon/human/lesser/monkey/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey)
	tts_seed = "Sniper"

/mob/living/carbon/human/lesser/farwa/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/tajaran)
	tts_seed = "Gyro"

/mob/living/carbon/human/lesser/wolpin/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/vulpkanin)
	tts_seed = "Bloodseeker"

/mob/living/carbon/human/lesser/neara/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/skrell)
	tts_seed = "Bounty"

/mob/living/carbon/human/lesser/stok/Initialize(mapload)
	. = ..(mapload, /datum/species/monkey/unathi)
	tts_seed = "Witchdoctor"

/mob/living/carbon/human/lesser/slip(description, stun, weaken, tilesSlipped, walkSafely, slipAny, grav_ignore = FALSE, slipVerb = "поскользнулись")
	. = ..()
	if(prob(50) && (has_gravity(src) || grav_ignore))
		unEquip(shoes, 1)
