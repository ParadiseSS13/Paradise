/**
 * This element is used to indicate that a movable atom can be mounted by mobs in order to ride it. The movable is considered mounted when a mob is buckled to it,
 * at which point a [riding component][/datum/component/riding] is created on the movable, and that component handles the actual riding behavior.
 *
 * Besides the target, the ridable element has one argument: the component subtype. This is not really ideal since there's ~20-30 component subtypes rather than
 * having the behavior defined on the ridable atoms themselves or some such, but because the old riding behavior was so horrifyingly spread out and redundant,
 * just having the variables, behavior, and procs be standardized is still a big improvement.
 */
/datum/element/ridable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The specific riding component subtype we're loading our instructions from, don't leave this as default please!
	var/riding_component_type = /datum/component/riding
	/// If we have a xenobio red potion applied to us, we get split off so we can pass our special status onto new riding components
	var/potion_boosted = FALSE

/datum/element/ridable/Attach(atom/movable/target, component_type = /datum/component/riding, potion_boost = FALSE)
	. = ..()
	if(!ismovable(target))
		return COMPONENT_INCOMPATIBLE

	if(component_type == /datum/component/riding)
		stack_trace("Tried attaching a ridable element to [target] with basic/abstract /datum/component/riding component type. Please designate a specific riding component subtype when adding the ridable element.")
		return COMPONENT_INCOMPATIBLE

	target.can_buckle = TRUE
	riding_component_type = component_type
	potion_boosted = potion_boost

	RegisterSignal(target, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(check_mounting))
	if(istgvehicle(target))
		RegisterSignal(target, COMSIG_SPEED_POTION_APPLIED, PROC_REF(check_potion))
	if(ismob(target))
		RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/datum/element/ridable/Detach(atom/movable/target)
	target.can_buckle = initial(target.can_buckle)
	UnregisterSignal(target, list(COMSIG_MOVABLE_PREBUCKLE, COMSIG_SPEED_POTION_APPLIED, COMSIG_MOB_STATCHANGE))
	return ..()

/// Someone is buckling to this movable, which is literally the only thing we care about (other than speed potions)
/datum/element/ridable/proc/check_mounting(atom/movable/target_movable, mob/living/potential_rider, force = FALSE)
	SIGNAL_HANDLER //COMSIG_MOVABLE_PREBUCKLE
	var/datum/component/riding/R = riding_component_type
	return check_mounting_part_two(target_movable, potential_rider, force, R.ride_check_flags)

/datum/element/ridable/proc/check_mounting_part_two(atom/movable/target_movable, mob/living/potential_rider, force = FALSE, ride_check_flags = NONE)
	var/arms_needed = 0
	if(ride_check_flags & RIDER_NEEDS_ARMS)
		arms_needed = 2
	else if(ride_check_flags & RIDER_NEEDS_ARM)
		arms_needed = 1
		ride_check_flags &= ~RIDER_NEEDS_ARM
		ride_check_flags |= RIDER_NEEDS_ARMS

	if(arms_needed && !equip_buckle_inhands(potential_rider, arms_needed, target_movable))
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get a grip on [target_movable] because [potential_rider.p_their()] hands are full!</span>", "<span class='warning'>You can't get a grip on [target_movable] because your hands are full!</span>")
		return COMPONENT_BLOCK_BUCKLE

	if((ride_check_flags & RIDER_NEEDS_LEGS) && HAS_TRAIT(potential_rider, TRAIT_FLOORED))
		potential_rider.visible_message("<span class='warning'>[potential_rider] can't get [potential_rider.p_their()] footing on [target_movable]!</span>",
			"<span class='warning'>You can't get your footing on [target_movable]!</span>")
		return COMPONENT_BLOCK_BUCKLE
	if((ride_check_flags & RIDER_CARBON_OR_SILICON_NO_LARGE_MOBS) && !(iscarbon(potential_rider) || issilicon(potential_rider) || potential_rider.mob_size <= MOB_SIZE_SMALL))
		potential_rider.visible_message("<span class='warning'>[potential_rider] is too big to get [potential_rider.p_their()] footing on [target_movable]!</span>",
			"<span class='warning'>You are too big to get your footing on [target_movable]!</span>")
		return COMPONENT_BLOCK_BUCKLE

	var/mob/living/target_living = target_movable

	target_living.AddComponent(riding_component_type, potential_rider, force, ride_check_flags, potion_boost = potion_boosted)

