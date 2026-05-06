/datum/action/cooldown/flock/create_structure
	name = "Place Tealprint"
	desc = "Create a structure tealprint for your drones to construct onto."
	button_icon_state = "fabstructure"

/datum/action/cooldown/flock/create_structure/is_valid_target(atom/cast_on)
	var/turf/simulated/floor/flock/T = get_turf(owner)
	if(!istype(T))
		to_chat(owner, SPAN_WARNING("We are unable to perform complex substrate manipulation outside of our tiles."))
		return FALSE

	if(T.broken)
		to_chat(owner, SPAN_WARNING("The tile we are above is broken."))
		return FALSE

	if(locate(/obj/structure/flock/tealprint) in T)
		to_chat(owner, SPAN_WARNING("We are currently building something there."))
		return FALSE

	if(locate(/obj/structure/flock) in T)
		to_chat(owner, SPAN_WARNING("An existing structure is occupying that tile."))
		return FALSE

	return TRUE

/datum/action/cooldown/flock/create_structure/Activate(atom/target)
	var/mob/camera/flock/overmind/ghost_bird = owner
	var/datum/flock/F = ghost_bird.flock
	var/turf/loc = get_turf(ghost_bird)

	var/options = list()
	for(var/datum/flock_unlockable/unlockable as anything in F.unlockables)
		if(!unlockable.unlocked)
			continue
		options[unlockable.name] = unlockable

	var/datum/flock_unlockable/desired = tgui_input_list(ghost_bird, "Select a structure to create. Bandwidth upkeep costs are provided in parenthesis.", "Tealprint Selection", options)
	desired = options[desired]

	if(isnull(desired))
		return

	F.refresh_unlockables()
	if(!desired.unlocked)
		return

	F.create_structure(loc, desired.structure_type)

	return ..()
