//NOT using the existing /obj/machinery/door type, since that has some complications on its own, mainly based on its machineryness
/obj/structure/mineral_door
	name = "metal door"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	icon = 'icons/obj/doors/mineral_doors.dmi'
	icon_state = "metal"
	max_integrity = 200
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 10, RAD = 100, FIRE = 50, ACID = 50)
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation_beta = RAD_BETA_BLOCKER
	rad_insulation_gamma = RAD_LIGHT_INSULATION
	var/initial_state
	var/state_open = FALSE
	var/is_operating = FALSE
	var/close_delay = -1 //-1 if does not auto close.

	var/hardness = 1
	var/sheetType = /obj/item/stack/sheet/metal
	var/sheetAmount = 7
	var/open_sound = 'sound/effects/stonedoor_openclose.ogg'
	var/close_sound = 'sound/effects/stonedoor_openclose.ogg'
	var/damageSound = null
	/// How much foam is on the door. Max 5 levels.
	var/foam_level = 0

/obj/structure/mineral_door/Initialize(mapload)
	. = ..()
	initial_state = icon_state
	recalculate_atmos_connectivity()
	AddComponent(/datum/component/debris, DEBRIS_SPARKS, -20, 10)

/obj/structure/mineral_door/Destroy()
	density = FALSE
	recalculate_atmos_connectivity()
	return ..()

/obj/structure/mineral_door/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/mineral_door/Bumped(atom/user)
	..()
	if(!state_open)
		return try_to_operate(user)

/obj/structure/mineral_door/attack_ai(mob/user) //those aren't machinery, they're just big fucking slabs of a mineral
	if(is_ai(user)) //so the AI can't open it
		return
	else if(isrobot(user) && Adjacent(user)) //but cyborgs can, but not remotely
		return try_to_operate(user)

/obj/structure/mineral_door/attack_hand(mob/user)
	return try_to_operate(user)

/obj/structure/mineral_door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		operate()

/obj/structure/mineral_door/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/mineral_door/CanAtmosPass(direction)
	return !density

/obj/structure/mineral_door/proc/try_to_operate(atom/user)
	if(is_operating)
		return
	if(foam_level)
		return
	if(isliving(user))
		var/mob/living/M = user
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					operate()
			else
				operate()
	else if(ismecha(user))
		operate()

/obj/structure/mineral_door/proc/operate()
	is_operating = TRUE
	if(!state_open)
		playsound(loc, open_sound, 100, TRUE)
		flick("[initial_state]opening",src)
	else
		var/turf/T = get_turf(src)
		for(var/mob/living/L in T)
			is_operating = FALSE
			return
		playsound(loc, close_sound, 100, TRUE)
		flick("[initial_state]closing",src)
	addtimer(CALLBACK(src, PROC_REF(operate_update)), 1 SECONDS)

/obj/structure/mineral_door/proc/operate_update()
	density = !density
	set_opacity(!opacity)
	state_open = !state_open
	recalculate_atmos_connectivity()
	update_icon(UPDATE_ICON_STATE)
	is_operating = FALSE

	if(state_open && close_delay != -1)
		addtimer(CALLBACK(src, PROC_REF(operate)), close_delay)

/obj/structure/mineral_door/update_icon_state()
	if(state_open)
		icon_state = "[initial_state]open"
	else
		icon_state = initial_state

/obj/structure/mineral_door/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/pickaxe))
		var/obj/item/pickaxe/digTool = W
		to_chat(user, "<span class='notice'>You start digging \the [src].</span>")
		if(do_after(user, 40 * digTool.toolspeed * hardness, target = src) && src)
			to_chat(user, "<span class='notice'>You finished digging.</span>")
			deconstruct(TRUE)
		return ITEM_INTERACT_COMPLETE
	else if(user.a_intent != INTENT_HARM)
		attack_hand(user)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/mineral_door/deconstruct(disassembled = TRUE)
	var/turf/T = get_turf(src)
	if(sheetType)
		if(disassembled)
			new sheetType(T, sheetAmount)
		else
			new sheetType(T, max(sheetAmount - 2, 1))
	qdel(src)

