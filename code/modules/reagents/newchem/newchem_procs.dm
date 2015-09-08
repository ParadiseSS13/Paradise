datum/reagent
	var/overdose_threshold = 0
	var/addiction_threshold = 0
	var/addiction_stage = 0
	var/overdosed = 0 // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	var/current_cycle = 0
datum/reagents
	var/chem_temp = 300
	var/addiction_tick = 1
	var/list/datum/reagent/addiction_list = new/list()

datum/reagents/proc/metabolize(var/mob/M)
	if(M)
		if(!istype(M, /mob/living))		//Non-living mobs can't metabolize reagents, so don't bother trying (runtime safety check)
			return
		chem_temp = M.bodytemperature
		handle_reactions()
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(!istype(R))
			continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			//Check if this mob's species is set and can process this type of reagent
			var/can_process = 0
			//If we somehow avoided getting a species or reagent_tag set, we'll assume we aren't meant to process ANY reagents (CODERS: SET YOUR SPECIES AND TAG!)
			if(H.species && H.species.reagent_tag)
				if((R.process_flags & SYNTHETIC) && (H.species.reagent_tag & PROCESS_SYN))		//SYNTHETIC-oriented reagents require PROCESS_SYN
					can_process = 1
				if((R.process_flags & ORGANIC) && (H.species.reagent_tag & PROCESS_ORG))		//ORGANIC-oriented reagents require PROCESS_ORG
					can_process = 1
				//Species with PROCESS_DUO are only affected by reagents that affect both organics and synthetics, like acid and hellwater
				if((R.process_flags & ORGANIC) && (R.process_flags & SYNTHETIC) && (H.species.reagent_tag & PROCESS_DUO))
					can_process = 1
			//If the mob can't process it, remove the reagent at it's normal rate without doing any addictions, overdoses, or on_mob_life() for the reagent
			if(can_process == 0)
				R.holder.remove_reagent(R.id, R.metabolization_rate)
				continue
		//We'll assume that non-human mobs lack the ability to process synthetic-oriented reagents (adjust this if we need to change that assumption)
		else
			if(R.process_flags == SYNTHETIC)
				R.holder.remove_reagent(R.id, R.metabolization_rate)
				continue
		//If you got this far, that means we can process whatever reagent this iteration is for. Handle things normally from here.
		if(M && R)
			if(R.volume >= R.overdose_threshold && !R.overdosed && R.overdose_threshold > 0)
				R.overdosed = 1
				M << "<span class = 'userdanger'>You feel like you took too much [R.name]!</span>"
				R.overdose_start(M)
			if(R.volume >= R.addiction_threshold && !is_type_in_list(R, addiction_list) && R.addiction_threshold > 0)
				var/datum/reagent/new_reagent = new R.type()
				addiction_list.Add(new_reagent)
			if(R.overdosed)
				R.overdose_process(M)
			if(is_type_in_list(R,addiction_list))
				for(var/datum/reagent/addicted_reagent in addiction_list)
					if(istype(R, addicted_reagent))
						addicted_reagent.addiction_stage = -15 // you're satisfied for a good while.
			R.on_mob_life(M)
	if(addiction_tick == 6)
		addiction_tick = 1
		for(var/A in addiction_list)
			var/datum/reagent/R = A
			if(M && R)
				if(R.addiction_stage <= 0)
					R.addiction_stage++
				if(R.addiction_stage > 0 && R.addiction_stage <= 10)
					R.addiction_act_stage1(M)
					R.addiction_stage++
				if(R.addiction_stage > 10 && R.addiction_stage <= 20)
					R.addiction_act_stage2(M)
					R.addiction_stage++
				if(R.addiction_stage > 20 && R.addiction_stage <= 30)
					R.addiction_act_stage3(M)
					R.addiction_stage++
				if(R.addiction_stage > 30 && R.addiction_stage <= 40)
					R.addiction_act_stage4(M)
					R.addiction_stage++
				if(R.addiction_stage > 40)
					M << "<span class = 'notice'>You feel like you've gotten over your need for [R.name].</span>"
					addiction_list.Remove(R)
	addiction_tick++
	update_total()

datum/reagents/proc/reagent_on_tick()
	for(var/datum/reagent/R in reagent_list)
		R.on_tick()
	return

datum/reagents/proc/check_ignoreslow(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("morphine"))
			return 1
		else
			M.status_flags &= ~IGNORESLOWDOWN

datum/reagents/proc/check_gofast(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("unholywater")||M.reagents.has_reagent("nuka_cola")||M.reagents.has_reagent("stimulative_agent"))
			return 1
		else
			M.status_flags &= ~GOTTAGOFAST

datum/reagents/proc/check_goreallyfast(var/mob/M)
	if(istype(M, /mob))
		if(M.reagents.has_reagent("methamphetamine"))
			return 1
		else
			M.status_flags &= ~GOTTAGOREALLYFAST

// Called every time reagent containers process.
datum/reagent/proc/on_tick(var/data)
	return

// Called when the reagent container is hit by an explosion
datum/reagent/proc/on_ex_act(var/severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
datum/reagent/proc/overdose_process(var/mob/living/M as mob)
	return

datum/reagent/proc/overdose_start(var/mob/living/M as mob)
	return

datum/reagent/proc/addiction_act_stage1(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'notice'>You feel like some [name] right about now.</span>"
	return

datum/reagent/proc/addiction_act_stage2(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'notice'>You feel like you need [name]. You just can't get enough.</span>"
	return

datum/reagent/proc/addiction_act_stage3(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'danger'>You have an intense craving for [name].</span>"
	return

datum/reagent/proc/addiction_act_stage4(var/mob/living/M as mob)
	if(prob(30))
		M << "<span class = 'danger'>You're not feeling good at all! You really need some [name].</span>"
	return

/datum/reagent/proc/reagent_deleted()
	return