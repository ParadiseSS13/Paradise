/////////////////////////////////////////////////////////////////////////////////////////
//Engineering
/////////////////////////////////////////////////////////////////////////////////////////

// Power the station
/datum/job_objective/powerstation/get_description()
	var/desc = "Полностью обеспечьте станцию энергией!"
	return sanitize_local(desc)

/datum/job_objective/powerstation/check_in_the_end()
  if(score_powerbonus) return 1
  else return 0

//Make a singulo
/datum/job_objective/singulo/get_description()
	var/desc = "Настройте сингулярность или тесла-установку, и не дайте ей убежать!"
	return sanitize_local(desc)

/datum/job_objective/singulo/check_in_the_end()
  var/not_contained = 0
  for(var/obj/singularity/O in singularities)
    if(!O)
      return 0
    var/count = locate(/obj/machinery/field/containment) in orange(30, O.loc)
    if(!count)
      not_contained++
  if(not_contained > 0) return 0
  else return 1

//SAVE THE STATION PLEASE
/datum/job_objective/station_integrity/get_description()
  var/desc = "Сохраните не менее 95 процентов станции до конца смены."
  return sanitize_local(desc)

/datum/job_objective/station_integrity/check_in_the_end()
  var/datum/station_state/ending_state = new /datum/station_state()
  ending_state.count()
  var/obj_station_integrity = min(round( 100.0 *  start_state.score(ending_state), 0.1), 100.0)
  if(obj_station_integrity < 95)
    return 0
  if(ticker.mode.station_was_nuked)
    return 0
  else return 1

//Mechanic objective
/datum/job_objective/make_pod/New()
  units_requested = rand(2,3)

/datum/job_objective/make_pod/get_description()
  var/desc = "Постройте [units_requested] пода."
  desc += "[units_completed] готово."
  return sanitize_local(desc)
