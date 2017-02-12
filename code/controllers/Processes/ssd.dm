
var/global/datum/controller/process/ssd/ssd

/datum/controller/process/ssd
	var/list/current_ssds = list()
	var/list/previous_ssds = list()
	var/list/ignored_ssds = list()
	var/list/areas_to_ignore = list(/area/security/prison, /area/security/permabrig)


/datum/controller/process/ssd/setup()
	name = "SSD"
	schedule_interval = 3000

/datum/controller/process/ssd/doWork()
	current_ssds = list()
	var/list/free_cryopods = list()
	var/obj/machinery/cryopod/target_cryopod = null
	for(var/obj/machinery/cryopod/P in machines)
		if(!P.occupant && istype(get_area(P), /area/crew_quarters/sleep))
			free_cryopods += P
	message_admins("A2")
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.is_valid_for_cryoing())
			if(H in ignored_ssds)
				continue
			if(H.mind)
				if(H.mind.assigned_role in command_positions)
					continue
			var/valid_area = 1
			for(var/area/A in areas_to_ignore)
				if(istype(get_area(H), A))
					valid_area = 0
					break
			if(!valid_area)
				continue
			current_ssds += H
	for(var/mob/living/carbon/human/T in current_ssds)
		if(T in previous_ssds)
			ignored_ssds += T
			if(free_cryopods.len)
				target_cryopod = safepick(free_cryopods)
				if(target_cryopod.check_occupant_allowed(T))
					target_cryopod.take_occupant(T, 1)
					free_cryopods -= target_cryopod
	previous_ssds = current_ssds

/mob/living/carbon/human/proc/is_valid_for_cryoing()
	if(!is_station_level(z))
		return 0
	if(!isLivingSSD(src))
		return 0
	if(anchored)
		return 0
	if(stunned)
		return 0
	if(handcuffed)
		return 0
	if(istype(get_turf(src), /turf/space))
		return 0
	if(buckled)
		return 0
	if(pulledby)
		return 0
	return 1