GLOBAL_LIST_INIT(shelf_colors, list("basic", "sci", "sup", "serv", "med", "sec", "cmd", "engi"))

/obj/structure/shelf
	name = "shelf"
	desc = "A piece of furniture used for vertical storage."
	icon = 'icons/obj/structures/shelves.dmi'
	icon_state = "shelf_basic"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTAKE
	max_integrity = 80
	/// The suffix of the icon state used for the shelf. Indexed into `GLOB.shelf_colors`.
	var/shelf_style = "basic"
	/// The current overlay of the top shelf. Used for interleaving objects and shelf layers for the illusion of depth.
	var/image/shelf_overlay
	COOLDOWN_DECLARE(spraypaint_cd)

/obj/structure/shelf/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	AddComponent(/datum/component/shelver/basic_shelf, random_pickup_locations_ = istype(A, /area/station/maintenance))
	update_icon()
	set_style(shelf_style)

	if(mapload)
		SEND_SIGNAL(src, COMSIG_SHELF_ADDED_ON_MAPLOAD)

/obj/structure/shelf/attackby(obj/item/I, mob/living/user, params)
	var/obj/item/toy/crayon/spraycan/spraycan = I
	if(!istype(spraycan))
		return ..()
	if(spraycan.capped)
		return ..()

	if(!COOLDOWN_FINISHED(src, spraypaint_cd))
		to_chat(user, "<span class='warning'>The paint on [src] is still drying!</span>")
		return

	var/cur_idx = GLOB.shelf_colors.Find(shelf_style)
	if(!cur_idx)
		cur_idx = 1
	cur_idx++
	if(cur_idx > length(GLOB.shelf_colors))
		cur_idx = 1
	set_style(GLOB.shelf_colors[cur_idx])
	spraycan.play_spray_sound(user)

	// Tiny cooldown to prevent constant spamming of the action
	COOLDOWN_START(src, spraypaint_cd, 1 SECONDS)

/obj/structure/shelf/proc/set_style(new_style)
	if(shelf_style == new_style && !isnull(shelf_overlay))
		return
	shelf_style = new_style
	icon_state = "shelf_[shelf_style]"
	// Don't think I can get away with both icon smoothing across tiles
	// and dealing with this overlay shit
	shelf_overlay = mutable_appearance('icons/obj/structures/shelves.dmi', "shelf_[shelf_style]-top")
	shelf_overlay.layer = LOW_ITEM_LAYER
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/shelf/update_overlays()
	return list(shelf_overlay)

/obj/structure/shelf/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(user.a_intent == INTENT_HELP)
		return FALSE
	if(!I.use_tool(src, user, 2.5 SECONDS, volume = I.tool_volume))
		return

	to_chat(user, "<span class='notice'>You disassemble [src].</span>")
	deconstruct()

/obj/structure/shelf/deconstruct(disassembled)
	new /obj/item/stack/sheet/metal(get_turf(src), 5)
	return ..()

/obj/structure/shelf/engineering
	icon_state = "shelf_engi"
	shelf_style = "engi"

/obj/structure/shelf/medbay
	icon_state = "shelf_med"
	shelf_style = "med"

/obj/structure/shelf/security
	icon_state = "shelf_sec"
	shelf_style = "sec"

/obj/structure/shelf/service
	icon_state = "shelf_serv"
	shelf_style = "serv"

/obj/structure/shelf/science
	icon_state = "shelf_sci"
	shelf_style = "sci"

/obj/structure/shelf/command
	icon_state = "shelf_cmd"
	shelf_style = "cmd"

/obj/structure/shelf/supply
	icon_state = "shelf_sup"
	shelf_style = "sup"

/obj/structure/gunrack
	name = "gun rack"
	desc = "A rack for stowing firearms."
	icon = 'icons/obj/structures.dmi'
	icon_state = "gunrack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTAKE
	max_integrity = 80

/obj/structure/gunrack/Initialize(mapload)
	. = ..()
	var/static/list/gun_subtypes = subtypesof(/obj/item/gun)
	AddComponent(/datum/component/shelver/gun_rack, allowed_types_ = gun_subtypes)

	if(mapload)
		SEND_SIGNAL(src, COMSIG_SHELF_ADDED_ON_MAPLOAD)

/obj/structure/gunrack/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(user.a_intent == INTENT_HELP)
		return FALSE
	if(!I.use_tool(src, user, 2.5 SECONDS, volume = I.tool_volume))
		return

	to_chat(user, "<span class='notice'>You disassemble [src].</span>")
	deconstruct()

/obj/structure/gunrack/deconstruct(disassembled)
	new /obj/item/stack/sheet/metal(get_turf(src), 5)
	return ..()
