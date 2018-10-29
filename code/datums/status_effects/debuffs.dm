//OTHER DEBUFFS

/datum/status_effect/cultghost //is a cult ghost and can't use manifest runes
	id = "cult_ghost"
	duration = -1
	alert_type = null

/datum/status_effect/cultghost/tick()
	if(owner.reagents)
		owner.reagents.del_reagent("holywater") //can't be deconverted