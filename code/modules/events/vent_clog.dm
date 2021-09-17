/datum/event/vent_clog
	announceWhen	= 0
	startWhen		= 5
	endWhen			= 35
	var/interval 	= 2
	var/list/vents  = list()

/datum/event/vent_clog/announce()
	GLOB.event_announcement.Announce("The scrubbers network is experiencing a backpressure surge.  Some ejection of contents may occur.", "Atmospherics alert", 'sound/AI/scrubbers.ogg')

/datum/event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in GLOB.machines)
		if(is_station_level(temp_vent.loc.z))
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent

/datum/event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/vent = pick_n_take(vents)

		var/list/gunk = list(/datum/reagent/water, /datum/reagent/carbon, /datum/reagent/consumable/flour, /datum/reagent/radium, /datum/reagent/toxin, /datum/reagent/space_cleaner,
							/datum/reagent/consumable/nutriment, /datum/reagent/consumable/condensedcapsaicin, /datum/reagent/psilocybin, /datum/reagent/lube, /datum/reagent/glyphosate/atrazine,
							/datum/reagent/consumable/drink/banana, /datum/reagent/medicine/charcoal, /datum/reagent/space_drugs, /datum/reagent/methamphetamine, /datum/reagent/holywater,
							/datum/reagent/consumable/ethanol, /datum/reagent/consumable/hot_coco, /datum/reagent/acid/facid, /datum/reagent/blood, /datum/reagent/medicine/morphine,
							/datum/reagent/medicine/ether, /datum/reagent/fluorine, /datum/reagent/medicine/mutadone, /datum/reagent/mutagen, /datum/reagent/medicine/hydrocodone, /datum/reagent/fuel,
							/datum/reagent/medicine/haloperidol, /datum/reagent/lsd, /datum/reagent/medicine/syndicate_nanites, /datum/reagent/lipolicide, /datum/reagent/consumable/frostoil,
							/datum/reagent/medicine/salglu_solution, /datum/reagent/consumable/ethanol/beepsky_smash, /datum/reagent/medicine/omnizine, /datum/reagent/amanitin,
							/datum/reagent/consumable/ethanol/neurotoxin, /datum/reagent/medicine/synaptizine, /datum/reagent/rotatium)
		var/datum/reagents/R = new/datum/reagents(50)
		R.my_atom = vent
		R.add_reagent(pick(gunk), 50)

		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(R, vent, TRUE)
		playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
		smoke.start(3)
		qdel(R)
