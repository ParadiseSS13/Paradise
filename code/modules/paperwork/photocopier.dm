#define PHOTOCOPIER_DELAY 15
///Global limit on copied papers and photos, bundles are counted as a sum of their parts
#define MAX_COPIES_PRINTABLE 300

/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"

	anchored = TRUE
	density = TRUE
	idle_power_consumption = 30
	active_power_consumption = 200
	max_integrity = 300
	integrity_failure = 100
	atom_say_verb = "bleeps"

	COOLDOWN_DECLARE(copying_cooldown)

	var/insert_anim = "bigscanner1"
	///Is the photocopier performing an action currently?
	var/copying = FALSE

	///Current obj stored in the copier to be copied
	var/obj/item/copyitem = null
	///Current folder obj stored in the copier to copy into
	var/obj/item/folder = null
	///Mob that is currently on the photocopier
	var/mob/living/copymob = null

	var/copies = 1
	var/toner = 60
	///Max number of copies that can be made at one time
	var/maxcopies = 10
	var/max_saved_documents = 5

	///Lazy init list, Objs currently saved inside the photocopier for printing later
	var/list/saved_documents

	///Total copies printed from copymachines globally
	var/static/total_copies = 0
	var/static/max_copies_reached = FALSE


/obj/machinery/photocopier/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/photocopier/attack_hand(mob/user)
	if(..())
		return TRUE
	ui_interact(user)

/**
  * Public proc for copying paper objs
  *
  * Takes a paper object and makes a copy of it. This proc specifically does not change toner which allows more versatile use for child objects
  * returns null if paper failed to be copied and returns the new copied paper obj if succesful
  * Arguments:
  * * obj/item/paper/copy - The paper obj to be copied
  * * scanning -  If true, the photo is stored inside the photocopier and we do not check for toner
  * * bundled - If true the photo is stored inside the photocopier, used by bundlecopy() to construct paper bundles
  */
/obj/machinery/photocopier/proc/papercopy(obj/item/paper/copy, scanning = FALSE, bundled = FALSE)
	if(!scanning)
		if(toner < 1)
			visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
			return null
		total_copies++
	var/obj/item/paper/c = new /obj/item/paper (loc)
	if(scanning || bundled)
		c.forceMove(src)
	else if(folder)
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
	var/list/temp_overlays = copy.stamp_overlays       //Iterates through stamps
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
			c.stamp_overlays += img
	c.updateinfolinks()
	return c

/**
  * Public proc for copying photo objs
  *
  * Takes a photo object and makes a copy of it. This proc specifically does not change toner which allows more versatile use for child objects
  * returns null if photo failed to be copied and returns the new copied photo object if succesful
  * Arguments:
  * * obj/item/photo/photocopy - The photo obj to be copied
  * * scanning -  If true, the photo is stored inside the photocopier and we do not check for toner
  * * bundled - If true the photo is stored inside the photocopier, used by bundlecopy() to construct paper bundles
  */
/obj/machinery/photocopier/proc/photocopy(obj/item/photo/photocopy, scanning = FALSE, bundled = FALSE)
	if(!scanning) //If we're just storing this as a file inside the copier then we don't expend toner
		if(toner < 5)
			visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
			return null
		total_copies++

	var/obj/item/photo/p = new /obj/item/photo (loc)
	if(scanning || bundled)
		p.forceMove(src)
	else if(folder)
		p.forceMove(folder)
	p.name = photocopy.name
	p.icon = photocopy.icon
	p.tiny = photocopy.tiny
	p.img = photocopy.img
	p.desc = photocopy.desc
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	if(photocopy.scribble)
		p.scribble = photocopy.scribble
	return p


/obj/machinery/photocopier/proc/copyass(scanning = FALSE)
	if(!scanning) //If we're just storing this as a file inside the copier then we don't expend toner
		if(toner < 5)
			visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner to finish the operation.</span>")
			return null
		total_copies++

	var/icon/temp_img

	if(emagged)
		if(ishuman(copymob))
			var/mob/living/carbon/human/H = copymob
			var/obj/item/organ/external/G = H.get_organ("groin")
			G.receive_damage(0, 30)
			H.emote("scream")
		else
			copymob.apply_damage(30, BURN)
		to_chat(copymob, "<span class='notice'>Something smells toasty...</span>")
	if(ishuman(copymob)) //Suit checks are in check_mob
		var/mob/living/carbon/human/H = copymob
		temp_img = icon('icons/obj/butts.dmi', H.dna.species.butt_sprite)
	else if(isdrone(copymob))
		temp_img = icon('icons/obj/butts.dmi', "drone")
	else if(isnymph(copymob))
		temp_img = icon('icons/obj/butts.dmi', "nymph")
	else if(isalien(copymob) || istype(copymob,/mob/living/simple_animal/hostile/alien)) //Xenos have their own asses, thanks to Pybro.
		temp_img = icon('icons/obj/butts.dmi', "xeno")
	else
		return
	var/obj/item/photo/p = new /obj/item/photo (loc)
	if(scanning)
		p.forceMove(src)
	else if(folder)
		p.forceMove(folder)
	p.desc = "You see [copymob]'s ass on the photo."
	p.pixel_x = rand(-10, 10)
	p.pixel_y = rand(-10, 10)
	p.img = temp_img
	var/icon/small_img = icon(temp_img) //Icon() is needed or else temp_img will be rescaled too >.>
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	p.icon = ic
	return p

