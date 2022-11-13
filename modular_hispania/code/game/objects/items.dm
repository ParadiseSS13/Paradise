
/obj/item

	var/hispania_icon = FALSE

/obj/item/Initialize()
	..()

	icon = (hispania_icon ? 'modular_hispania/icons/obj/items.dmi' : icon)
	lefthand_file = (hispania_icon ? 'modular_hispania/icons/mob/inhands/items_lefthand.dmi' : lefthand_file)
	righthand_file = (hispania_icon ? 'modular_hispania/icons/mob/inhands/items_righthand.dmi' : righthand_file)
