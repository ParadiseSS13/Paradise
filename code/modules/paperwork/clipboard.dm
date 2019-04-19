#define PAPERWORK	1
#define PHOTO		2

/obj/item/clipboard
	name = "clipboard"
	desc = "It looks like you're writing a letter. Want some help?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	var/obj/item/pen/containedpen
	var/obj/item/toppaper
	slot_flags = SLOT_BELT
	burn_state = FLAMMABLE

/obj/item/clipboard/New()
	..()
	update_icon()

/obj/item/clipboard/verb/removePen(mob/user)
	set category = "Object"
	set name = "Remove clipboard pen"
	if(!ishuman(user) || user.incapacitated())
		return
	penPlacement(user, containedpen, FALSE)

/obj/item/clipboard/proc/isPaperwork(obj/item/W) //This could probably do with being somewhere else but for now it's fine here.
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/paper_bundle))
		return PAPERWORK
	if(istype(W, /obj/item/photo))
		return PHOTO

/obj/item/clipboard/proc/checkTopPaper()
	if(toppaper.loc != src) //Oh no! We're missing a top sheet! Better get another one to be at the top.
		toppaper = locate(/obj/item/paper) in src
		if(!toppaper) //In case there's no paper, try find a paper bundle instead (why is paper_bundle not a subtype of paper?)
			toppaper = locate(/obj/item/paper_bundle) in src

/obj/item/clipboard/examine(mob/user)
	if(..(user, 1) && toppaper)
		toppaper.examine(user)

obj/item/clipboard/proc/penPlacement(mob/user, obj/item/pen/P, placing)
	if(placing)
		if(containedpen)
			to_chat(user, "<span class='warning'>There's already a pen in [src]!</span>")
			return
		if(!is_pen(P))
			return
		to_chat(user, "<span class='notice'>You slide [P] into [src].</span>")
		user.unEquip(P)
		P.forceMove(src)
		containedpen = P
	else
		if(!containedpen)
			to_chat(user, "<span class='warning'>There isn't a pen in [src] for you to remove!</span>")
			return
		to_chat(user, "<span class='notice'>You remove [containedpen] from [src].</span>")
		user.put_in_hands(containedpen)
		containedpen = null
	update_icon()

/obj/item/clipboard/proc/showClipboard(mob/user) //Show them what's on the clipboard
	var/dat = "<title>[src]</title>"
	dat += "<a href='?src=[UID()];doPenThings=[containedpen ? "Remove" : "Add"]'>[containedpen ? "Remove pen" : "Add pen"]</a><br><hr>"
	if(toppaper)
		dat += "<a href='?src=[UID()];remove=\ref[toppaper]'>Remove</a><a href='?src=[UID()];viewOrWrite=\ref[toppaper]'>[toppaper.name]</a><br><hr>"
	for(var/obj/item/P in src)
		if(isPaperwork(P) == PAPERWORK && P != toppaper)
			dat += "<a href='?src=[UID()];remove=\ref[P]'>Remove</a><a href='?src=[UID()];topPaper=\ref[P]'>Put on top</a><a href='?src=[UID()];viewOrWrite=\ref[P]'>[P.name]</a><br>"
		if(isPaperwork(P) == PHOTO)
			dat += "<a href='?src=[UID()];remove=\ref[P]'>Remove</a><a href='?src=[UID()];viewOrWrite=\ref[P]'>[P.name]</a><br>"
	var/datum/browser/popup = new(user, "clipboard", "[src]", 400, 400)
	popup.set_content(dat)
	popup.open()

/obj/item/clipboard/update_icon()
	overlays.Cut()
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	if(containedpen)
		overlays += "clipboard_pen"
	overlays += "clipboard_over"
	..()

/obj/item/clipboard/attackby(obj/item/W, mob/user)
	if(isPaperwork(W)) //If it's a photo, paper bundle, or piece of paper, place it on the clipboard.
		user.unEquip(W)
		W.forceMove(src)
		to_chat(user, "<span class='notice'>You clip [W] onto [src].</span>")
		playsound(loc, "pageturn", 50, 1)
		if(isPaperwork(W) == PAPERWORK)
			toppaper = W
		update_icon()
	else if(is_pen(W))
		if(!toppaper) //If there's no paper we can write on, just stick the pen into the clipboard
			penPlacement(user, W, TRUE)
			return
		if(containedpen) //If there's a pen in the clipboard, let's just let them write and not bother asking about the pen
			toppaper.attackby(W, user)
			return
		var/writeonwhat = input(user, "Write on [toppaper.name], or place your pen in [src]?", "Pick one!") as null|anything in list("Write", "Place pen")
		if(!Adjacent(user) || user.incapacitated())
			return
		switch(writeonwhat)
			if("Write")
				toppaper.attackby(W, user)
			if("Place pen")
				penPlacement(user, W, TRUE)
			else
				return
	else if(istype(W, /obj/item/stamp) && toppaper) //We can stamp the topmost piece of paper
		toppaper.attackby(W, user)
		update_icon()
	else
		return ..()

/obj/item/clipboard/attack_self(mob/user)
	showClipboard(user)

/obj/item/clipboard/Topic(href, href_list)
	..()
	if(!Adjacent(usr) || usr.incapacitated())
		return
	var/obj/item/I = usr.get_active_hand()
	if(href_list["doPenThings"])
		if(href_list["doPenThings"] == "Add")
			penPlacement(usr, I, TRUE)
		else
			penPlacement(usr, containedpen, FALSE)
	else if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"])
		if(isPaperwork(P))
			usr.put_in_hands(P)
			to_chat(usr, "<span class='notice'>You remove [P] from [src].</span>")
			checkTopPaper() //So we don't accidentally make the top sheet not be on the clipboard
	else if(href_list["viewOrWrite"])
		var/obj/item/P = locate(href_list["viewOrWrite"])
		if(!isPaperwork(P))
			return
		if(is_pen(I) && isPaperwork(P) != PHOTO) //Because you can't write on photos that aren't in your hand
			P.attackby(I, usr)
		else if(isPaperwork(P) == PAPERWORK) //Why can't these be subtypes of paper
			P.examine(usr)
		else if(isPaperwork(P) == PHOTO)
			var/obj/item/photo/Ph = P
			Ph.show(usr)
	else if(href_list["topPaper"])
		var/obj/item/P = locate(href_list["topPaper"])
		if(P == toppaper)
			return
		to_chat(usr, "<span class='notice'>You flick the pages so that [P] is on top.</span>")
		playsound(loc, "pageturn", 50, 1)
		toppaper = P
	update_icon()
	showClipboard(usr)

#undef PAPERWORK
#undef PHOTO
