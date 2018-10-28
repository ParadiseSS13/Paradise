// Squeak component ported over from tg
// Note to future coders: I decided to remove the special case for squeak cooldown on usage and instead opt for a universal 20 ticks cooldown to avoid squeak spam

/datum/component/squeak
	var/static/list/default_squeak_sounds = list('sound/items/toysqueak1.ogg'=1, 'sound/items/toysqueak2.ogg'=1, 'sound/items/toysqueak3.ogg'=1)
	var/list/override_squeak_sounds
	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam (Apply to both usage and normal triggering unlike tg which only apply it to use)
	var/last_squeak = 0
	var/squeak_delay = 20

/datum/component/squeak/Initialize(custom_sounds, volume_override, chance_override, step_delay_override, squeak_delay_override)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_BLOB_ACT, COMSIG_ATOM_HULK_ATTACK, COMSIG_PARENT_ATTACKBY), .proc/play_squeak)
	if(ismovableatom(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), .proc/play_squeak)
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/play_squeak_crossed)
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_OBJ, COMSIG_ITEM_HIT_REACT, COMSIG_ITEM_ATTACK_SELF), .proc/play_squeak)
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_squeak)

	override_squeak_sounds = custom_sounds
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(squeak_delay_override))
		squeak_delay = squeak_delay_override

/datum/component/squeak/proc/play_squeak()
	if(last_squeak + squeak_delay >= world.time)
		return
	last_squeak = world.time
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

/datum/component/squeak/proc/play_squeak_crossed(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.flags & ABSTRACT)
			return
		else if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			if(P.original != parent)
				return
	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()