/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
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
	origin_tech = "combat=1;plasmatech=2;engineering=2"
	var/status = FALSE
	var/lit = FALSE	//on or off
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/plasma/ptank = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter


/obj/item/flamethrower/Destroy()
	QDEL_NULL(weldtool)
	QDEL_NULL(igniter)
	QDEL_NULL(ptank)
	return ..()


/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = M.loc
	if(isturf(location)) //start a fire if possible
		igniter.flamethrower_process(location)


/obj/item/flamethrower/update_icon()
	cut_overlays()
	if(igniter)
		add_overlay("+igniter[status]")
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(user && user.get_active_hand() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			add_attack_logs(user, target, "Flamethrowered at [target.x],[target.y],[target.z]")
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/I, mob/user, params)
	if(iswrench(I) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.forceMove(T)
			weldtool = null
		if(igniter)
			igniter.forceMove(T)
			igniter = null
		if(ptank)
			ptank.forceMove(T)
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	else if(isscrewdriver(I) && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	else if(isigniter(I))
		var/obj/item/assembly/igniter/IG = I
		if(IG.secured)
			return
		if(igniter)
			return
		if(!user.drop_item())
			return
		IG.forceMove(src)
		igniter = IG
		update_icon()
		return

	else if(istype(I, /obj/item/tank/plasma))
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


/obj/item/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/AltClick(mob/user)
	if(ptank && isliving(user) && user.Adjacent(src))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, "<span class='notice'>You remove the plasma tank from [src]!</span>")
		update_icon()

/obj/item/flamethrower/examine(mob/user)
	..()
	if(ptank)
		to_chat(user, "<span class='notice'>[src] has \a [ptank] attached. Alt-click to remove it.</span>")

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(!status)
		to_chat(user, "<span class='notice'>Secure the igniter first!</span>")
		return
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	lit = !lit
	if(lit)
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		STOP_PROCESSING(SSobj,src)
	update_icon()

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	weldtool.status = FALSE
	igniter.secured = FALSE
	status = TRUE
	update_icon()

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
			continue	//so we don't burn the tile we be standin on
		if(!T.CanAtmosPass(previousturf))
			break
		if(igniter)
			igniter.ignite_turf(src, T)
		else
			default_ignite(T)
		sleep(1)
		previousturf = T
	operating = FALSE
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)


/obj/item/flamethrower/proc/default_ignite(turf/target, release_amount = 0.05)
	//TODO: DEFERRED Consider checking to make sure tank pressure is high enough before doing this...
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	if(air_transfer.toxins)
		air_transfer.toxins = air_transfer.toxins * 5
	target.assume_air(air_transfer)
	//Burn it based on transfered gas
	target.hotspot_expose((ptank.air_contents.temperature*2) + 380, 500)
	//location.hotspot_expose(1000,500,1)
	SSair.add_to_active(target, 0)


/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		weldtool.status = FALSE
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			ptank = new /obj/item/tank/plasma/full(src)
		update_icon()

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>[attack_text] hits the fueltank on [owner]'s [src], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
		igniter.ignite_turf(src,target_turf, release_amount = 100)
		QDEL_NULL(ptank)
		return 1 //It hit the flamethrower, not them

/obj/item/assembly/igniter/proc/flamethrower_process(turf/simulated/location)
	location.hotspot_expose(700, 2)

/obj/item/assembly/igniter/proc/ignite_turf(obj/item/flamethrower/F, turf/simulated/location, release_amount = 0.05)
	F.default_ignite(location, release_amount)