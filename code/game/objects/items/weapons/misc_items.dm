//MISC WEAPONS

//This file contains /obj/item's that do not fit in any other category and are not big enough to warrant individual files.
/*CURRENT CONTENTS
	Ball Toy
	Cane
	Crutches
	Cardboard Tube
	Fan
	Gaming Kit
	Gift
	Kidan Globe
	Lightning
	Newton Cradle
	PAI cable
	Red Phone
	Popsicle Sticks
*/

/obj/item/balltoy
	name = "ball toy"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "rollball"
	desc = "A device bored paper pushers use to remind themselves that the time did not stop yet."

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon_state = "cane"
	inhand_icon_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	materials = list(MAT_METAL=50)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed", "Vaudevilled")

/obj/item/cane/get_crutch_efficiency()
	return 2

/obj/item/crutches
	name = "crutches"
	desc = "A medical device to help those who have injured or missing legs to walk."
	gender = PLURAL
	icon = 'icons/obj/surgery.dmi' // I mean like... cmon its basically medical.dmi
	icon_state = "crutches0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	flags = CONDUCT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 500)
	attack_verb = list("bludgeoned", "whacked", "cracked")
	/// Is the secret compartment open?
	var/is_open = FALSE
	/// Tiny item that can be hidden on crutches with a screwdriver
	var/obj/item/hidden = null

/obj/item/crutches/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 5, force_wielded = 5, icon_wielded = "crutches1")

/obj/item/crutches/Destroy()
	if(hidden)
		hidden.forceMove(get_turf(src))
		hidden = null
	return ..()

/obj/item/crutches/update_icon_state() //Currently only here to fuck with the on-mob icons.
	icon_state = "crutches0"
	return ..()

/obj/item/crutches/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	. = ..()
	if(!is_open)
		return
	if(!hidden && I.tool_behaviour != TOOL_SCREWDRIVER && I.w_class == WEIGHT_CLASS_TINY)
		if(istype(I, /obj/item/disk/nuclear))
			to_chat(user, "<span class='warning'>You think you're gonna need more than crutches if your employers find out what you just tried to do...</span>")
			return
		if(I.flags & ABSTRACT)
			return
		if(!user.unequip(I))
			to_chat(user, "<span class='notice'>[I] doesn't seem to want to go into [src]!</span>")
			return
		I.forceMove(src)
		hidden = I
		to_chat(user, "<span class='notice'>You hide [I] inside the crutch tip.</span>")

/obj/item/crutches/attack_hand(mob/user, pickupfireoverride)
	if(!is_open)
		return ..()
	if(hidden)
		user.put_in_hands(hidden)
		to_chat(user, "<span class='notice'>You remove [hidden] from the crutch tip!</span>")
		hidden = null

	add_fingerprint(user)

/obj/item/crutches/screwdriver_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You screw the crutch tip [is_open ? "closed" : "open"].</span>")
	is_open = !is_open

/obj/item/crutches/get_crutch_efficiency()
	// 6 when wielded, 2 when not. Basically a small upgrade to just having 2 canes in each hand
	return 2 + (4 * HAS_TRAIT(src, TRAIT_WIELDED)) // less efficient when you're holding both in a single hand

/obj/item/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	icon_state = "c_tube"
	hitsound = 'sound/items/cardboard_tube.ogg'
	throwforce = 1
	force = 1
	attack_verb = list("bonked", "thunked")
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 5

/obj/item/c_tube/decompile_act(obj/item/matter_decompiler/C, mob/user)
	qdel(src)
	return TRUE



/obj/item/fan
	name = "desk fan"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "fan"
	desc = "A small desktop fan. The button seems to be stuck in the 'on' position."


/obj/item/gift
	name = "gift"
	desc = "A wrapped item."
	icon_state = "gift3"
	inhand_icon_state = "gift"
	w_class = WEIGHT_CLASS_BULKY
	var/size = 3.0
	var/obj/item/gift = null

/obj/item/gift/emp_act(severity)
	..()
	gift.emp_act(severity)

/obj/item/kidanglobe
	name = "Kidan homeworld globe"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "kidanglobe"
	desc = "A globe of the Kidan homeworld."

/obj/item/lightning
	name = "lightning"
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	desc = "test lightning."

/obj/item/lightning/New()
	..()
	icon_state = "1"

/obj/item/lightning/afterattack__legacy__attackchain(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
	var/angle = get_angle(A, user)
	//to_chat(world, angle)
	angle = round(angle) + 45
	if(angle > 180)
		angle -= 180
	else
		angle += 180

	if(!angle)
		angle = 1
	//to_chat(world, "adjusted [angle]")
	icon_state = "[angle]"
	//to_chat(world, "[angle] [(get_dist(user, A) - 1)]")
	user.Beam(A, "lightning", 'icons/obj/zap.dmi', 50, 15)

/obj/item/newton
	name = "newton cradle"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "newton"
	desc = "A device bored paper pushers use to remind themselves that time did not stop yet. Contains gravity."

/obj/item/pai_cable
	name = "data cable"
	desc = "A flexible coated cable with a universal jack on one end."
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"
	var/obj/machinery/machine

/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon_state = "red_phone"
	flags = CONDUCT
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'
	var/cooldown = 0

/obj/item/phone/attack_self__legacy__attackchain(mob/user)
	if(cooldown < world.time - 20)
		playsound(user.loc, 'sound/weapons/ring.ogg', 50, 1)
		cooldown = world.time

/obj/item/popsicle_stick
	name = "popsicle stick"
	desc = "A small wooden stick, usually topped by popsicles or other frozen treats."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "popsicle_stick"
