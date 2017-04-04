/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/metabolization_rate = REAGENTS_METABOLISM
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)
	var/shock_reduction = 0
	var/heart_rate_increase = 0
	var/heart_rate_decrease = 0
	var/heart_rate_stop = 0
	var/penetrates_skin = 0 //Whether or not a reagent penetrates the skin
	var/can_grow_in_plants = 1	//Determines if the reagent can be grown in plants, 0 means it cannot be grown
	//Processing flags, defines the type of mobs the reagent will affect
	//By default, all reagents will ONLY affect organics, not synthetics. Re-define in the reagent's definition if the reagent is meant to affect synths
	var/process_flags = ORGANIC
	var/admin_only = 0
	var/can_synth = 1 //whether or not a mech syringe gun and synthesize this reagent
	var/overdose_threshold = 0
	var/addiction_chance = 0
	var/addiction_stage = 1
	var/last_addiction_dose = 0
	var/overdosed = 0 // You fucked up and this is now triggering it's overdose effects, purge that shit quick.
	var/current_cycle = 1
	var/drink_icon = null
	var/drink_name = "Glass of ..what?"
	var/drink_desc = "You can't really tell what this is."

/datum/reagent/Destroy()
	. = ..()
	holder = null

/datum/reagent/proc/reaction_mob(mob/living/M, method=TOUCH, volume) //Some reagents transfer on touch, others don't; dependent on if they penetrate the skin or not.
	if(holder)  //for catching rare runtimes
		if(method == TOUCH && penetrates_skin)
			var/block  = M.get_permeability_protection()
			var/amount = round(volume * (1.0 - block), 0.1)
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
		return 1

/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/datum/reagent/proc/on_mob_life(mob/living/M)
	current_cycle++
	holder.remove_reagent(id, metabolization_rate * M.metabolism_efficiency * M.digestion_ratio) //By default it slowly disappears.

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


/****************************************/
/*	on_species_life Proc Declarations	*/
/****************************************/
/*
*	Override these procs on a reagent if a certain species should be affected differently by a certain reagent instead of the normal on_mob_life for that reagent
*	If you don't override the proc, it instead just calls on_mob_life for that reagent to run normally since you didn't want a special interaction
*	NOTE: These only apply to on_mob_life effects. If you want to have a unique effect to reaction_mob or something, these procs won't help you.
*
*	>> IMPORTANT! << Make sure you include this code in the species reagent proc if you override it:
*
*			H.reagents.remove_reagent(id, metabolization_rate)
*
*	If you don't include that, the reagent won't deplete normally!
*
*	You may be asking:
*		"But why not just include that in the species' handle_reagents proc?"
*	That's because then you'll remove twice as much (which is bad!) when you don't override this proc, since on_mob_life removes the reagent through a ..() call!
*	So don't be a dolt and try removing the reagent in handle_reagents okay?
*
*	Example:
*
*	/datum/reagent/fliptonium/on_vulpkanin_life(mob/living/carbon/human/H)
*		to_chat(H, "<span class='notice'>Roll over, Fido!</span>")
*		H.SpinAnimation(speed = 11, loops = -1)
*		to_chat(H, "<span class='notice'>Good doggo!</span>")
*		H.reagents.remove_reagent(id, metabolization_rate)
*
*	This example override for vulpkanin displays two messages and makes them flip once, then removes the normal amount of fliptonium every cycle.
*	It probably would also infuriate them since it does it EVERY time they metabolize the chemical. (honk!)
*
*	Additionally, including ..() in your override will make it call the normal on_mob_life since the base version of the proc calls it (as seen below).
*	Be careful when doing this, as you can end up with some weird behavior if you don't pay attention to what both versions' effects do!
*	However, if your override does all the same things as the base version and a little more, this can save you some copied lines. JUST BE SMART ABOUT IT!
*
*	Below are the initial defines for the per-species procs. Included are procs for every species except Human, since Human is meant to be the base-line/generic effect
*	I realize we might not want to provide effects for all of the species below, but I defined the procs now in case we want to in the future.
*		You're welcome future coder who wants to make banana juice act like omnizine for ONLY chimps but not farwa (even though both are monkey species types).
*	Additionally, if you add a new species, you will want to add a new proc for them so they can handle their own reagent effects rather than mooch of some other species.
*/

//Station species procs (humans aren't included since they are considered the "baseline" and on_mob_life should thus be the effect on humans)
/datum/reagent/proc/on_tajaran_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_vulpkanin_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_skrell_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_unathi_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_diona_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_grey_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_kidan_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_machine_person_life(mob/living/carbon/human/H)		//aka IPCs
	on_mob_life(H)

/datum/reagent/proc/on_slime_person_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_vox_life(mob/living/carbon/human/H)					//normal station vox
	on_mob_life(H)

/datum/reagent/proc/on_plasmaman_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_drask_life(mob/living/carbon/human/H)
	on_mob_life(H)


//Admin-only species procs
/datum/reagent/proc/on_skeleton_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_wryn_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_nucleation_life(mob/living/carbon/human/H)
	on_mob_life(H)

/datum/reagent/proc/on_vox_armalis_life(mob/living/carbon/human/H)			//big admin vox (they might not be affected by a reagent the same way as normal vox)
	on_mob_life(H)


//Other species procs
/datum/reagent/proc/on_abductor_life(mob/living/carbon/human/H)				//abductors, from the abductor game mode/event
	on_mob_life(H)

/datum/reagent/proc/on_golem_life(mob/living/carbon/human/H)				//golems, from xenobio
	on_mob_life(H)

/datum/reagent/proc/on_shadow_person_life(mob/living/carbon/human/H)		//shadow people, from xenobio (NOT SHADOWLINGS)
	on_mob_life(H)

/datum/reagent/proc/on_shadowling_life(mob/living/carbon/human/H)			//Normal Shadowlings, from the game mode (ascendant shadowlings are a simple_animal mob)
	on_mob_life(H)

/datum/reagent/proc/on_lesser_shadowling_life(mob/living/carbon/human/H)	//Lesser Shadowlings (empowered thralls), from the shadowling ability "Black Recuperation"
	//By default, this is going to call the same effect as the basic shadow person version so they will react the same to reagents that affect shadow people.
	//This is because these are powered up shadow people, but you can override this on reagents you want to handle differently for the empowered version without copying the rest
	on_shadow_person_life(H)


//Monkey species procs, these default to calling their "evolved" form's proc, but you can override this if you want them to react differently to a reagent in primitive form
/datum/reagent/proc/on_monkey_life(mob/living/carbon/human/H)				//human monkeys, aka chimps
	on_mob_life(H)		//humans use on_mob_life, change this if you make humans have their own on_species_life proc

/datum/reagent/proc/on_farwa_life(mob/living/carbon/human/H)				//tajaran monkeys
	on_tajaran_life(H)

/datum/reagent/proc/on_neara_life(mob/living/carbon/human/H)				//skrell monkeys
	on_skrell_life(H)

/datum/reagent/proc/on_wolpin_life(mob/living/carbon/human/H)				//vulpkanin monkeys
	on_vulpkanin_life(H)

/datum/reagent/proc/on_stok_life(mob/living/carbon/human/H)					//unathi monkeys
	on_unathi_life(H)