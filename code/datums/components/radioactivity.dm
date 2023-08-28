/**
 * Radioactivity Component
 *
 * When applied to an atom it will make it radioactive
 *
 */
/datum/component/radioactivity
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on an item
	/// How much rads our parent emits per interaction
	var/rad_per_interaction = 0
	/// Chance for radiation to fire on interaction, if zero it doesn't count
	var/rad_interaction_chance = 0
	/// Cooldown between rads emissions
	var/rad_interaction_cooldown = 1 SECONDS
	/// Radius for radiation effect on interaction
	var/rad_interaction_radius = 0
	/// How much rads our parent emits per cycle
	var/rad_per_cycle = 0
	/// Chance for radiation to fire per cycle, if zero it doesn't count
	var/rad_cycle_chance = 0
	/// How ofter radiation fired if rad_per_cycle is anything but zero
	var/rad_cycle = 2 SECONDS
	/// Radius for radiation effect per cycle
	var/rad_cycle_radius = 0
	/// Wheter radiation should ignore armor protection
	var/negate_armor = FALSE
	/// Optional callback to be called when someone interact with our atom
	var/datum/callback/interact_callback
	/// Optional callback to be called per cycle
	var/datum/callback/cycle_callback
	/// Timestamp for interaction cooldown
	var/last_interact_time = 0
	/// Timer ID
	var/cycle_timer = null


/**
 * Radioactivity Component
 *
 * Arguments:
 * * rad_per_interaction How much rads our parent emits per interaction
 * * rad_interaction_chance (otional) Chance for emission to occur on interaction (1-100), doesn't count if 0
 * * rad_interaction_cooldown (otional) Cooldown between rads emission on interaction
 * * rad_interaction_radius (optional) Radius for radiation effect on interaction, 0 = atom's turf
 * * rad_per_cycle (optional) How much rads our parent emits per time cycle
 * * rad_cycle (optional) How ofter radiation fired if rad_per_cycle is not a zero value
 * * rad_cycle_radius (optional) Radius for radiation effect on cycle, 0 = atom's turf
 * * negate_armor (optional) Wheter radiation should ignore armor protection
 * * interact_callback (optional) Additional callback on the parent to be called when someone interact with our atom
 * * cycle_callback (optional) Additional callback on the parent to be called per cycle
 */
/datum/component/radioactivity/Initialize(rad_per_interaction = 0, rad_interaction_chance = 0, rad_interaction_radius = 0, \
										rad_interaction_cooldown = 1 SECONDS, rad_per_cycle = 0, rad_cycle_chance = 0, rad_cycle = 2 SECONDS, \
										rad_cycle_radius = 0, negate_armor = FALSE, datum/callback/interact_callback, datum/callback/cycle_callback)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.rad_per_interaction = rad_per_interaction
	src.rad_interaction_chance = clamp(round(rad_interaction_chance), 0, 100)
	src.rad_interaction_cooldown = rad_interaction_cooldown
	src.rad_interaction_radius = rad_interaction_radius

	src.rad_per_cycle = rad_per_cycle
	src.rad_cycle_chance = clamp(round(rad_cycle_chance), 0, 100)
	src.rad_cycle = rad_cycle
	src.rad_cycle_radius = rad_cycle_radius
	src.negate_armor = negate_armor

	if(interact_callback)
		src.interact_callback = interact_callback
	if(cycle_callback)
		src.cycle_callback = cycle_callback

	if(src.rad_per_cycle)
		cycle_timer = addtimer(CALLBACK(parent, TYPE_PROC_REF(/atom, component_rad_process), rad_per_cycle, rad_cycle_chance, \
		rad_cycle_radius, negate_armor, src.cycle_callback), src.rad_cycle, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE)


// Inherit the new values passed to the component
/datum/component/radioactivity/InheritComponent(datum/component/radioactivity/new_comp, original, rad_per_interaction = 0, rad_interaction_chance = 0, \
											rad_interaction_cooldown = 0, rad_interaction_radius = 0, rad_per_cycle = 0, rad_cycle = 2 SECONDS, \
											rad_cycle_radius = 0, negate_armor = FALSE, datum/callback/interact_callback, datum/callback/cycle_callback)

	if(!original)
		return

	src.rad_per_interaction = rad_per_interaction
	src.rad_interaction_chance = clamp(round(rad_interaction_chance), 0, 100)
	src.rad_interaction_cooldown = rad_interaction_cooldown
	src.rad_interaction_radius = rad_interaction_radius

	src.rad_per_cycle = rad_per_cycle
	src.rad_cycle_chance = clamp(round(rad_cycle_chance), 0, 100)
	src.rad_cycle = rad_cycle
	src.rad_cycle_radius = rad_cycle_radius
	src.negate_armor = negate_armor

	if(interact_callback)
		src.interact_callback = interact_callback
	if(cycle_callback)
		src.cycle_callback = cycle_callback

	if(cycle_timer)
		deltimer(cycle_timer)
		if(src.rad_per_cycle)
			cycle_timer = addtimer(CALLBACK(parent, TYPE_PROC_REF(/atom, component_rad_process), rad_per_cycle, rad_cycle_chance, \
			rad_cycle_radius, negate_armor, src.cycle_callback), src.rad_cycle, TIMER_UNIQUE | TIMER_LOOP | TIMER_STOPPABLE)
		else
			cycle_timer = null


