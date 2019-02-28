/datum/reagent/virushcure //Puesto aqui dado que aun no se puede adquirir si no es dado por un administrador.
	name = "Mother cell stabilizer"
	id = "virushcure"
	description = "Heals the mother cells"
	reagent_state = LIQUID
	color = "#61337c"
	overdose_threshold = 5

/datum/reagent/virushcure/on_mob_life(mob/living/M)
	M.Druggy(30)
	M.AdjustHallucinate(20)
	return ..()

/datum/reagent/virushcure/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(10, FALSE)
	return list(0, update_flags)