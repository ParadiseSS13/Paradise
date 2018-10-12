/datum/event/vent_clog
	announceWhen	= 0
	startWhen		= 5
	endWhen			= 35
	var/interval 	= 2
	var/list/vents  = list()

/datum/event/vent_clog/announce()
	event_announcement.Announce("The scrubbers network is experiencing a backpressure surge.  Some ejection of contents may occur.", "Atmospherics alert")

/datum/event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in GLOB.machines)
		if(is_station_level(temp_vent.loc.z))
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent

/datum/event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/vent = pick_n_take(vents)

		var/list/gunk = list("water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin","psilocybin","lube",
							"atrazine","banana","charcoal","space_drugs","methamphetamine","holywater","ethanol","hot_coco","facid",
							"blood","morphine","ether","fluorine","mutadone","mutagen","hydrocodone","fuel",
							"haloperidol","lsd","syndicate_nanites","lipolicide","frostoil","salglu_solution","beepskysmash",
							"omnizine", "amanitin", "neurotoxin", "synaptizine")
		var/datum/reagents/R = new/datum/reagents(50)
		R.my_atom = vent
		R.add_reagent(pick(gunk), 50)

		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(R, rand(1, 2), 0, vent, 0, silent = 1)
		playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		smoke.start(3)
		qdel(R)
