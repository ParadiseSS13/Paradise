// others
/obj/item/envelope/medical/Initialize(mapload)
	. = ..()
	job_list |= GLOB.medical_positions_ss220

/datum/uplink_item/jobspecific/viral_injector/New()
	. = ..()
	job |= GLOB.medical_positions_ss220


// loadout
/datum/gear/accessory/stethoscope/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/accessory/armband_job/medical/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/glasses/goggles_job/medhudgoggles/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/mug/department/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/beret_job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/surgicalcap_purple/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/hat/surgicalcap_green/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/suit/coat/job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/skirt/job/med/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/medical/pscrubs/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220

/datum/gear/uniform/medical/gscrubs/New()
	. = ..()
	allowed_roles |= GLOB.medical_positions_ss220
