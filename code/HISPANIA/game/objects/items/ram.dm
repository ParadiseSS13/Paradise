/obj/item/twohanded/required/ram
	name = "ram"
	desc = "A heavy ram used to take down those pesky doors. "
	icon = 'icons/hispania/obj/ram.dmi'
	icon_state = "ram"
	item_state = "ram"
	force = 60
	throwforce = 15
	force_wielded = 8
	attack_verb = list("rammed")
	hitsound = 'sound/hispania/weapons/ram.ogg'
	usesound = 'sound/hispania/weapons/ram.ogg'
	max_integrity = 100

/obj/item/twohanded/required/ram/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/A = target
		while(A.obj_integrity > 0)
			if(!do_after(src, 20, target = A))
				return
			A.take_damage(force, damtype, "melee", 1)