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

/obj/structure/mopbucket/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(user.a_intent != INTENT_HELP)
		return ..()

	if(istype(used, /obj/item/reagent_containers))
		return ..()

	if(handle_mop_interaction(user, used))
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/mopbucket/proc/handle_mop_interaction(mob/living/user, obj/item/used)
	if(!istype(used, /obj/item/mop))
		return FALSE

	. = TRUE
	var/robot_mop = used.is_robot_module()
	var/obj/item/mop/attacking_mop = used
	if(attacking_mop.reagents.total_volume < attacking_mop.reagents.maximum_volume)
		attacking_mop.wet_mop(src, user, robot_mop)
		return

	if(robot_mop)
		to_chat(user, "<span class='warning'>You cannot store [used] in [src]!</span>")
		return

	if(stored_mop)
		to_chat(user, "<span class='notice'>There is already a mop in [src].</span>")
		return

	if(!put_in_cart(user, attacking_mop))
		to_chat(user, "<span class='notice'>[attacking_mop] is stuck to your hand!</span>")

/obj/structure/mopbucket/proc/put_in_cart(mob/user, obj/item/mop/I)
	if(!user.unequip(I))
		return FALSE

	stored_mop = I
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	update_icon(UPDATE_OVERLAYS)
	return TRUE

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