/**
  * A public proc for copying bundles of paper
  *
  * It iterates through each object in the bundle and calls papercopy() and photocopy() and stores the produce photo/paper in the bundle
  * Arguments:
  * * bundle - The paper bundle object being copied
  * * scanning - If true, the paper bundle is stored inside the photocopier
  * * use_toner - If true, this operation uses toner, this is not done in copy() because partial bundles would be impossible otherwise
  */
/obj/machinery/photocopier/proc/bundlecopy(obj/item/paper_bundle/bundle, scanning = FALSE, use_toner = FALSE)
	var/obj/item/paper_bundle/P = new /obj/item/paper_bundle (src, default_papers = FALSE)
	P.forceMove(src) //Bundle is initially inside copier to give copier time to build the bundle before the player can pick it up
	for(var/obj/item/W in bundle)
		if(istype(W, /obj/item/paper))
			W = papercopy(W, bundled = TRUE)
			if(use_toner && W)
				toner-- //In order to allow partial bundles we have to handle toner +- inside the proc
		else if(istype(W, /obj/item/photo))
			W = photocopy(W, bundled = TRUE)
			if(use_toner && W)
				toner -= 5
		if(!W)
			break
		W.forceMove(P)
		P.amount++
	P.amount-- //amount variable should be the number of pages in addition to the first (#pages - 1) this avoids runtimes from index errors
	if(!P.amount) //if we did not have enough toner to complete the second page, delete the bundle
		qdel(P)
		return FALSE
	if(!scanning)
		total_copies++
		if(folder) //Since bundle is still inside the copier, we need to finally move it out
			P.forceMove(folder)
		else
			P.forceMove(loc)

	P.update_icon()

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
			usr.put_in_hands(copyitem)
		to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
		copyitem = null

	else if(check_mob())
		to_chat(copymob, "<span class='notice'>You feel a slight pressure on your ass.</span>")
		atom_say("Attention: Unable to remove large object!")

/obj/machinery/photocopier/proc/remove_folder()
	if(copying)
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return
	if(folder)
		folder.forceMove(get_turf(src))
		if(ishuman(usr))
			usr.put_in_hands(folder)
		to_chat(usr, "<span class='notice'>You take \the [folder] out of \the [src].</span>")
		folder = null

/**
  * An internal proc for checking if a photocopier is able to copy an object
  *
  * It performs early checks/returns to see if the copier has any toner, if the copier is powered/working,
  * if the copier is currently perfoming an action, or if we've hit the global copy limit. Used to inform
  * the player in-game if they're using the photocopier incorrectly (no toner, no item inside, etc)
  * Arguments:
  * * scancopy - If TRUE, cancopy does not check for an item on/inside the copier to copy, used for copying stored files
  */
