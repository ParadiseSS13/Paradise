/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Edaggers
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
	icon_override = 'icons/mob/in-hand/tools.dmi'
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
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

	if(!force)
		if(M.can_inject(user, 1))
			user << "<span class='warning'>You stab [M] with the pen.</span>"
//			M << "<span class='danger'>You feel a tiny prick!</span>"
			. = 1

		add_logs(M, user, "stabbed", object="[name]")

	else
		. = ..()

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


/*
 * (Alan) Edaggers
 */
/obj/item/weapon/pen/edagger
	origin_tech = "combat=3;syndicate=5"
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut") //these wont show up if the pen is off
	var/on = 0

/obj/item/weapon/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = 0
		force = initial(force)
		sharp = 0
		edge = 0
		w_class = initial(w_class)
		name = initial(name)
		hitsound = initial(hitsound)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, 1)
		user << "<span class='warning'>[src] can now be concealed.</span>"
	else
		on = 1
		force = 18
		sharp = 1
		edge = 1
		w_class = 3
		name = "energy dagger"
		hitsound = 'sound/weapons/blade1.ogg'
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 5, 1)
		user << "<span class='warning'>[src] is now active.</span>"
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)