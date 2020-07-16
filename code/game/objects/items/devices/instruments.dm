//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 100
	var/datum/song/handheld/song
	var/instrument_id = "generic"
	var/instrument_extension = "mid"

/obj/item/instrument/New()
	song = new(instrument_id, src, instrument_extension)
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
	tgui_interact(user)

/obj/item/instrument/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	if(!isliving(user) || user.incapacitated())
		return

	song.tgui_interact(user, ui_key, ui, force_open)

/obj/item/instrument/tgui_data(mob/user)
	return song.tgui_data(user)

/obj/item/instrument/tgui_act(action, params)
	if(..())
		return
	return song.tgui_act(action, params)

/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	instrument_extension = "ogg"
	force = 10
	hitsound = "swing_hit"
	instrument_id = "violin"

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
	instrument_id = "piano"
	instrument_extension = "ogg"
	var/static/list/insTypes = list("accordion" = "mid", "glockenspiel" = "mid", "guitar" = "ogg", "eguitar" = "ogg", "harmonica" = "mid", "piano" = "ogg", "recorder" = "mid", "saxophone" = "mid", "trombone" = "mid", "violin" = "ogg", "xylophone" = "mid")
	actions_types = list(/datum/action/item_action/synthswitch)

/obj/item/instrument/piano_synth/proc/changeInstrument(name = "piano")
	song.instrument_folder = name
	song.instrument_extension = insTypes[name]

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	instrument_extension = "ogg"
	force = 10
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/effects/guitarsmash.ogg'
	instrument_id = "guitar"

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	instrument_extension = "ogg"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrument_id = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	instrument_id = "glockenspiel"

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	item_state = "accordion"
	instrument_id = "accordion"

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	instrument_id = "saxophone"

/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	instrument_id = "trombone"

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	icon_state = "recorder"
	item_state = "recorder"
	instrument_id = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	instrument_id = "harmonica"
	force = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/instrument/xylophone
	name = "xylophone"
	desc = "a percussion instrument with a bright tone."
	icon_state = "xylophone"
	item_state = "xylophone"
	instrument_id = "xylophone"

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	attack_verb = list("beautifully honks")
	instrument_id = "bikehorn"
	instrument_extension = "ogg"
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
