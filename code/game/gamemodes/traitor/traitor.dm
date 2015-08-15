/datum/game_mode
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()
	var/list/datum/mind/implanter = list()
	var/list/datum/mind/implanted = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue

/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list("Cyborg")//They are part of the AI if he is traitor so are they, they use to get double chances
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Internal Affairs Agent", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Internal Affairs Agent", "Brig Physician")//AI", Currently out of the list as malf does not work for shit
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4


	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 20

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/traitors_possible = 4 //hard limit on traitors if scaling is turned off
	var/const/traitor_scaling_coeff = 5.0 //how much does the amount of players get divided by to determine traitors


/datum/game_mode/traitor/announce()
	world << "<B>The current game mode is - Traitor!</B>"
	world << "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>"


/datum/game_mode/traitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(BE_TRAITOR)

	// stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	var/num_traitors = 1

	if(config.traitor_scaling)
		num_traitors = max(1, round((num_players())/(traitor_scaling_coeff)))
	else
		num_traitors = max(1, min(num_players(), traitors_possible))

	for(var/j = 0, j < num_traitors, j++)
		if (!possible_traitors.len)
			break
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		traitor.special_role = "traitor"
		traitor.restricted_roles = restricted_jobs
		possible_traitors.Remove(traitor)

	if(!traitors.len)
		return 0
	return 1


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in traitors)
		forge_traitor_objectives(traitor)
		spawn(rand(10,100))
			finalize_traitor(traitor)
			greet_traitor(traitor)
	modePlayer += traitors
	spawn (rand(waittime_l, waittime_h))
		send_intercept()
	..()
	return 1


/datum/game_mode/proc/forge_traitor_objectives(var/datum/mind/traitor)
	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective

		if(prob(10))
			var/datum/objective/block/block_objective = new
			block_objective.owner = traitor
			traitor.objectives += block_objective

	else
		if(!exchange_blue && traitors.len >= 5 && name != "AutoTraitor") 	//Set up an exchange if there are enough traitors, turned off during autotraitor temporarily due to bugs.
			if(!exchange_red)
				exchange_red = traitor
			else
				exchange_blue = traitor
				assign_exchange_role(exchange_red)
				assign_exchange_role(exchange_blue)
		else
			var/list/active_ais = active_ais()
			if(active_ais.len && prob(4)) // Leaving this at a flat chance for now, problems with the num_players() proc due to latejoin antags.
				var/datum/objective/destroy/destroy_objective = new
				destroy_objective.owner = traitor
				destroy_objective.find_target()
				traitor.objectives += destroy_objective
			else
				switch(rand(1,100))
					if(1 to 30)
						var/datum/objective/assassinate/kill_objective = new
						kill_objective.owner = traitor
						kill_objective.find_target()
						traitor.objectives += kill_objective
					if(31 to 40)
						var/datum/objective/debrain/debrain_objective = new
						debrain_objective.owner = traitor
						debrain_objective.find_target()
						traitor.objectives += debrain_objective
					if(41 to 50)
						var/datum/objective/protect/protect_objective = new
						protect_objective.owner = traitor
						protect_objective.find_target_with_special_role(null,0)
						if (!protect_objective.target)
							protect_objective.find_target()					//We could not find any traitors, protect somebody
						traitor.objectives += protect_objective
					if(51 to 61)
						var/datum/objective/harm/harm_objective = new
						harm_objective.owner = traitor
						harm_objective.find_target()
						traitor.objectives += harm_objective
					else
						var/datum/objective/steal/steal_objective = new
						steal_objective.owner = traitor
						steal_objective.find_target()
						traitor.objectives += steal_objective
		switch(rand(1,100))
			if(1 to 30) // Die glorious death
				if (!(locate(/datum/objective/die) in traitor.objectives) && !(locate(/datum/objective/steal) in traitor.objectives) && !(locate(/datum/objective/steal/exchange) in traitor.objectives) && !(locate(/datum/objective/steal/exchange/backstab) in traitor.objectives))
					var/datum/objective/die/die_objective = new
					die_objective.owner = traitor
					traitor.objectives += die_objective
				else
					if(prob(85))
						if (!(locate(/datum/objective/escape) in traitor.objectives))
							var/datum/objective/escape/escape_objective = new
							escape_objective.owner = traitor
							traitor.objectives += escape_objective
					else
						if(prob(50))
							if (!(locate(/datum/objective/hijack) in traitor.objectives))
								var/datum/objective/hijack/hijack_objective = new
								hijack_objective.owner = traitor
								traitor.objectives += hijack_objective
						else
							if (!(locate(/datum/objective/minimize_casualties) in traitor.objectives))
								var/datum/objective/minimize_casualties/escape_objective = new
								escape_objective.owner = traitor
								traitor.objectives += escape_objective
			if(31 to 85)
				if (!(locate(/datum/objective/escape) in traitor.objectives))
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective
			else
				if (!(locate(/datum/objective/hijack) in traitor.objectives))
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective

	return


