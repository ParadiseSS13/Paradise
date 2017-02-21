
var/global/datum/controller/process/ssd/ssd

/datum/controller/process/ssd
	var/list/current_ssds = list()
	var/list/previous_ssds = list()
	var/list/ignored_ssds = list()
	var/list/areas_to_ignore = list(/area/security/prison)

/datum/controller/process/ssd/setup()
	name = "SSD"
	schedule_interval = 6000

/datum/controller/process/ssd/doWork()
	current_ssds = list()
	for(var/mob/living/carbon/human/H in mob_list)
		if(H.is_valid_for_ssdhandling())
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
			if(T.mind && T.mind.assigned_role)
				T.mind.role_given_up = 1
				job_master.FreeRole(T.mind.assigned_role)
				log_admin("SSD: [key_name(T)] is SSD. Adding job slot for: [T.mind.assigned_role]")
	previous_ssds = current_ssds

/mob/living/carbon/human/proc/is_valid_for_ssdhandling()
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