#define PHOTOCOPIER_DELAY 15
#define MAX_COPIES_PRINTABLE 300

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
	max_integrity = 300
	integrity_failure = 100
	var/copying = FALSE //are we copying right now?
	atom_say_verb = "bleeps"

	var/obj/item/copyitem = null	//what's in the copier!
	var/obj/item/folder = null   //Folder in the copier

	var/copies = 1	//how many copies to print!
	var/toner = 60 //how much toner is left! woooooo~
	var/toner_requirement = 1 //How much toner will be required for this operation
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/mob/living/M = null //Whose ass are we copying? This is important information, hence why there is a var for it.

	var/list/saved_documents = list()
	var/max_saved_documents = 5

	var/static/total_copies = 0 //Global tracking of total copied items
	var/static/max_copies_reached = FALSE

/obj/machinery/photocopier/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	if(..() || (stat & NOPOWER))
		return
	ui_interact(user)

/obj/machinery/photocopier/proc/papercopy(obj/item/paper/copy, scanning = FALSE)
	var/obj/item/paper/c = new /obj/item/paper (loc)
	if (scanning)
		c.forceMove(src)
	else if (folder)
		c.forceMove(folder)
	c.header = copy.header
	c.info = copy.info
	c.footer = copy.footer
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
	if(!scanning)
		toner--
		total_copies++
	return c


/obj/machinery/photocopier/proc/photocopy(obj/item/photo/photocopy, scanning = FALSE)
	var/obj/item/photo/p = new /obj/item/photo (loc)
	if (scanning)
		p.forceMove(src)
	else if (folder)
		p.forceMove(folder)
	p.name = photocopy.name
	p.icon = photocopy.icon
	p.tiny = photocopy.tiny
	p.img = photocopy.img
	p.desc = photocopy.desc
	p.pixel_x = photocopy.pixel_x
	p.pixel_y = photocopy.pixel_y
	if(photocopy.scribble)
		p.scribble = photocopy.scribble
	if(!scanning)
		toner -= 5
		total_copies++
	if(toner < 0)
		toner = 0
	return p


