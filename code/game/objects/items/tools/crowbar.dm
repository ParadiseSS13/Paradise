/obj/item/crowbar
	name = "crowbar"
	desc = "This handy tool is useful for lots of things, such as prying floor tiles or opening unpowered doors."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	item_state = "crowbar"
	belt_icon = "crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL = 300)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	toolspeed = 1

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	item_state = "crowbar_red"
	belt_icon = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	icon_state = "crowbar_brass"
	item_state = "crowbar_brass"
	toolspeed = 0.5
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/crowbar/small
	name = "miniature titanium crowbar"
	desc = "A tiny, lightweight titanium crowbar. It fits handily in your pocket."
	force = 3
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 3
	materials = list(MAT_TITANIUM = 250)
	icon_state = "crowbar_titanium"
	item_state = "crowbar_titanium"
	origin_tech = "materials=2"
	toolspeed = 1.25

/obj/item/crowbar/large
	name = "large crowbar"
	desc = "It's a big crowbar. It doesn't fit in your pockets, because its too big."
	force = 12
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL = 400)
	icon_state = "crowbar_large"
	item_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/engineering
	name = "engineering crowbar"
	desc = "It's a big crowbar, perfect for fending off those assistants trying to get at your gloves."
	force = 12
	//w_class = WEIGHT_CLASS_NORMAL Commented out so it can fit in belts
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL = 400)
	icon_state = "crowbar_eng"
	item_state = "crowbar_eng"
	belt_icon = "crowbar_eng"
	toolspeed = 0.5

/obj/item/crowbar/engineering/suicide_act(mob/living/user)

	if(!user)
		return

	user.visible_message("<span class='suicide'>[user] looks up and hooks [src] into a ceiling tile! It looks like [user.p_theyre()] trying to commit suicide!</span>")

	user.Immobilize(10 SECONDS)
	playsound(loc, 'sound/items/crowbar.ogg', 50, TRUE, -1)

	sleep(2 SECONDS)
	add_fingerprint(user)

	to_chat(user, "<span class='userdanger'>You pry open the ceiling tile above you and look beyond it.. oh God, what the hell is <i>that?!</i></span>")
	user.emote("scream")
	animate_fading_leap_up(user)

	for(var/obj/item/W in user)
		user.unEquip(W)

	user.dust()
	return OBLITERATION

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Designed to replace crowbar in construction cyborgs."
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5

/obj/item/crowbar/cyborg/red
	name = "emergency hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Supplied to non-construction cyborgs primarily to allow them to pry open airlocks during power outages."
	icon_state = "crowbar_red"

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a prying head."
	flags = CONDUCT
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	belt_icon = "jaws"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.25
	w_class = WEIGHT_CLASS_NORMAL
	var/airlock_open_time = 100 // Time required to open powered airlocks

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src]. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, 1, -1)
	return BRUTELOSS

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(cutjaws)
