/obj/item/weapon/melee/energy
	var/active = 0
	var/force_on = 30 //force when active
	var/throwforce_on = 20
	w_class = 2
	var/w_class_on = 4
	var/icon_state_on = "axe1"
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	no_embed = 1 // Physically impossible for energy weapons to embed themselves into people, this should fix that. -- Dave
	hitsound = 'sound/weapons/blade1.ogg' // Probably more appropriate than the previous hitsound. -- Dave

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='suicide'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/attack_self(mob/living/carbon/user)
	if(user.disabilities & CLUMSY && prob(50))
		to_chat(user, "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>")
		user.take_organ_damage(5,5)
	active = !active
	if(active)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/blade1.ogg'
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(!item_color)
			icon_state = icon_state_on
		else
			icon_state = "sword[item_color]"
		w_class = w_class_on
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1) //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	throw_speed = 3
	throw_range = 5
	w_class = 3
	w_class_on = 5
	hitsound = "swing_hit"
	flags = CONDUCT
	armour_penetration = 100
	origin_tech = "combat=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()
	sharp = 1
	edge = 1

/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	hitsound = "swing_hit"
	armour_penetration = 35
	origin_tech = "magnets=3;syndicate=4"
	block_chance = 50
	sharp = 1
	edge = 1
	var/hacked = 0
	var/blade_color

/obj/item/weapon/melee/energy/sword/New()
	if(item_color == null)
		item_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(active)
		return ..()
	return 0

/obj/item/weapon/melee/energy/sword/cyborg
	var/hitcost = 50

/obj/item/weapon/melee/energy/sword/cyborg/attack(mob/M, var/mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/weapon/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self()
			to_chat(R, "<span class='notice'>It's out of charge!</span>")
			return
		..()
	return

/obj/item/weapon/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	force_on = 30
	force = 18 //About as much as a spear
	sharp = 1
	edge = 1
	hitsound = 'sound/weapons/circsawhit.ogg'
	origin_tech = "materials=3;biotech=3;syndicate=3"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	hitcost = 75 //Costs more than a standard cyborg esword
	item_color = null
	w_class = 3

/obj/item/weapon/melee/energy/sword/cyborg/saw/New()
	..()
	item_color = null

/obj/item/weapon/melee/energy/sword/cyborg/saw/hit_reaction()
	return 0

/obj/item/weapon/melee/energy/sword/saber

/obj/item/weapon/melee/energy/sword/saber/blue
	item_color = "blue"

/obj/item/weapon/melee/energy/sword/saber/purple
	item_color = "purple"

/obj/item/weapon/melee/energy/sword/saber/green
	item_color = "green"

/obj/item/weapon/melee/energy/sword/saber/red
	item_color = "red"

/obj/item/weapon/melee/energy/sword/saber/attackby(obj/item/weapon/W, mob/living/user, params)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword/saber))
		if(W == src)
			to_chat(user, "<span class='notice'>You try to attach the end of the energy sword to... itself. You're not very smart, are you?</span>")
			if(ishuman(user))
				user.adjustBrainLoss(10)
		else
			to_chat(user, "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>")
			var/obj/item/weapon/twohanded/dualsaber/newSaber = new /obj/item/weapon/twohanded/dualsaber(user.loc)
			if(src.hacked) // That's right, we'll only check the "original" esword.
				newSaber.hacked = 1
				newSaber.item_color = "rainbow"
			user.unEquip(W)
			user.unEquip(src)
			qdel(W)
			qdel(src)
			user.put_in_hands(newSaber)
	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			item_color = "rainbow"
			to_chat(user, "<span class='warning'>RNBW_ENGAGE</span>")

			if(active)
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand()
				else if(user.l_hand == src)
					user.update_inv_l_hand()

		else
			to_chat(user, "<span class='warning'>It's already fabulous!</span>")

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	icon_state_on = "cutlass1"

/obj/item/weapon/melee/energy/sword/pirate/New()
	return

/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 30
	sharp = 1
	edge = 1
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = 4//So you can't hide it in your pocket or some such.
	armour_penetration = 50
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/datum/effect/system/spark_spread/spark_system

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/melee/energy/blade/dropped()
	qdel(src)

/obj/item/weapon/melee/energy/blade/attack_self(mob/user)
	return