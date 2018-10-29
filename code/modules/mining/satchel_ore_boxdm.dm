
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5 * ONE_ATMOSPHERE

/obj/structure/ore_box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/t_scanner/adv_mining_scanner))
		attack_hand(user)
		return
	else if(istype(W, /obj/item/stack/ore))
		if(!user.drop_item())
			return
		W.forceMove(src)
	else if(istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/stack/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
			CHECK_TICK
		to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")
	else if(istype(W, /obj/item/crowbar))
		playsound(src, W.usesound, 50, 1)
		var/obj/item/crowbar/C = W
		if(do_after(user, 50 * C.toolspeed, target = src))
			user.visible_message("<span class='notice'>[user] pries [src] apart.</span>", "<span class='notice'>You pry apart [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
			deconstruct(TRUE, user)

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	var/list/assembled = list()
	for(var/obj/item/stack/ore/O in src)
		assembled[O.type] += O.amount
	for(var/type in assembled)
		var/obj/item/stack/ore/O = type
		dat += "[initial(O.name)] - [assembled[type]]<br>"

	dat += text("<br><br><A href='?src=[UID()];removeall=1'>Empty box</A>")
	var/datum/browser/popup = new(user, "orebox", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["removeall"])
		dump_box_contents()
		to_chat(usr, "<span class='notice'>You empty the box.</span>")
	updateUsrDialog()

obj/structure/ore_box/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		qdel(src) //nothing but ores can get inside unless its a bug and ores just return nothing on ex_act, not point in calling it on them

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/wood/W = new (loc, 4)
	if(user)
		W.add_fingerprint(user)
	dump_box_contents()
	qdel(src)

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/stack/ore/O in src)
		if(QDELETED(O))
			continue
		if(QDELETED(src))
			break
		O.forceMove(loc)
		CHECK_TICK

/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(usr.incapacitated())
		return

	if(!Adjacent(usr))
		to_chat(usr, "You cannot reach the ore box.")
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		to_chat(usr, "<span class='warning'>The ore box is empty.</span>")
		return

	dump_box_contents()
	to_chat(usr, "<span class='notice'>You empty the ore box.</span>")
