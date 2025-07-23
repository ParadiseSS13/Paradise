/obj/item/pneumatic_cannon
	name = "pneumatic cannon"
	desc = "A gas-powered cannon that can fire any object loaded into it."
	icon = 'icons/obj/pneumaticCannon.dmi'
	icon_state = "pneumaticCannon"
	inhand_icon_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 60, ACID = 50)
	w_class = WEIGHT_CLASS_BULKY
	force = 8 //Very heavy
	attack_verb = list("bludgeoned", "smashed", "beaten")
	new_attack_chain = TRUE
	///The max weight of items that can fit into the cannon
	var/max_weight_class = 20
	///The weight of items currently in the cannon
	var/loaded_weight_class = 0
	///The gas tank that is drawn from to fire things
	var/obj/item/tank/internals/tank = null
	///If the cannon needs a tank at all
	var/requires_tank = TRUE
	///How many moles of gas is drawn from a tank's pressure to fire
	var/gas_per_throw = 3
	///The items loaded into the cannon that will be fired out
	var/list/loaded_items = list()
	///How powerful the cannon is - higher pressure = more gas but more powerful throws
	var/pressure_setting = 1
	///In case we want a really strong cannon
	var/max_pressure_setting = 3

/obj/item/pneumatic_cannon/Destroy()
	QDEL_NULL(tank)
	QDEL_LIST_CONTENTS(loaded_items)
	return ..()

/obj/item/pneumatic_cannon/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
	else
		if(tank)
			. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>"
		for(var/obj/item/I in loaded_items)
			. += "<span class='notice'>[bicon(I)] It has [I] loaded.</span>"

/**
* Arguments:
* * I - item to load into the cannon
* * user - the person loading the item in
* * Returns:
* * True if item was loaded, false if it failed
*/
/obj/item/pneumatic_cannon/proc/load_item(obj/item/I, mob/user)
	if((loaded_weight_class + I.w_class) > max_weight_class)
		to_chat(user, "<span class='warning'>[I] won't fit into [src]!</span>")
		return FALSE
	if(I.w_class > w_class)
		to_chat(user, "<span class='warning'>[I] is too large to fit into [src]!</span>")
		return FALSE
	if(!user.unequip(I) || I.flags & (ABSTRACT | NODROP | DROPDEL))
		to_chat(user, "<span class='warning'>You can't put [I] into [src]!</span>")
		return FALSE
	loaded_items.Add(I)
	loaded_weight_class += I.w_class
	I.forceMove(src)
	return TRUE

/obj/item/pneumatic_cannon/wrench_act(mob/living/user, obj/item/I)
	adjust_setting(user)
	return TRUE

/obj/item/pneumatic_cannon/proc/adjust_setting(mob/living/user)
	if(pressure_setting == max_pressure_setting)
		pressure_setting = 1
	else
		pressure_setting++
	to_chat(user, "<span class='notice'>You tweak [src]'s pressure output to [pressure_setting].</span>")

/obj/item/pneumatic_cannon/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/tank/internals) && !tank)
		if(istype(used, /obj/item/tank/internals/emergency_oxygen))
			to_chat(user, "<span class='warning'>[used] is too small for [src].</span>")
			return ITEM_INTERACT_COMPLETE
		add_tank(used, user)
		return ITEM_INTERACT_COMPLETE
	if(used.type == type)
		to_chat(user, "<span class='warning'>You're fairly certain that putting a pneumatic cannon inside another pneumatic cannon would cause a spacetime disruption.</span>")
		return ITEM_INTERACT_COMPLETE
	load_item(used, user)
	return ..()

/obj/item/pneumatic_cannon/screwdriver_act(mob/living/user, obj/item/I)
	remove_tank(user)
	return TRUE

/obj/item/pneumatic_cannon/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	fire(user, target)
	return ITEM_INTERACT_COMPLETE

/obj/item/pneumatic_cannon/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(get_turf(user) == get_turf(target))
		return ..()
	if(user.a_intent != INTENT_HELP) // I know this seems backwards but other guns also have point blank shooting being locked to help intent
		return ..()
	fire(user, target)
	return ITEM_INTERACT_COMPLETE

/obj/item/pneumatic_cannon/proc/fire(mob/living/carbon/human/user, atom/target)
	if(!istype(user) && !target)
		return
	var/has_discharged = FALSE
	if(!loaded_items || !loaded_weight_class)
		to_chat(user, "<span class='warning'>[src] has nothing loaded.</span>")
		return
	if(requires_tank)
		if(!tank)
			to_chat(user, "<span class='warning'>[src] can't fire without a source of gas.</span>")
			return
		if(!tank.air_contents.boolean_remove(gas_per_throw * pressure_setting))
			to_chat(user, "<span class='warning'>[src] lets out a weak hiss and doesn't react!</span>")
			return
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(75))
		user.visible_message("<span class='warning'>[user] loses [user.p_their()] grip on [src], causing it to go off!</span>", "<span class='userdanger'>[src] slips out of your hands and goes off!</span>")
		user.drop_item()
		has_discharged = TRUE
		if(prob(10))
			target = user
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
	if(!has_discharged)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", \
							"<span class='danger'>You fire [src]!</span>")
	add_attack_logs(user, target, "Fired [src]")
	playsound(loc, 'sound/weapons/sonic_jackhammer.ogg', 50, TRUE)
	for(var/obj/item/loaded_item in loaded_items)
		loaded_items.Remove(loaded_item)
		loaded_weight_class -= loaded_item.w_class
		loaded_item.throw_speed = pressure_setting * 2
		loaded_item.forceMove(get_turf(src))
		loaded_item.throw_at(target, pressure_setting * 5, pressure_setting * 2, user)
	if(pressure_setting >= 3 && user)
		user.visible_message("<span class='warning'>[user] is thrown down by the force of the cannon!</span>", "<span class='userdanger'>[src] slams into your shoulder, knocking you down!")
		user.KnockDown(3 SECONDS)

/obj/item/pneumatic_cannon/proc/add_tank(obj/item/tank/new_tank, mob/living/carbon/human/user)
	if(tank)
		to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
		return
	if(!user.unequip(new_tank))
		return
	to_chat(user, "<span class='notice'>You hook [new_tank] up to [src].</span>")
	new_tank.forceMove(src)
	tank = new_tank
	update_icons()

/obj/item/pneumatic_cannon/proc/remove_tank(mob/living/carbon/human/user)
	if(!tank)
		return FALSE
	to_chat(user, "<span class='notice'>You detach [tank] from [src].</span>")
	user.put_in_hands(tank)
	tank = null
	update_icons()

/obj/item/pneumatic_cannon/proc/update_icons()
	src.overlays.Cut()
	if(!tank)
		return
	src.overlays += image('icons/obj/pneumaticCannon.dmi', "[tank.icon_state]")
	src.update_icon()

/obj/item/pneumatic_cannon/admin
	name = "admin pnuematic cannon"
	desc = "Infinite gas and infinite capacity, go crazy."
	requires_tank = FALSE
	max_weight_class = INFINITY

/// Obtainable by improvised methods; more gas per use, less capacity, but smaller
/obj/item/pneumatic_cannon/ghetto
	name = "improvised pneumatic cannon"
	desc = "A gas-powered, object-firing cannon made out of common parts."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	max_weight_class = 7
	gas_per_throw = 5
