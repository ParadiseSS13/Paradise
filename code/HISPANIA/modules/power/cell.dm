/obj/item/stock_parts/cell/get_part_rating()
	return rating * maxcharge

/obj/item/stock_parts/cell/proc/minorrecharge()
	minorrecharging = FALSE

/obj/item/stock_parts/cell/xenoblue
	icon = 'icons/hispania/obj/power.dmi'
	icon_state = "xenobluecell"
	item_state = "xenobluecell"
	name = "xenobluespace power cell"
	desc = "Created using xeno-bluespace technology. Designed by the renowned research director Adam Wolf."
	origin_tech = "powerstorage=6;biotech=4;materials=5; engineering=5;bluespace =5"
	maxcharge = 50000	//bateria bluespace + slime
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	materials = list(MAT_GLASS = 800)
	self_recharge = 1 // Infused slime cores self-recharge, over time
	rating = 1.1
	chargerate = 600
	overaynull = TRUE

/obj/item/xenobluecellmaker
	icon = 'icons/hispania/obj/power.dmi'
	icon_state = "xenobluecellmaker"
	item_state = "xenobluecellmaker"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	name = "xenobluespace power cell maker"
	desc = "High-tech power cell shell capable of creating a power cell that combines Bluespace and Xenobiology technology. Requiered a bluespace power cell and a charged slime core."
	origin_tech = "powerstorage=6;biotech=4"
	materials = list(MAT_GLASS = 1000)
	var/build_step = 0
	var/bluecharge
	var/bluemaxcharge
	var/obj/item/stock_parts/cell/xenocell
	var/cell_type = /obj/item/stock_parts/cell/xenoblue

/obj/item/xenobluecellmaker/attackby(obj/item/I, mob/user, params)
	..()
	switch(build_step)
		if(0)
			if(istype(I, /obj/item/stock_parts/cell/bluespace))
				var/obj/item/stock_parts/cell/bluespace/B = I
				bluecharge = B.charge
				bluemaxcharge = B.maxcharge
				if(!user.drop_item())
					return
				qdel(I)
				build_step++
				to_chat(user, "<span class='notice'>You add the bluespace power cell to [src].</span>")
				name = "xenobluecellmaker/bluespace power cell assembly"
				icon_state = "xenobluecellmaker-on"

		if(1)
			if(istype(I, /obj/item/stock_parts/cell/high/slime))
				var/obj/item/stock_parts/cell/high/slime/S = I
				if(!user.drop_item())
					return
				build_step++
				var/turf/T = get_turf(src)
				new/obj/effect/temp_visual/revenant/cracks(T)
				playsound(T, 'sound/magic/lightningshock.ogg', 10, 1, -1)
				to_chat(user, "<span class='notice'>You complete the Xenobluespace power cell.</span>")
				xenocell = new cell_type(src)
				xenocell.maxcharge = bluemaxcharge + S.maxcharge
				xenocell.charge = (bluecharge + S.charge)/2 //como maximo tendra la mitad de su carga completa
				xenocell.chargerate = S.chargerate * 1.2
				if(istype(loc, /turf))
					xenocell.forceMove(T)
				else
					user.drop_item(src)
					user.remove_from_mob(src)
					usr.put_in_hands(xenocell)
				qdel(I)
				qdel(src)
