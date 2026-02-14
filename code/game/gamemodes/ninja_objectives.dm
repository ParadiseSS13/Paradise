#define NINJA_OBJECTIVE_EASY 10
#define NINJA_OBJECTIVE_NORMAL 20
#define NINJA_OBJECTIVE_HARD 40

/datum/objective/ninja
	/// Can you only roll this objective once?
	var/onlyone = FALSE
	/// Does this objective come with special gear
	var/special_equipment_path
	/// Rewarded currency for objective completion
	var/reward_tc = NINJA_OBJECTIVE_EASY

/datum/objective/ninja/New(text, datum/team/team_to_join, datum/mind/_owner)
	. = ..()
	if(special_equipment_path)
		addtimer(CALLBACK(src, PROC_REF(hand_out_equipment)), 3 SECONDS, TIMER_DELETE_ME)

/datum/objective/ninja/proc/hand_out_equipment()
	give_kit(special_equipment_path)

/datum/objective/ninja/proc/complete_objective()
	for(var/datum/mind/M in get_owners())
		var/mob/living/carbon/human/H = M.current
		if(!ishuman(H))
			continue
		var/obj/item/bio_chip/uplink/ninja/nuplink = locate(/obj/item/bio_chip/uplink/ninja) in H
		if(!nuplink)
			continue
		nuplink.hidden_uplink.uses += reward_tc
	completed = TRUE

/datum/objective/ninja/proc/check_objective_conditions()
	return TRUE

/datum/objective/ninja/kill
	name = "Kill a Target"
	reward_tc = NINJA_OBJECTIVE_NORMAL

/datum/objective/ninja/kill/update_explanation_text()
	if(target?.current)
		explanation_text = "Kill [target.current.real_name], the [target.assigned_role]. Scan the corpse with your scanner to verify that the deed is done."
		var/datum/job/target_job = target.current.job
		if(target_job.job_department_flags & DEP_FLAG_COMMAND || target_job.job_department_flags & DEP_FLAG_SECURITY)
			reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/capture
	name = "Capture a Target"
	/// The kidnapee's belongings. Set upon capture.
	var/list/obj/item/victim_belongings = null
	/// Temporary objects that are available to the kidnapee during their time in jail. These are deleted when the victim is returned.
	var/list/obj/temp_objs = null
	/// Prisoner jail timer handle. On completion, returns the prisoner back to station.
	var/prisoner_timer_handle = null

/datum/objective/ninja/capture/update_explanation_text()
	if(target?.current)
		explanation_text = "Capture [target.current.real_name], the [target.assigned_role]. Use your energy net to capture them so that we can interrogate them at one of our many secret dojos."
		var/datum/job/target_job = target.current.job
		if(target_job.job_department_flags & DEP_FLAG_COMMAND || target_job.job_department_flags & DEP_FLAG_SECURITY)
			reward_tc = NINJA_OBJECTIVE_HARD
		if(target_job.job_department_flags & DEP_FLAG_SERVICE)
			reward_tc = NINJA_OBJECTIVE_EASY

