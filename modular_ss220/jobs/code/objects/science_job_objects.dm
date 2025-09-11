// others
/obj/item/envelope/science/Initialize(mapload)
	. = ..()
	job_list |= GLOB.science_positions_ss220

/datum/uplink_item/jobspecific/stims/New()
	. = ..()
	job |= GLOB.science_positions_ss220

/datum/theft_objective/reactive/New()
	. = ..()
	protected_jobs |= GLOB.science_positions_ss220


// loadout
/datum/gear/accessory/armband_job/sci/New()
	. = ..()
	allowed_roles |= GLOB.science_positions_ss220

/datum/gear/glasses/goggles_job/diaghudgoggles/New()
	. = ..()
	allowed_roles |= GLOB.science_positions_ss220

/datum/gear/mug/department/sci/New()
	. = ..()
	allowed_roles |= GLOB.science_positions_ss220

/datum/gear/hat/beret_job/sci/New()
	. = ..()
	allowed_roles |= GLOB.science_positions_ss220

/datum/gear/suit/coat/job/sci/New()
	. = ..()
	allowed_roles |= GLOB.science_positions_ss220

