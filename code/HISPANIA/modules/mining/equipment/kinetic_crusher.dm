/obj/item/twohanded/kinetic_crusher
	var/proyectile_type = /obj/item/projectile/destabilizer/cursed

/obj/item/twohanded/kinetic_crusher/cursed
	name = "cursed-kinetic crusher"
	desc = "This kinetic crusher... it's alive?"
	icon = 'icons/hispania/obj/kinetic_crusherc.dmi'
	icon_state = "cursed_crasher"
	item_state = "crusher0"
	lefthand_file = 'icons/hispania/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/items_righthand.dmi'
	charge_time = 5
	force_wielded = 30
	detonation_damage = 90
	backstab_bonus = 80
	flags = NODROP

/obj/item/projectile/destabilizer/cursed
	name = "cursed force"
	icon = 'icons/hispania/obj/projectiles.dmi'
	icon_state = "cursed_force"

