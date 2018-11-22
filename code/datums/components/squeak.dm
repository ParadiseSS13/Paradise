// Squeak component ported over from tg

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

/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, use_delay_override)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_PARENT_ATTACKBY), .proc/play_squeak_check)
	if(ismovableatom(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), .proc/play_squeak_check)
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/play_squeak_check)
		RegisterSignal(parent, COMSIG_MOVABLE_DISPOSING, .proc/disposing_react)
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT), .proc/play_squeak)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/use_squeak)
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_squeak)

	override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override

/datum/component/squeak/proc/play_squeak()
	if(prob(squeak_chance))
		if(!override_squeak_sounds)
			playsound(parent, pickweight(default_squeak_sounds), volume, 1, -1)
		else
			playsound(parent, pickweight(override_squeak_sounds), volume, 1, -1)

/datum/component/squeak/proc/step_squeak()
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++

/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	RegisterSignal(equipper, COMSIG_MOVABLE_DISPOSING, .proc/disposing_react, TRUE)

/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_DISPOSING)

/datum/component/squeak/proc/play_squeak_check(atom/movable/signal_owner, atom/movable/signal_trigger)
	// Signals are generally of the form SEND_SIGNAL(mob_listening_for_signals, signaltype, triggering_atom). E.g: SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)
	// Since proc/play_squeak_check's second argument is typed as /atom/movable/signal_trigger, it binds to the THIRD signal argument.
	// Hence what we actually get here is play_squeak_check(mob/themouse, atom/whatever_trigged_the_squeak).... the latter could be a crossing/bumping mob, or collision with a solid object.
	if(ismob(signal_owner))
		var/mob/M = signal_owner
		if(M.stat == DEAD) // Do not squeak if the squeaking mob is dead
			return
	if(ismob(signal_trigger))
		var/mob/M = signal_trigger
		if(M.stat == DEAD) // Do not squeak if the thing that is interacting with us is dead, e.g: a ghost
			return
	if(isitem(signal_trigger))
		var/obj/item/I = signal_trigger
		if(I.flags & ABSTRACT)
			return
		else if(istype(signal_trigger, /obj/item/projectile))
			var/obj/item/projectile/P = signal_trigger
			if(P.original != parent)
				return
	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()

/datum/component/squeak/proc/use_squeak()
	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()

/datum/component/squeak/proc/disposing_react(datum/source, obj/structure/disposalholder/holder, obj/machinery/disposal/source)
	//We don't need to worry about unregistering this signal as it will happen for us automaticaly when the holder is qdeleted
	RegisterSignal(holder, COMSIG_ATOM_DIR_CHANGE, .proc/holder_dir_change)

/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()