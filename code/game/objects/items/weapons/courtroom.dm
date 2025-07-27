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

/obj/item/gavelhammer/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] has sentenced [user.p_themselves()] to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
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

/obj/item/gavelblock/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/gavelhammer))
		return
	if(world.time > next_gavel_hit)
		playsound(loc, 'sound/items/gavel.ogg', 100, 1)
		next_gavel_hit = world.time + 5 SECONDS
		user.visible_message("<span class='warning'>[user] strikes \the [src] with \the [I].</span>")