/obj/machinery/photocopier/proc/cancopy(scancopy = FALSE) //are we able to make a copy of a doc?
	if(stat & (BROKEN|NOPOWER))
		return FALSE
	if(copying) //are we in the process of copying something already?
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return FALSE
	if(!scancopy && toner <= 0) //if we're not scanning lets check early that we actually have toner
		visible_message("<span class='notice'>A yellow light on [src] flashes, indicating there's not enough toner for the operation.</span>")
		return FALSE
	if(max_copies_reached)
		visible_message("<span class='warning'>The printer screen reads \"MAX COPIES REACHED, PHOTOCOPIER NETWORK OFFLINE: PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
		return FALSE
	if(total_copies >= MAX_COPIES_PRINTABLE)
		visible_message("<span class='warning'>The printer screen reads \"MAX COPIES REACHED, PHOTOCOPIER NETWORK OFFLINE: PLEASE CONTACT SYSTEM ADMINISTRATOR\".</span>")
		message_admins("Photocopier cap of [MAX_COPIES_PRINTABLE] paper copies reached, all photocopiers are now disabled.")
		max_copies_reached = TRUE
	if(!check_mob() && (!copyitem && !scancopy)) //is there anything in or ontop of the machine? If not, is this a scanned file?
		visible_message("<span class='notice'>A red light on [src] flashes, indicating there's nothing in [src] to copy.</span>")
		return FALSE
	return TRUE

/**
  * Public proc for copying items
  *
  * Determines what item needs to be copied whether it's a mob's ass, paper, bundle, or photo and then calls the respective
  * proc for it. Most toner var changing happens here so that the faxmachine child obj does not need to worry about toner
  * Arguments:
  * * obj/item/C - The item stored inside the photocopier to be copied (obj/paper, obj/photo, obj/paper_bundle)
  * * scancopy - Indicates that obj/item/C is a stored file, we need to pass this on to cancopy() so it passes the check
  */
/obj/machinery/photocopier/proc/copy(obj/item/C, scancopy = FALSE)
	if(!cancopy(scancopy))
		return
	copying = TRUE
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	if(istype(C, /obj/item/paper))
		for(var/i in copies to 1 step -1)
			if(!papercopy(C))
				break
			toner -= 1
			use_power(active_power_consumption)
			sleep(PHOTOCOPIER_DELAY)
	else if(istype(C, /obj/item/photo))
		for(var/i in copies to 1 step -1)
			if(!photocopy(C))
				break
			toner -= 5
			use_power(active_power_consumption)
			sleep(PHOTOCOPIER_DELAY)
	else if(istype(C, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/B = C
		for(var/i in copies to 1 step -1)
			if(!bundlecopy(C, use_toner = TRUE))
				break
			use_power(active_power_consumption)
			sleep(PHOTOCOPIER_DELAY * (B.amount + 1))
	else if(check_mob()) //Once we've scanned the copy_mob's ass we do not need to again
		for(var/i in copies to 1 step -1)
			if(!copyass())
				break
			toner -= 5
	else
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be copied by \the [src], ejecting.</span>")
		copyitem.forceMove(loc) //fuckery detected! get off my photocopier... shitbird!

	copying = FALSE

/obj/machinery/photocopier/proc/scan_document() //scan a document into a file
	if(!cancopy())
		return
	if(length(saved_documents) >= max_saved_documents)
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be scanned because the max file limit has been reached. Please delete a file to make room.</span>")
		return
	copying = TRUE
	var/obj/item/O
	//Instead of calling copy() we jump ahead and use the procs that do the heavy lifting to avoid using toner since we're only scanning
	if(istype(copyitem, /obj/item/paper))
		O = papercopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/photo))
		O = photocopy(copyitem, scanning = TRUE)
	else if(istype(copyitem, /obj/item/paper_bundle))
		O = bundlecopy(copyitem, scanning = TRUE, use_toner = FALSE)
	else if(copymob && copymob.loc == loc)
		O = copyass(scanning = TRUE)
	else
		to_chat(usr, "<span class='warning'>\The [copyitem] can't be scanned by \the [src].</span>")
		copying = FALSE
		return
	use_power(active_power_consumption)
	COOLDOWN_START(src, copying_cooldown, PHOTOCOPIER_DELAY)
	LAZYADD(saved_documents, O)
	copying = FALSE
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	atom_say("Document successfully scanned!")

/obj/machinery/photocopier/proc/delete_file(uid)
	var/document = locateUID(uid)
	if(LAZYIN(saved_documents, document)) //double checking that the list exists b4 we find document
		LAZYREMOVE(saved_documents, document)
		qdel(document)

/obj/machinery/photocopier/proc/file_copy(uid)
	var/document = locateUID(uid)
	if(LAZYIN(saved_documents, document))
		copy(document, scancopy = TRUE)


/obj/machinery/photocopier/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Photocopier", name, 402, 368, master_ui, state)
		ui.open()

/obj/machinery/photocopier/ui_data(mob/user)
	var/list/data = list()
	data["copynumber"] = copies
	data["toner"] = toner
	data["copyitem"] = (copyitem ? copyitem.name : null)
	data["folder"] = (folder ? folder.name : null)
	data["mob"] = (copymob ? copymob.name : null)
	data["files"] = list()
	data["issilicon"] = issilicon(user)
	if(LAZYLEN(saved_documents))
		for(var/obj/item/O in saved_documents)
			var/list/document_data = list(
				name = O.name,
				uid = O.UID()
			)
			data["files"] += list(document_data)
	return data

/obj/machinery/photocopier/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return
	. = FALSE
	if(!COOLDOWN_FINISHED(src, copying_cooldown))
		to_chat(usr, "<span class='warning'>[src] is busy, try again in a few seconds.</span>")
		return
	add_fingerprint(usr)
	switch(action)
		if("copy")
			copy(copyitem)
		if("removedocument")
			remove_document()
			. = TRUE
		if("removefolder")
			remove_folder()
			. = TRUE
		if("add")
			if(copies < maxcopies)
				copies++
				. = TRUE
		if("minus")
			if(copies > 0)
				copies--
				. = TRUE
		if("scandocument")
			scan_document()
		if("ai_text")
			ai_text(ui.user)
		if("ai_pic")
			ai_pic()
		if("filecopy")
			file_copy(params["uid"])
		if("deletefile")
			delete_file(params["uid"])
			. = TRUE
	update_icon()

/obj/machinery/photocopier/proc/ai_text(mob/user)
	if(!issilicon(user))
		return
	if(stat & (BROKEN|NOPOWER))
		return
	var/text = input("Enter what you want to write:", "Write", null, null) as message
	if(!text)
		return
	if(toner < 1 || !user)
		return
	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	var/obj/item/paper/p = new /obj/item/paper(loc)
	text = p.parsepencode(text, null, user)
	p.info = text
	p.populatefields()
	toner -= 1
	use_power(active_power_consumption)
	COOLDOWN_START(src, copying_cooldown, PHOTOCOPIER_DELAY)

/obj/machinery/photocopier/proc/ai_pic()
	if(!issilicon(usr))
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(toner < 5)
		return
	var/mob/living/silicon/tempAI = usr
	var/obj/item/camera/siliconcam/camera = tempAI.aiCamera

	if(!camera)
		return
	var/datum/picture/selection = camera.selectpicture()
	if(!selection)
		return

	playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)
	var/obj/item/photo/p = new /obj/item/photo(loc)
	p.construct(selection)
	if(p.desc == "")
		p.desc += "Copied by [tempAI.name]"
	else
		p.desc += " - Copied by [tempAI.name]"
	toner -= 5
	use_power(active_power_consumption)
	COOLDOWN_START(src, copying_cooldown, PHOTOCOPIER_DELAY)

