/obj/item/gun/syringe
	name = "syringe gun"
	desc = "A spring loaded rifle designed to fit syringes, used to incapacitate unruly patients from a distance."
	icon_state = "syringegun"
	item_state = "syringegun"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=2;biotech=3"
	throw_speed = 3
	throw_range = 7
	force = 4
	materials = list(MAT_METAL=2000)
	clumsy_check = 0
	fire_sound = 'sound/items/syringeproj.ogg'
	var/list/syringes = list()
	var/max_syringes = 1

/obj/item/gun/syringe/Initialize()
	..()
	chambered = new /obj/item/ammo_casing/syringegun(src)

/obj/item/gun/syringe/process_chamber()
	if(!length(syringes) || chambered.BB)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]
	if(!S)
		return

	chambered.BB = new S.projectile_type(src)
	S.reagents.trans_to(chambered.BB, S.reagents.total_volume)
	chambered.BB.name = S.name

	syringes.Remove(S)
	qdel(S)

/obj/item/gun/syringe/afterattack(atom/target, mob/living/user, flag, params)
	if(target == loc)
		return
	..()

/obj/item/gun/syringe/examine(mob/user)
	. = ..()
	var/num_syringes = syringes.len + (chambered.BB ? 1 : 0)
	. += "Can hold [max_syringes] syringe\s. Has [num_syringes] syringe\s remaining."

/obj/item/gun/syringe/attack_self(mob/living/user)
	if(!length(syringes) && !chambered.BB)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return FALSE

	var/obj/item/reagent_containers/syringe/S
	if(length(syringes))
		S = syringes[length(syringes)]
	else if(chambered.BB)
		// Remove the chambered syringe only if there's no syringe left
		S = new()
		chambered.BB.reagents.trans_to(S, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
		process_chamber()

	user.put_in_hands(S)
	syringes.Remove(S)
	to_chat(user, "<span class='notice'>You unload [S] from [src]!</span>")
	return TRUE

/obj/item/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.unEquip(A))
				return
			to_chat(user, "<span class='notice'>You load [A] into [src]!</span>")
			syringes.Add(A)
			A.loc = src
			process_chamber() // Chamber the syringe if none is already
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	else
		return ..()
/obj/item/gun/syringe/rapidsyringe_old
	name = "rapid syringe gun"
	desc = "A modification of the syringe gun design, using a rotating cylinder to store up to six syringes."
	icon_state = "rapidsyringegun"
	max_syringes = 6

/obj/item/gun/syringe/syndicate
	name = "dart pistol"
	desc = "A small spring-loaded sidearm that functions identically to a syringe gun."
	icon_state = "syringe_pistol"
	item_state = "gun" //Smaller inhand
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=2;syndicate=2;biotech=3"
	force = 2 //Also very weak because it's smaller
	suppressed = 1 //Softer fire sound
	can_unsuppress = 0 //Permanently silenced

// Not quite a syringe gun, but also not completely unlike one either.
// Uses an internal reservoir instead of separately filled syringes, and can unload them
// at a breakneck pace.
/obj/item/gun/syringe/rapidsyringe
	name = "rapid syringe gun"
	desc = "A syndicate rapid syringe gun based on an archived NanoTrasen prototype. Capable of storing and filling syringes from an internal reservoir. It has a large flap on the side that you can dump a box or bag of syringes into, and a port for filling it with liquid."
	icon_state = "rapidsyringegun"
	max_syringes = 14  // full two boxes worth
	/// Maximum size of the internal reservoir
	var/reservoir_volume = 300
	/// Possible amounts to fill each syringe with, toggleable by alt-clicking.
	var/list/possible_transfer_amounts = list(5, 10, 15)
	/// Index of possible_transfer_amounts that's currently active.
	var/transfer_amount_selection = 1
	/// Amount of reagents to transfer out at once if no syringe is loaded.
	var/reservoir_transfer_amount = 15
	/// Whether or not we've alerted the user that the reservoir is empty.
	var/alarmed = TRUE  // start out alarmed so a click just after buying doesn't give it away
	container_type = AMOUNT_VISIBLE | TRANSPARENT  // We'll handle transfers ourselves

/obj/item/gun/syringe/rapidsyringe/Initialize(mapload)
	. = ..()
	create_reagents(reservoir_volume)

/obj/item/gun/syringe/rapidsyringe/Destroy()
	QDEL_LIST(syringes)

	if(chambered)
		if(chambered.BB)
			QDEL_NULL(chambered.BB)
		qdel(chambered)

	return ..()

/obj/item/gun/syringe/rapidsyringe/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if("reservoir_volume")
			reagents.maximum_volume = var_value

/obj/item/gun/syringe/rapidsyringe/build_reagent_description(mob/user)
	. = list("<span class='notice'>There's a little window for the internal reservoir.</span>")
	. += ..()

/obj/item/gun/syringe/rapidsyringe/proc/get_units_per_shot()
	return possible_transfer_amounts[transfer_amount_selection]

