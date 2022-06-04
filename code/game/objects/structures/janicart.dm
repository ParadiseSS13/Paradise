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
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/storage/bag/trash/stored_bag	= null
	var/obj/item/mop/stored_mop = null
	var/obj/item/reagent_containers/spray/cleaner/stored_spray = null
	var/obj/item/lightreplacer/stored_replacer = null
	var/signs = 0
	var/const/max_signs = 4


/obj/structure/janitorialcart/Initialize(mapload)
	. = ..()
	create_reagents(100)
	GLOB.janitorial_equipment += src

/obj/structure/janitorialcart/Destroy()
	GLOB.janitorial_equipment -= src
	QDEL_NULL(stored_bag)
	QDEL_NULL(stored_mop)
	QDEL_NULL(stored_spray)
	QDEL_NULL(stored_replacer)
	return ..()

/obj/structure/janitorialcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.forceMove(src)
	update_icon(UPDATE_OVERLAYS)
	updateUsrDialog()
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return

/obj/structure/janitorialcart/on_reagent_change()
	update_icon(UPDATE_OVERLAYS)

/obj/structure/janitorialcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There is already one of those in [src].</span>"

	if(!I.is_robot_module())
		if(istype(I, /obj/item/mop))
			var/obj/item/mop/M = I
			if(M.reagents.total_volume < M.reagents.maximum_volume)
				M.wet_mop(src, user)
				return
			if(!stored_mop)
				M.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/storage/bag/trash))
			if(!stored_bag)
				var/obj/item/storage/bag/trash/T = I
				T.janicart_insert(user, src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/reagent_containers/spray/cleaner))
			if(!stored_spray)
				stored_spray = I
				put_in_cart(I, user)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/lightreplacer))
			if(!stored_replacer)
				var/obj/item/lightreplacer/L = I
				L.janicart_insert(user,src)
			else
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/caution))
			if(signs < max_signs)
				signs++
				put_in_cart(I, user)
			else
				to_chat(user, "<span class='notice'>[src] can't hold any more signs.</span>")
		else if(istype(I, /obj/item/crowbar))
			user.visible_message("<span class='warning'>[user] begins to empty the contents of [src].</span>")
			if(do_after(user, 30 * I.toolspeed, target = src))
				to_chat(usr, "<span class='notice'>You empty the contents of [src]'s bucket onto the floor.</span>")
				reagents.reaction(src.loc)
				src.reagents.clear_reagents()
		else if(stored_bag)
			stored_bag.attackby(I, user, params)
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/janitorialcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(stored_bag)
		dat += "<a href='?src=[UID()];garbage=1'>[stored_bag.name]</a><br>"
	if(stored_mop)
		dat += "<a href='?src=[UID()];mop=1'>[stored_mop.name]</a><br>"
	if(stored_spray)
		dat += "<a href='?src=[UID()];spray=1'>[stored_spray.name]</a><br>"
	if(stored_replacer)
		dat += "<a href='?src=[UID()];replacer=1'>[stored_replacer.name]</a><br>"
	if(signs)
		dat += "<a href='?src=[UID()];sign=1'>[signs] sign\s</a><br>"
	var/datum/browser/popup = new(user, "janicart", name, 240, 160)
	popup.set_content(dat)
	popup.open()

/obj/structure/janitorialcart/wrench_act(mob/user, obj/item/I)
	if(isinspace())
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(I.use_tool(src, user, 0, volume = I.tool_volume))
		anchored = !anchored
		user.visible_message( \
		"[user] [anchored ? "tightens" : "loosens"] \the [src]'s casters.", \
		"<span class='notice'> You have [anchored ? "tightened" : "loosened"] \the [src]'s casters.</span>", \
		"You hear ratchet.")

/obj/structure/janitorialcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["garbage"])
		if(stored_bag)
			user.put_in_hands(stored_bag)
			to_chat(user, "<span class='notice'>You take [stored_bag] from [src].</span>")
			stored_bag = null
	if(href_list["mop"])
		if(stored_mop)
			user.put_in_hands(stored_mop)
			to_chat(user, "<span class='notice'>You take [stored_mop] from [src].</span>")
			stored_mop = null
	if(href_list["spray"])
		if(stored_spray)
			user.put_in_hands(stored_spray)
			to_chat(user, "<span class='notice'>You take [stored_spray] from [src].</span>")
			stored_spray = null
	if(href_list["replacer"])
		if(stored_replacer)
			user.put_in_hands(stored_replacer)
			to_chat(user, "<span class='notice'>You take [stored_replacer] from [src].</span>")
			stored_replacer = null
	if(href_list["sign"])
		if(signs)
			var/obj/item/caution/Sign = locate() in src
			if(Sign)
				user.put_in_hands(Sign)
				to_chat(user, "<span class='notice'>You take \a [Sign] from [src].</span>")
				signs--
			else
				WARNING("Signs ([signs]) didn't match contents")
				signs = 0

	update_icon(UPDATE_OVERLAYS)
	updateUsrDialog()


/obj/structure/janitorialcart/update_overlays()
	. = ..()
	if(stored_bag)
		. += "cart_garbage"
	if(stored_mop)
		. += "cart_mop"
	if(stored_spray)
		. += "cart_spray"
	if(stored_replacer)
		. += "cart_replacer"
	if(signs)
		. += "cart_sign[signs]"
	if(reagents.total_volume > 0)
		var/image/reagentsImage = image(icon,src,"cart_reagents0")
		reagentsImage.alpha = 150
		switch((reagents.total_volume/reagents.maximum_volume)*100)
			if(1 to 25)
				reagentsImage.icon_state = "cart_reagents1"
			if(26 to 50)
				reagentsImage.icon_state = "cart_reagents2"
			if(51 to 75)
				reagentsImage.icon_state = "cart_reagents3"
			if(76 to 100)
				reagentsImage.icon_state = "cart_reagents4"
		reagentsImage.icon += mix_color_from_reagents(reagents.reagent_list)
		. += reagentsImage
