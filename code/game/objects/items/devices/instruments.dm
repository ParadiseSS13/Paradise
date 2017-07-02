//copy pasta of the space piano, don't hurt me -Pete
/obj/item/device/instrument
	name = "generic instrument"
	icon = 'icons/obj/musician.dmi'
	burn_state = FLAMMABLE
	var/datum/song/handheld/song
	var/instrumentId = "generic"
	var/instrumentExt = "ogg"

/obj/item/device/instrument/New()
	song = new(instrumentId, src)
	song.instrumentExt = instrumentExt
	..()

/obj/item/device/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/device/instrument/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] begins to play 'Gloomy Sunday'! It looks like \he's trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/device/instrument/initialize(mapload)
	song.tempo = song.sanitize_tempo(song.tempo) // tick_lag isn't set when the map is loaded
	..()

/obj/item/device/instrument/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/instrument/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(!isliving(user) || user.incapacitated())
		return

	song.ui_interact(user, ui_key, ui, force_open)

/obj/item/device/instrument/ui_data(mob/user, ui_key = "main", datum/topic_state/state = default_state)
	return song.ui_data(user, ui_key, state)

/obj/item/device/instrument/Topic(href, href_list)
	song.Topic(href, href_list)

/obj/item/device/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	force = 10
	hitsound = "swing_hit"
	instrumentId = "violin"

/obj/item/device/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	item_state = "golden_violin"
	burn_state = LAVA_PROOF

/obj/item/device/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	force = 10
	attack_verb = list("played metal on", "serenaded", "crashed", "smashed")
	hitsound = 'sound/effects/guitarsmash.ogg'
	instrumentId = "guitar"

/obj/item/device/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb = list("played metal on", "shredded", "crashed", "smashed")
	hitsound = 'sound/weapons/stringsmash.ogg'
	instrumentId = "eguitar"

/datum/crafting_recipe/violin
	name = "Violin"
	result = /obj/item/device/instrument/violin
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(/obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 80

/datum/crafting_recipe/guitar
	name = "Guitar"
	result = /obj/item/device/instrument/guitar
	reqs = list(/obj/item/stack/sheet/wood = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(/obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 80

/datum/crafting_recipe/eguitar
	name = "Electric Guitar"
	result = /obj/item/device/instrument/eguitar
	reqs = list(/obj/item/stack/sheet/metal = 5,
				/obj/item/stack/cable_coil = 6,
				/obj/item/stack/tape_roll = 5)
	tools = list(/obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters)
	time = 80