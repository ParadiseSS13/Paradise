#define EMAG_DELAY 50

/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	var/insert_anim = "bigscanner1"
	anchored = 1
	density = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	var/emag_cooldown
	atom_say_verb = "bleeps"
	var/obj/item/copyitem = null	//what's in the copier!
	var/copies = 1	//how many copies to print!
	var/toner = 60 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/mob/living/ass = null

/obj/machinery/photocopier/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	user.set_machine(src)

	var/dat = "Photocopier<BR><BR>"
	if(copyitem || (ass && (ass.loc == src.loc)))
		dat += "<a href='byond://?src=[UID()];remove=1'>Remove Item</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=[UID()];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=[UID()];min=1'>-</a> "
			dat += "<a href='byond://?src=[UID()];add=1'>+</a><BR><BR>"
	else if(toner)
		dat += "Please insert something to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon))
		dat += "<a href='byond://?src=[UID()];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	var/datum/browser/popup = new(user, "copier", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "copier")
	return

/obj/machinery/photocopier/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["copy"])
		if(stat & (BROKEN|NOPOWER))
			return

		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		for(var/i = 0, i < copies, i++)
			if(toner <= 0)
				break

			if(copier_items_printed >= copier_max_items) //global vars defined in misc.dm
				if(prob(10))
					visible_message("<span class='warning'>The printer screen reads \"PC LOAD LETTER\".</span>")
				else
					visible_message("<span class='warning'>The printer screen reads \"PHOTOCOPIER NETWORK OFFLINE, PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
				if(!copier_items_printed_logged)
					message_admins("Photocopier cap of [copier_max_items] papers reached, all photocopiers are now disabled. This may be the cause of any lag.")
					copier_items_printed_logged = TRUE
				break

			if(emag_cooldown > world.time)
				return

			if(istype(copyitem, /obj/item/paper))
				copy(copyitem)
				sleep(15)
			else if(istype(copyitem, /obj/item/photo))
				photocopy(copyitem)
				sleep(15)
			else if(istype(copyitem, /obj/item/paper_bundle))
				var/obj/item/paper_bundle/C = copyitem
				if(toner < (C.amount + 1))
					visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner for the operation.</span>") // It is better to prevent partial bundle than to produce broken paper bundle
					return
				var/obj/item/paper_bundle/B = bundlecopy(copyitem)
				if(!B)
					return
				sleep(15*B.amount)
			else if(ass && ass.loc == loc)
				copyass()
				sleep(15)
			else
				to_chat(usr, "<span class='warning'>\The [copyitem] can't be copied by \the [src].</span>")
				break
			copier_items_printed++
			use_power(active_power_usage)
		updateUsrDialog()
	else if(href_list["remove"])
		if(copyitem)
			copyitem.forceMove(get_turf(src))
			if(ishuman(usr))
				if(!usr.get_active_hand())
					usr.put_in_hands(copyitem)
			to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
			copyitem = null
			updateUsrDialog()
		else if(check_ass())
			to_chat(ass, "<span class='notice'>You feel a slight pressure on your ass.</span>")
			updateUsrDialog()
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
		if(stat & (BROKEN|NOPOWER)) return

		if(toner >= 5)
			var/mob/living/silicon/tempAI = usr
			var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

			if(!camera)
				return
			var/datum/picture/selection = camera.selectpicture()
			if(!selection)
				return

			playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
			var/obj/item/photo/p = new /obj/item/photo (src.loc)
			p.construct(selection)
			if(p.desc == "")
				p.desc += "Copied by [tempAI.name]"
			else
				p.desc += " - Copied by [tempAI.name]"
			toner -= 5
			sleep(15)
		updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo) || istype(O, /obj/item/paper_bundle))
		if(!copyitem)
			user.drop_item()
			copyitem = O
			O.forceMove(src)
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			flick(insert_anim, src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/toner))
		if(toner <= 10) //allow replacing when low toner is affecting the print darkness
			user.drop_item()
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			var/obj/item/toner/T = O
			toner += T.toner_amount
			qdel(O)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(istype(O, /obj/item/wrench))
		playsound(loc, O.usesound, 50, 1)
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")
	else if(istype(O, /obj/item/grab)) //For ass-copying.
		var/obj/item/grab/G = O
		if(ismob(G.affecting) && G.affecting != ass)
			var/mob/GM = G.affecting
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.forceMove(get_turf(src))
			ass = GM
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				copyitem = null
		updateUsrDialog()
	return

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
	return

