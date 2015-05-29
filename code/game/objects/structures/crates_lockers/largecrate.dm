/obj/structure/largecrate
	name = "large crate"
	desc = "A hefty wooden crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "densecrate"
	density = 1
	var/obj/item/weapon/paper/manifest/manifest

/obj/structure/largecrate/New()
	..()
	update_icon()

/obj/structure/largecrate/update_icon()
	..()
	overlays.Cut()
	if(manifest)
		overlays += "manifest"

/obj/structure/largecrate/attack_hand(mob/user as mob)
	if(manifest)
		user << "<span class='notice'>You tear the manifest off of the crate.</span>"
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 75, 1)
		manifest.loc = loc
		if(ishuman(user))
			user.put_in_hands(manifest)
		manifest = null
		update_icon()
		return
	else
		user << "<span class='notice'>You need a crowbar to pry this open!</span>"
		return

/obj/structure/largecrate/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		if(manifest)
			manifest.loc = loc
			manifest = null
			update_icon()
		new /obj/item/stack/sheet/wood(src)
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user.visible_message("<span class='notice'>[user] pries \the [src] open.</span>", \
							 "<span class='notice'>You pry open \the [src].</span>", \
							 "<span class='notice'>You hear splitting wood.</span>")
		del(src)
	else
		return attack_hand(user)

/obj/structure/largecrate/mule
	icon_state = "mulecrate"

/obj/structure/largecrate/lisa
	icon_state = "lisacrate"

/obj/structure/largecrate/lisa/attackby(obj/item/weapon/W as obj, mob/user as mob)	//ugly but oh well
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/pet/corgi/Lisa(loc)
	..()

/obj/structure/largecrate/cow
	name = "cow crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cow/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/cow(loc)
	..()

/obj/structure/largecrate/goat
	name = "goat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/goat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/hostile/retaliate/goat(loc)
	..()

/obj/structure/largecrate/chick
	name = "chicken crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/chick/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		var/num = rand(4, 6)
		for(var/i = 0, i < num, i++)
			new /mob/living/simple_animal/chick(loc)
	..()

/obj/structure/largecrate/cat
	name = "cat crate"
	icon_state = "lisacrate"

/obj/structure/largecrate/cat/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/crowbar))
		new /mob/living/simple_animal/pet/cat(loc)
	..()