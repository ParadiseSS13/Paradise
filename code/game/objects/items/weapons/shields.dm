/obj/item/shield
	name = "shield"
	block_chance = 50
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == THROWN_PROJECTILE_ATTACK)
		final_block_chance += 30
	if(owner.is_in_active_hand(src))
		final_block_chance += 15
	else
		final_block_chance -= 10
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	return ..()

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	slot_flags = SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_GLASS=7500, MAT_METAL=1000)
	origin_tech = "materials=3;combat=4"
	attack_verb = list("shoved", "bashed")
	hispania_icon = TRUE
	var/cooldown = 0 //shield bash cooldown. based on world.time

/obj/item/shield/riot/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	hispania_icon = FALSE
	materials = list(MAT_METAL=8500)

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	block_chance = 0
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	materials = list()
	origin_tech = "materials=1;combat=3;biotech=2"
	resistance_flags = FLAMMABLE
	hispania_icon = FALSE
	block_chance = 30

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere."
	icon_state = "eshield0" // eshield1 for expanded
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "materials=4;magnets=5;syndicate=6"
	attack_verb = list("shoved", "bashed")
	hispania_icon = FALSE
	var/active = 0

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/shield/energy/IsReflect()
	return (active)

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='warning'>You beat yourself in the head with [src].</span>")
		user.take_organ_damage(5)
	active = !active
	icon_state = "eshield[active]"

	if(active)
		force = 10
		throwforce = 8
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	origin_tech = "materials=3;combat=4;engineering=4"
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	hispania_icon = FALSE
	w_class = WEIGHT_CLASS_NORMAL
	var/active = 0

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(active)
		return ..()
	return 0

/obj/item/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = SLOT_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return
