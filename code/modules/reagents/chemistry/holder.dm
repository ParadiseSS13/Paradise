#define ADDICTION_TIME 4800 //8 minutes

///////////////////////////////////////////////////////////////////////////////////

/datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/chem_temp = T20C
	var/list/datum/reagent/addiction_list = new/list()
	var/list/addiction_threshold_accumulated = new/list()
	var/flags
	var/list/reagents_generated_per_cycle = new/list()

/datum/reagents/New(maximum = 100)
	maximum_volume = maximum
	if(!(flags & REAGENT_NOREACT))
		START_PROCESSING(SSobj, src)
	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!GLOB.chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = subtypesof(/datum/reagent)
		GLOB.chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			GLOB.chemical_reagents_list[D.id] = D
	if(!GLOB.chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["plasma"] is a list of all reactions relating to plasma

		var/paths = subtypesof(/datum/chemical_reaction)
		GLOB.chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D && D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!GLOB.chemical_reactions_list[id])
					GLOB.chemical_reactions_list[id] = list()
				GLOB.chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.

/datum/reagents/proc/remove_any(amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount)
			break
		if(total_volume <= 0 || !reagent_list.len)
			break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		remove_reagent(current_reagent.id, min(1, amount - total_transfered))

		current_list_element++
		total_transfered++
		update_total()

	handle_reactions()
	return total_transfered

/datum/reagents/proc/remove_all(amount = 1)
	var/list/cached_reagents = reagent_list
	if(total_volume > 0)
		var/part = amount / total_volume
		for(var/reagent in cached_reagents)
			var/datum/reagent/R = reagent
			remove_reagent(R.id, R.volume * part)

		update_total()
		handle_reactions()
		return amount

/datum/reagents/proc/get_master_reagent()
	var/the_reagent = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_reagent = A

	return the_reagent

/datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

/datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/datum/reagents/proc/trans_to(target, amount=1, multiplier=1, preserve_data=1, no_react = 0)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if(!target)
		return
	if(total_volume <= 0)
		return
	var/datum/reagents/R
	if(istype(target, /obj))
		var/obj/O = target
		if(!O.reagents )
			return
		R = O.reagents
	else if(isliving(target))
		var/mob/living/M = target
		if(!M.reagents)
			return
		R = M.reagents
	else if(istype(target, /datum/reagents))
		R = target
	else
		return

	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/datum/reagent/current_reagent in reagent_list)
		if(!current_reagent)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, chem_temp, no_react = 1)
		remove_reagent(current_reagent.id, current_reagent_transfer)

	update_total()
	R.update_total()
	if(!no_react)
		R.handle_reactions()
		handle_reactions()
	return amount

