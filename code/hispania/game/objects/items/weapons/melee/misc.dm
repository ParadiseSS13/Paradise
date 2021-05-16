///Melee Weapons of Hispania/

///wooden sword///
/obj/item/melee/woodensword
	name = "wooden sword"
	desc = "A wooden sword made with wood and duct tape"
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "woodsword"
	item_state = "woodsword"
	force = 8
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 0
	armour_penetration = 0
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	hispania_icon = TRUE

/obj/item/melee/woodensword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
    if(attack_type == MELEE_ATTACK)
        final_block_chance += 20
    if(attack_type == THROWN_PROJECTILE_ATTACK)
        final_block_chance += 40
    return ..()

///ram///
/obj/item/twohanded/required/ram
	name = "ram"
	desc = "A heavy ram used to take down those annoying doors or other structures in your way."
	icon = 'icons/hispania/obj/items.dmi'
	icon_state = "ram"
	item_state = "ram"
	force = 10
	throwforce = 24
	throw_range = 3
	force_wielded = 20 // La fire-axe hace 24
	attack_verb = list("rammed")
	hitsound = 'sound/hispania/weapons/ram.ogg'
	usesound = 'sound/hispania/weapons/ram.ogg'
	max_integrity = 100
	hispania_icon = TRUE
	var/ramming = FALSE

/obj/item/twohanded/required/ram/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(istype(target, /obj/machinery/door/airlock) || istype(target, /obj/structure/door_assembly) || \
	istype(target, /obj/machinery/door/window) || istype(target, /obj/structure/window) || \
	istype(target, /obj/structure/grille) || istype(target, /obj/structure/table) || \
	istype(target, /obj/structure/barricade) || istype(target, /obj/structure/closet))
		if(ramming)
			to_chat(user, "<span class='warning'>You are already ramming!</span>")
			return
		var/obj/A = target
		ramming = TRUE
		while(A.obj_integrity > 0)
			if(!proximity)
				return
			playsound(get_turf(A), 'sound/hispania/weapons/ram.ogg', 150, 1, -1)
			if(!do_after(usr, 10, target = A))
				ramming = FALSE
				return
			user.do_attack_animation(A)
			to_chat(viewers(user), "<span class='danger'>[user] rams [A]!</span>")
			if(A.obj_integrity <= 120 && istype(target, /obj/machinery/door/airlock)) // Si el golpe va a romper el airlock dejame manejarlo yo
				var/obj/machinery/door/airlock/loqueodeaire = target
				if(!(loqueodeaire.flags & BROKEN))
					loqueodeaire.obj_break() // Por si las moscas si no estaba roto ya, mas que todo por el humo.
				loqueodeaire.deconstruct(TRUE, null, FALSE) // El ultimo argumento hara que no deje el assembly al romperse
			else
				A.take_damage(120, damtype, "melee", 1)
		ramming = FALSE
