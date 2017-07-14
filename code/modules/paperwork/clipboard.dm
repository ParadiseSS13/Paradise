#define PAPERWORK	1
#define PHOTO		2

/obj/item/weapon/clipboard
	name = "clipboard"
	desc = "It looks like you're writing a letter. Want some help?"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/weapon/pen
	var/obj/item/weapon/toppaper
	slot_flags = SLOT_BELT
	burn_state = FLAMMABLE

/obj/item/weapon/clipboard/New()
	..()
	update_icon()

/obj/item/weapon/clipboard/verb/removePen()
	set category = "Object"
	set name = "Remove clipboard pen"
	if(!ishuman(usr) || usr.incapacitated())
		return
	penPlacement(FALSE, pen)

/obj/item/weapon/clipboard/proc/isPaperwork(var/obj/item/weapon/W) //This could probably do with being somewhere else but for now it's fine here.
	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/paper_bundle))
		return PAPERWORK
	if(istype(W, /obj/item/weapon/photo))
		return PHOTO

/obj/item/weapon/clipboard/proc/isPen(var/obj/item/weapon/W) //Should also probably be somewhere else
	if(istype(W, /obj/item/weapon/pen))
		return TRUE

/obj/item/weapon/clipboard/proc/checkTopPaper()
	if(toppaper.loc != src) //Oh no! We're missing a top sheet! Better get another one to be at the top.
		var/obj/item/weapon/paper/newtoppaper = locate(/obj/item/weapon/paper) in src
		if(!newtoppaper) //In case there's no paper, try find a paper bundle instead (why is paper_bundle not a subtype of paper?)
			newtoppaper = locate(/obj/item/weapon/paper_bundle) in src
		if(newtoppaper)
			toppaper = newtoppaper
		else
			toppaper = null

obj/item/weapon/clipboard/proc/penPlacement(var/placing, var/obj/item/weapon/pen/P)
	if(placing == TRUE)
		if(pen)
			to_chat(usr, "<span class = 'warning'>There's already a pen in [src]!</span>")
			return
		if(!isPen(P))
			return
		to_chat(usr, "<span class='notice'>You slide [P] into [src].</span>")
		usr.unEquip(P)
		P.forceMove(src)
		pen = P
	else
		if(!pen)
			to_chat(usr, "<span class = 'warning'>There isn't a pen in [src] for you to remove!</span>")
			return
		to_chat(usr, "<span class = 'notice'>You remove [pen] from [src].</span>")
		usr.put_in_hands(pen)
		pen = null
	update_icon()

/obj/item/weapon/clipboard/proc/show_clipboard() //Show them what's on the clipboard
	var/dat = "<title>[src]</title>"
	dat += "<a href='?src=[UID()];doPenThings=[pen ? "Remove" : "Add"]'>[pen ? "Remove pen" : "Add pen"]</a><br><hr>"
	for(var/obj/item/weapon/P in src)
		if(isPaperwork(P) == PAPERWORK)
			dat += "<a href='?src=[UID()];remove=\ref[P]'>Remove</a> <a href='?src=[UID()];topPaper=\ref[P]'>[toppaper == P ? "On top" : "Put on top"]</a> <a href='?src=[UID()];viewOrWrite=\ref[P]'>[toppaper == P ? "<strong>" : null][P.name][toppaper == P ? "</strong>" : null]</a><br><br>"
		if(isPaperwork(P) == PHOTO)
			dat += "<a href='?src=[UID()];remove=\ref[P]'>Remove</a> <a href='?src=[UID()];viewOrWrite=\ref[P]'>[P.name]</a><br><br>"
	var/datum/browser/popup = new(usr, "clipboard", "[src]", 400, 400)
	popup.set_content(dat)
	popup.open()

/obj/item/weapon/clipboard/update_icon()
	overlays.Cut()
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	if(pen)
		overlays += "clipboard_pen"
	overlays += "clipboard_over"
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/W, mob/user)
	var/obj/item/weapon/P = W
	if(isPaperwork(P)) //If it's a photo, paper bundle, or piece of paper, place it on the clipboard.
		user.unEquip(P)
		P.forceMove(src)
		to_chat(user, "<span class='notice'>You clip [P] onto [src].</span>")
		if(isPaperwork(P) == PAPERWORK)
			toppaper = P
		update_icon()
	else if(isPen(W)) //If it's not a pen, we're done here
		if(!toppaper) //If there's no paper we can write on, just stick the pen into the clipboard
			penPlacement(TRUE, P)
			return
		if(pen) //If there's a pen in the clipboard, let's just let them write and not bother asking about the pen
			var/obj/item/weapon/paper/T = toppaper
			T.attackby(P, user)
			return
		var/writeonwhat = input(user, "Write on [toppaper.name], or place your pen in [src]?", "Pick one!") as null|anything in list("Write", "Place pen")
		if(!writeonwhat)
			return
		if(writeonwhat == "Write")
			var/obj/item/weapon/paper/T = toppaper
			T.attackby(P, user)
		else if(writeonwhat == "Place pen")
			penPlacement(TRUE, P)

/obj/item/weapon/clipboard/attack_self(mob/user)
	show_clipboard()

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if(!Adjacent(usr) || usr.incapacitated())
		return
	var/obj/item/I = usr.get_active_hand()
	if(href_list["doPenThings"])
		if(href_list["doPenThings"] == "Add")
			var/obj/item/weapon/pen/W = usr.get_active_hand()
			penPlacement(TRUE, W)
		else
			penPlacement(FALSE, pen)
	else if(href_list["remove"])
		var/obj/item/P = locate(href_list["remove"])
		if(isPaperwork(P))
			usr.put_in_hands(P)
			to_chat(usr, "<span class = 'notice'>You remove [P] from [src].</span>")
			checkTopPaper() //So we don't accidentally make the top sheet not be on the clipboard
	else if(href_list["viewOrWrite"])
		var/obj/item/weapon/P = locate(href_list["viewOrWrite"])
		if(!isPaperwork(P))
			return
		if(isPen(I) && isPaperwork(P) != PHOTO) //Because you can't write on photos that aren't in your hand
			P.attackby(I, usr)
		else if(isPaperwork(P) == PAPERWORK) //Why can't these be subtypes of paper
			P.examine(usr)
		else if(isPaperwork(P) == PHOTO)
			var/obj/item/weapon/photo/Ph = P
			Ph.show(usr)
	else if(href_list["topPaper"])
		var/obj/item/weapon/paper/P = locate(href_list["topPaper"])
		if(P == toppaper)
			return
		to_chat(usr, "<span class = 'notice'>You flick the pages so that [P] is on top.</span>")
		playsound(loc, "pageturn", 50, 1)
		toppaper = P
	update_icon()
	show_clipboard()

#undef PAPERWORK
#undef PHOTO
