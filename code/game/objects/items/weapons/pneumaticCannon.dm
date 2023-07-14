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
	icon = 'icons/obj/pneumaticCannon.dmi'
	icon_state = "pneumaticCannon"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 60, ACID = 50)
	var/maxWeightClass = 20 //The max weight of items that can fit into the cannon
	var/loadedWeightClass = 0 //The weight of items currently in the cannon
	var/obj/item/tank/internals/tank = null //The gas tank that is drawn from to fire things
	var/gasPerThrow = 3 //How much gas is drawn from a tank's pressure to fire
	var/list/loadedItems = list() //The items loaded into the cannon that will be fired out
	var/pressure_setting = LOW_PRESSURE //How powerful the cannon is - higher pressure = more gas but more powerful throws

/obj/item/pneumatic_cannon/Destroy()
	QDEL_NULL(tank)
	QDEL_LIST_CONTENTS(loadedItems)
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
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
	else
		. += "<span class='notice'>Use a <b>wrench</b> to change the pressure level. Current output level is <b>[pressure_setting_to_text(pressure_setting)]</b>.</span>"
		if(tank)
			. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>"
		for(var/obj/item/I in loadedItems)
			. += "<span class='info'>[bicon(I)] It has [I] loaded.</span>"

/obj/item/pneumatic_cannon/return_analyzable_air()
	if(tank)
		return tank.return_analyzable_air()

/obj/item/pneumatic_cannon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		return
	if(istype(I, /obj/item/tank/internals) && !tank)
		if(istype(I, /obj/item/tank/internals/emergency_oxygen))
			to_chat(user, "<span class='warning'>[I] is too small for [src].</span>")
			return
		attach_tank(I, user)
		return
	if(I.type == type)
		to_chat(user, "<span class='warning'>You're fairly certain that putting a pneumatic cannon inside another pneumatic cannon would cause a spacetime disruption.</span>")
		return
	if(loadedWeightClass >= maxWeightClass)
		to_chat(user, "<span class='warning'>[src] can't hold any more items!</span>")
		return
	if(I.flags & (ABSTRACT | NODROP | DROPDEL))
		to_chat(user, "<span class='warning'>You can't put [I] into [src]!</span>")
		return
	if((loadedWeightClass + I.w_class) > maxWeightClass)
		to_chat(user, "<span class='warning'>[I] won't fit into [src]!</span>")
		return
	if(I.w_class > w_class)
		to_chat(user, "<span class='warning'>[I] is too large to fit into [src]!</span>")
		return
	if(!user.unEquip(I))
		return
	to_chat(user, "<span class='notice'>You load [I] into [src].</span>")
	loadedItems.Add(I)
	I.loc = src
	loadedWeightClass += I.w_class

/obj/item/pneumatic_cannon/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	pressure_setting = pressure_setting >= HIGH_PRESSURE ? LOW_PRESSURE : pressure_setting + 1
	to_chat(user, "<span class='notice'>You tweak pressure output to [pressure_setting_to_text(pressure_setting)].</span>")
	return TRUE

/obj/item/pneumatic_cannon/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!tank)
		to_chat(user, "<span class='notice'>There is no tank inside!</span>")
		return
	remove_tank(user)

/obj/item/pneumatic_cannon/afterattack(atom/target, mob/living/carbon/human/user, flag, params)
	. = ..()
	if(flag && user.a_intent == INTENT_HARM) // Melee attack
		return
	if(!istype(user))
		return
	if(!(loc == user))
		return
	if(isstorage(target) && Adjacent(user))
		return
	Fire(user, target)
	return TRUE

/obj/item/pneumatic_cannon/proc/Fire(mob/living/carbon/human/user, atom/target)
	if(!istype(user) && !target)
		return
	var/discharge = 0
	if(!loadedItems || !loadedWeightClass)
		to_chat(user, "<span class='warning'>[src] has nothing loaded.</span>")
		return
	if(!tank)
		to_chat(user, "<span class='warning'>[src] can't fire without a source of gas.</span>")
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You can't bring yourself to fire [src]! You don't want to risk harming anyone...</span>")
		return
	if(tank && !tank.air_contents.remove(gasPerThrow * pressure_setting))
		to_chat(user, "<span class='warning'>[src] lets out a weak hiss and doesn't react!</span>")
		return
	if(user && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(75))
		user.visible_message("<span class='warning'>[user] loses [user.p_their()] grip on [src], causing it to go off!</span>", "<span class='userdanger'>[src] slips out of your hands and goes off!</span>")
		user.drop_item()
		if(prob(10))
			target = get_turf(user)
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
		discharge = 1
	if(!discharge)
		user.visible_message("<span class='danger'>[user] fires [src]!</span>", \
							"<span class='danger'>You fire [src]!</span>")
	add_attack_logs(user, target, "Fired [src]")
	playsound(loc, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
	for(var/obj/item/ITD in loadedItems) //Item To Discharge
		spawn(0)
			loadedItems.Remove(ITD)
			loadedWeightClass -= ITD.w_class
			ITD.throw_speed = pressure_setting * 2
			ITD.loc = get_turf(src)
			ITD.throw_at(target, pressure_setting * 5, pressure_setting * 2, user)
	if(pressure_setting >= HIGH_PRESSURE && user)
		user.visible_message("<span class='warning'>[user] is thrown down by the force of the cannon!</span>", "<span class='userdanger'>[src] slams into your shoulder, knocking you down!")
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
	result = list(/obj/item/pneumatic_cannon/ghetto)
	tools = list(TOOL_WELDER, TOOL_WRENCH)
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/packageWrap = 8,
				/obj/item/pipe = 2)
	time = 300
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON

/obj/item/pneumatic_cannon/proc/remove_tank(mob/living/carbon/human/user)
	if(!tank)
		return
	to_chat(user, "<span class='notice'>You detach [tank] from [src].</span>")
	tank.loc = get_turf(src)
	user.put_in_hands(tank)
	tank = null
	update_icons()

/obj/item/pneumatic_cannon/proc/attach_tank(obj/item/tank/thetank, mob/living/carbon/human/user)
	if(tank)
		to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
		return
	if(!user.unEquip(thetank))
		return
	to_chat(user, "<span class='notice'>You hook [thetank] up to [src].</span>")
	tank = thetank
	thetank.loc = src
	update_icons()

/obj/item/pneumatic_cannon/proc/update_icons()
	overlays.Cut()
	if(!tank)
		return
	overlays += image('icons/obj/pneumaticCannon.dmi', "[tank.icon_state]")
	update_icon()

#undef LOW_PRESSURE
#undef MID_PRESSURE
#undef HIGH_PRESSURE
