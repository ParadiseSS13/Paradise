/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	icon_state = "color"
	inhand_icon_state = "color_suit"
	dyeable = TRUE
	var/default_palette_key = DYE_WHITE
	var/icon_palette_key = null
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/under/color.dmi',
		"Skkulakin" = 'icons/mob/clothing/species/skkulakin/under/color.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/color.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/color.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/color.dmi'
	)

/obj/item/clothing/under/color/jumpskirt
	desc = "A standard issue colored jumpskirt. Variety is the spice of life!"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	icon_state = "colorskirt"
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/color/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/under/color/update_icon()
	. = ..()
	set_icon_from_cache()

/obj/item/clothing/under/proc/set_icon_from_cache(palette_key = null, dye_key = null)
	if(!palette_key)
		return FALSE
	dye_key = dye_key || dyeing_key
	if(!GLOB.palette_registry[dye_key])
		stack_trace("Item just tried to be colored with an invalid registry key: [dye_key]")
	var/datum/asset/icon_cache/clothing/icon_cache = get_asset_datum(/datum/asset/icon_cache/clothing/)

	// Set icons
	for(var/sheet_key in sprite_sheets)
		sprite_sheets[sheet_key] = icon_cache.sprite_sheets[dye_key][palette_key][sheet_key]
	icon = icon_cache.sprite_sheets[dye_key][palette_key]["Obj"]
	worn_icon = icon_cache.sprite_sheets[dye_key][palette_key]["Human"]
	lefthand_file = icon_cache.sprite_sheets[dye_key][palette_key]["Lefthand"]
	righthand_file = icon_cache.sprite_sheets[dye_key][palette_key]["Righthand"]

	// Set icon states
	var/icon_state_prefix = findtext(palette_key, "psyche") ? "psyche" : "color"
	var/icon_state_skirt = dye_key == "under" ? "" : "skirt"
	icon_state = "[icon_state_prefix][icon_state_skirt]"
	inhand_icon_state = "[icon_state_prefix]_suit"

/obj/item/clothing/under/color/set_icon_from_cache(palette_key, dye_key)
	palette_key = palette_key || icon_palette_key
	. = ..()

/obj/item/clothing/under/color/random/Initialize(mapload)
	var/list/excluded = list(/obj/item/clothing/under/color/random,
							/obj/item/clothing/under/color/blue/dodgeball,
							/obj/item/clothing/under/color/orange/prison,
							/obj/item/clothing/under/color/red/dodgeball,
							/obj/item/clothing/under/color/red/jersey,
							/obj/item/clothing/under/color/blue/jersey,
							/obj/item/clothing/under/color/white/enforcer)
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - typesof(/obj/item/clothing/under/color/jumpskirt) - excluded)
	name = initial(C.name)
	icon_state = initial(C.icon_state)
	icon_palette_key = initial(C.icon_palette_key)
	inhand_icon_state = initial(C.inhand_icon_state)
	. = ..()
	if(C == /obj/item/clothing/under/color/psyche)
		set_icon_from_cache(palette_key = "psyche")

/obj/item/clothing/under/color/jumpskirt/random/Initialize(mapload)
	var/list/excluded = list(/obj/item/clothing/under/color/jumpskirt/random,
							/obj/item/clothing/under/color/jumpskirt/orange/prison,)
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color/jumpskirt) - excluded)
	name = initial(C.name)
	icon_state = initial(C.icon_state)
	icon_palette_key = initial(C.icon_palette_key)
	inhand_icon_state = initial(C.inhand_icon_state)
	. = ..()
	if(C == /obj/item/clothing/under/color/jumpskirt/psyche)
		set_icon_from_cache(palette_key = "psycheskirt")

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_palette_key = DYE_BLACK
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"
	icon_palette_key = DYE_BLACK
	resistance_flags = NONE // I am going to assume this is here for a reason

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_palette_key = DYE_BLUE

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	icon_palette_key = DYE_BLUE

