/obj/structure/bed/roller/bluespace
	name = "bluespace roller bed"
	desc = "A high technology bluespace roller bed. It seems to be floating in midair."
	icon = 'icons/hispania/obj/rollerbed.dmi'

/obj/structure/bed/roller/bluespace/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(has_buckled_mobs())
			return FALSE
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

/obj/structure/bed/dogbed/ducktron
	desc = "A comfy-looking duck bed. You can even strap your pet in, in case the gravity turns off."
	name = "Ducks's bed"
	anchored = TRUE

/obj/structure/bed/dogbed/garronte
	desc = "A comfy-looking owl bed. You can even strap your pet in, in case the gravity turns off."
	name = "Garronte's bed"
	anchored = TRUE

/obj/structure/bed/roller/advanced
	name = "advanced roller bed"
	desc = "A robust roller bed, perfect for field surgery."
	icon = 'icons/hispania/obj/rollerbed_adv.dmi'

/obj/structure/bed/roller/advanced/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!ishuman(usr))
			return
		if(has_buckled_mobs())
			return FALSE
		usr.visible_message("<span class='notice'>[usr] collapses \the [name].</span>", "<span class='notice'>You collapse \the [name].</span>")
		new/obj/item/roller/advanced(get_turf(src))
		qdel(src)

/obj/item/roller/advanced
	name = "advanced roller bed"
	desc = "A collapsed advanced roller bed that can be use for field surgery."
	icon = 'icons/hispania/obj/rollerbed_adv.dmi'

/obj/item/roller/advanced/attack_self(mob/user)
	var/obj/structure/bed/roller/advanced/R = new (user.loc)
	R.add_fingerprint(user)
	qdel(src)
