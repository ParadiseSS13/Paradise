GLOBAL_LIST_INIT(station_departments, list("Command", "Medical", "Engineering", "Science", "Security", "Cargo", "Support", "Assistant"))


/datum/job
	///The department the job belongs to.
	var/department
	///Whether this is a head position
	var/head_position = FALSE

/datum/job/captain
	department = "Command"
	head_position = TRUE

/datum/job/hop
	department = "Support"
	head_position = TRUE

/datum/job/assistant
	department = "Assistant"

/datum/job/bartender
	department = "Support"

/datum/job/chef
	department = "Support"

/datum/job/hydro
	department = "Support"

/datum/job/mining
	department = "Support"

/datum/job/janitor
	department = "Support"

/datum/job/librarian
	department = "Support"

/datum/job/lawyer
	department = "Support"

/datum/job/chaplain
	department = "Support"

/datum/job/qm
	department = "Cargo"
	head_position = TRUE

/datum/job/cargo_tech
	department = "Cargo"

/datum/job/chief_engineer
	department = "Engineering"
	head_position = TRUE

/datum/job/engineer
	department = "Engineering"

/datum/job/atmos
	department = "Engineering"

/datum/job/cmo
	department = "Medical"
	head_position = TRUE

/datum/job/doctor
	department = "Medical"

/datum/job/chemist
	department = "Medical"

/datum/job/geneticist
	department = "Medical"

/datum/job/psychiatrist
	department = "Medical"

/datum/job/rd
	department = "Science"
	head_position = TRUE

/datum/job/scientist
	department = "Science"

/datum/job/roboticist
	department = "Science"

/datum/job/hos
	department = "Security"
	head_position = TRUE

/datum/job/warden
	department = "Security"

/datum/job/detective
	department = "Security"

/datum/job/officer
	department = "Security"
