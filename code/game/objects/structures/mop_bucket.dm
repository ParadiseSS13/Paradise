/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE
	container_type = OPENCONTAINER
	face_while_pulling = FALSE
	var/obj/item/mop/stored_mop = null
	var/maximum_volume = 150
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/Initialize(mapload)
	. = ..()
	create_reagents(150)
	GLOB.janitorial_equipment += src

/obj/structure/mopbucket/full/Initialize(mapload)
	. = ..()
	reagents.add_reagent("water", 150)

/obj/structure/mopbucket/Destroy()
	GLOB.janitorial_equipment -= src
	return ..()

/obj/structure/mopbucket/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/mop))
		var/obj/item/mop/M = W
		if(M.reagents.total_volume < M.reagents.maximum_volume)
			M.wet_mop(src, user)
			return
		if(!stored_mop)
			M.mopbucket_insert(user, src)
			return
		to_chat(user, "<span class='notice'>Theres already a mop in the mopbucket.</span>")
		return

/obj/structure/mopbucket/proc/put_in_cart(obj/item/mop/I, mob/user)
	user.drop_item()
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	update_icon(UPDATE_OVERLAYS)
	return

/obj/item/mop/proc/mopbucket_insert(mob/user, obj/structure/mopbucket/J)
	J.stored_mop = src
	J.put_in_cart(src, user)

/obj/structure/mopbucket/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/mopbucket/update_overlays()
	. = ..()
	if(stored_mop)
		. += "mopbucket_mop"
	if(reagents.total_volume > 0)
		var/image/reagentsImage = image(icon, src, "mopbucket_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / maximum_volume) * 100)
			if(1 to 37)
				reagentsImage.icon_state = "mopbucket_reagents1"
			if(38 to 75)
				reagentsImage.icon_state = "mopbucket_reagents2"
			if(76 to 112)
				reagentsImage.icon_state = "mopbucket_reagents3"
			if(113 to 150)
				reagentsImage.icon_state = "mopbucket_reagents4"
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage

/obj/structure/mopbucket/attack_hand(mob/living/user)
	. = ..()
	if(stored_mop)
		user.put_in_hands(stored_mop)
		to_chat(user, "<span class='notice'>You take [stored_mop] from [src].</span>")
		stored_mop = null
		update_icon(UPDATE_OVERLAYS)
		return

