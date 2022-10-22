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
	var/harmless = FALSE //flag used for attack logs
	var/can_synth = TRUE //whether or not a mech syringe gun and synthesize this reagent
	var/overdose_threshold = 0
	var/addiction_chance = 0
	var/addiction_chance_additional = 100 // If we want to lower the chance of addiction even more, set this
	var/addiction_threshold = 0 // How much of a chem do we have to absorb before we can start rolling for its ill effects?
	var/minor_addiction = FALSE
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = FALSE // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	var/current_cycle = 1
	var/drink_icon = null
	var/drink_name = "Glass of ..what?"
	var/drink_desc = "You can't really tell what this is."
	var/taste_mult = 1 //how easy it is to taste - the more the easier
	var/taste_description = "metaphorical salt"
	var/addict_supertype = /datum/reagent

/datum/reagent/New()
	addict_supertype = type

/datum/reagent/Destroy()
	. = ..()
	holder = null
	if(islist(data))
		data.Cut()
	data = null

/datum/reagent/proc/reaction_temperature(exposed_temperature, exposed_volume) //By default we do nothing.
	return

/datum/reagent/proc/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume, show_message = TRUE) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
	if(holder)  //for catching rare runtimes
		if(method == REAGENT_TOUCH && penetrates_skin)
			var/block  = M.get_permeability_protection()
			var/amount = round(volume * (1 - block), 0.1)
			if(M.reagents)
				if(amount >= 1)
					M.reagents.add_reagent(id, amount)

		if(method == REAGENT_INGEST) //Yes, even Xenos can get addicted to drugs.
			var/can_become_addicted = M.reagents.reaction_check(M, src)
			if(can_become_addicted)
				if(count_by_type(M.reagents.addiction_list, addict_supertype) > 0)
					to_chat(M, "<span class='notice'>You feel slightly better, but for how long?</span>") //sate_addiction handles this now, but kept this for the feed back.
		return TRUE

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume, color)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	var/total_depletion_rate = metabolization_rate * M.metabolism_efficiency * M.digestion_ratio // Cache it

	handle_addiction(M, total_depletion_rate)
	sate_addiction(M)

	holder.remove_reagent(id, total_depletion_rate) //By default it slowly disappears.
	return STATUS_UPDATE_NONE

/datum/reagent/proc/handle_addiction(mob/living/M, consumption_rate)
	if(addiction_chance && count_by_type(M.reagents.addiction_list, addict_supertype) < 1)
		var/datum/reagent/new_reagent = new addict_supertype()
		M.reagents.addiction_threshold_accumulated[new_reagent.id] += consumption_rate
		var/current_threshold_accumulated = M.reagents.addiction_threshold_accumulated[new_reagent.id]

		if(addiction_threshold < current_threshold_accumulated && prob(addiction_chance) && prob(addiction_chance_additional))
			to_chat(M, "<span class='danger'>You suddenly feel invigorated and guilty...</span>")
			new_reagent.last_addiction_dose = world.timeofday
			M.reagents.addiction_list.Add(new_reagent)

/datum/reagent/proc/sate_addiction(mob/living/M) //reagents sate their own withdrawals
	for(var/datum/reagent/AD in M.reagents.addiction_list)
		if(AD && istype(AD, addict_supertype))
			AD.last_addiction_dose = world.timeofday
			AD.addiction_stage = 1

/datum/reagent/proc/on_mob_death(mob/living/M)	//use this to have chems have a "death-triggered" effect
	return

/**
 * Flashfire is a proc used to log fire causing chemical reactions.
 *
 * Call this whenever you have a chemical reaction that makes fire flashes.
 * Arguments:
 * * holder: the beaker that the reagent is in
 * * name: name of the reagent / reaction
 */
