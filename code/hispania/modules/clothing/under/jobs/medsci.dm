///Hispania MedSci Department Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Resprite of RD Uniform by Danaleja2005

/obj/item/clothing/under/rank/research_director
	icon_state = "rd"
	item_state = "rd"
	item_color = "rd"
	hispania_icon = TRUE
	icon = 'icons/hispania/mob/uniform.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/hispania/mob/species/vox/uniform.dmi',
		"Grey" = 'icons/hispania/mob/species/grey/uniform.dmi'
		)

/obj/item/clothing/under/rank/research_director/formal
	name = "research director's black formal uniform"
	desc = "A formal uniform with a tie and a badge, it says Research Director"
	icon_state = "rd_black"
	item_color = "rd_black"
	species_restricted = list("exclude", "Grey", "Vox")


/obj/item/clothing/under/rank/research_director/formal/purple
	name = "research director's purple formal uniform"
	icon_state = "rd_purple"
	item_color = "rd_purple"

