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

/obj/item/gun/syringe/New()
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
	if(chambered.BB) // Remove the chambered syringe first
		S = new()
		chambered.BB.reagents.trans_to(S, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
	else
		S = syringes[length(syringes)]

	user.put_in_hands(S)
	syringes.Remove(S)
	process_chamber()
	to_chat(user, "<span class='notice'>You unload [S] from \the [src]!</span>")
	return TRUE

/obj/item/gun/syringe/attackby(obj/item/A, mob/user, params, show_msg = TRUE)
	if(istype(A, /obj/item/reagent_containers/syringe))
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.unEquip(A))
				return
			to_chat(user, "<span class='notice'>You load [A] into \the [src]!</span>")
			syringes.Add(A)
			A.loc = src
			process_chamber() // Chamber the syringe if none is already
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] cannot hold more syringes.</span>")
	else
		return ..()

/obj/item/gun/syringe/rapidsyringe
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
// these names are subject to change, I just want to leave stuff in place for now.
/obj/item/gun/syringe/rapidsyringe/newrapid
	name = "rapid syringe gun mk. II"  // placeholder
	desc = "A syndicate modification of an advanced syringe gun design. Has an internal mechanism capable of storing and filling syringes from an internal reservoir.\nIt has a large flap on the side that you can dump a box or bag of syringes into, and a port for filling it with liquid."
	icon_state = "rapidsyringegun"
	max_syringes = 12  // I think that's a full two boxes worth?
	/// Internal reagent container.
	var/obj/item/reagent_containers/glass/beaker/bluespace/internal_beaker
	/// Index of possible transfer amounts to select
	var/reagents_per_syringe_selection
	var/list/possible_transfer_amounts = list(5, 10, 15)

/obj/item/gun/syringe/rapidsyringe/newrapid/Initialize(mapload)
	. = ..()
	internal_beaker = new(src)
	reagents_per_syringe_selection = 1

/obj/item/gun/syringe/rapidsyringe/newrapid/Destroy()
	. = ..()
	qdel(internal_beaker)

/obj/item/gun/syringe/rapidsyringe/newrapid/proc/get_units_per_shot()
	return possible_transfer_amounts[reagents_per_syringe_selection]

/obj/item/gun/syringe/rapidsyringe/newrapid/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to unload an empty syringe.</span>"
	. += "A switch on the side is set to '[get_units_per_shot()] unit\s per shot'."
	. += "Its internal reservoir contains [internal_beaker.reagents.total_volume]/[internal_beaker.reagents.maximum_volume] units."
	if(chambered.BB)
		. += "<span class='notice'>You can see the chambered syringe contains [chambered.BB.reagents.total_volume] units."

