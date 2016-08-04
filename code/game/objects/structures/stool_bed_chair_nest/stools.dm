/obj/structure/stool
	name = "stool"
	desc = "Apply butt."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	anchored = 1.0

/obj/structure/stool/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(70))
				new /obj/item/stack/sheet/metal(src.loc)
				qdel(src)
				return
		if(3.0)
			if(prob(50))
				new /obj/item/stack/sheet/metal(src.loc)
				qdel(src)
				return
	return

/obj/structure/stool/blob_act()
	if(prob(75))
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)

/obj/structure/stool/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(src.loc)
		qdel(src)
	return

/obj/structure/stool/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params, skip_fucking_stool_shit = 0)
	if(skip_fucking_stool_shit)
		return ..(over_object)
	if(istype(over_object, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = over_object
		if(H==usr && !H.restrained() && !H.stat && in_range(src, over_object))
			var/obj/item/weapon/stool/S = new/obj/item/weapon/stool()
			S.origin = src
			src.loc = S
			H.put_in_hands(S)
			H.visible_message("<span class='warning'>[H] grabs [src] from the floor!</span>", "<span class='warning'>You grab [src] from the floor!</span>")

/obj/item/weapon/stool
	name = "stool"
	desc = "Uh-hoh, bar is heating up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	force = 10
	throwforce = 10
	w_class = 5
	var/obj/structure/stool/origin = null

/obj/item/weapon/stool/attack_self(mob/user as mob)
	..()
	origin.loc = get_turf(src)
	user.unEquip(src)
	user.visible_message("<span class='notice'>[user] puts [src] down.</span>", "<span class='notice'>You put [src] down.</span>")
	qdel(src)

/obj/item/weapon/stool/attack(mob/M as mob, mob/user as mob)
	if(prob(5) && istype(M,/mob/living))
		user.visible_message("<span class='danger'>[user] breaks [src] over [M]'s back!.</span>")
		user.unEquip(src)
		var/obj/item/stack/sheet/metal/m = new/obj/item/stack/sheet/metal
		m.loc = get_turf(src)
		qdel(src)
		var/mob/living/T = M
		T.Weaken(5)
		return
	..()
