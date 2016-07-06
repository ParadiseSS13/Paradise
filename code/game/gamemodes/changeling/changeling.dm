var/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/game_mode
	var/list/datum/mind/changelings = list()


/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician", "Internal Affairs Agent", "Nanotrasen Navy Officer", "Special Operations Officer")
	protected_species = list("Machine", "Slime People", "Plasmaman")
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	var/changeling_amount = 4

/datum/game_mode/changeling/announce()
	to_chat(world, "<B>The current game mode is - Changeling!</B>")
	to_chat(world, "<B>There are alien changelings on the station. Do not let the changelings succeed!</B>")

/datum/game_mode/changeling/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	changeling_amount = 1 + round(num_players() / 10)

	if(possible_changelings.len>0)
		for(var/i = 0, i < changeling_amount, i++)
			if(!possible_changelings.len) break
			var/datum/mind/changeling = pick(possible_changelings)
			possible_changelings -= changeling
			changelings += changeling
			changeling.restricted_roles = restricted_jobs
			modePlayer += changelings
			changeling.special_role = "Changeling"
		return 1
	else
		return 0

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		grant_changeling_powers(changeling.current)
		forge_changeling_objectives(changeling)
		greet_changeling(changeling)
		update_change_icons_added(changeling)

	..()


/datum/game_mode/proc/forge_changeling_objectives(var/datum/mind/changeling)
	//OBJECTIVES - Always absorb 5 genomes, plus random traitor objectives.
	//If they have two objectives as well as absorb, they must survive rather than escape
	//No escape alone because changelings aren't suited for it and it'd probably just lead to rampant robusting
	//If it seems like they'd be able to do it in play, add a 10% chance to have to escape alone

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = changeling
	absorb_objective.gen_amount_goal(6, 8)
	changeling.objectives += absorb_objective

	if(prob(60))
		var/datum/objective/steal/steal_objective = new
		steal_objective.owner = changeling
		steal_objective.find_target()
		changeling.objectives += steal_objective
	else
		var/datum/objective/debrain/debrain_objective = new
		debrain_objective.owner = changeling
		debrain_objective.find_target()
		changeling.objectives += debrain_objective

	var/list/active_ais = active_ais()
	if(active_ais.len && prob(4)) // Leaving this at a flat chance for now, problems with the num_players() proc due to latejoin antags.
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = changeling
		destroy_objective.find_target()
		changeling.objectives += destroy_objective
	else
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = changeling
		kill_objective.find_target()
		changeling.objectives += kill_objective

		if (!(locate(/datum/objective/escape) in changeling.objectives))
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = changeling
			identity_theft.target = kill_objective.target
			if(identity_theft.target && identity_theft.target.current)
				identity_theft.target_real_name = kill_objective.target.current.real_name //Whoops, forgot this.
				var/mob/living/carbon/human/H = identity_theft.target.current
				if(H.species && H.species.flags && H.species.flags & NO_SCAN) // For species that can't be absorbed - should default to an escape objective instead
					return
				else
					identity_theft.explanation_text = "Escape on the shuttle or an escape pod with the identity of [identity_theft.target_real_name], the [identity_theft.target.assigned_role] while wearing their identification card."
			changeling.objectives += identity_theft

	if (!(locate(/datum/objective/escape) in changeling.objectives))
		if(prob(70))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = changeling
			changeling.objectives += escape_objective
		else
			var/datum/objective/escape/escape_with_identity/identity_theft = new
			identity_theft.owner = changeling
			identity_theft.find_target()
			changeling.objectives += identity_theft
	return

