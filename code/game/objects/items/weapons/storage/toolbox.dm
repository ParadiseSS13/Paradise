/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon_state = "toolbox_default"
	inhand_icon_state = "toolbox_default"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	flags = CONDUCT
	force = 10
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1;engineering=1"
	attack_verb = list("robusted")
	use_sound = 'sound/effects/toolbox.ogg'
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	var/latches = "single_latch"
	var/has_latches = TRUE

/obj/item/storage/toolbox/Initialize(mapload)
	. = ..()
	if(has_latches)
		if(prob(10))
			if(prob(1))
				latches = "triple_latch"
			else
				latches = "double_latch"
	update_icon(UPDATE_OVERLAYS)

/obj/item/storage/toolbox/update_overlays()
	. = ..()
	if(has_latches)
		. += latches

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	inhand_icon_state = "toolbox_red"

/obj/item/storage/toolbox/emergency/populate_contents()
	new /obj/item/crowbar/small(src)
	new /obj/item/weldingtool/mini(src)
	new /obj/item/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/flashlight(src)
	else
		new /obj/item/flashlight/flare(src)
	new /obj/item/radio(src)

/obj/item/storage/toolbox/emergency/old
	name = "rusty red toolbox"
	icon_state = "toolbox_red_old"
	has_latches = FALSE

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	inhand_icon_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/populate_contents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/mechanical/greytide
	flags = NODROP

/obj/item/storage/toolbox/mechanical/old
	name = "rusty blue toolbox"
	icon_state = "toolbox_blue_old"
	has_latches = FALSE

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	inhand_icon_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/populate_contents()
	var/pickedcolor = pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, pickedcolor)
	new /obj/item/stack/cable_coil(src, 30, pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		new /obj/item/stack/cable_coil(src, 30, pickedcolor)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	inhand_icon_state = "toolbox_syndi"
	origin_tech = "combat=2;syndicate=1;engineering=2"
	silent = TRUE
	force = 15
	throwforce = 18

/obj/item/storage/toolbox/syndicate/populate_contents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool/red(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/storage/toolbox/fakesyndi
	name = "suspicous looking toolbox"
	icon_state = "syndicate"
	inhand_icon_state = "toolbox_syndi"
	desc = "Danger. Very Robust. The paint is still wet."

/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	inhand_icon_state = "toolbox_blue"

/obj/item/storage/toolbox/drone/populate_contents()
	var/pickedcolor = pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, 30, pickedcolor)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/toolbox/artistic
	name = "artistic toolbox"
	desc = "A toolbox painted bright green. Why anyone would store art supplies in a toolbox is beyond you, but it has plenty of extra space."
	icon_state = "green"
	inhand_icon_state = "artistic_toolbox"
	w_class = WEIGHT_CLASS_GIGANTIC //Holds more than a regular toolbox!
	max_combined_w_class = 20
	storage_slots = 10

/obj/item/storage/toolbox/artistic/populate_contents()
	new /obj/item/storage/fancy/crayons(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/stack/cable_coil/yellow(src)
	new /obj/item/stack/cable_coil/blue(src)
	new /obj/item/stack/cable_coil/green(src)
	new /obj/item/stack/cable_coil/pink(src)
	new /obj/item/stack/cable_coil/orange(src)
	new /obj/item/stack/cable_coil/cyan(src)
	new /obj/item/stack/cable_coil/white(src)
