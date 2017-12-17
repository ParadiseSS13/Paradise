/obj/machinery/glass_recycler
	name = "Kitchenware Recycler"
	desc = "A machine that recycles glass shards into kitchenware."
	icon = 'hyntatmta/icons/obj/machinery/kitchen.dmi'
	icon_state = "glass_recycler"
	anchored = 1
	density = 0
	var/glass_amt = 0

	New()
		..()
		UnsubscribeProcess()

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/shard))
			glass_amt += 1
			user.visible_message("<span style=\"color:blue\">[user] inserts [W] into [src].</span>")
			user.unEquip(W)
			qdel(W)
		else
			to_chat(user, "<span style=\"color:red\">[src] only accepts glass shards!</span>")
			return

	attack_hand(mob/user as mob)
		var/dat = "<b>Glass Left</b>: [glass_amt]<br>"
		dat += "<A href='?src=[UID()];type=drinking'>Drinking Glass</A><br>"
		dat += "<A href='?src=[UID()];type=shot'>Shot Glass</A><br>"
		dat += "<A href='?src=[UID()];type=wine'>Wine Glass</A><br>"
		dat += "<A href='?src=[UID()];type=cocktail'>Cocktail Glass</A><br>"
		dat += "<A href='?src=[UID()];type=flute'>Champagne Flute</A><br>"
		dat += "<A href='?src=[UID()];type=pitcher'>Pitcher</A><br>"
		dat += "<HR><A href='?src=[UID()];refresh=1'>Refresh</A>"
		dat += "<BR><BR><A href='?action=mach_close&window=glass'>Close</A>"
		user << browse(dat, "window=glass;size=220x240")
		onclose(user, "glass")
		return

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			usr.machine = src

			if (href_list["type"])
				create(lowertext(href_list["type"]))

			if (href_list["refresh"])
				src.updateUsrDialog()
			src.add_fingerprint(usr)
			src.updateUsrDialog()
		return

	proc/check_glass()
		if(src.glass_amt <= 0)
			return 0
		else
			return 1

	proc/create(var/object)
		if(!src.check_glass())
			src.visible_message("<span style=\"color:red\">[src] doesn't have enough glass!</span>")
			return

		switch(object)
			if("drinking")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass(get_turf(src))
				src.glass_amt -= 1
			if("shot")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/shotglass(get_turf(src))
				src.glass_amt -= 1
			if("wine")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/wine(get_turf(src))
				src.glass_amt -= 1
			if("cocktail")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/cocktail(get_turf(src))
				src.glass_amt -= 1
			if("flute")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/champagne(get_turf(src))
				src.glass_amt -= 1
			if("pitcher")
				new /obj/item/weapon/reagent_containers/food/drinks/drinkingglass/pitcher(get_turf(src))
				src.glass_amt -= 1
			else
				return

		if(object != "pitcher")
			src.visible_message("<span style=\"color:blue\">[src] manufactures a [object] glass!</span>")
			return
		else
			src.visible_message("<span style=\"color:blue\">[src] manufactures a pitcher!</span>")
			return