///Defines for the pressure strength of the cannon
#define LOW_PRESSURE 1
#define MID_PRESSURE 2
#define HIGH_PRESSURE 3

/obj/item/pneumatic_cannon
	name = "pneumatic cannon"
	desc = "A gas-powered cannon that can fire any object loaded into it."
	w_class = WEIGHT_CLASS_BULKY
	force = 8 //Very heavy
	attack_verb = list("bludgeoned", "smashed", "beaten")
	icon = 'icons/obj/weapons/pneumaticCannon.dmi'
	icon_state = "pneumaticCannon"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50)
	var/maxWeightClass = 20 //The max weight of items that can fit into the cannon
	var/loadedWeightClass = 0 //The weight of items currently in the cannon
	var/obj/item/tank/internals/tank = null //The gas tank that is drawn from to fire things
	var/gasPerThrow = 3 //How much gas is drawn from a tank's pressure to fire
	var/list/loadedItems = list() //The items loaded into the cannon that will be fired out
	var/pressure_setting = LOW_PRESSURE //How powerful the cannon is - higher pressure = more gas but more powerful throws

/obj/item/pneumatic_cannon/Destroy()
	QDEL_NULL(tank)
	QDEL_LIST(loadedItems)
	return ..()

/obj/item/pneumatic_cannon/proc/pressure_setting_to_text(pressure_setting)
	switch(pressure_setting)
		if(LOW_PRESSURE)
			return "low"
		if(MID_PRESSURE)
			return "medium"
		if(HIGH_PRESSURE)
			return "high"
		else
			CRASH("Invalid pressure setting: [pressure_setting]!")

/obj/item/pneumatic_cannon/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += span_notice(">You'll need to get closer to see any more.")
	else
		. += span_notice("Use a <b>wrench</b> to change the pressure level. Current output level is <b>[pressure_setting_to_text(pressure_setting)]</b>.")
		if(tank)
			. += span_notice("[bicon(tank)] It has [tank] mounted onto it. It could be removed with a <b>screwdriver</b>.")
		for(var/obj/item/I in loadedItems)
			. += span_notice("[bicon(I)] It has \a [I] loaded.")

/obj/item/pneumatic_cannon/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(tank)
		updateTank(tank, 1, user)
	else
		to_chat(user, span_notice("There is no tank inside!"))

/obj/item/pneumatic_cannon/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	pressure_setting = pressure_setting >= HIGH_PRESSURE ? LOW_PRESSURE : pressure_setting + 1
	to_chat(user, span_notice("You tweak pressure output to [pressure_setting_to_text(pressure_setting)]."))

/obj/item/pneumatic_cannon/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()

/obj/item/pneumatic_cannon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		return
	if(istype(I, /obj/item/tank/internals) && !tank)
		if(istype(I, /obj/item/tank/internals/emergency_oxygen))
			to_chat(user, span_warning("[I] is too small for [src]."))
			return
		updateTank(I, 0, user)
		return
	if(I.type == type)
		to_chat(user, span_warning("You're fairly certain that putting a pneumatic cannon inside another pneumatic cannon would cause a spacetime disruption"))
		return
	if(loadedWeightClass >= maxWeightClass)
		to_chat(user, span_warning("[src] can't hold any more items!"))
		return
	if((loadedWeightClass + I.w_class) > maxWeightClass)
		to_chat(user, span_warning("[I] won't fit into [src]!"))
		return
	if(I.w_class > src.w_class)
		to_chat(user, span_warning("[I] is too large to fit into [src]!"))
		return
	if(!user.unEquip(I))
		return
	to_chat(user, span_notice("You load [I] into [src]"))
	loadedItems.Add(I)
	loadedWeightClass += I.w_class
	I.loc = src

/obj/item/pneumatic_cannon/afterattack(atom/target, mob/living/carbon/human/user, flag, params)
	. = ..()
	if(flag && user.a_intent == INTENT_HARM) // Melee attack
		return ..()
	if(!istype(user))
		return ..()
	if(!(loc == user))
		return ..()
	Fire(user, target)
	return TRUE

/obj/item/pneumatic_cannon/proc/Fire(var/mob/living/carbon/human/user, var/atom/target)
	if(!istype(user) && !target)
		return
	var/discharge = 0
	if(!loadedItems || !loadedWeightClass)
		to_chat(user, span_warning("[src] has nothing loaded."))
		return
	if(!tank)
		to_chat(user, span_warning("[src] can't fire without a source of gas."))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You can't bring yourself to fire [src]! You don't want to risk harming anyone..."))
		return
	if(tank && !tank.air_contents.remove(gasPerThrow * pressure_setting))
		to_chat(user, span_warning("[src] lets out a weak hiss and doesn't react!"))
		return
	if(user && (CLUMSY in user.mutations) && prob(75))
		user.visible_message(span_warning("[user] loses [user.p_their()] grip on [src], causing it to go off!"), span_userdanger("[src] slips out of your hands and goes off!"))
		user.drop_item()
		if(prob(10))
			target = get_turf(user)
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
		discharge = 1
	if(!discharge)
		user.visible_message(span_danger("[user] fires [src]!"), span_danger("You fire [src]!"))
	add_attack_logs(user, target, "Fired [src]")
	playsound(src.loc, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
	for(var/obj/item/ITD in loadedItems) //Item To Discharge
		spawn(0)
			loadedItems.Remove(ITD)
			loadedWeightClass -= ITD.w_class
			ITD.throw_speed = pressure_setting * 2
			ITD.loc = get_turf(src)
			ITD.throw_at(target, pressure_setting * 5, pressure_setting * 2,user)
	if(pressure_setting >= HIGH_PRESSURE && user)
		user.visible_message(span_warning("[user] is thrown down by the force of the cannon!"), span_userdanger("[src] slams into your shoulder, knocking you down!"))
		user.Weaken(3)

/obj/item/pneumatic_cannon/ghetto //Obtainable by improvised methods; more gas per use, less capacity, but smaller
	name = "improvised pneumatic cannon"
	desc = "A gas-powered, object-firing cannon made out of common parts."
	force = 5
	w_class = WEIGHT_CLASS_NORMAL
	maxWeightClass = 7
	gasPerThrow = 5

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "Pneumatic Cannon"
	result = /obj/item/pneumatic_cannon/ghetto
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/packageWrap = 8,
				/obj/item/pipe = 2)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/obj/item/pneumatic_cannon/proc/updateTank(obj/item/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			return
		to_chat(user, span_notice("You detach [thetank] from [src]."))
		tank.loc = get_turf(src)
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, span_warning("[src] already has a tank."))
			return
		if(!user.unEquip(thetank))
			return
		to_chat(user, span_notice("You hook [thetank] up to [src]."))
		tank = thetank
		thetank.loc = src
	update_icons()

/obj/item/pneumatic_cannon/proc/update_icons()
	overlays.Cut()
	if(!tank)
		return
	overlays += image('icons/obj/weapons/pneumaticCannon.dmi', "[tank.icon_state]")
	update_icon()

#undef LOW_PRESSURE
#undef MID_PRESSURE
#undef HIGH_PRESSURE
