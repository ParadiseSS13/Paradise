/obj/item/whetstone
	name = "whetstone"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "whetstone"
	desc = "A block of stone used to sharpen things."
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/screwdriver.ogg'
	var/used = FALSE
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"
	var/requires_sharpness = TRUE
	var/claw_damage_increase = 2


/obj/item/whetstone/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, SPAN_WARNING("The whetstone is too worn to use again!"))
		return
	if(requires_sharpness && !I.sharp)
		to_chat(user, SPAN_WARNING("You can only sharpen items that are already sharp, such as knives!"))
		return
	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max)

	if((signal_out & COMPONENT_BLOCK_SHARPEN_MAXED) || I.force >= max || I.throwforce >= max) //If the item's components enforce more limits on maximum power from sharpening,  we fail
		to_chat(user, SPAN_WARNING("[I] is much too powerful to sharpen further!"))
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, SPAN_WARNING("[I] is not able to be sharpened right now!"))
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !(signal_out & COMPONENT_SHARPEN_APPLIED))) //No sharpening stuff twice
		to_chat(user, SPAN_WARNING("[I] has already been refined before. It cannot be sharpened further!"))
		return

	if(!(signal_out & COMPONENT_SHARPEN_APPLIED)) //If the item has a relevant component and COMPONENT_BLOCK_SHARPEN_APPLIED is returned, the item only gets the throw force increase
		I.force = clamp(I.force + increment, 0, max)

	user.visible_message(SPAN_NOTICE("[user] sharpens [I] with [src]!"), SPAN_NOTICE("You sharpen [I], making it much more deadly than before."))
	if(!requires_sharpness)
		set_sharpness(TRUE)
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	playsound(get_turf(src), usesound, 50, TRUE)
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = TRUE
	update_icon()

/obj/item/whetstone/attack_self__legacy__attackchain(mob/user)
	if(used)
		to_chat(user, SPAN_WARNING("The whetstone is too worn to use again!"))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/unarmed_attack/attack = H.get_unarmed_attack()
		if(istype(attack, /datum/unarmed_attack/claws))
			var/datum/unarmed_attack/claws/C = attack
			if(!C.has_been_sharpened)
				C.has_been_sharpened = TRUE
				attack.damage += claw_damage_increase
				H.visible_message(SPAN_NOTICE("[H] sharpens [H.p_their()] claws on [src]!"), SPAN_NOTICE("You sharpen your claws on [src]."))
				playsound(get_turf(H), usesound, 50, 1)
				name = "worn out [name]"
				desc = "[desc] At least, it used to."
				used = TRUE
				update_icon()
			else
				to_chat(user, SPAN_WARNING("You can not sharpen your claws any further!"))

/obj/item/whetstone/super
	name = "super whetstone block"
	desc = "A block of stone that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
	requires_sharpness = FALSE
	claw_damage_increase = 200
