/obj/item/gun/Initialize()
	. = ..()

	icon = (hispania_icon ? 'modular_hispania/icons/obj/guns/projectile.dmi' : icon)
	lefthand_file = (hispania_icon ? 'modular_hispania/icons/mob/inhands/guns_lefthand.dmi' : lefthand_file)
	righthand_file = (hispania_icon ? 'modular_hispania/icons/mob/inhands/guns_righthand.dmi' : righthand_file)
