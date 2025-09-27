/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	icon = 'icons/obj/clothing/under/color.dmi'
	worn_icon = 'icons/mob/clothing/under/color.dmi'
	dyeable = TRUE
	sprite_sheets = list(
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
	inhand_icon_state = initial(C.inhand_icon_state)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	inhand_icon_state = "bl_suit"
	resistance_flags = NONE

/obj/item/clothing/under/color/jumpskirt/black
	name = "black jumpskirt"
	icon_state = "blackskirt"
	inhand_icon_state = "bl_suit"
	resistance_flags = NONE // I am going to assume this is here for a reason

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/jumpskirt/blue
	name = "blue jumpskirt"
	icon_state = "blueskirt"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/color/blue/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/jumpskirt/green
	name = "green jumpskirt"
	icon_state = "greenskirt"
	inhand_icon_state = "g_suit"

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/color/grey/greytide
	flags = NODROP

/obj/item/clothing/under/color/jumpskirt/grey
	name = "grey jumpskirt"
	desc = "A tasteful grey jumpskirt that reminds you of the good old days."
	icon_state = "greyskirt"
	inhand_icon_state = "gy_suit"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."
	icon_state = "ancient"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orange"
	inhand_icon_state = "o_suit"

/obj/item/clothing/under/color/jumpskirt/orange
	name = "orange jumpskirt"
	desc = "Don't wear this near paranoid security officers."
	icon_state = "orangeskirt"
	inhand_icon_state = "o_suit"

/obj/item/clothing/under/color/orange/prison
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisoner"
	inhand_icon_state = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/jumpskirt/orange/prison
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "prisonerskirt"
	inhand_icon_state = "prisoner"
	has_sensor = 2
	sensor_mode = SENSOR_COORDS

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/jumpskirt/pink
	name = "pink jumpskirt"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pinkskirt"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/jumpskirt/red
	name = "red jumpskirt"
	icon_state = "redskirt"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/color/red/dodgeball
	flags = NODROP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"

/obj/item/clothing/under/color/jumpskirt/white
	name = "white jumpskirt"
	icon_state = "whiteskirt"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"

/obj/item/clothing/under/color/jumpskirt/yellow
	name = "yellow jumpskirt"
	icon_state = "yellowskirt"

/obj/item/clothing/under/color/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"

/obj/item/clothing/under/color/jumpskirt/lightblue
	name = "light blue jumpskirt"
	icon_state = "lightblueskirt"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"

/obj/item/clothing/under/color/jumpskirt/aqua
	name = "aqua jumpskirt"
	icon_state = "aquaskirt"

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/color/jumpskirt/purple
	name = "purple jumpskirt"
	icon_state = "purpleskirt"
	inhand_icon_state = "p_suit"

/// for jani ert
/obj/item/clothing/under/color/purple/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_state = "lightpurple"

/obj/item/clothing/under/color/jumpskirt/lightpurple
	name = "light purple jumpskirt"
	icon_state = "lightpurpleskirt"

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_state = "lightgreen"

/obj/item/clothing/under/color/jumpskirt/lightgreen
	name = "light green jumpskirt"
	icon_state = "lightgreenskirt"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_state = "lightbrown"

/obj/item/clothing/under/color/jumpskirt/lightbrown
	name = "light brown jumpskirt"
	icon_state = "lightbrownskirt"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"

/obj/item/clothing/under/color/jumpskirt/brown
	name = "brown jumpskirt"
	icon_state = "brownskirt"

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_state = "yellowgreen"

/obj/item/clothing/under/color/jumpskirt/yellowgreen
	name = "yellow green jumpskirt"
	icon_state = "yellowgreenskirt"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	icon_state = "darkblue"

/obj/item/clothing/under/color/jumpskirt/darkblue
	name = "dark blue jumpskirt"
	icon_state = "darkblueskirt"

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "lightred"

/obj/item/clothing/under/color/jumpskirt/lightred
	name = "light red jumpskirt"
	icon_state = "lightredskirt"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "darkred"

/obj/item/clothing/under/color/jumpskirt/darkred
	name = "dark red jumpskirt"
	icon_state = "darkredskirt"

/obj/item/clothing/under/color/rainbow
	name = "rainbow"
	desc = "rainbow."
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

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon_state = "bluejersey"
