// Ported from TG
/obj/item/paperplane
	name = "paper plane"
	desc = "Paper, folded in the shape of a plane."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paperplane"
	throw_range = 7
	throw_speed = 1
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	burn_state = FLAMMABLE
	burntime = 5
	no_spin = TRUE

	var/obj/item/paper/internal_paper

/obj/item/paperplane/New(loc, obj/item/paper/new_paper)
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	if(new_paper)
		internal_paper = new_paper
		flags = new_paper.flags
		color = new_paper.color
		new_paper.forceMove(src)
	else
		internal_paper = new /obj/item/paper(src)
	update_icon()

/obj/item/paperplane/Destroy()
	QDEL_NULL(internal_paper)
	return ..()

/obj/item/paperplane/suicide_act(mob/living/user)
	user.Stun(10)
	user.visible_message("<span class='suicide'>[user] jams [name] in [user.p_their()] nose. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.EyeBlurry(6)
	var/obj/item/organ/internal/eyes/E = user.get_int_organ(/obj/item/organ/internal/eyes)
	if(E)
		E.take_damage(8, 1)
	sleep(10)
	return BRUTELOSS

/obj/item/paperplane/update_icon()
	overlays.Cut()
	var/list/stamped = internal_paper.stamped
	if(!stamped)
		stamped = new
	else if(stamped)
		for(var/S in stamped)
			var/obj/item/stamp = S
			var/image/stampoverlay = image('icons/obj/bureaucracy.dmi', "paperplane_[initial(stamp.icon_state)]")
			overlays += stampoverlay

/obj/item/paperplane/attack_self(mob/user) // Unfold the paper plane
	to_chat(user, "<span class='notice'>You unfold [src].</span>")
	if(internal_paper)
		internal_paper.forceMove(get_turf(src))
		user.put_in_hands(internal_paper)
		internal_paper = null
		qdel(src)

/obj/item/paperplane/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()

	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		to_chat(user, "<span class='notice'>You should unfold [src] before changing it.</span>")
		return

	else if(istype(P, /obj/item/stamp)) 	//we don't randomize stamps on a paperplane
		internal_paper.attackby(P, user) //spoofed attack to update internal paper.
		update_icon()

	else if(is_hot(P))
		if(user.disabilities & CLUMSY && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
				"<span class='userdanger'>You miss [src] and accidentally light yourself on fire!</span>")
			user.unEquip(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!in_range(user, src)) //to prevent issues as a result of telepathically lighting a paper
			return
		user.unEquip(src)
		user.visible_message("<span class='danger'>[user] lights [src] on fire with [P]!</span>", "<span class='danger'>You lights [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)

/obj/item/paperplane/throw_impact(atom/hit_atom)
	if(..())
		return
	if(!ishuman(hit_atom))
		return
	var/mob/living/carbon/human/H = hit_atom
	if(prob(2))
		if(H.head && H.head.flags_cover & HEADCOVERSEYES)
			return
		if(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES)
			return
		if(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES)
			return
		visible_message("<span class='danger'>[src] hits [H] in the eye!</span>")
		H.EyeBlurry(6)
		H.Weaken(2)
		var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(E)
			E.take_damage(8, 1)
		H.emote("scream")

/obj/item/paper/AltClick(mob/user, obj/item/I)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		I = H.is_in_hands(/obj/item/paper)
		if(I)
			ProcFoldPlane(H, I)
	else
		..()

/obj/item/paper/proc/ProcFoldPlane(mob/living/carbon/user, obj/item/I)
	if(istype(user))
		if((!in_range(src, user)) || user.stat || user.restrained())
			return
		to_chat(user, "<span class='notice'>You fold [src] into the shape of a plane!</span>")
		user.unEquip(src)
		I = new /obj/item/paperplane(user, src)
		user.put_in_hands(I)
	else
		to_chat(user, "<span class='notice'>You lack the dexterity to fold [src].</span>")
