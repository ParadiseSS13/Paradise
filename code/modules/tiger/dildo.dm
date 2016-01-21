//Stolen from Nexendia~

/obj/item/weapon/dildo
	name = "\improper Dragon Dildo"
	desc = "It's a Dragon Dildo. If you are seeing this, please make an issue report detailing how you came across it."

	icon       = 'icons/obj/dildos.dmi'
	icon_state = null

	force      = 5
	throwforce = 5
	w_class    = 1

	hitsound    = 'sound/items/squishy.ogg'
	attack_verb = list("slapped")

/obj/item/weapon/dildo/attack(mob/living/carbon/human/M, mob/user)
	. = ..()

	if(istype(M))
		spawn(2)
			if(user && M)
				user.visible_message("<span class='userdanger'>[uppertext(user.name)] HAS ANGRERED THE GODS!</span>")

				loc = get_turf(user)
				user.gib()

				M.drop_l_hand()
				M.drop_r_hand()

				M.put_in_hands(src)
				M << "<span class='notice'>\The [src] has chosen you to be it's new master!</span><span class='danger'> Now, go fuck yourself.</span>"
				//Yep.


/obj/item/weapon/dildo/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is shoving \the [src] down \his throat! It looks like they're trying to commit suicide.</span>")
	return(BRUTELOSS)

/obj/item/weapon/dildo/sea
	name = "\improper Sea Dragon Dildo"
	desc = "A Sea Dragon Dildo. Always wet!"

	icon_state = "seadragon"

	w_class = 2


/obj/item/weapon/dildo/canine
	name = "\improper Vulvakin Dildo"
	desc = "A Canine Dildo, designed to look very close to those of the Vulvakin species."

	icon_state = "canine"

	w_class    = 2
	throwforce = 7

/obj/item/weapon/dildo/equine
	name       = "\improper Equine Dildo"
	desc       = "It's a fucking horse cock."
	icon_state = "equine"

	force      = 11
	throwforce = 9
	w_class    = 3

//stolen from eros
/obj/item/weapon/dildo/metal_dildo
	name = "metal dildo"
	desc = "Who the fuck made a metal dildo?"

	icon_state = "metal_dildo"
	item_state = "metal_dildo"

	slot_flags = SLOT_BELT

/obj/item/weapon/dildo/bigblackdick
	name = "big black dick"
	desc = "Once you go black, you never go back!"

	icon_state = "bigblackdick"
	item_state = "bigblackdick"

	slot_flags = SLOT_BELT

/obj/item/weapon/dildo/purple_dong
	name = "purple dong"
	desc = "Reminiscent of your mother's dildo."

	icon_state = "purple-dong"
	item_state = "purple-dong"

	slot_flags = SLOT_BELT

/obj/item/weapon/dildo/floppydick
	name = "floppy dick"
	desc = "It's floppy."

	icon_state = "floppydick"
	item_state = "floppydick"

	slot_flags = SLOT_BELT

/obj/item/weapon/dildo/floppydick/examine(mob/user)
	if(user.gender == FEMALE)
		user << "\icon[src] That's a [src]. It is a small item.\n It's floppy. Very familiar!"
	else
		. = ..()


/obj/structure/shelf/dildo
	name = "\improper Dildo Shelf"
	desc = "A shelf for all of your oversized Dildos."
	icon = 'icons/obj/dildos.dmi'
	icon_state = "shelf1"

/obj/structure/shelf/dildo/alt
	name = "\improper Dildo Shelf"
	desc = "A shelf for all of your oversized Dildos."
	icon_state = "shelf2"