/proc/fire_flash_log(datum/reagents/holder, name)
	if(!holder.my_atom)
		return
	if(holder.my_atom.fingerprintslast)
		var/mob/M = get_mob_by_key(holder.my_atom.fingerprintslast)
		add_attack_logs(M, COORD(holder.my_atom.loc), "Caused a flashfire reaction of [name]. Last associated key is [holder.my_atom.fingerprintslast]", ATKLOG_FEW)
	holder.my_atom.investigate_log("A Flashfire reaction, (reagent type [name]) last touched by [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"], triggered at [COORD(holder.my_atom.loc)].", INVESTIGATE_BOMB)

// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L)
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
/datum/reagent/process()
	if(!holder || holder.flags & REAGENT_NOREACT)
		return FALSE
	return TRUE

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
	if(minor_addiction)
		if(prob(4))
			to_chat(M, "<span class='notice'>You briefly think about getting some more [name].</span>")
	else
		if(prob(8))
			M.emote("shiver")
			M.Jitter(60)
		if(prob(8))
			M.emote("sneeze")
		if(prob(4))
			to_chat(M, "<span class='notice'>You feel a dull headache.</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(minor_addiction)
		if(prob(4))
			to_chat(M, "<span class='notice'>You could really go for some [name] right now.</span>")
	else
		if(prob(8))
			M.emote("twitch_s")
			M.Jitter(80)
		if(prob(8))
			M.emote("shiver")
			M.Jitter(60)
		if(prob(4))
			to_chat(M, "<span class='warning'>Your head hurts.</span>")
		if(prob(4))
			to_chat(M, "<span class='warning'>You begin craving [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(minor_addiction)
		if(prob(8))
			to_chat(M, "<span class='notice'>You could really go for some [name] right now.</span>")
		if(prob(4))
			M.emote("twitch")
			M.Jitter(80)
	else
		if(prob(8))
			M.emote("twitch")
			M.Jitter(80)
		if(prob(4))
			to_chat(M, "<span class='warning'>You have a pounding headache.</span>")
		if(prob(4))
			to_chat(M, "<span class='warning'>You have the strong urge for some [name]!</span>")
		else if(prob(4))
			to_chat(M, "<span class='warning'>You REALLY crave some [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage5(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(minor_addiction)
		if(prob(8))
			to_chat(M, "<span class='notice'>You can't stop thinking about [name]...</span>")
		if(prob(4))
			M.emote(pick("twitch", "twitch_s", "shiver"))
			M.Jitter(80)
	else
		if(prob(6))
			to_chat(M, "<span class='warning'>Your stomach lurches painfully!</span>")
			M.visible_message("<span class='warning'>[M] gags and retches!</span>")
			update_flags |= M.Stun(rand(2,4), FALSE)
			update_flags |= M.Weaken(rand(2,4), FALSE)
		if(prob(8))
			M.emote(pick("twitch", "twitch_s", "shiver"))
			M.Jitter(80)
		if(prob(4))
			to_chat(M, "<span class='warning'>Your head is killing you!</span>")
		if(prob(5))
			to_chat(M, "<span class='warning'>You feel like you can't live without [name]!</span>")
		else if(prob(5))
			to_chat(M, "<span class='warning'>You would DIE for some [name] right now!</span>")
	return update_flags

/datum/reagent/proc/fakedeath(mob/living/M)
	if(M.status_flags & FAKEDEATH)
		return
	if(!(M.status_flags & CANPARALYSE))
		return
	if(M.mind && M.mind.changeling && M.mind.changeling.regenerating) //no messing with changeling's fake death
		return
	M.emote("deathgasp")
	M.status_flags |= FAKEDEATH
	M.updatehealth("fakedeath reagent")

/datum/reagent/proc/fakerevive(mob/living/M)
	if(!(M.status_flags & FAKEDEATH))
		return
	if(M.mind && M.mind.changeling && M.mind.changeling.regenerating)
		return
	if(M.resting)
		M.StopResting()
	M.status_flags &= ~(FAKEDEATH)
	if(M.healthdoll)
		M.healthdoll.cached_healthdoll_overlays.Cut()
	M.updatehealth("fakedeath reagent end")
