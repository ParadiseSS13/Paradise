/**
  * # Slip Component
  *
  * This is a component that can be applied to any movable atom (mob or obj).
  *
  * While the atom has this component, any human mob that walks over it will have a chance to slip.
  * Duration, tiles moved, and so on, depend on what variables are passed in when the component is added.
  *
  */
/datum/component/slippery
	/// Text that gets displayed in the slip proc, i.e. "user slips on [description]"
	var/description
	/// The amount of stun to apply after slip.
	var/stun
	/// The amount of weaken to apply after slip.
	var/weaken
	/// The chance that walking over the parent will slip you.
	var/slip_chance
	/// The amount of tiles someone will be moved after slip.
	var/slip_tiles
	/// TRUE If this slip can be avoided by walking.
	var/walking_is_safe
	/// FALSE if you want no slip shoes to make you immune to the slip
	var/slip_always
	/// FALSE if you want no slip without gravity
	var/gravi_ignore
	/// The verb that players will see when someone slips on the parent. In the form of "You [slip_verb]ped on".
	var/slip_verb

/datum/component/slippery/Initialize(_description, _stun = 0, _weaken = 0, _slip_chance = 100, _slip_tiles = 0, _walking_is_safe = TRUE, _slip_always = FALSE, _gravi_ignore = FALSE, _slip_verb = "slip")
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	description = _description
	stun = max(0, _stun)
	weaken = max(0, _weaken)
	slip_chance = max(0, _slip_chance)
	slip_tiles = max(0, _slip_tiles)
	walking_is_safe = _walking_is_safe
	slip_always = _slip_always
	gravi_ignore = _gravi_ignore
	slip_verb = _slip_verb

/datum/component/slippery/RegisterWithParent()
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)

/datum/component/slippery/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED))

/**
	Called whenever the parent recieves either the `MOVABLE_CROSSED` signal or the `ATOM_ENTERED` signal.

	Calls the `victim`'s `slip()` proc with the component's variables as arguments.
	Additionally calls the parent's `after_slip()` proc on the `victim`.
*/
/datum/component/slippery/proc/Slip(datum/source, mob/living/carbon/human/victim)
	if(istype(victim) && !victim.flying && prob(slip_chance) && victim.slip(description, stun, weaken, slip_tiles, walking_is_safe, slip_always, gravi_ignore, slip_verb))
		var/atom/movable/owner = parent
		owner.after_slip(victim)
