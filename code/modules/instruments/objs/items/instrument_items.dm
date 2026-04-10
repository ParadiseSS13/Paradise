/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	hitsound = "swing_hit"
	allowed_instrument_ids = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/piano_synth
	name = "synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon_state = "synth"
	allowed_instrument_ids = "piano"

/obj/item/instrument/piano_synth/Initialize(mapload)
	. = ..()
	song.allowed_instrument_ids = SSinstruments.synthesizer_instrument_ids

/obj/item/instrument/banjo
	name = "banjo"
	desc = "A 'Mura' brand banjo. It's pretty much just a drum with a neck and strings."
	icon_state = "banjo"
	attack_verb = list("scruggs-styled", "hum-diggitied", "shin-digged", "clawhammered")
	hitsound = 'sound/weapons/banjoslap.ogg'
	allowed_instrument_ids = "banjo"

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has a kit of varied strings."
	icon_state = "guitar"
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/weapons/guitarslam.ogg'
	allowed_instrument_ids = list("guitar", "csteelgt", "cnylongt", "ccleangt", "cmutedgt", "sleggt", "piclgt")

/// This is a special guitar for the emagged service borg that hits pretty hard and can still play music. Clonk.
/obj/item/instrument/guitar/cyborg
	name = "steel-reinforced guitar"
	desc = "This guitar has robust metal plating inside to give it some extra kick."
	force = 20

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	allowed_instrument_ids = list("glockenspiel", "crvibr")

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	allowed_instrument_ids = list("accordion", "crack", "crtango")

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = "To announce the arrival of the king!"
	icon_state = "trumpet"
	allowed_instrument_ids = list("crtrumpet")

/obj/item/instrument/trumpet/spectral
	name = "spectral trumpet"
	desc = "Things are about to get spooky!"
	icon_state = "spectral_trumpet"
	force = 0
	attack_verb = list("played", "jazzed", "trumpeted", "mourned", "dooted", "spooked")

/obj/item/instrument/trumpet/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trumpet/spectral/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	playsound(src, 'sound/instruments/trombone/En4.mid', 100, TRUE, -1)
	..()

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	allowed_instrument_ids = "saxophone"

/obj/item/instrument/saxophone/spectral
	name = "spectral saxophone"
	desc = "This spooky sound will be sure to leave mortals in bones."
	force = 0
	attack_verb = list("played", "jazzed", "saxxed", "mourned", "dooted", "spooked")

/obj/item/instrument/saxophone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/saxophone/spectral/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	playsound(src, 'sound/instruments/saxophone/En4.mid', 100, TRUE,-1)
	..()

/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	inhand_icon_state = "trombone"
	allowed_instrument_ids = list("trombone", "crtrombone")

/obj/item/instrument/trombone/spectral
	name = "spectral trombone"
	desc = "A skeleton's favorite instrument. Apply directly on the mortals."
	force = 0
	attack_verb = list("played", "jazzed", "tromboned", "mourned", "dooted", "spooked")

/obj/item/instrument/trombone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trombone/spectral/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	playsound (src, 'sound/instruments/trombone/Cn4.mid', 100,1,-1)
	..()

/obj/item/instrument/trombone/sad
	name = "sad trombone"
	desc = "Wah. Waah. Waaah. Waaaaaaah."
	force = 0
	attack_verb = list("Wahed", "Waahed", "Waaahed", "Honked")

/obj/item/instrument/trombone/sad/attack__legacy__attackchain(mob/living/carbon/C, mob/user)
	playsound(loc, 'sound/misc/sadtrombone.ogg', 50, TRUE, -1)
	..()

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	force = 5
	icon_state = "recorder"
	allowed_instrument_ids = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	allowed_instrument_ids = "harmonica"

/obj/item/instrument/xylophone
	name = "xylophone"
	desc = "A percussion instrument with a bright tone."
	icon_state = "xylophone"
	allowed_instrument_ids = list("xylophone", "crvibr")

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	attack_verb = list("beautifully honks")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	hitsound = 'sound/items/bikehorn.ogg'
	allowed_instrument_ids = list("bikehorn", "honk")

// Crafting recipes
/datum/crafting_recipe/violin
	name = "Violin"
	result = list(/obj/item/instrument/violin)
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 8 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/guitar
	name = "Guitar"
	result = list(/obj/item/instrument/guitar)
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 8 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/eguitar
	name = "Electric Guitar"
	result = list(/obj/item/instrument/eguitar)
	reqs = list(/obj/item/stack/sheet/metal = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 8 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/banjo
	name = "Banjo"
	result = list(/obj/item/instrument/banjo)
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 8 SECONDS
	category = CAT_MISC
