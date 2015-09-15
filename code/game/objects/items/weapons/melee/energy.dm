/obj/item/weapon/melee/energy
	var/active = 0
	no_embed = 1 // Physically impossible for energy weapons to embed themselves into people, this should fix that. -- Dave
	hitsound = 'sound/weapons/blade1.ogg' // Probably more appropriate than the previous hitsound. -- Dave

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	viewers(user) << pick("<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='suicide'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	hitsound = "swing_hit"
	flags = CONDUCT | NOSHIELD
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = 1
	edge = 1


/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>"
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	var/hacked = 0
	var/blade_color
	color
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	hitsound = "swing_hit"
	flags = NOSHIELD
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = 1
	edge = 1

/obj/item/weapon/melee/energy/sword/cyborg
	var/hitcost = 250

/obj/item/weapon/melee/energy/sword/cyborg/attack(mob/M, var/mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/weapon/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self()
			R << "<span class='notice'>It's out of charge!</span>"
			return
		//C.use(hitcost)
		..()
	return

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"

/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 30.0 //Normal attacks deal esword damage
	sharp = 1
	edge = 1
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 1
	throw_range = 1
	w_class = 4.0//So you can't hide it in your pocket or some such.
	flags = NOSHIELD
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/datum/effect/effect/system/spark_spread/spark_system
