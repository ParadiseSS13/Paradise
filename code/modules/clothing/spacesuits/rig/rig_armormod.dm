/obj/item/clothing/suit/space/new_rig/calc_breach_damage()
	..()
	holder.update_armor()		//New dammage, new armormultiplikator.
	return damage

/obj/item/rig/proc/update_armor()
	var/multi = 1					//Multiplicative modification to the armor, maybe add an additive later on
	if(chest)
		multi *= (100 - chest.damage) / 100			//If we have some breaches, lower the armor value.

	//TODO check for other armor mods, likely modules, which need to be coded.

	for(var/obj/item/piece in list(gloves, helmet, boots, chest))
		if(!istype(piece))			//Do we have the piece
			continue
		if(islist(armor))				//Did we even give them some armor, if this is the case, the list should be initialized from New()
			var/list/L = armor
			for(var/armortype in L)
				piece.armor[armortype] = L[armortype]*multi

//Perfect place to also add something like shield modules, or any other hit_reaction modules check.
