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

/obj/item/clothing/under/color/jumpskirt
	desc = "A standard issue colored jumpskirt. Variety is the spice of life!"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	dyeing_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/color/random/Initialize(mapload)
	. = ..()
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
	item_state = initial(C.item_state)
	item_color = initial(C.item_color)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"
	icon_state = "blackjumpskirt"
	item_state = "bl_suit"
	item_color = "blackskirt"
	resistance_flags = NONE // I am going to assume this is here for a reason

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	item_color = "blue"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	icon_state = "bluejumpskirt"
	item_state = "b_suit"
	item_color = "blueskirt"

/obj/item/clothing/under/color/blue/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	item_color = "green"

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	icon_state = "greenjumpskirt"
	item_state = "g_suit"
	item_color = "greenskirt"

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/obj/item/clothing/under/color/grey/greytide
	flags = NODROP

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	icon_state = "greyjumpskirt"
	item_state = "gy_suit"
	item_color = "greyskirt"

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

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orangejumpskirt"
	item_state = "o_suit"
	item_color = "orangeskirt"

/obj/item/clothing/under/color/orange/prison
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	item_state = "prisoner"
	item_color = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/jumpskirt/orange/prison
	name = "orange jumpskirt"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisonerjumpskirt"
	item_state = "prisoner"
	item_color = "prisonerskirt"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	item_state = "p_suit"
	item_color = "pink"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pinkjumpskirt"
	item_state = "p_suit"
	item_color = "pinkskirt"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	item_color = "red"

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	icon_state = "redjumpskirt"
	item_state = "r_suit"
	item_color = "redskirt"

/obj/item/clothing/under/color/red/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	item_color = "white"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	icon_state = "whitejumpskirt"
	item_state = "w_suit"
	item_color = "whiteskirt"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	item_color = "yellow"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	icon_state = "yellowjumpskirt"
	item_state = "y_suit"
	item_color = "yellowskirt"

/obj/item/clothing/under/color/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_color = "psyche"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	item_color = "lightblue"

/obj/item/clothing/under/color/jumpskirt/lightblue
	name = "light blue jumpskirt"
	icon_state = "lightbluejumpskirt"
	item_color = "lightblueskirt"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	item_color = "aqua"

/obj/item/clothing/under/color/jumpskirt/aqua
	name = "aqua jumpskirt"
	icon_state = "aquajumpskirt"
	item_color = "aquaskirt"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	item_color = "purple"

/obj/item/clothing/under/color/jumpskirt/purple
	name = "purple jumpskirt"
	icon_state = "purplejumpskirt"
	item_state = "p_suit"
	item_color = "purpleskirt"

/// for jani ert
/obj/item/clothing/under/color/purple/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_state = "lightpurple"
	item_color = "lightpurple"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	icon_state = "lightpurplejumpskirt"
	item_color = "lightpurpleskirt"

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_state = "lightgreen"
	item_color = "lightgreen"

/obj/item/clothing/under/color/jumpskirt/lightgreen
	name = "light green jumpskirt"
	icon_state = "lightgreenjumpskirt"
	item_color = "lightgreenskirt"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_state = "lightbrown"
	item_color = "lightbrown"

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "light brown jumpskirt"
	icon_state = "lightbrownjumpskirt"
	item_color = "lightbrownskirt"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	item_color = "brown"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	icon_state = "brownjumpskirt"
	item_color = "brownskirt"

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_state = "yellowgreen"
	item_color = "yellowgreen"

/obj/item/clothing/under/color/jumpskirt/yellowgreen
	name = "yellow green jumpskirt"
	icon_state = "yellowgreenjumpskirt"
	item_color = "yellowgreenskirt"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	icon_state = "darkblue"
	item_color = "darkblue"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	icon_state = "darkbluejumpskirt"
	item_color = "darkblueskirt"

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "lightred"
	item_color = "lightred"

/obj/item/clothing/under/color/jumpskirt/lightred
	name = "light red jumpskirt"
	icon_state = "lightredjumpskirt"
	item_color = "lightredskirt"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "darkred"
	item_color = "darkred"

/obj/item/clothing/under/color/jumpskirt/darkred
	name = "dark red jumpskirt"
	icon_state = "darkredjumpskirt"
	item_color = "darkredskirt"

/obj/item/clothing/under/color/rainbow
	name = "rainbow"
	desc = "rainbow"
	icon_state = "rainbow"
	item_state = "rainbow"
	item_color = "rainbow"

/obj/item/clothing/under/color/jumpskirt/rainbow
	name = "rainbow jumpskirt"
	desc = "Rainbow."
	icon_state = "rainbowjumpskirt"
	item_state = "rainbow"
	item_color = "rainbowskirt"

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
