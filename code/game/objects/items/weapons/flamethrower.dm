#define FLAMETHROWERMODE 1
#define WELDERMODE 2

/obj/item/flamethrower //do not spawn
	name = "flamethrower"
	desc = "how did you get this?"
	var/lit = FALSE	//on or off
	var/operating = FALSE//cooldown
	var/warned_admins = FALSE //for the message_admins() when lit
	var/flame_intensity = 0 //for flame intensity
	var/consumption_rate = 25 // how much fuel is used as a percentage
	var/tank_exposure = 0 //defensive purposes, namely how likely your to blow up upon being shot holding a flamethrower
	var/obj/item/tank/plasma/ptank = null

/obj/item/flamethrower/process()
	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2) //start a fire if possible
	if(prob(5)) //sometimes consume fuel
		consume_fuel(5) //and not massive chunks of it
	..()

/obj/item/flamethrower/attack_self(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(ptank.air_contents.toxins < 5)
		to_chat(user, "<span class='notice'>Plasma tank is low on plasma!</span>")
		return
	if(!warned_admins) //informing who lit it first.
		message_admins("[ADMIN_LOOKUPFLW(user)] has lit a [src].")
		warned_admins = TRUE
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	toggle_igniter()

/obj/item/flamethrower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/plasma))		
		if(user.drop_item())
			if(ptank)			
				ptank.forceMove(get_turf(src))
				to_chat(user, "<span class='notice'>You swap the plasma tank in [src]!</span>")
			I.forceMove(src)
			ptank = I
			update_icon()
			return

	else if(istype(I, /obj/item/analyzer) && ptank)
		atmosanalyzer_scan(ptank.air_contents, user)
	else
		return ..()

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(ptank)
		. += "<span class='notice'>[src] has \a [ptank] attached. Alt-click to remove it.</span>"

/obj/item/flamethrower/AltClick(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'> Turn off [src] first!</span>")
	else if(ptank && isliving(user) && user.Adjacent(src))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, "<span class='notice'>You remove the plasma tank from [src]!</span>")
		update_icon()

//turn it on or off
/obj/item/flamethrower/proc/toggle_igniter(turn_off = FALSE)
	if(!lit && turn_off)
		return
	lit = turn_off ? FALSE : !lit
	if(lit)
		playsound(loc, 'sound/items/welderactivate.ogg', 50, 1)
		START_PROCESSING(SSobj, src)		
	else
		playsound(loc, 'sound/items/welderdeactivate.ogg', 50, 1)
		STOP_PROCESSING(SSobj,src)
	update_icon()

/obj/item/flamethrower/proc/consume_fuel(amount) 
	ptank.air_contents.remove_ratio(amount / 100) //using whole numbers then turning them into percentages
	if(ptank.air_contents.toxins < 5)
		toggle_igniter(TRUE)
	update_icon()
		
/obj/item/flamethrower/proc/ignite_turf(obj/item/flamethrower/F, turf/simulated/location, release_amount = 0.05)
	F.default_ignite(location, release_amount)

/obj/item/flamethrower/proc/default_ignite(turf/target, amount)
	var/turf/simulated/target_turf = target
	if(istype(target_turf))
		target_turf.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, amount) //amount of plasma spawned based on flame intensity
	target.hotspot_expose(1000,500)
	SSair.add_to_active(target, 0)

/obj/item/flamethrower/proc/fireline(atom/target, mob/user)
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		var/turflist = getline(user, target_turf)
		add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
		flame_turf(turflist)

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return
	operating = TRUE
	var/turf/previousturf = get_turf(src)
	for(var/turf/simulated/T in turflist)
		if(!T.air)
			break
		if(T == previousturf)
			continue	//so we don't burn the tile we be standing on
		if(!T.CanAtmosPass(previousturf))
			break
		default_ignite(T, flame_intensity)
		sleep(1)
		previousturf = T
	operating = FALSE

/obj/item/flamethrower/proc/startfireline(atom/target, mob/user)
	if(lit)
		if(user && user.get_active_hand() == src) // Make sure our user is still holding us
			playsound(get_turf(src),'sound/magic/fireball.ogg', 200, TRUE)
			fireline(target, user)
			consume_fuel(consumption_rate)

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(tank_exposure))
		if(ptank) //need to check is ptank exists first
			owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
			var/turf/target_turf = get_turf(owner)
			log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
			ignite_turf(src,target_turf, release_amount = ptank.air_contents.toxins)
			QDEL_NULL(ptank)
			return TRUE //It hit the flamethrower, not them


/obj/item/flamethrower/basic
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrower0"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 3
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=500)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	flame_intensity = 1
	consumption_rate = 25
	tank_exposure = 15
	lit = FALSE	
	var/obj/item/weldingtool/weldtool = null //so you can recover the welding tool you used
	var/create_full = FALSE
	var/create_with_tank = FALSE

/obj/item/flamethrower/basic/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(ptank)
	return ..()

/obj/item/flamethrower/basic/update_icon()
	cut_overlays()
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		item_state = "flamethrower_1"
		icon_state = "flamethrower1"
	else
		item_state = "flamethrower_0"
		icon_state = "flamethrower0"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/flamethrower/basic/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	startfireline(target, user)

