/obj/item/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters"
	belt_icon = "wirecutters_red"
	flags = CONDUCT
	slot_flags = SLOT_FLAG_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 370)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/wirecutter_drop.ogg'
	pickup_sound =  'sound/items/handling/wirecutter_pickup.ogg'
	sharp = TRUE
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 50, ACID = 30)
	tool_behaviour = TOOL_WIRECUTTER
	var/random_color = TRUE

/obj/item/wirecutters/New(loc, param_color = null)
	..()
	if(random_color)
		if(!param_color)
			param_color = pick("yellow", "red")
		belt_icon = "wirecutters_[param_color]"
		icon_state = "cutters_[param_color]"

/obj/item/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/restraints/handcuffs/cable))
		user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
		QDEL_NULL(C.handcuffed)
		if(C.buckled && C.buckled.buckle_requires_restraints)
			C.buckled.unbuckle_mob(C)
		C.update_handcuffed()
		return
	else
		return ..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is cutting at [user.p_their()] [is_robotic_suicide(user) ? "wiring" : "arteries"] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, usesound, 50, TRUE, -1)
	return BRUTELOSS

/obj/item/wirecutters/proc/is_robotic_suicide(mob/user)
	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/chest/chest = H.bodyparts_by_name["chest"]
	if(!chest)
		return FALSE

	return chest.is_robotic()

/obj/item/wirecutters/security
	name = "security wirecutters"
	desc = "A pair of wirecutters with a tactical grip and robust build."
	icon_state = "cutters_sec"
	belt_icon = "wirecutters_sec"
	item_state = "cutters_red" //shh
	attack_verb = list("reformed", "robusted", "102'd") //102: battery in space law
	force = 9 //same as seclites
	toolspeed = 0.75
	random_color = FALSE

/obj/item/wirecutters/security/suicide_act(mob/living/user)

	if(!user)
		return
	user.visible_message("<span class='suicide'>[user] is cutting [user.p_themselves()] free from the mortal coil! It looks like [user.p_theyre()] trying to commit suicide!</span>")


	user.Immobilize(10 SECONDS)
	sleep(2 SECONDS)
	add_fingerprint(user)

	playsound(loc, usesound, 50, TRUE, -1)

	new /obj/item/restraints/handcuffs/cable/zipties/used(user.loc)

	for(var/obj/item/W in user)
		user.unEquip(W)

	user.dust()
	return OBLITERATION

/obj/item/wirecutters/brass
	name = "brass wirecutters"
	desc = "A pair of wirecutters made of brass. The handle feels freezing cold to the touch."
	icon_state = "cutters_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wirecutters/cyborg
	name = "wirecutters"
	desc = "This cuts wires."
	toolspeed = 0.5

/obj/item/wirecutters/cyborg/drone

/obj/item/wirecutters/cyborg/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOW_WIRE_INFO, ROUNDSTART_TRAIT) // Drones are linked to the station

/obj/item/wirecutters/power
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a cutting head."
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	belt_icon = "jaws"
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	usesound = 'sound/items/jaws_cut.ogg'
	toolspeed = 0.25
	w_class = WEIGHT_CLASS_NORMAL
	random_color = FALSE

/obj/item/wirecutters/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")

	if(!use_tool(user, user, 3 SECONDS, volume = tool_volume))
		return SHAME

	if(!ishuman(user))
		return BRUTELOSS

	var/mob/living/carbon/human/H = user
	var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
	if(!head)
		user.visible_message("<span class='suicide'>...but [user.p_they()] [user.p_are()] already headless! How embarassing.</span>")
		return SHAME

	head.droplimb(FALSE, DROPLIMB_SHARP, FALSE, TRUE)

	if(user.stat != DEAD)
		user.visible_message("<span class='suicide'>...but [user.p_they()] didn't need it anyway! How embarassing.</span>")
		return SHAME

	return OXYLOSS

/obj/item/wirecutters/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/crowbar/power/pryjaws = new /obj/item/crowbar/power
	to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(pryjaws)
