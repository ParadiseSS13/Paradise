//CONTAINS: Evidence bags

/obj/item/evidencebag
	name = "evidence bag"
	desc = "An empty evidence bag."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_state = ""
	w_class = WEIGHT_CLASS_TINY

/obj/item/evidencebag/afterattack(obj/item/I, mob/user,proximity)
	if(!proximity || loc == I)
		return
	evidencebagEquip(I, user)

/obj/item/evidencebag/attackby(obj/item/I, mob/user, params)
	if(evidencebagEquip(I, user))
		return 1

/obj/item/evidencebag/proc/evidencebagEquip(obj/item/I, mob/user)
	if(!istype(I) || I.anchored == 1)
		return

	if(istype(I, /obj/item/storage/box))
		to_chat(user, "<span class='notice'>This box is too big to fit in the evidence bag.</span>")
		return

	if(istype(I, /obj/item/evidencebag))
		to_chat(user, "<span class='notice'>You find putting an evidence bag in another evidence bag to be slightly absurd.</span>")
		return 1 //now this is podracing

	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, "<span class='notice'>[I] won't fit in [src].</span>")
		return

	if(contents.len)
		to_chat(user, "<span class='notice'>[src] already has something inside it.</span>")
		return

	if(!isturf(I.loc)) //If it isn't on the floor. Do some checks to see if it's in our hands or a box. Otherwise give up.
		if(istype(I.loc,/obj/item/storage))	//in a container.
			var/obj/item/storage/U = I.loc
			U.remove_from_storage(I, src)
		else if(user.l_hand == I)					//in a hand
			user.drop_l_hand()
		else if(user.r_hand == I)					//in a hand
			user.drop_r_hand()
		else
			return

	user.visible_message("<span class='notice'>[user] puts [I] into [src].</span>", "<span class='notice'>You put [I] inside [src].</span>",\
	"<span class='notice'>You hear a rustle as someone puts something into a plastic bag.</span>")

	icon_state = "evidence"

	var/xx = I.pixel_x	//save the offset of the item
	var/yy = I.pixel_y
	I.pixel_x = 0		//then remove it so it'll stay within the evidence bag
	I.pixel_y = 0
	var/image/img = image("icon"=I, "layer"=FLOAT_LAYER)	//take a snapshot. (necessary to stop the underlays appearing under our inventory-HUD slots ~Carn
	img.plane = FLOAT_PLANE
	I.pixel_x = xx		//and then return it
	I.pixel_y = yy
	overlays += img
	overlays += "evidence"	//should look nicer for transparent stuff. not really that important, but hey.

	desc = "An evidence bag containing [I]. [I.desc]"
	I.loc = src
	w_class = I.w_class
	return 1

/obj/item/evidencebag/attack_self(mob/user)
	if(contents.len)
		var/obj/item/I = contents[1]
		user.visible_message("<span class='notice'>[user] takes [I] out of [src].</span>", "<span class='notice'>You take [I] out of [src].</span>",\
		"<span class='notice'>You hear someone rustle around in a plastic bag, and remove something.</span>")
		overlays.Cut()	//remove the overlays
		user.put_in_hands(I)
		w_class = WEIGHT_CLASS_TINY
		icon_state = "evidenceobj"
		desc = "An empty evidence bag."

	else
		to_chat(user, "[src] is empty.")
		icon_state = "evidenceobj"

