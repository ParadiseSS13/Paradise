	///Hispania Armors///

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir modular_hispania/icons
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Code by Danaleja2005
/obj/item/clothing/suit/armor/vest/captrenchcoat
	name = "captain's trench coat"
	desc = "A special trenchcoat made with nanofibers of high resistance to melee, laser and projectile attacks, exclusive use for station captains. Made by D&N Corp"
	icon = 'modular_hispania/icons/mob/suit.dmi'
	icon_state = "captain_trenchcoat"
	item_state = "captain_trenchcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 90)
	dog_fashion = null
	hispania_icon = TRUE
	resistance_flags = FIRE_PROOF
	species_restricted = list("exclude", "Grey", "Vox")

//Code by gingungangingungan
/obj/item/clothing/suit/armor/hos/ranger
	name = "armored security ranger"
	desc = "A riot armor used in desert operations, represent law and justice!."
	icon = 'modular_hispania/icons/mob/suit.dmi'
	icon_state = "riot_rangerw2"
	item_state = "riot_rangerw2"
	flags_inv = 0
	ignore_suitadjust = 1
	hispania_icon = TRUE
	species_restricted = list("Human", "Slime", "Machine", "Kidan", "Skrell", "Diona" )

/obj/item/clothing/suit/storage/brigdoc
	name = "brig physician's vest"
	desc = "A vest often worn by doctors caring for inmates."
	icon_state = "brigphysician-vest"
	item_state = "brigphysician-vest"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, \
	/obj/item/radio, /obj/item/tank/internals/emergency_oxygen)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 50, acid = 50)

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)