/obj/item/gun/syringe/rapidsyringe/newrapid/attackby(obj/item/A, mob/user, params, show_msg)

	if(istype(A, /obj/item/storage))
		// Boxes can be dumped in.
		var/obj/item/storage/container = A
		if(!length(container.contents))
			to_chat(user, "<span class='warning'>[A] is empty!.</span>")
			return TRUE
		if(length(syringes) + (chambered.BB ? 1 : 0) == max_syringes)
			to_chat(user, "<span class='warning'>[src] is full!</span>")
			return TRUE

		var/total_inserted = 0
		for(var/obj/item/reagent_containers/syringe/S in container)
			if((length(syringes) + (chambered.BB ? 1 : 0)) == max_syringes)
				break

			if(!S.reagents.total_volume)
				syringes += S
				S.loc = src
				total_inserted++

		if(total_inserted)
			to_chat(user, "<span class='notice'>You load [total_inserted] empty syringes into [src].")
			// Chamber a syringe.
			process_chamber()
			update_loaded_syringe()


	else if(istype(A, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = A
		if(S.reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] only accepts empty syringes.")
			return TRUE
		var/in_clip = length(syringes) + (chambered.BB ? 1 : 0)
		if(in_clip < max_syringes)
			if(!user.unEquip(A))
				return
			to_chat(user, "<span class='notice'>You load [A] into [src]!</span>")
			syringes.Add(A)
			A.loc = src
			process_chamber() // Chamber the syringe if none is already
			update_loaded_syringe()
			return TRUE
		else
			to_chat(user, "<span class='notice'>[src] is full!.</span>")


			// use existing syringe loading logic


	else if(istype(A, /obj/item/reagent_containers))
		var/obj/item/reagent_containers/incoming = A
		if(!incoming.reagents.total_volume)
			to_chat(user, "<span class='warning'>[incoming] is empty!</span>")
			return

		if(internal_beaker.reagents.holder_full())
			to_chat(user, "<span class='warning'>[src]'s internal reservoir is full.</span>")
			return

		var/trans = incoming.reagents.trans_to(internal_beaker, incoming.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] unit\s of the solution to [src]'s internal reservoir.</span>")
		update_loaded_syringe()

	else
		return ..()

	// Should we be able to empty this? Maybe attacking a beaker of some sort?
	// Also, should science goggles be able to see the contents?

// Allow for emptying your deathmix.
/obj/item/gun/syringe/rapidsyringe/newrapid/afterattack(atom/target, mob/living/user, flag, params)
	if(istype(target, /obj/item/reagent_containers) && !istype(target, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/destination = target
		if(!internal_beaker.reagents.total_volume)
			to_chat(user, "<span class='warning'>[src]'s internal reservoir is empty!</span>")
			return

		if(destination.reagents.holder_full())
			to_chat(user, "<span class='warning'>[destination] is full.</span>")
			return

		var/trans = internal_beaker.reagents.trans_to(destination, internal_beaker.amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You drain [trans] unit\s from [src]'s internal reservoir into [destination].</span>")
		update_loaded_syringe()
		return TRUE
	else
		. = ..()

/obj/item/gun/syringe/rapidsyringe/newrapid/AltClick(mob/living/user)
	// Switch the amount of reagents used per shot.
	reagents_per_syringe_selection = reagents_per_syringe_selection + 1
	if(reagents_per_syringe_selection > length(possible_transfer_amounts))
		reagents_per_syringe_selection = 1

	to_chat(user, "<span class='notice'>[src] will now fill each syringe with up to [get_units_per_shot()] units.</span>")
	update_loaded_syringe()


/// Update the chambered syringe's contents based on the reservoir contents.
/obj/item/gun/syringe/rapidsyringe/newrapid/proc/update_loaded_syringe()
	if(!chambered.BB)
		return

	// transfer it out of the syringe and then back in so we always have a consistent mix.
	// The only time we /won't/ is when we dump out to a beaker.
	if(chambered.BB.reagents.total_volume)
		chambered.BB.reagents.trans_to(internal_beaker, chambered.BB.reagents.total_volume)

	internal_beaker.reagents.trans_to(chambered.BB, get_units_per_shot())

/obj/item/gun/syringe/rapidsyringe/newrapid/process_chamber()
	// Note: This gets called both when we add more reagents and after firing

	if(!length(syringes) || chambered.BB)
		return

	var/obj/item/reagent_containers/syringe/S = syringes[1]
	if(!S)
		return

	chambered.BB = new S.projectile_type(src)
	update_loaded_syringe()
	chambered.BB.name = S.name

	syringes.Remove(S)
	qdel(S)

// TODO update attack_self
/obj/item/gun/syringe/rapidsyringe/newrapid/attack_self(mob/living/user)
	if(!length(syringes) && !chambered.BB)
		to_chat(user, "<span class='notice'>[src] is empty.</span>")
		return FALSE

	var/obj/item/reagent_containers/syringe/S
	if(chambered.BB) // Remove the chambered syringe first
		S = new()
		// Dump it into the main reservoir beforehand
		chambered.BB.reagents.trans_to(internal_beaker, chambered.BB.reagents.total_volume)
		qdel(chambered.BB)
		chambered.BB = null
	else
		S = syringes[length(syringes)]

	user.put_in_hands(S)
	syringes.Remove(S)
	process_chamber()
	playsound(src, "sound/weapons/gun_interactions/remove_bullet.ogg", 25, 1)
	to_chat(user, "<span class='notice'>You unload [S] from [src]!</span>")
	return TRUE

/obj/item/gun/syringe/rapidsyringe/newrapid/suicide_act(mob/user)

	if(!chambered.BB)
		visible_message(user, "<span class='danger'>[usr] puts [user.p_their()] mouth to the reagent port and swings [user.p_their()] head back, it looks like [user.p_theyre()] trying to commit suicide!</span>")
		if(!internal_beaker.reagents.total_volume)
			to_chat(user, "<span class='userdanger'>...but the reservoir is empty!</span>")
			return SHAME
	else
		visible_message(user, "<span class='danger'>[user] raises [src] to [user.p_their()] shoulder, it looks like [user.p_theyre()] trying to innoculate [user.p_them]self!</span>")
	handle_suicide(user)
	return TOXLOSS