/obj/structure/mineral_door/iron
	max_integrity = 300

/obj/structure/mineral_door/silver
	name = "silver door"
	icon_state = "silver"
	sheetType = /obj/item/stack/sheet/mineral/silver
	max_integrity = 300

/obj/structure/mineral_door/gold
	name = "gold door"
	icon_state = "gold"
	sheetType = /obj/item/stack/sheet/mineral/gold
	rad_insulation_gamma = RAD_MEDIUM_INSULATION

/obj/structure/mineral_door/uranium
	name = "uranium door"
	icon_state = "uranium"
	sheetType = /obj/item/stack/sheet/mineral/uranium
	max_integrity = 300
	light_range = 2

/obj/structure/mineral_door/sandstone
	name = "sandstone door"
	icon_state = "sandstone"
	sheetType = /obj/item/stack/sheet/mineral/sandstone
	max_integrity = 100

/obj/structure/mineral_door/transparent
	opacity = FALSE
	rad_insulation_beta = RAD_MEDIUM_INSULATION

/obj/structure/mineral_door/transparent/operate_update()
	density = !density
	state_open = !state_open
	recalculate_atmos_connectivity()
	update_icon(UPDATE_ICON_STATE)
	is_operating = FALSE

/obj/structure/mineral_door/transparent/plasma
	name = "plasma door"
	icon_state = "plasma"
	sheetType = /obj/item/stack/sheet/mineral/plasma
	cares_about_temperature = TRUE

/obj/structure/mineral_door/transparent/plasma/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(W.get_heat())
		message_admins("Plasma mineral door ignited by [key_name_admin(user)] in ([x], [y], [z] - <a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)", 0, 1)
		log_game("Plasma mineral door ignited by [key_name(user)] in ([x], [y], [z])")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]",INVESTIGATE_ATMOS)
		TemperatureAct(100)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/structure/mineral_door/transparent/plasma/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		TemperatureAct(exposed_temperature)

/obj/structure/mineral_door/transparent/plasma/proc/TemperatureAct(temperature)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 500)
	deconstruct(FALSE)

/obj/structure/mineral_door/transparent/diamond
	name = "diamond door"
	icon_state = "diamond"
	sheetType = /obj/item/stack/sheet/mineral/diamond
	max_integrity = 1000

/obj/structure/mineral_door/wood
	name = "wood door"
	icon_state = "wood"
	open_sound = 'sound/effects/doorcreaky.ogg'
	close_sound = 'sound/effects/doorcreaky.ogg'
	sheetType = /obj/item/stack/sheet/wood
	resistance_flags = FLAMMABLE
	rad_insulation_beta = RAD_VERY_LIGHT_INSULATION

/obj/structure/mineral_door/wood/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/debris, DEBRIS_WOOD, -20, 10)

#define MAX_FOAM_LEVEL 5
// Adds foam to the airlock, which will block it from being opened
/obj/structure/mineral_door/proc/foam_up()
	if(!foam_level)
		new /obj/structure/barricade/foam(get_turf(src))
		foam_level++
		return

	if(foam_level == MAX_FOAM_LEVEL)
		return

	for(var/obj/structure/barricade/foam/blockage in loc.contents)
		blockage.foam_level = min(++blockage.foam_level, 5)
		// The last level will increase the integrity by 50 instead of 25
		if(foam_level == 4)
			blockage.obj_integrity += 50
			blockage.max_integrity += 50
		else
			blockage.obj_integrity += 25
			blockage.max_integrity += 25
		foam_level++
		blockage.icon_state = "foamed_[foam_level]"
		blockage.update_icon(UPDATE_ICON_STATE)

#undef MAX_FOAM_LEVEL
