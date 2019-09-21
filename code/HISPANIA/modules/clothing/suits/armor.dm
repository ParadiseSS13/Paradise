///Hispania Armors///

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Code by Danaleja2005

/obj/item/clothing/suit/armor/vest/captrenchcoat
	name = "captain's trench coat"
	desc = "A special trenchcoat made with nanofibers of high resistance to melee, laser and projectile attacks, exclusive use for station captains. Made by D&N Corp"
	icon = 'icons/hispania/mob/suit.dmi'
	icon_state = "Captain_TrenchCoat"
	item_state = "Captain_TrenchCoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(melee = 55, bullet = 45, laser = 55, energy = 20, bomb = 25, bio = 0, rad = 0)
	dog_fashion = null
	hispania_icon = TRUE