/obj/machinery/photocopier/blob_act()
	if(prob(50))
		qdel(src)
	else
		if(toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0
	return

/obj/machinery/photocopier/proc/copy(var/obj/item/paper/copy)
	var/obj/item/paper/c = new /obj/item/paper (loc)
	c.info = copy.info
	c.name = copy.name // -- Doohl
	c.fields = copy.fields
	c.stamps = copy.stamps
	c.stamped = copy.stamped
	c.ico = copy.ico
	c.offset_x = copy.offset_x
	c.offset_y = copy.offset_y
	var/list/temp_overlays = copy.overlays       //Iterates through stamps
	var/image/img                                //and puts a matching
	for(var/j = 1, j <= temp_overlays.len, j++) //gray overlay onto the copy
		if(copy.ico.len)
			if(findtext(copy.ico[j], "cap") || findtext(copy.ico[j], "cent") || findtext(copy.ico[j], "rep"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-circle")
			else if(findtext(copy.ico[j], "deny"))
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-x")
			else
				img = image('icons/obj/bureaucracy.dmi', "paper_stamp-dots")
			img.pixel_x = copy.offset_x[j]
			img.pixel_y = copy.offset_y[j]
			c.overlays += img
	c.updateinfolinks()
	toner--
	if(toner == 0)
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return c


/obj/machinery/photocopier/proc/photocopy(var/obj/item/photo/photocopy)
	var/obj/item/photo/p = new /obj/item/photo (loc)
	p.name = photocopy.name
	p.icon = photocopy.icon
	p.tiny = photocopy.tiny
	p.img = photocopy.img
	p.desc = photocopy.desc
	p.pixel_x = photocopy.pixel_x
	p.pixel_y = photocopy.pixel_y
	if(photocopy.scribble)
		p.scribble = photocopy.scribble
	toner -= 5
	if(toner < 0)
		toner = 0
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return p


/obj/machinery/photocopier/proc/copyass()
	var/icon/temp_img
	if(!check_ass()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
		return
	if(emagged)
		if(ishuman(ass))
			var/mob/living/carbon/human/H = ass
			to_chat(H, "<span class='notice'>Something smells toasty...</span>")
			var/obj/item/organ/external/G = H.get_organ("groin")
			G.receive_damage(0, 30)
			spawn(20)
				H.emote("scream")
			emag_cooldown = world.time + EMAG_DELAY
		else
			to_chat(ass, "<span class='notice'>Something smells toasty...</span>")
			ass.apply_damage(30, BURN)
			emag_cooldown = world.time + EMAG_DELAY
	if(ishuman(ass)) //Suit checks are in check_ass
		var/mob/living/carbon/human/H = ass
		temp_img = icon('icons/obj/butts.dmi', H.dna.species.butt_sprite)
	else if(istype(ass,/mob/living/silicon/robot/drone))
		temp_img = icon('icons/obj/butts.dmi', "drone")
	else if(istype(ass,/mob/living/simple_animal/diona))
		temp_img = icon('icons/obj/butts.dmi', "nymph")
	else if(isalien(ass) || istype(ass,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/obj/butts.dmi', "xeno")
	else
		return
	var/obj/item/photo/p = new /obj/item/photo (loc)
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
	if(toner < 0)
		toner = 0
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	return p

//If need_toner is 0, the copies will still be lightened when low on toner, however it will not be prevented from printing. TODO: Implement print queues for fax machines and get rid of need_toner
/obj/machinery/photocopier/proc/bundlecopy(var/obj/item/paper_bundle/bundle, var/need_toner=1)
	var/obj/item/paper_bundle/P = new /obj/item/paper_bundle (src, default_papers = FALSE)
	for(var/obj/item/W in bundle)
		if(toner <= 0 && need_toner)
			toner = 0
			visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
			break

		if(istype(W, /obj/item/paper))
			W = copy(W)
		else if(istype(W, /obj/item/photo))
			W = photocopy(W)
		W.forceMove(P)
		P.amount++
	if(!P.amount)
		qdel(P)
		return null
	P.amount--
	P.forceMove(get_turf(src))
	P.update_icon()
	P.icon_state = "paper_words"
	P.name = bundle.name
	P.pixel_y = rand(-8, 8)
	P.pixel_x = rand(-9, 9)
	return P


/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	check_ass() //Just to make sure that you can re-drag somebody onto it after they moved off.
	if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai) || target == ass)
		return
	src.add_fingerprint(user)
	if(target == user && !user.incapacitated())
		visible_message("<span class='warning'>[usr] jumps onto [src]!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.weakened && !user.stunned && !user.paralysis)
		if(target.anchored) return
		if(!ishuman(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto [src]!</span>")
	target.forceMove(get_turf(src))
	ass = target
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		visible_message("<span class='notice'>[copyitem] is shoved out of the way by [ass]!</span>")
		copyitem = null
	updateUsrDialog()

/obj/machinery/photocopier/proc/check_ass() //I'm not sure wether I made this proc because it's good form or because of the name.
	if(!ass)
		return 0
	if(ass.loc != src.loc)
		ass = null
		updateUsrDialog()
		return 0
	else
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		atom_say("<span class='danger'>Attention: Posterior Placed on Printing Plaque!</span>")
		return 1

/obj/machinery/photocopier/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You overload [src]'s laser printing mechanism.</span>")
	else
		to_chat(user, "<span class='notice'>[src]'s laser printing mechanism is already overloaded!</span>")

/obj/item/toner
	name = "toner cartridge"
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	var/toner_amount = 30

#undef EMAG_DELAY
