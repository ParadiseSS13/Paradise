/datum/component/clumsy_climb
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS // Only one of the component can exist on table
	/// default for all human-sized livings
	var/thrown_chance = 80
	/// force damage modifier
	var/force_mod = 0.1
	// max current possible thrown objects
	var/max_thrown_objects = 15
	// max possible thrown objects when not forced
	var/max_thrown_objects_low = 5

/datum/component/clumsy_climb/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/clumsy_climb/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, PROC_REF(cross))
	RegisterSignal(parent, COMSIG_CLIMBED_ON, PROC_REF(cross))
	RegisterSignal(parent, COMSIG_DANCED_ON, PROC_REF(cross))

/datum/component/clumsy_climb/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_CLIMBED_ON, COMSIG_DANCED_ON))

/datum/component/clumsy_climb/proc/cross(atom/table, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_clumsy), table, user)

/datum/component/clumsy_climb/proc/try_clumsy(atom/table, mob/living/user)
	if(!table.contents)
		return

	if(!istype(user))
		return

	if(user.mob_size <= MOB_SIZE_SMALL && !user.throwing)
		return

	max_thrown_objects = initial(max_thrown_objects)
	if(!user.throwing)
		max_thrown_objects = max_thrown_objects_low

	throw_items(user)


/datum/component/clumsy_climb/proc/throw_items(mob/living/user)
	if(!user)
		return

	switch(user.mob_size)
		if(MOB_SIZE_LARGE)
			thrown_chance = 100
		if(MOB_SIZE_SMALL)
			thrown_chance = 20
		if(MOB_SIZE_TINY)
			thrown_chance = 10

	if(HAS_TRAIT(user, TRAIT_CLUMSY))
		thrown_chance += 20
	if(user.mind?.miming)
		thrown_chance -= 30

	thrown_chance = clamp(thrown_chance, 1, 100)

	var/list/items_to_throw = list()

	var/turf/user_turf = get_turf(user)
	for(var/obj/item/candidate_to_throw in user_turf)
		if(length(items_to_throw) >= max_thrown_objects)
			break

		if(candidate_to_throw.anchored || !prob(thrown_chance))
			continue

		items_to_throw += candidate_to_throw

	for(var/obj/item/item_to_throw as anything in items_to_throw)
		var/atom/thrown_target = get_edge_target_turf(user, get_dir(user_turf, get_step_away(item_to_throw, user_turf)))
		item_to_throw.throw_at(target = thrown_target, range = 1, speed = 1)
		item_to_throw.force *= force_mod
		item_to_throw.throwforce *= force_mod //no killing using shards :lul:
		item_to_throw.pixel_x = rand(-10, 10)
		item_to_throw.pixel_y = rand(-4, 16)
		item_to_throw.force /= force_mod
		item_to_throw.throwforce /= force_mod

	qdel(src)
