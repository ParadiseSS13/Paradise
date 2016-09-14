#define ADDICTION_TIME 4800 //8 minutes

/datum/reagent
	var/overdose_threshold = 0
	var/addiction_chance = 0
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = 0 // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	var/current_cycle = 1

/datum/reagents/proc/metabolize(mob/living/M)
	if(M)
		chem_temp = M.bodytemperature
		handle_reactions()
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
			if(H.species && H.species.reagent_tag)
				if((R.process_flags & SYNTHETIC) && (H.species.reagent_tag & PROCESS_SYN))		//SYNTHETIC-oriented reagents require PROCESS_SYN
					can_process = 1
				if((R.process_flags & ORGANIC) && (H.species.reagent_tag & PROCESS_ORG))		//ORGANIC-oriented reagents require PROCESS_ORG
					can_process = 1
				//Species with PROCESS_DUO are only affected by reagents that affect both organics and synthetics, like acid and hellwater
				if((R.process_flags & ORGANIC) && (R.process_flags & SYNTHETIC) && (H.species.reagent_tag & PROCESS_DUO))
					can_process = 1

			//If handle_reagents returns 0, it's doing the reagent removal on its own
			var/species_handled = !(H.species.handle_reagents(H, R))
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
			R.on_mob_life(M)
			if(R.volume >= R.overdose_threshold && !R.overdosed && R.overdose_threshold > 0)
				R.overdosed = 1
				R.overdose_start(M)
			if(R.volume < R.overdose_threshold && R.overdosed)
				R.overdosed = 0
			if(R.overdosed)
				R.overdose_process(M, R.volume >= R.overdose_threshold*2 ? 2 : 1)

	for(var/A in addiction_list)
		var/datum/reagent/R = A
		if(M && R)
			if(R.addiction_stage < 5)
				if(prob(5))
					R.addiction_stage++
			switch(R.addiction_stage)
				if(1)
					R.addiction_act_stage1(M)
				if(2)
					R.addiction_act_stage2(M)
				if(3)
					R.addiction_act_stage3(M)
				if(4)
					R.addiction_act_stage4(M)
				if(5)
					R.addiction_act_stage5(M)
			if(prob(20) && (world.timeofday > (R.last_addiction_dose + ADDICTION_TIME))) //Each addiction lasts 8 minutes before it can end
				to_chat(M, "<span class='notice'>You no longer feel reliant on [R.name]!</span>")
				addiction_list.Remove(R)
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


/datum/reagents/proc/reagent_on_tick()
	for(var/datum/reagent/R in reagent_list)
		R.on_tick()
	return

// Called every time reagent containers process.
/datum/reagent/proc/on_tick(data)
	return

// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M, severity)
	var/effect = rand(1, 100) - severity
	if(effect <= 8)
		M.adjustToxLoss(severity)
	return effect

/datum/reagent/proc/overdose_start(mob/living/M)
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	return

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(prob(8))
		M.emote("shiver")
	if(prob(8))
		M.emote("sneeze")
	if(prob(4))
		to_chat(M, "<span class='notice'>You feel a dull headache.</span>")

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(prob(8))
		M.emote("twitch_s")
	if(prob(8))
		M.emote("shiver")
	if(prob(4))
		to_chat(M, "<span class='warning'>You begin craving [name]!</span>")

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(prob(8))
		M.emote("twitch")
	if(prob(4))
		to_chat(M, "<span class='warning'>You have the strong urge for some [name]!</span>")
	if(prob(4))
		to_chat(M, "<span class='warning'>You REALLY crave some [name]!</span>")

/datum/reagent/proc/addiction_act_stage5(mob/living/M)
	if(prob(8))
		M.emote("twitch")
	if(prob(6))
		to_chat(M, "<span class='warning'>Your stomach lurches painfully!</span>")
		M.visible_message("<span class='warning'>[M] gags and retches!</span>")
		M.Stun(rand(2,4))
		M.Weaken(rand(2,4))
	if(prob(5))
		to_chat(M, "<span class='warning'>You feel like you can't live without [name]!</span>")
	if(prob(5))
		to_chat(M, "<span class='warning'>You would DIE for some [name] right now!</span>")

/datum/reagent/proc/reagent_deleted()
	return

var/list/chemical_mob_spawn_meancritters = list() // list of possible hostile mobs
var/list/chemical_mob_spawn_nicecritters = list() // and possible friendly mobs
/datum/chemical_reaction/proc/chemical_mob_spawn(datum/reagents/holder, amount_to_spawn, reaction_name, mob_faction = "chemicalsummon")
	if(holder && holder.my_atom)
		if(chemical_mob_spawn_meancritters.len <= 0 || chemical_mob_spawn_nicecritters.len <= 0)
			for(var/T in typesof(/mob/living/simple_animal))
				var/mob/living/simple_animal/SA = T
				switch(initial(SA.gold_core_spawnable))
					if(CHEM_MOB_SPAWN_HOSTILE)
						chemical_mob_spawn_meancritters += T
					if(CHEM_MOB_SPAWN_FRIENDLY)
						chemical_mob_spawn_nicecritters += T
		var/atom/A = holder.my_atom
		var/turf/T = get_turf(A)
		var/area/my_area = get_area(T)
		var/message = "A [reaction_name] reaction has occured in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>)"
		message += " (<A HREF='?_src_=vars;Vars=[A.UID()]'>VV</A>)"

		var/mob/M = get(A, /mob)
		if(M)
			message += " - Carried By: [key_name_admin(M)](<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>)"
		else
			message += " - Last Fingerprint: [(A.fingerprintslast ? A.fingerprintslast : "N/A")]"

		message_admins(message, 0, 1)

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/C in viewers(get_turf(holder.my_atom), null))
			C.flash_eyes()
		for(var/i = 1, i <= amount_to_spawn, i++)
			var/chosen
			if(reaction_name == "Friendly Gold Slime")
				chosen = pick(chemical_mob_spawn_nicecritters)
			else
				chosen = pick(chemical_mob_spawn_meancritters)
			var/mob/living/simple_animal/C = new chosen
			C.faction |= mob_faction
			C.forceMove(get_turf(holder.my_atom))
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))

#undef ADDICTION_TIME