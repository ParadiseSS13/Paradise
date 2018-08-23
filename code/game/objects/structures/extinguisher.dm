#define NO_EXTINGUISHER 0
#define NORMAL_EXTINGUISHER 1
#define MINI_EXTINGUISHER 2


/obj/structure/extinguisher_cabinet
	name = "extinguisher cabinet"
	desc = "A small wall mounted cabinet designed to hold a fire extinguisher."
	icon = 'icons/obj/closet.dmi'
	icon_state = "extinguisher_closed"
	anchored = 1
	density = 0
	var/obj/item/extinguisher/has_extinguisher = null
	var/extinguishertype
	var/opened = 0
	var/material_drop = /obj/item/stack/sheet/metal

/obj/structure/extinguisher_cabinet/New(turf/loc, ndir = null)
	..()
	if(ndir)
		pixel_x = (ndir & EAST|WEST) ? (ndir == EAST ? 28 : -28) : 0
		pixel_y = (ndir & NORTH|SOUTH)? (ndir == WEST ? 28 : -28) : 0
	switch(extinguishertype)
		if(NO_EXTINGUISHER)
			return
		if(MINI_EXTINGUISHER)
			has_extinguisher = new/obj/item/extinguisher/mini
		else
			has_extinguisher = new/obj/item/extinguisher

/obj/structure/extinguisher_cabinet/Destroy()
	QDEL_NULL(has_extinguisher)
	return ..()
	
/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/extinguisher))
		if(!has_extinguisher && opened)
			user.drop_item(O)
			contents += O
			has_extinguisher = O
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
		else
			opened = !opened
	else if(istype(O, /obj/item/weldingtool))
		if(has_extinguisher)
			to_chat(user, "<span class='warning'>You need to remove the extinguisher before deconstructing the cabinet!</span>")
			return
		if(!opened)
			to_chat(user, "<span class='warning'>Open the cabinet before cutting it apart!</span>")
			return
		var/obj/item/weldingtool/WT = O
		if(!WT.remove_fuel(0, user))
			return
		to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
		playsound(loc, WT.usesound, 40, 1)
		if(do_after(user, 40 * WT.toolspeed, 1, target = src))
			if(!src ||!opened || !WT.isOn()) // !src to prevent it being duped
				return
			visible_message("<span class='notice'>[user] slices apart [src].</span>",
							"<span class='notice'>You cut [src] apart with [WT].</span>",
							"<span class='italics'>You hear welding.</span>")
			var/turf/T = get_turf(src)
			new material_drop(T)
			qdel(src)
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_hand(mob/user)
	if(isrobot(user) || isalien(user))
		to_chat(user, "<span class='notice'>You don't have the dexterity to do this!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return
	if(has_extinguisher)
		user.put_in_hands(has_extinguisher)
		to_chat(user, "<span class='notice'>You take [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(has_extinguisher)
		has_extinguisher.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [has_extinguisher] from [src].</span>")
		has_extinguisher = null
		opened = 1
	else
		opened = !opened
	update_icon()


/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(has_extinguisher)
		if(istype(has_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini"
		else
			icon_state = "extinguisher_full"
	else
		icon_state = "extinguisher_empty"

/obj/structure/extinguisher_cabinet/empty/New(turf/loc, ndir = null)
	extinguishertype = NO_EXTINGUISHER
	..()

#undef NO_EXTINGUISHER
#undef NORMAL_EXTINGUISHER
#undef MINI_EXTINGUISHER
