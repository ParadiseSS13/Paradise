/obj/item/weapon/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	item_state = "briefcase"
	flags = CONDUCT
	hitsound = "swing_hit"
	force = 8.0
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 21
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	burn_state = FLAMMABLE
	burntime = 20
	var/cuff
	var/cuff_active = FALSE

/obj/item/weapon/storage/briefcase/New()
	..()

/obj/item/weapon/storage/briefcase/MouseDrop_T(obj/item/weapon/restraints/handcuffs/I, mob/user)
	if(user.incapacitated() || !ishuman(user))
		return

	if(cuffs)
		to_chat(user, "<span class='notice'>[src] already has [cuff.name] attached!</span>")

	else
		to_chat(user, "<span class='notice'>You start attaching [I] to [src]'s handle.</span>")
		if(do_after(user, 20))
			cuff = I
			to_chat(user, "<span class='notice'>You successfully clip the shackle of [I] around [src]'s handle.'</span>")
			qdel(I)
			desc += " It has [cuff.name] hanging from its handle."

/obj/item/weapon/storage/briefcase/attack_self(mob/living/human/user)
	if(!cuff)
		return

	var/hand
	if(user.incapacitated())
		return

	if(user.l_hand == src)
		user.l_hand.flags ^= NODROP
		cuff_active = !cuff_active
		hand = "left"

	else if(user.r_hand == src)
		user.r_hand.flags ^= NODROP
		cuff_active = !cuff_active
		hand = "right"

	else
		to_chat(user, "<span class='notice'>[src] isn't in your hand!</span>")
		return

	if(cuff_active)
		to_chat(user, "<span class='notice'>You attach [src] to your [hand] wrist using its [I.name]</span>")
	else
		to_chat(user, "<span class='notice'>You unclip [src]'s shackle from your [hand] wrist.</span>")