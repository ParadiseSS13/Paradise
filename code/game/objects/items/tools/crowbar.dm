/obj/item/crowbar
	name = "pocket crowbar"
	desc = "A small crowbar. This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 7
	item_state = "crowbar"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50)
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 1

	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/crowbar/large
	name = "crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because its too big."
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL=70)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Designed to replace crowbar in construction cyborgs."
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5