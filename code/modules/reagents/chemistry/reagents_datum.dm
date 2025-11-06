/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	/// A reference to the holder the chemical is 'in'.
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/metabolization_rate = REAGENTS_METABOLISM
	/// The color of the agent outside of containers.
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/shock_reduction = 0
	var/view_true_health = FALSE // Determines if a painkiller messes with someone seeing their actual health on the health doll or not
	var/heart_rate_increase = 0
	var/heart_rate_decrease = 0
	var/heart_rate_stop = 0
	var/penetrates_skin = FALSE //Whether or not a reagent penetrates the skin
	//Processing flags, defines the type of mobs the reagent will affect
	//By default, all reagents will ONLY affect organics, not synthetics. Re-define in the reagent's definition if the reagent is meant to affect synths
	var/process_flags = ORGANIC
	var/harmless = FALSE //flag used for attack logs
	var/overdose_threshold = 0
	var/addiction_chance = 0
	var/addiction_chance_additional = 100 // If we want to lower the chance of addiction even more, set this
	var/addiction_threshold = 0 // How much of a chem do we have to absorb before we can start rolling for its ill effects?
	var/minor_addiction = FALSE
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = FALSE // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	/// If this variable is true, chemicals will continue to process in mobs when overdosed.
	var/allowed_overdose_process = FALSE
	var/current_cycle = 1
	var/drink_icon = null
	var/drink_name = "Glass of ..what?"
	var/drink_desc = "You can't really tell what this is."
	var/taste_mult = 1 //how easy it is to taste - the more the easier
	var/taste_description = "metaphorical salt"
	/// how quickly the addiction threshold var decays
	var/addiction_decay_rate = 0.01

	// Which department's (if any) reagent goals this is eligible for.
	// Must match the values used by request consoles.
	var/goal_department = "Unknown"
	// How difficult is this chemical for the department to make?
	// Affects the quantity of the reagent that is requested by CC.
	var/goal_difficulty = REAGENT_GOAL_SKIP

	/// At what temperature does this reagent burn? Currently only used for chemical flamethrowers
	var/burn_temperature = T0C
	/// How long would a fire burn using this reagent? Currently only used for chemical flamethrowers
	var/burn_duration = 30 SECONDS
	/// How many firestacks will the reagent apply when it is burning? Currently only used for chemical flamethrowers
	var/fire_stack_applications = 1
	/// If we burn in a fire, what color do we have?
	var/burn_color

/datum/reagent/Destroy()
	. = ..()
	holder = null
	if(islist(data))
		data.Cut()
	data = null

/// By default do nothing
/datum/reagent/proc/reaction_temperature(exposed_temperature, exposed_volume)
	return

/// By default do nothing
/datum/reagent/proc/reaction_radiation(amount, emission_type)
	return

/**
 * React with a mob.
 *
 * The method var can be either `REAGENT_TOUCH` or `REAGENT_INGEST`. Some
 * reagents transfer on touch, others don't; dependent on if they penetrate the
 * skin or not. You'll want to put stuff like acid-facemelting in here. Should
 * only ever be called, directly, on living mobs.
 */
/datum/reagent/proc/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume, show_message = TRUE)
	if(!holder)  //for catching rare runtimes
		return
	if(method == REAGENT_TOUCH && penetrates_skin)
		var/block  = M.get_permeability_protection()
		var/amount = round(volume * (1 - block), 0.1)
		if(M.reagents)
			if(amount >= 1)
				M.reagents.add_reagent(id, amount)

	if(method == REAGENT_INGEST) //Yes, even Xenos can get addicted to drugs.
		var/can_become_addicted = M.reagents.reaction_check(M, src)
		if(can_become_addicted)
			if(is_type_in_list(src, M.reagents.addiction_list))
				to_chat(M, "<span class='notice'>You feel slightly better, but for how long?</span>") //sate_addiction handles this now, but kept this for the feed back.
	var/mob/living/carbon/C = M
	if(C.mind?.has_antag_datum(/datum/antagonist/vampire))
		return
	if(method == REAGENT_INGEST && istype(C) && C.get_blood_id() == id)
		if(id == "blood" && !(data?["blood_type"] in get_safe_blood(C.dna?.blood_type)) || C.dna?.species.name != data?["species"] && (data?["species_only"] || C.dna?.species.own_species_blood))
			C.reagents.add_reagent("toxin", volume * 0.5)
		else
			if(data?["blood_type"] != BLOOD_TYPE_FAKE_BLOOD)
				C.blood_volume = min(C.blood_volume + round(volume, 0.1), BLOOD_VOLUME_NORMAL)
		// This does not absorb the blood we are getting in *this* reagent transfer operation,
		// (because the actual transfer has not happened yet. Because reasons) but it does process
		// the blood already in the mob.
		// This one only matters if the mob is dead.
		M.absorb_blood()