/// Try putting the appropriate number of [riding offhand items][/obj/item/riding_offhand] into the target's hands, return FALSE if we can't
/datum/element/ridable/proc/equip_buckle_inhands(mob/living/carbon/human/user, amount_required = 1, atom/movable/target_movable, riding_target_override = null)
	var/atom/movable/AM = target_movable
	var/amount_equipped = 0
	for(var/amount_needed = amount_required, amount_needed > 0, amount_needed--)
		var/obj/item/riding_offhand/inhand = new /obj/item/riding_offhand(user)
		if(!riding_target_override)
			inhand.rider = user
		else
			inhand.rider = riding_target_override
		inhand.parent = AM
		var/list/held_items = list()
		held_items += user.l_hand
		held_items += user.r_hand
		for(var/obj/item/I in held_items) // delete any hand items like slappers that could still totally be used to grab on
			if(I.flags & DROPDEL & ABSTRACT)
				qdel(I)

		// this would be put_in_hands() if it didn't have the chance to sleep, since this proc gets called from a signal handler that relies on what this returns
		var/inserted_successfully = FALSE
		if(user.put_in_inactive_hand(inhand))
			inserted_successfully = TRUE
		else
			if(user.put_in_active_hand(inhand))
				inserted_successfully = TRUE

		if(inserted_successfully)
			amount_equipped++
		else
			qdel(inhand)
			return FALSE

	if(amount_equipped >= amount_required)
		return TRUE
	else
		unequip_buckle_inhands(user, target_movable)
		return FALSE

/// Checks to see if we've been hit with a red xenobio potion to make us faster. This is only registered if we're a vehicle
/datum/element/ridable/proc/check_potion(atom/movable/ridable_atom, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(potion_boosted)
		to_chat(user, "<span class='warning'>[ridable_atom] has already been coated with red, that's as fast as it'll go!</span>")
		return
	if(ridable_atom.has_buckled_mobs()) // effect won't take place til the next time someone mounts it, so just prevent that situation
		to_chat(user, "<span class='warning'>It's too dangerous to smear [speed_potion] on [ridable_atom] while it's being ridden!</span>")
		return
	var/speed_limit = round(GLOB.configuration.movement.human_delay * 0.85, 0.01)
	var/datum/component/riding/theoretical_riding_component = riding_component_type
	var/theoretical_speed = initial(theoretical_riding_component.vehicle_move_delay)
	if(theoretical_speed <= speed_limit) // i say speed but this is actually move delay, so you have to be ABOVE the speed limit to pass
		to_chat(user, "<span class='warning'>[ridable_atom] can't be made any faster!</span>")
		return
	Detach(ridable_atom)
	ridable_atom.AddElement(/datum/element/ridable, component_type = riding_component_type, potion_boost = TRUE)
	to_chat(user, "<span class='notice'>You slather the red gunk over [ridable_atom], making it faster.</span>")
	ridable_atom.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
	ridable_atom.add_atom_colour("#6e6e86", FIXED_COLOUR_PRIORITY)
	ADD_TRAIT(ridable_atom, TRAIT_OIL_SLICKED, "potion")
	qdel(speed_potion)
	return SPEED_POTION_STOP

/// Remove all of the relevant [riding offhand items][/obj/item/riding_offhand] from the target
/datum/element/ridable/proc/unequip_buckle_inhands(mob/living/carbon/user, atom/movable/target_movable)
	var/atom/movable/AM = target_movable
	for(var/obj/item/riding_offhand/O in user.contents)
		if(O.parent != AM)
			CRASH("RIDING OFFHAND ON WRONG MOB")
		if(O.selfdeleting)
			continue
		else
			qdel(O)
	return TRUE

/datum/element/ridable/proc/on_stat_change(mob/source)
	SIGNAL_HANDLER

	// If we're dead, don't let anyone buckle onto us
	if(source.stat == DEAD)
		source.can_buckle = FALSE
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom/movable, unbuckle_all_mobs), source)

	// If we're alive, back to being buckle-able
	else
		source.can_buckle = TRUE

/obj/item/riding_offhand
	name = "offhand"
	icon_state = "offhand"
	w_class = WEIGHT_CLASS_HUGE
	flags = ABSTRACT | DROPDEL | NOBLUDGEON
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/rider
	var/mob/living/parent
	var/selfdeleting = FALSE

/obj/item/riding_offhand/dropped()
	selfdeleting = TRUE
	return ..()

/obj/item/riding_offhand/equipped()
	if(loc != rider && loc != parent)
		selfdeleting = TRUE
		qdel(src)
	return ..()

/obj/item/riding_offhand/Destroy()
	var/atom/movable/AM = parent
	if(selfdeleting)
		if(rider in AM.buckled_mobs)
			AM.unbuckle_mob(rider)
	return ..()

