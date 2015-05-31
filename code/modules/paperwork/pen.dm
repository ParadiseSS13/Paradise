/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 */


/*
 * Pens
 */
/obj/item/weapon/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	m_amt = 10
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2


/obj/item/weapon/pen/blue
	name = "blue-ink pen"
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/weapon/pen/red
	name = "red-ink pen"
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/weapon/pen/gray
	name = "gray-ink pen"
	desc = "It's a normal gray ink pen."
	colour = "gray"

/obj/item/weapon/pen/invisible
	desc = "It's an invisble pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/weapon/pen/multi //spaceman96: Trenna Seber
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

/obj/item/weapon/pen/fancy
	name = "fancy pen"
	desc = "A fancy metal pen. It uses blue ink. An inscription on one side reads,\"L.L. - L.R.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fancypen"

/obj/item/weapon/pen/gold
	name = "Gilded Pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'Nanotrasen' is etched on the clip of the pen."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "eugene_pen"

/obj/item/weapon/pen/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(M.can_inject(user, 1))
		user << "<span class='warning'>You stab [M] with the pen.</span>"
//		M << "<span class='danger'>You feel a tiny prick!</span>"
		. = 1

	add_logs(M, user, "stabbed", object="[name]")

/*
 * Sleepypens
 */
/obj/item/weapon/pen/sleepy
	flags = OPENCONTAINER
	origin_tech = "materials=2;syndicate=5"


/obj/item/weapon/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))	return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)
				reagents.trans_to(M, 50)


/obj/item/weapon/pen/sleepy/New()
	create_reagents(100)
	reagents.add_reagent("ketamine", 100)
	..()
