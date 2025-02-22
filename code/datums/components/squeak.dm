/datum/component/squeak
	var/static/list/default_squeak_sounds = list('sound/items/toysqueak1.ogg'=1, 'sound/items/toysqueak2.ogg'=1, 'sound/items/toysqueak3.ogg'=1)
	var/list/override_squeak_sounds
	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20

	///extra-range for this component's sound
	var/sound_extra_range = -1
	///when sounds start falling off for the squeak
	var/sound_falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE
	///sound exponent for squeak. Defaults to 10 as squeaking is loud and annoying enough.
	var/sound_falloff_exponent = 10

	///what we set connect_loc to if parent is an item
	var/static/list/item_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)


/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, use_delay_override, squeak_on_move, extrarange, falloff_exponent, fallof_distance)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATTACK_BY), PROC_REF(play_squeak))
	if(ismovable(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), PROC_REF(play_squeak))

		AddComponent(/datum/component/connect_loc_behalf, parent, item_connections)
		RegisterSignal(parent, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react))
		if(squeak_on_move)
			RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(play_squeak))
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ATTACK, COMSIG_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT), PROC_REF(play_squeak))
			RegisterSignal(parent, COMSIG_ACTIVATE_SELF, PROC_REF(use_squeak))
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, PROC_REF(step_squeak))

	override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override
	if(isnum(extrarange))
		sound_extra_range = extrarange
	if(isnum(falloff_exponent))
		sound_falloff_exponent = falloff_exponent
	if(isnum(fallof_distance))
		sound_falloff_distance = fallof_distance

/datum/component/squeak/proc/play_squeak()
	if(ismob(parent))
		var/mob/M = parent
		if(M.stat == DEAD)
			return
	if(prob(squeak_chance))
		if(!override_squeak_sounds)
			playsound(parent, pickweight(default_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)
		else
			playsound(parent, pickweight(override_squeak_sounds), volume, TRUE, sound_extra_range, sound_falloff_exponent, falloff_distance = sound_falloff_distance)

/datum/component/squeak/proc/step_squeak()
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++

/datum/component/squeak/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(istype(entered, /obj/effect))
		return
	if(ismob(entered))
		var/mob/M = entered
		if(HAS_TRAIT(M, TRAIT_FLYING))
			return
		if(isliving(entered))
			var/mob/living/L = M
			if(L.floating)
				return
	else if(isitem(entered))
		var/obj/item/I = source
		if(I.flags & ABSTRACT)
			return
		if(isprojectile(entered))
			var/obj/item/projectile/P = entered
			if(P.original != parent)
				return
	if(ismob(source))
		var/mob/M = source
		if(HAS_TRAIT(M, TRAIT_FLYING))
			return
		if(isliving(source))
			var/mob/living/L = M
			if(L.floating)
				return
	play_squeak()

/datum/component/squeak/proc/use_squeak()
	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()

/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_MOVABLE_DISPOSING, PROC_REF(disposing_react), TRUE)

/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_DISPOSING)

// Disposal pipes related shit
/datum/component/squeak/proc/disposing_react(datum/source, obj/structure/disposalholder/disposal_holder, obj/machinery/disposal/disposal_source)
	//We don't need to worry about unregistering this signal as it will happen for us automaticaly when the holder is qdeleted
	RegisterSignal(disposal_holder, COMSIG_ATOM_DIR_CHANGE, PROC_REF(holder_dir_change))

/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()
