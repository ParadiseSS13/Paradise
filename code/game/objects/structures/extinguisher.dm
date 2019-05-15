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
	obj_integrity = 200
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/extinguisher/stored_extinguisher
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
			stored_extinguisher = new/obj/item/extinguisher/mini
		else
			stored_extinguisher = new/obj/item/extinguisher

/obj/structure/extinguisher_cabinet/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>Alt-click to [opened ? "close":"open"] it.</span>")

/obj/structure/extinguisher_cabinet/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!in_range(src, user))
		return
	if(!iscarbon(usr))
		return
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	opened = !opened
	toggle_cabinet()

/obj/structure/extinguisher_cabinet/proc/toggle_cabinet(mob/user)
	if(opened && broken)
		user << "<span class='warning'>[src] is broken open.</span>"
	else
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
		opened = !opened
		update_icon()

/obj/structure/extinguisher_cabinet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		broken = 1
		opened = 1
		update_icon()
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null

/obj/structure/extinguisher_cabinet/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal (loc, 2)
		if(stored_extinguisher)
			stored_extinguisher.forceMove(loc)
			stored_extinguisher = null
	qdel(src)

/obj/structure/extinguisher_cabinet/Destroy()
	if(stored_extinguisher)
		qdel(stored_extinguisher)
		stored_extinguisher = null
	return ..()
	
/obj/structure/extinguisher_cabinet/attackby(obj/item/O, mob/user, params)
	if(isrobot(user) || isalien(user))
		return
	if(istype(O, /obj/item/extinguisher))
		if(!stored_extinguisher && opened)
			if(!user.drop_item())
				return
			user.drop_item(O)
			contents += O
			stored_extinguisher = O
			update_icon()
			to_chat(user, "<span class='notice'>You place [O] in [src].</span>")
			return TRUE
		else
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
			opened = !opened
	else if(istype(O, /obj/item/weldingtool))
		if(stored_extinguisher)
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
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
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
	if(stored_extinguisher)
		if(icon_state == "extinguisher_closed")
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		user.put_in_hands(stored_extinguisher)
		to_chat(user, "<span class='notice'>You take [stored_extinguisher] from [src].</span>")
		stored_extinguisher = null
		opened = 1
	else
		playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		opened = !opened
	update_icon()

/obj/structure/extinguisher_cabinet/attack_tk(mob/user)
	if(stored_extinguisher)
		if(icon_state == "extinguisher_closed")
			playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
		stored_extinguisher.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [stored_extinguisher] from [src].</span>")
		stored_extinguisher = null
		opened = 1
	else
		toggle_cabinet()


/obj/structure/extinguisher_cabinet/update_icon()
	if(!opened)
		icon_state = "extinguisher_closed"
		return
	if(stored_extinguisher)
		if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
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
