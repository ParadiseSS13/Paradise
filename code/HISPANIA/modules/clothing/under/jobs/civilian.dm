///Hispania Civilians Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

// Captain Formal uniform by Danaleja
/obj/item/clothing/under/rank/command/captain/formal/dark
	name = "captain's formal blue uniform"
	desc = "A nice and formal uniform made of silk, only for station captains. Made by D&N Corp."
	icon = 'icons/hispania/mob/uniform.dmi'
	icon_state = "captain_dark"
	item_state = "captain_dark_s"
	item_color = "captain_dark"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

/obj/item/clothing/under/rank/command/captain/formal/light
	name = "captain's formal white uniform"
	desc = "A nice and formal uniform made of silk, only for station captains. Made by D&N Corp."
	icon = 'icons/hispania/mob/uniform.dmi'
	icon_state = "captain_light"
	item_state = "captain_light_s"
	item_color = "captain_light"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")
