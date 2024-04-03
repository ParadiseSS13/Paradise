/datum/job/cargo_tech/New()
	. = ..()
	access |= list(ACCESS_MINING)

/datum/job/mining/New()
	. = ..()
	access |= list(ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_SUPPLY_SHUTTLE, ACCESS_MAILSORTING)

/datum/job/bartender/New()
	. = ..()
	access |= list(ACCESS_KITCHEN, ACCESS_HYDROPONICS)

/datum/job/chef/New()
	. = ..()
	access |= list(ACCESS_BAR, ACCESS_HYDROPONICS)

/datum/job/hydro/New()
	. = ..()
	access |= list(ACCESS_KITCHEN, ACCESS_BAR)

/datum/job/doctor/New()
	. = ..()
	access |= list(ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_VIROLOGY)

/datum/job/paramedic/New()
	. = ..()
	access |= list(ACCESS_CARGO_BAY, ACCESS_SURGERY)

/datum/job/atmos/New()
	. = ..()
	access |= list(ACCESS_ENGINE)

/datum/job/engineer/New()
	. = ..()
	access |= list(ACCESS_ATMOSPHERICS)

/datum/job/blueshield/New()
	. = ..()
	access |= list(ACCESS_CARGO_BAY)

/datum/job/roboticist/New()
	. = ..()
	access |= list(ACCESS_TOX)
