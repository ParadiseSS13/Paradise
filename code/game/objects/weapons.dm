/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/weapons.dmi'

/obj/item/weapon/New()
	..()
	if(!hitsound)
		if(damtype == BURN)
			hitsound = 'sound/items/welder.ogg'
		if(damtype == BRUTE)
			hitsound = "swing_hit"