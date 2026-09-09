// SINGULOHAMMER.
/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "singulohammer0"
	base_icon_state = "singulohammer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/charged = 2
	origin_tech = "combat=4;bluespace=4;plasmatech=7"
	new_attack_chain = TRUE

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.25, _parryable_attack_types = ALL_ATTACK_TYPES, _parry_cooldown = (4 / 3) SECONDS, _requires_two_hands = TRUE) // 0.3333 seconds of cooldown for 75% uptime
	AddComponent(/datum/component/two_handed, \
		force_wielded = 40, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")
	START_PROCESSING(SSobj, src)

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/process()
	if(charged < 2)
		charged++

/obj/item/singularityhammer/update_icon_state()  // Currently only here to fuck with the on-mob icons.
	icon_state = "singulohammer0"

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/movable/X in range(5, pull))
		if(X.move_resist == INFINITY)
			continue
		if(X == wielder)
			continue
		if((X) && (!X.anchored) && (!ishuman(X)))
			step_towards(X, pull)
			step_towards(X, pull)
			step_towards(X, pull)
		else if(ishuman(X))
			var/mob/living/carbon/human/H = X
			if(HAS_TRAIT(H, TRAIT_MAGPULSE))
				continue
			H.Weaken(4 SECONDS)
			step_towards(H, pull)
			step_towards(H, pull)
			step_towards(H, pull)

/obj/item/singularityhammer/after_attack(mob/living/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()
	if(charged < 2)
		return ..()
	charged = 0
	if(isliving(target))
		target.take_organ_damage(20, 0)
	playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
	var/turf/target_turf = get_turf(target)
	vortex(target_turf, user)
	return FINISH_ATTACK

/obj/item/mjollnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = "combat=4;powerstorage=7"
	new_attack_chain = TRUE

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, \
		_requires_two_hands = TRUE) // 0.3333 seconds of parry cooldown for 75% uptime.
	AddComponent(/datum/component/two_handed, \
		force_wielded = 25, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")

/obj/item/mjollnir/proc/shock(mob/living/target)
	do_sparks(5, 1, target.loc)
	target.visible_message(
		SPAN_DANGER("[target] was shocked by [src]!"),
		SPAN_USERDANGER("You feel a powerful shock course through your body sending you flying!"),
		SPAN_DANGER("You hear a heavy electrical crack!")
	)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)

/obj/item/mjollnir/after_attack(mob/living/target, mob/user, proximity_flag, click_parameters)
	if(!isliving(target))
		return ..()

	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return ..()

	playsound(loc, "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	target.Stun(6 SECONDS)
	shock(target)
	return FINISH_ATTACK

/obj/item/mjollnir/throw_impact(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		L.Stun(6 SECONDS)
		shock(L)

/obj/item/mjollnir/update_icon_state()  // Currently only here to fuck with the on-mob icons.
	icon_state = "mjollnir0"

/obj/item/knighthammer
	name = "singuloth knight's hammer"
	desc = "A hammer made of sturdy metal with a golden skull adorned with wings on either side of the head. <br>This weapon causes devastating damage to those it hits due to a power field sustained by a mini-singularity inside of the hammer."
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	icon = 'icons/obj/weapons/magical_weapons.dmi'
	icon_state = "knighthammer0"
	base_icon_state = "knighthammer"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	var/charged = 5
	origin_tech = "combat=5;bluespace=4"
	new_attack_chain = TRUE

/obj/item/knighthammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/parry, \
		_stamina_constant = 2, \
		_stamina_coefficient = 0.25, \
		_parryable_attack_types = ALL_ATTACK_TYPES, \
		_parry_cooldown = (4 / 3) SECONDS, \
		_requires_two_hands = TRUE) // 0.3333 seconds of parry cooldown for 75% uptime.
	AddComponent(/datum/component/two_handed, \
		force_wielded = 30, \
		force_unwielded = force, \
		icon_wielded = "[base_icon_state]1")

/obj/item/knighthammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/knighthammer/process()
	if(charged < 5)
		charged++

/obj/item/knighthammer/update_icon_state()  // Currently only here to fuck with the on-mob icons.
	icon_state = "knighthammer0"

/obj/item/knighthammer/after_attack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return FINISH_ATTACK
	if(charged < 5)
		return ..()

	charged = 0
	if(isliving(target))
		var/mob/living/Z = target
		if(Z.health > HEALTH_THRESHOLD_CRIT)
			Z.visible_message(
				SPAN_DANGER("[Z.name] was sent flying by a blow from [src]!"),
				SPAN_USERDANGER("You feel a powerful blow connect with your body and send you flying!"),
				SPAN_DANGER("You hear something heavy impact flesh!")
			)
			var/atom/throw_target = get_edge_target_turf(Z, get_dir(src, get_step_away(Z, src)))
			Z.throw_at(throw_target, 200, 4)
		// Target is in crit, check if we're holding securely enough to gib them.
		else if(HAS_TRAIT(src, TRAIT_WIELDED))
			Z.visible_message(
				SPAN_DANGER("[Z.name] was blown to pieces by the power of [src]!"),
				SPAN_USERDANGER("You feel a powerful blow rip you apart!"),
				SPAN_DANGER("You hear a heavy impact and the sound of ripping flesh!")
			)
			Z.gib()
		playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
		return FINISH_ATTACK
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(iswallturf(target))
			var/turf/simulated/wall/Z = target
			Z.ex_act(EXPLODE_HEAVY)
		else if(isstructure(target) || ismecha(target))
			var/obj/Z = target
			Z.ex_act(EXPLODE_HEAVY)
		charged = 3
		playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
	return FINISH_ATTACK
