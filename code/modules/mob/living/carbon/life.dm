/mob/living/carbon/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if (!contents.Find(internal))
			internal = null
		if (!wear_mask || !(wear_mask.flags & MASKINTERNALS) )
			internal = null
		if(internal)
			if (internals)
				internals.icon_state = "internal1"
			return internal.remove_air_volume(volume_needed)
		else
			if (internals)
				internals.icon_state = "internal0"
	return

/mob/living/carbon/proc/handle_addictions()
	if(!addictive_personality)
		return
	if(!reagents)
		CRASH("[src] does not have reagents defined somehow!")
	if(!reagents.addiction_list || !reagents.addiction_list.len)
		return

	if(status_flags & GODMODE)	return 0	//godmode

	if(reagents.addiction_tick == 6)
		reagents.addiction_tick = 1

		var/fixer = 0
		for(var/datum/reagent/R in reagents.reagent_list)
			if((R.id == "fixer") && (R.volume < R.overdose_threshold))		//Fixer doesn't function while overdosed
				fixer = 1

		for(var/AR in reagents.addiction_list)
			if(reagents.get_reagent_amount(AR))
				continue	//Don't handle withdrawal or addiction decay if they are using the drug

			var/datum/reagent/R = chemical_reagents_list[AR]
			if(!R || R.id != AR)
				continue	//something didn't work with this one
			var/progress = reagents.addiction_list[AR]
			var/threshold = R.addiction_threshold

			if(!fixer)		//Only handle withdrawal if they aren't on Fixer
				if(progress >= (4*threshold))
					R.addiction_act_stage4(src)
				else if(progress >= (3*threshold))
					R.addiction_act_stage3(src)
				else if(progress >= (2*threshold))
					R.addiction_act_stage2(src)
				else if(progress >= (threshold))
					R.addiction_act_stage1(src)

			update_addictions(AR, ADDICT_DECAY)

	reagents.addiction_tick++
	updatehealth()
	return
