// others
/obj/item/envelope/engineering/Initialize(mapload)
	. = ..()
	job_list |= GLOB.engineering_positions_ss220

/datum/uplink_item/jobspecific/powergloves/New()
	. = ..()
	job |= GLOB.engineering_positions_ss220

/datum/theft_objective/supermatter_sliver/New()
	. = ..()
	protected_jobs |= GLOB.engineering_positions_ss220


// loadout
/datum/gear/accessory/armband_job/engineering/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/mug/department/eng/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/hat/hhat_yellow/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/hat/hhat_orange/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/hat/hhat_blue/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/hat/beret_job/eng/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/suit/coat/job/engi/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

/datum/gear/uniform/skirt/job/eng/New()
	. = ..()
	allowed_roles |= GLOB.engineering_positions_ss220

