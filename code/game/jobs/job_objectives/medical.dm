/////////////////////////////////////////////////////////////////////////////////////////
//Medical
/////////////////////////////////////////////////////////////////////////////////////////

/datum/job_objective/disease/get_description()
	var/desc = "Не дайте болезням захватить станцию!"
	return sanitize_local(desc)

/datum/job_objective/disease/check_in_the_end()
  if(score_disease)
    return 0
  else return 1

/datum/job_objective/hurt/get_description()
	var/desc = "Исцелите всех пациентов до прилета на ЦК"
	return sanitize_local(desc)

/datum/job_objective/hurt/check_in_the_end()
  if(score_dmgestdamage > 15)
    return 0
  else return 1
