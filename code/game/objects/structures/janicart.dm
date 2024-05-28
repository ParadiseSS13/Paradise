//TG style Janicart

/obj/structure/janitorialcart
	name = "janitorial cart"
	desc = "This is the alpha and omega of sanitation."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cart"
	anchored = FALSE
	density = TRUE
	face_while_pulling = FALSE
	container_type = OPENCONTAINER
	//copypaste sorry
	var/maximum_volume = 150
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/mybag = null
	var/obj/item/mop/mymop = null
	var/obj/item/push_broom/mybroom = null
	var/obj/item/reagent_containers/spray/cleaner/myspray = null
	var/obj/item/lightreplacer/myreplacer = null
	var/signs = 0
	var/const/max_signs = 4

/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(150)
	GLOB.janitorial_equipment += src

/obj/structure/janitorialcart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(mybag)
	QDEL_NULL(mymop)
	QDEL_NULL(mybroom)
	QDEL_NULL(myspray)
	QDEL_NULL(myreplacer)
	return ..()

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.forceMove(src)
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	update_icon(UPDATE_OVERLAYS)
	return

/obj/structure/janitorialcart/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(!I.is_robot_module())
		if(istype(I, /obj/item/mop))
			var/obj/item/mop/m=I
			if(m.reagents.total_volume < m.reagents.maximum_volume)
				m.wet_mop(src, user)
				return
			if(!mymop)
				m.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/push_broom))
			if(!mybroom)
				var/obj/item/push_broom/B = I
				B.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/bag/trash))
			if(!mybag)
				var/obj/item/storage/bag/trash/t=I
				t.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/reagent_containers/spray/cleaner))
			if(!myspray)
				myspray = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/lightreplacer))
			if(!myreplacer)
				var/obj/item/lightreplacer/l=I
				l.janicart_insert(user,src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/caution))
			if(signs < max_signs)
				signs++
				put_in_cart(I, user)
			else
				to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")
		else if(mybag)
			mybag.attackby(I, user, params)
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/janitorialcart/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	user.visible_message("<span class='warning'>[user] begins to empty the contents of [src].</span>")
	if(!I.use_tool(src, user, 3 SECONDS, I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>")
	reagents.reaction(loc)
	reagents.clear_reagents()

/obj/structure/janitorialcart/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!anchored && !isinspace())
		if(!I.use_tool(src, user, I.tool_volume))
			return
		user.visible_message( \
			"[user] tightens [src]'s casters.", \
			"<span class='notice'>You have tightened [src]'s casters.</span>", \
			"You hear ratchet.")
		anchored = TRUE
		return
	if(anchored)
		if(!I.use_tool(src, user, I.tool_volume))
			return
		user.visible_message( \
			"[user] loosens [src]'s casters.", \
			"<span class='notice'>You have loosened [src]'s casters.</span>", \
			"You hear ratchet.")
		anchored = FALSE

/obj/structure/janitorialcart/attack_hand(mob/user)
	var/list/cart_items = list()

	if(mybag)
		cart_items["Trash Bag"] = image(icon = mybag.icon, icon_state = mybag.icon_state)
	if(mymop)
		cart_items["Mop"] = image(icon = mymop.icon, icon_state = mymop.icon_state)
	if(mybroom)
		cart_items["Broom"] = image(icon = mybroom.icon, icon_state = mybroom.icon_state)
	if(myspray)
		cart_items["Spray Bottle"] = image(icon = myspray.icon, icon_state = myspray.icon_state)
	if(myreplacer)
		cart_items["Light Replacer"] = image(icon = myreplacer.icon, icon_state = myreplacer.icon_state)
	var/obj/item/caution/Sign = locate() in src
	if(Sign)
		cart_items["Sign"] = image(icon = Sign.icon, icon_state = Sign.icon_state)

	if(!length(cart_items))
		return

	var/pick = show_radial_menu(user, src, cart_items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)

	if(!pick)
		return

	switch(pick)
		if("Trash Bag")
			if(!mybag)
				return
			user.put_in_hands(mybag)
			to_chat(user, "<span class='notice'>You take [mybag] from [src].</span>")
			mybag = null
		if("Mop")
			if(!mymop)
				return
			user.put_in_hands(mymop)
			to_chat(user, "<span class='notice'>You take [mymop] from [src].</span>")
			mymop = null
		if("Broom")
			if(!mybroom)
				return
			user.put_in_hands(mybroom)
			to_chat(user, "<span class='notice'>You take [mybroom] from [src].</span>")
			mybroom = null
		if("Spray Bottle")
			if(!myspray)
				return
			user.put_in_hands(myspray)
			to_chat(user, "<span class='notice'>You take [myspray] from [src].</span>")
			myspray = null
		if("Light Replacer")
			if(!myreplacer)
				return
			user.put_in_hands(myreplacer)
			to_chat(user, "<span class='notice'>You take [myreplacer] from [src].</span>")
			myreplacer = null
		if("Sign")
			if(!signs)
				return
			if(Sign)
				user.put_in_hands(Sign)
				to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/proc/check_menu(mob/living/user)
	return (istype(user) && !HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))

/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(mybag)
		. += "cart_garbage"
	if(mymop)
		. += "cart_mop"
	if(mybroom)
		. += "cart_broom"
	if(myspray)
		. += "cart_spray"
	if(myreplacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/image/reagentsImage = image(icon,src,"cart_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume / maximum_volume) * 100)
			if(1 to 37)
				reagentsImage.icon_state = "cart_reagents1"
			if(38 to 75)
				reagentsImage.icon_state = "cart_reagents2"
			if(76 to 112)
				reagentsImage.icon_state = "cart_reagents3"
			if(113 to 150)
				reagentsImage.icon_state = "cart_reagents4"
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage
