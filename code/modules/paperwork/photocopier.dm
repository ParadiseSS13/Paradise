/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	use_power = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/obj/item/weapon/paper/copy = null	//what's in the copier!
	var/obj/item/weapon/photo/photocopy = null
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/mob/living/ass = null
	var/busy = 0

	attack_ai(mob/user as mob)
		return attack_hand(user)

	attack_paw(mob/user as mob)
		return attack_hand(user)

	attack_hand(mob/user as mob)
		user.set_machine(src)

		var/dat = "Photocopier<BR><BR>"
		if(copy || photocopy || (ass && (ass.loc == src.loc)))
			dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Paper</a><BR>"
			if(toner)
				dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
				dat += "Printing: [copies] copies."
				dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
				dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
		else if(toner)
			dat += "Please insert paper to copy.<BR><BR>"
		if(istype(user,/mob/living/silicon))
			dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
		dat += "Current toner level: [toner]"
		if(!toner)
			dat +="<BR>Please insert a new toner cartridge!"
		user << browse(dat, "window=copier")
		onclose(user, "copier")
		return

	Topic(href, href_list)
		if(href_list["copy"])
			if(copy)
				for(var/i = 0, i < copies, i++)
					if(toner > 0 && !busy && copy)
						var/obj/item/weapon/paper/c = new /obj/item/weapon/paper (loc)
						if(toner > 10)	//lots of toner, make it dark
							c.info = "<font color = #101010>"
						else			//no toner? shitty copies for you!
							c.info = "<font color = #808080>"
						var/copied = copy.info
						copied = replacetext(copied, "<font face=\"[c.deffont]\" color=", "<font face=\"[c.deffont]\" nocolor=")	//state of the art techniques in action
						copied = replacetext(copied, "<font face=\"[c.crayonfont]\" color=", "<font face=\"[c.crayonfont]\" nocolor=")	//This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
						c.info += copied
						c.info += "</font>"
						c.name = copy.name // -- Doohl
						c.fields = copy.fields
						c.updateinfolinks()
						toner--
						busy = 1
						sleep(15)
						busy = 0
					else
						break
				updateUsrDialog()
			else if(photocopy)
				for(var/i = 0, i < copies, i++)
					if(toner >= 5 && !busy && photocopy)
						var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
						var/icon/I = icon(photocopy.icon, photocopy.icon_state)
						var/icon/img = icon(photocopy.img)
						if(toner > 10)	//plenty of toner, go straight greyscale
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))		//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
						else			//not much toner left, lighten the photo
							I.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
							img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
						p.icon = I
						p.img = img
						p.name = photocopy.name
						p.desc = photocopy.desc
						p.scribble = photocopy.scribble
						toner -= 5	//photos use a lot of ink!
						busy = 1
						sleep(15)
						busy = 0
					else
						break
				updateUsrDialog()
			else if(ass) //ASS COPY. By Miauw
				for(var/i = 0, i < copies, i++)
					var/icon/temp_img
					if(ishuman(ass) && (ass.get_item_by_slot(slot_w_uniform) || ass.get_item_by_slot(slot_wear_suit)))
						usr << "<span class='notice'>You feel kind of silly copying [ass == usr ? "your" : ass][ass == usr ? "" : "\'s"] ass with [ass == usr ? "your" : "their"] clothes on.</span>"
					else if(toner >= 5 && !busy && check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
						if(isalien(ass) || istype(ass,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
							temp_img = icon('icons/ass/assalien.png')
						else if(ishuman(ass)) //Suit checks are in check_ass
							if(ass.gender == MALE)
								temp_img = icon('icons/ass/assmale.png')
							else if(ass.gender == FEMALE)
								temp_img = icon('icons/ass/assfemale.png')
							else                   //In case anyone ever makes the generic ass. For now I'll be using male asses.
								temp_img = icon('icons/ass/assmale.png')
					else
						break
					var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (loc)
					p.desc = "You see [ass]'s ass on the photo."
					p.pixel_x = rand(-10, 10)
					p.pixel_y = rand(-10, 10)
					p.img = temp_img
					var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
					var/icon/ic = icon('icons/obj/items.dmi',"photo")
					small_img.Scale(8, 8)
					ic.Blend(small_img,ICON_OVERLAY, 10, 13)
					p.icon = ic
					toner -= 5
					busy = 1
					sleep(15)
					busy = 0
				updateUsrDialog()
		else if(href_list["remove"])
			if(copy)
				copy.loc = usr.loc
				usr.put_in_hands(copy)
				usr << "<span class='notice'>You take the paper out of \the [src].</span>"
				copy = null
				updateUsrDialog()
			else if(photocopy)
				photocopy.loc = usr.loc
				usr.put_in_hands(photocopy)
				usr << "<span class='notice'>You take the photo out of \the [src].</span>"
				photocopy = null
				updateUsrDialog()
			else if(check_ass())
				ass << "<span class='notice'>You feel a slight pressure on your ass.</span>"
		else if(href_list["min"])
			if(copies > 1)
				copies--
				updateUsrDialog()
		else if(href_list["add"])
			if(copies < maxcopies)
				copies++
				updateUsrDialog()
		else if(href_list["aipic"])
			if(!istype(usr,/mob/living/silicon)) return
			if(toner >= 5)
				var/mob/living/silicon/tempAI = usr
				var/obj/item/device/camera/siliconcam/camera = tempAI.aiCamera

				if(!camera)
					return
				var/datum/picture/selection = camera.selectpicture()
				if (!selection)
					return

				var/obj/item/weapon/photo/p = new /obj/item/weapon/photo (src.loc)
				p.construct(selection)
				if (p.desc == "")
					p.desc += "Copied by [tempAI.name]"
				else
					p.desc += " - Copied by [tempAI.name]"
				toner -= 5
				sleep(15)
			updateUsrDialog()

	attackby(obj/item/O as obj, mob/user as mob)
		if(istype(O, /obj/item/weapon/paper))
			if(!copy && !photocopy)
				user.drop_item()
				copy = O
				O.loc = src
				user << "<span class='notice'>You insert the paper into \the [src].</span>"
				flick("bigscanner1", src)
				updateUsrDialog()
			else
				user << "<span class='notice'>There is already something in \the [src].</span>"
		else if(istype(O, /obj/item/weapon/photo))
			if(copier_empty())
				user.drop_item()
				photocopy = O
				O.loc = src
				user << "<span class='notice'>You insert the photo into \the [src].</span>"
				flick("bigscanner1", src)
				updateUsrDialog()
			else
				user << "<span class='notice'>There is already something in \the [src].</span>"
		else if(istype(O, /obj/item/device/toner))
			if(toner <= 0)
				user.drop_item()
				del(O)
				toner = 30
				user << "<span class='notice'>You insert the toner cartridge into \the [src].</span>"
				updateUsrDialog()
			else
				user << "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>"
		else if(istype(O, /obj/item/weapon/wrench))
			playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = !anchored
			user << "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>"
		else if(istype(O, /obj/item/weapon/grab)) //For ass-copying.
			var/obj/item/weapon/grab/G = O
			if(ismob(G.affecting) && G.affecting != ass)
				var/mob/GM = G.affecting
				visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
				GM.loc = get_turf(src)
				ass = GM
				if(photocopy)
					photocopy.loc = src.loc
					photocopy = null
				else if(copy)
					copy.loc = src.loc
					copy = null
			updateUsrDialog()
		return

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
			if(2.0)
				if(prob(50))
					del(src)
				else
					if(toner > 0)
						new /obj/effect/decal/cleanable/oil(get_turf(src))
						toner = 0
			else
				if(prob(50))
					if(toner > 0)
						new /obj/effect/decal/cleanable/oil(get_turf(src))
						toner = 0
		return

	blob_act()
		if(prob(50))
			qdel(src)
		else
			if(toner > 0)
				new /obj/effect/decal/cleanable/oil(get_turf(src))
				toner = 0
		return

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if (!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai) || target == ass)
		return
	src.add_fingerprint(user)
	if(target == user && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		visible_message("<span class='warning'>[usr] jumps onto the photocopier!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		if(target.anchored) return
		if(!ishuman(user) && !ismonkey(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto the photocopier!</span>")
	target.loc = get_turf(src)
	ass = target
	if(photocopy)
		photocopy.loc = src.loc
		visible_message("<span class='notice'>[photocopy] is shoved out of the way by [ass]!</span>")
		photocopy = null
	else if(copy)
		copy.loc = src.loc
		visible_message("<span class='notice'>[copy] is shoved out of the way by [ass]!</span>")
		copy = null
	updateUsrDialog()

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return 0
	if(ass.loc != src.loc)
		ass = null
		updateUsrDialog()
		return 0
	else if(istype(ass,/mob/living/carbon/human))
		if(!ass.get_item_by_slot(slot_w_uniform) && !ass.get_item_by_slot(slot_wear_suit))
			return 1
		else
			return 0
	else
		return 1

/obj/machinery/photocopier/proc/copier_empty()
	if(copy || photocopy || check_ass())
		return 0
	else
		return 1

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
