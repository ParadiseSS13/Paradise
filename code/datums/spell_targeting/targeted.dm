/* FUCK this shit for now. See if this all is still needed once others are made
/datum/spell_targeting/targeted
	/// only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/target_ignore_prev
	//if it includes usr in the target list
	var/include_user
	/// chooses random viable target instead of asking the caster
	var/random_target
	/// if random_target is enabled how it will pick the target
	var/random_target_priority
	/// for avoiding simple animals and only doing "human" mobs, 0 = all mobs, 1 = humans only
	var/humans_only

/datum/spell_targeting/targeted/choose_targets(mob/user)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited

			if(!humans_only)
				for(var/mob/living/target in view_or_range(range, user, selection_type))
					targets += target
			else
				for(var/mob/living/carbon/human/target in view_or_range(range, user, selection_type))
					targets += target

		if(1) //single target can be picked
			if(range < 0)
				targets += user
			else
				var/possible_targets = list()

				if(!humans_only)
					for(var/mob/living/M in view_or_range(range, user, selection_type))
						if(!include_user && user == M)
							continue
						possible_targets += M
				else
					for(var/mob/living/carbon/human/M in view_or_range(range, user, selection_type))
						if(!include_user && user == M)
							continue
						possible_targets += M

				//targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				//Adds a safety check post-input to make sure those targets are actually in range.
				var/mob/M
				if(!random_target)
					M = input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				else
					switch(random_target_priority)
						if(TARGET_RANDOM)
							M = pick(possible_targets)
						if(TARGET_CLOSEST)
							for(var/mob/living/L in possible_targets)
								if(M)
									if(get_dist(user,L) < get_dist(user,M))
										if(los_check(user, L))
											M = L
								else
									if(los_check(user, L))
										M = L
				if(M in view_or_range(range, user, selection_type)) targets += M

		else
			var/list/possible_targets = list()
			if(!humans_only)
				for(var/mob/living/target in view_or_range(range, user, selection_type))
					possible_targets += target
			else
				for(var/mob/living/carbon/human/target in view_or_range(range, user, selection_type))
					possible_targets += target
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!include_user)
		targets -= user

	return targets


/datum/spell_targeting/targeted/proc/los_check(atom/A, atom/B)
	//Checks for obstacles from A to B
	var/obj/dummy = new(A.loc)
	dummy.pass_flags |= PASSTABLE
	for(var/turf/turf in getline(A,B))
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1
*/
