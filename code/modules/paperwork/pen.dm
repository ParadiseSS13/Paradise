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
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2

/obj/item/weapon/pen/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] starts scribbling numbers over \himself with the [src.name]! It looks like \he's trying to commit sudoku.</span>")
	return (BRUTELOSS)

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

/obj/item/weapon/pen/multi
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

	// these values are for the overlay
	var/list/colour_choices = list(
		"black" = list(0.25, 0.25, 0.25),
		"red" = list(1, 0.25, 0.25),
		"green" = list(0, 1, 0),
		"blue" = list(0.5, 0.5, 1),
		"yellow" = list(1, 1, 0))
	var/pen_color_iconstate = "pencolor"
	var/pen_color_shift = 3

/obj/item/weapon/pen/multi/New()
	..()
	update_icon()

/obj/item/weapon/pen/multi/proc/select_colour(mob/user as mob)
	var/newcolour = input(user, "Which colour would you like to use?", name, colour) as null|anything in colour_choices
	if(newcolour)
		colour = newcolour
		playsound(loc, 'sound/effects/pop.ogg', 50, 1)
		update_icon()

/obj/item/weapon/pen/multi/attack_self(mob/living/user as mob)
	select_colour(user)

/obj/item/weapon/pen/multi/update_icon()
	overlays.Cut()
	var/icon/o = new(icon, pen_color_iconstate)
	var/list/c = colour_choices[colour]
	o.SetIntensity(c[1], c[2], c[3])
	if(pen_color_shift)
		o.Shift(SOUTH, pen_color_shift)
	overlays += o

/obj/item/weapon/pen/fancy
	name = "fancy pen"
	desc = "A fancy metal pen. It uses blue ink. An inscription on one side reads,\"L.L. - L.R.\""
	icon_state = "fancypen"

/obj/item/weapon/pen/multi/gold
	name = "Gilded Pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'Nanotrasen' is etched on the clip of the pen."
	icon_state = "goldpen"
	pen_color_shift = 0

/obj/item/weapon/pen/multi/fountain
	name = "Engraved Fountain Pen"
	desc = "An expensive looking pen."
	icon_state = "fountainpen"
	pen_color_shift = 0

/obj/item/weapon/pen/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(!force)
		if(M.can_inject(user, 1))
			to_chat(user, "<span class='warning'>You stab [M] with the pen.</span>")
//			to_chat(M, "<span class='danger'>You feel a tiny prick!</span>")
			. = 1

		add_logs(user, M, "stabbed", object="[name]")

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
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
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
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
	update_icon()

/obj/item/weapon/pen/edagger/update_icon()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)
