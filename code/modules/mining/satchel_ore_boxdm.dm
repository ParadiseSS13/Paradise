
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_glass = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_strange = 0
	var/last_update = 0

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		user.u_equip(W)
		src.contents += W
	if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/weapon/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		user << "\blue You empty the satchel into the box."
	return

/obj/structure/ore_box/examine()
	set name = "Examine"
	set category = "IC"
	set src in view(usr.client) //If it can be seen, it can be examined.

	if (!( usr ))
		return
	usr << "That's an [src]."
	usr << desc

	if(!istype(usr, /mob/living/carbon/human)) //Only living, intelligent creatures with hands can check the contents of ore boxes.
		return

	if(!Adjacent(usr)) //Can only check the contents of ore boxes if you can physically reach them.
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		usr << "It is empty."
		return

	if(world.time > last_update + 10)
		update_orecount()
		last_update = world.time

	var/dat = text("<b>The contents of the ore box reveal...</b>")
	if (amt_iron)
		dat += text("<br>Metal ore: [amt_iron]")
	if (amt_glass)
		dat += text("<br>Sand: [amt_glass]")
	if (amt_plasma)
		dat += text("<br>Plasma ore: [amt_plasma]")
	if (amt_uranium)
		dat += text("<br>Uranium ore: [amt_uranium]")
	if (amt_silver)
		dat += text("<br>Silver ore: [amt_silver]")
	if (amt_gold)
		dat += text("<br>Gold ore: [amt_gold]")
	if (amt_diamond)
		dat += text("<br>Diamond ore: [amt_diamond]")
	if (amt_strange)
		dat += text("<br>Strange rocks: [amt_strange]")
	if (amt_clown)
		dat += text("<br>Bananium ore: [amt_clown]")

	usr << dat

	return


/obj/structure/ore_box/verb/empty_box()
	set name = "Empty Ore Box"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human)) //Only living, intelligent creatures with hands can empty ore boxes.
		usr << "\red You are physically incapable of emptying the ore box."
		return

	if( usr.stat || usr.restrained() )
		return

	if(!Adjacent(usr)) //You can only empty the box if you can physically reach it
		usr << "You cannot reach the ore box."
		return

	add_fingerprint(usr)

	if(contents.len < 1)
		usr << "\red The ore box is empty"
		return

	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	usr << "\blue You empty the ore box"

	return


// Updates ore tally
/obj/structure/ore_box/proc/update_orecount()
	amt_iron = 0
	amt_glass = 0
	amt_plasma = 0
	amt_uranium = 0
	amt_silver = 0
	amt_gold = 0
	amt_diamond = 0
	amt_strange = 0
	amt_clown = 0

	for(var/obj/item/weapon/ore/O in contents)
		if(!istype(O))
			continue

		if (istype(O, /obj/item/weapon/ore/iron))
			amt_iron++
			continue
		if (istype(O, /obj/item/weapon/ore/glass))
			amt_glass++
			continue
		if (istype(O, /obj/item/weapon/ore/plasma))
			amt_plasma++
			continue
		if (istype(O, /obj/item/weapon/ore/uranium))
			amt_uranium++
			continue
		if (istype(O, /obj/item/weapon/ore/silver))
			amt_silver++
			continue
		if (istype(O, /obj/item/weapon/ore/gold))
			amt_gold++
			continue
		if (istype(O, /obj/item/weapon/ore/diamond))
			amt_diamond++
			continue
		if (istype(O, /obj/item/weapon/ore/strangerock))
			amt_strange++
			continue
		if (istype(O, /obj/item/weapon/ore/clown))
			amt_clown++
			continue
	return
