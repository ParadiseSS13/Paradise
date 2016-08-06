/////////////////////////////////////////////////////////////////////////////////////////
//Engineering
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/powerstation
  completion_payment = 5
  per_unit = 1

/datum/job_objective/powerstation/get_description()
	var/desc = "Полностью обеспечьте станцию энергией!"
	return desc

/datum/job_objective/powerstation/check_for_completion()
  if(score_powerloss == 0) return 1
  else return 0

//Make a singulo
/datum/job_objective/singulo
	completion_payment = 5
	per_unit = 1

/datum/job_objective/singulo/get_description()
	var/desc = "Настройте сингулярность или тесла-установку, и не дайте ей убежать!"
	return desc

/datum/job_objective/singulo/check_for_completion()
  var/not_contained = 0
  for(var/obj/singularity/O in singularities)
    var/count = locate(/obj/machinery/field/containment) in orange(30, O.loc)
    if(!count)
      not_contained++
  if(not_contained > 0) return 0
  else return 1

//SAVE THE STATION PLEASE
/datum/job_objective/station_integrity
  completion_payment = 5
  per_unit = 1

/datum/job_objective/station_integrity/get_description()
  var/desc = "Сохраните не менее 80 процентов станции до конца смены."
  return desc

/datum/job_objective/station_integrity/check_for_completion()
  var/datum/station_state/ending_state = new /datum/station_state()
  ending_state.count()
  var/obj_station_integrity = min(round( 100.0 *  start_state.score(ending_state), 0.1), 100.0)
  if(obj_station_integrity < 80)
    return 0
  else return 1
