/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/metabolization_rate = REAGENTS_METABOLISM
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/shock_reduction = 0
	var/heart_rate_increase = 0
	var/heart_rate_decrease = 0
	var/heart_rate_stop = 0
	var/penetrates_skin = FALSE //Whether or not a reagent penetrates the skin
	//Processing flags, defines the type of mobs the reagent will affect
	//By default, all reagents will ONLY affect organics, not synthetics. Re-define in the reagent's definition if the reagent is meant to affect synths
	var/process_flags = ORGANIC
	var/can_synth = TRUE //whether or not a mech syringe gun and synthesize this reagent
	var/overdose_threshold = 0
	var/addiction_chance = 0
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = FALSE // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	var/current_cycle = 1
	var/drink_icon = null
	var/drink_name = "Glass of ..what?"
	var/drink_desc = "You can't really tell what this is."
	var/taste_strength = 1 //how easy it is to taste - the more the easier
	var/taste_message = "bitterness" //life's bitter by default. Cool points for using a span class for when you're tasting <span class='userdanger'>LIQUID FUCKING DEATH</span>

/datum/reagent/Destroy()
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method = TOUCH, volume) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
	if(holder)  //for catching rare runtimes
		if(method == TOUCH && penetrates_skin)
			var/block  = M.get_permeability_protection()
			var/amount = round(volume * (1 - block), 0.1)
			if(M.reagents)
				if(amount >= 1)
					M.reagents.add_reagent(id, amount)

		if(method == INGEST) //Yes, even Xenos can get addicted to drugs.
			var/can_become_addicted = M.reagents.reaction_check(M, src)

			if(can_become_addicted)
				if(prob(addiction_chance) && !is_type_in_list(src, M.reagents.addiction_list))
					to_chat(M, "<span class='danger'>You suddenly feel invigorated and guilty...</span>")
					var/datum/reagent/new_reagent = new type()
					new_reagent.last_addiction_dose = world.timeofday
					M.reagents.addiction_list.Add(new_reagent)
				else if(is_type_in_list(src, M.reagents.addiction_list))
					to_chat(M, "<span class='notice'>You feel slightly better, but for how long?</span>")
					for(var/A in M.reagents.addiction_list)
						var/datum/reagent/AD = A
						if(AD && istype(AD, src))
							AD.last_addiction_dose = world.timeofday
							AD.addiction_stage = 1
		return TRUE

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(id, metabolization_rate * M.metabolism_efficiency * M.digestion_ratio) //By default it slowly disappears.
	return STATUS_UPDATE_NONE

/datum/reagent/proc/on_mob_death(mob/living/M)	//use this to have chems have a "death-triggered" effect
	return

// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/M)
	return

/datum/reagent/proc/on_move(mob/M)
	return

// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/datum/reagent/proc/on_update(atom/A)
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
	var/update_flags = STATUS_UPDATE_NONE
	if(effect <= 8)
		update_flags |= (M.adjustToxLoss(severity, FALSE) ? STATUS_UPDATE_HEALTH : STATUS_UPDATE_NONE)
	return list(effect, update_flags)

/datum/reagent/proc/overdose_start(mob/living/M)
	return

/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(prob(8))
		M.emote("shiver")
	if(prob(8))
		M.emote("sneeze")
	if(prob(4))
		to_chat(M, "<span class='notice'>You feel a dull headache.</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(prob(8))
		M.emote("twitch_s")
	if(prob(8))
		M.emote("shiver")
	if(prob(4))
		to_chat(M, "<span class='warning'>You begin craving [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(prob(8))
		M.emote("twitch")
	if(prob(4))
		to_chat(M, "<span class='warning'>You have the strong urge for some [name]!</span>")
	if(prob(4))
		to_chat(M, "<span class='warning'>You REALLY crave some [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage5(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(8))
		M.emote("twitch")
	if(prob(6))
		to_chat(M, "<span class='warning'>Your stomach lurches painfully!</span>")
		M.visible_message("<span class='warning'>[M] gags and retches!</span>")
		update_flags |= M.Stun(rand(2,4), FALSE)
		update_flags |= M.Weaken(rand(2,4), FALSE)
	if(prob(5))
		to_chat(M, "<span class='warning'>You feel like you can't live without [name]!</span>")
	if(prob(5))
		to_chat(M, "<span class='warning'>You would DIE for some [name] right now!</span>")
	return update_flags

/datum/reagent/proc/fakedeath(mob/living/M)
	if(M.status_flags & FAKEDEATH)
		return
	if(!(M.status_flags & CANPARALYSE))
		return
	if(M.mind && M.mind.changeling && M.mind.changeling.regenerating) //no messing with changeling's fake death
		return
	M.visible_message("<B>[M]</B> seizes up and falls limp, [M.p_their()] eyes dead and lifeless...") //so you can't trigger deathgasp emote on people. Edge case, but necessary.
	M.status_flags |= FAKEDEATH
	M.update_stat("fakedeath reagent")
	M.med_hud_set_health()
	M.med_hud_set_status()

/datum/reagent/proc/fakerevive(mob/living/M)
	if(!(M.status_flags & FAKEDEATH))
		return
	if(M.mind && M.mind.changeling && M.mind.changeling.regenerating)
		return
	if(M.resting)
		M.StopResting()
	M.status_flags &= ~(FAKEDEATH)
	M.update_stat("fakedeath reagent end")
	M.med_hud_set_status()
	M.med_hud_set_health()
	if(M.healthdoll)
		M.healthdoll.cached_healthdoll_overlays.Cut()
	if(M.dna.species)
		M.dna.species.handle_hud_icons(M)