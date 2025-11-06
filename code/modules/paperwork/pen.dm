/* Pens!
 * CONTENTS:
 *	1. PENS
 *	2. SLEEPYPENS
 *	3. E-DAGGERS
	4. POISON PEN
 */


// PENS

/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BOTH_EARS
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	materials = list(MAT_METAL=10)
	var/colour = "black"	//what colour the ink is!
	pressure_resistance = 2

/obj/item/pen/suicide_act(mob/user)
	to_chat(viewers(user), "<span class='suicide'>[user] starts scribbling numbers over [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit sudoku!</span>")
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

/obj/item/pen/multi/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/pen/multi/proc/select_colour(mob/user as mob)
	var/newcolour = tgui_input_list(user, "Which colour would you like to use?", name, colour_choices)
	if(newcolour)
		colour = newcolour
		playsound(loc, 'sound/effects/pop.ogg', 50, 1)
		update_icon()

/obj/item/pen/multi/attack_self__legacy__attackchain(mob/living/user as mob)
	select_colour(user)

/obj/item/pen/multi/update_overlays()
	. = ..()
	var/icon/colour_overlay = new(icon, pen_colour_iconstate)
	var/list/colours = colour_choices[colour]
	colour_overlay.SetIntensity(colours[1], colours[2], colours[3])
	. += colour_overlay

/obj/item/pen/fancy
	name = "fancy pen"
	desc = "A fancy metal pen. An inscription on one side reads, \"L.L. - L.R.\""
	icon_state = "fancypen"

/obj/item/pen/multi/gold
	name = "gilded pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'Nanotrasen' is etched on the clip of the pen."
	icon_state = "goldpen"

/obj/item/pen/multi/fountain
	name = "engraved fountain pen"
	desc = "An expensive-looking pen typically issued to Nanotrasen employees."
	icon_state = "fountainpen"

/obj/item/pen/multi/syndicate
	name = "syndicate fountain pen"
	desc = "A suspicious-looking pen issued to Syndicate staff."
	icon_state = "pen_syndie"

/obj/item/pen/cap
	name = "captain's fountain pen"
	desc = "An expensive pen only issued to station captains."
	icon_state = "pen_cap"

/obj/item/pen/hop
	name = "head of personnel's fountain pen"
	desc = "An expensive-looking pen only issued to heads of service."
	icon_state = "pen_hop"

/obj/item/pen/hos
	name = "head of security's fountain pen"
	desc = "An expensive-looking pen only issued to heads of security."
	icon_state = "pen_hos"

/obj/item/pen/cmo
	name = "chief medical officer's fountain pen"
	desc = "An expensive-looking pen only issued to heads of medical."
	icon_state = "pen_cmo"

/obj/item/pen/ce
	name = "chief engineer's fountain pen"
	desc = "An expensive-looking pen only issued to heads of engineering."
	icon_state = "pen_ce"

/obj/item/pen/rd
	name = "research director's fountain pen"
	desc = "An expensive-looking pen only issued to heads of research."
	icon_state = "pen_rd"

/obj/item/pen/qm
	name = "quartermaster's fountain pen"
	desc = "An expensive-looking pen only issued to heads of cargo."
	icon_state = "pen_qm"

//  SLEEPYPEN

/obj/item/pen/sleepy
	container_type = OPENCONTAINER
	origin_tech = "engineering=4;syndicate=2"
	var/transfer_amount = 50

/obj/item/pen/sleepy/attack__legacy__attackchain(mob/living/M, mob/user)
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
		var/fraction = min(transfer_amount / reagents.total_volume, 1)
		reagents.reaction(M, REAGENT_INGEST, fraction)
		transfered = reagents.trans_to(M, transfer_amount)
	to_chat(user, "<span class='warning'>You sneakily stab [M] with the pen.</span>")
	add_attack_logs(user, M, "Stabbed with (sleepy) [src]. [transfered]u of reagents transfered from pen containing [english_list(contained)].")
	return TRUE

/obj/item/pen/sleepy/Initialize(mapload)
	. = ..()
	create_reagents(100)
	fill_pen()

/obj/item/pen/sleepy/proc/fill_pen()
	reagents.add_reagent("ketamine", 100)

/obj/item/pen/sleepy/love
	name = "fancy pen"
	desc = "A fancy metal pen. An inscription on one side reads, \"L.L. - L.R.\""
	icon_state = "fancypen"
	container_type = (DRAINABLE | TRANSPARENT) //cannot be refilled, but pax can be extracted for use in other items with syringe
	transfer_amount = 25 // 4 Dosages instead of 2

/obj/item/pen/sleepy/love/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/pen/sleepy/love/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/pen/sleepy/love/fill_pen()
	reagents.add_reagent("pax", 100) // strong and unique reagent, making you a pacifist for a long time.

