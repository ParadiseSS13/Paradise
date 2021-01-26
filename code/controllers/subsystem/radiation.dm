PROCESSING_SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	flags = SS_NO_INIT | SS_BACKGROUND
	wait = 1 SECONDS
	offline_implications = "Radiation will no longer function; power generation may not happen. A restart may or may not be required, depending on the situation."
	var/list/warned_atoms = list()

/datum/controller/subsystem/processing/radiation/proc/warn(datum/component/radioactive/contamination)
	if(!contamination || QDELETED(contamination))
		return
	var/ref = contamination.parent.UID()
	if(warned_atoms[ref])
		return
	warned_atoms[ref] = TRUE
	var/atom/master = contamination.parent
	SSblackbox.record_feedback("tally", "contaminated", 1, master.type)
	var/msg = "has become contaminated with enough radiation to contaminate other objects. || Source: [contamination.source] || Strength: [contamination.strength]"
	master.investigate_log(msg, "radiation")