/datum/game_mode/proc/greet_traitor(var/datum/mind/traitor)
	traitor.current << "<B><font size=3 color=red>You are the traitor.</font></B>"
	var/obj_count = 1
	for(var/datum/objective/objective in traitor.objectives)
		traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/finalize_traitor(var/datum/mind/traitor)
	if (istype(traitor.current, /mob/living/silicon))
		add_law_zero(traitor.current)
	else
		equip_traitor(traitor.current)
	return


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/traitor/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	for(var/datum/mind/traitor_mind in traitors)
		for(var/datum/objective/objective in traitor_mind.objectives)
			objective.check_completion()
	return 0

/datum/game_mode/proc/give_codewords(mob/living/traitor_mob)
	traitor_mob << "<U><B>The Syndicate provided you with the following information on how to identify their agents:</B></U>"
	traitor_mob << "<B>Code Phrase</B>: <span class='danger'>[syndicate_code_phrase]</span>"
	traitor_mob << "<B>Code Response</B>: <span class='danger'>[syndicate_code_response]</span>"

	traitor_mob.mind.store_memory("<b>Code Phrase</b>: [syndicate_code_phrase]")
	traitor_mob.mind.store_memory("<b>Code Response</b>: [syndicate_code_response]")

	traitor_mob << "Use the code words in the order provided, during regular conversation, to identify other agents. Proceed with caution, however, as everyone is a potential foe."

/datum/game_mode/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	var/law_borg = "Accomplish your AI's objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer.set_zeroth_law(law, law_borg)
	killer << "New law: 0. [law]"
	give_codewords(killer)


/datum/game_mode/proc/auto_declare_completion_traitor()
	if(traitors.len)
		var/text = "<FONT size = 2><B>The traitors were:</B></FONT>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = 1

			text += "<br>[traitor.key] was [traitor.name] ("
			if(traitor.current)
				if(traitor.current.stat == DEAD)
					text += "died"
				else
					text += "survived"
				if(traitor.current.real_name != traitor.name)
					text += " as [traitor.current.real_name]"
			else
				text += "body destroyed"
			text += ")"


			var/TC_uses = 0
			var/uplink_true = 0
			var/purchases = ""
			for(var/obj/item/device/uplink/H in world_uplinks)
				if(H && H.uplink_owner && H.uplink_owner==traitor.key)
					TC_uses += H.used_TC
					uplink_true=1
					purchases += H.purchase_log

			if(uplink_true) text += " (used [TC_uses] TC) [purchases]"


			if(traitor.objectives && traitor.objectives.len)//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in traitor.objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						feedback_add_details("traitor_objective","[objective.type]|SUCCESS")
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						feedback_add_details("traitor_objective","[objective.type]|FAIL")
						traitorwin = 0
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"


			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font>"
				feedback_add_details("traitor_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font>"
				feedback_add_details("traitor_success","FAIL")


		world << text
	return 1


/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob, var/safety = 0)
	if (!istype(traitor_mob))
		return
	. = 1
	if (traitor_mob.mind)
		if (traitor_mob.mind.assigned_role == "Clown")
			traitor_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			traitor_mob.mutations.Remove(CLUMSY)

	// find a radio! toolbox(es), backpack, belt, headset
	var/obj/item/R = locate(/obj/item/device/pda) in traitor_mob.contents //Hide the uplink in a PDA if available, otherwise radio
	if(!R)
		R = locate(/obj/item/device/radio) in traitor_mob.contents

	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
		. = 0
	else
		if (istype(R, /obj/item/device/radio))
			// generate list of radio freqs
			var/obj/item/device/radio/target_radio = R
			var/freq = 1441
			var/list/freqlist = list()
			while (freq <= 1489)
				if (freq < 1451 || freq > 1459)
					freqlist += freq
				freq += 2
				if ((freq % 2) == 0)
					freq += 1
			freq = freqlist[rand(1, freqlist.len)]

			var/obj/item/device/uplink/hidden/T = new(R)
			target_radio.hidden_uplink = T
			T.uplink_owner = "[traitor_mob.key]"
			target_radio.traitor_frequency = freq
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [T.loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [T.loc]).")
		else if (istype(R, /obj/item/device/pda))
			// generate a passcode if the uplink is hidden in a PDA
			var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

			var/obj/item/device/uplink/hidden/T = new(R)
			R.hidden_uplink = T
			T.uplink_owner = "[traitor_mob.key]"
			var/obj/item/device/pda/P = R
			P.lock_code = pda_pass

			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [T.loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [T.loc]).")
	if(!safety)//If they are not a rev. Can be added on to.
		give_codewords(traitor_mob)

	// Tell them about people they might want to contact.
	var/mob/living/carbon/human/M = get_nt_opposed()
	if(M && M != traitor_mob)
		traitor_mob << "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them."
		traitor_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/datum/game_mode/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/ref = "\ref[traitor_mind]"
	if(ref in implanter)
		if(traitor_mind.current)
			if(traitor_mind.current.client)
				var/I = image('icons/mob/mob.dmi', loc = traitor_mind.current, icon_state = "greytide_head")
				traitor_mind.current.client.images += I
	for(var/headref in implanter)
		for(var/datum/mind/t_mind in implanter[headref])
			var/datum/mind/head = locate(headref)
			if(head)
				if(head.current)
					if(head.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "greytide")
						head.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = head.current, icon_state = "greytide_head")
						t_mind.current.client.images += I
				if(t_mind.current)
					if(t_mind.current.client)
						var/I = image('icons/mob/mob.dmi', loc = t_mind.current, icon_state = "greytide")
						t_mind.current.client.images += I

