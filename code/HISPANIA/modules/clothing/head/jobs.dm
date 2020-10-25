///Hispania Job Hats

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/



//Captain formal hat by Danaleja
/obj/item/clothing/head/caphat/dark
	name = "captain's formal blue hat"
	desc = "A nice and formal hat made of silk, only for station captains. Made by D&N Corp."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "caphat_dark"
	item_state = "caphat_dark"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

/obj/item/clothing/head/caphat/light
	name = "captain's formal white hat"
	desc = "A nice and formal hat made of silk, only for station captains. Made by D&N Corp."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "caphat_light"
	item_state = "caphat_light"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

//Private Sec Berets (Danaleja2005)
/obj/item/clothing/head/beret/sec/private
	name = "blue security beret"
	desc = "A blue security beret, its have a badge of Security Department. Made by D&N Corp."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "secberetprivateofficer_blue"
	item_state = "secberetprivateofficer_blue"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Vox", "Grey")

/obj/item/clothing/head/beret/sec/private/red
	name = "red security beret"
	desc = "A red security beret, its have a badge of Security Department. Made by D&N Corp."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "secberetprivateofficer_red"
	item_state = "secberetprivateofficer_red"
	hispania_icon = TRUE

/obj/item/clothing/head/officer/hat
	name = "officer's blue hat"
	desc = "A blue hat with a badge of Security Department. Made by D&N Corp."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "sechat_blue"
	item_state = "sechat_blue"
	strip_delay = 80
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey")
	sprite_sheets = list(
		"Vox" = 'icons/hispania/mob/species/vox/head.dmi'
		)

/obj/item/clothing/head/officer/hat/red
	name = "officer's red hat"
	desc = "A red hat with a badge of Security Department."
	icon = 'icons/hispania/mob/head.dmi'
	icon_state = "sechat_red"
	item_state = "sechat_red"
	hispania_icon = TRUE
