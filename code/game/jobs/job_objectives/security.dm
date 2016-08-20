/////////////////////////////////////////////////////////////////////////////////////////
//Security
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/bringantag/get_description()
	var/desc = "Bring the antag to the Central Command, handcuffed and in the shuttle brig zone."
	return desc

/datum/job_objective/bringantag/check_in_the_end()
	for(var/datum/mind/M in ticker.minds)
		if(M.special_role && M.current && !istype(M.current,/mob/dead) && istype(get_turf(M.current),/turf/simulated/shuttle/floor4))
			if(M.current && M.current.stat != 2 && istype(get_turf(M.current),/turf/simulated/shuttle/floor4)) //split this up as it was long
				return 1
	return 0

/datum/job_objective/evac/get_description()
	var/desc = "Do not let the heads or VIP die."
	return desc

/datum/job_objective/evac/check_in_the_end()
  var/count_evac
  var/count_all
  for(var/mob/living/carbon/human/H in respawnable_list)
    if((H.mind.assigned_role in command_positions) || (H.mind.assigned_role in whitelisted_positions))
      count_all++
      var/turf/location = get_turf(H.mind.current)
      if(location.onCentcom() || location.onSyndieBase())
        if(H.mind.current || H.mind.current.stat != DEAD)
          count_evac++
  if(count_all > count_evac) return 0
  else return 1
