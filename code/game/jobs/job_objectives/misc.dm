/////////////////////////////////////////////////////////////////////////////////////////
// Misc objectives - optional and such
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/inviolate_escape
  completion_payment = 5
  per_unit = 1

/datum/job_objective/inviolate_escape/get_description()
	var/desc = "Покиньте станцию на шаттле свободным и живым, никого не убив."
	return desc

/datum/job_objective/inviolate_escape/check_for_completion()

  if(owner.kills.len>1)
    return 0
  if(issilicon(owner.current))
    return 0
  if(isbrain(owner.current))
    return 0
  if(!owner.current || owner.current.stat == DEAD)
    return 0
  if(shuttle_master.emergency.mode < SHUTTLE_ENDGAME)
    return 0
  var/turf/location = get_turf(owner.current)
  if(!location)
    return 0

  if(istype(location, /turf/simulated/shuttle/floor4)) // Fails traitors if they are in the shuttle brig -- Polymorph
    return 0

  if(location.onCentcom() || location.onSyndieBase())
    return 1
  return 0
