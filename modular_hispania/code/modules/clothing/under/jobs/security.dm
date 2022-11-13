///Hispania Security Department Clothes

/*Nota: todos los sprites que sean pertenecientes al code hispania y tengan sus
respectivos sprites en las carpetas de iconos de hispania , es decir modular_hispania/icons
deberan tener una linea de codigo demas para que funcionen "hispania_icon = TRUE"*/

//Security Formal Uniform and Formal Pod Pilot's jumpsuit (Danaleja2005)
/obj/item/clothing/under/rank/security/private
	name = "formal blue security officer's uniform"
	desc = "A formal security officer's uniform, it has a logo that says 'Security Department'. Made by D&N Corp."
	icon = 'modular_hispania/icons/mob/uniform.dmi'
	icon_state = "oficialblue"
	item_color = "oficialblue"
	hispania_icon = TRUE
	sprite_sheets = list(
		"Vox" = 'modular_hispania/icons/mob/species/vox/uniform.dmi',
		"Grey" = 'modular_hispania/icons/mob/species/grey/uniform.dmi'
		)

/obj/item/clothing/under/rank/security/private/red
	name = "formal red security officer's uniform"
	icon_state = "oficialred"
	item_color = "oficialred"

/obj/item/clothing/under/rank/security/pod_pilot/formal
	name = "formal pod pilot's jumpsuit"
	desc = "A formal security pod pilot's jumpsuit, its have a medal says Security Air Force."
	icon = 'modular_hispania/icons/mob/uniform.dmi'
	icon_state = "podpilot_formal"
	item_color = "podpilot_formal"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Grey", "Vox")

//Pod Pilot
/obj/item/clothing/under/rank/security/pod_pilot
	name = "pod pilot's jumpsuit"
	desc = "Suit for your regular pod pilot."
	icon_state = "pod_pilot"
	item_state = "pod_pilot"
	item_color = "pod_pilot"

/obj/item/clothing/under/rank/security/brigphys
	name = "brig physician's jumpsuit"
	desc = "Jumpsuit for Brig Physician it has both medical and security protection."
	icon_state = "brig_phys"
	item_state = "brig_phys"
	item_color = "brig_phys"
	permeability_coefficient = 0.50
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 30, acid = 30)
