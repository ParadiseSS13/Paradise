/obj/item/weapon/pneumatic_cannon
	name = "pneumatic cannon"
	desc = "A gas-powered cannon that can fire any object loaded into it."
	w_class = 4
	force = 8 //Very heavy
	attack_verb = list("bludgeoned", "smashed", "beaten")
	icon = 'icons/obj/pneumaticCannon.dmi'
	icon_state = "pneumaticCannon"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	var/maxWeightClass = 20 //The max weight of items that can fit into the cannon
	var/loadedWeightClass = 0 //The weight of items currently in the cannon
	var/obj/item/weapon/tank/tank = null //The gas tank that is drawn from to fire things
	var/gasPerThrow = 3 //How much gas is drawn from a tank's pressure to fire
	var/list/loadedItems = list() //The items loaded into the cannon that will be fired out
	var/pressureSetting = 1 //How powerful the cannon is - higher pressure = more gas but more powerful throws


/obj/item/weapon/pneumatic_cannon/examine(mob/user)
	..()
	if(!in_range(user, src))
		to_chat(user, "<span class='notice'>You'll need to get closer to see any more.</span>")
		return
	for(var/obj/item/I in loadedItems)
		spawn(0)
			to_chat(user, "<span class='info'>[bicon(I)] It has \the [I] loaded.</span>")
	if(tank)
		to_chat(user, "<span class='notice'>[bicon(tank)] It has \the [tank] mounted onto it.</span>")


/obj/item/weapon/pneumatic_cannon/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/tank/) && !tank)
		if(istype(W, /obj/item/weapon/tank/emergency_oxygen))
			to_chat(user, "<span class='warning'>\The [W] is too small for \the [src].</span>")
			return
		updateTank(W, 0, user)
		return
	if(W.type == type)
		to_chat(user, "<span class='warning'>You're fairly certain that putting a pneumatic cannon inside another pneumatic cannon would cause a spacetime disruption.</span>")
		return
	if(istype(W, /obj/item/weapon/wrench))
		switch(pressureSetting)
			if(1)
				pressureSetting = 2
			if(2)
				pressureSetting = 3
			if(3)
				pressureSetting = 1
		to_chat(user, "<span class='notice'>You tweak \the [src]'s pressure output to [pressureSetting].</span>")
		return
	if(istype(W, /obj/item/weapon/screwdriver) && tank)
		updateTank(tank, 1, user)
		return
	if(loadedWeightClass >= maxWeightClass)
		to_chat(user, "<span class='warning'>\The [src] can't hold any more items!</span>")
		return
	if(istype(W, /obj/item))
		var/obj/item/IW = W
		if((loadedWeightClass + IW.w_class) > maxWeightClass)
			to_chat(user, "<span class='warning'>\The [IW] won't fit into \the [src]!</span>")
			return
		if(IW.w_class > src.w_class)
			to_chat(user, "<span class='warning'>\The [IW] is too large to fit into \the [src]!</span>")
			return
		if(!user.unEquip(W))
			return
		to_chat(user, "<span class='notice'>You load \the [IW] into \the [src].</span>")
		loadedItems.Add(IW)
		loadedWeightClass += IW.w_class
		IW.loc = src
		return


/obj/item/weapon/pneumatic_cannon/afterattack(atom/target, mob/living/carbon/human/user, flag, params)
	if(istype(target, /obj/item/weapon/storage)) //So you can store it in backpacks
		return ..()
	if(istype(target, /obj/structure/closet)) //So you can store it in closets
		return ..()
	if(istype(target, /obj/structure/rack)) //So you can store it on racks
		return ..()
	if(!istype(user))
		return ..()
	Fire(user, target)


/obj/item/weapon/pneumatic_cannon/proc/Fire(var/mob/living/carbon/human/user, var/atom/target)
	if(!istype(user) && !target)
		return
	var/discharge = 0
	if(!loadedItems || !loadedWeightClass)
		to_chat(user, "<span class='warning'>\The [src] has nothing loaded.</span>")
		return
	if(!tank)
		to_chat(user, "<span class='warning'>\The [src] can't fire without a source of gas.</span>")
		return
	if(tank && !tank.air_contents.remove(gasPerThrow * pressureSetting))
		to_chat(user, "<span class='warning'>\The [src] lets out a weak hiss and doesn't react!</span>")
		return
	if(user && (CLUMSY in user.mutations) && prob(75))
		user.visible_message("<span class='warning'>[user] loses their grip on [src], causing it to go off!</span>", "<span class='userdanger'>[src] slips out of your hands and goes off!</span>")
		user.drop_item()
		if(prob(10))
			target = get_turf(user)
		else
			var/list/possible_targets = range(3,src)
			target = pick(possible_targets)
		discharge = 1
	if(!discharge)
		user.visible_message("<span class='danger'>[user] fires \the [src]!</span>", \
				    		 "<span class='danger'>You fire \the [src]!</span>")
	add_logs(target, user, "fired at", src)
	playsound(src.loc, 'sound/weapons/sonic_jackhammer.ogg', 50, 1)
	for(var/obj/item/ITD in loadedItems) //Item To Discharge
		spawn(0)
			loadedItems.Remove(ITD)
			loadedWeightClass -= ITD.w_class
			ITD.throw_speed = pressureSetting * 2
			ITD.loc = get_turf(src)
			ITD.throw_at(target, pressureSetting * 5, pressureSetting * 2,user)
	if(pressureSetting >= 3 && user)
		user.visible_message("<span class='warning'>[user] is thrown down by the force of the cannon!</span>", "<span class='userdanger'>[src] slams into your shoulder, knocking you down!")
		user.Weaken(3)


/obj/item/weapon/pneumatic_cannon/ghetto //Obtainable by improvised methods; more gas per use, less capacity, but smaller
	name = "improvised pneumatic cannon"
	desc = "A gas-powered, object-firing cannon made out of common parts."
	force = 5
	w_class = 3
	maxWeightClass = 7
	gasPerThrow = 5

/datum/crafting_recipe/improvised_pneumatic_cannon //Pretty easy to obtain but
	name = "Pneumatic Cannon"
	result = /obj/item/weapon/pneumatic_cannon/ghetto
	tools = list(/obj/item/weapon/weldingtool,
				 /obj/item/weapon/wrench)
	reqs = list(/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/packageWrap = 8,
				/obj/item/pipe = 2)
	time = 300

/obj/item/weapon/pneumatic_cannon/proc/updateTank(obj/item/weapon/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!src.tank)
			return
		to_chat(user, "<span class='notice'>You detach \the [thetank] from \the [src].</span>")
		src.tank.loc = get_turf(user)
		user.put_in_hands(tank)
		src.tank = null
	if(!removing)
		if(src.tank)
			to_chat(user, "<span class='warning'>\The [src] already has a tank.</span>")
			return
		if(!user.unEquip(thetank))
			return
		to_chat(user, "<span class='notice'>You hook \the [thetank] up to \the [src].</span>")
		src.tank = thetank
		thetank.loc = src
	src.update_icons()

/obj/item/weapon/pneumatic_cannon/proc/update_icons()
	src.overlays.Cut()
	if(!tank)
		return
	src.overlays += image('icons/obj/pneumaticCannon.dmi', "[tank.icon_state]")
	src.update_icon()