/obj/item/gun/syringe/rapidsyringe/examine(mob/user)
	. = ..()
	. += "A switch on the side is set to [get_units_per_shot()] unit\s per shot, <span class='notice'>alt-click to change it.</span>"
	if(chambered?.BB)
		. += "<span class='notice'>The chambered syringe contains [round(chambered.BB.reagents.total_volume)] units."

/// If user is null in this proc, messages will just be ignored
/obj/item/gun/syringe/rapidsyringe/proc/insert_single_syringe(obj/item/reagent_containers/syringe/new_syringe, mob/user)
	if(new_syringe.reagents.total_volume)
		if(user)
			to_chat(user, "<span class='warning'>[src] only accepts empty syringes.</span>")
		return FALSE
	var/in_clip = length(syringes) + (chambered?.BB ? 1 : 0)
	if(in_clip >= max_syringes)
		if(user)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
		return FALSE

	if(user)
		if(!user.unEquip(new_syringe))
			return
		to_chat(user, "<span class='notice'>You load \the [new_syringe] into [src].</span>")
		playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
	syringes.Add(new_syringe)
	new_syringe.forceMove(src)

	process_chamber() // Chamber the syringe if none is already
	return TRUE

/obj/item/gun/syringe/rapidsyringe/attackby(obj/item/A, mob/user, params, show_msg)

	if(istype(A, /obj/item/storage))
		// Boxes can be dumped in.
		var/obj/item/storage/container = A
		if(!length(container.contents))
			to_chat(user, "<span class='warning'>[A] is empty!</span>")
			return TRUE
		if(length(syringes) + (chambered?.BB ? 1 : 0) == max_syringes)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return TRUE

		var/total_inserted = 0
		var/found_any_syringe = FALSE
		for(var/obj/item/reagent_containers/syringe/S in container)
			found_any_syringe = TRUE
			if((length(syringes) + (chambered?.BB ? 1 : 0)) == max_syringes)
				// full
				break

			// only allow empty syringes.
			// no user call here since it'd otherwise be spamming the user with chat messages.
			if(insert_single_syringe(S))
				total_inserted++

		if(total_inserted)
			playsound(src, 'sound/weapons/gun_interactions/bulletinsert.ogg', 50, 1)
			to_chat(user, "<span class='notice'>You load [total_inserted] empty syringes into [src].")
			// Chamber a syringe.
			process_chamber()

		else if(!found_any_syringe)
			to_chat(user, "<span class='warning'>There are no empty syringes in [A]!</span>")
			return TRUE

	else if(istype(A, /obj/item/reagent_containers/syringe))
		insert_single_syringe(A, user)
		return TRUE

	else if(istype(A, /obj/item/reagent_containers))
		// Loading with chemicals (but not from syringes)
		var/obj/item/reagent_containers/incoming = A
		if(!incoming.is_drainable())
			return

		if(!incoming.reagents.total_volume)
			to_chat(user, "<span class='warning'>[incoming] is empty!</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src]'s internal reservoir is full!</span>")
			return

		var/trans = incoming.reagents.trans_to(src, incoming.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [round(trans)] unit\s of the solution to [src]'s internal reservoir.</span>")
		update_loaded_syringe()

		// Reset the reservoir alarm
		alarmed = FALSE

	else
		return ..()

// Allow for emptying your deathmix, or for sec to find out what you were dumping into people
/obj/item/gun/syringe/rapidsyringe/afterattack(atom/target, mob/living/user, flag, params)
	if(istype(target, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/destination = target

		if(!destination.is_refillable())
			return

		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src]'s internal reservoir is empty!</span>")
			return

		if(destination.reagents.holder_full())
			to_chat(user, "<span class='warning'>[destination] is full.</span>")
			return

		var/transfer_source = "[src]'s internal reservoir"
		var/transfer_amount

		// Empty directly from the syringe, if it's loaded.
		// Otherwise, we wouldn't be able to fully empty the gun's chems without firing it.
		if(chambered?.BB && chambered.BB.reagents.total_volume)
			transfer_amount = chambered.BB.reagents.trans_to(destination, get_units_per_shot())
			transfer_source = "the syringe chambered in [src]"
		else
			transfer_amount = reagents.trans_to(destination, reservoir_transfer_amount)

		to_chat(user, "<span class='notice'>You drain [transfer_amount] unit\s from [transfer_source] into [destination].</span>")
		// Refill the syringe
		update_loaded_syringe()
		return TRUE
	else if(!reagents.total_volume && (!chambered?.BB || !chambered.BB.reagents.total_volume))
		// Play an alert when the reservoir has run out of reagents so people don't unknowingly dump empty syringes into their foes
		// Running out of syringes is just handled by *click*
		to_chat(user, "<span class='[alarmed ? "danger" : "userdanger"]'>[src] [alarmed ? "beeps" : "whines"]: Internal chemical reservoir empty!</span>")
		if(!alarmed)
			playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 25, 1, frequency = 60000)
			alarmed = TRUE
		// always send the to_chat so there's still feedback if the gun tries to fire

		return TRUE
	else
		return ..()

// Switch the amount of reagents used per shot.
/obj/item/gun/syringe/rapidsyringe/AltClick(mob/living/user)

	transfer_amount_selection++
	if(transfer_amount_selection > length(possible_transfer_amounts))
		transfer_amount_selection = 1

	playsound(src, 'sound/weapons/gun_interactions/selector.ogg', 25, 1)
	to_chat(user, "<span class='notice'>[src] will now fill each syringe with up to [get_units_per_shot()] units.</span>")
	update_loaded_syringe()

/// Update the chambered syringe's contents based on the reservoir contents.
/// Makes sure that what's contained in the syringe is representative of the mix as a whole.
/obj/item/gun/syringe/rapidsyringe/proc/update_loaded_syringe()
	if(!chambered?.BB)
		return

	// Refresh the mix in the syringe by pushing it into our internal beaker, and then pulling it out.
	// The only time we /won't/ is when we dump out to a beaker.
	if(chambered.BB.reagents.total_volume)
		chambered.BB.reagents.trans_to(src, chambered.BB.reagents.total_volume)

	reagents.trans_to(chambered.BB, get_units_per_shot())

/obj/item/gun/syringe/rapidsyringe/process_chamber()

	if(!length(syringes) || chambered?.BB)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]
	if(!S)
		return

	chambered.BB = new S.projectile_type(src)
	update_loaded_syringe()
	chambered.BB.name = S.name

	syringes.Remove(S)
	qdel(S)

