/datum/job/cargo_tech/New()
	. = ..()
	access += list(ACCESS_MINING)

/datum/job/mining/New()
	. = ..()
	access += list(ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MAILSORTING)

/datum/job/bartender/New()
	. = ..()
	access += list(ACCESS_KITCHEN, ACCESS_HYDROPONICS)

/datum/job/chef/New()
	. = ..()
	access += list(ACCESS_BAR, ACCESS_HYDROPONICS)

/datum/job/hydro/New()
	. = ..()
	access += list(ACCESS_KITCHEN, ACCESS_BAR)
