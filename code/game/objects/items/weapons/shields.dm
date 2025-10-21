/obj/item/shield
	name = "shield"
	icon = 'icons/obj/weapons/shield.dmi'
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, RAD = 0, FIRE = 80, ACID = 70)

/obj/item/shield/proc/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = ALL_ATTACK_TYPES)

/obj/item/shield/Initialize(mapload)
	. = ..()
	add_parry_component()

/obj/item/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == LEAP_ATTACK)
		final_block_chance = 100
	return ..()

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	slot_flags = ITEM_SLOT_BACK
	force = 10
	throwforce = 5
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_GLASS=7500, MAT_METAL=1000)
	origin_tech = "materials=3;combat=4"
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	var/list/allowed_bashers = list(/obj/item/melee/baton, /obj/item/kitchen/knife/combat)

/obj/item/shield/riot/attackby__legacy__attackchain(obj/item/W, mob/user, params)
	if(is_type_in_list(W, allowed_bashers))
		if(cooldown < world.time - 2.5 SECONDS)
			user.visible_message("<span class='warning'>[user] bashes [src] with [W]!</span>")
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else
		..()

/obj/item/shield/riot/roman
	name = "roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	materials = list(MAT_METAL=8500)

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	armor = null

/obj/item/shield/riot/roman/fake/add_parry_component()
	return

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	materials = list()
	origin_tech = "materials=1;combat=3;biotech=2"
	resistance_flags = FLAMMABLE

/obj/item/shield/riot/buckler/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (10 / 3) SECONDS) // 2.3333 seconds of cooldown for 30% uptime

/obj/item/shield/riot/bone
	name = "bone shield"
	desc = "A primitive yet durable shield made from bone."
	icon_state = "bone_shield"
	materials = list()
	origin_tech = "materials=1;combat=3;biotech=4"
	resistance_flags = FLAMMABLE

/obj/item/shield/riot/bone/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 3, _stamina_coefficient = 0.6, _parryable_attack_types = ALL_ATTACK_TYPES)

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
	var/active = FALSE

/obj/item/shield/energy/add_parry_component()
	return

/obj/item/shield/energy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(isprojectile(hitby))
		var/obj/item/projectile/P = hitby
		if(P.shield_buster && active)
			toggle(owner, TRUE)
			to_chat(owner, "<span class='warning'>[hitby] overloaded your [src]!</span>")
	return 0

/obj/item/shield/energy/IsReflect()
	return (active)

/obj/item/shield/energy/attack_self__legacy__attackchain(mob/living/carbon/human/user)
	toggle(user, FALSE)

/obj/item/shield/energy/proc/toggle(mob/living/carbon/human/user, forced)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && !forced)
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
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	if(!forced)
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
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_GLASS = 4000, MAT_METAL = 1000)

/obj/item/shield/riot/tele/add_parry_component()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.7, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (5 / 3) SECONDS, _requires_activation = TRUE)

/obj/item/shield/riot/tele/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		return ..()
	return FALSE // by not calling the parent the hit_reaction signal is never sent

/obj/item/shield/riot/tele/attack_self__legacy__attackchain(mob/living/user)
	if(HAS_TRAIT(src, TRAIT_ITEM_ACTIVE))
		REMOVE_TRAIT(src,TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	else
		ADD_TRAIT(src, TRAIT_ITEM_ACTIVE, TRAIT_GENERIC)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, "<span class='notice'>You extend \the [src].</span>")
	icon_state = "teleriot[HAS_TRAIT(src, TRAIT_ITEM_ACTIVE)]"
	playsound(loc, 'sound/weapons/batonextend.ogg', 50, TRUE)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	return
