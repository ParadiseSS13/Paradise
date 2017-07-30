/obj/item/weapon/implant/health
	name = "health implant"
	activated = FALSE
	var/healthstring = ""

/obj/item/weapon/implant/health/proc/sensehealth()
	if(!imp_in)
		return "ERROR"
	else
		healthstring = "[round(imp_in.getOxyLoss())] - [round(imp_in.getFireLoss())] - [round(imp_in.getToxLoss())] - [round(imp_in.getBruteLoss())]"
	return healthstring