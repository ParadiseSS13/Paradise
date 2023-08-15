/* Pens!
 * Contains:
 *		Pens
 *		Sleepy Pens
 *		Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	slot_flags = SLOT_BELT | SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2

/obj/item/pen/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] starts scribbling numbers over [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit sudoku.</span>")
	return BRUTELOSS

/obj/item/pen/blue
	name = "blue-ink pen"
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	name = "red-ink pen"
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"

/obj/item/pen/gray
	name = "gray-ink pen"
	desc = "It's a normal gray ink pen."
	colour = "gray"

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/multi
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

	// these values are for the overlay
	var/list/colour_choices = list(
		"black" = list(0.25, 0.25, 0.25),
		"red" = list(1, 0.25, 0.25),
		"green" = list(0, 1, 0),
		"blue" = list(0.5, 0.5, 1),
		"yellow" = list(1, 1, 0))
	var/pen_colour_iconstate = "pencolor"
	var/pen_colour_shift = 3

/obj/item/pen/multi/Initialize(mapload)
	..()
	update_icon()

/obj/item/pen/multi/proc/select_colour(mob/user as mob)
	var/newcolour = input(user, "Which colour would you like to use?", name, colour) as null|anything in colour_choices
	if(newcolour)
		colour = newcolour
		playsound(loc, 'sound/effects/pop.ogg', 50, 1)
		update_icon()

/obj/item/pen/multi/attack_self(mob/living/user as mob)
	select_colour(user)

/obj/item/pen/multi/update_overlays()
	. = ..()
	var/icon/colour_overlay = new(icon, pen_colour_iconstate)
	var/list/colours = colour_choices[colour]
	colour_overlay.SetIntensity(colours[1], colours[2], colours[3])
	if(pen_colour_shift)
		colour_overlay.Shift(SOUTH, pen_colour_shift)
	. += colour_overlay

/obj/item/pen/fancy
	name = "fancy pen"
	desc = "A fancy metal pen. An inscription on one side reads, \"L.L. - L.R.\""
	icon_state = "fancypen"

/obj/item/pen/multi/gold
	name = "Gilded Pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'Nanotrasen' is etched on the clip of the pen."
	icon_state = "goldpen"
	pen_colour_shift = 0

/obj/item/pen/multi/fountain
	name = "Engraved Fountain Pen"
	desc = "An expensive looking pen."
	icon_state = "fountainpen"
	pen_colour_shift = 0

/*
 * Sleepypens
 */
/obj/item/pen/sleepy
	container_type = OPENCONTAINER
	origin_tech = "engineering=4;syndicate=2"


/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(!M.can_inject(user, TRUE))
		return
	var/transfered = 0
	var/contained = list()

	for(var/R in reagents.reagent_list)
		var/datum/reagent/reagent = R
		contained += "[round(reagent.volume, 0.01)]u [reagent]"

	if(reagents.total_volume && M.reagents)
		transfered = reagents.trans_to(M, 50)
	to_chat(user, "<span class='warning'>You sneakily stab [M] with the pen.</span>")
	add_attack_logs(user, M, "Stabbed with (sleepy) [src]. [transfered]u of reagents transfered from pen containing [english_list(contained)].")
	for(var/datum/reagent/R as anything in reagents.reagent_list)
		if(initial(R.id) == "????") // Yes this is a specific case that we don't really want
			return TRUE
	reagents.reaction(M, REAGENT_INGEST, 0.1)
	return TRUE


/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(100)
	reagents.add_reagent("ketamine", 100)


/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	origin_tech = "combat=3;syndicate=1"
	var/on = FALSE
	var/brightness_on = 2
	light_color = LIGHT_COLOR_RED
	var/backstab_sound = 'sound/items/unsheath.ogg'
	var/backstab_damage = 12
	armour_penetration_flat = 20
	throw_speed = 4

/obj/item/pen/edagger/attack(mob/living/M, mob/living/user, def_zone)
	var/extra_force_applied = FALSE
	if(on && user.dir == M.dir && !HAS_TRAIT(M, TRAIT_FLOORED) && user != M)
		force += backstab_damage
		extra_force_applied = TRUE
		add_attack_logs(user, M, "Backstabbed with [src]", ATKLOG_ALL)
		M.apply_damage(40, STAMINA) //Just enough to slow
		M.KnockDown(2 SECONDS)
		M.visible_message("<span class='warning'>[user] stabs [M] in the back!</span>", "<span class='userdanger'>[user] stabs you in the back! The energy blade makes you collapse in pain!</span>")

		playsound(loc, backstab_sound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	else
		playsound(loc, hitsound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	. = ..()
	if(extra_force_applied)
		force -= backstab_damage

/obj/item/pen/edagger/get_clamped_volume() //So the parent proc of attack isn't the loudest sound known to man
	return 0


/obj/item/pen/edagger/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		w_class = initial(w_class)
		name = initial(name)
		attack_verb = list()
		hitsound = initial(hitsound)
		embed_chance = initial(embed_chance)
		throwforce = initial(throwforce)
		playsound(user, 'sound/weapons/saberoff.ogg', 2, 1)
		to_chat(user, "<span class='warning'>[src] can now be concealed.</span>")
		set_light(0)
	else
		on = TRUE
		force = 18
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/blade1.ogg'
		embed_chance = 100 //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 2, 1)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
		set_light(brightness_on, 1)
	set_sharpness(on)
	update_icon()

/obj/item/pen/edagger/update_icon_state()
	if(on)
		icon_state = "edagger"
		item_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		item_state = initial(item_state)

/obj/item/proc/on_write(obj/item/paper/P, mob/user)
	return

/obj/item/pen/multi/poison
	var/current_poison = null

/obj/item/pen/multi/poison/attack_self(mob/living/user)
	. = ..()
	switch(colour)
		if("black")
			current_poison = null
		if("red")
			current_poison = "amanitin"
		if("green")
			current_poison = "polonium"
		if("blue")
			current_poison = "teslium"
		if("yellow")
			current_poison = "pancuronium"

/obj/item/pen/multi/poison/on_write(obj/item/paper/P, mob/user)
	if(current_poison)
		if(P.contact_poison)
			to_chat(user, "<span class='warning'>[P] is already coated.</span>")
		else
			P.contact_poison = current_poison
			P.contact_poison_volume = 20
			P.contact_poison_poisoner = user.name
			add_attack_logs(user, P, "Poison pen'ed")
			to_chat(user, "<span class='warning'>You apply the poison to [P].</span>")
