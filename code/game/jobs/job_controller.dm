var/global/datum/controller/occupations/job_master

#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2

/datum/controller/occupations
		//List of all jobs
	var/list/occupations = list()
		//Players who need jobs
	var/list/unassigned = list()
		//Debug info
	var/list/job_debug = list()


	proc/SetupOccupations(var/list/faction = list("Station"))
		occupations = list()
		var/list/all_jobs = subtypesof(/datum/job)
		if(!all_jobs.len)
			to_chat(world, "\red \b Error setting up jobs, no job datums found")
			return 0
		for(var/J in all_jobs)
			var/datum/job/job = new J()
			if(!job)	continue
			if(!job.faction in faction)	continue
			occupations += job

		return 1


	proc/Debug(var/text)
		if(!Debug2)	return 0
		job_debug.Add(text)
		return 1


	proc/GetJob(var/rank)
		if(!rank)	return null
		for(var/datum/job/J in occupations)
			if(!J)	continue
			if(J.title == rank)	return J
		return null

	proc/GetPlayerAltTitle(mob/new_player/player, rank)
		return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

	proc/AssignRole(var/mob/new_player/player, var/rank, var/latejoin = 0)
		Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
		if(player && player.mind && rank)
			var/datum/job/job = GetJob(rank)
			if(!job)	return 0
			if(jobban_isbanned(player, rank))	return 0
			if(!job.player_old_enough(player.client)) return 0
			if(!is_job_whitelisted(player, rank)) return 0
			var/position_limit = job.total_positions
			if(!latejoin)
				position_limit = job.spawn_positions
			if((job.current_positions < position_limit) || position_limit == -1)
				Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
				player.mind.assigned_role = rank
				player.mind.role_alt_title = GetPlayerAltTitle(player, rank)

				// JOB OBJECTIVES OH SHIT
				player.mind.job_objectives.Cut()
				for(var/objectiveType in job.required_objectives)
					new objectiveType(player.mind)

				// 50/50 chance of getting optional objectives.
				for(var/objectiveType in job.optional_objectives)
					if(prob(50))
						new objectiveType(player.mind)

				unassigned -= player
				job.current_positions++
				return 1
		Debug("AR has failed, Player: [player], Rank: [rank]")
		return 0

	proc/FreeRole(var/rank)	//making additional slot on the fly
		var/datum/job/job = GetJob(rank)
		if(job && job.current_positions >= job.total_positions && job.total_positions != -1)
			job.total_positions++
			return 1
		return 0

	proc/FindOccupationCandidates(datum/job/job, level, flag)
		Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
		var/list/candidates = list()
		for(var/mob/new_player/player in unassigned)
			Debug(" - Player: [player] Banned: [jobban_isbanned(player, job.title)] Old Enough: [!job.player_old_enough(player.client)] Flag && Be Special: [flag] && [player.client.prefs.be_special] Job Department: [player.client.prefs.GetJobDepartment(job, level)] Job Flag: [job.flag] Job Department Flag = [job.department_flag]")
			if(jobban_isbanned(player, job.title))
				Debug("FOC isbanned failed, Player: [player]")
				continue
			if(!job.player_old_enough(player.client))
				Debug("FOC player not old enough, Player: [player]")
				continue
			if(flag && !(flag in player.client.prefs.be_special))
				Debug("FOC flag failed, Player: [player], Flag: [flag], ")
				continue
			if(player.mind && job.title in player.mind.restricted_roles)
				Debug("FOC incompatbile with antagonist role, Player: [player]")
				continue
			if(player.client.prefs.GetJobDepartment(job, level) & job.flag)
				Debug("FOC pass, Player: [player], Level:[level]")
				candidates += player
		return candidates

	proc/GiveRandomJob(var/mob/new_player/player)
		Debug("GRJ Giving random job, Player: [player]")
		for(var/datum/job/job in shuffle(occupations))
			if(!job)
				continue

			if(istype(job, GetJob("Civilian"))) // We don't want to give him assistant, that's boring!
				continue

			if(job.title in command_positions) //If you want a command position, select it!
				continue

			if(job.title in whitelisted_positions) // No random whitelisted job, sorry!
				continue

			if(job.admin_only) // No admin positions either.
				continue

			if(jobban_isbanned(player, job.title))
				Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
				continue

			if(!job.player_old_enough(player.client))
				Debug("GRJ player not old enough, Player: [player]")
				continue

			if(player.mind && job.title in player.mind.restricted_roles)
				Debug("GRJ incompatible with antagonist role, Player: [player], Job: [job.title]")
				continue

			if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
				Debug("GRJ Random job given, Player: [player], Job: [job]")
				AssignRole(player, job.title)
				unassigned -= player
				break

	proc/ResetOccupations()
		for(var/mob/new_player/player in player_list)
			if((player) && (player.mind))
				player.mind.assigned_role = null
				player.mind.special_role = null
		SetupOccupations()
		unassigned = list()
		return


	///This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
	proc/FillHeadPosition()
		for(var/level = 1 to 3)
			for(var/command_position in command_positions)
				var/datum/job/job = GetJob(command_position)
				if(!job)	continue
				var/list/candidates = FindOccupationCandidates(job, level)
				if(!candidates.len)	continue

				// Build a weighted list, weight by age.
				var/list/weightedCandidates = list()

				// Different head positions have different good ages.
				var/good_age_minimal = 25
				var/good_age_maximal = 60
				if(command_position == "Captain")
					good_age_minimal = 30
					good_age_maximal = 70 // Old geezer captains ftw

				for(var/mob/V in candidates)
					// Log-out during round-start? What a bad boy, no head position for you!
					if(!V.client) continue
					var/age = V.client.prefs.age
					switch(age)
						if(good_age_minimal - 10 to good_age_minimal)
							weightedCandidates[V] = 3 // Still a bit young.
						if(good_age_minimal to good_age_minimal + 10)
							weightedCandidates[V] = 6 // Better.
						if(good_age_minimal + 10 to good_age_maximal - 10)
							weightedCandidates[V] = 10 // Great.
						if(good_age_maximal - 10 to good_age_maximal)
							weightedCandidates[V] = 6 // Still good.
						if(good_age_maximal to good_age_maximal + 10)
							weightedCandidates[V] = 6 // Bit old, don't you think?
						if(good_age_maximal to good_age_maximal + 50)
							weightedCandidates[V] = 3 // Geezer.
						else
							// If there's ABSOLUTELY NOBODY ELSE
							if(candidates.len == 1) weightedCandidates[V] = 1


				var/mob/new_player/candidate = pickweight(weightedCandidates)
				if(AssignRole(candidate, command_position))
					return 1
		return 0


	///This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
	proc/CheckHeadPositions(var/level)
		for(var/command_position in command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)	continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)	continue
			var/mob/new_player/candidate = pick(candidates)
			AssignRole(candidate, command_position)
		return


	proc/FillAIPosition()
		var/ai_selected = 0
		var/datum/job/job = GetJob("AI")
		if(!job)
			return 0
		if((job.title == "AI") && (config) && (!config.allow_ai))
			return 0
		for(var/i = job.total_positions, i > 0, i--)
			for(var/level = 1 to 3)
				var/list/candidates = list()
				candidates = FindOccupationCandidates(job, level)
				if(candidates.len)
					var/mob/new_player/candidate = pick(candidates)
					if(AssignRole(candidate, "AI"))
						ai_selected++
						break
			if(ai_selected)	return 1
			return 0


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
	proc/DivideOccupations()
		//Setup new player list and get the jobs list
		Debug("Running DO")
		SetupOccupations()

		//Holder for Triumvirate is stored in the ticker, this just processes it
		if(ticker)
			for(var/datum/job/ai/A in occupations)
				if(ticker.triai)
					A.spawn_positions = 3

		//Get the players who are ready
		for(var/mob/new_player/player in player_list)
			if(player.ready && player.mind && !player.mind.assigned_role)
				unassigned += player
				if(player.client.prefs.randomslot) player.client.prefs.random_character(player.client)
		Debug("DO, Len: [unassigned.len]")
		if(unassigned.len == 0)	return 0

		//Shuffle players and jobs
		unassigned = shuffle(unassigned)

		HandleFeedbackGathering()

		//People who wants to be assistants, sure, go on.
		Debug("DO, Running Civilian Check 1")
		var/datum/job/civ = new /datum/job/civilian()
		var/list/civilian_candidates = FindOccupationCandidates(civ, 3)
		Debug("AC1, Candidates: [civilian_candidates.len]")
		for(var/mob/new_player/player in civilian_candidates)
			Debug("AC1 pass, Player: [player]")
			AssignRole(player, "Civilian")
			civilian_candidates -= player
		Debug("DO, AC1 end")

		//Select one head
		Debug("DO, Running Head Check")
		FillHeadPosition()
		Debug("DO, Head Check end")

		//Check for an AI
		Debug("DO, Running AI Check")
		FillAIPosition()
		Debug("DO, AI Check end")

		//Other jobs are now checked
		Debug("DO, Running Standard Check")


		// New job giving system by Donkie
		// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
		// Hopefully this will add more randomness and fairness to job giving.

		// Loop through all levels from high to low
		var/list/shuffledoccupations = shuffle(occupations)
		for(var/level = 1 to 3)
			//Check the head jobs first each level
			CheckHeadPositions(level)

			// Loop through all unassigned players
			for(var/mob/new_player/player in unassigned)

				// Loop through all jobs
				for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
					if(!job)
						continue

					if(jobban_isbanned(player, job.title))
						Debug("DO isbanned failed, Player: [player], Job:[job.title]")
						continue

					if(!job.player_old_enough(player.client))
						Debug("DO player not old enough, Player: [player], Job:[job.title]")
						continue

					if(player.mind && job.title in player.mind.restricted_roles)
						Debug("DO incompatible with antagonist role, Player: [player], Job:[job.title]")
						continue

					if(!is_job_whitelisted(player, job.title))
						Debug("DO player not whitelisted, Player: [player], Job:[job.title]")
						continue

					// If the player wants that job on this level, then try give it to him.
					if(player.client.prefs.GetJobDepartment(job, level) & job.flag)

						// If the job isn't filled
						if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
							Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
							Debug(" - Job Flag: [job.flag] Job Department: [player.client.prefs.GetJobDepartment(job, level)] Job Current Pos: [job.current_positions] Job Spawn Positions = [job.spawn_positions]")
							AssignRole(player, job.title)
							unassigned -= player
							break

		// Hand out random jobs to the people who didn't get any in the last check
		// Also makes sure that they got their preference correct
		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
				GiveRandomJob(player)
		/*
		Old job system
		for(var/level = 1 to 3)
			for(var/datum/job/job in occupations)
				Debug("Checking job: [job]")
				if(!job)
					continue
				if(!unassigned.len)
					break
				if((job.current_positions >= job.spawn_positions) && job.spawn_positions != -1)
					continue
				var/list/candidates = FindOccupationCandidates(job, level)
				while(candidates.len && ((job.current_positions < job.spawn_positions) || job.spawn_positions == -1))
					var/mob/new_player/candidate = pick(candidates)
					Debug("Selcted: [candidate], for: [job.title]")
					AssignRole(candidate, job.title)
					candidates -= candidate*/

		Debug("DO, Standard Check end")

		Debug("DO, Running AC2")

		// For those who wanted to be civilians if their preferences were filled, here you go.
		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == BE_ASSISTANT)
				Debug("AC2 Assistant located, Player: [player]")
				AssignRole(player, "Civilian")

		for(var/mob/new_player/player in unassigned)
			if(player.mind.special_role)
				GiveRandomJob(player)

		//For ones returning to lobby
		for(var/mob/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
				player.ready = 0
				unassigned -= player
		return 1


	proc/EquipRank(var/mob/living/carbon/human/H, var/rank, var/joined_late = 0)
		if(!H)	return null
		var/datum/job/job = GetJob(rank)
		var/list/spawn_in_storage = list()

		if(job)

			//Equip custom gear loadout.
			var/list/custom_equip_slots = list() //If more than one item takes the same slot, all after the first one spawn in storage.
			var/list/custom_equip_leftovers = list()
			if(H.client.prefs.gear && H.client.prefs.gear.len && job.title != "Cyborg" && job.title != "AI")
				for(var/thing in H.client.prefs.gear)
					var/datum/gear/G = gear_datums[thing]
					if(G)
						var/permitted
						if(G.allowed_roles)
							for(var/job_name in G.allowed_roles)
								if(job.title == job_name)
									permitted = 1
						else
							permitted = 1

						if(G.whitelisted && (G.whitelisted != H.species.name || !is_alien_whitelisted(H, G.whitelisted)))
							permitted = 0

						if(!permitted)
							to_chat(H, "<span class='warning'>Your current job or whitelist status does not permit you to spawn with [thing]!</span>")
							continue

						if(G.slot && !(G.slot in custom_equip_slots))
							// This is a miserable way to fix the loadout overwrite bug, but the alternative requires
							// adding an arg to a bunch of different procs. Will look into it after this merge. ~ Z
							if(G.slot == slot_wear_mask || G.slot == slot_wear_suit || G.slot == slot_head)
								custom_equip_leftovers += thing
							else if(H.equip_to_slot_or_del(G.spawn_item(H), G.slot))
								to_chat(H, "<span class='notice'>Equipping you with \the [thing]!</span>")
								custom_equip_slots.Add(G.slot)
							else
								custom_equip_leftovers.Add(thing)
						else
							spawn_in_storage += thing

			job.equip(H)
			job.apply_fingerprints(H)

			//If some custom items could not be equipped before, try again now.
			for(var/thing in custom_equip_leftovers)
				var/datum/gear/G = gear_datums[thing]
				if(G.slot in custom_equip_slots)
					spawn_in_storage += thing
				else
					var/metadata = H.client.prefs.gear[G.display_name]
					if(H.equip_to_slot_or_del(G.spawn_item(H, metadata), G.slot))
						to_chat(H, "<span class='notice'>Equipping you with \the [thing]!</span>")
						custom_equip_slots.Add(G.slot)
					else
						spawn_in_storage += thing
		else
			to_chat(H, "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator.")

		H.job = rank

		if(!joined_late)
			var/obj/S = null
			for(var/obj/effect/landmark/start/sloc in landmarks_list)
				if(sloc.name != rank)	continue
				if(locate(/mob/living) in sloc.loc)	continue
				S = sloc
				break
			if(!S)
				S = locate("start*[rank]") // use old stype
			if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				H.loc = S.loc
			// Moving wheelchair if they have one
			if(H.buckled && istype(H.buckled, /obj/structure/stool/bed/chair/wheelchair))
				H.buckled.loc = H.loc
				H.buckled.dir = H.dir

		var/datum/money_account/M = create_account(H.real_name, rand(50,500)*10, null)
		if(H.mind)
			var/remembered_info = ""

			remembered_info += "<b>Your account number is:</b> #[M.account_number]<br>"
			remembered_info += "<b>Your account pin is:</b> [M.remote_access_pin]<br>"
			remembered_info += "<b>Your account funds are:</b> $[M.money]<br>"

			if(M.transaction_log.len)
				var/datum/transaction/T = M.transaction_log[1]
				remembered_info += "<b>Your account was created:</b> [T.time], [T.date] at [T.source_terminal]<br>"
			H.mind.store_memory(remembered_info)

			H.mind.initial_account = M

		// If they're head, give them the account info for their department
		if(H.mind && job.head_position)
			var/remembered_info = ""
			var/datum/money_account/department_account = department_accounts[job.department]

			if(department_account)
				remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
				remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
				remembered_info += "<b>Your department's account funds are:</b> $[department_account.money]<br>"

			H.mind.store_memory(remembered_info)

		spawn(0)
			to_chat(H, "<span class='boldnotice'>Your account number is: [M.account_number], your account pin is: [M.remote_access_pin]</span>")

		var/alt_title = null
		if(H.mind)
			H.mind.assigned_role = rank
			alt_title = H.mind.role_alt_title

			switch(rank)
				if("Cyborg")
					return H.Robotize()
				if("AI")
					return H
				if("Clown")	//don't need bag preference stuff!
					if(rank=="Clown") // Clowns DO need to breathe, though - N3X
						H.species.equip(H)
				else
					switch(H.backbag) //BS12 EDIT
						if(1)
							H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
						if(2)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
						if(3)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel_norm(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
						if(4)
							var/obj/item/weapon/storage/backpack/BPK = new/obj/item/weapon/storage/backpack/satchel(H)
							new /obj/item/weapon/storage/box/survival(BPK)
							H.equip_to_slot_or_del(BPK, slot_back,1)
					H.species.equip(H)

			//Deferred item spawning.
			for(var/thing in spawn_in_storage)
				var/datum/gear/G = gear_datums[thing]
				var/metadata = H.client.prefs.gear[G.display_name]
				var/item = G.spawn_item(null, metadata)

				var/atom/placed_in = H.equip_or_collect(item)
				if(placed_in)
					to_chat(H, "<span class='notice'>Placing \the [item] in your [placed_in.name]!</span>")
					continue
				if(H.equip_to_appropriate_slot(item))
					to_chat(H, "<span class='notice'>Placing \the [item] in your inventory!</span>")
					continue
				if(H.put_in_hands(item))
					to_chat(H, "<span class='notice'>Placing \the [item] in your hands!</span>")
					continue
				to_chat(H, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no arms and no backpack or this is a bug.</span>")
				qdel(item)


		to_chat(H, "<B>You are the [alt_title ? alt_title : rank].</B>")
		to_chat(H, "<b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b>")
		if(job.req_admin_notify)
			to_chat(H, "<b>You are playing a job that is important for the game progression. If you have to disconnect, please notify the admins via adminhelp.</b>")

		spawnId(H, rank, alt_title)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset(H), slot_l_ear)

		//Gives glasses to the vision impaired
		if(H.disabilities & DISABILITY_FLAG_NEARSIGHTED)
			var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)
			if(equipped != 1)
				var/obj/item/clothing/glasses/G = H.glasses
				if(istype(G) && !G.prescription)
					G.prescription = 1
					G.name = "prescription [G.name]"
		H.regenerate_icons()

		H.sec_hud_set_ID()
		H.sec_hud_set_implants()
		return H


	proc/spawnId(var/mob/living/carbon/human/H, rank, title)
		if(!H)	return 0
		var/obj/item/weapon/card/id/C = null

		var/datum/job/job = null
		for(var/datum/job/J in occupations)
			if(J.title == rank)
				job = J
				break

		if(job)
			if(job.title == "Cyborg")
				return
			else
				C = new job.idtype(H)
				C.access = job.get_access()
		else
			C = new /obj/item/weapon/card/id(H)
		if(C)
			C.registered_name = H.real_name
			C.rank = rank
			C.assignment = title ? title : rank
			C.sex = capitalize(H.gender)
			C.age = H.age
			C.name = "[C.registered_name]'s ID Card ([C.assignment])"
			C.photo = get_id_photo(H)

			//put the player's account number onto the ID
			if(H.mind && H.mind.initial_account)
				C.associated_account_number = H.mind.initial_account.account_number

			H.equip_to_slot_or_del(C, slot_wear_id)

		H.equip_to_slot_or_del(new /obj/item/device/pda(H), slot_wear_pda)
		if(locate(/obj/item/device/pda,H))
			var/obj/item/device/pda/pda = locate(/obj/item/device/pda,H)
			pda.owner = H.real_name
			pda.ownjob = C.assignment
			pda.ownrank = C.rank
			pda.name = "PDA-[H.real_name] ([pda.ownjob])"

		return 1


	proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
		if(!config.load_jobs_from_txt)
			return 0

		var/list/jobEntries = file2list(jobsfile)

		for(var/job in jobEntries)
			if(!job)
				continue

			job = trim(job)
			if(!length(job))
				continue

			var/pos = findtext(job, "=")
			var/name = null
			var/value = null

			if(pos)
				name = copytext(job, 1, pos)
				value = copytext(job, pos + 1)
			else
				continue

			if(name && value)
				var/datum/job/J = GetJob(name)
				if(!J)	continue
				J.total_positions = text2num(value)
				J.spawn_positions = text2num(value)
				if(name == "AI" || name == "Cyborg")//I dont like this here but it will do for now
					J.total_positions = 0

		return 1


	proc/HandleFeedbackGathering()
		for(var/datum/job/job in occupations)
			var/tmp_str = "|[job.title]|"

			var/level1 = 0 //high
			var/level2 = 0 //medium
			var/level3 = 0 //low
			var/level4 = 0 //never
			var/level5 = 0 //banned
			var/level6 = 0 //account too young
			for(var/mob/new_player/player in player_list)
				if(!(player.ready && player.mind && !player.mind.assigned_role))
					continue //This player is not ready
				if(jobban_isbanned(player, job.title))
					level5++
					continue
				if(!job.player_old_enough(player.client))
					level6++
					continue
				if(player.client.prefs.GetJobDepartment(job, 1) & job.flag)
					level1++
				else if(player.client.prefs.GetJobDepartment(job, 2) & job.flag)
					level2++
				else if(player.client.prefs.GetJobDepartment(job, 3) & job.flag)
					level3++
				else level4++ //not selected

			tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
			feedback_add_details("job_preferences",tmp_str)
