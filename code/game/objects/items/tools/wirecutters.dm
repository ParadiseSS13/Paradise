/obj/item/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 6
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	sharp = 1
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	tool_behaviour = TOOL_WIRECUTTER
	var/random_color = TRUE

/obj/item/wirecutters/New(loc, param_color = null)
	..()
	if(random_color)
		if(!param_color)
			param_color = pick("yellow", "red")
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
		..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is cutting at [user.p_their()] arteries with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, usesound, 50, 1, -1)
	return BRUTELOSS

/obj/item/wirecutters/brass
	name = "brass wirecutters"
	desc = "A pair of wirecutters made of brass. The handle feels freezing cold to the touch."
	icon_state = "cutters_brass"
	toolspeed = 0.5
	random_color = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters"
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=4;abductor=3"
	random_color = FALSE

/obj/item/wirecutters/cyborg
	name = "wirecutters"
	desc = "This cuts wires."
	toolspeed = 0.5

/obj/item/wirecutters/power
	name = "jaws of life"
	desc = "A set of jaws of life, the magic of science has managed to fit it down into a device small enough to fit in a tool belt. It's fitted with a cutting head."
	icon_state = "jaws_cutter"
	item_state = "jawsoflife"
	origin_tech = "materials=2;engineering=2"
	materials = list(MAT_METAL=150,MAT_SILVER=50,MAT_TITANIUM=25)
	usesound = 'sound/items/jaws_cut.ogg'
	toolspeed = 0.25
	random_color = FALSE

/obj/item/wirecutters/power/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")
	playsound(loc, 'sound/items/jaws_cut.ogg', 50, 1, -1)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/head/head = H.bodyparts_by_name["head"]
		if(head)
			head.droplimb(0, DROPLIMB_BLUNT, FALSE, TRUE)
			playsound(loc,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
	return BRUTELOSS

/obj/item/wirecutters/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	var/obj/item/crowbar/power/pryjaws = new /obj/item/crowbar/power
	to_chat(user, "<span class='notice'>You attach the pry jaws to [src].</span>")
	qdel(src)
	user.put_in_active_hand(pryjaws)