/datum/game_mode/proc/greet_changeling(var/datum/mind/changeling, var/you_are=1)
	if (you_are)
		to_chat(changeling.current, "<B>\red You are a changeling!</B>")
	to_chat(changeling.current, "<b>\red Use say \":g message\" to communicate with your fellow changelings. Remember: you get all of their absorbed DNA if you absorb them.</b>")
	to_chat(changeling.current, "<B>You must complete the following tasks:</B>")
	if (changeling.current.mind)
		if (changeling.current.mind.assigned_role == "Clown")
			to_chat(changeling.current, "You have evolved beyond your clownish nature, allowing you to wield weapons without harming yourself.")
			changeling.current.mutations.Remove(CLUMSY)

	var/obj_count = 1
	for(var/datum/objective/objective in changeling.objectives)
		to_chat(changeling.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return



/datum/game_mode/proc/remove_changeling(datum/mind/changeling_mind)
	if(changeling_mind in changelings)
		changelings -= changeling_mind
		changeling_mind.current.remove_changeling_powers()
		changeling_mind.memory = ""
		changeling_mind.special_role = null
		if(issilicon(changeling_mind))
			to_chat(changeling_mind.current, "<span class='userdanger'>You have been robotized!</span>")
			to_chat(changeling_mind.current, "<span class='danger'>You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.</span>")
		else
			to_chat(changeling_mind.current, "<FONT color='red' size = 3><B>You lose your powers! You are no longer a changeling and are stuck in your current form!</B></FONT>")
		update_change_icons_removed(changeling_mind)

/datum/game_mode/proc/update_change_icons_added(datum/mind/changeling)
	var/datum/atom_hud/antag/linghud = huds[ANTAG_HUD_CHANGELING]
	linghud.join_hud(changeling.current)
	set_antag_hud(changeling.current, "hudchangeling")

/datum/game_mode/proc/update_change_icons_removed(datum/mind/changeling)
	var/datum/atom_hud/antag/linghud = huds[ANTAG_HUD_CHANGELING]
	linghud.leave_hud(changeling.current)
	set_antag_hud(changeling.current, null)


/*/datum/game_mode/changeling/check_finished()
	var/changelings_alive = 0
	for(var/datum/mind/changeling in changelings)
		if(!istype(changeling.current,/mob/living/carbon))
			continue
		if(changeling.current.stat==2)
			continue
		changelings_alive++

	if (changelings_alive)
		changelingdeath = 0
		return ..()
	else
		if (!changelingdeath)
			changelingdeathtime = world.time
			changelingdeath = 1
		if(world.time-changelingdeathtime > TIME_TO_GET_REVIVED)
			return 1
		else
			return ..()
	return 0*/

/datum/game_mode/proc/grant_changeling_powers(mob/living/carbon/changeling_mob)
	if(!istype(changeling_mob))	return
	changeling_mob.make_changeling()

/datum/game_mode/proc/auto_declare_completion_changeling()
	if(changelings.len)
		var/text = "<FONT size = 3><B>The changelings were:</B></FONT>"
		for(var/datum/mind/changeling in changelings)
			var/changelingwin = 1

			text += "<br>[changeling.key] was [changeling.name] ("
			if(changeling.current)
				if(changeling.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(changeling.current.real_name != changeling.name)
					text += " as [changeling.current.real_name]"
			else
				text += "body destroyed"
				changelingwin = 0
			text += ")"

			//Removed sanity if(changeling) because we -want- a runtime to inform us that the changelings list is incorrect and needs to be fixed.
			text += "<br><b>Changeling ID:</b> [changeling.changeling.changelingID]."
			text += "<br><b>Genomes Extracted:</b> [changeling.changeling.absorbedcount]"

			if(changeling.objectives.len)
				var/count = 1
				for(var/datum/objective/objective in changeling.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("changeling_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("changeling_objective","[objective.type]|FAIL")
						changelingwin = 0
					count++

			if(changelingwin)
				text += "<br><font color='green'><B>The changeling was successful!</B></font>"
				feedback_add_details("changeling_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The changeling has failed.</B></font>"
				feedback_add_details("changeling_success","FAIL")

		to_chat(world, text)


	return 1

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/absorbed_dna = list()
	var/list/absorbed_languages = list()
	var/list/protected_dna = list() //DNA that is not lost when capacity is otherwise full.
	var/dna_max = 4 //How many extra DNA strands the changeling can store for transformation.
	var/absorbedcount = 1 //Would require at least 1 sample to take on the form of a human
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_recharge_slowdown = 0
	var/chem_storage = 50
	var/sting_range = 2
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 10
	var/purchasedpowers = list()
	var/mimicing = ""
	var/canrespec = 0
	var/changeling_speak = 0
	var/datum/dna/chosen_dna
	var/obj/effect/proc_holder/changeling/sting/chosen_sting

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific
	if(gender == FEMALE)	honorific = "Ms."
	else					honorific = "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"
	absorbed_dna.len = dna_max

/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges + chem_recharge_rate - chem_recharge_slowdown), chem_storage)
	geneticdamage = max(0, geneticdamage-1)


/datum/changeling/proc/GetDNA(var/dna_owner)
	for(var/datum/dna/DNA in (absorbed_dna + protected_dna))
		if(dna_owner == DNA.real_name)
			return DNA

/datum/changeling/proc/has_dna(var/datum/dna/tDNA)
	for(var/datum/dna/D in (absorbed_dna + protected_dna))
		if(tDNA.unique_enzymes == D.unique_enzymes && tDNA.uni_identity == D.uni_identity && tDNA.species == D.species)
			return 1
	return 0

/datum/changeling/proc/can_absorb_dna(var/mob/living/carbon/user, var/mob/living/carbon/target)
	if(absorbed_dna[1] == user.dna)//If our current DNA is the stalest, we gotta ditch it.
		to_chat(user, "<span class='warning'>We have reached our capacity to store genetic information! We must transform before absorbing more.</span>")
		return

	if(!target || !target.dna)
		to_chat(user, "<span class='warning'>This creature does not have any DNA.</span>")
		return

	var/mob/living/carbon/human/T = target
	if(!istype(T) || issmall(T))
		to_chat(user, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if((NOCLONE || SKELETON || HUSK) in T.mutations)
		to_chat(user, "<span class='warning'>DNA of [target] is ruined beyond usability!</span>")
		return

	if(T.species.flags & NO_DNA)
		to_chat(user, "<span class='warning'>This creature does not have DNA!</span>")
		return

	if(T.species.flags & NO_SCAN)
		to_chat(user, "<span class='warning'>We do not know how to parse this creature's DNA!</span>")
		return

	if(T.species.flags & NO_BLOOD)
		to_chat(user, "<span class='warning'>We are not able to use the DNA of a creature without a circulatory system.</span>")
		return

	if(has_dna(target.dna))
		to_chat(user, "<span class='warning'>We already have this DNA in storage!</span>")

	return 1

