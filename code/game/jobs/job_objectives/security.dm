/////////////////////////////////////////////////////////////////////////////////////////
//Security
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/bringantag
  completion_payment = 5
  per_unit = 1

/datum/job_objective/bringantag/get_description()
	var/desc = "Приведите антагониста на ЦК для допроса (в наручниках)"
	return sanitize_local(desc)

/datum/job_objective/bringantag/check_in_the_end()
  for(var/datum/mind/M in ticker.minds)
		if(M.special_role && M.current && !istype(M.current,/mob/dead) && istype(get_area(M.current),/area/shuttle/escape/centcom) && M.current.handcuffed)
			if(owner.current && owner.current.stat != 2 && istype(get_area(owner.current),/area/shuttle/escape/centcom)) //split this up as it was long
				return 1
	return 0

/datum/job_objective/evac
  completion_payment = 5
  per_unit = 1

/datum/job_objective/evac/get_description()
	var/desc = "Не допустите гибели глав и VIP, доставьте их на ЦК при эвакуации."
	return sanitize_local(desc)

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
