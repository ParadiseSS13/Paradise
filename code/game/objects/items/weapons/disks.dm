/obj/item/weapon/disk
	name = "disk"
	icon = 'icons/obj/items.dmi'

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

/*
/obj/item/weapon/disk/nuclear/pickup(mob/living/user as mob)
	if(issyndicate(user))
		set_security_level(3)*/     //Nuke Ops rework makes stealth approach significantly harder; this makes it damn near impossible; besides, it's horrendously meta.