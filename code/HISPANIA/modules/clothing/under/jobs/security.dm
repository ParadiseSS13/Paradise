///Hispania Security Department Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir icons/hispania
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Security Formal Uniform and Formal Pod Pilot's jumpsuit (Danaleja2005)
/obj/item/clothing/under/rank/security/private
	name = "formal blue security officer's uniform"
	desc = "A formal security officer's uniform, its have a logo says Security Department. Made by D&N Corp."
	icon = 'icons/hispania/mob/uniform.dmi'
	icon_state = "oficialblue_s"
	item_state = "oficialblue"
	item_color = "oficialblue"
	hispania_icon = TRUE
	sprite_sheets = list(
		"Vox" = 'icons/hispania/mob/species/vox/uniform.dmi',
		"Grey" = 'icons/hispania/mob/species/grey/uniform.dmi'
		)

/obj/item/clothing/under/rank/security/private/red
	name = "formal red security officer's uniform"
	desc = "A formal security officer's uniform, its have a logo says Security Department."
	icon = 'icons/hispania/mob/uniform.dmi'
	icon_state = "oficialred_s"
	item_state = "oficialred"
	item_color = "oficialred"
	hispania_icon = TRUE

/obj/item/clothing/under/rank/security/pod_pilot/formal
	name = "formal pod pilot's jumpsuit"
	desc = "A formal security pod pilot's jumpsuit, its have a medal says Security Air Force."
	icon = 'icons/hispania/mob/uniform.dmi'
	icon_state = "podpilot_formal"
	item_color = "podpilot_formal"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")
