
//objects in /obj/effect should never be things that are attackable, use obj/structure instead.
//Effects are mostly temporary visual effects like sparks, smoke, as well as decals, etc...

/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	move_resist = INFINITY
	anchored = TRUE
	can_be_hit = FALSE
	new_attack_chain = TRUE

/obj/effect/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	return

/obj/effect/singularity_act()
	qdel(src)
	return FALSE

/obj/effect/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	return

/obj/effect/acid_act()
	return

/obj/effect/proc/is_cleanable() //Called when you want to clean something, and usualy delete it after
	return FALSE

/obj/effect/mech_melee_attack(obj/mecha/M)
	return 0

/obj/effect/blob_act(obj/structure/blob/B)
	return

/obj/effect/experience_pressure_difference(flow_x, flow_y)
	return // Immune to gas flow.

/obj/effect/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(60))
				qdel(src)
		if(3)
			if(prob(25))
				qdel(src)

/**
 * # The abstract object
 *
 * This is an object that is intended to able to be placed, but that is completely invisible.
 * The object should be immune to all forms of damage, or things that can delete it, such as the singularity, or explosions.
 */
/obj/effect/abstract
	name = "Abstract object"
	invisibility = INVISIBILITY_ABSTRACT
	layer = TURF_LAYER
	icon = null
	icon_state = null
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, RAD = 100, FIRE = 100, ACID = 100)

// Most of these overrides procs below are overkill, but better safe than sorry.
/obj/effect/abstract/bullet_act(obj/item/projectile/P)
	return

/obj/effect/abstract/decompile_act(obj/item/matter_decompiler/C, mob/user)
	return

/obj/effect/abstract/singularity_act()
	return

/obj/effect/abstract/narsie_act()
	return

/obj/effect/abstract/ex_act(severity)
	return

/obj/effect/abstract/blob_act()
	return

/obj/effect/abstract/acid_act()
	return

/obj/effect/abstract/fire_act()
	return

/obj/effect/decal
	plane = FLOOR_PLANE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/no_scoop = FALSE   //if it has this, don't let it be scooped up
	var/no_clear = FALSE    //if it has this, don't delete it when its' scooped up
	var/list/scoop_reagents = null

/obj/effect/decal/Initialize(mapload)
	. = ..()
	if(scoop_reagents)
		create_reagents(100)
		reagents.add_reagent_list(scoop_reagents)

/obj/effect/decal/build_base_description(infix, suffix) // overriding this is a sin but it fixes a worse sin
	. = list("[bicon(src)] That's \a [src][infix]. [suffix]")
	if(desc)
		. += desc

/obj/effect/decal/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/reagent_containers/glass) || istype(used, /obj/item/reagent_containers/drinks))
		scoop(used, user)
	else if(issimulatedturf(loc))
		used.melee_attack_chain(user, loc)
	return ITEM_INTERACT_COMPLETE

/obj/effect/decal/attack_animal(mob/living/simple_animal/M)
	if(issimulatedturf(loc))
		loc.attack_animal(M)

/obj/effect/decal/attack_hand(mob/living/user)
	if(issimulatedturf(loc))
		loc.attack_hand(user)

/obj/effect/decal/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(issimulatedturf(loc))
		loc.attack_hulk(user, does_attack_animation)

/obj/effect/decal/proc/scoop(obj/item/I, mob/user)
	if(reagents && I.reagents && !no_scoop)
		if(!reagents.total_volume)
			to_chat(user, "<span class='notice'>There isn't enough [src] to scoop up!</span>")
			return
		if(I.reagents.total_volume >= I.reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[I] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You scoop [src] into [I]!</span>")
		on_scoop()
		reagents.trans_to(I, reagents.total_volume)
		if(!reagents.total_volume && !no_clear) //scooped up all of it
			qdel(src)

/obj/effect/decal/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	qdel(src)

/obj/effect/decal/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)
	if(!(resistance_flags & FIRE_PROOF)) //non fire proof decal or being burned by lava
		qdel(src)

/obj/effect/decal/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		qdel(src)

/obj/effect/decal/proc/on_scoop()
	return

/// These effects can be added to anything to hold particles, which is useful because Byond only allows a single particle per atom
/obj/effect/abstract/particle_holder
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	invisibility = FALSE
	///typepath of the last location we're in, if it's different when moved then we need to update vis contents
	var/last_attached_location_type
	/// The main item we're attached to at the moment, particle holders hold particles for something
	var/atom/movable/parent
	/// The mob that is holding our item
	var/mob/holding_parent

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = null)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	parent = loc

	if(ismovable(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_qdel))

	particles = new particle_path
	update_visual_contents(parent)

/obj/effect/abstract/particle_holder/Destroy(force)
	if(parent)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	QDEL_NULL(particles)
	holding_parent = null
	parent.vis_contents -= src
	return ..()

///signal called when parent is moved
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(parent.loc.type != last_attached_location_type)
		update_visual_contents(attached)

///signal called when parent is deleted
/obj/effect/abstract/particle_holder/proc/on_qdel(atom/movable/attached, force)
	SIGNAL_HANDLER
	attached.vis_contents -= src
	qdel(src)//our parent is gone and we need to be as well

///logic proc for particle holders, aka where they move.
///subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
///this base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles
/obj/effect/abstract/particle_holder/proc/update_visual_contents(atom/movable/attached_to)
	// Remove old
	if(holding_parent && !(QDELETED(holding_parent)))
		holding_parent.vis_contents -= src

	// Add new
	if(isitem(attached_to) && ismob(attached_to.loc)) //special case we want to also be emitting from the mob
		holding_parent = attached_to.loc
		last_attached_location_type = attached_to.loc
		holding_parent.vis_contents += src

	// Readd to ourselves
	attached_to.vis_contents |= src
