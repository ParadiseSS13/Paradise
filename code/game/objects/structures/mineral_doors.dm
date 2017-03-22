//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its machineryness
/obj/structure/mineral_door
	name = "metal door"
	density = 1
	anchored = 1
	opacity = 1

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"

	var/initial_state
	var/state = 0 //closed, 1 == open
	var/isSwitchingStates = 0
	var/close_delay = -1 //-1 if does not auto close.

	var/hardness = 1
	var/sheetType = /obj/item/stack/sheet/metal
	var/sheetAmount = 7
	var/openSound = 'sound/effects/stonedoor_openclose.ogg'
	var/closeSound = 'sound/effects/stonedoor_openclose.ogg'
	var/damageSound = null

/obj/structure/mineral_door/New(location)
	..()
	initial_state = icon_state

/obj/structure/mineral_door/initialize()
	..()
	air_update_turf(1)

/obj/structure/mineral_door/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/mineral_door/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/mineral_door/Bumped(atom/user)
	..()
	if(!state)
		return TryToSwitchState(user)

/obj/structure/mineral_door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(isAI(user)) //so the AI can't open it
		return
	else if(isrobot(user) && Adjacent(user)) //but cyborgs can, but not remotely
		return TryToSwitchState(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	return TryToSwitchState(user)

/obj/structure/mineral_door/attack_animal(mob/user)
	return TryToSwitchState(user)
	
/obj/structure/mineral_door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		SwitchState()

/obj/structure/mineral_door/CanPass(atom/movable/mover, turf/target, height = 0)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/CanAtmosPass(turf/T)
	return !density

/obj/structure/mineral_door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) 
		return
	if(isliving(user))
		var/mob/living/M = user
		if(world.time - user.last_bumped <= 60) 
			return //NOTE do we really need that?
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()
	else if(istype(user, /obj/mecha))
		SwitchState()

/obj/structure/mineral_door/proc/SwitchState()
	if(state)
		Close()
	else
		Open()

/obj/structure/mineral_door/proc/Open()
	isSwitchingStates = 1
	playsound(loc, openSound, 100, 1)
	flick("[initial_state]opening",src)
	sleep(10)
	density = 0
	opacity = 0
	state = 1
	air_update_turf(1)
	update_icon()
	isSwitchingStates = 0
	
	if(close_delay != -1)
		spawn(close_delay)
			Close()

/obj/structure/mineral_door/proc/Close()
	if(isSwitchingStates || state != 1)
		return
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		return
	isSwitchingStates = 1
	playsound(loc, closeSound, 100, 1)
	flick("[initial_state]closing",src)
	sleep(10)
	density = 1
	opacity = 1
	state = 0
	air_update_turf(1)
	update_icon()
	isSwitchingStates = 0

/obj/structure/mineral_door/update_icon()
	if(state)
		icon_state = "[initial_state]open"
	else
		icon_state = initial_state

/obj/structure/mineral_door/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/digTool = W
		to_chat(user, "<span class='notice'>You start digging \the [src].</span>")
		if(do_after(user, digTool.digspeed * hardness, target = src) && src)
			to_chat(user, "<span class='notice'>You finished digging.</span>")
			deconstruct(TRUE)
	else if(user.a_intent != I_HARM)
		attack_hand(user)
	else
		attacked_by(W, user)

/obj/structure/mineral_door/proc/attacked_by(obj/item/I, mob/user)
	if(I.damtype != STAMINA)
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(src)
		visible_message("<span class='notice'>[user] hits \the [src] with \the [I].</span>")
		if(damageSound)
			playsound(loc, damageSound, 100, 1)
		else
			playsound(loc, I.hitsound, 100, 1)
		hardness -= I.force / 100
		CheckHardness()

/obj/structure/mineral_door/proc/CheckHardness()
	if(hardness <= 0)
		deconstruct(FALSE)

/obj/structure/mineral_door/proc/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(sheetType)
		if(disassembled)
			new sheetType(T, sheetAmount)
		else
			new sheetType(T, max(sheetAmount - 2, 1))
	qdel(src)

/obj/structure/mineral_door/ex_act(severity = 1)
	switch(severity)
		if(1)
			deconstruct(FALSE)
		if(2)
			if(prob(20))
				deconstruct(FALSE)
			else
				hardness--
				CheckHardness()
		if(3)
			hardness -= 0.1
			CheckHardness()

/obj/structure/mineral_door/iron
	hardness = 3

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	sheetType = /obj/item/stack/sheet/mineral/silver
	hardness = 3

/obj/structure/mineral_door/gold
	name = "gold door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	sheetType = /obj/item/stack/sheet/mineral/uranium
	hardness = 3
	light_range = 2

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	sheetType = /obj/item/stack/sheet/mineral/sandstone
	hardness = 0.5

/obj/structure/mineral_door/transparent
	opacity = 0

/obj/structure/mineral_door/transparent/Close()
	..()
	set_opacity(0)

/obj/structure/mineral_door/transparent/plasma
	name = "plasma door"
	icon_state = "plasma"
	sheetType = /obj/item/stack/sheet/mineral/plasma

/obj/structure/mineral_door/transparent/plasma/attackby(obj/item/weapon/W, mob/user)
	if(is_hot(W))
		message_admins("Plasma mineral door ignited by [key_name_admin(user)] in ([x], [y], [z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)", 0, 1)
		log_game("Plasma mineral door ignited by [key_name(user)] in ([x], [y], [z])")
		TemperatureAct(100)
	else
		return ..()

/obj/structure/mineral_door/transparent/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/plasma/proc/TemperatureAct(temperature)
	atmos_spawn_air(SPAWN_HEAT | SPAWN_TOXINS, 500)
	deconstruct(FALSE)

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	sheetType = /obj/item/stack/sheet/mineral/diamond
	hardness = 10

/obj/structure/mineral_door/wood
	name = "wood door"
	icon_state = "wood"
	openSound = 'sound/effects/doorcreaky.ogg'
	closeSound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/wood
	hardness = 1
	burn_state = FLAMMABLE
	burntime = 30

/obj/structure/mineral_door/resin
	name = "resin door"
	icon_state = "resin"
	hardness = 1.5
	close_delay = 100
	openSound = 'sound/effects/attackblob.ogg'
	closeSound = 'sound/effects/attackblob.ogg'
	damageSound = 'sound/effects/attackblob.ogg'
	sheetType = null

/obj/structure/mineral_door/resin/TryToSwitchState(atom/user)
	if(isalien(user))
		return ..()
