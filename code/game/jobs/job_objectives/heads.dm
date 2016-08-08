/////////////////////////////////////////////////////////////////////////////////////////
//Heads objectives
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/savedept
  completion_payment = 5
  per_unit = 1
  var/list/head_department

/datum/job_objective/savedept/New()
  switch(owner.assigned_role)
    if("Head of Personnel")
      head_department = support_positions
    if("Head of Security")
      head_department = security_positions
    if("Chief Engineer")
      head_department = engineering_positions
    if("Research Director")
      head_department = science_positions
    if("Chief Medical Officer")
      head_department = medical_positions

/datum/job_objective/savedept/get_description()
	var/desc = "  концу смены увезите со станции весь свой отдел в целости и сохранности."
	return sanitize_local(desc)

/datum/job_objective/savedept/check_in_the_end()
  var/count_evac
  var/count_all
  for(var/mob/living/carbon/human/H in player_list)
    if(H.mind.assigned_role in head_department)
      count_all++
      var/turf/location = get_turf(H.mind.current)
      if(location.onCentcom() || location.onSyndieBase())
        if(H.mind.current || H.mind.current.stat != DEAD)
          count_evac++
  if(count_all > count_evac) return 0
  else return 1