/datum/game_mode/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	for(var/headref in implanter)
		var/datum/mind/head = locate(headref)
		for(var/datum/mind/t_mind in implanter[headref])
			if(t_mind.current)
				if(t_mind.current.client)
					for(var/image/I in t_mind.current.client.images)
						if((I.icon_state == "greytide" || I.icon_state == "greytide_head") && I.loc == traitor_mind.current)
							//log_to_dd("deleting [traitor_mind] overlay")
							qdel(I)
		if(head)
			//log_to_dd("found [head.name]")
			if(head.current)
				if(head.current.client)
					for(var/image/I in head.current.client.images)
						if((I.icon_state == "greytide" || I.icon_state == "greytide_head") && I.loc == traitor_mind.current)
							//log_to_dd("deleting [traitor_mind] overlay")
							qdel(I)
	if(traitor_mind.current)
		if(traitor_mind.current.client)
			for(var/image/I in traitor_mind.current.client.images)
				if(I.icon_state == "greytide" || I.icon_state == "greytide_head")
					qdel(I)

/datum/game_mode/proc/remove_traitor_mind(datum/mind/traitor_mind, datum/mind/head)
	//var/list/removal
	var/ref = "\ref[head]"
	if(ref in implanter)
		implanter[ref] -= traitor_mind
	implanted -= traitor_mind
	traitors -= traitor_mind
	traitor_mind.special_role = null
	update_traitor_icons_removed(traitor_mind)
	//world << "Removed [traitor_mind.current.name] from traitor shit"
	traitor_mind.current << "\red <FONT size = 3><B>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now.(You don't remember who implanted you)</B></FONT>"

/datum/game_mode/proc/assign_exchange_role(var/datum/mind/owner)
	//set faction
	var/faction = "red"
	if(owner == exchange_blue)
		faction = "blue"

	//Assign objectives
	var/datum/objective/steal/exchange/exchange_objective = new
	exchange_objective.set_faction(faction,((faction == "red") ? exchange_blue : exchange_red))
	exchange_objective.owner = owner
	owner.objectives += exchange_objective

	if(prob(20))
		var/datum/objective/steal/exchange/backstab/backstab_objective = new
		backstab_objective.set_faction(faction)
		backstab_objective.owner = owner
		owner.objectives += backstab_objective

	//Spawn and equip documents
	var/mob/living/carbon/human/mob = owner.current

	var/obj/item/weapon/folder/syndicate/folder
	if(owner == exchange_red)
		folder = new/obj/item/weapon/folder/syndicate/red(mob.locs)
	else
		folder = new/obj/item/weapon/folder/syndicate/blue(mob.locs)

	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)

	var/where = "At your feet"
	var/equipped_slot = mob.equip_in_one_of_slots(folder, slots)
	if (equipped_slot)
		where = "In your [equipped_slot]"
	mob << "<BR><BR><span class='info'>[where] is a folder containing <b>secret documents</b> that another Syndicate group wants. We have set up a meeting with one of their agents on station to make an exchange. Exercise extreme caution as they cannot be trusted and may be hostile.</span><BR>"
	mob.update_icons()
