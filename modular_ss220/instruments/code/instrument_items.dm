/obj/item/instrument/soundhand_metal_guitar
	name = "гитара Арии"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва. Эта гитара украшена пламенем в районе корпуса и подписью Арии Вильвен."
	icon_state = "elguitar_fire"
	item_state = "elguitar_fire"
	icon = 'modular_ss220/instruments/icons/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_ss220/instruments/icons/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_ss220/instruments/icons/samurai_guitar_righthand.dmi'
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt","cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_metal_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_bass_guitar
	name = "бас-гитара"
	desc = "Тяжелая гитара с сокращенным количеством широких струн для извлечения низкочастотных звуков."
	icon_state = "bluegitara"
	item_state = "bluegitara"
	icon = 'modular_ss220/instruments/icons/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_ss220/instruments/icons/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_ss220/instruments/icons/samurai_guitar_righthand.dmi'
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshbassgt", "cnylongt", "cmutedgt")

/obj/item/instrument/soundhand_bass_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/instrument/soundhand_rock_guitar
	name = "рок-гитара"
	desc = "Тяжелая гитара со встроенными эффектами дисторшена и овердрайва"
	icon_state = "elguitar"
	item_state = "elguitar"
	icon = 'modular_ss220/instruments/icons/samurai_guitar.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	lefthand_file = 'modular_ss220/instruments/icons/samurai_guitar_lefthand.dmi'
	righthand_file = 'modular_ss220/instruments/icons/samurai_guitar_righthand.dmi'
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("cshmetalgt", "cshrockgt", "csteelgt", "ccleangt")

/obj/item/instrument/soundhand_rock_guitar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/datum/supply_packs/misc/soundhand
	name = "Soundhand Concert Crate"
	contains = list(/obj/item/clothing/suit/storage/soundhand_black_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_black_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_olive_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_olive_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_brown_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_brown_jacket/tag,
					/obj/item/clothing/suit/storage/soundhand_white_jacket/tag,
					/obj/item/instrument/soundhand_metal_guitar,
					/obj/item/instrument/soundhand_bass_guitar,
					/obj/item/instrument/soundhand_rock_guitar,
					/obj/structure/musician/drumskit,
					/obj/structure/concertspeaker_fake,
					/obj/structure/concertspeaker_fake,
					/obj/machinery/jukebox/concertspeaker,
					/obj/item/instrument/piano_synth,
					/obj/item/flag/soundhand,
					/obj/item/flag/soundhand,
					/obj/item/flag/soundhand,
					/obj/item/flag/soundhand)
	cost = 1000
	containername = "soundhand concert crate"
