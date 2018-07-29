
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
	if(istype(W, /obj/item/ore))
		if(!user.drop_item())
			return
		W.forceMove(src)
	if(istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
			CHECK_TICK
		to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")

/obj/structure/ore_box/attack_hand(mob/user)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_glass = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_titanium = 0
	var/amt_clown = 0
	var/amt_mime = 0
	var/amt_bluespace = 0

	for(var/obj/item/ore/C in contents)
		if(istype(C,/obj/item/ore/diamond))
			amt_diamond++
		if(istype(C,/obj/item/ore/glass))
			amt_glass++
		if(istype(C,/obj/item/ore/plasma))
			amt_plasma++
		if(istype(C,/obj/item/ore/iron))
			amt_iron++
		if(istype(C,/obj/item/ore/silver))
			amt_silver++
		if(istype(C,/obj/item/ore/gold))
			amt_gold++
		if(istype(C,/obj/item/ore/uranium))
			amt_uranium++
		if(istype(C,/obj/item/ore/bananium))
			amt_clown++
		if(istype(C,/obj/item/ore/tranquillite))
			amt_mime++
		if(istype(C, /obj/item/ore/titanium))
			amt_titanium++
		if(istype(C,/obj/item/ore/bluespace_crystal))
			amt_bluespace++

	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	if(amt_gold)
		dat += text("Gold ore: [amt_gold]<br>")
	if(amt_silver)
		dat += text("Silver ore: [amt_silver]<br>")
	if(amt_iron)
		dat += text("Metal ore: [amt_iron]<br>")
	if(amt_glass)
		dat += text("Sand: [amt_glass]<br>")
	if(amt_diamond)
		dat += text("Diamond ore: [amt_diamond]<br>")
	if(amt_plasma)
		dat += text("Plasma ore: [amt_plasma]<br>")
	if(amt_uranium)
		dat += text("Uranium ore: [amt_uranium]<br>")
	if(amt_titanium)
		dat += text("Titanium ore: [amt_titanium]<br>")
	if(amt_clown)
		dat += text("Bananium ore: [amt_clown]<br>")
	if(amt_mime)
		dat += text("Tranquillite ore: [amt_mime]<br>")
	if(amt_bluespace)
		dat += text("Bluespace crystals: [amt_bluespace]<br>")

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
		for(var/obj/item/ore/O in contents)
			contents -= O
			O.forceMove(loc)
			CHECK_TICK
		to_chat(usr, "<span class='notice'>You empty the box.</span>")
	updateUsrDialog()

obj/structure/ore_box/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		qdel(src) //nothing but ores can get inside unless its a bug and ores just return nothing on ex_act, not point in calling it on them


/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr)) //Only living, intelligent creatures with hands can empty ore boxes.
		to_chat(usr, "<span class='warning'>You are physically incapable of emptying the ore box.</span>")
		return

	if(usr.incapacitated())
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		to_chat(usr, "You cannot reach the ore box.")
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		to_chat(usr, "<span class='warning'>The ore box is empty.</span>")
		return

	for(var/obj/item/ore/O in contents)
		contents -= O
		O.forceMove(loc)
		CHECK_TICK
	to_chat(usr, "<span class='notice'>You empty the ore box.</span>")