/obj/item/flamethrower/basic/wrench_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/turf/T = get_turf(src)
	if(weldtool)
		weldtool.forceMove(T)
		weldtool = null
	if(ptank)
		ptank.forceMove(T)
		ptank = null
	new /obj/item/stack/rods(T)
	new /obj/item/assembly/igniter(T) //why did it care about this in the first place?
	qdel(src)

/obj/item/flamethrower/basic/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	update_icon()

/obj/item/flamethrower/basic/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		if(create_with_tank)
			ptank = new /obj/item/tank/plasma/full(src)
		update_icon()

/obj/item/flamethrower/basic/full
	create_full = TRUE

/obj/item/flamethrower/basic/full/tank
	create_with_tank = TRUE


/obj/item/flamethrower/advanced
	name = "Burner Boyes Flamethrower"
	desc = "Adapted from specialised salavaging equipment, the Burner Boyes flamerthrower lets you roast the average spaceman or cut through them."
	icon = 'icons/obj/burner.dmi'
	icon_state = "burner0"
	item_state = "burner0"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	flags = CONDUCT
	force = 15 //it's heavy
	armour_penetration = 0
	throwforce = 10
	throw_speed = 1
	throw_range = 2 //again heavy
	w_class = WEIGHT_CLASS_BULKY //not stuffing this into a backpack
	materials = list(MAT_METAL=500)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	flame_intensity = 1.4
	consumption_rate = 20
	tank_exposure = 3
	lit = FALSE
	tool_behaviour = null
	toolspeed = 0.5
	usesound = 'sound/items/welder.ogg'
	actions_types = list(/datum/action/item_action/toggle_flamethrowermode)
	var/consumption_rate_welder = 5
	var/force_welder = 30
	var/armour_penetration_welder = 50
	var/status = FLAMETHROWERMODE
	var/create_with_tank = FALSE

/obj/item/flamethrower/advanced/Destroy()
	QDEL_NULL(ptank)
	return ..()

/obj/item/flamethrower/advanced/update_icon()
	cut_overlays()
	if(ptank)
		add_overlay("+ptank")
		if(ptank.air_contents.toxins > 20) //preempting that runetime.
			add_overlay("+fuel5")
		else if(ptank.air_contents.toxins > 15)
			add_overlay("+fuel4")
		else if(ptank.air_contents.toxins > 10)
			add_overlay("+fuel3")
		else if(ptank.air_contents.toxins > 5)
			add_overlay("+fuel2")
		else if(ptank.air_contents.toxins < 5)
			add_overlay("+fuel1")
	else 
		add_overlay("+fuel0")
	if(lit)
		item_state = "burner[status]"
		add_overlay("+lit[status]")
	else
		item_state = "burner0"
		icon_state = "burner[status]"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/flamethrower/advanced/attack(mob/living/M, mob/living/user)
	if(user.get_inactive_hand())
		to_chat(user, "<span class='userdanger'>You need both hands free to attack with \the [src]!</span>")
		return
	if(lit && status == WELDERMODE) //we want it to have different attack values depending on what status and if it's on or not
		damtype = BURN
		force = force_welder
		armour_penetration = armour_penetration_welder
		hitsound = 'sound/items/welder.ogg'
		consume_fuel(consumption_rate)
	else
		damtype = BRUTE
		force = initial(force)
		armour_penetration = initial(armour_penetration)
		hitsound = "swing_hit"
	..()

/obj/item/flamethrower/advanced/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(user.get_inactive_hand())
		to_chat(user, "<span class='userdanger'>You need both hands free to use \the [src]!</span>")
		return
	if(status == WELDERMODE)
		return
	else
		startfireline(target, user)
	
/obj/item/flamethrower/advanced/tool_use_check(mob/living/user)
	if(!lit)
		to_chat(user, "<span class='notice'>[src] has to be on to complete this task!</span>")
		return FALSE
	return TRUE

/obj/item/flamethrower/advanced/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks)
	. = ..()
	consume_fuel(consumption_rate)

/obj/item/flamethrower/advanced/ui_action_click(mob/user, actiontype)
	toggle_mode(user)

/obj/item/flamethrower/advanced/proc/toggle_mode(mob/user)
	playsound(get_turf(user), 'sound/items/change_jaws.ogg', 50, 1)
	if(status == FLAMETHROWERMODE)
		status = WELDERMODE
		consumption_rate = consumption_rate_welder
		tool_behaviour = TOOL_WELDER
		to_chat(user, "<span class='notice'> You swap to welder mode.</span>")
	else
		status = FLAMETHROWERMODE
		consumption_rate = initial(consumption_rate)
		tool_behaviour = null
		to_chat(user, "<span class='notice'> You swap to flamethrower mode.</span>")
	update_icon()

/obj/item/flamethrower/advanced/examine(mob/user)
	. = ..()
	if(status == 2)
		. += "<span class='notice'>[src] is in welder mode.</span>"
	else
		. += "<span class='notice'>[src] is in flamethrower mode.</span>"

/obj/item/flamethrower/advanced/Initialize(mapload)
	. = ..()
	if(create_with_tank)
		ptank = new /obj/item/tank/plasma/full(src)
	update_icon()

/obj/item/flamethrower/advanced/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	if(attack_type == MELEE_ATTACK) //this is a pretty study flamethrower
		final_block_chance = 33

/obj/item/flamethrower/advanced/tank
	create_with_tank = TRUE

//////// advanced flamethrower actions //////

/datum/action/item_action/toggle_flamethrowermode
	name = "Toggle Flamethrower mode"
