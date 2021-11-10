/obj/machinery/disposal/big // Nada mas cosmetico
	name = "big disposal unit"
	desc = "A big pneumatic waste disposal unit."
	icon = 'icons/hispania/obj/pipes/disposal.dmi'

/obj/structure/disposalpipe/junction/brigespecial/nextdir(fromdir)
// El sortjunction funcionaba por probabilidad cuando viene de la entrada secundaria
// Este siempre saldra por el setbit, evitando problemas con los tubos en el perma de DABABYV2
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)	// came from secondary dir
		return dir		// so exit through primary
	else				// came from primary
						// so need to choose either secondary exit
		var/mask = ..(fromdir)

		// find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		return mask & (~setbit)
