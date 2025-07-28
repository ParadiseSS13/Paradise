/obj/item/crowbar
	name = "crowbar"
	desc = "A basic crowbar made of forged steel. Handy for opening unpowered airlocks, prying out objects, and being an improvised melee weapon."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	belt_icon = "crowbar"
	usesound = 'sound/items/crowbar.ogg'
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	materials = list(MAT_METAL = 300)
	drop_sound = 'sound/items/handling/crowbar_drop.ogg'
	pickup_sound =  'sound/items/handling/crowbar_pickup.ogg'
	origin_tech = "engineering=1;combat=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")

	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_CROWBAR

/obj/item/crowbar/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_BIT_ATTACH, PROC_REF(add_bit))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(remove_bit))

/obj/item/crowbar/red
	desc = "A hefty steel crowbar with red stripes. It'll hit a bit harder than a normal crowbar."
	icon_state = "crowbar_red"
	belt_icon = "crowbar_red"
	force = 8

/obj/item/crowbar/brass
	name = "brass crowbar"
	desc = "A brass crowbar. It feels faintly warm to the touch."
	icon_state = "crowbar_brass"
	belt_icon = "crowbar_brass"
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
	origin_tech = "materials=2"
	toolspeed = 1.25

/obj/item/crowbar/large
	name = "large crowbar"
	desc = "A very large, quite heavy crowbar. It's got some real oomph behind it."
	force = 12
	w_class = WEIGHT_CLASS_HUGE
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL = 400)
	icon_state = "crowbar_large"
	toolspeed = 0.5

/obj/item/crowbar/engineering
	name = "engineering crowbar"
	desc = "A large crowbar covered in Engineering hazard stripes and reflective material."
	force = 12
	//w_class = WEIGHT_CLASS_NORMAL Commented out so it can fit in belts
	throw_speed = 3
	throw_range = 3
	materials = list(MAT_METAL = 400)
	icon_state = "crowbar_eng"
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
		user.drop_item_to_ground(W)

	user.dust()
	return OBLITERATION

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = "A powerful and compact hydraulic crowbar typically found in construction and engineering robots."
	usesound = 'sound/items/jaws_pry.ogg'
	force = 10
	toolspeed = 0.5

/obj/item/crowbar/cyborg/red
	name = "emergency hydraulic crowbar"
	desc = "A hydraulic prying tool, compact but powerful. Supplied to non-construction cyborgs primarily to allow them to pry open airlocks during power outages."
	icon_state = "crowbar_red"

/obj/item/crowbar/power
	name = "jaws of life"
	desc = "A compact and powerful industrial tool with a modular head. This one has a set of prying jaws attached, which are strong enough to pry open powered airlocks."
	icon_state = "jaws_pry"
	inhand_icon_state = "jawsoflife"
	belt_icon = "jaws"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	origin_tech = "materials=2;engineering=2"
	usesound = 'sound/items/jaws_pry.ogg'
	force = 15
	toolspeed = 0.25
	var/airlock_open_time = 100 // Time required to open powered airlocks

/obj/item/crowbar/power/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ADVANCED_SURGICAL, ROUNDSTART_TRAIT)

/obj/item/crowbar/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src]. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/jaws_pry.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/crowbar/power/attack_self__legacy__attackchain(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/wirecutters/power/cutjaws = new /obj/item/wirecutters/power
	to_chat(user, "<span class='notice'>You attach the cutting jaws to [src].</span>")
	for(var/obj/item/smithed_item/tool_bit/bit in attached_bits)
		bit.on_detached()
		bit.forceMove(cutjaws)
		cutjaws.attached_bits += bit
		bit.on_attached(cutjaws)
	qdel(src)
	user.put_in_active_hand(cutjaws)
