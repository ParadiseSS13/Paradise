/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dyeable = TRUE
	icon = 'icons/obj/clothing/under/color.dmi'

	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/under/color.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/under/color.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/under/color.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/under/color.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/under/color.dmi'
		)

/obj/item/clothing/under/color/random/Initialize(mapload)
	. = ..()
	var/list/excluded = list(/obj/item/clothing/under/color/random,
							/obj/item/clothing/under/color/blue/dodgeball,
							/obj/item/clothing/under/color/orange/prison,
							/obj/item/clothing/under/color/red/dodgeball,
							/obj/item/clothing/under/color/red/jersey,
							/obj/item/clothing/under/color/blue/jersey,
							/obj/item/clothing/under/color/white/enforcer)
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - excluded)
	name = initial(C.name)
	icon_state = initial(C.icon_state)
	item_state = initial(C.item_state)
	item_color = initial(C.item_color)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	resistance_flags = NONE

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	item_color = "blue"

/obj/item/clothing/under/color/blue/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	item_color = "green"

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/obj/item/clothing/under/color/grey/greytide
	flags = NODROP

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "ancient"
	item_state = "gy_suit"
	item_color = "ancient"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers"
	icon_state = "orange"
	item_state = "o_suit"
	item_color = "orange"

/obj/item/clothing/under/color/orange/prison
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	item_state = "prisoner"
	item_color = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	item_state = "p_suit"
	item_color = "pink"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	item_color = "red"

/obj/item/clothing/under/color/red/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	item_color = "white"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	item_color = "yellow"

/obj/item/clothing/under/color/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_color = "psyche"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	item_color = "lightblue"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	item_color = "aqua"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	item_color = "purple"

/// for jani ert
/obj/item/clothing/under/color/purple/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_state = "lightpurple"
	item_color = "lightpurple"

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_state = "lightgreen"
	item_color = "lightgreen"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	item_color = "lightblue"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_state = "lightbrown"
	item_color = "lightbrown"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	item_color = "brown"

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_state = "yellowgreen"
	item_color = "yellowgreen"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	icon_state = "darkblue"
	item_color = "darkblue"

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "lightred"
	item_color = "lightred"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "darkred"
	item_color = "darkred"

/obj/item/clothing/under/color/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"

/obj/item/clothing/under/color/red/jersey
	name = "red team jersey"
	desc = "The jersey of the Nanotrasen Phi-ghters!"
	icon_state = "redjersey"
	item_state = "r_suit"
	item_color = "redjersey"

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon_state = "bluejersey"
	item_state = "b_suit"
	item_color = "bluejersey"