/obj/machinery/photocopier/proc/copyass(scanning = FALSE)
	var/icon/temp_img
	if(!check_mob()) //You have to be sitting on the copier and either be a xeno or a human without clothes on.
		return
	if(emagged)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/external/G = H.get_organ("groin")
			G.receive_damage(0, 30)
			H.emote("scream")
		else
			M.apply_damage(30, BURN)
		to_chat(M, "<span class='notice'>Something smells toasty...</span>")
	if(ishuman(M)) //Suit checks are in check_mob
		var/mob/living/carbon/human/H = M
		temp_img = icon('icons/obj/butts.dmi', H.dna.species.butt_sprite)
	else if(istype(M,/mob/living/silicon/robot/drone))
		temp_img = icon('icons/obj/butts.dmi', "drone")
	else if(istype(M,/mob/living/simple_animal/diona))
		temp_img = icon('icons/obj/butts.dmi', "nymph")
	else if(isalien(M) || istype(M,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/obj/butts.dmi', "xeno")
	else
		return
	var/obj/item/photo/p = new /obj/item/photo (loc)
	if (scanning)
		p.forceMove(src)
	else if (folder)
		p.forceMove(folder)
	p.desc = "You see [M]'s ass on the photo."
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.img = temp_img
	var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	p.icon = ic
	if(!scanning)
		toner -= 5
		total_copies++
	if(toner < 0)
		toner = 0
	return p

//If need_toner is 0, the copies will still be lightened when low on toner, however it will not be prevented from printing. TODO: Implement print queues for fax machines and get rid of need_toner
/obj/machinery/photocopier/proc/bundlecopy(obj/item/paper_bundle/bundle, need_toner=1, scanning = FALSE)
	var/obj/item/paper_bundle/P = new /obj/item/paper_bundle (src, default_papers = FALSE)
	if (scanning)
		P.forceMove(src)
	else if (folder)
		P.forceMove(folder)
	for(var/obj/item/W in bundle)
		if(toner <= 0 && need_toner)
			toner = 0
			break

		if(istype(W, /obj/item/paper))
			W = papercopy(W, scanning)
		else if(istype(W, /obj/item/photo))
			W = photocopy(W, scanning)
		W.forceMove(P)
		P.amount++
	if(!P.amount)
		qdel(P)
		return null
	P.amount--
	if(!scanning)
		toner-= P.amount
		total_copies++
		if(!folder)
			P.forceMove(get_turf(src))
	P.update_icon()
	SStgui.update_uis(src)

	P.icon_state = "paper_words"
	P.name = bundle.name
	P.pixel_y = rand(-8, 8)
	P.pixel_x = rand(-9, 9)
	return P

/obj/machinery/photocopier/proc/remove_document()
	if(copying)
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		if(ishuman(usr))
			if(!usr.get_active_hand())
				usr.put_in_hands(copyitem)
		to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
		copyitem = null
		SStgui.update_uis(src)
	else if(check_mob())
		to_chat(M, "<span class='notice'>You feel a slight pressure on your ass.</span>")
		atom_say("Attention: Unable to remove large object!")

/obj/machinery/photocopier/proc/remove_folder()
	if(copying)
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return
	if(folder)
		folder.forceMove(get_turf(src))
		if(ishuman(usr))
			if(!usr.get_active_hand())
				usr.put_in_hands(folder)
		to_chat(usr, "<span class='notice'>You take \the [folder] out of \the [src].</span>")
		folder = null
		SStgui.update_uis(src)

/obj/machinery/photocopier/proc/cancopy(scancopy = FALSE) //are we able to make a copy of a doc?
	if(stat & (BROKEN|NOPOWER))
		return

	if(max_copies_reached)
		visible_message("<span class='warning'>The printer screen reads \"MAX COPIES REACHED, PHOTOCOPIER NETWORK OFFLINE: PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
		return
	if(total_copies >= MAX_COPIES_PRINTABLE)
		visible_message("<span class='warning'>The printer screen reads \"MAX COPIES REACHED, PHOTOCOPIER NETWORK OFFLINE: PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
		message_admins("Photocopier cap of [MAX_COPIES_PRINTABLE] paper copies reached, all photocopiers are now disabled.")
		max_copies_reached = TRUE

	if(copying) //are we in the process of copying something already?
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return
	if((!M || !check_mob()) && (!copyitem && !scancopy)) //is there anything in or ontop of the machine? If not, is this a scanned file?
		visible_message("<span class='notice'>A red light on [src] flashes, indicating there's nothing in [src] to copy.</span>")
		return
	return TRUE

/obj/machinery/photocopier/proc/copy(obj/item/C, scancopy = FALSE)
	if(!cancopy(scancopy))
		return
	if(toner <= 0)
		visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner for the operation.</span>")
		return
	copying = TRUE
	if(istype(C, /obj/item/paper))
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		for(var/i = copies; i > 0; i--)
			if (toner > 0)
				papercopy(C)
				use_power(active_power_usage)
				sleep(PHOTOCOPIER_DELAY)
			else
				visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
				break
	else if(istype(C, /obj/item/photo))
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		for(var/i = copies; i > 0; i--)
			if (toner > 4)
				photocopy(C)
				use_power(active_power_usage)
				sleep(PHOTOCOPIER_DELAY)
			else
				visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
				break
	else if(istype(C, /obj/item/paper_bundle))
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		var/obj/item/paper_bundle/I = copyitem
		for(var/i = copies; i > 0; i--)
			if(toner < (I.amount + 1))
				visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
				return // It is better to prevent partial bundle than to produce broken paper bundle
			var/obj/item/paper_bundle/B = bundlecopy(C)
			if(!B) //B returned null because it was partial
				break
			sleep(PHOTOCOPIER_DELAY*B.amount)
	else if(M && M.loc == src.loc)
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)
		for(var/i = copies; i > 0; i--)
			if(toner > 4)
				copyass()
				sleep(PHOTOCOPIER_DELAY)
			else
				visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
				break
	else
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be copied by \the [src].</span>")
	copying = FALSE
	SStgui.update_uis(src)

/obj/machinery/photocopier/proc/scan_document() //scan a document into a file
	if(!cancopy())
		return
	if(saved_documents.len >= max_saved_documents)
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be scanned because the max file limit has been reached. Please delete a file to make room.</span>")
		return
	copying = TRUE
	var/obj/item/O
	if(istype(copyitem, /obj/item/paper))
		O = papercopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/photo))
		O = photocopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/paper_bundle))
		O = bundlecopy(copyitem, scanning = TRUE)
	else if(M && M.loc == src.loc)
		O = copyass(scanning = TRUE)
	else
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be scanned by \the [src].</span>")
		copying = FALSE
		return
	use_power(active_power_usage)
	sleep(PHOTOCOPIER_DELAY)
	saved_documents.Add(O)
	copying = FALSE
	playsound(loc, 'sound/machines/ping.ogg', 50, 0)
	atom_say("Document succesfully scanned!")

