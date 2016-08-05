/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"


/obj/item/clothing/under/color/random/New()
	..()
	var/list/excluded = list(/obj/item/clothing/under/color/random, /obj/item/clothing/under/color/blackf, /obj/item/clothing/under/color/blue/dodgeball, /obj/item/clothing/under/color/orange/prison, /obj/item/clothing/under/color/red/dodgeball, /obj/item/clothing/under/color/red/jersey, /obj/item/clothing/under/color/blue/jersey)
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
	flags_size = ONESIZEFITSALL
	burn_state = FIRE_PROOF

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "blackf"

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	item_color = "blue"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/blue/dodgeball
	flags = NODROP
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	item_color = "green"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/grey/greytide
	flags = NODROP
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."

/obj/item/clothing/under/color/grey/glorf/hit_reaction(mob/living/carbon/human/owner)
	owner.forcesay(hit_appends)
	return 0

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers"
	icon_state = "orange"
	item_state = "o_suit"
	item_color = "orange"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/orange/prison
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "orange"
	item_state = "o_suit"
	item_color = "orange"
	has_sensor = 2
	sensor_mode = 3
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	item_state = "p_suit"
	item_color = "pink"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	item_color = "red"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/red/dodgeball
	flags = NODROP
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	item_color = "white"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	item_color = "yellow"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_color = "psyche"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/uniform.dmi'
		)

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	item_color = "lightblue"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	item_color = "aqua"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	item_color = "purple"

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
	flags_size = ONESIZEFITSALL

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
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "lightred"
	item_color = "lightred"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "darkred"
	item_color = "darkred"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/red/jersey
	name = "red team jersey"
	desc = "The jersey of the Nanotrasen Phi-ghters!"
	icon_state = "redjersey"
	item_state = "r_suit"
	item_color = "redjersey"
	flags_size = ONESIZEFITSALL

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon_state = "bluejersey"
	item_state = "b_suit"
	item_color = "bluejersey"
	flags_size = ONESIZEFITSALL
