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

/obj/item/clothing/under/rank/chaplain/elzra
	name = "Elzra's Acolyte Robes"
	desc = "A long acolyte robes for the high religious priests of the order of the great lady (lady elzra) made of silk. Made by D&N Corp."
	icon_state = "elzramale"
	item_state = "elzramale"
	item_color = "elzramale"
	hispania_icon = TRUE
	over_shoe = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

/obj/item/clothing/under/rank/chaplain/elzra/female
	name = "Elzra's Acolyte Female Robes"
	desc = "A female long acolyte robes for high religious priests of the order of the great lady (lady elzra) made of silk, it have a small ruby on it. Made by D&N Corp."
	icon_state = "elzrafem"
	item_state = "elzrafem"
	item_color = "elzrafem"
	over_shoe = TRUE

/obj/item/clothing/under/rank/chaplain/alt
	name = "Priest's Uniform"
	icon = 'icons/hispania/mob/uniform.dmi'
	desc = "A set of special shirt, pants and clergyman worn by priests. Made by D&N Corp."
	icon_state = "chapalt"
	item_state = "chapalt"
	item_color = "chapalt"
	species_restricted = list("exclude", "Grey", "Vox")
	hispania_icon = TRUE	

/obj/item/clothing/under/rank/chaplain/alt/blue
	name = "Priest's Blue Uniform"
	desc = "A set of special shirt, pants and clergyman worn by priests. Made by D&N Corp."
	icon_state = "chapaltblue"
	item_state = "chapaltblue"
	item_color = "chapaltblue"

/obj/item/clothing/under/rank/chaplain/cassock
	name = "Cassock"
	desc = "a long black garment worn by christian priests. Made by D&N Corp."
	icon_state = "cassock"
	item_state = "cassock"	
	item_color = "cassock"
	species_restricted = list("exclude", "Grey", "Vox")
	over_shoe = TRUE
	hispania_icon = TRUE
