///////////////////////////////////////////////////////////////////////////////////
/datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	/// A list of IDs of the required reagents.
	///
	/// Each ID also needs an associated value that gives us the minimum
	/// required amount / of that reagent. The handle_reaction proc can detect
	/// mutiples of the same recipes / so for most cases you want to set the
	/// required amount to 1.
	var/list/required_reagents = list()
	var/list/required_catalysts = list()

	// Both of these variables are mostly going to be used with slime cores
	// but if you want to, you can use them for other things

	/// The container required for the reaction to happen.
	/// Leave this null if you want the reaction to happen anywhere.
	var/atom/required_container = null
	/// Extra requirements for the reaction to happen.
	var/required_other = FALSE

	/// This is the amount of the resulting reagent this recipe will produce.
	/// It's recommended you set this to the total volume of all required reagents.
	var/result_amount = 0
	var/list/secondary_results = list()		//additional reagents produced by the reaction
	var/min_temp = 0		//Minimum temperature required for the reaction to occur (heat to/above this). min_temp = 0 means no requirement
	var/max_temp = 9999		//Maximum temperature allowed for the reaction to occur (cool to/below this).
	var/mix_message = "The solution begins to bubble."
	var/mix_sound = 'sound/effects/bubbles.ogg'

/datum/chemical_reaction/proc/on_reaction(datum/reagents/holder, created_volume)
	return

/datum/chemical_reaction/proc/last_can_react_check(datum/reagents/holder)
	return TRUE

/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_class = HOSTILE_SPAWN, mob_faction = "chemicalsummon", random = TRUE, gold_core_spawn = FALSE)
	if(holder && holder.my_atom)
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/message = "A [reaction_name] reaction has occurred in [ADMIN_VERBOSEJMP(T)]"
		message += " ([ADMIN_VV(A,"VV")])"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [key_name_admin(M)]([ADMIN_QUE(M,"?")]) ([ADMIN_FLW(M,"FLW")])"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)
		log_game("[reaction_name] chemical mob spawn reaction occurring at [AREACOORD(T)] carried by [key_name(M)] with last fingerprint [A.fingerprintslast? A.fingerprintslast : "N/A"]")

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_eyes()

		for(var/i in 1 to amount_to_spawn)
			var/mob/living/new_mob
			if(random)
				new_mob = create_random_mob(get_turf(holder.my_atom), mob_class)
			else
				new_mob = new mob_class(get_turf(holder.my_atom))//Spawn our specific mob_class
			if(gold_core_spawn) //For tracking xenobiology mobs
				ADD_TRAIT(new_mob, TRAIT_XENOBIO_SPAWNED, "xenobio")
			new_mob.faction |= mob_faction
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(new_mob, pick(NORTH,SOUTH,EAST,WEST))

/**
  * Throws or pulls objects to/from a chem reaction
  *
  * Scales the amount of objects thrown with the volume, unless ignore_volume is TRUE
  *
  * Arguments:
  * * T - The turf to use as the throw from/to point
  * * pull - Do we want to pull objects towards T (TRUE) or push them away from it (FALSE)
  * * volume - The volume of reagents. Used to scale the effect is ignore_volume = FALSE
  * * ignore_volume - Do we want to ignore the volume of reagents and just throw regardless
  */
/proc/goonchem_vortex(turf/T, pull, volume, ignore_volume = FALSE)
	if(pull)
		new /obj/effect/temp_visual/implosion(T)
		playsound(T, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
	else
		new /obj/effect/temp_visual/shockwave(T)
		playsound(T, 'sound/effects/bang.ogg', 25, 1)
	// PARADISE EDIT: Allow only a certain amount of atoms to be pulled per unit
	var/units_per_atom = 5
	var/atoms_to_move = round(volume / units_per_atom)
	var/moved_count = 0
	// The ternary below isnt exactly needed, but it makes code more readable because `pull` is a bool
	for(var/atom/movable/X in view(2 + (pull ? 1 : 0)  + (volume > 30 ? 1 : 0), T))
		if(iseffect(X))
			continue  //stop pulling smoke and hotspots please
		if(X && !X.anchored && X.move_resist <= MOVE_FORCE_DEFAULT)
			if(pull)
				X.throw_at(T, 20 + round(volume * 2), 1 + round(volume / 10))
			else
				X.throw_at(get_edge_target_turf(T, get_dir(T, X)), 20 + round(volume * 2), 1 + round(volume / 10))
			moved_count++
			if((moved_count >= atoms_to_move) && !ignore_volume)
				break
