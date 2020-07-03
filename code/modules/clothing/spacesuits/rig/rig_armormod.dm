/obj/item/clothing/suit/space/new_rig/calc_breach_damage()
	..()
	holder.update_armor()		//New dammage, new armormultiplikator.
	return damage

/obj/item/rig/proc/update_armor()
	var/multi = 1					//Multiplicative modification to the armor, maybe add an additive later on
	if(chest)
		multi *= (100 - chest.damage) / 100			//If we have some breaches, lower the armor value.

	//TODO check for other armor mods, likely modules, which need to be coded.
	if(!armor)				//Did we even give them some armor, if this is the case, the list should be initialized from New()
		return

	var/datum/armor/A = armor
	for(var/obj/item/piece in list(gloves, helmet, boots, chest))
		if(!istype(piece))			//Do we have the piece
			continue

		piece.armor = piece.armor.setRating(melee_value = A.getRating("melee") * multi,
											bullet_value = A.getRating("bullet") * multi,
											laser_value = A.getRating("laser") * multi,
											energy_value = A.getRating("energy") * multi,
											bomb_value = A.getRating("bomb") * multi,
											bio_value = A.getRating("bio") * multi,
											rad_value = A.getRating("rad") * multi,
											fire_value = A.getRating("fire") * multi,
											acid_value = A.getRating("acidd") * multi)

//Perfect place to also add something like shield modules, or any other hit_reaction modules check.
