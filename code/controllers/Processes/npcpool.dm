var/global/datum/controller/process/npcpool/npc_master

/datum/controller/process/npcpool
	var/list/canBeUsed = list()
	var/list/canBeUsed_non = list()
	var/list/needsDelegate = list()
	var/list/needsAssistant = list()
	var/list/needsHelp_non = list()
	var/list/botPool_l = list() //list of all npcs using the pool
	var/list/botPool_l_non = list() //list of all non SNPC mobs using the pool

/datum/controller/process/npcpool/setup()
	name = "npc pool"
	schedule_interval = 100
	start_delay = 17
	log_startup_progress("NPC pool ticker starting up.")
	if(npc_master)
		qdel(npc_master) //only one mob master
	npc_master = src

/datum/controller/process/npcpool/copyStateFrom(var/datum/controller/process/npcpool/target)
	canBeUsed = target.canBeUsed
	canBeUsed_non = target.canBeUsed_non
	needsDelegate = target.needsDelegate
	needsAssistant = target.needsAssistant
	needsHelp_non = target.needsHelp_non
	botPool_l = target.botPool_l
	botPool_l_non = target.botPool_l_non

/datum/controller/process/npcpool/proc/insertBot(toInsert)
	if(istype(toInsert, /mob/living/carbon/human/interactive))
		botPool_l |= toInsert

/datum/controller/process/npcpool/statProcess()
	..()
	stat(null, "T [botPool_l.len + botPool_l_non.len] | D [needsDelegate.len] | A [needsAssistant.len + needsHelp_non.len] | U [canBeUsed.len + canBeUsed_non.len]")

/datum/controller/process/npcpool/doWork()
	//bot delegation and coordination systems
	//General checklist/Tasks for delegating a task or coordinating it (for SNPCs)
	// 1. Bot proximity to task target: if too far, delegate, if close, coordinate
	// 2. Bot Health/status: check health with bots in local area, if their health is higher, delegate task to them, else coordinate
	// 3. Process delegation: if a bot (or bots) has been delegated, assign them to the task.
	// 4. Process coordination: if a bot(or bots) has been asked to coordinate, assign them to help.
	// 5. Do all assignments: goes through the delegated/coordianted bots and assigns the right variables/tasks to them.

	listclearnulls(canBeUsed)

	//SNPC handling
	for(var/mob/living/carbon/human/interactive/check in botPool_l)
		if(!check)
			botPool_l -= check
			continue
		var/checkInRange = view(SNPC_MAX_RANGE_FIND, check)
		if(!(locate(check.TARGET) in checkInRange))
			needsDelegate |= check

		else if(check.IsDeadOrIncap(0))
			needsDelegate |= check

		else if(check.doing & SNPC_FIGHTING)
			needsAssistant |= check

		else
			canBeUsed |= check
		SCHECK

	if(needsDelegate.len)
		needsDelegate -= pick(needsDelegate) // cheapo way to make sure stuff doesn't pingpong around in the pool forever. delegation runs seperately to each loop so it will work much smoother

		for(var/mob/living/carbon/human/interactive/check in needsDelegate)
			if(!check)
				needsDelegate -= check
				continue
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				var/facCount = 0
				var/helpProb = 0
				for(var/C in check.faction)
					for(var/D in candidate.faction)
						if(D == C)
							helpProb = min(100, helpProb + 25)
						facCount++
				if(facCount == 1 && helpProb > 0)
					helpProb = 100
				if(prob(helpProb))
					if(candidate.takeDelegate(check))
						needsDelegate -= check
						canBeUsed -= candidate
						candidate.change_eye_color(255, 0, 0)
			SCHECK

	if(needsAssistant.len)
		needsAssistant -= pick(needsAssistant)

		for(var/mob/living/carbon/human/interactive/check in needsAssistant)
			if(!check)
				needsAssistant -= check
				continue
			if(canBeUsed.len)
				var/mob/living/carbon/human/interactive/candidate = pick(canBeUsed)
				var/facCount = 0
				var/helpProb = 0
				for(var/C in check.faction)
					for(var/D in candidate.faction)
						if(D == C)
							helpProb = min(100, helpProb + 25)
						facCount++
				if(facCount == 1 && helpProb > 0)
					helpProb = 100
				if(prob(helpProb))
					if(candidate.takeDelegate(check, 0))
						needsAssistant -= check
						canBeUsed -= candidate
						candidate.change_eye_color(255, 255, 0)
			SCHECK