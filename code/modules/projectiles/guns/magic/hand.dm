/obj/item/weapon/gun/magic/hand
	name = "Readied Spell"
	desc = "Now you're playing with power! (and bugs. Report this as a bug!)"
	icon = 'icons/obj/weapons.dmi'
	flags = ABSTRACT | NODROP
	var/catchphrase = "OOPS SOME CODER MADE A MISTAKE"
	w_class = 5.0
	force = 0
	throwforce = 0
	throw_range = 0
	throw_speed = 0

/obj/item/weapon/gun/magic/hand/Fire(atom/target as mob|obj|turf|area, mob/living/carbon/user as mob|obj, params, reflex = 0)
	..()
	user.say(catchphrase)
	qdel(src)

/obj/item/weapon/gun/magic/hand/fireball
	name = "readied fireball"
	desc = "Don't pick your nose."

	// Should be close enough
	icon_state = "disintegrate"
	item_state = "disintegrate"
	projectile_type = "/obj/item/projectile/magic/fireball"
	catchphrase = "ONI SOMA"