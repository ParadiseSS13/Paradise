//MISC WEAPONS

//This file contains /obj/item's that do not fit in any other category and are not big enough to warrant individual files.
/*CURRENT CONTENTS
	Ball Toy
	Cane
	Crutches
	Cardboard Tube
	Fan
	Gaming Kit
	Kidan Globe
	Lightning
	Newton Cradle
	Red Phone
	Popsicle Sticks
*/

/obj/item/balltoy
	name = "ball toy"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "rollball"
	desc = "A device bored paper pushers use to remind themselves that the time did not stop yet."
	new_attack_chain = TRUE

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon_state = "cane"
	inhand_icon_state = "stick"
	flags = CONDUCT
	force = 5.0
	throwforce = 7.0
	materials = list(MAT_METAL = 2000)
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed", "Vaudevilled")
	new_attack_chain = TRUE

/obj/item/cane/get_crutch_efficiency()
	return 2

/obj/item/blindcane
	name = "white cane"
	desc = "A white cane for the visually impaired to feel their way around, though not sturdy enough to lean on. It easily folds up into a bag or pocket."
	icon = 'icons/obj/weapons/melee.dmi' // Smack!
	icon_state = "blindcane"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	flags = CONDUCT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL // Canes can fold up to fit in bags or pockets
	materials = list(MAT_METAL = 1000)
	attack_verb = list("smacked", "whacked", "bumped", "struck")
	new_attack_chain = TRUE

/obj/item/blindcane/pre_attack(atom/target, mob/living/user, params)
	. = ..()
	if(!(ismob(target) || istype(target, /obj/structure) || istype(target, /obj/machinery)))
		return

	if(user.a_intent == INTENT_HELP)
		user.do_attack_animation(target)
		user.visible_message(
			SPAN_NOTICE("[user] has prodded [target] with [src]."),
			SPAN_NOTICE("You prod [target] with [src].")
		)
		if(HAS_TRAIT(user, TRAIT_BLIND))
			to_chat(user, SPAN_NOTICE("You feel [target] with [src]."))
		playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)

	else if(user.a_intent == INTENT_DISARM && ismob(target)) //Harmless smack
		user.visible_message(
			SPAN_NOTICE("[user] harmlessly slaps [target] with the end of the white cane."),
			SPAN_NOTICE("You harmlessly slap [target] with the end of the white cane.")
		)
		if(HAS_TRAIT(user, TRAIT_BLIND))
			to_chat(user, SPAN_NOTICE("You harmlessly slap [target] with the end of the white cane."))
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		playsound(loc, 'sound/effects/woodhit.ogg', 50, TRUE, -1)

	else // If the user is not on help or disarm intent
		return // Harmful smack

	return FINISH_ATTACK | MELEE_COOLDOWN_PREATTACK

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
	materials = list(MAT_METAL = 1000, MAT_TITANIUM = 500)
	attack_verb = list("bludgeoned", "whacked", "cracked")
	/// Is the secret compartment open?
	var/is_open = FALSE
	/// Tiny item that can be hidden on crutches with a screwdriver
	var/obj/item/hidden_object = null
	new_attack_chain = TRUE

/obj/item/crutches/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 5, force_wielded = 5, icon_wielded = "crutches1")

/obj/item/crutches/Destroy()
	if(hidden_object)
		hidden_object.forceMove(get_turf(src))
		hidden_object = null
	return ..()

/obj/item/crutches/update_icon_state() //Currently only here to fuck with the on-mob icons.
	icon_state = "crutches0"
	return ..()

/obj/item/crutches/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_open)
		return ..()

	if(!(!hidden_object && used.tool_behaviour != TOOL_SCREWDRIVER && used.w_class == WEIGHT_CLASS_TINY))
		return ..()

	if(istype(used, /obj/item/disk/nuclear))
		to_chat(user, SPAN_WARNING("You think you're gonna need more than crutches if your employers find out what you just tried to do..."))
		return ITEM_INTERACT_COMPLETE

	if(used.flags & ABSTRACT)
		return ITEM_INTERACT_COMPLETE

	if(!user.unequip(used))
		to_chat(user, SPAN_NOTICE("[used] is stuck to your hand! You can't put it inside [src]!"))
		return ITEM_INTERACT_COMPLETE

	used.forceMove(src)
	hidden_object = used
	add_fingerprint(user)
	to_chat(user, SPAN_NOTICE("You hide [used] inside the crutch tip."))

/obj/item/crutches/attack_hand(mob/user, pickupfireoverride)
	if(!is_open)
		return ..()
	if(hidden_object)
		user.put_in_hands(hidden_object)
		to_chat(user, SPAN_NOTICE("You remove [hidden_object] from the crutch tip!"))
		hidden_object = null

	add_fingerprint(user)

/obj/item/crutches/screwdriver_act(mob/living/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, SPAN_NOTICE("You screw the crutch tip [is_open ? "closed" : "open"]."))
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
	attack_verb = list("bonked", "thunked")
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 5
	materials = list(MAT_CARDBOARD = 2000)
	new_attack_chain = TRUE

/obj/item/c_tube/decompile_act(obj/item/matter_decompiler/C, mob/user)
	qdel(src)
	return TRUE

/obj/item/c_tube/should_play_hitsound(damage)
	return TRUE

/obj/item/fan
	name = "desk fan"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "fan"
	desc = "A small desktop fan. The button seems to be stuck in the 'on' position."
	new_attack_chain = TRUE

/obj/item/kidanglobe
	name = "Kidan homeworld globe"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "kidanglobe"
	desc = "A globe of the Kidan homeworld."
	new_attack_chain = TRUE

/obj/item/lightning
	name = "lightning"
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	desc = "test lightning."
	new_attack_chain = TRUE

/obj/item/lightning/Initialize(mapload)
	. = ..()
	icon_state = "1"

/obj/item/lightning/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	if(..())
		return FINISH_ATTACK
	var/angle = get_angle(target, user)
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
	user.Beam(target, "lightning", 'icons/obj/zap.dmi', 50, 15)

/obj/item/newton
	name = "\improper Newton's cradle"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "newton"
	desc = "A device bored paper pushers use to remind themselves that time did not stop yet. Contains gravity."
	new_attack_chain = TRUE

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
	new_attack_chain = TRUE

/obj/item/phone/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(cooldown < world.time - 20)
		playsound(user.loc, 'sound/weapons/ring.ogg', 50, 1)
		cooldown = world.time
		add_fingerprint(user)

/obj/item/popsicle_stick
	name = "popsicle stick"
	desc = "A small wooden stick, usually topped by popsicles or other frozen treats."
	icon = 'icons/obj/food/frozen_treats.dmi'
	icon_state = "popsicle_stick"
	new_attack_chain = TRUE
