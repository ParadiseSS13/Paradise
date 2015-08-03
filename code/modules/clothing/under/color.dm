/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"

/obj/item/clothing/under/color/random/New()
	..()
	var/list/excluded = list(/obj/item/clothing/under/color/random, /obj/item/clothing/under/color/blackf, /obj/item/clothing/under/color/blue/dodgeball, /obj/item/clothing/under/color/orange/prison, /obj/item/clothing/under/color/red/dodgeball, /obj/item/clothing/under/color/red/jersey, /obj/item/clothing/under/color/blue/jersey)
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - excluded)
	name = initial(C.name)
	icon_state = initial(C.icon_state)
	item_state = initial(C.item_state)
	_color = initial(C._color)

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "black"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/blackf
	name = "feminine black jumpsuit"
	desc = "It's very smart and in a ladies-size!"
	icon_state = "black"
	item_state = "bl_suit"
	_color = "blackf"

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"
	_color = "blue"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/blue/dodgeball
	flags = ONESIZEFITSALL | NODROP

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"
	_color = "green"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"
	_color = "grey"
	flags = ONESIZEFITSALL
	species_fit = list("Vox")

/obj/item/clothing/under/color/grey/greytide
	flags = ONESIZEFITSALL | NODROP

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid security officers"
	icon_state = "orange"
	item_state = "o_suit"
	_color = "orange"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/orange/prison
	name = "orange jumpsuit"
	desc = "It's standardised Nanotrasen prisoner-wear. Its suit sensors are stuck in the \"Fully On\" position."
	icon_state = "orange"
	item_state = "o_suit"
	_color = "orange"
	has_sensor = 2
	sensor_mode = 3
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	icon_state = "pink"
	item_state = "p_suit"
	_color = "pink"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"
	_color = "red"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/red/dodgeball
	flags = ONESIZEFITSALL | NODROP

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"
	_color = "white"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"
	_color = "yellow"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	_color = "psyche"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	_color = "lightblue"

/obj/item/clothing/under/color/aqua
	name = "aqua jumpsuit"
	icon_state = "aqua"
	_color = "aqua"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/purple
	name = "purple jumpsuit"
	icon_state = "purple"
	item_state = "p_suit"
	_color = "purple"

/obj/item/clothing/under/color/lightpurple
	name = "light purple jumpsuit"
	icon_state = "lightpurple"
	_color = "lightpurple"

/obj/item/clothing/under/color/lightgreen
	name = "light green jumpsuit"
	icon_state = "lightgreen"
	_color = "lightgreen"

/obj/item/clothing/under/color/lightblue
	name = "light blue jumpsuit"
	icon_state = "lightblue"
	_color = "lightblue"

/obj/item/clothing/under/color/lightbrown
	name = "light brown jumpsuit"
	icon_state = "lightbrown"
	_color = "lightbrown"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	_color = "brown"

/obj/item/clothing/under/color/yellowgreen
	name = "yellow green jumpsuit"
	icon_state = "yellowgreen"
	_color = "yellowgreen"

/obj/item/clothing/under/color/darkblue
	name = "dark blue jumpsuit"
	icon_state = "darkblue"
	_color = "darkblue"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/lightred
	name = "light red jumpsuit"
	icon_state = "lightred"
	_color = "lightred"

/obj/item/clothing/under/color/darkred
	name = "dark red jumpsuit"
	icon_state = "darkred"
	_color = "darkred"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/red/jersey
	name = "red team jersey"
	desc = "The jersey of the Nanotrasen Phi-ghters!"
	icon_state = "redjersey"
	item_state = "r_suit"
	_color = "redjersey"
	flags = ONESIZEFITSALL

/obj/item/clothing/under/color/blue/jersey
	name = "blue team jersey"
	desc = "The jersey of the Nanotrasen Pi-rates!"
	icon_state = "bluejersey"
	item_state = "b_suit"
	_color = "bluejersey"
	flags = ONESIZEFITSALL