/datum/reagents/proc/copy_to(obj/target, amount=1, multiplier=1, preserve_data=1, safety = 0)
	if(!target)
		return
	if(!target.reagents || total_volume<=0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / total_volume
	var/trans_data = null
	for(var/datum/reagent/current_reagent in reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data)

	update_total()
	R.update_total()
	R.handle_reactions()
	handle_reactions()
	return amount

/datum/reagents/proc/set_reagent_temp(new_temp = T0C, react = TRUE)
	chem_temp = new_temp
	if(react)
		temperature_react()
		handle_reactions()

/datum/reagents/proc/temperature_react() //Calls the temperature reaction procs without changing the temp.
	for(var/datum/reagent/current_reagent in reagent_list)
		current_reagent.reaction_temperature(chem_temp, 100)

/datum/reagents/proc/temperature_reagents(exposed_temperature, divisor = 35, change_cap = 15) //This is what you use to change the temp of a reagent holder.
	//Do not manually change the reagent unless you know what youre doing.
	var/difference = abs(chem_temp - exposed_temperature)
	var/change = min(max((difference / divisor), 1), change_cap)
	if(exposed_temperature > chem_temp)
		chem_temp += change
	else if(exposed_temperature < chem_temp)
		chem_temp -= change

	chem_temp = max(min(chem_temp, 10000), 0) //Cap for the moment.
	temperature_react()

	handle_reactions()

/datum/reagents/proc/trans_id_to(obj/target, reagent, amount=1, preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	if(!target)
		return
	if(!target.reagents || total_volume<=0 || !get_reagent_amount(reagent))
		return

	var/datum/reagents/R = target.reagents
	if(get_reagent_amount(reagent) < amount)
		amount = get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for(var/datum/reagent/current_reagent in reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = copy_data(current_reagent)
			R.add_reagent(current_reagent.id, amount, trans_data, chem_temp)
			remove_reagent(current_reagent.id, amount, 1)
			break

	update_total()
	R.update_total()
	R.handle_reactions()
	//handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount


/datum/reagents/proc/metabolize(mob/living/M)
	if(M)
		temperature_reagents(M.bodytemperature - 30)


	if(LAZYLEN(addiction_threshold_accumulated))
		for(var/thing in addiction_threshold_accumulated)
			if(has_reagent(thing))
				continue // if we have the reagent in our system, then don't deplete the addiction threshold
			addiction_threshold_accumulated[thing] -= 0.01 // Otherwise very slowly deplete the buildup
			if(addiction_threshold_accumulated[thing] <= 0)
				addiction_threshold_accumulated -= thing

	// a bitfield filled in by each reagent's `on_mob_life` to find out which states to update
	var/update_flags = STATUS_UPDATE_NONE
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(!istype(R)) // How are non-reagents ending up in the reagents_list?
			continue
		if(!R.holder)
			continue
		if(!M)
			M = R.holder.my_atom
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			//Check if this mob's species is set and can process this type of reagent
			var/can_process = 0
			//If we somehow avoided getting a species or reagent_tag set, we'll assume we aren't meant to process ANY reagents (CODERS: SET YOUR SPECIES AND TAG!)
			if(H.dna.species && H.dna.species.reagent_tag)
				if((R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_SYN))		//SYNTHETIC-oriented reagents require PROCESS_SYN
					can_process = 1
				if((R.process_flags & ORGANIC) && (H.dna.species.reagent_tag & PROCESS_ORG))		//ORGANIC-oriented reagents require PROCESS_ORG
					can_process = 1
				//Species with PROCESS_DUO are only affected by reagents that affect both organics and synthetics, like acid and hellwater
				if((R.process_flags & ORGANIC) && (R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_DUO))
					can_process = 1

			//If handle_reagents returns 0, it's doing the reagent removal on its own
			var/species_handled = !(H.dna.species.handle_reagents(H, R))
			can_process = can_process && !species_handled
			//If the mob can't process it, remove the reagent at it's normal rate without doing any addictions, overdoses, or on_mob_life() for the reagent
			if(can_process == 0)
				if(!species_handled)
					R.holder.remove_reagent(R.id, R.metabolization_rate)
				continue
		//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
		else
			if(R.process_flags == SYNTHETIC)
				R.holder.remove_reagent(R.id, R.metabolization_rate)
				continue
		//If you got this far, that means we can process whatever reagent this iteration is for. Handle things normally from here.
		if(M && R)
			update_flags |= R.on_mob_life(M)
			if(R.volume >= R.overdose_threshold && !R.overdosed && R.overdose_threshold > 0)
				R.overdosed = TRUE
				R.overdose_start(M)
			if(R.volume < R.overdose_threshold && R.overdosed)
				R.overdosed = FALSE
			if(R.overdosed)
				var/list/overdose_results = R.overdose_process(M, R.volume >= R.overdose_threshold*2 ? 2 : 1)
				if(overdose_results) // to protect against poorly-coded overdose procs
					update_flags |= overdose_results[REAGENT_OVERDOSE_FLAGS]
				else
					log_runtime(EXCEPTION("Reagent '[R.name]' does not return an overdose info list!"))

	for(var/A in addiction_list)
		var/datum/reagent/R = A
		if(M && R)
			if(R.addiction_stage < 5)
				if(prob(5))
					R.addiction_stage++
			if(M.reagents.has_reagent(R.id))
				R.last_addiction_dose = world.timeofday
				R.addiction_stage = 1
			else
				switch(R.addiction_stage)
					if(1)
						update_flags |= R.addiction_act_stage1(M)
					if(2)
						update_flags |= R.addiction_act_stage2(M)
					if(3)
						update_flags |= R.addiction_act_stage3(M)
					if(4)
						update_flags |= R.addiction_act_stage4(M)
					if(5)
						update_flags |= R.addiction_act_stage5(M)
			if(prob(20) && (world.timeofday > (R.last_addiction_dose + ADDICTION_TIME))) //Each addiction lasts 8 minutes before it can end
				to_chat(M, "<span class='notice'>You no longer feel reliant on [R.name]!</span>")
				addiction_list.Remove(R)
				qdel(R)

	if(update_flags & STATUS_UPDATE_HEALTH)
		M.updatehealth("reagent metabolism")
	else if(update_flags & STATUS_UPDATE_STAT)
		// update_stat is called in updatehealth
		M.update_stat("reagent metabolism")
	if(update_flags & STATUS_UPDATE_CANMOVE)
		M.update_canmove()
	if(update_flags & STATUS_UPDATE_STAMINA)
		M.update_stamina()
	if(update_flags & STATUS_UPDATE_BLIND)
		M.update_blind_effects()
	if(update_flags & STATUS_UPDATE_BLURRY)
		M.update_blurry_effects()
	if(update_flags & STATUS_UPDATE_NEARSIGHTED)
		M.update_nearsighted_effects()
	if(update_flags & STATUS_UPDATE_DRUGGY)
		M.update_druggy_effects()
	update_total()

/datum/reagents/proc/death_metabolize(mob/living/M)
	if(!M)
		return
	if(M.stat != DEAD)				//what part of DEATH_metabolize don't you get?
		return
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(!istype(R))
			continue
		if(M && R)
			R.on_mob_death(M)

/datum/reagents/proc/overdose_list()
	var/od_chems[0]
	for(var/datum/reagent/R in reagent_list)
		if(R.overdosed)
			od_chems.Add(R.id)
	return od_chems

/datum/reagents/process()
	if(flags & REAGENT_NOREACT)
		STOP_PROCESSING(SSobj, src)
		return
	for(var/thing in reagents_generated_per_cycle)
		add_reagent(thing, reagents_generated_per_cycle[thing])
	for(var/datum/reagent/R in reagent_list)
		R.on_tick()

/datum/reagents/proc/set_reacting(react = TRUE)
	if(react)
		// Order is important, process() can remove from processing if
		// the flag is present
		flags &= ~(REAGENT_NOREACT)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
		flags |= REAGENT_NOREACT

/*
	if(!target) return
	var/total_transfered = 0
	var/current_list_element = 1
	var/datum/reagents/R = target.reagents
	var/trans_data = null
	//if(R.total_volume + amount > R.maximum_volume) return 0

	current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

	while(total_transfered != amount)
		if(total_transfered >= amount) break //Better safe than sorry.
		if(total_volume <= 0 || !reagent_list.len) break
		if(R.total_volume >= R.maximum_volume) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
		remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		update_total()
		R.update_total()
	R.handle_reactions()
	handle_reactions()

	return total_transfered
*/


/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A, )
	for(var/datum/reagent/R in reagent_list)
		R.on_update (A)
	update_total()

/datum/reagents/proc/handle_reactions()
	if(flags & REAGENT_NOREACT)
		return //Yup, no reactions here. No siree.

	var/reaction_occured = 0
	do
		reaction_occured = 0
		for(var/datum/reagent/R in reagent_list) // Usually a small list
			for(var/reaction in GLOB.chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id
				if(!reaction)
					continue

				var/datum/chemical_reaction/C = reaction
				var/total_required_reagents = C.required_reagents.len
				var/total_matching_reagents = 0
				var/total_required_catalysts = C.required_catalysts.len
				var/total_matching_catalysts= 0
				var/matching_container = 0
				var/matching_other = 0
				var/list/multipliers = new/list()
				var/min_temp = C.min_temp			//Minimum temperature required for the reaction to occur (heat to/above this)
				var/max_temp = C.max_temp			//Maximum temperature allowed for the reaction to occur (cool to/below this)
				for(var/B in C.required_reagents)
					if(!has_reagent(B, C.required_reagents[B]))
						break
					total_matching_reagents++
					multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
				for(var/B in C.required_catalysts)
					if(!has_reagent(B, C.required_catalysts[B]))
						break
					total_matching_catalysts++

				if(!C.required_container)
					matching_container = 1

				else
					if(my_atom.type == C.required_container)
						matching_container = 1

				if(!C.required_other)
					matching_other = 1

				else if(istype(my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/M = my_atom

					if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
						matching_other = 1

				if(min_temp == 0)
					min_temp = chem_temp

				if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other && chem_temp <= max_temp && chem_temp >= min_temp)
					var/multiplier = min(multipliers)
					var/preserved_data = null
					for(var/B in C.required_reagents)
						if(!preserved_data)
							preserved_data = get_data(B)
						remove_reagent(B, (multiplier * C.required_reagents[B]), safety = 1)

					var/created_volume = C.result_amount*multiplier
					if(C.result)
						feedback_add_details("chemical_reaction","[C.result]|[C.result_amount*multiplier]")
						multiplier = max(multiplier, 1) //this shouldnt happen ...
						add_reagent(C.result, C.result_amount*multiplier)
						set_data(C.result, preserved_data)

						//add secondary products
						for(var/S in C.secondary_results)
							add_reagent(S, C.result_amount * C.secondary_results[S] * multiplier)

					var/list/seen = viewers(4, get_turf(my_atom))
					for(var/mob/living/M in seen)
						if(C.mix_message)
							to_chat(M, "<span class='notice'>[bicon(my_atom)] [C.mix_message]</span>")

					if(istype(my_atom, /obj/item/slime_extract))
						var/obj/item/slime_extract/ME2 = my_atom
						ME2.Uses--
						if(ME2.Uses <= 0) // give the notification that the slime core is dead
							for(var/mob/M in seen)
								to_chat(M, "<span class='notice'>[bicon(my_atom)] The [my_atom]'s power is consumed in the reaction.</span>")
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."

					if(C.mix_sound)
						playsound(get_turf(my_atom), C.mix_sound, 80, 1)

					C.on_reaction(src, created_volume)
					reaction_occured = 1
					break

	while(reaction_occured)
	update_total()
	return 0

/datum/reagents/proc/isolate_reagent(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id != reagent)
			del_reagent(R.id)
			update_total()

/datum/reagents/proc/del_reagent(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			if(isliving(my_atom))
				var/mob/living/M = my_atom
				R.on_mob_delete(M)
			reagent_list -= A
			qdel(A)
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			return 0


	return 1

/datum/reagents/proc/update_total()
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume

	return 0

/datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id)
	return 0

/datum/reagents/proc/reaction_check(mob/living/M, datum/reagent/R)
	var/can_process = 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		//Check if this mob's species is set and can process this type of reagent
		if(H.dna.species && H.dna.species.reagent_tag)
			if((R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_SYN))		//SYNTHETIC-oriented reagents require PROCESS_SYN
				can_process = 1
			if((R.process_flags & ORGANIC) && (H.dna.species.reagent_tag & PROCESS_ORG))		//ORGANIC-oriented reagents require PROCESS_ORG
				can_process = 1
			//Species with PROCESS_DUO are only affected by reagents that affect both organics and synthetics, like acid and hellwater
			if((R.process_flags & ORGANIC) && (R.process_flags & SYNTHETIC) && (H.dna.species.reagent_tag & PROCESS_DUO))
				can_process = 1
	//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
	else
		if(R.process_flags != SYNTHETIC)
			can_process = 1
	return can_process

/datum/reagents/proc/reaction(atom/A, method = REAGENT_TOUCH, volume_modifier = 1)
	var/react_type
	if(isliving(A))
		react_type = "LIVING"
	else if(isturf(A))
		react_type = "TURF"
	else if(istype(A, /obj))
		react_type = "OBJ"
	else
		return

	if(react_type == "LIVING" && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(method == REAGENT_TOUCH)
			var/obj/item/organ/external/head/affecting = H.get_organ("head")
			if(affecting)
				if(chem_temp > H.dna.species.heat_level_1)
					if(H.reagent_safety_check())
						to_chat(H, "<span class='danger'>You are scalded by the hot chemicals!</span>")
						affecting.receive_damage(0, round(log(chem_temp / 50) * 10))
						H.emote("scream")
						H.adjust_bodytemperature(min(max((chem_temp - T0C) - 20, 5), 500))
				else if(chem_temp < H.dna.species.cold_level_1)
					if(H.reagent_safety_check(FALSE))
						to_chat(H, "<span class='danger'>You are frostbitten by the freezing cold chemicals!</span>")
						affecting.receive_damage(0, round(log(T0C - chem_temp / 50) * 10))
						H.emote("scream")
						H.adjust_bodytemperature(- min(max(T0C - chem_temp - 20, 5), 500))

		if(method == REAGENT_INGEST)
			if(chem_temp > H.dna.species.heat_level_1)
				to_chat(H, "<span class='danger'>You scald yourself trying to consume the boiling hot substance!</span>")
				H.adjustFireLoss(7)
				H.adjust_bodytemperature(min(max((chem_temp - T0C) - 20, 5), 700))
			else if(chem_temp < H.dna.species.cold_level_1)
				to_chat(H, "<span class='danger'>You frostburn yourself trying to consume the freezing cold substance!</span>")
				H.adjustFireLoss(7)
				H.adjust_bodytemperature(- min(max((T0C - chem_temp) - 20, 5), 700))

	for(var/datum/reagent/R in reagent_list)
		switch(react_type)
			if("LIVING")
				var/check = reaction_check(A, R)
				if(!check)
					continue
				R.reaction_mob(A, method, R.volume * volume_modifier)
			if("TURF")
				R.reaction_turf(A, R.volume * volume_modifier)
			if("OBJ")
				R.reaction_obj(A, R.volume * volume_modifier)

/datum/reagents/proc/add_reagent_list(list/list_reagents, list/data=null) // Like add_reagent but you can enter a list. Format it like this: list("toxin" = 10, "beer" = 15)
	for(var/r_id in list_reagents)
		var/amt = list_reagents[r_id]
		add_reagent(r_id, amt, data)

/datum/reagents/proc/add_reagent(reagent, amount, list/data=null, reagtemp = T20C, no_react = 0)
	if(!isnum(amount))
		return 1
	update_total()
	if(total_volume + amount > maximum_volume) amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.
	if(amount <= 0)
		return 0
	chem_temp = (chem_temp * total_volume + reagtemp * amount) / (total_volume + amount) //equalize with new chems

	for(var/A in reagent_list)

		var/datum/reagent/R = A
		if(R.id == reagent)
			R.volume += amount
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			R.on_merge(data)
			if(!no_react)
				temperature_react()
				handle_reactions()
			return 0

	var/datum/reagent/D = GLOB.chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		R.on_new(data)
		if(data)
			R.data = data

		if(isliving(my_atom))
			R.on_mob_add(my_atom) //Must occur befor it could posibly run on_mob_delete
		update_total()
		if(my_atom)
			my_atom.on_reagent_change()
		if(!no_react)
			temperature_react()
			handle_reactions()
		return 0
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	handle_reactions()

	return 1

/datum/reagents/proc/check_and_add(reagent, check, add)
	if(get_reagent_amount(reagent) < check)
		add_reagent(reagent, add)
		return TRUE

/datum/reagents/proc/remove_reagent(reagent, amount, safety)//Added a safety check for the trans_id_to

	if(!isnum(amount))
		return 1

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 0

	return 1

/datum/reagents/proc/has_reagent(reagent, amount = -1)

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			if(!amount)
				return R
			else
				if(R.volume >= amount)
					return R
				else
					return 0

	return 0

/datum/reagents/proc/get_reagent_amount(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id == reagent)
			return R.volume

	return 0

/datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if(res != "") res += ","
		res += A.name

	return res

/datum/reagents/proc/get_reagent(type)
	. = locate(type) in reagent_list

/datum/reagents/proc/remove_all_type(reagent_type, amount, strict = 0, safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount))
		return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

// Admin logging.
/datum/reagents/proc/get_reagent_ids(and_amount=0)
	var/list/stuff = list()
	for(var/datum/reagent/A in reagent_list)
		if(and_amount)
			stuff += "[get_reagent_amount(A.id)]U of [A.id]"
		else
			stuff += A.id
	return english_list(stuff)

/datum/reagents/proc/log_list()
	if(!length(reagent_list))
		return "no reagents"
	var/list/data = list()
	for(var/r in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = r
		data += "[R.id] ([round(R.volume, 0.1)]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

//helper for attack logs, tells you if all reagents are harmless or not. returns true if harmless.
/datum/reagents/proc/harmless_helper()
	for(var/datum/reagent/r in reagent_list)
		if(!r.harmless)
			return FALSE
	return TRUE

//two helper functions to preserve data across reactions (needed for xenoarch)
/datum/reagents/proc/get_data(reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
//			to_chat(world, "proffering a data-carrying reagent ([reagent_id])")
			return D.data

/datum/reagents/proc/set_data(reagent_id, new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
//			to_chat(world, "reagent data set ([reagent_id])")
			D.data = new_data

/datum/reagents/proc/copy_data(datum/reagent/current_reagent)
	if(!current_reagent || !current_reagent.data)
		return null
	if(!istype(current_reagent.data, /list))
		return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if(trans_data["viruses"])
		var/list/temp = list()
		for(var/datum/disease/v in trans_data["viruses"])
			temp.Add(v.Copy())
		trans_data["viruses"] = temp
	return trans_data

/datum/reagents/proc/generate_taste_message(minimum_percent = TASTE_SENSITIVITY_NORMAL)
	var/list/out = list()
	var/list/reagent_tastes = list() //in the form reagent_tastes["descriptor"] = strength
	//mobs should get this message when either they cannot taste, the tastes are all too weak for them to detect, or the tastes somehow don't have any strength
	var/no_taste_text = "something indescribable"
	if(minimum_percent > 100)
		return no_taste_text
	for(var/datum/reagent/R in reagent_list)
		if(!R.taste_mult)
			continue
		//nutriment carries a list of tastes that originates from the snack food that the nutriment came from
		if(istype(R, /datum/reagent/consumable/nutriment))
			var/list/nutriment_taste_data = R.data
			for(var/nutriment_taste in nutriment_taste_data)
				var/ratio = nutriment_taste_data[nutriment_taste]
				var/amount = ratio * R.taste_mult * R.volume
				if(nutriment_taste in reagent_tastes)
					reagent_tastes[nutriment_taste] += amount
				else
					reagent_tastes[nutriment_taste] = amount
		else
			var/taste_desc = R.taste_description
			var/taste_amount = R.volume * R.taste_mult
			if(taste_desc in reagent_tastes)
				reagent_tastes[taste_desc] += taste_amount
			else
				reagent_tastes[taste_desc] = taste_amount
	//deal with percentages
	//TODO: may want to sort these from strong to weak
	var/total_taste = counterlist_sum(reagent_tastes)
	if(total_taste <= 0)
		return no_taste_text
	for(var/taste_desc in reagent_tastes)
		var/percent = (reagent_tastes[taste_desc] / total_taste) * 100
		if(percent < minimum_percent) //the lower the minimum percent, the more sensitive the message is
			continue
		var/intensity_desc = "a hint of"
		if(percent > minimum_percent * 3 && percent != 100)
			intensity_desc = "a strong flavor of"
		else if(percent > minimum_percent * 2 || percent == 100)
			intensity_desc = ""

		if(intensity_desc != "")
			out += "[intensity_desc] [taste_desc]"
		else
			out += "[taste_desc]"

	return english_list(out, no_taste_text)

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
/atom/proc/create_reagents(max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src

/proc/get_random_reagent_id()	// Returns a random reagent ID minus blacklisted reagents
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing  in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.can_synth))
				random_reagents += initial(R.id)
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

/datum/reagents/proc/get_reagent_from_id(id)
	var/datum/reagent/result = null
	for(var/datum/reagent/R in reagent_list)
		if(R.id == id)
			result = R
			break
	return result

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/datum/reagents/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	QDEL_LIST(reagent_list)
	reagent_list = null
	QDEL_LIST(addiction_list)
	addiction_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
