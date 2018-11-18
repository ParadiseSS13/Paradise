/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(istype(M))
		var/mob/living/carbon/human/H
		var/obj/item/organ/external/affecting
		var/selected_zone = user.zone_sel.selecting

		if(istype(M, /mob/living/carbon/human))
			H = M
			affecting = H.get_organ(check_zone(selected_zone))

		if(can_operate(M) || isslime(M))	//if they're prone or a slime
			var/datum/active_surgery/current_surgery
			for(var/datum/active_surgery/S in M.surgeries)
				if(S.location == selected_zone)
					current_surgery = S

			if(!current_surgery)
				// Here's where we initialize our active_surgery
				var/list/all_surgeries = GLOB.surgeries_list.Copy()

				// This list's format:
				// 	Each entry will be a "surgery_step" type
				//	It will be the "key" for a list of full surgeries we can do that have it as a first step
				//	If there's multiple possible first steps, then we pop up the prompt
				// 	Otherwise, we just do that step
				var/list/possible_first_steps = list()

				//Build a list of steps we can perform without any prior steps
				for(var/datum/surgery/S in all_surgeries)
					if(!S.surgery_is_compatible(user, M, selected_zone))
						continue

					var/datum/surgery_step/first_step = S.steps[1]
					var/datum/surgery_step/temp_reference = new first_step
					if(possible_first_steps.Find(temp_reference.name))
						continue
					if(temp_reference.tool_quality(I) > 0)
						// Our starter-tool can perform the first step,
						// let's add this step to the list of ones we can do!
						possible_first_steps[temp_reference.name] = first_step
					qdel(temp_reference)

				/* This is where I build a list of possible steps
				To get this list:
				I will look through all possible surgeries
				I will look at their first steps
				I will see if their first step can be performed with the held item
					If there are different types of steps that can be performed with the held tool,
					then pop up the procedure prompt
				*/
				var/datum/surgery_step/the_first_step
				if(possible_first_steps.len > 1)
					// We'll need to build a list of surgeries, tagged by name, from our "possible_first_steps" list

					var/P = input("Perform which step?", "Surgery", null, null) as null|anything in possible_first_steps
					if(P)
						the_first_step = possible_first_steps[P]
				else if(possible_first_steps.len == 1)
					// Whee BYOND lists are weird - a blend of hash-tables and arrays
					var/step_name = possible_first_steps[1]
					the_first_step = possible_first_steps[step_name]

				if(the_first_step && user && user.Adjacent(M) && (I in user))
					var/datum/active_surgery/procedure = new
					if(procedure)
						procedure.location = selected_zone
						procedure.next_step_to_do = the_first_step
						M.surgeries += procedure
						procedure.organ_ref = affecting
						user.visible_message("[user] prepares to operate on [M]'s [parse_zone(selected_zone)].", \
						"<span class='notice'>You prepare to operate on [M]'s [parse_zone(selected_zone)].</span>")
						procedure.next_step(user, M)

			else if(!current_surgery.step_in_progress)
				if(istype(user.get_inactive_hand(), /obj/item/cautery) && current_surgery.can_cancel)
					M.surgeries -= current_surgery
					user.visible_message("[user] mends the incision on [M]'s [parse_zone(selected_zone)] with the [I] .", \
						"<span class='notice'>You mend the incision on [M]'s [parse_zone(selected_zone)].</span>")
					if(affecting)
						affecting.open = 0
						affecting.germ_level = 0
					qdel(current_surgery)
				else if(current_surgery.can_cancel)
					to_chat(user, "<span class='warning'>You need to hold a cautery in inactive hand to stop [M]'s surgery!</span>")


			return 1
	return 0

/proc/get_pain_modifier(mob/living/carbon/human/M) //returns modfier to make surgery harder if patient is conscious and feels pain
	if(M.stat) //stat=0 if CONSCIOUS, 1=UNCONSCIOUS and 2=DEAD. Operating on dead people is easy, too. Just sleeping won't work, though.
		return 1
	if(NO_PAIN in M.dna.species.species_traits)//if you don't feel pain, you can hold still
		return 1
	if(M.reagents.has_reagent("hydrocodone"))//really good pain killer
		return 0.99
	if(M.reagents.has_reagent("morphine"))//Just as effective as Hydrocodone, but has an addiction chance
		return 0.99
	if(M.drunk >= 80)//really damn drunk
		return 0.95
	if(M.drunk >= 40)//pretty drunk
		return 0.9
	if(M.reagents.has_reagent("sal_acid")) //it's better than nothing, as far as painkillers go.
		return 0.85
	if(M.drunk >= 15)//a little drunk
		return 0.85
	return 0.8 //20% failure chance

/proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/machinery/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5

// Called when a limb containing this object is placed back on a body
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	return 0

/proc/can_be_used_for_starting_surgery(obj/item/I, mob/living/user, mob/living/target)
	// Eh, I split it up like this so you can view it in a single screen
	if(is_sharp(I))
		// Surgery, "Classic"!
		return 1
	if(istype(I, /obj/item/robot_parts))
		// Robot limbs
		return 1
	if(istype(I, /obj/item/screwdriver))
		// Robotic "surgeries"
		return 1
	if(istype(I, /obj/item/organ/external))
		// Limb attachment
		return 1
	if(istype(I, /obj/item/multitool))
		// Robo-limb removal
		return 1
	return 0