// Register signals withthe parent item
/datum/component/radioactivity/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_BUMPED, PROC_REF(on_bump))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attack_by))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack_mob))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(on_attack_obj))


// Remove all siginals registered to the parent item
/datum/component/radioactivity/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_BUMPED, COMSIG_ATOM_ENTERED, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND))

	if(isitem(parent))
		UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ))


// Triggered on atom bump
/datum/component/radioactivity/proc/on_bump(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	rad_interact(moving_atom)


// Triggered on parent being entered by other atom
/datum/component/radioactivity/proc/on_enter(datum/source, atom/movable/moving_atom)
	SIGNAL_HANDLER
	rad_interact(moving_atom)


// Triggered on atom being attacked
/datum/component/radioactivity/proc/on_attack_by(datum/source, obj/item/attacking_item, mob/user)
	SIGNAL_HANDLER
	rad_interact(user)


// Triggered on atom being attacked by hand
/datum/component/radioactivity/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	rad_interact(user)


// Triggered on attack mob with the parent item
/datum/component/radioactivity/proc/on_attack_mob(obj/item/source, mob/target, mob/user)
	SIGNAL_HANDLER
	rad_interact(user)


// Triggered on attack obj with the parent item
/datum/component/radioactivity/proc/on_attack_obj(obj/item/source, obj/target, mob/user)
	SIGNAL_HANDLER
	rad_interact(user)


// Generic interact proc
/datum/component/radioactivity/proc/rad_interact(datum/interacting_atom)
	if(QDELETED(parent))
		return

	if(HAS_TRAIT(parent, TRAIT_BLOCK_RADIATION))
		return

	if(!rad_per_interaction)
		return

	if(rad_interaction_chance && !prob(rad_interaction_chance))
		return

	if(world.time < last_interact_time + rad_interaction_cooldown)
		return
	last_interact_time = world.time

	INVOKE_ASYNC(parent, TYPE_PROC_REF(/atom, component_radiate), rad_per_interaction, rad_interaction_radius, 0, 0, negate_armor)
	interact_callback?.Invoke(parent, interacting_atom)


// Generic process proc
/atom/proc/component_rad_process(rad_per_cycle, rad_cycle_chance, rad_cycle_radius, negate_armor, datum/callback/cycle_callback)
	if(QDELETED(src))
		return

	if(HAS_TRAIT(src, TRAIT_BLOCK_RADIATION))
		return

	if(!rad_per_cycle)
		return

	if(rad_cycle_chance && !prob(rad_cycle_chance))
		return

	component_radiate(0, 0, rad_per_cycle, rad_cycle_radius, negate_armor)
	cycle_callback?.Invoke(src)


// Irradiation main proc
/atom/proc/component_radiate(rad_per_interaction, rad_interaction_radius, rad_per_cycle, rad_cycle_radius, negate_armor)
	if(QDELETED(src))
		return

	var/turf/parent_turf = get_turf(src)
	if(!parent_turf)
		return

	var/list/irradiated_mobs = list()
	var/rad_damage = rad_per_interaction
	var/rad_range = rad_interaction_radius

	if(rad_per_cycle)
		rad_damage = rad_per_cycle
		rad_range = rad_cycle_radius

	for(var/turf/target_turf in range(rad_range, parent_turf))
		irradiated_mobs |= target_turf.collect_all_atoms_of_type(/mob/living)

	if(!length(irradiated_mobs))
		return

	for(var/mob/living/target in irradiated_mobs)
		if(QDELETED(target))
			continue

		if(ishuman(target) && (RADIMMUNE in target.dna?.species?.species_traits))
			continue

		var/resist = target.getarmor(type = "rad")
		target.apply_effect(rad_damage, IRRADIATE, resist, negate_armor)