/datum/objective/ninja/capture/proc/handle_capture(mob/living/sucker, turf/T)
	var/mob/living/carbon/human/H = sucker

	// Prepare their return
	prisoner_timer_handle = addtimer(CALLBACK(src, PROC_REF(handle_target_return), sucker, T), rand(3 MINUTES, 5 MINUTES), TIMER_STOPPABLE)

	LAZYSET(GLOB.prisoner_belongings.prisoners, sucker, src)

	// Shove all of the victim's items in the secure locker.
	victim_belongings = list()
	var/list/obj/item/stuff_to_transfer = list()

	// Cybernetic implants get removed first (to deal with NODROP stuff)
	for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
		// Greys get to keep their implant
		if(isgrey(H) && istype(I, /obj/item/organ/internal/cyberimp/brain/speech_translator))
			continue
		// IPCs keep this implant, free of charge!
		if(ismachineperson(H) && istype(I, /obj/item/organ/internal/cyberimp/arm/power_cord))
			continue
		// Try removing it
		I = I.remove(H)
		if(I)
			stuff_to_transfer += I

	// Skrell headpocket. They already have a check in place to limit what's placed in them.
	var/obj/item/organ/internal/headpocket/C = H.get_int_organ(/obj/item/organ/internal/headpocket)
	if(C?.held_item)
		GLOB.prisoner_belongings.give_item(C.held_item)
		victim_belongings += C.held_item
		C.held_item = null

	if(sucker.back) // Lets not bork modsuits in funny ways.
		var/obj/modsuit_safety = sucker.back
		sucker.drop_item_to_ground(modsuit_safety)
		stuff_to_transfer += modsuit_safety
	// Regular items get removed in second
	for(var/obj/item/I in sucker)
		// Any items we don't want to take from them?
		if(istype(H))
			// Keep their uniform and shoes
			if(I == H.w_uniform || I == H.shoes)
				continue
			// Plasmamen are no use if they're crispy
			if(isplasmaman(H) && I == H.head)
				continue

		// Any kind of implant gets potentially removed (mindshield, freedoms, etc)
		if(istype(I, /obj/item/bio_chip))
			if(istype(I, /obj/item/bio_chip/storage)) // Storage items are removed and placed in the confiscation locker before the implant is taken.
				var/obj/item/bio_chip/storage/storage_chip = I
				for(var/it in storage_chip.storage)
					storage_chip.storage.remove_from_storage(it)
					stuff_to_transfer += it
			qdel(I)
			continue

		if(sucker.drop_item_to_ground(I))
			stuff_to_transfer += I

	// Remove accessories from the suit if present
	if(length(H.w_uniform?.accessories))
		for(var/obj/item/clothing/accessory/A in H.w_uniform.accessories)
			H.w_uniform.detach_accessory(A, null)
			H.drop_item_to_ground(A)
			stuff_to_transfer += A

	// Transfer it all (or drop it if not possible)
	for(var/i in stuff_to_transfer)
		var/obj/item/I = i
		if(GLOB.prisoner_belongings.give_item(I))
			victim_belongings += I
		else if(!((ABSTRACT|NODROP) in I.flags)) // Anything that can't be put on hold, just drop it on the ground
			I.forceMove(T)

	// Give some species the necessary to survive. Courtesy of the Syndicate.
	if(istype(H))
		var/obj/item/tank/internals/emergency_oxygen/tank
		var/obj/item/clothing/mask/breath/mask
		if(isvox(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/nitrogen(H)
			mask = new /obj/item/clothing/mask/breath/vox(H)
		else if(isplasmaman(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/plasma(H)
			mask = new /obj/item/clothing/mask/breath(H)

		if(tank)
			H.equip_to_appropriate_slot(tank)
			H.equip_to_appropriate_slot(mask)
			tank.toggle_internals(H, TRUE)

	sucker.reagents.add_reagent("mutadone", 1) // 1u of mutadone for the Hulk:tm: experience
	sucker.update_icons()

	// Supply them with some chow. How generous is the Syndicate?
	var/obj/item/food/sliced/bread/food = new(get_turf(sucker))
	food.name = "stale bread"
	food.desc = "Looks like your captors care for their prisoners as much as their bread."
	food.trash = null
	if(prob(10))
		// Mold adds a bit of spice to it
		food.name = "moldy bread"
		food.reagents.add_reagent("fungus", 1)

	var/obj/item/reagent_containers/drinks/drinkingglass/drink = new(get_turf(sucker))
	drink.reagents.add_reagent("tea", 25) // British coders beware, tea in glasses

	var/obj/item/coin/antagtoken/passingtime = new(get_turf(sucker))

	temp_objs = list(food, drink, passingtime)

	// Narrate their kidnapping and torturing experience.
	if(sucker.stat != DEAD)
		// Heal them up - gets them out of crit/soft crit.
		sucker.reagents.add_reagent("omnizine", 10)

		to_chat(sucker, SPAN_WARNING("You feel strange..."))
		sucker.Paralyse(30 SECONDS)
		sucker.EyeBlind(35 SECONDS)
		sucker.EyeBlurry(35 SECONDS)
		sucker.AdjustConfused(35 SECONDS)

		for(var/mob/living/simple_animal/hostile/guardian/G in GLOB.alive_mob_list)
			if(G.summoner == sucker)
				sucker.remove_guardian_actions()
				to_chat(G, SPAN_DANGER("You feel your body ripped to shreds as you're forcibly removed from your summoner!"))
				to_chat(sucker, SPAN_WARNING("You feel some part of you missing, you're not who you used to be..."))
				G.ghostize()
				qdel(G)

		sleep(6 SECONDS)
		to_chat(sucker, SPAN_WARNING("That portal did something to you..."))

		sleep(6.5 SECONDS)
		to_chat(sucker, SPAN_WARNING("Your head pounds... It feels like it's going to burst out your skull!"))

		sleep(3 SECONDS)
		to_chat(sucker, SPAN_WARNING("Your head pounds..."))

		sleep(10 SECONDS)
		to_chat(sucker, "<span class='specialnotice'>A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
					we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
					so it's only a matter of time before we send you back...\"</i></span>")

		to_chat(sucker, SPAN_DANGER("<font size=3>You have been kidnapped and interrogated for valuable information! You will be sent back to the station in a few minutes...</font>"))

/datum/objective/ninja/capture/proc/handle_target_return(mob/living/M, turf/T)
	// Make a closet to return the target and their items neatly
	var/obj/structure/closet/closet = new
	closet.forceMove(T)

	// Return their items
	for(var/i in victim_belongings)
		var/obj/item/I = GLOB.prisoner_belongings.remove_item(i)
		if(!I)
			continue
		I.forceMove(closet)

	victim_belongings = list()

	// Clean up
	var/obj/item/bio_chip/uplink/uplink_implant = locate() in M
	uplink_implant?.hidden_uplink?.is_jammed = FALSE

	QDEL_LIST_CONTENTS(temp_objs)

	// Injuries due to questioning
	injure_target(M)

	// Return them a bit confused.
	M.visible_message(SPAN_NOTICE("[M] vanishes..."))
	M.forceMove(closet)
	M.Paralyse(3 SECONDS)
	M.EyeBlurry(5 SECONDS)
	M.AdjustConfused(5 SECONDS)
	M.Dizzy(70 SECONDS)
	do_sparks(4, FALSE, T)

	prisoner_timer_handle = null
	GLOB.prisoner_belongings.prisoners[M] = null

/datum/objective/ninja/capture/proc/injure_target(mob/living/M)
	var/obj/item/organ/external/injury_target
	if(prob(20)) // See if they're !!!lucky!!! enough to just chop a hand or foot off first, or even !!LUCKIER!! that it chose an already amputated limb
		injury_target = M.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		default_damage(M)
		injury_target.droplimb()
		to_chat(M, SPAN_WARNING("You were interrogated by your captors before being sent back! Oh god, something's missing!"))
		return
		// Species specific punishments first
	if(ismachineperson(M))
		M.emp_act(EMP_HEAVY)
		M.adjustBrainLoss(30)
		to_chat(M, SPAN_WARNING("You were interrogated by your captors before being sent back! You feel like some of your components are loose!"))
		return
	default_damage(M) // Now that we won't accidentally kill an IPC we can make everyone take damage
	if(isslimeperson(M))
		injury_target = M.get_organ(pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT))
		if(!injury_target)
			return
		injury_target.cause_internal_bleeding()
		injury_target = M.get_organ(BODY_ZONE_CHEST)
		injury_target.cause_internal_bleeding()
		to_chat(M, SPAN_WARNING("You were interrogated by your captors before being sent back! You feel like your inner membrane has been punctured!"))
		return
	if(prob(25)) // You either get broken ribs, or a broken limb and IB if you made it this far
		injury_target = M.get_organ(BODY_ZONE_CHEST)
		injury_target.fracture()
	else
		injury_target = M.get_organ(pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_R_LEG))
		if(!injury_target)
			return
		injury_target.fracture()
		injury_target.cause_internal_bleeding()

/datum/objective/ninja/capture/proc/default_damage(mob/living/M)
	M.adjustBruteLoss(40)
	M.adjustBrainLoss(25)

/datum/objective/ninja/hack_rnd
	name = "Hack RnD"
	explanation_text = "A client wants access to Nanotrasen's research databank. Use your scanner on their servers to give them a way inside."
	needs_target = FALSE
	onlyone = TRUE

/datum/objective/ninja/interrogate_ai
	name = "Interrogate AI"
	explanation_text = "We wish to expunge some data from their AI system. Use your scanner on an active AI core to wirelessly transfer it to us for interrogation."
	needs_target = FALSE
	onlyone = TRUE
	reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/interrogate_ai/check_objective_conditions() // If there is no AI, you don't get the objective.
	if(!length(GLOB.ai_list))
		return FALSE
	return TRUE

/datum/objective/ninja/steal_supermatter
	name = "Steal Supermatter"
	explanation_text = "Steal the supermatter crystal, using the net gun we have modified for you. The crystal will sell well to the highest bidder."
	needs_target = FALSE
	onlyone = TRUE
	reward_tc = NINJA_OBJECTIVE_HARD

/datum/objective/ninja/steal_supermatter/check_objective_conditions() // If there is no supermatter, you don't get the objective.
	return !isnull(GLOB.main_supermatter_engine)

/datum/objective/ninja/bomb_department
	name = "Bomb Department"
	needs_target = FALSE
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb
	explanation_text = "Use the special flare provided to call down and arm a spider bomb. The target department is inscribed on the flare."
	reward_tc = NINJA_OBJECTIVE_NORMAL

/datum/objective/ninja/bomb_department/emp
	name = "EMP Department"
	explanation_text = "Use the special flare provided to call down and arm an EMP bomb. The target department is inscribed on the flare."
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb/emp

/datum/objective/ninja/bomb_department/spiders
	name = "Spider Bomb Department"
	explanation_text = "Use the special flare provided to call down and arm a Spider bomb. The target department is inscribed on the flare."
	special_equipment_path = /obj/item/wormhole_jaunter/ninja_bomb/spiders

/datum/objective/ninja_exfiltrate
	name = "Exfiltrate"
	explanation_text = "Use your exfiltration flare to escape the station when your work is done."
	needs_target = FALSE

#undef NINJA_OBJECTIVE_EASY
#undef NINJA_OBJECTIVE_NORMAL
#undef NINJA_OBJECTIVE_HARD