/obj/machinery/photocopier/proc/delete_file(uid)
	var/document = locateUID(uid)
	if(document in saved_documents)
		saved_documents.Remove(document)
		qdel(document)
		SStgui.update_uis(src)

/obj/machinery/photocopier/proc/file_copy(uid)
	var/document = locateUID(uid)
	if(document in saved_documents)
		copy(document, scancopy=TRUE)


/obj/machinery/photocopier/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Photocopier", name, 402, 368, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	var/list/data = list()
	data["copynumber"] = copies
	data["toner"] = toner
	data["copyitem"] = (copyitem ? copyitem.name : null)
	data["folder"] = (folder ? folder.name : null)
	data["mob"] = (M ? M.name : null)
	data["files"] = list()
	for(var/obj/item/O in saved_documents)
		var/list/document_data = list(
			name = O.name,
			uid = O.UID()
		)
		data["files"] += list(document_data)
	return data

/obj/machinery/photocopier/ui_act(action, list/params)
	if(..())
		return
	add_fingerprint(usr)
	switch(action)
		if("copy")
			copy(copyitem)
		if("removedocument")
			remove_document()
		if("removefolder")
			remove_folder()
		if("add")
			if(copies<maxcopies)
				copies++
		if("minus")
			if(copies>0)
				copies--
		if("scandocument")
			scan_document()
		if("filecopy")
			file_copy(params["uid"])
		if("deletefile")
			delete_file(params["uid"])
	update_icon()

/obj/machinery/photocopier/proc/aipic()
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
		SStgui.update_uis(src)
		sleep(15)

/obj/machinery/photocopier/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo) || istype(O, /obj/item/paper_bundle))
		if(!copyitem)
			user.drop_item()
			copyitem = O
			O.forceMove(src)
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			flick(insert_anim, src)
			SStgui.update_uis(src)
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/toner))
		if(toner <= 10) //allow replacing when low toner is affecting the print darkness
			user.drop_item()
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			var/obj/item/toner/T = O
			toner += T.toner_amount
			qdel(O)
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(istype(O, /obj/item/folder))
		if(!folder) //allow replacing when low toner is affecting the print darkness
			user.drop_item()
			to_chat(user, "<span class='notice'>You slide the [O] into \the [src].</span>")
			folder = O
			O.forceMove(src)
			SStgui.update_uis(src)
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(istype(O, /obj/item/grab)) //For ass-copying.
		var/obj/item/grab/G = O
		if(ismob(G.affecting) && G.affecting != M)
			var/mob/GM = G.affecting
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.forceMove(get_turf(src))
			M = GM
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				copyitem = null
			SStgui.update_uis(src)
	else
		return ..()

/obj/machinery/photocopier/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/photocopier/obj_break(damage_flag)
	if(!(flags & NODECONSTRUCT))
		if(toner > 0)
			new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
			toner = 0

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/user)
	if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || istype(user, /mob/living/silicon/ai))
		return
	if (check_mob()) //is target mob or another mob on this photocopier already?
		return
	src.add_fingerprint(user)
	if(target == user && !user.incapacitated())
		visible_message("<span class='warning'>[usr] jumps onto [src]!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.stunned && !user.paralysis)
		if(target.anchored) return
		if(!ishuman(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto [src]!</span>")
	target.forceMove(get_turf(src))
	M = target
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		visible_message("<span class='notice'>[copyitem] is shoved out of the way by [M]!</span>")
		copyitem = null
	playsound(loc, 'sound/machines/ping.ogg', 50, 0)
	atom_say("Attention: Posterior Placed on Printing Plaque!")

/obj/machinery/photocopier/proc/check_mob()
	if(!M)
		return FALSE
	if(M.loc != src.loc) //Is there a mob ontop of the photocopier?
		M = null
		return FALSE
	else
		return TRUE

/obj/machinery/photocopier/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You overload [src]'s laser printing mechanism.</span>")
	else
		to_chat(user, "<span class='notice'>[src]'s laser printing mechanism is already overloaded!</span>")


//TODO: Add an emp_act effect for photocopiers -sirryan

/obj/item/toner
	name = "toner cartridge"
	icon = 'icons/obj/device.dmi'
	icon_state = "tonercartridge"
	var/toner_amount = 30

#undef PHOTOCOPIER_DELAY
#undef MAX_COPIES_PRINTABLE