/obj/machinery/photocopier/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/paper) || istype(O, /obj/item/photo) || istype(O, /obj/item/paper_bundle))
		if(!copyitem)
			user.drop_item()
			copyitem = O
			O.forceMove(src)
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			flick(insert_anim, src)
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
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else if(istype(O, /obj/item/grab)) //For ass-copying.
		var/obj/item/grab/G = O
		if(ismob(G.affecting) && G.affecting != copymob)
			var/mob/GM = G.affecting
			visible_message("<span class='warning'>[usr] drags [GM.name] onto the photocopier!</span>")
			GM.forceMove(get_turf(src))
			copymob = GM
			if(copyitem)
				copyitem.forceMove(get_turf(src))
				copyitem = null
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

/obj/machinery/photocopier/MouseDrop_T(mob/target, mob/living/user)
	if(!istype(target) || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.stat || isAI(user) || target.move_resist > user.pull_force)
		return
	if(check_mob()) //is target mob or another mob on this photocopier already?
		return
	src.add_fingerprint(user)
	if(target == user && !user.incapacitated())
		visible_message("<span class='warning'>[usr] jumps onto [src]!</span>")
	else if(target != user && !user.restrained() && !user.stat && !user.IsWeakened() && !user.IsStunned() && !user.IsParalyzed())
		if(target.anchored) return
		if(!ishuman(user)) return
		visible_message("<span class='warning'>[usr] drags [target.name] onto [src]!</span>")
	target.forceMove(get_turf(src))
	copymob = target
	if(copyitem)
		copyitem.forceMove(get_turf(src))
		visible_message("<span class='notice'>[copyitem] is shoved out of the way by [copymob]!</span>")
		copyitem = null
	playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)
	atom_say("Attention: Posterior Placed on Printing Plaque!")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/photocopier/Destroy()
	QDEL_LIST_CONTENTS(saved_documents)
	return ..()

/**
  * Internal proc for checking the Mob on top of the copier
  * Reports FALSE if there is no copymob or if the copymob is in a diff location than the copy machine, otherwise reports TRUE
  */
/obj/machinery/photocopier/proc/check_mob()
	if(!copymob)
		return FALSE
	if(copymob.loc != loc)
		copymob = null
		return FALSE
	else
		return TRUE

/obj/machinery/photocopier/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
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
