/obj/item/envelope/security/Initialize(mapload)
	. = ..()
	job_list |= GLOB.security_positions_ss220

/datum/gear/accessory/holobadge/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/accessory/holobadge_n/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/accessory/armband_job/sec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/glasses/sechud/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/glasses/goggles_job/sechudgoggles/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/mug/department/sec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/hat/capcsec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/hat/capsec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/hat/beret_job/sec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/suit/coat/job/sec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/suit/bomber/job/sec/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/suit/secjacket/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/uniform/skirt/job/security/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/uniform/sec/formal/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/uniform/sec/secorporate/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/uniform/sec/dispatch/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220

/datum/gear/uniform/sec/casual/New()
	. = ..()
	allowed_roles |= GLOB.security_positions_ss220
