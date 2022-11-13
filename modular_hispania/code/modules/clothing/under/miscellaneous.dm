///Hispania Civilians Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir modular_hispania/icons
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/


//BunnySuit by Danaleja2005(CODE), killer7luis(SPRITES)

/obj/item/clothing/under/bunnysuit
	name = "Black Bunny Suit"
	icon = 'modular_hispania/icons/mob/uniform.dmi'
	icon_state = "bunnysuit"
	item_state = "bunnysuit"
	item_color = "bunnysuit"
	desc = "A sexy bunny suit, it is black. Made by KCompanies and distributed by D&N."
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")


/obj/item/clothing/under/bunnysuit/red
	name = "Red Bunny Suit"
	icon = 'modular_hispania/icons/mob/uniform.dmi'
	icon_state = "bunnysuitred"
	item_state = "bunnysuitred"
	item_color = "bunnysuitred"
	desc = "A sexy bunny suit, it is red. Made by KCompanies and distributed by D&N."
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

/obj/item/clothing/under/dress
	over_shoe = TRUE

/obj/item/clothing/under/wedding
	over_shoe = TRUE
