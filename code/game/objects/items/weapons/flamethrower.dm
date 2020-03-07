/obj/item/flamethrower //do not spawn
	name = "flamethrower"
	desc = "how did you get this?"
	var/lit = FALSE	//on or off
	var/operating = FALSE//cooldown
	var/warned_admins = FALSE //for the message_admins() when lit
	var/consumption_rate = 0 //for flame intensity and fuel useage 
	var/efficiency = 1 // higher is worse
	var/obj/item/tank/plasma/ptank = null

/obj/item/flamethrower/process()
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		location.hotspot_expose(700, 2)
	if(prob(5)) //sometimes consume full
		consume_fuel(consumption_rate)
	..()

/obj/item/flamethrower/attack_self(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(ptank.air_contents.toxins < 5)
		to_chat(user, "<span class='notice'>Plasma tank is low on plasma!</span>")
		return
	if(!warned_admins)
		message_admins("[ADMIN_LOOKUPFLW(user)] has lit a [src].")
		warned_admins = TRUE
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	toggle_igniter()

/obj/item/flamethrower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/plasma))
		if(ptank)
			if(user.drop_item())
				I.forceMove(src)
				ptank.forceMove(get_turf(src))
				ptank = I
				to_chat(user, "<span class='notice'>You swap the plasma tank in [src]!</span>")
			return
		if(!user.drop_item())
			return
		I.forceMove(src)
		ptank = I
		update_icon()
		return

	else if(istype(I, /obj/item/analyzer) && ptank)
		atmosanalyzer_scan(ptank.air_contents, user)
	else
		return ..()

//turn it on or off, also informs the admins
/obj/item/flamethrower/proc/toggle_igniter(turn_off = FALSE)
	lit = turn_off ? FALSE : !lit
	if(lit)
		START_PROCESSING(SSobj, src)		
	else
		STOP_PROCESSING(SSobj,src)
	update_icon()

obj/item/flamethrower/proc/consume_fuel(amount) 
	ptank.air_contents.remove_ratio(amount * efficiency)
	if(ptank.air_contents.toxins < 5)
		toggle_igniter(TRUE)
		
/obj/item/flamethrower/proc/ignite_turf(obj/item/flamethrower/F, turf/simulated/location, release_amount = 0.05)
	F.default_ignite(location, release_amount)

/obj/item/flamethrower/proc/default_ignite(turf/target, amount)
	var/turf/simulated/target_turf = target
	if(istype(target_turf))
		target_turf.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, 29.11 * amount) //based on the moles of plasma in a full plasma tank
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
		default_ignite(T, consumption_rate)
		sleep(1)
		previousturf = T
	operating = FALSE
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)

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
	consumption_rate = 0.04
	efficiency = 6
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
	if(lit)
		if(user && user.get_active_hand() == src) // Make sure our user is still holding us
			fireline(target, user)
			consume_fuel(consumption_rate)
	

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


/obj/item/flamethrower/basic/AltClick(mob/user)
	if(lit)
		to_chat(user, "<span class='notice'> turn off [src] first!</span>")
	else if(ptank && isliving(user) && user.Adjacent(src))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, "<span class='notice'>You remove the plasma tank from [src]!</span>")
		update_icon()


/obj/item/flamethrower/basic/examine(mob/user)
	. = ..()
	if(ptank)
		. += "<span class='notice'>[src] has \a [ptank] attached. Alt-click to remove it.</span>"


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


/obj/item/flamethrower/basic/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
		ignite_turf(src,target_turf, release_amount = 1)
		QDEL_NULL(ptank)
		return 1 //It hit the flamethrower, not them


/obj/item/flamethrower/basic/full
	create_full = TRUE

/obj/item/flamethrower/basic/full/tank
	create_with_tank = TRUE