// Unload an empty syringe, making sure its existing contents get returned to the reservoir
/obj/item/gun/syringe/rapidsyringe/attack_self(mob/living/user)
	if(!length(syringes) && !chambered.BB)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return FALSE

	var/obj/item/reagent_containers/syringe/S
	if(chambered.BB) // Remove the chambered syringe first
		S = new()
		// Dump it into the main reservoir beforehand
		chambered.BB.reagents.trans_to(src, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
	else
		S = syringes[length(syringes)]

	user.put_in_hands(S)
	syringes.Remove(S)
	process_chamber()
	playsound(src, "sound/weapons/gun_interactions/remove_bullet.ogg", 25, 1)
	to_chat(user, "<span class='notice'>You unload [S] from [src].</span>")
	return TRUE

/obj/item/gun/syringe/rapidsyringe/suicide_act(mob/user)

	if(!chambered?.BB)
		visible_message("<span class='danger'>[user] puts [user.p_their()] mouth to [src]'s reagent port and swings [user.p_their()] head back, it looks like [user.p_theyre()] trying to commit suicide!</span>")
		if(!reagents.total_volume)
			visible_message("<span class='danger'>...but there was nothing inside!</span>")
			return SHAME
		else
			reagents.trans_to(user, reagents.total_volume)
	else
		visible_message("<span class='danger'>[user] raises [src] to [user.p_their()] shoulder, it looks like [user.p_theyre()] trying to lose their medical license!</span>")
		handle_suicide(user, user)
	return TOXLOSS

/// Version that comes pre-loaded with a given amount of syringes.
/obj/item/gun/syringe/rapidsyringe/preloaded
	/// The number of syringes to reload. If not set, defaults to max_syringes.
	var/number_to_preload

/obj/item/gun/syringe/rapidsyringe/preloaded/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/syringe/new_syringe
	for(var/i in 0 to (number_to_preload == null ? max_syringes : number_to_preload))
		new_syringe = new()
		insert_single_syringe(new_syringe)

/// Version that comes loaded with half of the standard amount of syringes. Used in the uplink.
/obj/item/gun/syringe/rapidsyringe/preloaded/half

/obj/item/gun/syringe/rapidsyringe/preloaded/half/Initialize(mapload)
	number_to_preload = max_syringes / 2
	. = ..()

/// For shenanigans. This is essentially an RSG that never needs to be refilled with syringes.
/obj/item/gun/syringe/rapidsyringe/preloaded/beaker_blaster
	name = "beaker buster"
	desc = "A syringe gun presumably cobbled together with the power of bluespace and powerful stimulants. Can shoot large amounts of reagents with an endless supply of syringes."
	possible_transfer_amounts = list(1, 5, 10, 15, 20, 25, 30, 50)
	reservoir_volume = 10000  // stupid big
	max_syringes = 3  // doesn't really matter since they regen

/obj/item/gun/syringe/rapidsyringe/preloaded/beaker_blaster/process_chamber()
	. = ..()
	// add a new syringe so it's technically infinite
	insert_single_syringe(new /obj/item/reagent_containers/syringe)

/obj/item/gun/syringe/rapidsyringe/preloaded/beaker_blaster/attack_self(mob/living/user)
	// no printing infinite syringes.
	return