/obj/item/pen/sleepy/love/process()
	if(reagents.total_volume < 100)
		reagents.add_reagent("pax", 0.5) // slow refill over time. In average 1 dose every 100 seconds.


/obj/item/pen/sleepy/undisguised
	name = "sleepy pen"
	desc = "Used to stealthily inject targets. Comes loaded with ketamine but can be refilled with other chemicals. This one isn't disguised."
	icon_state = "pen_syndie"

// E-DAGGER

/obj/item/pen/edagger
	inhand_icon_state = null
	origin_tech = "combat=3;syndicate=1"
	var/active = FALSE
	var/brightness_on = 2
	light_color = LIGHT_COLOR_RED
	var/backstab_sound = 'sound/items/unsheath.ogg'
	var/backstab_damage = 12
	armor_penetration_flat = 20
	throw_speed = 4

/obj/item/pen/edagger/attack__legacy__attackchain(mob/living/M, mob/living/user, def_zone)
	if(cigarette_lighter_act(user, M))
		return

	var/extra_force_applied = FALSE
	if(active && user.dir == M.dir && !HAS_TRAIT(M, TRAIT_FLOORED) && user != M)
		force += backstab_damage
		extra_force_applied = TRUE
		add_attack_logs(user, M, "Backstabbed with [src]", ATKLOG_ALL)
		M.apply_damage(40, STAMINA) //Just enough to slow
		M.KnockDown(2 SECONDS)
		M.visible_message(
			"<span class='warning'>[user] stabs [M] in the back!</span>",
			"<span class='userdanger'>[user] stabs you in the back! The energy blade makes you collapse in pain!</span>"
		)

		playsound(loc, backstab_sound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	else
		playsound(loc, hitsound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	. = ..()
	if(extra_force_applied)
		force -= backstab_damage

/obj/item/pen/edagger/cigarette_lighter_act(mob/living/user, mob/living/carbon/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(!active)
		to_chat(user, "<span class='warning'>You need to activate [src] before you can light anything with it!</span>")
		return TRUE

	if(target == user)
		user.visible_message(
			"<span class='warning'>[user] makes a violent slashing motion, barely missing [user.p_their()] nose as light flashes! \
			[user.p_they(TRUE)] light[user.p_s()] [user.p_their()] [cig] with [src] in the process.</span>",
			"<span class='notice'>You casually slash [src] at [cig], lighting it with the blade.</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	else
		user.visible_message(
			"<span class='danger'>[user] makes a violent slashing motion, barely missing the nose of [target] as light flashes! \
			[user.p_they(TRUE)] light[user.p_s()] [cig] in the mouth of [target] with [src] in the process.</span>",
			"<span class='notice'>You casually slash [src] at [cig] in the mouth of [target], lighting it with the blade.</span>",
			"<span class='danger'>You hear an energy blade slashing something!</span>"
		)
	user.do_attack_animation(target)
	playsound(user.loc, hitsound, 5, TRUE, ignore_walls = FALSE, falloff_distance = 0)
	cig.light(user, target)
	return TRUE

/obj/item/pen/edagger/get_clamped_volume() //So the parent proc of attack isn't the loudest sound known to man
	return FALSE

/obj/item/pen/edagger/attack_self__legacy__attackchain(mob/living/user)
	if(active)
		active = FALSE
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
		active = TRUE
		force = 18
		w_class = WEIGHT_CLASS_NORMAL
		name = "energy dagger"
		attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
		hitsound = 'sound/weapons/blade1.ogg'
		embed_chance = 100 //rule of cool
		throwforce = 35
		playsound(user, 'sound/weapons/saberon.ogg', 2, TRUE)
		to_chat(user, "<span class='warning'>[src] is now active.</span>")
		set_light(brightness_on, 1)
	set_sharpness(active)
	update_icon()

/obj/item/pen/edagger/update_icon_state()
	if(active)
		icon_state = "edagger"
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.

/obj/item/proc/on_write(obj/item/paper/P, mob/user)
	return

// POISON PEN

/obj/item/pen/multi/poison
	var/current_poison = null

/obj/item/pen/multi/poison/attack_self__legacy__attackchain(mob/living/user)
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

// MARK: CHAMELEON PEN
/obj/item/pen/chameleon
	var/forge_name

/obj/item/pen/chameleon/attack_self__legacy__attackchain(mob/user)
	if(!iscarbon(user))
		return

	if(!Adjacent(user) || user.incapacitated())
		return

	forge_name = tgui_input_text(user, "Enter the name of the person whose signature you want to forge", "Forge name", max_length = MAX_NAME_LEN)

