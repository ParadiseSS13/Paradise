//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "mid"

/obj/item/instrument/New()
	song = new(instrumentId, src, instrumentExt)
	..()

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/instrument/Initialize(mapload)
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/item/instrument/attack_self(mob/user)
	ui_interact(user)

/obj/item/instrument/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!isliving(user) || user.incapacitated())
		return

	song.ui_interact(user, ui_key, ui, force_open)

/obj/item/instrument/ui_data(mob/user, ui_key = "main", datum/topic_state/state = GLOB.default_state)
	return song.ui_data(user, ui_key, state)

/obj/item/instrument/Topic(href, href_list)
	song.Topic(href, href_list)

/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	instrumentExt = "ogg"
	force = 10
	hitsound = "swing_hit"
	instrumentId = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	item_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/piano_synth
	name = "synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon_state = "synth"
	item_state = "synth"
	instrumentId = "piano"
	instrumentExt = "ogg"
	var/static/list/insTypes = list("accordion" = "mid", "glockenspiel" = "mid", "guitar" = "ogg", "eguitar" = "ogg", "harmonica" = "mid", "piano" = "ogg", "recorder" = "mid", "saxophone" = "mid", "trombone" = "mid", "violin" = "ogg", "xylophone" = "mid")
	actions_types = list(/datum/action/item_action/synthswitch)

/obj/item/instrument/piano_synth/proc/changeInstrument(name = "piano")
	song.instrumentDir = name
	song.instrumentExt = insTypes[name]

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	instrumentExt = "ogg"
	force = 10
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/effects/guitarsmash.ogg'
	instrumentId = "guitar"

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	instrumentExt = "ogg"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	instrumentId = "glockenspiel"

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	item_state = "accordion"
	instrumentId = "accordion"

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	instrumentId = "saxophone"

/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	instrumentId = "trombone"

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	icon_state = "recorder"
	item_state = "recorder"
	instrumentId = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	instrumentId = "harmonica"
	force = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/instrument/xylophone
	name = "xylophone"
	desc = "a percussion instrument with a bright tone."
	icon_state = "xylophone"
	item_state = "xylophone"
	instrumentId = "xylophone"

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	attack_verb = list("beautifully honks")
	instrumentId = "bikehorn"
	instrumentExt = "ogg"
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 7
	hitsound = 'sound/items/bikehorn.ogg'

/datum/crafting_recipe/violin
	name = "Violin"
	result = /obj/item/instrument/violin
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 80
	category = CAT_MISC

/datum/crafting_recipe/guitar
	name = "Guitar"
	result = /obj/item/instrument/guitar
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 80
	category = CAT_MISC

/datum/crafting_recipe/eguitar
	name = "Electric Guitar"
	result = /obj/item/instrument/eguitar
	reqs = list(/obj/item/stack/sheet/metal = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 80
	category = CAT_MISC
