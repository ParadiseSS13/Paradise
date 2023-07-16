/obj/item/boltcutters
	name = "boltcutters"
	desc = "A heavy duty tool for snipping locks and high voltage cabling."
	icon = 'icons/obj/tools.dmi'
	icon_state = "boltcutters"
	flags = CONDUCT
	slot_flags = SLOT_BACK
	force = 10
	throw_speed = 5
	throw_range = 3
	w_class = WEIGHT_CLASS_HUGE
	materials = list(MAT_METAL = 2000)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("clips", "shreds", "slashes")
	hitsound = 'sound/items/wirecutter.ogg'
	usesound = 'sound/items/wirecutter.ogg'
	drop_sound = 'sound/items/handling/wirecutter_drop.ogg'
	pickup_sound = 'sound/items/handling/wirecutter_pickup.ogg'
	sharp = TRUE
	toolspeed = 1
	tool_behaviour = TOOL_WIRECUTTER


/obj/item/wirecutters/New(loc, param_color = null)
	..()
	if(random_color)
		if(!param_color)
			param_color = pick("yellow", "red")
		belt_icon = "wirecutters_[param_color]"
		icon_state = "cutters_[param_color]"

#warn Add custom animation for using the tool
#warn Add sounds for boltcutters
#warn Add Ability for people to cut off fingers when targetting the hands
/obj/item/wirecutters/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && istype(C.handcuffed, /obj/item/restraints/handcuffs/cable))
		user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
		QDEL_NULL(C.handcuffed)
		if(C.buckled && C.buckled.buckle_requires_restraints)
			C.buckled.unbuckle_mob(C)
		C.update_handcuffed()
		return


	return ..()

/obj/item/wirecutters/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is cutting at [user.p_their()] arteries with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, usesound, 50, 1, -1)
	return BRUTELOSS