/obj/item/clothing/under/color/blue/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_palette_key = DYE_GREEN

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	icon_palette_key = DYE_GREEN

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_palette_key = DYE_GREY

/obj/item/clothing/under/color/grey/greytide
	flags = NODROP

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	icon_palette_key = DYE_GREY

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "ancient"
	icon_palette_key = null

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	icon_palette_key = DYE_ORANGE

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	desc = "Don't wear this near paranoid security officers."
	icon_palette_key = DYE_ORANGE

/obj/item/clothing/under/color/orange/prison
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	icon_palette_key = null
	inhand_icon_state = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/jumpskirt/orange/prison
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisonerskirt"
	icon_palette_key = null
	inhand_icon_state = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_palette_key = DYE_PINK

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_palette_key = DYE_PINK

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_palette_key = DYE_RED

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	icon_palette_key = DYE_RED

/obj/item/clothing/under/color/red/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_palette_key = DYE_WHITE

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	icon_palette_key = DYE_WHITE

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_palette_key = DYE_YELLOW

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	icon_palette_key = DYE_YELLOW

/obj/item/clothing/under/color/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	inhand_icon_state = "psyche_suit"

/obj/item/clothing/under/color/psyche/set_icon_from_cache(palette_key = "psyche", dye_key = null)
	return ..()

/obj/item/clothing/under/color/jumpskirt/psyche
	name = "psychedelic jumpskirt"
	desc = "Far out!"
	icon_state = "psycheskirt"
	inhand_icon_state = "psyche_suit"

/obj/item/clothing/under/color/jumpskirt/psyche/set_icon_from_cache(palette_key = "psycheskirt", dye_key = null)
	return ..()

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_palette_key = DYE_LIGHTBLUE

/obj/item/clothing/under/color/jumpskirt/lightblue
	name = "light blue jumpskirt"
	icon_palette_key = DYE_LIGHTBLUE

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_palette_key = DYE_AQUA

/obj/item/clothing/under/color/jumpskirt/aqua
	name = "aqua jumpskirt"
	icon_palette_key = DYE_AQUA

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_palette_key = DYE_PURPLE

/obj/item/clothing/under/color/jumpskirt/purple
	name = "purple jumpskirt"
	icon_palette_key = DYE_PURPLE

/// for jani ert
/obj/item/clothing/under/color/purple/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_palette_key = DYE_LIGHTPURPLE

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	icon_palette_key = DYE_LIGHTPURPLE

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_palette_key = DYE_LIGHTGREEN

/obj/item/clothing/under/color/jumpskirt/lightgreen
	name = "light green jumpskirt"
	icon_palette_key = DYE_LIGHTGREEN

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_palette_key = DYE_LIGHTBROWN

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "light brown jumpskirt"
	icon_palette_key = DYE_LIGHTBROWN

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_palette_key = DYE_BROWN

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	icon_palette_key = DYE_BROWN

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_palette_key = DYE_YELLOWGREEN

/obj/item/clothing/under/color/jumpskirt/yellowgreen
	name = "yellow green jumpskirt"
	icon_palette_key = DYE_YELLOWGREEN

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	icon_palette_key = DYE_DARKBLUE

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	icon_palette_key = DYE_DARKBLUE

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_palette_key = DYE_LIGHTRED

/obj/item/clothing/under/color/jumpskirt/lightred
	name = "light red jumpskirt"
	icon_palette_key = DYE_LIGHTRED

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_palette_key = DYE_DARKRED

/obj/item/clothing/under/color/jumpskirt/darkred
	name = "dark red jumpskirt"
	icon_palette_key = DYE_DARKRED

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "Rainbow."
	icon_state = "rainbow"
	inhand_icon_state = "rainbow"

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "Rainbow."
	icon_state = "rainbowskirt"
	inhand_icon_state = "rainbow"

/obj/item/clothing/under/color/red/jersey
	name = "red team jersey"
	desc = "The jersey of the Nanotrasen Phi-ghters!"
	icon_state = "redjersey"
	icon_palette_key = null

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon_state = "bluejersey"
	icon_palette_key = null
