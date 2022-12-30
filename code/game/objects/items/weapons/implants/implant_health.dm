/obj/item/implant/health
	name = "health bio-chip"
	activated = FALSE
	implant_data = /datum/implant_fluff/health
	implant_state = "implant-default"

	var/healthstring = ""

/obj/item/implant/health/proc/sensehealth()
	if(!imp_in)
		return "ERROR"
	else
		healthstring = "[round(imp_in.getOxyLoss())] - [round(imp_in.getFireLoss())] - [round(imp_in.getToxLoss())] - [round(imp_in.getBruteLoss())]"
	return healthstring

/obj/item/implanter/health
	name = "implanter (health)"
	implant_type = /obj/item/implant/health

/obj/item/implantcase/health
	name = "implant case - 'Health'"
	desc = "A glass case containing a health implant."
	implant_type = /obj/item/implant/health
