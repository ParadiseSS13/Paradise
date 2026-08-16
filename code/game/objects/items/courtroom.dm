// Contains:
// Gavel Hammer
// Gavel Block

/obj/item/gavelhammer
	name = "gavel hammer"
	desc = "Order, order! No bombs in my courthouse."
	icon_state = "gavelhammer"
	force = 5.0
	throwforce = 6.0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bashed", "battered", "judged", "whacked")
	resistance_flags = FLAMMABLE
	new_attack_chain = TRUE

/obj/item/gavelhammer/suicide_act(mob/user)
	user.visible_message(SPAN_SUICIDE("[user] has sentenced [user.p_themselves()] to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/items/gavel.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/gavelblock
	name = "gavel block"
	desc = "Smack it with a gavel hammer when the assistants get rowdy."
	icon_state = "gavelblock"
	force = 2.0
	throwforce = 2.0
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/next_gavel_hit
	new_attack_chain = TRUE

/obj/item/gavelblock/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/gavelhammer))
		return ..()
	if(world.time > next_gavel_hit)
		playsound(loc, 'sound/items/gavel.ogg', 100, 1)
		next_gavel_hit = world.time + 5 SECONDS
		user.visible_message(
			SPAN_WARNING("[user] strikes [src] with [used]!"),
			SPAN_NOTICE("You strike [src] with [used]."),
			SPAN_HEAR("You hear a gavel banging!")
		)
		add_fingerprint(user)
		used.add_fingerprint(user)
		return ITEM_INTERACT_COMPLETE

