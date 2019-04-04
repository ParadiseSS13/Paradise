/obj/structure/aed
	name = "AED mount"
	desc = "Holds an Automatic external defibrillator."
	icon = 'icons/obj/closet.dmi'
	icon_state = "aed"
	density = FALSE
	anchored = TRUE
	var/opened = FALSE
	var/obj/item/defibrillator/aed/defib

/obj/structure/aed/New(turf/loc, ndir = null)
	..()
	if(ndir)
		pixel_x = (ndir & EAST|WEST) ? (ndir == EAST ? 28 : -28) : 0
		pixel_y = (ndir & NORTH|SOUTH)? (ndir == WEST ? 28 : -28) : 0
	update_icon()

/obj/structure/aed/loaded/New() //loaded subtype for mapping use
	..()
	defib = new/obj/item/defibrillator/aed/loaded(src)
	

/obj/structure/aed/Destroy()
	QDEL_NULL(defib)
	return ..()

/obj/structure/aed/update_icon()
	icon_state = "[initial(icon_state)][defib ? 1 : 0]-[opened ? "open" : "closed"]"

/obj/structure/aed/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/defibrillator/aed))
		if(!defib && opened)
			user.drop_item(O)
			contents += O
			defib = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
			update_icon()
			return
	open_close(user)
	update_icon()

/obj/structure/aed/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
		return
	if(opened && defib)
		user.put_in_hands(defib)
		to_chat(user, "<span class='notice'>You take [defib] from [src].</span>")
		defib = null
	else
		open_close(user)
	update_icon()

/obj/structure/aed/attack_tk(mob/user)
	if(opened && defib)
		defib.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [defib] from [src].</span>")
		defib = null
	else
		open_close(user)
	update_icon()

/obj/structure/aed/proc/open_close(mob/user)
	to_chat(user, "<span class='notice'>You [opened ? "close" : "open"] [src].</span>")
	opened = !opened