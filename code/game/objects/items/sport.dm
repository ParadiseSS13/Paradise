/obj/item/beach_ball
	name = "beach ball"
	icon = 'icons/misc/beach.dmi'
	desc = "An inflatable ball of fun, enjoyed on many beaches."
	icon_state = "ball"
	inhand_icon_state = "beachball"
	throw_speed = 1
	throw_range = 20
	flags = CONDUCT
	new_attack_chain = TRUE
	/// Whether `attack_self` will move ("dribble") it to the other hand
	var/dribbleable = FALSE // Most balls do not have a dribble animation

/obj/item/beach_ball/activate_self(mob/user)
	if(..())
		return
	if(!dribbleable)
		return

	if(!user.get_inactive_hand()) // We ballin
		user.unequip(src)
		user.put_in_inactive_hand(src)
	else
		to_chat(user, "<span class='warning'>You can't dribble to an occupied hand!</span>")

/obj/item/beach_ball/baseball
	name = "baseball"
	desc = "Take me out to the ball game."
	icon = 'icons/obj/basketball.dmi'
	icon_state = "baseball"
	inhand_icon_state = null // no icon state
	w_class = WEIGHT_CLASS_SMALL

/obj/item/beach_ball/dodgeball
	name = "dodgeball"
	desc = "Used for playing the most violent and degrading of childhood games. This one is connected to the laser tag armour system."
	icon = 'icons/obj/basketball.dmi'
	icon_state = "dodgeball"
	inhand_icon_state = "dodgeball"
	dribbleable = TRUE
	var/list/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)

/obj/item/beach_ball/dodgeball/throw_impact(atom/hit_atom)
	. = ..()
	var/mob/living/carbon/human/M = hit_atom
	if(ishuman(hit_atom) && (M.wear_suit?.type in suit_types))
		if(M.is_holding(src))
			return
		playsound(src, 'sound/items/dodgeball.ogg', 50, 1)
		M.KnockDown(6 SECONDS)

/obj/item/beach_ball/holoball
	name = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	icon = 'icons/obj/basketball.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	dribbleable = TRUE
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets

/obj/structure/holohoop
	name = "basketball hoop"
	desc = "Boom, Shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	pass_flags_self = LETPASSTHROW | PASSTAKE

/obj/structure/holohoop/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/grab) && get_dist(src, user) <= 1)
		var/obj/item/grab/G = W
		if(G.state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return ITEM_INTERACT_COMPLETE
		G.affecting.forceMove(loc)
		G.affecting.Weaken(10 SECONDS)
		visible_message("<span class='warning'>[G.assailant] dunks [G.affecting] into [src]!</span>")
		qdel(W)
		return ITEM_INTERACT_COMPLETE
	else if(isitem(W) && get_dist(src,user) <= 1)
		user.drop_item(src)
		visible_message("<span class='notice'>[user] dunks [W] into [src]!</span>")
		return ITEM_INTERACT_COMPLETE

/obj/structure/holohoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && !isprojectile(AM))
		var/atom/movable/thrower = throwingdatum?.get_thrower()
		if(prob(50) || HAS_TRAIT(thrower, TRAIT_BADASS))
			AM.forceMove(get_turf(src))
			visible_message("<span class='notice'>Swish! [AM] lands in [src].</span>")
		else
			visible_message("<span class='danger'>[AM] bounces off of [src]'s rim!</span>")
			return ..()
	else
		return ..()
