
/datum/law/modifier
	/// Type of modifier
	var/category = "misc"
	/// Name of modifier
	var/name = "Unnamed Modifier"
	/// Description of modifier
	var/desc = "No description."
	/// How much extra time, flat, for the modifier, in minutes
	var/time_added = 0
	/// How much the modifier multiplies crime time
	var/time_multiplier = 1

/datum/law/modifier/cooperate
	category = "cooperation"
	name = "Cooperation with Security"
	desc = "Being helpful to the members of security, revealing things during questioning."
	time_multiplier = 0.5

/datum/law/modifier/refuse_cooperate
	category = "cooperation"
	name = "Refusal to Cooperate"
	desc = "Non-cooperative behaviour while already detained inside the brig and awaiting a sentence."
	time_multiplier = 1.5

// Surrender / Resisting
/datum/law/modifier/resisting_arrest
	category = "surrenderResisting"
	name = "Resisting Arrest"
	desc = "To resist or impede an officer legally arresting or searching you."
	time_added = 5

/datum/law/modifier/surrender
	category = "surrenderResisting"
	name = "Surrender"
	desc = "Willfully surrendering to Security."
	time_multiplier = 0.5

// Aiding
/datum/law/modifier/aiding_abetting
	category = "aiding"
	name = "Aiding and Abetting"
	desc = "To knowingly assist a criminal."

// Officer
/datum/law/modifier/against_an_officer
	category = "officer"
	name = "Offence Against an Officer"
	desc = "To batter, assault or kidnap an Officer. An Officer is defined as any member of Security, Command, or of Dignitary status (Magistrate, Blueshield, Representative). "
	time_added = 5

// Repeat Offender
/datum/law/modifier/repeat_offender_first
	category = "repeatOffender"
	name = "Repeat Offender - Second Offence"
	desc = "To be brigged for the same offense more than once."
	time_added = 10

/datum/law/modifier/repeat_offender_second
	category = "repeatOffender"
	name = "Repeat Offender - Third Offence"
	desc = "To be brigged for the same offense more than once."
	time_added = 20