/**
 * React with an object.
 */
/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/**
 * React with a turf.
 *
 * You'll want to put stuff like extra slippery floors for lube or something in here.
 */
/datum/reagent/proc/reaction_turf(turf/T, volume, color)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	var/total_depletion_rate = metabolization_rate * M.metabolism_efficiency // Cache it

	handle_addiction(M, total_depletion_rate)
	sate_addiction(M)

	holder.remove_reagent(id, total_depletion_rate) //By default it slowly disappears.
	return STATUS_UPDATE_NONE

/datum/reagent/proc/on_mob_overdose_life(mob/living/M) //We want to drain reagents but not do the entire mob life.
	current_cycle++
	var/total_depletion_rate = metabolization_rate * M.metabolism_efficiency // Cache it

	handle_addiction(M, total_depletion_rate)
	sate_addiction(M)

	holder.remove_reagent(id, total_depletion_rate) //By default it slowly disappears.
	return STATUS_UPDATE_NONE

/datum/reagent/proc/handle_addiction(mob/living/M, consumption_rate)
	if(!addiction_chance)
		return
	M.reagents.addiction_threshold_accumulated[type] += consumption_rate
	if(is_type_in_list(src, M.reagents.addiction_list))
		return
	var/current_threshold_accumulated = M.reagents.addiction_threshold_accumulated[type]

	if(addiction_threshold < current_threshold_accumulated && prob(addiction_chance) && prob(addiction_chance_additional))
		to_chat(M, "<span class='danger'>You suddenly feel invigorated and guilty...</span>")
		var/datum/reagent/new_reagent = new type()
		new_reagent.last_addiction_dose = world.timeofday
		M.reagents.addiction_list.Add(new_reagent)

/datum/reagent/proc/sate_addiction(mob/living/M) //reagents sate their own withdrawals
	if(is_type_in_list(src, M.reagents.addiction_list))
		for(var/A in M.reagents.addiction_list)
			var/datum/reagent/AD = A
			if(AD && istype(AD, src))
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
		log_game("Flashfire reaction ([holder.my_atom], reagent type: [name]) at [COORD(holder.my_atom.loc)]. Last touched by: [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"].")
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

/datum/reagent/proc/overdose_end(mob/living/M)
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
		if(prob(8))
			M.emote("shiver")
		if(prob(4))
			to_chat(M, "<span class='warning'>Your head hurts.</span>")
		if(prob(4))
			to_chat(M, "<span class='warning'>You begin craving [name]!</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(minor_addiction)
		if(prob(8))
			to_chat(M, "<span class='notice'>You could really go for some [name] right now.</span>")
	else
		if(prob(8))
			M.emote("twitch")
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
			M.emote(pick("twitch"))
	else
		if(prob(6))
			to_chat(M, "<span class='warning'>Your stomach lurches painfully!</span>")
			M.visible_message("<span class='warning'>[M] gags and retches!</span>")
			M.Weaken(rand(4 SECONDS, 8 SECONDS))
		if(prob(8))
			M.emote(pick("twitch", "twitch_s", "shiver"))
		if(prob(4))
			to_chat(M, "<span class='warning'>Your head is killing you!</span>")
		if(prob(5))
			to_chat(M, "<span class='warning'>You feel like you can't live without [name]!</span>")
		else if(prob(5))
			to_chat(M, "<span class='warning'>You would DIE for some [name] right now!</span>")
	return update_flags

/datum/reagent/proc/fakedeath(mob/living/M)
	if(HAS_TRAIT(M, TRAIT_FAKEDEATH))
		return
	if(!(M.status_flags & CANPARALYSE))
		return
	M.emote("deathgasp")
	ADD_TRAIT(M, TRAIT_FAKEDEATH, id)
	M.updatehealth("fakedeath reagent")

/datum/reagent/proc/fakerevive(mob/living/M)
	if(!HAS_TRAIT_FROM(M, TRAIT_FAKEDEATH, id))
		return
	if(IS_HORIZONTAL(M))
		M.stand_up()
	REMOVE_TRAIT(M, TRAIT_FAKEDEATH, id)
	if(M.healthdoll)
		M.healthdoll.cached_healthdoll_overlays.Cut()
	M.updatehealth("fakedeath reagent end")

/datum/reagent/proc/has_heart_rate_increase()
	return heart_rate_increase
