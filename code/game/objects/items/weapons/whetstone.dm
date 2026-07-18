/obj/item/whetstone
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	desc = "A block of stone used to sharpen things."
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	var/used_up = FALSE
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = TRUE
	var/claw_damage_increase = 2
	new_attack_chain = TRUE

/obj/item/whetstone/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(used_up)
		to_chat(user, SPAN_WARNING("The whetstone is too worn to use again!"))
		return ITEM_INTERACT_COMPLETE

	if(requires_sharpness && !used.sharp)
		to_chat(user, SPAN_WARNING("You can only sharpen items have a sharpenable edge, such as knives!"))
		return ITEM_INTERACT_COMPLETE
	var/signal_out = SEND_SIGNAL(used, COMSIG_ITEM_SHARPEN_ACT, increment, max)

	if((signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) || used.force >= max || used.throwforce >= max) // If the item's components enforce more limits on maximum power from sharpening,  we fail.
		to_chat(user, SPAN_WARNING("[used] is much too powerful to sharpen further!"))
		return ITEM_INTERACT_COMPLETE

	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, SPAN_WARNING("[used] is not able to be sharpened right now!"))
		return ITEM_INTERACT_COMPLETE

	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (used.force > initial(used.force) && !(signal_out & COMPONENT_SHARPEN_APPLIED))) // No sharpening stuff twice.
		to_chat(user, SPAN_WARNING("[used] has already been refined before. It cannot be sharpened further!"))
		return ITEM_INTERACT_COMPLETE

	if(!(signal_out & COMPONENT_SHARPEN_APPLIED)) // If the item has a relevant component and COMPONENT_BLOCK_SHARPEN_APPLIED is returned, the item only gets the throw force increase.
		used.force = clamp(used.force + increment, 0, max)

	user.visible_message(
		SPAN_NOTICE("[user] sharpens [used] with [src]!"),
		SPAN_NOTICE("You sharpen [used], making it much more deadly than before."),
		SPAN_HEAR("You hear metal gliding along stone, refining to a perfect edge.")
	)
	if(!requires_sharpness)
		set_sharpness(TRUE)
	used.throwforce = clamp(used.throwforce + increment, 0, max)
	used.name = "[prefix] [used.name]"
	playsound(get_turf(src), usesound, 50, TRUE)
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used_up = TRUE
	update_icon()
	add_fingerprint(user)
	used.add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/whetstone/activate_self(mob/living/carbon/human/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	if(used_up)
		to_chat(user, SPAN_WARNING("The whetstone is too worn to use again!"))
		return ITEM_INTERACT_COMPLETE

	if(!ishuman(user))
		return ITEM_INTERACT_COMPLETE

	var/datum/unarmed_attack/attack = user.get_unarmed_attack()
	if(!istype(attack, /datum/unarmed_attack/claws))
		to_chat(user, SPAN_WARNING("You don't have claws to sharpen!"))
		return ITEM_INTERACT_COMPLETE

	var/datum/unarmed_attack/claws/claw_attack = attack
	if(claw_attack.has_been_sharpened)
		to_chat(user, SPAN_WARNING("You cannot sharpen your claws any further!"))
		return ITEM_INTERACT_COMPLETE

	claw_attack.has_been_sharpened = TRUE
	attack.damage += claw_damage_increase
	user.visible_message(
		SPAN_NOTICE("[user] sharpens [user.p_their()] claws on [src]!"),
		SPAN_NOTICE("You sharpen your claws on [src]."),
		SPAN_HEAR("You hear keratin gliding along stone, refining to a perfect edge.")
	)
	playsound(get_turf(user), usesound, 50, 1)
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used_up = TRUE
	update_icon()
	add_fingerprint(user)
	return ITEM_INTERACT_COMPLETE

/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "A block of stone that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = FALSE
	claw_damage_increase = 200
