/obj/item/weapon/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity"
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	canRwall = 1
	icon_state = "arcd"

/obj/item/weapon/construction/rcd/arcd/afterattack(atom/A, mob/user)
	range_check(A,user)
	if(target_check(A,user))
		user.Beam(A,icon_state="rped_upgrade",time=30)
	..()
