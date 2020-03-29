/obj/item/twohanded/required/ram
	name = "ram"
	desc = "A heavy ram used to take down those pesky doors. "
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "ram"
	item_state = "ram"
	force = 8
	throwforce = 12
	force_wielded = 8
	attack_verb = list("rammed")
	hitsound = 'sound/hispania/weapons/ram.ogg'
	usesound = 'sound/hispania/weapons/ram.ogg'
	max_integrity = 100
	hispania_icon = TRUE
	var/ramming = FALSE

/obj/item/twohanded/required/ram/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock) || istype(target, /obj/structure/door_assembly))
		var/obj/machinery/door/A = target
		if(ramming)
			to_chat(user, "<span class='danger'>You are already ramming the airlock!</span>")
			return
		ramming = TRUE
		while(A.obj_integrity > 0)
			playsound(get_turf(A), 'sound/hispania/weapons/ram.ogg', 100, 1, -1)
			if(!do_after(user, 20, target = A))
				return
			A.take_damage(120, damtype, "melee", 1)
		ramming = FALSE