/obj/item/stock_parts/cell/xenoblue
	icon = 'icons/HISPANIA/obj/power.dmi'
	icon_state = "xenobluecell"
	item_state = "xenobluecell"
	name = "xenobluespace power cell"
	desc = "Created using xeno-bluespace technology. Designed by the renowned research director Adam Wolf."
	origin_tech = "powerstorage=6;biotech=4;materials=5; engineering=5;bluespace =5"
	maxcharge = 50000
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	materials = list(MAT_GLASS = 800)
	rating = 7
	self_recharge = 1 // Infused slime cores self-recharge, over time
	chargerate = 600

/obj/item/xenobluecellmaker
	icon = 'icons/HISPANIA/obj/power.dmi'
	icon_state = "xenobluecellmaker"
	item_state = "xenobluecellmaker"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	name = "xenobluespace power cell Maker"
	desc = "High-tech power cell shell capable of creating a power cell that combines Bluespace and Xenobiology technology. Requiered a bluespace power cell and a charged slime core. Has inscribed: -en Honor a Blob Bob, Maestro de la Teleciencia, Sticky Gum, Maestra de la Xenobiologia y a Baldric Chapman, Maestro de la Robotica-"
	origin_tech = "powerstorage=6;biotech=4"
	materials = list(MAT_GLASS = 1000)
	var/build_step = 0

/obj/item/xenobluecellmaker/attackby(obj/item/I, mob/user, params)
	..()
	switch(build_step)
		if(0)
			if(istype(I, /obj/item/stock_parts/cell/bluespace))
				if(!user.drop_item())
					return
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the bluespace power cell to [src].</span>")
				name = "xenobluecellmaker/bluespace power cell assembly"

		if(1)
			if(istype(I, /obj/item/stock_parts/cell/high/slime))
				if(!user.drop_item())
					return
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You complete the Xenobluespace power cell.</span>")
				var/turf/T = get_turf(src)
				new /obj/item/stock_parts/cell/xenoblue(T)
				user.unEquip(src, 1)
				qdel(src)

