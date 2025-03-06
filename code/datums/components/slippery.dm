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
	/// The amount of knockdown to apply after slip.
	var/knockdown
	/// The chance that walking over the parent will slip you.
	var/slip_chance
	/// The amount of tiles someone will be moved after slip.
	var/slip_tiles
	/// TRUE If this slip can be avoided by walking.
	var/walking_is_safe
	/// FALSE if you want no slip shoes to make you immune to the slip
	var/slip_always
	/// The verb that players will see when someone slips on the parent. In the form of "You [slip_verb]ped on".
	var/slip_verb
	/// TRUE the player will only slip if the mob this datum is attached to is horizontal
	var/horizontal_required
	///what we give to connect_loc by default, makes slippable mobs moving over us slip
	var/static/list/default_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(slip),
	)

/datum/component/slippery/Initialize(_description, _knockdown = 0, _slip_chance = 100, _slip_tiles = 0, _walking_is_safe = TRUE, _slip_always = FALSE, _slip_verb = "slip", _horizontal_required = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	description = _description
	knockdown = max(0, _knockdown)
	slip_chance = max(0, _slip_chance)
	slip_tiles = max(0, _slip_tiles)
	walking_is_safe = _walking_is_safe
	slip_always = _slip_always
	slip_verb = _slip_verb
	horizontal_required = _horizontal_required

	add_connect_loc_behalf_to_parent()

/datum/component/slippery/proc/add_connect_loc_behalf_to_parent()
	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, default_connections)

/**
	Called whenever the parent receives the `ATOM_ENTERED` signal.

	Calls the `victim`'s `slip()` proc with the component's variables as arguments.
	Additionally calls the parent's `after_slip()` proc on the `victim`.
*/
/datum/component/slippery/proc/slip(datum/source, mob/living/carbon/human/victim)
	SIGNAL_HANDLER // COMSIG_ATOM_ENTERED

	if(istype(victim) && !HAS_TRAIT(victim, TRAIT_FLYING))
		var/atom/movable/owner = parent
		if(!isturf(owner.loc))
			return
		if(isliving(owner))
			var/mob/living/mob_owner = owner
			if(horizontal_required && !IS_HORIZONTAL(mob_owner))
				return
		if(prob(slip_chance) && victim.slip(description, knockdown, slip_tiles, walking_is_safe, slip_always, slip_verb))
			owner.after_slip(victim)
