/obj/structure/bed/roller/bluespace
	name = "bluespace roller bed"
	desc = "A high technology bluespace roller bed. It seems to be floating in midair."
	icon = 'icons/hispania/obj/rollerbed.dmi'

/obj/structure/bed/roller/bluespace/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(has_buckled_mobs())
			return 0
		usr.visible_message("<span class='notice'>[usr] collapses \the [name].</span>", "<span class='notice'>You collapse \the [name].</span>")
		new/obj/item/roller/bluespace(get_turf(src))
		qdel(src)

/obj/item/roller/bluespace
	name = "bluespace roller bed"
	desc = "A collapsed bluespace roller bed that can be carried around even in your backpack."
	icon = 'icons/hispania/obj/rollerbed.dmi'
	w_class = WEIGHT_CLASS_NORMAL // Can be put in backpacks.

/obj/item/roller/bluespace/attack_self(mob/user)
	var/obj/structure/bed/roller/bluespace/R = new /obj/structure/bed/roller/bluespace(user.loc)
	R.add_fingerprint(user)
	qdel(src)